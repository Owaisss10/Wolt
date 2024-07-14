//
//  RestaurantsService.swift
//  Wolt
//
//  Created by Awais Akram on 7.7.2024.
//

import Foundation
import Combine
import CoreLocation

protocol RestaurantsServiceProtocol {
    
    func getNearbyRestaurants(for location: CLLocation) -> AnyPublisher<[Restaurant], Error>
}

class RestaurantsService: RestaurantsServiceProtocol {
    
    static var shared = RestaurantsService()
    
    private let urlSession = URLSession(configuration: .default)
    
    let queue = DispatchQueue(label: "Restaurants.\(UUID().uuidString)")
    
    
    var getRestaurantsPublisher: AnyPublisher<[Restaurant], Error>?
    
    func getNearbyRestaurants(for location: CLLocation) -> AnyPublisher<[Restaurant], Error> {
        
        return queue.sync { [weak self] in
            
            if let publisher = self?.getRestaurantsPublisher {
                return publisher
            }
            
            let baseUrlString = Constants.API.baseURL + Constants.API.restaurantsEndpoint

//            let latitude = location.coordinate.latitude
//            let longitude = location.coordinate.longitude

            // TODO: MOCK Location for Simulator
            let latitude = 60.225816043150196
            let longitude = 25.06250127220998

            guard let url = URL(string: "\(baseUrlString)?lat=\(latitude)&lon=\(longitude)") else {
                return Fail(
                    outputType: [Restaurant].self,
                    failure: URLError(.badURL)
                )
                .eraseToAnyPublisher()
            }
            
            let request = URLRequest(url: url)
            
            let publisher = self!.urlSession.defaultNetworking(request)
                .tryMap { (data: Data, response: URLResponse) -> [Restaurant] in
                    guard response.isHttpStatusCode(in: 200...299) else {
                        throw HTTPError.any(response: response)
                    }
                    
                    let restaurantsResponse = try JSONDecoder().decode(
                        RestaurantsResponse.self,
                        from: data
                    )

                    // TODO: Throw error for testing
//                    if Bool.random() {
//                        throw RestaurantsServiceError.noRestaurants
//                    }

                    guard let section = restaurantsResponse.sections?.last,
                          let restaurants = section.restaurants,
                          !restaurants.isEmpty
                    else {
                        throw RestaurantsServiceError.noRestaurants
                    }
                    // Use first 15 restaurants
                    return Array(restaurants.prefix(15))
                }
                .share()
                .handleEvents(receiveCompletion: { _ in
                    if self?.getRestaurantsPublisher != nil {
                        self?.getRestaurantsPublisher = nil
                    }
                })
                .eraseToAnyPublisher()
            
            self?.getRestaurantsPublisher = publisher
            
            return publisher
        }
    }
    
}
