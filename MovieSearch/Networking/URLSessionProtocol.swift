//
//  URLSessionProtocol.swift
//  MovieSearch
//
//  Created by Edwin Boyko on 04/04/2019.
//  Copyright © 2019 Edwin Boyko. All rights reserved.
//

import Foundation

protocol URLSessionProtocol {
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

protocol URLSessionDataTaskProtocol {
    func resume()
    func cancel()
    var state: URLSessionTask.State { get }
}
extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
    }
}
extension URLSessionDataTask: URLSessionDataTaskProtocol {}
