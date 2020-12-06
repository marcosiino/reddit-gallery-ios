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
    
    private var magnifyingGlassImageView: UIImageView?
    private var magnifyingGlassCenterXConstr: NSLayoutConstraint?
    private var magnifyingGlassCenterYConstr: NSLayoutConstraint?
    private var magnifyingGlassRightAnchorConstr: NSLayoutConstraint?
    private var magnifyingGlassBottomAnchorConstr: NSLayoutConstraint?
    private var magnifyingGlassWidthAnchorConstr: NSLayoutConstraint?
    private var magnifyingGlassHeightAnchorConstr: NSLayoutConstraint?
    
    private var magnifyingGlassTimer: Timer?
    
    private var isAppearing = false
    
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
        
        setupUI()
        updateUI()
        
        if let post = post {
            NotificationCenter.default.addObserver(self, selector: #selector(favoriteAdded), name: .addedFavorite, object: post.id)
            NotificationCenter.default.addObserver(self, selector: #selector(favoriteRemoved), name: .removedFavorite, object: post.id)
        }
        
        setMagnifyingGlassPosition(position: .bottomRightCorner)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isAppearing = true
        //Play the magnifying glass animation every 5 seconds
        scheduleMagnifyingGlassAnimationTimer()

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isAppearing = false
        
        //Stop playing the animation
        magnifyingGlassTimer?.invalidate()
        magnifyingGlassTimer = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        tableView.estimatedRowHeight = 200.0
        tableView.rowHeight = UITableView.automaticDimension
        
        //Setup Magnifying glass image view
        magnifyingGlassImageView = UIImageView(frame: CGRect.zero)
        magnifyingGlassImageView?.image = UIImage(systemName: "magnifyingglass")
        magnifyingGlassImageView?.tintColor = UIColor.white
        
        imageView?.addSubview(magnifyingGlassImageView!)
        magnifyingGlassImageView?.translatesAutoresizingMaskIntoConstraints = false
        
        //Size anchors
        magnifyingGlassWidthAnchorConstr = magnifyingGlassImageView?.widthAnchor.constraint(equalToConstant: 60.0)
        magnifyingGlassHeightAnchorConstr = magnifyingGlassImageView?.heightAnchor.constraint(equalToConstant: 60.0)
        magnifyingGlassWidthAnchorConstr?.isActive = true
        magnifyingGlassHeightAnchorConstr?.isActive = true
        
        if let imageView = imageView {
            //Magnifying glass image center constraints
            magnifyingGlassCenterXConstr = magnifyingGlassImageView?.centerXAnchor.constraint(equalTo: imageView.centerXAnchor)
            magnifyingGlassCenterYConstr = magnifyingGlassImageView?.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
            
            //Magnifying glass bottom-right corner anchoring constraints
            magnifyingGlassRightAnchorConstr = magnifyingGlassImageView?.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: -8.0)
            magnifyingGlassBottomAnchorConstr = magnifyingGlassImageView?.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -8.0)
            
        }
         
        setMagnifyingGlassPosition(position: .center)
    }
    
    private func scheduleMagnifyingGlassAnimationTimer() {
        self.magnifyingGlassTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { [weak self] (timer) in
            self?.showMagnifyingGlass()
        })
    }
    
    enum MagnifyingGlassPosition {
        case center
        case bottomRightCorner
    }
    
    //Switch the magnifying glass constraints between the center constraints and the bottom-right anchoring constraints
    private func setMagnifyingGlassPosition(position: MagnifyingGlassPosition) {
        switch(position) {
        case .center:
            magnifyingGlassCenterXConstr?.isActive = true
            magnifyingGlassCenterYConstr?.isActive = true
            magnifyingGlassRightAnchorConstr?.isActive = false
            magnifyingGlassBottomAnchorConstr?.isActive = false
        
            magnifyingGlassWidthAnchorConstr?.constant = 60.0
            magnifyingGlassHeightAnchorConstr?.constant = 60.0
            
        case .bottomRightCorner:
            magnifyingGlassCenterXConstr?.isActive = false
            magnifyingGlassCenterYConstr?.isActive = false
            magnifyingGlassRightAnchorConstr?.isActive = true
            magnifyingGlassBottomAnchorConstr?.isActive = true
            
            magnifyingGlassWidthAnchorConstr?.constant = 40.0
            magnifyingGlassHeightAnchorConstr?.constant = 40.0
        }
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
                    self.imageView?.fadeIn { [weak self] in
                    }
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
    
    private func showMagnifyingGlass() {
        setMagnifyingGlassPosition(position: .center)
        magnifyingGlassImageView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        //Scale in
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut) { [weak self] in
            self?.magnifyingGlassImageView?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        } completion: { [weak self] _ in
            //Scale out
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut) { [weak self] in
                self?.magnifyingGlassImageView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            } completion: { [weak self] _ in
                //Scale in
                UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut) { [weak self] in
                    self?.magnifyingGlassImageView?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                } completion: { [weak self] _ in
                    //Scale out
                    UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut) { [weak self] in
                        self?.magnifyingGlassImageView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    } completion: { [weak self] _ in
                        
                        //Move to the bottom-right corner
                        self?.setMagnifyingGlassPosition(position: .bottomRightCorner)
                        UIView.animate(withDuration: 0.25, delay: 1.0, options: .curveEaseOut) {
                            [weak self] in
                            self?.view.layoutIfNeeded()
                        } completion: { [weak self] _ in
                            guard let self = self else {
                                return
                            }
                            
                            //Schedule the next animation
                            if self.isAppearing {
                                self.scheduleMagnifyingGlassAnimationTimer()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func favoriteButtonTouched() {
        guard post != nil else {
            return
        }
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
        feedbackGenerator.impactOccurred()
        
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
            navigationController?.pushViewController(imageViewerVC, animated: true)
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
