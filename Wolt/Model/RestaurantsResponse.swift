//
//  RestaurantsResponse.swift
//  Wolt
//
//  Created by Awais Akram on 7.7.2024.
//

//sections -> items -> venue -> id
//sections -> items -> venue -> name
//sections -> items -> venue -> short_description
//sections -> items -> image -> url

import Foundation

struct RestaurantsResponse: Codable {
    let sections: [Section]?
}

struct Section: Codable {
    let restaurants: [Restaurant]?
    
    enum CodingKeys: String, CodingKey {
        case restaurants = "items"
    }
}

struct Restaurant: Codable {
    let venue: Venue?
    let image: Image?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.venue = try container.decodeIfPresent(Venue.self, forKey: .venue)
        self.image = try container.decodeIfPresent(Image.self, forKey: .image)
    }
    
    var isFavorite: Bool = false
}

extension Restaurant: Equatable {
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        return lhs.venue?.id == rhs.venue?.id
    }
}

struct Image: Codable {
    let url: String?
}

struct Venue: Codable {
    let id: String
    let name: String?
    let short_description: String?
}

