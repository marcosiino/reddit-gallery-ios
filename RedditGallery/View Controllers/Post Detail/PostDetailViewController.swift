//
//  PostDetailViewController.swift
//  RedditGallery
//
//  Created by Marco Siino on 05/12/2020.
//

import Foundation
import UIKit

/**
 A view controller which shows a single post details
 */


class PostDetailViewController: UITableViewController, DataRepositoryInjectable {
    
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var authorLabel: UILabel?
    @IBOutlet weak var upsLabel: UILabel?
    @IBOutlet weak var downsLabel: UILabel?
    @IBOutlet weak var favoriteButton: UIButton?
    @IBOutlet weak var upsImageView: UIImageView?
    @IBOutlet weak var downsImageView: UIImageView?
    @IBOutlet weak var imageLoadingIndicator: UIActivityIndicatorView?
    
    //Read only from outside because the viewcontroller is observing favorite changes notifications only for the post id which is showing
    private(set) var post: Post?
    
    var dataRepository: DataRepository?
    
    static func instantiate(post: Post, dataRepository: DataRepository) -> PostDetailViewController {
        let vc = UIStoryboard(name: "PostDetail", bundle: nil).instantiateViewController(identifier: "PostDetailViewController") as! PostDetailViewController
        
        vc.post = post
        vc.dataRepository = dataRepository
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        tableView.estimatedRowHeight = 200.0
        tableView.rowHeight = UITableView.automaticDimension
        
        if let post = post {
            NotificationCenter.default.addObserver(self, selector: #selector(favoriteAdded), name: .addedFavorite, object: post.id)
            NotificationCenter.default.addObserver(self, selector: #selector(favoriteRemoved), name: .removedFavorite, object: post.id)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func updateUI() {
        if let post = post {
            titleLabel?.text = post.title
            authorLabel?.text = post.author
            
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            
            if let ups = post.ups, let downs = post.downs {
                upsLabel?.text = formatter.string(from: NSNumber(integerLiteral: ups))
                downsLabel?.text = formatter.string(from: NSNumber(integerLiteral: downs))
            }
            else {
                upsLabel?.text = ""
                downsLabel?.text = ""
                upsImageView?.isHidden = true
                downsImageView?.isHidden = true
            }
            
            let symbolConf = UIImage.SymbolConfiguration(pointSize: 20.0, weight: .medium, scale: .large)
            
            if post.favorited {
                let image = UIImage(systemName: "heart.fill", withConfiguration: symbolConf)
                favoriteButton?.setImage(image, for: .normal)
                favoriteButton?.tintColor = UIColor.systemRed
            }
            else {
                let image = UIImage(systemName: "heart", withConfiguration: symbolConf)
                favoriteButton?.setImage(image, for: .normal)
                favoriteButton?.tintColor = UIColor.systemRed
            }
        }
        
        loadImage()
    }
    
    private func loadImage() {
        if let post = post, let imageUrl = post.images.first {
            let isCached = ImageRepository.sharedInstance.isCached(url: imageUrl)
            
            //Only show the loading HUD if the image is not cached (it would require time
            if isCached == false {
                imageLoadingIndicator?.isHidden = false
            }
            
            ImageRepository.sharedInstance.getImage(url: imageUrl) { [weak self] (result) in
                guard let self = self else {
                    return
                }
             
                if isCached == false {
                    self.imageLoadingIndicator?.isHidden = true
                    self.animateDownloadedImage()
                }
                
                switch(result) {
                case .success(let image):
                    if let image = image {
                        self.imageView?.image = image
                    }
                    
                case .error(let error):
                    print("Unable to load image: \(error?.localizedDescription)")
                }
            }
        }
    }
    
    private func animateDownloadedImage() {
        imageView?.alpha = 0.0
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.imageView?.alpha = 1.0
        }
    }
    
    @IBAction func favoriteButtonTouched() {
        guard post != nil else {
            return
        }
        
        if post!.favorited { //Is already favorite
            //Remove from favorites
            if let result = dataRepository?.removeFavorite(post: post!), result == true
            {
                post!.favorited = false
                updateUI()
            }
        }
        else { //Is not favorited
            //Add as favorite
            if let result = dataRepository?.addFavorite(post: post!), result == true {
                post!.favorited = true
                updateUI()
            }
        }
    }
    
    //The post has been added to favorites from outside, refresh UI
    @objc func favoriteAdded(notification: Notification) {
        guard let post = post else {
            return
        }
        
        if let postId = notification.object as? String, postId == post.id {
            post.favorited = true
            updateUI()
        }
    }
    
    //The post has been removed from favorites from outside, refresh UI
    @objc func favoriteRemoved(notification: Notification) {
        guard let post = post else {
            return
        }
        
        if let postId = notification.object as? String, postId == post.id {
            post.favorited = false
            updateUI()
        }
    }

}

extension PostDetailViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Selected the image
        if indexPath.row == 0, let image = imageView?.image {
            let imageViewerVC = ImageViewerViewController.instantiate(image: image)
            imageViewerVC.modalPresentationStyle = .fullScreen
            present(imageViewerVC, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return self.view.frame.size.height*0.6 //The image has a fixed height
        }
        else{
            return UITableView.automaticDimension
        }
    }

}
