//
//  PlacesMapViewController.swift
//  Nearby
//
//  Created by Geoff Raeder on 10/20/21.
//

import UIKit
import MapKit

protocol PlacesMapViewControllerDelegate: NSObjectProtocol {
    func placesMapViewController(_ controller: PlacesMapViewController, didSelectPlace place: Place)
}

class PlaceAnnotation: MKPointAnnotation {
    var placeId: String

    init(placeId: String) {
        self.placeId = placeId
        super.init()
    }
}

class PlacesMapViewController: PlacesViewController, MKMapViewDelegate, UISearchControllerDelegate {
    
    let mapView = MKMapView()
    weak var delegate: PlacesMapViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mapView)
        mapView.pinTo(view: view)

        mapView.delegate = self
        mapView.showsUserLocation = true
    }

    override func reload() {
        super.reload()
        updateAnnotations()
        showAllAnnotations(animated: true)
    }

    func updateRegion(animated: Bool, for location: CLLocation) {
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: defaultNearbyRadius,
                                        longitudinalMeters: defaultNearbyRadius)
        
        mapView.setRegion(region, animated: animated)
    }

    func showAllAnnotations(animated: Bool) {
        mapView.showAnnotations(mapView.annotations, animated: animated)
    }

    func updateAnnotations() {
        guard let places = self.places else {
            return
        }

        mapView.removeAnnotations(mapView.annotations)
        
        let annotations = places.compactMap { place -> MKAnnotation? in
            guard let location = place.location else {
                return nil
            }

            let annotation = PlaceAnnotation(placeId: place.id)
            annotation.title = place.name
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            return annotation
        }

        mapView.addAnnotations(annotations)
    }
}

// MARK: - MKMapViewDelegate

extension PlacesMapViewController {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let placeAnnotation = view.annotation as? PlaceAnnotation else {
            return
        }

        let placeId = placeAnnotation.placeId
        if let selectedPlace = places?.filter({ $0.id == placeId }).first {
            self.delegate?.placesMapViewController(self, didSelectPlace: selectedPlace)
        }
    }
}

