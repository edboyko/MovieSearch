//
//  ViewController.swift
//  MovieSearch
//
//  Created by Edwin Boyko on 04/04/2019.
//  Copyright © 2019 Edwin Boyko. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet private var searchField: UITextField!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var textFieldCetreConstraint: NSLayoutConstraint!
    @IBOutlet private var fieldRightConstraint: NSLayoutConstraint!
    @IBOutlet private var fieldLeftConstraint: NSLayoutConstraint!
    
    // Properties
    private var basicFieldSideConstraintsValue: CGFloat = 8
    
    // View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        basicFieldSideConstraintsValue = fieldRightConstraint.constant // Assign current Constraint value so we could restore it later
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // UIResponder
    // Helps with keyboard dismissal
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // Keyboard
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let offset = view.frame.size.height/2 - keyboardSize.size.height // Calculate the offset for the search field
            
            self.textFieldCetreConstraint.constant = offset - self.searchField.frame.size.height/2 // Move search field so it would appear exactly on the top of the keyboard
            fieldLeftConstraint.constant = 0
            fieldRightConstraint.constant = 0
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        // Restore everything to defaults so search field would return to initial position
        textFieldCetreConstraint.constant = 0
        fieldLeftConstraint.constant = basicFieldSideConstraintsValue
        fieldRightConstraint.constant = basicFieldSideConstraintsValue
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    // View Controller Methods
    func search(from textField: UITextField) {
        self.view.endEditing(true) // Dismiss the keyboard
        if let searchQuery = textField.text, !searchQuery.isEmpty {
            let moviesProvider = MoviesProvider() // Create movies prodifer that will be used for getting initial page with results and subsequent pages
            activityIndicator.startAnimating() // Show loading indicator
            moviesProvider.getMovies(searchQuery: searchQuery) { (movies, error) in
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    if let movies = movies {
                        
                        // Create Results View Controller with Navigation Controller
                        guard
                            let navController = self?.storyboard?.instantiateViewController(withIdentifier: "SearchResultsViewController") as? UINavigationController,
                            let resultsVC = navController.viewControllers.first as? SearchResultsViewController
                        else { return }
                        
                        resultsVC.movies = movies
                        resultsVC.moviesProvider = moviesProvider // Pass movies provider to Search Results View Controller so we could use it later for getting subsequent pages
                        resultsVC.title = "Results for: \(searchQuery)"
                        strongSelf.present(navController, animated: true)
                    }
                    else { // Shows error if was not able to get data
                        let alert = strongSelf.createDefaultAlert(message: error?.localizedDescription ?? "An Error Occurred")
                        
                        strongSelf.present(alert, animated: true)
                    }
                    strongSelf.activityIndicator.stopAnimating() // Hide loading indicator
                }
            }
        }
        else {
            let alert = createDefaultAlert(message: "Search Field Should Not Be Empty")
            
            self.present(alert, animated: true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
}
extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search(from: textField)
        
        return false
    }
}
