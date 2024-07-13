//
//  Networking.swift
//  Wolt
//
//  Created by Awais Akram on 7.7.2024.
//

import Foundation
import Combine

typealias NetworkingPublisherOutput = (data: Data, response: URLResponse)
typealias NetworkingPublisher = AnyPublisher<NetworkingPublisherOutput, Error>

extension URLSession {
    
    /// Default networking without any request modifiers.
    func defaultNetworking(_ request: URLRequest) -> NetworkingPublisher {
        
        dataTaskPublisher(for: request)
            .mapError { NetworkError($0) }
            .eraseToAnyPublisher()
    }
    
}
