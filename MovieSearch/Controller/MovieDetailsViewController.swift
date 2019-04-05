//
//  MovieDetailsViewController.swift
//  MovieSearch
//
//  Created by Edwin Boyko on 05/04/2019.
//  Copyright © 2019 Edwin Boyko. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UITableViewController {
    @IBOutlet var firstCell: UITableViewCell!
    @IBOutlet var secondCell: DescriptionCell!
    
    var movieDetails: MovieDetails?
    var movieID: Int?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let movieID = movieID else {
            return
        }
        MoviesProvider().getMovieDetails(movieID: movieID) { [weak self] (movieDetails, error) in
            guard let strongSelf = self else {
                return
            }
            if let movieDetails = movieDetails {
                DispatchQueue.main.async {
                    strongSelf.firstCell.textLabel?.text = movieDetails.title
                    strongSelf.firstCell.detailTextLabel?.text = movieDetails.genres.first?.name
                    strongSelf.secondCell.textView?.text = movieDetails.overview
                    strongSelf.tableView.reloadData()
                }
            }
            else {
                let alert = strongSelf.createDefaultAlert(message: error?.localizedDescription ?? "Error Occurred")
                strongSelf.navigationController?.present(alert, animated: true)
            }
        }
    }
}
