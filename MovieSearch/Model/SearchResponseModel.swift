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
    let results: [MovieSearchResult]
}

struct MovieSearchResult: Movie, Decodable {

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
    let releaseDate: String
}
struct MovieDetails: Movie, Decodable {
    
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
    
    let revenue: Int
    
    let status: String
    let tagline: String
    let title: String
    let voteAverage: Float
    let voteCount: Int
    let releaseDate: String
}
protocol Movie {
    
    var voteCount: Int { get }
    var id: Int { get }
    var voteAverage: Float { get }
    var title: String { get }
    var popularity: Float { get }
    var posterPath: String? { get }
    var originalLanguage: String { get }
    var originalTitle: String { get }
    var backdropPath: String? { get }
    var adult: Bool { get }
    var overview: String { get }
    var releaseDate: String { get }
}
extension Movie {
    var releaseDateParsed: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: releaseDate)
    }
    
    var releaseYear: String? {
        guard let releaseDate = releaseDateParsed else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: releaseDate)
    }
}
