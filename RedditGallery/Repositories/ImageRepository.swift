//
//  ImageRepository.swift
//  RedditGallery
//
//  Created by Marco Siino on 03/12/2020.
//

import Foundation
import UIKit

/**
 A singleton which download images asyncronously, caches them, and return the cached images if present instead of redownloading them. This class does what SDWebCache or Kingfisher do with image caching, in a simpler way.
 */
class ImageRepository {
    
    static let sharedInstance = ImageRepository()
    private init() { }
    
    enum Result {
        case success(image: UIImage?)
        case error(error: Error?)
    }
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    func isCached(url: String) -> Bool {
        if let cachedImage = CoreDataHelper.getCachedImage(url: url), let _ = cachedImage.image {
            return true
        }
        else {
            return false
        }
    }
    
    /**
     Return the image from the cache or download it if not still cached. Returns an URLSessionDataTask if the image is being downloaded from internet, or nil if the image is being loaded from the cache.
     */
    func getImage(url: String, completion: @escaping (Result) -> ()) -> URLSessionDataTask? {
        
        //If the image is cached
        if let cachedImage = CoreDataHelper.getCachedImage(url: url) {
            if let imageData = cachedImage.image {
                completion(.success(image: UIImage(data: imageData)))
                return nil
            }
        }
        
        //Otherwise, download it asynchronously, cache it and return it through the completion closure
        
        if let url = URL(string: url) {
            let dataTask = session.dataTask(with: url) { [weak self] (data, response, error) in
                DispatchQueue.main.async {
                    guard error == nil else {
                        completion(.error(error: error))
                        return
                    }
                    
                    if let data = data, let image = UIImage(data: data) {
                        CoreDataHelper.saveCachedImage(url: url.absoluteString, imageData: data)
                        completion(.success(image: image))
                    }
                    else {
                        completion(.error(error: nil))
                    }
                }
                
            }
            
            dataTask.resume()
            return dataTask
        }
        else {
            completion(.error(error: nil))
        }
        return nil
    }
}
