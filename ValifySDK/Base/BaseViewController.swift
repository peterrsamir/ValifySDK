//
//  BaseViewController.swift
//  ValifySDK
//
//  Created by Peter Samir on 30/08/2024.
//

import UIKit

public class BaseViewController: UIViewController {

    // Method to present an alert with a custom closure for actions
    func presentAlert(
        title: String,
        message: String,
        actionTitle: String = "OK",
        action2Title: String? = "Cancel",
        actionHandler: (() -> Void)? = nil,
        action2Handler: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        DispatchQueue.main.async { [weak self] in
            let defaultAction = UIAlertAction(title: actionTitle, style: .default) { _ in
                actionHandler?()
            }
            alert.addAction(defaultAction)
            if let action2Title = action2Title {
                alert.addAction(UIAlertAction(title: action2Title, style: .cancel, handler: { _ in
                    action2Handler?()
                }))
            }
            self?.present(alert, animated: true, completion: nil)
        }
    }
}
