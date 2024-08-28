//
//  ServerConfig.swift
//  LittleCakesNLOrderBook
//
//  Created by Usman Siddiqui on 26/08/2024.
//

import Foundation

enum BaseUrl: String {
    case DEV = "API_DEV_FORM_ID"
    case RELEASE = "API_RELEASE_FORM_ID"
    case OLD = "API_RELEASE_FORM_ID_FIRST"
}

final class ServerConfig {
    static let shared: ServerConfig = ServerConfig()
    
    var baseURL: String = ""
    var collectionName: String = "submissions"
    
    private init() {
        setupServerConfig()
    }
    
    private func setupServerConfig() {
        
        #if DEV
        self.baseURL = ProcessInfo.processInfo.environment[BaseUrl.DEV.rawValue] ?? ""
        self.collectionName = "submissionsDev"
        #else
        self.baseURL = ProcessInfo.processInfo.environment[BaseUrl.RELEASE.rawValue] ?? ""
        self.collectionName = "submissions"
        #endif
    }
}
