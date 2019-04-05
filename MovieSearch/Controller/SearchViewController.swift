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

    // IBActions
    @IBAction func searchAction(_ sender: Any) {
        search(from: searchField)
    }
    
    // View Controller Methods
    func search(from textField: UITextField) {
        self.view.endEditing(true)
        if let searchQuery = textField.text, !searchQuery.isEmpty {
            activityIndicator.startAnimating()
            MoviesProvider().getMovies(searchQuery: searchQuery) { (movies, error) in
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
                        resultsVC.title = "Results for: \(searchQuery)"
                        strongSelf.activityIndicator.stopAnimating()
                        strongSelf.present(navController, animated: true)
                    }
                    else {
                        let alert = strongSelf.createDefaultAlert(message: error?.localizedDescription ?? "An Error Occurred")
                        
                        strongSelf.present(alert, animated: true)
                    }
                }
            }
        }
        else {
            let alert = createDefaultAlert(message: "Search Field Should Not Be Empty")
            
            self.present(alert, animated: true)
        }
    }
}
extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search(from: textField)
        
        return false
    }
}
