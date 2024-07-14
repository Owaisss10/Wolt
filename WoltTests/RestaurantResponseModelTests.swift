//
//  RestaurantResponseModelTests.swift
//  WoltTests
//
//  Created by Awais Akram on 14.7.2024.
//

import XCTest
@testable import Wolt

class RestaurantResponseModelTests: XCTestCase {

    func testDecodingRestaurantsResponse() {
        let json = """
        {
            "sections": [
                {
                    "items": [
                        {
                            "venue": {
                                "id": "1",
                                "name": "Test Venue",
                                "short_description": "A nice place"
                            },
                            "image": {
                                "url": "http://example.com/image.jpg"
                            }
                        }
                    ]
                }
            ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(RestaurantsResponse.self, from: json)
            XCTAssertNotNil(response.sections)
            XCTAssertEqual(response.sections?.count, 1)
            XCTAssertEqual(response.sections?.first?.restaurants?.count, 1)
            XCTAssertEqual(response.sections?.first?.restaurants?.first?.venue?.id, "1")
            XCTAssertEqual(response.sections?.first?.restaurants?.first?.image?.url, "http://example.com/image.jpg")
        } catch {
            XCTFail("Decoding failed: \(error)")
        }
    }

    func testDecodingSection() {
        let json = """
        {
            "items": [
                {
                    "venue": {
                        "id": "1",
                        "name": "Test Venue",
                        "short_description": "A nice place"
                    },
                    "image": {
                        "url": "http://example.com/image.jpg"
                    }
                }
            ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        do {
            let section = try decoder.decode(Section.self, from: json)
            XCTAssertNotNil(section.restaurants)
            XCTAssertEqual(section.restaurants?.count, 1)
        } catch {
            XCTFail("Decoding failed: \(error)")
        }
    }

    func testRestaurantEquatable() {
        let venue1 = Venue(id: "1", name: "Restaurant A", short_description: "Description A")
        let venue2 = Venue(id: "1", name: "Restaurant B", short_description: "Description B")
        let venue3 = Venue(id: "2", name: "Restaurant C", short_description: "Description C")

        let restaurantA1 = Restaurant(venue: venue1, image: nil)
        let restaurantA2 = Restaurant(venue: venue2, image: nil)
        let restaurantB = Restaurant(venue: venue3, image: nil)

        XCTAssertEqual(restaurantA1, restaurantA2) // Same ID
        XCTAssertNotEqual(restaurantA1, restaurantB) // Different ID
    }

    func testDecodingRestaurant() {
        let json = """
        {
            "venue": {
                "id": "1",
                "name": "Test Venue",
                "short_description": "A nice place"
            },
            "image": {
                "url": "http://example.com/image.jpg"
            }
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        do {
            let restaurant = try decoder.decode(Restaurant.self, from: json)
            XCTAssertNotNil(restaurant.venue)
            XCTAssertEqual(restaurant.venue?.id, "1")
            XCTAssertEqual(restaurant.image?.url, "http://example.com/image.jpg")
        } catch {
            XCTFail("Decoding failed: \(error)")
        }
    }

    func testDecodingVenue() {
        let json = """
        {
            "id": "1",
            "name": "Test Venue",
            "short_description": "A nice place"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        do {
            let venue = try decoder.decode(Venue.self, from: json)
            XCTAssertEqual(venue.id, "1")
            XCTAssertEqual(venue.name, "Test Venue")
            XCTAssertEqual(venue.short_description, "A nice place")
        } catch {
            XCTFail("Decoding failed: \(error)")
        }
    }

    func testDecodingImage() {
        let json = """
        {
            "url": "http://example.com/image.jpg"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        do {
            let image = try decoder.decode(Image.self, from: json)
            XCTAssertEqual(image.url, "http://example.com/image.jpg")
        } catch {
            XCTFail("Decoding failed: \(error)")
        }
    }
}
