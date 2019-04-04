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
    
    override func setUp() {
        let networkManager = NetworkManager(urlSession: MockURLSession())
        moviesProvider = MoviesProvider(networkManager: networkManager)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetMovies() {
        moviesProvider.getMovies(searchQuery: "test") { (movies, error) in
            if let movies = movies {
                XCTAssert(movies.first?.title == "Batman")
                XCTAssert(movies[5].title == "Batman & Robin")
                XCTAssert(movies[9].title == "Batman v Superman: Dawn of Justice")
                XCTAssert(movies.last?.title == "The Batman vs. Dracula")
            }
            else {
                XCTFail()
            }
        }
    }
}
class MockURLSession: URLSessionProtocol {
    
    var nextDataTask = MockURLSessionDataTask()
    
    var nextError: Error?
    
    private (set) var lastURL: URL?
    
    func successHttpURLResponse(request: URLRequest) -> URLResponse {
        
        return HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        lastURL = request.url
        
        let url = Bundle(for: MovieSearchTests.self).url(forResource: "TestData", withExtension: "json")
        let data = try? Data(contentsOf: url!)
        completionHandler(data, successHttpURLResponse(request: request), nextError)
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
