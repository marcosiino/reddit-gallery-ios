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

class PostsPageViewController: UIPageViewController, DataRepositoryInjectable {
    private let posts: [Post]
    private var currentPostIndex: Int = 0
    var dataRepository: DataRepository?
    
    init(posts _posts: [Post], initialPostIndex index: Int, dataRepository: DataRepository) {
        
        posts = _posts
        if currentPostIndex < posts.count {
            currentPostIndex = index
        }
        else {
            currentPostIndex = 0
        }
        
        self.dataRepository = dataRepository
        
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
        
        if let vc = instantiateDetailViewController(forPostAtIndex: currentPostIndex) {
            setViewControllers([vc], direction: .forward, animated: true, completion: nil)
        }
    }
    
    private func instantiateDetailViewController(forPostAtIndex index: Int) -> PostDetailViewController? {
        guard index < posts.count && index >= 0 else {
            return nil
        }
        
        guard let dataRepository = dataRepository else {
            return nil
        }
        
        //An item which is not the first or the last
        let currentPageVC = PostDetailViewController.instantiate(post: posts[index], dataRepository: dataRepository)
        
        return currentPageVC
    }
}

extension PostsPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? PostDetailViewController, let post = viewController.post {
            if let index = posts.firstIndex(of: post) { //The index of the post that this viewController is showing
                
                if index+1 < posts.count {
                    return instantiateDetailViewController(forPostAtIndex: index + 1)
                }
            }
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? PostDetailViewController, let post = viewController.post {
            if let index = posts.firstIndex(of: post) { //The index of the post that this viewController is showing
                
                if index - 1 >= 0 {
                    return instantiateDetailViewController(forPostAtIndex: index - 1)
                }
            }
        }
        
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return posts.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentPostIndex
    }
}
