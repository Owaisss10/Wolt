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
    var nextViewControllerPublisher: PassthroughSubject<UIViewController, Never> { get }
    var presentViewControllerPublisher: PassthroughSubject<UIViewController, Never> { get }

    var locationPermissionStatus: PassthroughSubject<CLAuthorizationStatus?, Never> { get }
    var locationPermissionDenied: PassthroughSubject<Void, Never> { get }
    var locationPermissionGranted: PassthroughSubject<Void, Never> { get }
    var isLocationPermissionGranted: Bool { get }
    func checkAndRequestLocationPermissions()
    func navigateToVenueListViewController()
    func presentSettingsAlertController()
}

class WelcomeViewModel: WelcomeViewModelProtocol {

    // MARK: - Variables
    private var cancellables = Set<AnyCancellable>()
    private var locationManager: LocationManagerProtocol

    // MARK: - Publishers
    var nextViewControllerPublisher = PassthroughSubject<UIViewController, Never>()
    var presentViewControllerPublisher = PassthroughSubject<UIViewController, Never>()
    var locationPermissionStatus = PassthroughSubject<CLAuthorizationStatus?, Never>()
    var locationPermissionDenied = PassthroughSubject<Void, Never>()
    var locationPermissionGranted = PassthroughSubject<Void, Never>()

    var isLocationPermissionGranted: Bool {
        return locationManager.isLocationPermissionGranted
    }

    // MARK: - init
    init(locationManager: LocationManagerProtocol = LocationManager.shared) {
        self.locationManager = locationManager
        setupBindings()
    }

    // MARK: - Functions
    private func setupBindings() {
        locationManager.authorizationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] authorizationStatus in
                guard let self = self else { return }
                self.didReceiveAuthorizationStatus(authorizationStatus)
            }
            .store(in: &cancellables)
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

    func checkAndRequestLocationPermissions() {
        // If location permissions are denied, show an alert dialog for navigating to settings and allowing location services
        // otherwise show location services prompt
        if locationManager.authorizationPublisher.value == .denied {
            presentSettingsAlertController()
        } else {
            locationManager.requestLocationPermissions()
        }
    }

    func navigateToVenueListViewController() {
        let venueListViewController = VenueListViewController(
            viewModel: VenueListViewModel(
                service: RestaurantsService()
            )
        )
        nextViewControllerPublisher.send(venueListViewController)
    }

    func presentSettingsAlertController() {
        presentViewControllerPublisher.send(getSettingsAlertController)
    }

    var getSettingsAlertController: UIAlertController {
        let alertController = UIAlertController(
            title: Constants.ErrorMessages.settingsAlertErrorTitle,
            message: Constants.ErrorMessages.settingsAlertErrorMessage,
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(
            title: Constants.ErrorMessages.openSettingsActionButtonTitle,
            style: .default
        ) { (_) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(
            title: Constants.ErrorMessages.cancelActionButtonTitle,
            style: .cancel,
            handler: nil
        )

        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)

        return alertController
    }
}
