//
//  CLLocation+Extensions.swift
//  Nearby
//
//  Created by Geoff Raeder on 10/24/21.
//

import Foundation
import MapKit

// https://stackoverflow.com/questions/15421106/centering-mkmapview-on-spot-n-pixels-below-pin

import MapKit

extension MKMapView {

    func moveCenterByOffSet(offSet: CGPoint, coordinate: CLLocationCoordinate2D) {
        var point = self.convert(coordinate, toPointTo: self)

        point.x += offSet.x
        point.y += offSet.y

        let center = self.convert(point, toCoordinateFrom: self)
        self.setCenter(center, animated: true)
    }

    func centerCoordinateByOffSet(offSet: CGPoint) -> CLLocationCoordinate2D {
        var point = self.center

        point.x += offSet.x
        point.y += offSet.y

        return self.convert(point, toCoordinateFrom: self)
    }
}
