//
//  AppDelegate+Injection.swift
//  Nearby
//
//  Created by Geoff Raeder on 10/20/21.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {

    public static func registerAllServices() {
        register { NetworkService() as NetworkServiceType }
        register { PlaceDataService() as PlaceDataServiceType }
    }
}
