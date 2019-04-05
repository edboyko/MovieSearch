//
//  SearchResponseModel.swift
//  MovieSearch
//
//  Created by Edwin Boyko on 04/04/2019.
//  Copyright © 2019 Edwin Boyko. All rights reserved.
//

import Foundation

struct SearchResponseModel: Decodable {
    
    let page: Int
    let totalResults: Int
    let totalPages: Int
    let results: [Movie]
}

struct Movie: Decodable {

    let voteCount: Int
    let id: Int
    let video: Bool
    let voteAverage: Float
    let title: String
    let popularity: Float
    let posterPath: String?
    let originalLanguage: String
    let originalTitle: String
    let genreIds: [Int]
    let backdropPath: String?
    let adult: Bool
    let overview: String
    let releaseDate: Date
}
struct MovieDetails: Decodable {
    struct Genre: Decodable {
        let name: String
    }
    let adult: Bool
    let backdropPath: String?
    
    let budget: Int
    let genres: [Genre]
    
    let homepage: URL?
    let id: Int
    let imdbId: String
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let popularity: Float
    let posterPath: String?
    
    let releaseDate: Date
    let revenue: Int
    
    let status: String
    let tagline: String
    let title: String
    let voteAverage: Float
    let voteCount: Int
}
