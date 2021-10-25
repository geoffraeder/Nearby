//
//  NearbyTests.swift
//  NearbyTests
//
//  Created by Geoff Raeder on 10/16/21.
//

import XCTest

class NearbyTests: XCTestCase {

    func testDecodePlaces() throws {
        let bundle = Bundle(for: Self.self)

        guard let url = bundle.url(forResource: "place-data", withExtension: "json") else {
            fatalError()
        }

        let decoded = try JSONDecoder().decode(PlaceResult.self, from: Data(contentsOf: url))

        for place in decoded.places {
            XCTAssertNotNil(place.id)
            XCTAssertNotNil(place.name)
            XCTAssertNotNil(place.rating)
            XCTAssertNotNil(place.vicinity)
            XCTAssertNotNil(place.geometry)
            XCTAssertNotNil(place.geometry?.location)
            XCTAssertNotNil(place.geometry?.location.latitude)
            XCTAssertNotNil(place.geometry?.location.longitude)
            XCTAssertNotNil(place.location?.coordinate.latitude)
            XCTAssertNotNil(place.location?.coordinate.longitude)
        }
    }
}
