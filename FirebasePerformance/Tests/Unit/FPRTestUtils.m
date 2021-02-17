// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "FirebasePerformance/Tests/Unit/FPRTestUtils.h"

#import "FirebasePerformance/Sources/FPRProtoUtils.h"
#import "FirebasePerformance/Sources/Gauges/Memory/FPRMemoryGaugeData.h"
#import "FirebasePerformance/Sources/Instrumentation/FPRNetworkTrace+Private.h"
#import "FirebasePerformance/Sources/Instrumentation/FPRNetworkTrace.h"
#import "FirebasePerformance/Sources/Timer/FIRTrace+Internal.h"
#import "FirebasePerformance/Sources/Timer/FIRTrace+Private.h"

#import "FirebasePerformance/ProtoSupport/PerfMetric.pbobjc.h"

static NSInteger const kLogSource = 462;  // LogRequest_LogSource_Fireperf

@implementation FPRTestUtils

#pragma mark - Test utility methods

+ (FIRTrace *)createRandomTraceWithName:(NSString *)traceName {
  FIRTrace *trace = [[FIRTrace alloc] initWithName:traceName];
  [trace start];
  [trace stop];
  // Make sure there are no sessions.
  trace.activeSessions = [NSMutableArray array];

  return trace;
}

+ (FIRTrace *)addVerboseSessionToTrace:(FIRTrace *)trace {
  FPRSessionDetails *details =
      [[FPRSessionDetails alloc] initWithSessionId:@"random" options:FPRSessionOptionsGauges];
  trace.activeSessions = [[NSMutableArray alloc] initWithObjects:details, nil];

  return trace;
}

+ (FPRMSGPerfMetric *)createRandomPerfMetric:(NSString *)traceName {
  FPRMSGPerfMetric *perfMetric = FPRGetPerfMetricMessage(@"RandomAppID");
  FIRTrace *trace = [FPRTestUtils createRandomTraceWithName:traceName];
  // Make sure there are no sessions.
  trace.activeSessions = [NSMutableArray array];
  perfMetric.traceMetric = FPRGetTraceMetric(trace);

  return perfMetric;
}

+ (FPRMSGPerfMetric *)createVerboseRandomPerfMetric:(NSString *)traceName {
  FPRMSGPerfMetric *perfMetric = FPRGetPerfMetricMessage(@"RandomAppID");
  FIRTrace *trace = [FPRTestUtils createRandomTraceWithName:traceName];
  trace = [FPRTestUtils addVerboseSessionToTrace:trace];
  perfMetric.traceMetric = FPRGetTraceMetric(trace);

  return perfMetric;
}

+ (FPRMSGPerfMetric *)createRandomInternalPerfMetric:(NSString *)traceName {
  FPRMSGPerfMetric *perfMetric = FPRGetPerfMetricMessage(@"RandomAppID");

  FIRTrace *trace = [[FIRTrace alloc] initInternalTraceWithName:traceName];
  [trace start];
  [trace stop];
  // Make sure there are no sessions.
  trace.activeSessions = [NSMutableArray array];
  perfMetric.traceMetric = FPRGetTraceMetric(trace);

  return perfMetric;
}

+ (FPRMSGPerfMetric *)createRandomNetworkPerfMetric:(NSString *)url {
  FPRMSGPerfMetric *perfMetric = FPRGetPerfMetricMessage(@"RandomAppID");

  NSURL *URL = [NSURL URLWithString:url];
  NSURLRequest *URLRequest = [NSURLRequest requestWithURL:URL];
  FPRNetworkTrace *networkTrace = [[FPRNetworkTrace alloc] initWithURLRequest:URLRequest];
  [networkTrace start];
  [networkTrace checkpointState:FPRNetworkTraceCheckpointStateInitiated];
  [networkTrace checkpointState:FPRNetworkTraceCheckpointStateResponseReceived];

  NSDictionary<NSString *, NSString *> *headerFields = @{@"Content-Type" : @"text/json"};
  NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:URL
                                                            statusCode:200
                                                           HTTPVersion:@"HTTP/1.1"
                                                          headerFields:headerFields];
  [networkTrace didReceiveData:[NSData data]];
  [networkTrace didCompleteRequestWithResponse:response error:nil];
  networkTrace.activeSessions = [NSMutableArray array];
  perfMetric.networkRequestMetric = FPRGetNetworkRequestMetric(networkTrace);

  return perfMetric;
}

+ (FPRMSGPerfMetric *)createRandomGaugePerfMetric {
  FPRMSGPerfMetric *perfMetric = FPRGetPerfMetricMessage(@"RandomAppID");

  NSMutableArray<NSObject *> *gauges = [[NSMutableArray alloc] init];
  NSDate *date = [NSDate date];
  FPRMemoryGaugeData *memoryData = [[FPRMemoryGaugeData alloc] initWithCollectionTime:date
                                                                             heapUsed:5 * 1024
                                                                        heapAvailable:10 * 1024];
  [gauges addObject:memoryData];

  FPRMSGGaugeMetric *gaugeMetric = FPRGetGaugeMetric(gauges, @"123");
  perfMetric.gaugeMetric = gaugeMetric;

  return perfMetric;
}

+ (GDTCOREvent *)createRandomTraceGDTEvent:(NSString *)traceName {
  FPRMSGPerfMetric *perfMetric = [self createRandomPerfMetric:traceName];

  NSString *mappingID = [NSString stringWithFormat:@"%ld", (long)kLogSource];
  GDTCOREvent *gdtEvent = [[GDTCOREvent alloc] initWithMappingID:mappingID target:kGDTCORTargetCCT];
  gdtEvent.dataObject = [FPRGDTEvent gdtEventForPerfMetric:perfMetric];
  return gdtEvent;
}

+ (GDTCOREvent *)createRandomInternalTraceGDTEvent:(NSString *)traceName {
  FPRMSGPerfMetric *perfMetric = [self createRandomInternalPerfMetric:traceName];

  NSString *mappingID = [NSString stringWithFormat:@"%ld", (long)kLogSource];
  GDTCOREvent *gdtEvent = [[GDTCOREvent alloc] initWithMappingID:mappingID target:kGDTCORTargetCCT];
  gdtEvent.dataObject = [FPRGDTEvent gdtEventForPerfMetric:perfMetric];
  return gdtEvent;
}

+ (GDTCOREvent *)createRandomNetworkGDTEvent:(NSString *)url {
  FPRMSGPerfMetric *perfMetric = [self createRandomNetworkPerfMetric:url];

  NSString *mappingID = [NSString stringWithFormat:@"%ld", (long)kLogSource];
  GDTCOREvent *gdtEvent = [[GDTCOREvent alloc] initWithMappingID:mappingID target:kGDTCORTargetCCT];
  gdtEvent.dataObject = [FPRGDTEvent gdtEventForPerfMetric:perfMetric];
  return gdtEvent;
}

@end
