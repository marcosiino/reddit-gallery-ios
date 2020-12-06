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
     Retrieves posts using the rest client and provide higher level models
     - forKeyword: the subreddit to query (i.e. cats)
     - completionHandler: the completion closure which returns the queried Posts. This closure is called in the main queue
     */
    
    func getPosts(searchKeyword keyword: String, afterId: String? = nil, completionHandler: @escaping (DataRepositoryResult<[Post]>) -> () ) {
        
        if keyword.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
            completionHandler(.success([Post]()))
            return
        }
        
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
                        
                        guard let postId = data.id, let author = data.author, let title = data.title, let ups = data.ups, let downs = data.downs, let permalink = data.permalink else {
                            continue
                        }
                        
                        let images = data.preview?.images.map({ (imageSet) -> String in
                            let image = imageSet.original
                            return image.url.decodeHtmlEncodedString()
                        }) ?? [String]()
                        
                        //If this post doesn't have a thumbnail and at least an image, skip it
                        guard images.count > 0 else {
                            continue
                        }
                        
                        guard let previewImage = data.preview?.images.first?.smaller?.url else {
                            continue
                        }
                        
                        let favorited = CoreDataHelper.isFavorite(postId: postId)
                        
                        //Create an higher level data model of type Post
                        let post = Post(id: postId, author: author, title: title, images: images, thumbnail: previewImage.decodeHtmlEncodedString(), ups: ups, downs: downs, permalink: permalink.decodeHtmlEncodedString(), favorited: favorited)
                        posts.append(post)
                    }
                    
                    //Calling the completion closure on the main thread
                    completionHandler(.success(posts))
                }
                else {
                    
                    //Calling the completion closure on the main thread
                    completionHandler(.success([Post]()))
                }
            case .error(let error, let httpStatusCode):
                
                //Calling the completion closure on the main thread
                completionHandler(.error(error))
            }
        }
    }
    
    func supportsPaging() -> Bool {
        return true
    }
    
}
