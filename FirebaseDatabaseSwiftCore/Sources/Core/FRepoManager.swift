//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 24/04/2022.
//

import Foundation

class FRepoManager {
    private static var lock = NSLock()
    private static var configs: [String: [FRepoInfo: FRepo]] = [:]

    /**
     * Used for legacy unit tests.  The public API should go through
     * FirebaseDatabase which calls createRepo.
     */

    class func getRepo(_ repoInfo: FRepoInfo, config: DatabaseConfig) -> FRepo {
        // XXX TODO: NO objc_sync on non-Darwin
//        objc_sync_enter(configs)
//        defer {
//            objc_sync_exit(configs)
//        }
        lock.lock()
        defer { lock.unlock() }
        let repos = configs[config.sessionIdentifier]
        if let repo = repos?[repoInfo] {
            return repo
        } else {
            // Calling this should create the repo.
            _ = Database.createDatabaseForTests(repoInfo, config: config)
            // XXX TODO FORCE UNWRAP
            return configs[config.sessionIdentifier]![repoInfo]!
        }
    }

    class func createRepo(_ repoInfo: FRepoInfo, config: DatabaseConfig, database: Database) -> FRepo {
        config.freeze()
        // XXX TODO: NO objc_sync on non-Darwin
//        objc_sync_enter(configs)
//        defer {
//            objc_sync_exit(configs)
//        }
        lock.lock()
        defer { lock.unlock() }
        var repos = configs[config.sessionIdentifier, default: [:]]
        if repos[repoInfo] != nil {
            fatalError("createRepo called for Repo that already exists.")
        } else {
            let repo = FRepo(repoInfo: repoInfo, config: config, database: database)
            repos[repoInfo] = repo
            configs[config.sessionIdentifier] = repos
            return repo
        }
    }

    class func interruptAll() {
        DatabaseQuery.sharedQueue.async {
            for repos in configs.values {
                for repo in repos.values {
                    repo.interrupt()
                }
            }
        }
    }
    
    class func interrupt(_ config: DatabaseConfig) {
        DatabaseQuery.sharedQueue.async {
            guard let repos = configs[config.sessionIdentifier] else { return }
            for repo in repos.values {
                repo.interrupt()
            }
        }
    }
    class func resumeAll() {
        DatabaseQuery.sharedQueue.async {
            for repos in configs.values {
                for repo in repos.values {
                    repo.resume()
                }
            }
        }

    }
    class func resume(_ config: DatabaseConfig) {
        DatabaseQuery.sharedQueue.async {
            guard let repos = configs[config.sessionIdentifier] else { return }
            for repo in repos.values {
                repo.resume()
            }
        }
    }
    class func disposeRepos(_ config: DatabaseConfig) {
        // Do this synchronously to make sure we release our references to LevelDB
        // before returning, allowing LevelDB to close and release its exclusive
        // locks.
        DatabaseQuery.sharedQueue.sync {
            FFLog("I-RDB040001", "Disposing all repos for Config with name \(config.sessionIdentifier)")
            guard let repos = configs[config.sessionIdentifier] else { return }
            for repo in repos.values {
                repo.dispose()
            }
            configs.removeValue(forKey: config.sessionIdentifier)
        }
    }
}
