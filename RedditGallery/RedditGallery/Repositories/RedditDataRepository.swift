//
//  RedditDataRepository.swift
//  RedditGallery
//
//  Created by Marco Siino on 02/12/2020.
//

import Foundation
import CoreData

class RedditDataRepository: DataRepository {
    
    private let client = RedditClient()
    private var dataTask: URLSessionTask?
    
    /**
     Retrieves the speciefied posts using the rest client and provide higher level models
     - type: The type of posts to query
     - forKeyword: the keyword to query (i.e. cats)
     - completionHandler: the completion closure which returns the queried Posts. This closure is called in the main queue
     */
    
    func getPosts(type: DataRepositoryPostType, forKeyword keyword: String, afterId: String? = nil, completionHandler: @escaping (DataRepositoryResult<[Post]>) -> () ) {
        
        //Cancel the previous request, if any
        if let dataTask = dataTask {
            dataTask.cancel()
        }
        
        //Start a new request to the client
        dataTask = client.request(endpoint: .top(keyword: keyword, afterId: afterId)) { [weak self] (response) in
            self?.dataTask = nil
            
            switch(response) {
            case .success(let responseModel, _):
                if let responseModel = responseModel as? ListingRootModel {
                    
                    var posts = [Post]()
                    //For each child in the deserialized network model
                    for child in responseModel.data.children {
                        let data = child.data
                        
                        let mediumResImages = data.preview?.images.map({ (imageSet) -> String in
                            let image = imageSet.medium ?? imageSet.original
                            return image.url.decodeHtmlEncodedString()
                        }) ?? [String]()
                        
                        //Create an higher level data model of type Post
                        let post = Post(id: data.id, author: data.author, title: data.title, images: mediumResImages, thumbnail: data.thumbnail?.decodeHtmlEncodedString(), ups: data.ups, downs: data.downs, permalink: data.permalink.decodeHtmlEncodedString())
                        posts.append(post)
                    }
                    
                    //Calling the completion closure on the main thread
                    DispatchQueue.main.async {
                        completionHandler(.success(posts))
                    }
                }
                else {
                    
                    //Calling the completion closure on the main thread
                    DispatchQueue.main.async {
                        completionHandler(.success([Post]()))
                    }
                }
            case .error(let error, let httpStatusCode):
                
                //Calling the completion closure on the main thread
                DispatchQueue.main.async {
                    completionHandler(.error(error))
                }
            }
        }
    }
    
}
