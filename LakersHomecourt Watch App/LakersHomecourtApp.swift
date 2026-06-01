//
//  LakersHomecourtApp.swift
//  LakersHomecourt Watch App
//
//  Created by AGRM on 04/03/26.
//

import SwiftUI
import UserNotifications
import WatchKit

@main
struct LakersHomecourt_Watch_AppApp: App {
    
    @WKApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, WKApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func applicationDidFinishLaunching() {
        UNUserNotificationCenter.current().delegate = self
        requestNotificationPermission()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    WKApplication.shared().registerForRemoteNotifications()
                }
            }
        }
    }
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device token: \(tokenString)")
        saveTokenToSupabase(token: tokenString)
    }
    
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        print("Failed to register: \(error.localizedDescription)")
    }
    
    private func saveTokenToSupabase(token: String) {
        guard let url = URL(string: "https://ptbcoxaguvbwprxdundz.supabase.co/rest/v1/device_tokens_watchos") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        request.setValue("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB0YmNveGFndXZid3ByeGR1bmR6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMzNDMzOTQsImV4cCI6MjA4ODkxOTM5NH0.gPMQ9zMFJZafkgQGjaoHBaacU787LhLpENcRMHFXpH8", forHTTPHeaderField: "apikey")
        request.setValue("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB0YmNveGFndXZid3ByeGR1bmR6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMzNDMzOTQsImV4cCI6MjA4ODkxOTM5NH0.gPMQ9zMFJZafkgQGjaoHBaacU787LhLpENcRMHFXpH8", forHTTPHeaderField: "Authorization")
        
        let body = ["device_token": token]
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Error saving token: \(error.localizedDescription)")
            } else {
                print("Token saved successfully")
            }
        }.resume()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
