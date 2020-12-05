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

class PostDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var scrollView: UIScrollView?
    
    var post: Post?
    weak var delegate: PostDetailViewControllerDelegate?
    
    static func instantiate(post: Post, delegate: PostDetailViewControllerDelegate) -> PostDetailViewController {
        let vc = UIStoryboard(name: "PostDetail", bundle: nil).instantiateViewController(identifier: "PostDetailViewController") as! PostDetailViewController
        
        vc.post = post
        vc.delegate = delegate
        
        return vc
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView?.minimumZoomScale = 1.0
        scrollView?.maximumZoomScale = 3.0
        
        let tapToZoomGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToZoom))
        tapToZoomGestureRecognizer.numberOfTapsRequired = 2
        scrollView?.addGestureRecognizer(tapToZoomGestureRecognizer)
        
        if let post = post, let imageUrl = post.images.first {
            
            delegate?.didStartLoadingPost(postDetailViewController: self, post: post)
            
            ImageRepository.sharedInstance.getImage(url: imageUrl) { [weak self] (result) in
                guard let self = self else {
                    return
                }
                
                self.delegate?.didFinishLoadingPost(postDetailViewController: self, post: post)
                
                switch(result) {
                case .success(let image):
                    if let image = image {
                        self.imageView?.image = image
                    }
                    
                case .error(_):
                    let alert = UIAlertController(title: NSLocalizedString("generic.error", comment: "generic.error"), message: NSLocalizedString("postDetail.loadingImageFailedMessage", comment: "postDetail.loadingImageFailedMessage"), preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("generic.ok", comment: "generic.ok"), style: .default, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    break
                }
            }
        }
    }
    
    @objc func tapToZoom() {
        //Every time a double tap is performed, zoom to maximum zoom if the current zoom is less than 1.5, or to minimumScale if the current zoom is greater or equal than 1.5
        if let scrollView = scrollView {
            if scrollView.zoomScale < 1.5 {
                scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
            }
            else {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            }
        }
    }
}

extension PostDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
