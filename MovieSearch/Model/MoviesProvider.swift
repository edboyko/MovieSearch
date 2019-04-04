//
//  MoviesProvider.swift
//  MovieSearch
//
//  Created by Edwin Boyko on 04/04/2019.
//  Copyright © 2019 Edwin Boyko. All rights reserved.
//

import Foundation

class MoviesProvider {
    private static let baseURL = "https://api.themoviedb.org/3"
    private static let apiKey = "<#Insert API Key#>"
    
    private let networkManager: NetworkManager
    private(set) var hasMorePages = true
    private(set) var currentPage = 1
    
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func getMovies(page: Int = 1, searchQuery: String, completion: @escaping ([Movie]?, Error?) -> Void) {
        guard let url = URL(string: MoviesProvider.baseURL)?.appendingPathComponent("search").appendingPathComponent("movie"), var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }
        
        let pageString = NSNumber(value: currentPage).stringValue
        
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: MoviesProvider.apiKey),
            URLQueryItem(name: "query", value: searchQuery),
            URLQueryItem(name: "page", value: pageString),
            URLQueryItem(name: "order", value: "desc")
        ]
        let finalUrl = urlComponents.url!
        
        networkManager.loadData(url: finalUrl) { (data, error) in
            if let error = error as NSError? {
                completion(nil, error)
            }
            else if let data = data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                do {
                    let response = try decoder.decode(SearchResponseModel.self, from: data)
                    let movies = response.results
                    self.hasMorePages = response.page < response.totalPages
                    
                    self.currentPage += 1
                    completion(movies, nil)
                    
                }
                catch {
                    completion(nil, error)
                }
            }
            else {
                completion(nil, error)
            }
        }
    }
}
