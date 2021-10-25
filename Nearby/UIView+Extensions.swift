//
//  UIView+Extensions.swift
//  Nearby
//
//  Created by Geoff Raeder on 10/20/21.
//

import UIKit

extension UIView {

    func pinTo(view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func pinTo(safeAreaOf view: UIView) {
        let safeAreaLayoutGuide = view.safeAreaLayoutGuide

        self.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            self.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            self.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}


