//
//  MovieSearchTests.swift
//  MovieSearchTests
//
//  Created by Edwin Boyko on 04/04/2019.
//  Copyright © 2019 Edwin Boyko. All rights reserved.
//

import XCTest
import CoreData
@testable import MovieSearch

class MovieSearchTests: XCTestCase {

    var moviesProvider: MoviesProvider!
    let mockSession = MockURLSession()
    var storageManager: StorageManager!
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: MovieSearchTests.self)] )!
        return managedObjectModel
    }()
    
    var mockPersistantContainer: NSPersistentContainer {
        
        let container = NSPersistentContainer(name: "UserList", managedObjectModel: managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )
            
            // Check if creating container wrong
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        return container
    }
    
    override func setUp() {
        let networkManager = NetworkManager(urlSession: mockSession)
        moviesProvider = MoviesProvider(networkManager: networkManager)
        storageManager = StorageManager(persistentContainer: mockPersistantContainer)
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
    
    func testAddFavourite() {
        let id = 1
        let title = "Test Title"
        let promise = expectation(description: "TestPassed")
        storageManager.save(id: id, title: title) { (error) in
            if let error = error {
                print("Error:", error.localizedDescription ?? "Unknown Error")
                XCTFail()
            }
            else {
                let favourites = self.storageManager.getFavourites()
                guard let movie = favourites?.first else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(1, favourites?.count)
                XCTAssertTrue(movie.id == id)
                XCTAssertTrue(movie.title == title)
                promise.fulfill()
            }
        }
        wait(for: [promise], timeout: 2)
    }
    
    func testDeleteFavourite() {
        let id = 1
        let title = "Test Title"
        let promise = expectation(description: "TestPassed")
        storageManager.save(id: id, title: title) { (error) in
            if let error = error {
                print("Error:", error.localizedDescription ?? "Unknown Error")
                XCTFail()
            }
            else {
                let favourites = self.storageManager.getFavourites()
                guard let movie = favourites?.first else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(1, favourites?.count)
                XCTAssertTrue(movie.id == id)
                XCTAssertTrue(movie.title == title)
                self.storageManager.deleteFromFavourites(movie: movie)
                XCTAssertEqual(0, self.storageManager.getFavourites()?.count)
                promise.fulfill()
            }
        }
        wait(for: [promise], timeout: 2)
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
