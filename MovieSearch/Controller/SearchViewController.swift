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
        basicFieldSideConstraintsValue = fieldRightConstraint.constant
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }

    // UIResponder
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // Keyboard
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let offset = view.frame.size.height/2 - keyboardSize.size.height
            
            self.textFieldCetreConstraint.constant = offset - self.searchField.frame.size.height/2
            fieldLeftConstraint.constant = 0
            fieldRightConstraint.constant = 0
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        textFieldCetreConstraint.constant = 0
        fieldLeftConstraint.constant = basicFieldSideConstraintsValue
        fieldRightConstraint.constant = basicFieldSideConstraintsValue
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    // View Controller Methods
    func search(from textField: UITextField) {
        self.view.endEditing(true)
        if let searchQuery = textField.text, !searchQuery.isEmpty {
            let moviesProvider = MoviesProvider()
            activityIndicator.startAnimating()
            moviesProvider.getMovies(searchQuery: searchQuery) { (movies, error) in
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    if let movies = movies {
                        
                        guard
                            let navController = self?.storyboard?.instantiateViewController(withIdentifier: "SearchResultsViewController") as? UINavigationController,
                            let resultsVC = navController.viewControllers.first as? SearchResultsViewController
                        else { return }
                        
                        resultsVC.movies = movies
                        resultsVC.moviesProvider = moviesProvider
                        resultsVC.title = "Results for: \(searchQuery)"
                        strongSelf.present(navController, animated: true)
                    }
                    else {
                        let alert = strongSelf.createDefaultAlert(message: error?.localizedDescription ?? "An Error Occurred")
                        
                        strongSelf.present(alert, animated: true)
                    }
                    strongSelf.activityIndicator.stopAnimating()
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
