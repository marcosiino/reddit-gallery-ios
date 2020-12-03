//
//  RedditDataRepository.swift
//  RedditGallery
//
//  Created by Marco Siino on 02/12/2020.
//

import Foundation
import CoreData

/**
 Concrete DataRepository
 */
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
                        guard child.kind == "t3" else { //t3 = posts
                            continue
                        }
                        
                        let data = child.data
                        
                        guard let postId = data.id, let author = data.author, let title = data.title, let thumbnail = data.thumbnail, let ups = data.ups, let downs = data.downs, let permalink = data.permalink else {
                            continue
                        }
                        
                        let mediumResImages = data.preview?.images.map({ (imageSet) -> String in
                            let image = imageSet.medium ?? imageSet.original
                            return image.url.decodeHtmlEncodedString()
                        }) ?? [String]()
                        
                        //If this post doesn't have a thumbnail and at least an image, skip it
                        guard mediumResImages.count > 0 else {
                            continue
                        }
                        
                        //Create an higher level data model of type Post
                        let post = Post(id: postId, author: author, title: title, images: mediumResImages, thumbnail: thumbnail.decodeHtmlEncodedString(), ups: ups, downs: downs, permalink: permalink.decodeHtmlEncodedString())
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
