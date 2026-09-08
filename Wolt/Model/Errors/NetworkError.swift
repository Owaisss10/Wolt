//
//  NetworkError.swift
//  Wolt
//
//  Created by Awais Akram on 7.7.2024.
//

import Foundation

/// A convenience error type for network errors.
///
/// Handling `URLError`s in the error handling process is inconvenient,
/// because apparently the type is not always `URLError` but `type(of:)`
/// later returns `NSURLError`, and any `URLError` extensions do not
/// apply and cannot be used for easy error type checking.
enum NetworkError: Error {
    
    case notConnectedToInternet
    case timedOut
    case other
}

extension NetworkError {
    
    init(_ urlError: URLError) {
        switch urlError.code {
        case .notConnectedToInternet: self = .notConnectedToInternet
        case .timedOut: self = .timedOut
        default: self = .other
        }
    }
    
    init(_ error: Error) {
        if let urlError = error as? URLError {
            self.init(urlError)
        } else {
            self = .other
        }
    }
}

extension NetworkError {
    
    var message: ErrorMessage {
        switch self {
            
        case .notConnectedToInternet:
            return .init(
                title: Constants.ErrorMessages.networkOfflineTitle,
                body: Constants.ErrorMessages.networkOfflineMessage
            )
            
        case .timedOut, .other:
            return .init(
                title: Constants.ErrorMessages.serverErrorTitle,
                body: Constants.ErrorMessages.serverErrorMessage
            )
            
        }
    }
    
}

