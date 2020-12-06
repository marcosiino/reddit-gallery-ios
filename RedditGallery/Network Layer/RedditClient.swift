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
    fileprivate static let baseURL: String = "https://www.reddit.com/"
    
    init() {
        session = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    func request(endpoint: Endpoint, completion: @escaping RequestCompletionHandler) -> URLSessionTask? {
        let request = URLRequest(url: endpoint.url)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            let httpResponse = response as? HTTPURLResponse
            
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(.error(error: error, httpStatusCode: httpResponse?.statusCode))
                }
                return
            }
            
            if let data = data {
                do {
                    let model = try JSONDecoder().decode(ListingRootModel.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(data: model, httpStatusCode: httpResponse?.statusCode))
                    }
                }
                catch(let error) {
                    DispatchQueue.main.async {
                        completion(.error(error: error, httpStatusCode: httpResponse?.statusCode))
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    completion(.success(data: nil, httpStatusCode: httpResponse?.statusCode))
                }
            }
        }
        
        dataTask.resume()
        return dataTask
    }
}

//MARK: - Endpoints

extension RedditClient {
    enum Endpoint {
        /**
         Top listings for the specified keyword. If pageAfter is specified, the items after the specified item id is returned (for paging), otherwise the first page is returned
         */
        case top(keyword: String, afterId: String? = nil)
        
        var url: URL {
            get {
                switch(self) {
                case .top(let keyword, let afterId):
                    var urlComps = URLComponents(string: baseURL)!
                    urlComps.path = "/r/\(keyword)/top.json"
                    
                    if let afterId = afterId {
                        urlComps.queryItems = [
                            URLQueryItem(name: "after", value: afterId)
                        ]
                    }
                    
                    return urlComps.url!
                }
            }
        }
    }
}
