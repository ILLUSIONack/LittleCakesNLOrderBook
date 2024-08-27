//
//  EnvLoader.swift
//  LittleCakesNLOrderBook
//
//  Created by Usman Siddiqui on 26/08/2024.
//
import Foundation

final class EnvLoader {
    
    static func loadEnv() {
        guard let filePath = Bundle.main.path(forResource: ".env", ofType: nil) else {
            print("⚠️ .env file not found in the bundle.")
            return
        }

        do {
            let contents = try String(contentsOfFile: filePath, encoding: .utf8)
            let lines = contents.split { $0.isNewline }
            
            for line in lines {
                let parts = line.split(separator: "=", maxSplits: 1).map { String($0) }
                
                if parts.count == 2 {
                    let key = parts[0].trimmingCharacters(in: .whitespaces)
                    let value = parts[1].trimmingCharacters(in: .whitespaces)
                    setenv(key, value, 1)
                }
            }
        } catch {
            print("⚠️ Could not load .env file: \(error)")
        }
    }
}
