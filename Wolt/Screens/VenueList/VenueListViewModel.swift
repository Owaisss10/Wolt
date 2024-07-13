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
    var currentAreaName = CurrentValueSubject<String, Never>("Nearby restaurants in \n-")

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
                guard let self = self else { return }
                self.getNearbyRestaurantsIn(location: location)
                self.fetchAddress(for: location)
            }
            .store(in: &cancellables)

        locationManager.addressPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] address in
                guard let self = self,
                      let address else { return }
                self.currentAreaName.send("Showing nearby restaurants in \n\(address)")
            }
            .store(in: &cancellables)
    }

    // MARK: - Load data
    func getNearbyRestaurantsIn(location: CLLocation) {

        isLoading = true

        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        print("Current location: \(lat), \(lon)")

        self.service.getNearbyRestaurants(for: CLLocation(
            latitude: lat,
            longitude: lon
        ))
        .sink( receiveCompletion: { [weak self] in
            guard let self = self else { return }
            if case let .failure(error) = $0 {
                self.handleError(error)
            }
        }, receiveValue: { [weak self] in
            guard let self = self else { return }
            self.processAndMatchFavoriteRestaurants($0)
        })
        .store(in: &self.cancellables)
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    private func processAndMatchFavoriteRestaurants(_ restaurants: [Restaurant]) {
        isLoading = false

        // Match the restaurants coming from server with locally saved restaurants
        matchRestaurantsWithFavoriteState(restaurants)
    }

    private func didReceiveRestaurants(_ restaurants: [Restaurant]) {
        restaurantsPublisher.send(restaurants)
        errorStatePublisher.send(nil)
    }

    // MARK: Error handling
    /// 1. Check for any `NetworkError`
    /// 2. Check for any `RestaurantsServiceError`
    /// 3. Check for any `HTTPError`
    private func handleError(_ error: Error) {
        isLoading = false

        var errorState = ErrorState.unknownError

        if let networkError = error as? NetworkError {
            switch(networkError) {
            case .notConnectedToInternet:
                errorState = ErrorState.networkOffline
            case .other, .timedOut:
                errorState = ErrorState.serverError
            }
        } else if let restaurantsServiceError = error as? RestaurantsServiceError {
            errorState = ErrorState.customError(errorMessage: restaurantsServiceError.message)
        } else if let httpError = error as? HTTPError,
                  case let .any(response) = httpError,
                  let statusCode = response.httpStatusCode {
            errorState = ErrorState.httpError(statusCode: statusCode)
        }
        showErrorState(errorState)
    }

    private func showErrorState(_ errorState: ErrorState) {
        restaurantsPublisher.send([])
        errorStatePublisher.send(errorState)
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

extension VenueListViewModel {

    func saveFavoriteState(for venueId: String?, isFavorite: Bool? = false) {
        guard let venueId = venueId else { return }

        CoreDataManager.shared.fetchFavoriteItem(withId: venueId)
            .flatMap { favoriteItem -> AnyPublisher<Void, Error> in
                let context = CoreDataManager.shared.context
                if let venue = favoriteItem {
                    venue.setValue(isFavorite, forKey: "isFavorite")
                } else {
                    let entity = NSEntityDescription.entity(forEntityName: "FavoriteItem", in: context)!
                    let newVenue = NSManagedObject(entity: entity, insertInto: context)
                    newVenue.setValue(venueId, forKey: "id")
                    newVenue.setValue(isFavorite, forKey: "isFavorite")
                }
                return CoreDataManager.shared.saveContext()
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Failed to save favorite state: \(error)")
                }
            }, receiveValue: {
                print("Favorite state saved successfully")
            })
            .store(in: &cancellables)
    }

    func matchRestaurantsWithFavoriteState(_ restaurants: [Restaurant]) {
        CoreDataManager.shared.fetchFavoriteItems()
            .map { favoriteItems -> [Restaurant] in
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
            }
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Failed to match restaurants with favorite state: \(error)")
                    self.handleError(error)
                }
            }, receiveValue: { matchedRestaurants in
                self.didReceiveRestaurants(matchedRestaurants)
            })
            .store(in: &cancellables)
    }
}
