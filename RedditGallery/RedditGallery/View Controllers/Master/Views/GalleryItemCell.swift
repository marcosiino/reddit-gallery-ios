//
//  GalleryItemCell.swift
//  RedditGallery
//
//  Created by Marco Siino on 03/12/2020.
//

import Foundation
import UIKit

class GalleryItemCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView?
    
    func setPost(post: Post) {
        //Reset the image
        imageView?.image = UIImage(systemName: "camera.fill")
        
        //Download the thumbnail asynchronously
        let session = URLSession(configuration: URLSessionConfiguration.default)
        if let thumbnail = post.thumbnail, let url = URL(string: thumbnail) {
            print(post.thumbnail)
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
}
