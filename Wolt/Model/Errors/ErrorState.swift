//
//  ErrorState.swift
//  Wolt
//
//  Created by Awais Akram on 8.7.2024.
//

import Foundation

enum ErrorState {
    case networkOffline
    case serverError
    case customError(errorMessage: ErrorMessage)
    case httpError(statusCode: Int)
    case unknownError

    var title: String {
        switch self {
        case .networkOffline:
            return "Network Error"
        case .serverError:
            return "Server Error"
        case .customError(let errorMessage):
            return errorMessage.title ?? ""
        case .httpError(let statusCode):
            return "HTTP Error - \(statusCode)"
        case .unknownError:
            return "Unknown Error"
        }
    }

    var message: String {
        switch self {
        case .networkOffline:
            return "Please check your internet connection and try again."
        case .serverError:
            return "Something went wrong with the network request. Please try again later."
        case .customError(let errorMessage):
            return errorMessage.body ?? ""
        case .httpError(_):
            return "An unexpected error occurred while processing your request. Please try again."
        case .unknownError:
            return "An unexpected error occurred while processing your request. Please try again."
        }
    }
}
