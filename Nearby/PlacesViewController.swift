//
//  PlacesViewController.swift
//  Nearby
//
//  Created by Geoff Raeder on 10/24/21.
//

import UIKit
import CoreLocation
import Resolver

class PlacesViewController: UIViewController {

    @Injected var placeDataService: PlaceDataServiceType

    var places: [Place]? {
        didSet {
            reload()
        }
    }

    var locationSnapshot: CLLocation?

    func reload() {}
}
