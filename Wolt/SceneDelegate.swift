//
//  SceneDelegate.swift
//  Wolt
//
//  Created by Awais Akram on 5.7.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private let locationManager = LocationManager.shared
    private let coreDataManager = CoreDataManager.shared

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // We have removed the storyboard from this project
        // We will programatically set the first/welcome ViewController below
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let welcomeViewController = WelcomeViewController(viewModel: WelcomeViewModel())
        let navigationController = UINavigationController(rootViewController: welcomeViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Release any resources associated with this scene.
        // Save data and stop listening to location updates.
        coreDataManager.saveContext()
        stopLocationUpdates()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Restart tasks that were paused or not started when the scene was inactive.
        startLocationUpdates()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Pause tasks that are about to move from active to inactive state.
        // Save data and stop listening to location updates.
        coreDataManager.saveContext()
        stopLocationUpdates()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Start listening to location updates when coming to foreground.
        startLocationUpdates()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save data and Start listening to location updates when going to background.
        coreDataManager.saveContext()
        stopLocationUpdates()
    }

    private func startLocationUpdates() {
        if locationManager.isLocationPermissionGranted {
            locationManager.startUpdatingLocation(every: 10)
        }
    }

    private func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
}

