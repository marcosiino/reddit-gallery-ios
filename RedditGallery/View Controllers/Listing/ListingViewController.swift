//
//  ListingViewController.swift
//  RedditGallery
//
//  Created by Marco Siino on 03/12/2020.
//

import Foundation
import UIKit
import MSLoadingHUD

class ListingViewController: UIViewController, DataRepositoryInjectable, Loadable {
    
    
    private var searchController: UISearchController?
    private var searchTimer: Timer?
    private var emptyView: EmptyView?
    
    var dataRepository: DataRepository?
    var lastSearchKeyword: String?
    var posts: [Post]? {
        didSet {
            updateUI()
        }
    }
    
    var collectionView: UICollectionView?
    
    init(dataRepository: DataRepository) {
        self.dataRepository = dataRepository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

        search(keyword: "")
        
        NotificationCenter.default.addObserver(self, selector: #selector(favoritesChanged), name: .favoritesChanged, object: nil)
        
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.white
        navigationController?.view.backgroundColor = UIColor.white
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView?.backgroundColor = UIColor.white
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.delegate = self
        collectionView?.dataSource = self
        view.addSubview(collectionView!)
        
        collectionView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        navigationItem.searchController = searchController
        
        if let loadedEmptyView = Bundle.main.loadNibNamed("EmptyView", owner: nil, options: [:])?.first as? EmptyView {
            emptyView = loadedEmptyView
            emptyView?.setMessage(message: NSLocalizedString("generic.initialEmptyMessage", comment: "generic.initialEmptyMessage"))
            collectionView?.backgroundView = emptyView
        }
        
        collectionView?.register(UINib(nibName: "GalleryItemCell", bundle: nil), forCellWithReuseIdentifier: "GalleryItemCell")
        
        
        if let collectionView = collectionView, let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize.zero
            layout.minimumInteritemSpacing = 0.0
            layout.minimumLineSpacing = 0.0
            layout.sectionInset = UIEdgeInsets.zero
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func updateUI() {
        collectionView?.reloadData()
        
        if let posts = posts, posts.count > 0 {
            collectionView?.backgroundView = nil
        }
        else {
            collectionView?.backgroundView = emptyView
            emptyView?.setMessage(message: NSLocalizedString("generic.noResults", comment: "generic.noResults"))
        }
    }

    @objc func favoritesChanged() {
       //Called when favorites is added/removed from any view controller
    }
    
    func search(keyword: String) {
        
        lastSearchKeyword = keyword
        
        let formatStr = NSLocalizedString("listing.searchingLoadingHUDText", comment:"listing.searchingLoadingHUDText")
        
        if let lastSearchKeyword = lastSearchKeyword {
            showLoadingHUD(loadingMessage: String(format:formatStr, lastSearchKeyword))
        }
        else {
            showLoadingHUD()
        }
        
        dataRepository?.getPosts(searchKeyword: keyword, afterId: nil, completionHandler: { [weak self] (result) in
            
            self?.hideLoadingHUD()
            
            switch(result) {
            case .success(let posts):
                self?.posts = posts
            case .error(let error):
                //TODO: show error
            break
            }
        })
    }
    
    func setSearchBoxPlaceholder(placeholder: String) {
        navigationItem.searchController?.searchBar.placeholder = placeholder
    }
}

extension ListingViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text
        guard searchText != lastSearchKeyword else {
            return
        }
        
        if let searchText = searchText {
            //Invalidate the previous timer (if any) and create a new timer which delays the search to avoid asking the DataRepository new items for every character typed
            searchTimer?.invalidate()
            searchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { [weak self] (timer) in
            
                searchController.dismiss(animated: true) {
                    self?.search(keyword: searchText)
                }
            })
        }
    }
}

extension ListingViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryItemCell", for: indexPath) as? GalleryItemCell else  {
            
            return UICollectionViewCell()
        }
        
        if let posts = posts {
            cell.setPost(post: posts[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = collectionView.bounds.size.width/3.0
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let dataRepository = dataRepository, dataRepository.supportsPaging() else {
            return
        }
        
        guard let posts = posts else {
            return
        }
        
        //If it is going to display the last item, i start requesting the data after that item (paging)
        if indexPath.row == posts.count - 1 {
            loadMoreResults(afterPostId: "t3_" + posts[indexPath.row].id)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let posts = posts, let dataRepository = dataRepository {
            let detailVC = PostsPageViewController(posts: posts, initialPostIndex: indexPath.row, delegate: self, dataRepository: dataRepository)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    private func loadMoreResults(afterPostId postId: String) {
        //showLoadingHUD(loadingMessage: NSLocalizedString("listing.loadingMoreResults", comment: "listing.loadingMoreResults"))
        guard let lastSearchKeyword = lastSearchKeyword else {
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        dataRepository?.getPosts(searchKeyword: lastSearchKeyword, afterId: postId, completionHandler: { [weak self] (result) in
            
            //self?.hideLoadingHUD()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            switch(result) {
            case .success(let posts):
                if posts.count > 0 {
                    self?.posts?.append(contentsOf: posts)
                }
                
            case .error(let error):
                break
            }
        })
    }
}

extension ListingViewController: PostsPageViewControllerDelegate {
    func didStartLoadingPostData() {
        showLoadingHUD()
    }
    
    func didFinishLoadingPostData() {
        hideLoadingHUD()
    }
}
