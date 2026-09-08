//
//  RestaurantsServiceError.swift
//  Wolt
//
//  Created by Awais Akram on 7.7.2024.
//

import Foundation

enum RestaurantsServiceError: Error {

    case noRestaurants
    case unknown
}

extension RestaurantsServiceError {

    var message: ErrorMessage {
        switch self {

        case .noRestaurants:
            return ErrorMessage(
                title: "No restaurants available",
                body: "Wolt is unable to get any restaurants in your area right now."
            )
            
        case .unknown:
            return ErrorMessage(
                title: "Something went wrong",
                body: "Sorry, an unknown error occurred. Please try again later."
            )

        }
    }

}

