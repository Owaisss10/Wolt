//
//  HTTPError.swift
//  Wolt
//
//  Created by Awais Akram on 7.7.2024.
//

import Foundation

enum HTTPError: Error {

    case any(response: URLResponse)
}
