//
//  ImageRepository.swift
//  RedditGallery
//
//  Created by Marco Siino on 03/12/2020.
//

import Foundation

class ImageRepository {
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    func getImage(url: String, completion: @escaping (UIImage?) -> ()) {
        
        //Download the thumbnail asynchronously
        if let url = URL(string: url) {
            
            NSEntity
            
            session.dataTask(with: url) { [weak self] (data, response, error) in
                DispatchQueue.main.async { [weak self] in
                    guard error == nil else {
                        self?.imageView?.image = UIImage(systemName: "camera.fill")
                        return
                    }
                    
                    if let data = data, let image = UIImage(data: data) {
                        self?.imageView?.image = image
                    }
                }
                
            }.resume()
    }
}
