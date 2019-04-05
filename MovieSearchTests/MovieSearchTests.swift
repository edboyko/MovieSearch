//
//  MovieSearchTests.swift
//  MovieSearchTests
//
//  Created by Edwin Boyko on 04/04/2019.
//  Copyright © 2019 Edwin Boyko. All rights reserved.
//

import XCTest
@testable import MovieSearch

class MovieSearchTests: XCTestCase {

    var moviesProvider: MoviesProvider!
    let mockSession = MockURLSession()
    
    override func setUp() {
        let networkManager = NetworkManager(urlSession: mockSession)
        moviesProvider = MoviesProvider(networkManager: networkManager)
    }

    override func tearDown() {
        mockSession.testData = nil
    }

    func testGetMovies() {
        let url = Bundle(for: MovieSearchTests.self).url(forResource: "TestData", withExtension: "json")
        mockSession.testData = try? Data(contentsOf: url!)
        
        moviesProvider.getMovies(searchQuery: "test") { (movies, error) in
            if let movies = movies {
                XCTAssert(movies.first?.title == "Batman")
                XCTAssert(movies[5].title == "Batman & Robin")
                XCTAssert(movies[9].title == "Batman v Superman: Dawn of Justice")
                XCTAssert(movies.last?.title == "The Batman vs. Dracula")
            }
            else {
                print("error:", error?.localizedDescription ?? "Error")
                XCTFail()
            }
        }
    }
    
    func testGetMovieDetails() {
        let url = Bundle(for: MovieSearchTests.self).url(forResource: "MovieDetailsTestData", withExtension: "json")
        mockSession.testData = try? Data(contentsOf: url!)
        
        moviesProvider.getMovieDetails(movieID: 0, completion: { (movieDetails, error) in
            if let movieDetails = movieDetails {
                XCTAssert(movieDetails.budget == 125000000)
                XCTAssert(movieDetails.title == "Harry Potter and the Philosopher's Stone")
                XCTAssert(movieDetails.id == 671)
                XCTAssert(movieDetails.genres.first?.name == "Adventure")
            }
            else {
                print("error:", error?.localizedDescription ?? "Error")
                XCTFail()
            }
        })
    }
}
class MockURLSession: URLSessionProtocol {
    
    var testData: Data?
    
    var nextDataTask = MockURLSessionDataTask()
    
    var nextError: Error?
    
    private (set) var lastURL: URL?
    
    func successHttpURLResponse(request: URLRequest) -> URLResponse {
        
        return HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        lastURL = request.url
        
        
        completionHandler(testData, successHttpURLResponse(request: request), nextError)
        return nextDataTask
    }
    
}
class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    func cancel() {
        cancelled = true
    }
    
    var state: URLSessionTask.State {
        return .running
    }
    
    private (set) var resumeWasCalled = false
    
    private (set) var cancelled = false
    func resume() {
        resumeWasCalled = true
    }
    
}
