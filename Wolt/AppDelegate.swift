//
//  AppDelegate.swift
//  Wolt
//
//  Created by Awais Akram on 5.7.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let locationManager = LocationManager.shared
    private let coreDataManager = CoreDataManager.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // This method is called when the app is about to move from active to inactive state.
        // This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
        // or when the user quits the app and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
        coreDataManager.saveContext()
    }

    // This method is called when the app is about to terminate
    func applicationWillTerminate(_ application: UIApplication) {
        // Saves changes in the application's managed object context before the application terminates.
        coreDataManager.saveContext()
        locationManager.stopUpdatingLocation()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        coreDataManager.saveContext()
        locationManager.startUpdatingLocation(every: 10)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        locationManager.startUpdatingLocation(every: 10)
    }
}

