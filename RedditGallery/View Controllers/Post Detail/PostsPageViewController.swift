//
//  PostsPageViewController.swift
//  RedditGallery
//
//  Created by Marco Siino on 05/12/2020.
//

/**
 A page view controllers which allows to swipe between a list of post details
 */

import Foundation
import UIKit

protocol PostsPageViewControllerDelegate: class {
    func didStartLoadingPostData()
    func didFinishLoadingPostData()
}

class PostsPageViewController: UIPageViewController {
    
    private let posts: [Post]
    private var currentPostIndex: Int = 0
    weak var postsPagesDelegate: PostsPageViewControllerDelegate?
    
    init(posts _posts: [Post], currentPostIndex index: Int, delegate _del: PostsPageViewControllerDelegate) {
        
        posts = _posts
        if currentPostIndex < posts.count {
            currentPostIndex = index
        }
        else {
            currentPostIndex = 0
        }
        
        postsPagesDelegate = _del
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentPost = posts[currentPostIndex]
        setViewControllers([PostDetailViewController.instantiate(post: currentPost, delegate: self)], direction: .forward, animated: true, completion: nil)
    }
}

extension PostsPageViewController: PostDetailViewControllerDelegate {
    func didFinishLoadingPost(postDetailViewController: PostDetailViewController, post: Post) {
        postsPagesDelegate?.didFinishLoadingPostData()
    }
    
    func didStartLoadingPost(postDetailViewController: PostDetailViewController, post: Post) {
        postsPagesDelegate?.didStartLoadingPostData()
    }
}

extension PostsPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if currentPostIndex + 1 < posts.count {
            currentPostIndex += 1
            return PostDetailViewController.instantiate(post: posts[currentPostIndex], delegate: self)
        }
        else {
            return nil
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if currentPostIndex - 1 >= 0 {
            currentPostIndex -= 1
            
            return PostDetailViewController.instantiate(post: posts[currentPostIndex], delegate: self)
        }
        else {
            return nil
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return posts.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentPostIndex
    }
}
