//
//  WelcomeViewModel.swift
//  Wolt
//
//  Created by Awais Akram on 7.7.2024.
//

import UIKit
import CoreLocation
import Combine

protocol WelcomeViewModelProtocol {
    var locationPermissionStatus: PassthroughSubject<CLAuthorizationStatus?, Never> { get }
    var locationPermissionDenied: PassthroughSubject<Void, Never> { get }
    var locationPermissionGranted: PassthroughSubject<Void, Never> { get }
    var getSettingsAlertController: UIAlertController { get }
    var isLocationPermissionGranted: Bool { get }
    func requestLocationPermissions()
}

class WelcomeViewModel: WelcomeViewModelProtocol {

    // MARK: - Variables
    private var cancellables = Set<AnyCancellable>()
    private var locationManager: LocationManaging

    // MARK: - Publishers
    var locationPermissionStatus = PassthroughSubject<CLAuthorizationStatus?, Never>()
    var locationPermissionDenied = PassthroughSubject<Void, Never>()
    var locationPermissionGranted = PassthroughSubject<Void, Never>()


    // MARK: - init
    init(locationManager: LocationManaging = LocationManager.shared) {
        self.locationManager = locationManager
        (self.locationManager as? LocationManager)?.delegate = self
        setupBindings()
    }

    private func setupBindings() {
        locationManager.authorizationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] authorizationStatus in
                guard let self = self else { return }
                self.didReceiveAuthorizationStatus(authorizationStatus)
            }
            .store(in: &cancellables)
    }

    var isLocationPermissionGranted: Bool {
        return locationManager.isLocationPermissionGranted
    }

    func didReceiveAuthorizationStatus(_ status: CLAuthorizationStatus) {
        locationPermissionStatus.send(status)

        switch status {
        case .restricted, .denied:
            locationPermissionDenied.send()
        case .authorizedWhenInUse, .authorizedAlways:
            locationPermissionGranted.send()
        default:
            break
        }
    }

    func requestLocationPermissions() {
        locationManager.requestLocationPermissions()
    }

    var getSettingsAlertController: UIAlertController {
        let alertController = UIAlertController(
            title: "Location Access Needed",
            message: "In order to see the nearby restaurants, please enable location services in the Settings.",
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(title: "Open settings", style: .default) { (_) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)

        return alertController
    }
}

// MARK: - LocationManagerDelegate
extension WelcomeViewModel: LocationManagerDelegate {

    func locationManagerDidUpdateLocation(_ location: CLLocation) {
        print("WelcomeViewModel.locationManagerDidUpdateLocation", location)
        print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
    }

    func locationManagerDidFailWithError(_ error: Error) {
        print("WelcomeViewModel.locationManagerDidFailWithError", error)
        locationManager.stopUpdatingLocation()
    }
}
