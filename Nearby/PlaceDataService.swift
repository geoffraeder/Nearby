//
//  ArticleURLService.swift
//  Articles
//
//  Created by Geoff Raeder on 1/14/21.
//

import Foundation
import CoreLocation
import Resolver

enum PlaceType: String {
    case restaurant = "restaurant"
    //...
}

enum PlaceServiceRouter: NetworkServiceURLRequestType {

    case nearbyPlaces(location: CLLocation, radius: CLLocationDistance, type: PlaceType, keyword: String?)

    var path: String {
        switch self {
        case .nearbyPlaces:
            return "/maps/api/place/nearbysearch/json"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .nearbyPlaces(let location, let radius, let type, let keyword):
            let locationValue = "\(location.coordinate.latitude),\(location.coordinate.longitude)"

            var queryItems = [URLQueryItem]()
            queryItems.append(URLQueryItem(name: "location", value: locationValue))
            queryItems.append(URLQueryItem(name: "type", value: type.rawValue))
            queryItems.append(URLQueryItem(name: "radius", value: "\(radius)"))
            queryItems.append(URLQueryItem(name: "keyword", value: keyword))

            return queryItems
        }
    }

    func asURLRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "maps.googleapis.com"
        components.path = path

        let apiKeyParameter = URLQueryItem(name: "key", value: "AIzaSyDQSd210wKX_7cz9MELkxhaEOUhFP0AkSk")

        switch self {
        case .nearbyPlaces:
            var queryItems = queryItems
            queryItems.append(apiKeyParameter)
            components.queryItems = queryItems

            guard let url = components.url else {
                throw NetworkServiceURLRequestError.malformedURL
            }

            return URLRequest(url: url)
        }
    }
}

protocol PlaceDataServiceType: DataServiceType {
    func getNearbyPlaces(for location: CLLocation, radius: CLLocationDistance, type: PlaceType, keyword: String?) async throws -> [Place]
}

extension PlaceDataServiceType {
    func getNearbyPlaces(for location: CLLocation, radius: CLLocationDistance, type: PlaceType, keyword: String? = nil) async throws -> [Place] {
        return try await getNearbyPlaces(for: location, radius: radius, type: type, keyword: keyword)
    }
}

class PlaceDataService: DataService, PlaceDataServiceType {

    func getNearbyPlaces(for location: CLLocation, radius: CLLocationDistance, type: PlaceType, keyword: String?) async throws -> [Place] {

        let route = PlaceServiceRouter.nearbyPlaces(location: location, radius: radius, type: type, keyword: keyword)

        let placeResult: PlaceResult = try await self.networkService.execute(for: route)
        return placeResult.places
    }
}
