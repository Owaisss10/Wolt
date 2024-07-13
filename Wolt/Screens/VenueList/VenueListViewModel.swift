//
//  VenueListViewModel.swift
//  Wolt
//
//  Created by Awais Akram on 7.7.2024.
//

import UIKit
import Combine
import CoreData
import CoreLocation

protocol VenueListViewModelProtocol: AnyObject {
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorStatePublisher: CurrentValueSubject<ErrorState?, Never> { get }
    var restaurantsPublisher: CurrentValueSubject<[Restaurant], Never> { get }
    var nextViewControllerPublisher: PassthroughSubject<UIViewController, Never> { get }
    var currentAreaName: CurrentValueSubject<String, Never> { get }
    func saveFavoriteState(for venueId: String?, isFavorite: Bool?)
    func stopUpdatingLocation()
}

class VenueListViewModel: VenueListViewModelProtocol {

    // MARK: - Variables
    let service: RestaurantsServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var locationManager: LocationManaging

    // MARK: - Publishers
    @Published var isLoading = false
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var restaurantsPublisher = CurrentValueSubject<[Restaurant], Never>([])
    var errorStatePublisher = CurrentValueSubject<ErrorState?, Never>(nil)
    var nextViewControllerPublisher = PassthroughSubject<UIViewController, Never>()
    var currentAreaName = CurrentValueSubject<String, Never>("Nearby restaurants")

    // MARK: - init
    init(
        service: RestaurantsServiceProtocol,
        locationManager: LocationManaging = LocationManager.shared
    ) {
        self.service = service
        self.locationManager = locationManager
        (self.locationManager as? LocationManager)?.delegate = self
        setupBindings()
        self.locationManager.startUpdatingLocation(every: 10)
    }

    private func setupBindings() {
        locationManager.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.getNearbyRestaurantsIn(location: location)
                self?.fetchAddress(for: location)
            }
            .store(in: &cancellables)

        locationManager.addressPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] address in
                guard let self = self,
                      let address else { return }
                print("Address: \(address)")
                self.currentAreaName.send("Showing restaurants in \n\(address)")
            }
            .store(in: &cancellables)
    }

    // MARK: - Load data
    func getNearbyRestaurantsIn(location: CLLocation) {

        self.isLoading = true

        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        print("Current location: \(lat), \(lon)")
        // let lat = 60.22580563115522
        // let lon = 25.06259609234061

        self.service.getNearbyRestaurants(for: Location(
            latitude: lat,
            longitude: lon
        ))
        .sink( receiveCompletion: { [weak self] in
            if case let .failure(error) = $0 {
                self?.handleError(error)
            }
        }, receiveValue: { [weak self] in
            self?.handleRestaurantsList($0)
        })
        .store(in: &self.cancellables)
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    private func handleRestaurantsList(_ restaurants: [Restaurant]) {
        isLoading = false
        // Match the restaurants coming from server with locally saved restaurants
        let restaurantsWithFavoriteState = self.matchRestaurantsWithFavoriteState(
            restaurants: restaurants
        )

        restaurantsPublisher.send(restaurantsWithFavoriteState)
        errorStatePublisher.send(nil)
    }


    // MARK: Error handling
    private func handleError(_ error: Error) {
        isLoading = false

        var errorState = ErrorState.unknownError

        let networkError = NetworkError(error)

        switch(networkError) {
        case .notConnectedToInternet:
            errorState = ErrorState.networkOffline
        case .other, .timedOut:
            errorState = ErrorState.serverError
        }

        if let restaurantsServiceError = error as? RestaurantsServiceError {
            errorState = ErrorState.customError(errorMessage: restaurantsServiceError.message)
        } else if let httpError = error as? HTTPError,
                  case let .any(response) = httpError,
                  let statusCode = response.httpStatusCode {
            if statusCode == -1009 {
                errorState = ErrorState.networkOffline
            } else {
                errorState = ErrorState.serverError
            }

        }
        showErrorState(errorState)
    }

    private func showErrorState(_ errorState: ErrorState) {
        restaurantsPublisher.send([])
        errorStatePublisher.send(errorState)
    }

    func presentAlertFor(_ message: ErrorMessage?) {
        guard let message = message else { return }
        let alertController = UIAlertController(
            title: message.title,
            message: message.body,
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(title: "OK", style: .default, handler: nil)
        )
        nextViewControllerPublisher.send(alertController)
    }

    private func fetchAddress(for location: CLLocation) {
        locationManager.getAddressFromLatLon(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
}

// MARK: - LocationManagerDelegate
extension VenueListViewModel: LocationManagerDelegate {

    func locationManagerDidUpdateLocation(_ location: CLLocation) {
        print("VenueListViewModel.locationManagerDidUpdateLocation", location)
        fetchAddress(for: location)
    }

    func locationManagerDidFailWithError(_ error: Error) {
        print("VenueListViewModel.locationManagerDidFailWithError", error)
        handleError(error)
    }
}

// MARK: - Core Data methods

// TODO: Start using Combne?

extension VenueListViewModel {
    func saveFavoriteState(for venueId: String?, isFavorite: Bool? = false) {
        let context = CoreDataManager.shared.context
        guard let venueId else { return }

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteItem")
        fetchRequest.predicate = NSPredicate(format: "id == %@", venueId)

        do {
            let results = try context.fetch(fetchRequest)
            if let venue = results.first {
                venue.setValue(isFavorite, forKey: "isFavorite")
            } else {
                let entity = NSEntityDescription.entity(forEntityName: "FavoriteItem", in: context)!
                let newVenue = NSManagedObject(entity: entity, insertInto: context)
                newVenue.setValue(venueId, forKey: "id")
                newVenue.setValue(isFavorite, forKey: "isFavorite")
            }
            try context.save()
        } catch {
            print("Failed to fetch or save venue: \(error)")
        }
    }

    func matchRestaurantsWithFavoriteState(restaurants: [Restaurant]) -> [Restaurant] {
        let context = CoreDataManager.shared.context
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteItem")

        do {
            let favoriteItems = try context.fetch(fetchRequest)
            var restaurantsWithFavoriteState: [Restaurant] = []

            for restaurant in restaurants {
                if let favoriteRestaurant = favoriteItems.first(
                    where: { $0.value(forKey: "id") as? String == restaurant.venue?.id }
                ) {
                    let isFavorite = favoriteRestaurant.value(forKey: "isFavorite") as? Bool ?? false
                    var updatedRestaurant = restaurant
                    updatedRestaurant.isFavorite = isFavorite
                    restaurantsWithFavoriteState.append(updatedRestaurant)
                } else {
                    restaurantsWithFavoriteState.append(restaurant)
                }
            }

            return restaurantsWithFavoriteState
        } catch {
            print("Failed to fetch favorite restaurants: \(error)")
            return restaurants
        }
    }

}
