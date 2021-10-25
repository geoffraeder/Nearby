//
//  Place.swift
//  Nearby
//
//  Created by Geoff Raeder on 10/13/21.
//

import Foundation
import CoreLocation

struct Location: Codable {
    var latitude: Double
    var longitude: Double

    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
}

struct Geometry: Codable {
    var location: Location
}

struct Place: Codable, Identifiable {

    var id: String
    var name: String?
    var rating: Double?
    var priceLevel: Int?
    var iconUrl: String?
    var website: String?
    var vicinity: String?
    var geometry: Geometry?
    var location: CLLocation? {
        guard let geometry = geometry else {
            return nil
        }

        return CLLocation(latitude: geometry.location.latitude,
                          longitude: geometry.location.longitude)
    }

    enum CodingKeys: String, CodingKey {
        case name
        case rating
        case website
        case iconUrl
        case vicinity
        case geometry
        case priceLevel = "price_level"
        case id = "place_id"
    }
}

struct PlaceResult: Codable {
    var places: [Place]
    var nextPageToken: String?

    enum CodingKeys: String, CodingKey {
        case nextPageToken = "next_page_token"
        case places = "results"
    }
}

extension Place {

    static func saved() -> [Place] {
        guard let places = UserDefaults.standard.array(forKey: "places") as? [[String: Data]] else {
            return [Place]()
        }

        do {
            let decodedPlaces = try places.compactMap { placeDict -> Place? in
                guard let placeData = placeDict.values.first else {
                    return nil
                }

                return try JSONDecoder().decode(Place.self, from: placeData)
            }

            return decodedPlaces
        } catch {
            return [Place]()
        }
    }

    func delete() {
        let userDefaults = UserDefaults.standard
        guard var places = UserDefaults.standard.array(forKey: "places") as? [[String: Data]] else {
            return
        }

        places.removeAll { $0.index(forKey: self.id) != nil }
        userDefaults.set(places, forKey: "places")
    }

    func save() throws {
        let userDefaults = UserDefaults.standard
        let placeData = try JSONEncoder().encode(self)
        var places = userDefaults.array(forKey: "places") ?? [[String: Data]]()
        places.append([self.id: placeData])
        userDefaults.set(places, forKey: "places")
    }

    func isSaved() -> Bool {
        guard let places = UserDefaults.standard.array(forKey: "places") as? [[String: Data]] else {
            return false
        }

        let filteredPlaces = places.filter { $0.index(forKey: self.id) != nil }
        return !filteredPlaces.isEmpty
    }
}
