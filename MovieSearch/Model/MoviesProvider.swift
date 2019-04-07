//
//  MoviesProvider.swift
//  MovieSearch
//
//  Created by Edwin Boyko on 04/04/2019.
//  Copyright © 2019 Edwin Boyko. All rights reserved.
//

import Foundation
enum MoviesProviderError: Error {
    case NoCurrentQuery
}
class MoviesProvider {
    
    // Properties
    private static let baseURL = "https://api.themoviedb.org/3"
    private static let apiKey = "<#Insert API Key#>"
    private let networkManager: NetworkManager
    private(set) var hasMorePages = true
    private(set) var currentPage = 1
    private(set) var currentQuery: String?
    
    // Initialisers
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    // Methods
    func getMovies(searchQuery: String, completion: @escaping ([MovieSearchResult]?, Error?) -> Void) {
        currentQuery = searchQuery // Save query for getting next page later
        
        // Create URL
        guard let url = URL(string: MoviesProvider.baseURL)?.appendingPathComponent("search").appendingPathComponent("movie"), var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            completion(nil, nil)
            return
        }
        
        let pageString = NSNumber(value: currentPage).stringValue
        
        // Attach query to URL
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: MoviesProvider.apiKey),
            URLQueryItem(name: "query", value: currentQuery),
            URLQueryItem(name: "page", value: pageString)
        ]
        
        guard let finalURL = urlComponents.url else {
            completion(nil, nil)
            return
        }
        
        getData(type: SearchResponseModel.self, url: finalURL) { [weak self] (responseModel, error) in
            if let response = responseModel {
                
                let movies = response.results
                self?.hasMorePages = response.page < response.totalPages
                
                if self?.hasMorePages ?? false { self?.currentPage += 1 } // Increment page numbner so we would be ready to get next page results
                completion(movies, nil)
            }
            else {
                completion(nil, error)
            }
        }
    }
    
    func getNextPage(completion: @escaping ([MovieSearchResult]?, Error?) -> Void) {
        // Prevent making request call if search query does not exist
        guard let searchQuery = currentQuery else {
            completion(nil, MoviesProviderError.NoCurrentQuery)
            return
        }
        getMovies(searchQuery: searchQuery) { (movies, error) in
            completion(movies, error)
        }
    }
    
    func getMovieDetails(movieID: Int, completion: @escaping (MovieDetails?, Error?) -> Void) {
        // Create URL
        let idString = NSNumber(value: movieID).stringValue
        guard let url = URL(string: MoviesProvider.baseURL)?.appendingPathComponent("movie").appendingPathComponent(idString), var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }
        
        // Assign query
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: MoviesProvider.apiKey)
        ]
        let finalUrl = urlComponents.url!
        
        getData(type: MovieDetails.self, url: finalUrl) { (movieDetails, error) in
            
            completion(movieDetails, error)
        }
    }
    
    private func getData<T: Decodable>(type: T.Type, url: URL, completion: @escaping (T?, Error?) -> Void) {
        // Download data using URL provided
        networkManager.loadData(url: url) { (data, error) in
            
            if let data = data {
                // Decode data
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let response = try decoder.decode(T.self, from: data)
                    completion(response, nil)
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
