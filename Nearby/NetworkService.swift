//
//  NetworkService.swift
//  NetworkService
//
//  Created by Geoff Raeder on 8/26/21.
//

import Foundation

enum NetworkServiceURLRequestError: Error {
    case malformedURL
}

protocol NetworkServiceURLRequestType {

    func asURLRequest() throws -> URLRequest
}

protocol NetworkServiceType {
    func execute<T: Decodable>(for request: NetworkServiceURLRequestType) async throws -> T
}

class NetworkService: NetworkServiceType {

    func execute<T: Decodable>(for request: NetworkServiceURLRequestType) async throws -> T {
        let (data, _) = try await URLSession.shared.data(for: request.asURLRequest())
//        print("response json: \(data.prettyPrintedJSONString)")
        return try JSONDecoder().decode(T.self, from: data)
    }
}


