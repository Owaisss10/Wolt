//
//  LocationManager.swift
//  Wolt
//
//  Created by Awais Akram on 11.7.2024.
//

import Foundation
import CoreLocation
import Combine

protocol LocationManagerProtocol {
    var isLocationPermissionGranted: Bool { get }
    var locationPublisher: PassthroughSubject<CLLocation, Never> { get }
    var addressPublisher: PassthroughSubject<String?, Never> { get }
    var authorizationPublisher: CurrentValueSubject<CLAuthorizationStatus, Never> { get }

    func requestLocationPermissions()
    func startUpdatingLocation(every interval: TimeInterval)
    func stopUpdatingLocation()
    func getAddressFromLatLon(latitude: Double, longitude: Double)
}

class LocationManager: NSObject, LocationManagerProtocol {

    // MARK: - Variables
    static let shared = LocationManager()

    private let locationManager = CLLocationManager()
    private var locationUpdateTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    var locationPublisher = PassthroughSubject<CLLocation, Never>()
    var addressPublisher = PassthroughSubject<String?, Never>()
    var authorizationPublisher = CurrentValueSubject<CLAuthorizationStatus, Never>(.notDetermined)

    var isLocationPermissionGranted: Bool {
        let status = locationManager.authorizationStatus
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }

    // MARK: - initializer
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }

    // MARK: - Functions
    func requestLocationPermissions() {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }

    func startUpdatingLocation(every interval: TimeInterval) {
        stopUpdatingLocation()
        locationManager.startUpdatingLocation()
        locationUpdateTimer = Timer.scheduledTimer(
            timeInterval: interval,
            target: self,
            selector: #selector(requestLocation),
            userInfo: nil,
            repeats: true
        )
        print("startUpdatingLocation every \(interval) seconds")
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
    }

    @objc private func requestLocation() {
        locationManager.requestLocation()
    }

    // Convert latitude and longitude to address
    func getAddressFromLatLon(
        latitude: Double,
        longitude: Double
    ) {
        let location = CLLocation(latitude: latitude, longitude: longitude)

        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard error == nil else {
                print("Reverse geocoding error: \(error!.localizedDescription)")
                self?.addressPublisher.send(nil)
                return
            }

            guard let placemark = placemarks?.first else {
                print("No placemarks found")
                self?.addressPublisher.send(nil)
                return
            }

            var areaName = ""

            // Combine subLocality and subAdministrativeArea if available
            var parts: [String] = []
            if let subLocality = placemark.subLocality, !subLocality.isEmpty {
                parts.append(subLocality)
            }
            if let subAdministrativeArea = placemark.subAdministrativeArea, !subAdministrativeArea.isEmpty {
                parts.append(subAdministrativeArea)
            }

            areaName = parts.joined(separator: ", ")

            // If both are empty, fallback to higher-level properties
            if areaName.isEmpty {
                if let locality = placemark.locality, !locality.isEmpty {
                    areaName = locality
                } else if let administrativeArea = placemark.administrativeArea, !administrativeArea.isEmpty {
                    areaName = administrativeArea
                } else if let country = placemark.country, !country.isEmpty {
                    areaName = country
                } else {
                    areaName = Constants.DisplayMessages.unknownArea
                }
            }

            self?.addressPublisher.send(areaName)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationPublisher.send(location)
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        stopUpdatingLocation()
        print("Failed to get user location: \(error.localizedDescription)")
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                print("Location unknown.")
            case .denied:
                print("Location access denied.")
            case .headingFailure:
                print("Heading failure.")
            default:
                print("Failed to get user location: \(error.localizedDescription)")
            }
        } else {
            print("Failed to get user location: \(error.localizedDescription)")
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        switch status {
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        default:
            break
        }
        authorizationPublisher.send(status)
    }
}
