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
        static let woltWelcomePageImage = "https://woltpartner.dk/wp-content/uploads/2021/08/BTQ_wolt_bike_couriers_6K_v03@2x.jpg"

        static let topPadding: CGFloat = 20.0
        static let cellTopPadding: CGFloat = 20.0
        static let cellBottomPadding: CGFloat = 10.0
        static let bottomPadding: CGFloat = 20.0
        static let horizontalPadding: CGFloat = 20.0
        static let verticalPadding: CGFloat = 10.0
        static let buttonHeight: CGFloat = 50.0
        static let cellLeadingImageWidth: CGFloat = 60.0
        static let cellLeadingImageHeight: CGFloat = 60.0
        static let cellTrailingImageWidth: CGFloat = 30.0
        static let cellTrailingImageHeight: CGFloat = 30.0
        static let cellImageCornerRadius: CGFloat = 10.0
        static let cellErrorStateImageWidth: CGFloat = 100.0
        static let cellErrorStateImageHeight: CGFloat = 100.0

        struct Fonts {
            static let title1 = UIFont.preferredFont(forTextStyle: .title1)
            static let title2 = UIFont.preferredFont(forTextStyle: .title2)
            static let body = UIFont.preferredFont(forTextStyle: .body)
            static let headline = UIFont.preferredFont(forTextStyle: .headline)
            static let subheadline = UIFont.preferredFont(forTextStyle: .subheadline)
        }
    }

    struct DisplayMessages {
        static let currentAddressPrefix = "Showing nearby restaurants in \n"
        static let unknownArea = "Unknown Area"
    }

    struct ErrorMessages {
        static let networkOfflineTitle = "Network Error"
        static let serverErrorTitle = "Server Error"
        static let httpErrorTitle = "HTTP Error"
        static let unknownErrorTitle = "Unknown Error"

        static let networkOfflineMessage = "Please check your internet connection and try again."
        static let serverErrorMessage = "Something went wrong with the network request. Please try again later."
        static let httpErrorMessage = "An unexpected http error occurred while processing your request. Please try again."
        static let unknownErrorMessage = "An unexpected error occurred while processing your request. Please try again."

        static let settingsAlertErrorTitle = "Location Access Needed"
        static let settingsAlertErrorMessage = "In order to see the nearby restaurants, please enable location services in the Settings."

        static let openSettingsActionButtonTitle = "Open settings"
        static let cancelActionButtonTitle = "Cancel"
    }
}
