//
//  MovieDetailsViewController.swift
//  MovieSearch
//
//  Created by Edwin Boyko on 05/04/2019.
//  Copyright © 2019 Edwin Boyko. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UITableViewController {
    
    // IBOutlets
    @IBOutlet private var titleCell: UITableViewCell!
    @IBOutlet private var overviewCell: DescriptionCell!
    @IBOutlet private var posterImageView: UIImageView!
    @IBOutlet private var genresCell: UITableViewCell!
    @IBOutlet private var posterNotAvailableLabel: UILabel!
    @IBOutlet private var yearAndRatingCell: UITableViewCell!
    
    // Properties
    var movieDetails: MovieDetails?
    var movieID: Int?
    let imageProvider = ImageProvider()
    
    // ViewController lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDetails()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageProvider.stopImageDownload()
    }
    
    // IBActions
    @IBAction func addToFavouritesAction(_ sender: Any) {
        guard let movieDetails = movieDetails else {
            return
        }
        StorageManager().save(id: movieDetails.id, title: movieDetails.title) { [weak self] (error) in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                let alert = strongSelf.createDefaultAlert(message: error?.localizedDescription ?? "Added to Favourites!")
                self?.navigationController?.present(alert, animated: true)
            }
        }
    }
    
    // ViewController methods
    func getDetails() {
        guard let movieID = movieID else {
            return
        }
        
        MoviesProvider().getMovieDetails(movieID: movieID) { [weak self] (movieDetails, error) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.movieDetails = movieDetails
            if let movieDetails = strongSelf.movieDetails {
                DispatchQueue.main.async {
                    strongSelf.titleCell.textLabel?.text = movieDetails.title
                    strongSelf.yearAndRatingCell.textLabel?.text = movieDetails.releaseYear
                    strongSelf.yearAndRatingCell.detailTextLabel?.text = "Rating: \(String(movieDetails.voteAverage))"
                    strongSelf.overviewCell.textView?.text = movieDetails.overview
                    let genres = movieDetails.genres.map { return $0.name }.joined(separator: ", ")
                    strongSelf.genresCell.textLabel?.text = "Genres: \(genres)"
                    strongSelf.tableView.reloadData()
                    
                }
                
                strongSelf.imageProvider.getImage(for: movieDetails, completion: { (image) in
                    DispatchQueue.main.async {
                        if let image = image {
                            strongSelf.posterImageView.image = image
                            strongSelf.tableView.reloadData()
                        }
                        else {
                            strongSelf.posterNotAvailableLabel.isHidden = false
                        }
                    }
                })
            }
            else {
                let alert = strongSelf.createDefaultAlert(message: error?.localizedDescription ?? "Error Occurred")
                strongSelf.navigationController?.present(alert, animated: true)
            }
        }
    }
}
