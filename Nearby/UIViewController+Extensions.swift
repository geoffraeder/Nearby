//
//  UIViewController+Extensions.swift
//  Nearby
//
//  Created by Geoff Raeder on 10/21/21.
//

import Foundation
import UIKit

extension UIViewController {

    func presentError(_ error: Error) {
        let title = NSLocalizedString("Error", comment: "Error raised")
        let message = NSLocalizedString("\(error.localizedDescription)", comment: "An error occurred.")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Dismiss error message"), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
