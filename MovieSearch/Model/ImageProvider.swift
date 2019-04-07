//
//  ImageProvider.swift
//  MovieSearch
//
//  Created by Edwin Boyko on 07/04/2019.
//  Copyright © 2019 Edwin Boyko. All rights reserved.
//

import UIKit

class ImageProvider {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func getImage(for movie: MovieDetails, completion: @escaping (UIImage?) -> Void) {
        // Create URL
        guard let posterPath = movie.posterPath, let url = URL(string: "https://image.tmdb.org/t/p/w342\(posterPath)") else {
            completion(nil)
            return
        }
        networkManager.loadData(url: url) { (data, error) in
            if let data = data {
                let image = UIImage(data: data)
                completion(image)
            }
            else if let error = error{
                print("Error downloading image:", error.localizedDescription)
                completion(nil)
            }
        }
    }
    
    func stopImageDownload() {
        networkManager.cancel()
    }
}
