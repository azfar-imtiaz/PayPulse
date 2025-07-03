//
//  KeychainHelper.swift
//  PayPulse
//
//  Created by Azfar Imtiaz on 2025-07-03.
//

import Foundation
import OSLog

class KeychainHelper {
    private static let logger = Logger(subsystem: "PayPulse", category: "KeychainHelper")
    
    static func save(key: String, value: String) {
        // TODO: Implement actual Keychain storing logic here
        // this is not secure - just a placeholder for now
        UserDefaults.standard.set(value, forKey: key)
        Self.logger.debug("(keychainHelper): Saved key '\(key, privacy: .public)'")
    }
    
    static func load(key: String) -> String? {
        // TODO: Implement actual Keychain loading logic here
        // this is not secure - just a placeholder for now
        let value = UserDefaults.standard.string(forKey: key)
        Self.logger.debug("(keychainHelper): Loaded key '\(key, privacy: .public)'")
        return value
    }
    
    static func delete(key: String) {
        // TODO: Implement actual Keychain deletion logic here
        // this is not secure - just a placeholder for now
        UserDefaults.standard.removeObject(forKey: key)
        Self.logger.debug("(keychainHelper): Removed '\(key, privacy: .public)'")
    }
}
