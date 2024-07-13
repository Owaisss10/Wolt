//
//  AppDelegate.swift
//  Wolt
//
//  Created by Awais Akram on 5.7.2024.
//

import UIKit
import Combine

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private var cancellables = Set<AnyCancellable>()
    var locationManager = LocationManager.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if locationManager.isLocationPermissionGranted {
            locationManager.startUpdatingLocation(every: 10)
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // This method is called when the app is about to move from active to inactive state.
        // This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
        // or when the user quits the app and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
        saveContext()
    }

    // This method is called when the app is about to terminate
    func applicationWillTerminate(_ application: UIApplication) {
        // Saves changes in the application's managed object context before the application terminates.
        saveContext()
        locationManager.stopUpdatingLocation()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        saveContext()
        locationManager.startUpdatingLocation(every: 10)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        locationManager.startUpdatingLocation(every: 10)
    }

    private func saveContext() {
        CoreDataManager.shared.saveContext()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Successfully saved context")
                case .failure(let error):
                    print("Failed to save context: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}

