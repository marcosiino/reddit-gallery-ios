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
        imageView?.image = nil
        
        if let thumbnail = post.thumbnail {
            let wasCached = ImageRepository.sharedInstance.isCached(url: thumbnail)
            
            ImageRepository.sharedInstance.getImage(url: thumbnail) { [weak self] (result) in
                switch(result) {
                case .success(let image):
                    if let image = image {
                        self?.imageView?.image = image
                        if wasCached == false {
                            self?.imageView?.fadeIn()
                        }
                    }
                case .error(let error):
                    self?.imageView?.image = nil
                }
            }
        }
    }
}
