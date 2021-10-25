//
//  PlacesListViewController.swift
//  Nearby
//
//  Created by Geoff Raeder on 10/20/21.
//

import UIKit
import CoreLocation

protocol PlacesListViewControllerDelegate: NSObjectProtocol {
    func showAllPlacesForPlacesListViewController(_ controller: PlacesListViewController)
    func placesListViewController(_ controller: PlacesListViewController, didSelectPlace place: Place)
}

class PlacesListViewController: PlacesViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView = UITableView()
    weak var delegate: PlacesListViewControllerDelegate?

    var isSearchContext = false
    private var showAllEnabled = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.pinTo(view: view)
    }

    override func reload() {
        showAllEnabled = false
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension PlacesListViewController {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let places = self.places else {
            return 0
        }

        if places.count > 1 && isSearchContext {
            return places.count + 1
        }

        return places.count
    }
}

// MARK: - UITableViewDelegate

extension PlacesListViewController {

    func updatedCell(_ cell: UITableViewCell, for place: Place) -> UITableViewCell {
        let placeAddress = place.vicinity ?? ""

        cell.textLabel?.text = place.name
        cell.detailTextLabel?.textColor = .systemGray

        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        cell.imageView?.image = UIImage(systemName: "fork.knife.circle.fill", withConfiguration: configuration)

        var distance: Double?

        if let placeLocation = place.location, let currentLocation = self.locationSnapshot {
            distance = currentLocation.distance(from: placeLocation) * 0.000621 // Convert to miles although would need to localize
        }

        let distanceText = distance != nil ? "\(String(format: "%.2f", distance!)) mi •" : ""
        cell.detailTextLabel?.text = "\(distanceText) \(placeAddress)"

        return cell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "placeCell"

        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }

        guard let places = self.places else {
            return cell!
        }

        if places.count > 1 && indexPath.row == 0 && isSearchContext {
            showAllEnabled = true
            cell!.textLabel?.text = NSLocalizedString("See locations", comment: "See locations on map")
            cell!.detailTextLabel?.text = nil
            let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .light, scale: .medium)
            cell!.imageView?.image = UIImage(systemName: "map", withConfiguration: configuration)
            return cell!
        } else {
            let rowIndex = showAllEnabled == true ? (indexPath.row - 1) : indexPath.row
            let place = places[rowIndex]
            return updatedCell(cell!, for: place)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && showAllEnabled {
            self.delegate?.showAllPlacesForPlacesListViewController(self)
        }
        else if let place = places?[indexPath.row] {
            self.delegate?.placesListViewController(self, didSelectPlace: place)
        }
    }
}
