//
//  UIViewController+Alerts.swift
//  MovieSearch
//
//  Created by Edwin Boyko on 05/04/2019.
//  Copyright © 2019 Edwin Boyko. All rights reserved.
//

import UIKit

extension UIViewController {
    func createDefaultAlert(title: String? = nil, message: String) -> UIAlertController{
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Default alert action title."), style: .default)
        controller.addAction(okAction)
        return controller
    }
}
