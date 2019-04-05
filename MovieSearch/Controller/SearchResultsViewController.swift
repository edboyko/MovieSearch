//
//  SearchResultsViewController.swift
//  MovieSearch
//
//  Created by Edwin Boyko on 04/04/2019.
//  Copyright © 2019 Edwin Boyko. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController {

    var movies = [Movie]()
    
    @IBOutlet private var tableView: UITableView!
    
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
}
extension SearchResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        cell.textLabel?.text = movies[indexPath.row].title
        return cell
    }
}
