//
//  PlacesContainerViewController.swift
//  Nearby
//
//  Created by Geoff Raeder on 10/24/21.
//

import UIKit
import CoreLocation
import Resolver

let defaultNearbyRadius = 8000.0 // ~5 miles
let defaultSearchRadius = 160000.0 // ~100 miles

enum PlacesViewControllerState {
    case map
    case list
}

class PlacesContainerViewController: PlacesViewController, UISearchControllerDelegate, UISearchResultsUpdating, LocationManagerDelegate, PlacesListViewControllerDelegate, PlacesMapViewControllerDelegate {

    let locationManager = LocationManager()
    let placesListViewController = PlacesListViewController()
    let placesMapViewController = PlacesMapViewController()
    private(set) var currentViewController: PlacesViewController? = nil
    private(set) var viewControllerState = PlacesViewControllerState.map
    private(set) var pendingSearchWorkItem: DispatchWorkItem?
    private(set) var listViewBarButtonItem: UIBarButtonItem?
    private(set) var mapViewBarButtonItem: UIBarButtonItem?
    private(set) var nearbyBarButtonItem: UIBarButtonItem?
    private(set) var savedBarButtonItem: UIBarButtonItem?

    override func viewDidLoad() {
        definesPresentationContext = true

        locationManager.delegate = self
        locationManager.start()

        placesListViewController.delegate = self
        placesMapViewController.delegate = self

        view.backgroundColor = .blue

        let searchResultsController = PlacesListViewController()
        searchResultsController.delegate = self
        searchResultsController.isSearchContext = true

        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchBar.placeholder = NSLocalizedString("Search for a restaurant", comment: "Restaurant search")
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        title = NSLocalizedString("Nearby", comment: "Nearby places")

        setupBarButtonItems()

        updateTransitionButton()
        showMapViewController(nil)

        toolbarItems = [nearbyBarButtonItem!, savedBarButtonItem!]
        navigationController?.isToolbarHidden = false
    }

    private func setupBarButtonItems() {
        let listButton = UIButton()
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .light, scale: .large)
        let listImage = UIImage(systemName: "list.dash", withConfiguration: imageConfiguration)
        listButton.setImage(listImage, for: .normal)
        listButton.addTarget(self, action: #selector(showListViewController(_:)), for: .touchUpInside)
        listViewBarButtonItem = UIBarButtonItem(customView: listButton)

        let mapButton = UIButton()
        let mapImage = UIImage(systemName: "map", withConfiguration: imageConfiguration)
        mapButton.setImage(mapImage, for: .normal)
        mapButton.addTarget(self, action: #selector(showMapViewController(_:)), for: .touchUpInside)
        mapViewBarButtonItem = UIBarButtonItem(customView: mapButton)

        let nearbyButton = UIButton()
        let nearbyConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .large)
        let locationImage = UIImage(systemName: "location.circle", withConfiguration: nearbyConfiguration)
        nearbyButton.setImage(locationImage, for: .normal)
        nearbyButton.addTarget(self, action: #selector(showNearbyPlaces(_:)), for: .touchUpInside)
        nearbyBarButtonItem = UIBarButtonItem(customView: nearbyButton)

        let savedButton = UIButton()
        let savedConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .large)
        let savedImage = UIImage(systemName: "bookmark.circle", withConfiguration: savedConfiguration)
        savedButton.setImage(savedImage, for: .normal)
        savedButton.addTarget(self, action: #selector(showSavedPlaces(_:)), for: .touchUpInside)
        savedBarButtonItem = UIBarButtonItem(customView: savedButton)
    }

    private func updateTransitionButton() {
        switch viewControllerState {
        case .map:
            navigationItem.rightBarButtonItem = listViewBarButtonItem
        case .list:
            navigationItem.rightBarButtonItem = mapViewBarButtonItem
        }
    }

    private func removeCurrentController() {
        currentViewController?.willMove(toParent: nil)
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()
    }

    private func showPlacesController(_ controller: PlacesViewController, state: PlacesViewControllerState) {
        removeCurrentController()
        controller.willMove(toParent: self)
        addChild(controller)

        currentViewController = controller
        reload()

        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.view.addSubview(controller.view)
            controller.view?.pinTo(view: self.view)
            controller.didMove(toParent: self)
        }) { _ in
            self.viewControllerState = state
            self.updateTransitionButton()
        }
    }

    override func reload() {
        dismiss(animated: true, completion: nil)
        currentViewController?.locationSnapshot = locationSnapshot
        currentViewController?.places = places
    }

    private func updatePlaces(for location: CLLocation) {
        locationSnapshot = location

        Task {
            do {
                places = try await placeDataService.getNearbyPlaces(for: location, radius: defaultNearbyRadius, type: .restaurant)
                placesMapViewController.showAllAnnotations(animated: true)
            } catch {
                presentError(error)
            }
        }
    }

    @objc func showListViewController(_ sender: UIButton?) {
        showPlacesController(placesListViewController, state: .list)
    }

    @objc func showMapViewController(_ sender: UIButton?) {
        navigationController?.isToolbarHidden = true
        showPlacesController(placesMapViewController, state: .map)
        navigationController?.isToolbarHidden = false // Hack to get desired toolbar display
    }

    @objc func showNearbyPlaces(_ sender: UIButton?) {
        guard let currentLocation = locationSnapshot else {
            return
        }
        
        updatePlaces(for: currentLocation)
    }

    @objc func showSavedPlaces(_ sender: UIButton?) {

        let savedPlaces = Place.saved()
        if !savedPlaces.isEmpty {
            places = savedPlaces
        }
    }

    private func searchPlaces(for searchText: String) {
        guard let placesListController = navigationItem.searchController?.searchResultsController as? PlacesListViewController else {
            return
        }

        guard let currentLocation = locationSnapshot else {
            return
        }

        Task {
            do {
                placesListController.places = try await placeDataService.getNearbyPlaces(for: currentLocation,
                                                                                            radius: defaultSearchRadius,
                                                                                            type: .restaurant,
                                                                                            keyword: searchText)

                placesListController.tableView.reloadData()

            } catch {
                presentError(error)
            }
        }
    }

    private func presentPlace(_ place: Place) {

        if let searchController = navigationItem.searchController, searchController.isActive {
            searchController.isActive = false
        }

        let placeDetailViewController = PlaceDetailViewController()
        placeDetailViewController.place = place
        placeDetailViewController.currentLocation = locationSnapshot
        
        if let sheet = placeDetailViewController.sheetPresentationController {
            sheet.detents = [ .medium(), .large() ]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
        }

        places = [place]
        showMapViewController(nil)

        currentViewController?.reload()
        let mapView = placesMapViewController.mapView

        if let placeCoordinate = place.location?.coordinate {
            mapView.moveCenterByOffSet(offSet: CGPoint(x: 0, y: 175), coordinate: placeCoordinate)
        }

        present(placeDetailViewController, animated: true)
    }
}

// MARK: - LocationManagerDelegate

extension PlacesContainerViewController {
    func locationManager(_ locationManager: LocationManager, didUpdateCurrentLocation location: CLLocation) {
        if let previousLocation = locationSnapshot {
            // Update if user location changes beyond ~1 mile
            if location.distance(from: previousLocation) > 1600 {
                updatePlaces(for: location)
            }
        } else {
            placesMapViewController.updateRegion(animated: true, for: location) // update region on first current location
            updatePlaces(for: location)
        }
    }
}

// MARK: - UISearchControllerDelegate

extension PlacesContainerViewController {
    func willPresentSearchController(_ searchController: UISearchController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UISearchResultsUpdating

extension PlacesContainerViewController {

    func updateSearchResults(for searchController: UISearchController) {
        guard let placesListController = searchController.searchResultsController as? PlacesListViewController else {
            return
        }

        guard let searchText = searchController.searchBar.text, searchText.count > 0 else {
            placesListController.places?.removeAll()
            placesListController.tableView.reloadData()
            return
        }

        // Uses DispatchWorkItem to execute search after a delay. If the user is typing fast, the queued search will get cancelled to throttle requests.
        pendingSearchWorkItem?.cancel()

        let searchWorkItem = DispatchWorkItem { [weak self] in
            self?.searchPlaces(for: searchText)
        }

        pendingSearchWorkItem = searchWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500),
                                      execute: searchWorkItem)
    }
}

// MARK: - PlacesListViewControllerDelegate

extension PlacesContainerViewController {
    func showAllPlacesForPlacesListViewController(_ controller: PlacesListViewController) {
        places = controller.places
        placesMapViewController.showAllAnnotations(animated: true)
    }

    func placesListViewController(_ controller: PlacesListViewController, didSelectPlace place: Place) {
        presentPlace(place)
    }
}

// MARK: - PlacesMapViewControllerDelegate

extension PlacesContainerViewController {
    func placesMapViewController(_ controller: PlacesMapViewController, didSelectPlace place: Place) {
        presentPlace(place)
    }
}
