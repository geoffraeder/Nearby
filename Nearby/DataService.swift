//
//  DataService.swift
//  DataService
//
//  Created by Geoff Raeder on 8/26/21.
//

import Foundation
import Resolver

protocol DataServiceType {
    var networkService: NetworkServiceType { set get }
}

class DataService: DataServiceType {
    @Injected var networkService: NetworkServiceType
}
