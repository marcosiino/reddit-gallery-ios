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
    
    var imageDownloadTask: URLSessionTask?
    
    func setPost(post: Post) {
        hero.id = "postImage-\(post.id)"
        
        if let thumbnail = post.thumbnail {
            let wasCached = ImageRepository.sharedInstance.isCached(url: thumbnail)
            
            imageDownloadTask = ImageRepository.sharedInstance.getImage(url: thumbnail) { [weak self] (result) in
                switch(result) {
                case .success(let image):
                    if let image = image {
                        self?.imageView?.image = image
                        if wasCached == false {
                            self?.imageView?.fadeIn()
                        }
                    }
                case .error(let error):
                    break
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView?.image = nil
        hero.id = nil
        
        //If a previous image downloading was in progress, cancel it to avoid loading the image in a wrong (reused) cell
        if let imageDownloadTask = imageDownloadTask {
            imageDownloadTask.cancel()
        }
    }
}
