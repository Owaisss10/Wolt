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
            return Constants.ErrorMessages.networkOfflineTitle
        case .serverError:
            return Constants.ErrorMessages.serverErrorTitle
        case .customError(let errorMessage):
            return errorMessage.title ?? ""
        case .httpError(let statusCode):
            return "\(Constants.ErrorMessages.httpErrorTitle) - \(statusCode)"
        case .unknownError:
            return Constants.ErrorMessages.unknownErrorTitle
        }
    }

    var message: String {
        switch self {
        case .networkOffline:
            return Constants.ErrorMessages.networkOfflineMessage
        case .serverError:
            return Constants.ErrorMessages.serverErrorMessage
        case .customError(let errorMessage):
            return errorMessage.body ?? ""
        case .httpError(_):
            return Constants.ErrorMessages.httpErrorMessage
        case .unknownError:
            return Constants.ErrorMessages.unknownErrorMessage
        }
    }
}
