//
//  PlaceDetailViewController.swift
//  Nearby
//
//  Created by Geoff Raeder on 10/24/21.
//

import UIKit
import CoreLocation

class PlaceDetailViewController: UIViewController, PlaceViewDelegate {

    let placeView = PlaceView()
    var place: Place?
    var currentLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(placeView)
        placeView.pinTo(safeAreaOf: view)

        placeView.delegate = self
        placeView.nameLabel.text = place?.name

        placeView.isBookmarked = place?.isSaved() ?? false

        if let address = place?.vicinity,
            let placeLocation = place?.location,
            let currentLocation = currentLocation {

            let distance = currentLocation.distance(from: placeLocation) * 0.000621 // Convert to miles although would need to localize

            placeView.addressLabel.text = "\(address) • \(String(format: "%.2f", distance)) mi"
        }

        if let rating = place?.rating {
            placeView.ratingLabel.text = "Rating: \(rating)"
        }

        if let priceLevel = place?.priceLevel {
            placeView.priceLevelLabel.text = "Price level: \(priceLevel)/4"
        }

        if let website = place?.website {
            placeView.websiteButton.setTitle(website, for: .normal)
        }
    }
}

// MARK: - PlaceViewDelegate

extension PlaceDetailViewController {
    
    func placeViewDidToggleBookmarkStatus(_ view: PlaceView) {
        do {
            if view.isBookmarked {
                try place?.save()
            } else {
                place?.delete()
            }
        } catch {
            presentError(error)
        }
    }
}
