//
//  StorageManager.swift
//  MovieSearch
//
//  Created by Edwin Boyko on 05/04/2019.
//  Copyright © 2019 Edwin Boyko. All rights reserved.
//

import CoreData

class StorageManager {

    private let persistentContainer: NSPersistentContainer
    
    init(persistentContainer: NSPersistentContainer = AppDelegate.instance.persistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func getFavourites() -> [MovieFavourite]? {
        let request: NSFetchRequest<MovieFavourite> = MovieFavourite.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "dateAdded", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.fetchBatchSize = 30
        var favourites: [MovieFavourite]?
        mainContext.performAndWait {
            favourites = try? mainContext.fetch(request)
        }
        return favourites
    }
    
    func save(id: Int, title: String, completion: ((Error?) -> Void)? = nil) {
        
        let context = self.persistentContainer.newBackgroundContext()
        
        context.performAndWait {
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            let newFavourite = MovieFavourite(context: context)
            newFavourite.id = Int64(id)
            newFavourite.dateAdded = Date()
            newFavourite.title = title
            
            do {
                try context.save()
                completion?(nil)
            } catch {
                completion?(error)
            }
        }
    }
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
