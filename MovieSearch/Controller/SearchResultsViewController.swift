//
//  SearchResultsViewController.swift
//  MovieSearch
//
//  Created by Edwin Boyko on 04/04/2019.
//  Copyright © 2019 Edwin Boyko. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController {

    // Properties
    var moviesProvider: MoviesProvider?
    var movies = [MovieSearchResult]()
    
    // IBOutlets
    @IBOutlet private var tableView: UITableView!
    
    // IBActions
    @IBAction func closeAction(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
    // Navigation Support
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell), let movieDetailsVC = segue.destination as? MovieDetailsViewController else {
            return
        }
        let selectedMovie = movies[indexPath.row]
        movieDetailsVC.movieID = selectedMovie.id
    }
    
    // ViewController Methods
    func getMore() {
        guard let moviesProvider = moviesProvider, let currentQuery = moviesProvider.currentQuery else {
            return
        }
        if moviesProvider.hasMorePages {
            moviesProvider.getMovies(searchQuery: currentQuery) { [weak self] (movies, error) in
                DispatchQueue.main.async {
                    
                    if let movies = movies {
                        self?.movies.append(contentsOf: movies)
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
}
extension SearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        let movie =  movies[indexPath.row]
        cell.textLabel?.text = movie.title
        cell.detailTextLabel?.text = "Release Year: \(movie.releaseYear ?? "N/A") Rating: \(String(movie.voteAverage))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if moviesProvider?.hasMorePages ?? false {
            return "Loading..."
        }
        else {
            return nil
        }
    }
    
    //UITableViewDelegate
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        getMore()
    }
}
