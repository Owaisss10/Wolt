//
//  Constants.swift
//  Wolt
//
//  Created by Awais Akram on 14.7.2024.
//

import Foundation
import UIKit

struct Constants {

    struct API {
        static let baseURL = "https://restaurant-api.wolt.com/v1/pages"
        static let restaurantsEndpoint = "/restaurants"
    }

    struct UI {
        static let topPadding: CGFloat = 20.0
        static let bottomPadding: CGFloat = 20.0
        static let horizontalPadding: CGFloat = 20.0
        static let verticalPadding: CGFloat = 10.0
        static let buttonHeight: CGFloat = 50.0

        struct Colors {
            static let primaryColor = UIColor(red: 0.25, green: 0.47, blue: 0.85, alpha: 1.0)
            static let secondaryColor = UIColor(red: 0.85, green: 0.25, blue: 0.47, alpha: 1.0)
        }

        struct Fonts {
            static let title1 = UIFont.preferredFont(forTextStyle: .title1)
            static let title2 = UIFont.preferredFont(forTextStyle: .title2)
            static let body = UIFont.preferredFont(forTextStyle: .body)
            static let headline = UIFont.preferredFont(forTextStyle: .headline)
            static let subheadline = UIFont.preferredFont(forTextStyle: .subheadline)
        }
    }

    struct ErrorMessages {
        static let networkErrorTitle = "Network Error"
        static let networkErrorBody = "Please check your internet connection and try again."
        static let serverErrorTitle = "Server Error"
        static let serverErrorBody = "Something went wrong with the network request. Please try again later."
    }
}
