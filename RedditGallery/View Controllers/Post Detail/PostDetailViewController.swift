//
//  PostDetailViewController.swift
//  RedditGallery
//
//  Created by Marco Siino on 05/12/2020.
//

import Foundation
import UIKit
import MSLoadingHUD

/**
 A view controller which shows a single post details
 */

protocol PostDetailViewControllerDelegate: class {
    func didStartLoadingPost(postDetailViewController: PostDetailViewController, post: Post)
    func didFinishLoadingPost(postDetailViewController: PostDetailViewController, post: Post)
}

class PostDetailViewController: UITableViewController, DataRepositoryInjectable {
    
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var authorLabel: UILabel?
    @IBOutlet weak var upsLabel: UILabel?
    @IBOutlet weak var downsLabel: UILabel?
    @IBOutlet weak var favoriteButton: UIButton?
    
    var post: Post?
    var dataRepository: DataRepository?
    weak var delegate: PostDetailViewControllerDelegate?
    
    static func instantiate(post: Post, delegate: PostDetailViewControllerDelegate, dataRepository: DataRepository) -> PostDetailViewController {
        let vc = UIStoryboard(name: "PostDetail", bundle: nil).instantiateViewController(identifier: "PostDetailViewController") as! PostDetailViewController
        
        vc.post = post
        vc.delegate = delegate
        vc.dataRepository = dataRepository
        return vc
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        tableView.estimatedRowHeight = 200.0
        tableView.rowHeight = UITableView.automaticDimension
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
                delegate?.didStartLoadingPost(postDetailViewController: self, post: post)
            }
            
            ImageRepository.sharedInstance.getImage(url: imageUrl) { [weak self] (result) in
                guard let self = self else {
                    return
                }
             
                if isCached == false {
                    self.delegate?.didFinishLoadingPost(postDetailViewController: self, post: post)
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

}

extension PostDetailViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Selected the image
        if indexPath.row == 0, let image = imageView?.image {
            let imageViewerVC = ImageViewerViewController.instantiate(image: image)
            present(imageViewerVC, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return self.view.frame.size.height*0.4 //The image has a fixed height
        }
        else{
            return UITableView.automaticDimension
        }
    }

}
