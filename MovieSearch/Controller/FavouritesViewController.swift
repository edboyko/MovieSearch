//
//  FavouritesViewController.swift
//  MovieSearch
//
//  Created by Edwin Boyko on 05/04/2019.
//  Copyright © 2019 Edwin Boyko. All rights reserved.
//

import UIKit
import CoreData

class FavouritesViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        try? fetchedResultsController.performFetch()
        tableView.reloadData()
    }
    
    // Navigation Support
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell), let movieDetailsVC = segue.destination as? MovieDetailsViewController else {
            return
        }
        let selectedMovie = fetchedResultsController.object(at: indexPath)
        movieDetailsVC.movieID = Int(selectedMovie.id)
    }

    // MARK: - Fetched results controller
    var fetchedResultsController: NSFetchedResultsController<MovieFavourite> {
        if let controller = _fetchedResultsController {
            return controller
        }
        
        let fetchRequest: NSFetchRequest<MovieFavourite> = MovieFavourite.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "dateAdded", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: StorageManager().mainContext, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<MovieFavourite>? = nil
}
extension FavouritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let favourite = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieFavouriteCell", for: indexPath)
        cell.textLabel?.text = favourite.title
        return cell
    }
}
extension FavouritesViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        tableView.reloadData()
    }
}
