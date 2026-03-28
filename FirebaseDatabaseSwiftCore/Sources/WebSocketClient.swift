//
//  WebSocketClient.swift
//  WebSocketClient
//
//  Created by Morten Bek Ditlevsen on 09/09/2021.
//

import Foundation
import Logging
import NIOCore
import NIOPosix
import NIOHTTP1
import NIOWebSocket
import NIOSSL

private enum WebSocketClientError: Error {
    case invalidURL(String)
    case tlsSetupFailed(Error)
}

final class WebSocketClient {
    private let webSocketHandler: WebSocketHandler
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    // Bootstrap creation can fail during TLS setup; store the result so open()
    // can throw a meaningful error rather than crashing at init time.
    private let bootstrapResult: Result<ClientBootstrap, Error>
    private let url: URL
    private static let logger = Logger(label: "com.google.firebase.database.websocket")

    func open() throws {
        let bootstrap = try bootstrapResult.get()
        guard let host = url.host else {
            throw WebSocketClientError.invalidURL("URL has no host: \(url)")
        }
        _ = try bootstrap.connect(host: host, port: url.port ?? 443).wait()
    }

    func close() {
        guard let context = webSocketHandler.context else {
            Self.logger.warning("close() called but WebSocket context is unavailable")
            return
        }

        context.eventLoop.execute {
            _ = context.close()
        }
    }

    func send(data: Data) {
        webSocketHandler.send(data: data)
    }

    func send(string: Substring) {
        webSocketHandler.send(string: string)
    }

    func send(string: String) {
        webSocketHandler.send(string: string)
    }

    init(url: URL,
         headers: HTTPHeaders,
         onOpen: @escaping () -> Void,
         onMessage: @escaping (String) -> Void,
         onClose: @escaping () -> Void) {
        self.url = url
        self.webSocketHandler = WebSocketHandler(
            onOpen: onOpen,
            onMessage: onMessage,
            onClose: onClose
        )

        let httpHandler = HTTPInitialRequestHandler(url: url, headers: headers)
        let configuration = TLSConfiguration.makeClientConfiguration()

        do {
            let sslContext = try NIOSSLContext(configuration: configuration)

            let bootstrap = ClientBootstrap(group: group)
                .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
                .channelInitializer { [webSocketHandler] channel in
                    do {
                        // url.host may be nil for invalid URLs; passing nil to
                        // NIOSSLClientHandler disables SNI but still allows TLS.
                        let sslHandler = try NIOSSLClientHandler(
                            context: sslContext,
                            serverHostname: url.host
                        )

                        let websocketUpgrader = NIOWebSocketClientUpgrader(
                            upgradePipelineHandler: { (channel: Channel, _: HTTPResponseHead) in
                                channel.pipeline.addHandler(webSocketHandler)
                            }
                        )

                        let config: NIOHTTPClientUpgradeConfiguration = (
                            upgraders: [websocketUpgrader],
                            completionHandler: { _ in
                                channel.pipeline.removeHandler(httpHandler, promise: nil)
                            }
                        )

                        return channel.pipeline.addHandler(sslHandler).flatMap {
                            channel.pipeline.addHTTPClientHandlers(
                                leftOverBytesStrategy: .forwardBytes,
                                withClientUpgrade: config
                            ).flatMap {
                                channel.pipeline.addHandler(httpHandler)
                            }
                        }
                    } catch {
                        return channel.eventLoop.makeFailedFuture(error)
                    }
                }

            self.bootstrapResult = .success(bootstrap)
        } catch {
            Self.logger.error("TLS context creation failed: \(error)")
            self.bootstrapResult = .failure(WebSocketClientError.tlsSetupFailed(error))
        }
    }
}

private final class HTTPInitialRequestHandler: ChannelInboundHandler, RemovableChannelHandler {
    public typealias InboundIn = HTTPClientResponsePart
    public typealias OutboundOut = HTTPClientRequestPart

    public let url: URL
    private let extraHeaders: HTTPHeaders
    private static let logger = Logger(label: "com.google.firebase.database.websocket.http")

    init(url: URL, headers: HTTPHeaders) {
        self.url = url
        self.extraHeaders = headers
    }

    func channelActive(context: ChannelHandlerContext) {
        Self.logger.debug("Client connected to \(context.remoteAddress?.description ?? "unknown")")

        var headers = HTTPHeaders()
        headers.add(name: "Host", value: "\(url.host ?? ""):\(url.port ?? 443)")
        headers.add(name: "Content-Type", value: "text/plain; charset=utf-8")
        headers.add(name: "Content-Length", value: "\(0)")
        headers.add(contentsOf: extraHeaders)

        let uri = url.path + (url.query.map { "?\($0)" } ?? "")

        let requestHead = HTTPRequestHead(version: .http1_1,
                                          method: .GET,
                                          uri: uri,
                                          headers: headers)

        context.write(self.wrapOutboundOut(.head(requestHead)), promise: nil)

        let body = HTTPClientRequestPart.body(.byteBuffer(ByteBuffer()))
        context.write(self.wrapOutboundOut(body), promise: nil)

        context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let clientResponse = self.unwrapInboundIn(data)

        Self.logger.error("WebSocket upgrade failed")

        switch clientResponse {
        case .head(let responseHead):
            Self.logger.error("Received HTTP status: \(responseHead.status)")
        case .body(let byteBuffer):
            let string = String(buffer: byteBuffer)
            Self.logger.debug("Received body from server: \(string)")
        case .end:
            Self.logger.debug("Closing channel after failed upgrade")
            context.close(promise: nil)
        }
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        Self.logger.error("HTTP handler error: \(error)")
        context.close(promise: nil)
    }
}

private final class WebSocketHandler: ChannelInboundHandler {
    typealias InboundIn = WebSocketFrame
    typealias OutboundOut = WebSocketFrame

    var context: ChannelHandlerContext?
    private let onClose: () -> Void
    private let onMessage: (String) -> Void
    private let onOpen: () -> Void
    private static let logger = Logger(label: "com.google.firebase.database.websocket.handler")

    init(onOpen: @escaping () -> Void,
         onMessage: @escaping (String) -> Void,
         onClose: @escaping () -> Void) {
        self.onOpen = onOpen
        self.onClose = onClose
        self.onMessage = onMessage
    }

    func handlerAdded(context: ChannelHandlerContext) {
        self.context = context
        onOpen()
    }

    func send(data: Data) {
        guard let stringData = String(data: data, encoding: .utf8) else { return }
        self.send(string: stringData[...])
    }

    func send(string: Substring) {
        self.send(stringData: string, x: { $0.channel.allocator.buffer(substring: $1) })
    }

    func send(string: String) {
        self.send(stringData: string, x: { $0.channel.allocator.buffer(string: $1) })
    }

    func send<T: StringProtocol>(stringData: T, x: @escaping (ChannelHandlerContext, T) -> ByteBuffer) {
        guard let context = context else { return }
        let send = {
            let buffer = x(context, stringData)
            let frame = WebSocketFrame(fin: true, opcode: .text, maskKey: .random(), data: buffer)
            context.write(self.wrapOutboundOut(frame), promise: nil)
            context.flush()
        }
        if !context.eventLoop.inEventLoop {
            context.eventLoop.execute(send)
        } else {
            send()
        }
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let frame = self.unwrapInboundIn(data)

        switch frame.opcode {
        case .text:
            var byteBuffer = frame.unmaskedData
            let string = byteBuffer.readString(length: byteBuffer.readableBytes) ?? ""
            onMessage(string)

        case .connectionClose:
            self.receivedClose(context: context, frame: frame)
        case .binary, .continuation, .ping, .pong:
            break
        default:
            self.closeOnError(context: context)
        }
    }

    func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }

    private func receivedClose(context: ChannelHandlerContext, frame: WebSocketFrame) {
        Self.logger.debug("Received close frame from server")
        context.close(promise: nil)
        onClose()
    }

    private func closeOnError(context: ChannelHandlerContext) {
        var data = context.channel.allocator.buffer(capacity: 2)
        data.write(webSocketErrorCode: .protocolError)
        let frame = WebSocketFrame(fin: true, opcode: .connectionClose, data: data)
        context.write(self.wrapOutboundOut(frame)).whenComplete { (_: Result<Void, Error>) in
            context.close(mode: .output, promise: nil)
        }
        onClose()
    }
}
