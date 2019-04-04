//
//  NetworkManager.swift
//  MovieSearch
//
//  Created by Edwin Boyko on 04/04/2019.
//  Copyright © 2019 Edwin Boyko. All rights reserved.
//

import Foundation

class NetworkManager {
    private let urlSession: URLSessionProtocol
    
    private var dataTask: URLSessionDataTaskProtocol?
    
    init(urlSession: URLSessionProtocol = URLSession.shared) {
        
        self.urlSession = urlSession
    }
    
    func loadData(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let request = URLRequest(url: url)
        
        dataTask = urlSession.dataTask(with: request) { (data, response, error) in
            completion(data, error)
        }
        
        dataTask?.resume()
    }
    
    func cancel() {
        if dataTask?.state == .running {
            dataTask?.cancel()
        }
    }
}
