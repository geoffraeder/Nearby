//
//  LocationManager.swift
//  Nearby
//
//  Created by Geoff Raeder on 10/20/21.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: NSObjectProtocol {
    func locationManager(_ locationManager: LocationManager, didUpdateCurrentLocation location: CLLocation)
}

class LocationManager: NSObject, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()

    weak var delegate: LocationManagerDelegate?
    private(set) var isUpdatingLocation = false

    var isAuthorized: Bool {
        let status = CLLocationManager().authorizationStatus
        return status == .authorizedAlways || status == .authorizedWhenInUse
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
    }

    func start() {
        if CLLocationManager.locationServicesEnabled() && isAuthorized && !isUpdatingLocation {
            locationManager.startUpdatingLocation()
            isUpdatingLocation = true
        }
    }

    func stop() {
        if isUpdatingLocation {
            locationManager.stopUpdatingLocation()
            isUpdatingLocation = false
        }
    }
}

extension LocationManager {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {
            return
        }

        self.delegate?.locationManager(self, didUpdateCurrentLocation: currentLocation)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.stop()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if isAuthorized {
            self.start()
        } else {
            self.stop()
        }
    }
}
