//
//  LittleCakesNLOrderBookApp.swift
//  LittleCakesNLOrderBook
//
//  Created by Usman Siddiqui on 22/08/2024.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        EnvLoader.loadEnv()
        let _ = ServerConfig.shared
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct LittleCakesNLAgenaApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            BottomTabView()
                .environmentObject(FirestoreManager.shared)
        }
    }
}
