//
//  RedditClient.swift
//  RedditGallery
//
//  Created by Marco Siino on 02/12/2020.
//

import Foundation

class RedditClient {
    enum ResponseType {
        case success(data: RedditResponse?, httpStatusCode: Int?)
        case error(error: Error?, httpStatusCode: Int?)
    }
    
    typealias RequestCompletionHandler = (_ result: ResponseType) -> ()
    
    private let session: URLSession
    private static let baseURL: URL = URL(string: "https://www.reddit.com/")!
    
    init() {
        session = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    func request(endpoint: Endpoint, completion: @escaping RequestCompletionHandler) -> URLSessionTask? {
        let request = URLRequest(url: endpoint.url)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            let httpResponse = response as? HTTPURLResponse
            
            guard error == nil else {
                completion(.error(error: error, httpStatusCode: httpResponse?.statusCode))
                return
            }
            
            if let data = data {
                do {
                    let model = try JSONDecoder().decode(ListingRootModel.self, from: data)
                    completion(.success(data: model, httpStatusCode: httpResponse?.statusCode))
                }
                catch(let error) {
                    completion(.error(error: error, httpStatusCode: httpResponse?.statusCode))
                }
            }
            else {
                completion(.success(data: nil, httpStatusCode: httpResponse?.statusCode))
            }
        }
        
        dataTask.resume()
        return dataTask
    }
}

//MARK: - Endpoints

extension RedditClient {
    enum Endpoint {
        case top(keyword: String)
        
        var url: URL {
            get {
                switch(self) {
                case .top(let keyword):
                    return baseURL.appendingPathComponent("r/\(keyword)/top.json")
                }
            }
        }
    }
}
