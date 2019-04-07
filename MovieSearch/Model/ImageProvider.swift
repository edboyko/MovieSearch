//
//  ImageProvider.swift
//  MovieSearch
//
//  Created by Edwin Boyko on 07/04/2019.
//  Copyright © 2019 Edwin Boyko. All rights reserved.
//

import UIKit

class ImageProvider {
    private var networkManager: NetworkManager
    
    init() {
        self.networkManager = NetworkManager(urlSession: URLSession.shared)
    }
    
    func getImage(for movie: MovieDetails, completion: @escaping (UIImage?) -> Void) {
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
