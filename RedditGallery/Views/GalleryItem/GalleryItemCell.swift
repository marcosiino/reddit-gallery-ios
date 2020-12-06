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
    private let noImage = UIImage(systemName: "camera.fill")
    
    func setPost(post: Post) {
        //Reset the image
        imageView?.image = noImage
        
        if let thumbnail = post.thumbnail {
            ImageRepository.sharedInstance.getImage(url: thumbnail) { [weak self] (result) in
                switch(result) {
                case .success(let image):
                    if let image = image {
                        self?.imageView?.image = image
                    }
                break
                case .error(let error):
                    self?.imageView?.image = self?.noImage
                    break
                }
            }
        }
    }
}
