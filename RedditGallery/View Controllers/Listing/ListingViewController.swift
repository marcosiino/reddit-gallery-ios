//
//  ListingViewController.swift
//  RedditGallery
//
//  Created by Marco Siino on 03/12/2020.
//

import Foundation
import UIKit
import MSLoadingHUD

class ListingViewController: UIViewController, Loadable {
    
    enum BigImageAlignment {
        case left
        case right
    }
    
    enum Section {
        case top
        case main
    }
    
    enum ListingMode {
        case posts(mainRepository: DataRepositoryProtocol, topRepository: DataRepositoryProtocol)
        case favorites(favoritesRepository: DataRepositoryProtocol)
    }
    
    private var searchBar: UISearchBar?
    private var searchTimer: Timer?
    private var emptyView: EmptyView?
    private var searchBarPlaceholderText: String  = ""
    private let listingMode: ListingMode
    private let favoritesService: FavoritesServiceProtocol
    
    var lastSearchKeyword: String?
    
    var topPosts: [Post]? {
        didSet {
            updateUI()
        }
    }
    
    var posts: [Post]? {
        didSet {
            updateUI()
        }
    }
    
    var collectionView: UICollectionView?
    var datasource: UICollectionViewDiffableDataSource<Section, Post>?

    init(mode: ListingMode, favoritesService: FavoritesServiceProtocol) {
        self.listingMode = mode
        self.favoritesService = favoritesService
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(favoritesChanged), name: .addedFavorite, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(favoritesChanged), name: .removedFavorite, object: nil)
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.white
        navigationController?.view.backgroundColor = UIColor.white

        if let loadedEmptyView = Bundle.main.loadNibNamed("EmptyView", owner: nil, options: [:])?.first as? EmptyView {
            emptyView = loadedEmptyView
            emptyView?.setMessage(message: "")
        }
        
        let layout = setupCollectionViewLayout()
        setupCollectionView(layout: layout, emptyStateView: emptyView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resignSearchBar))
        emptyView?.addGestureRecognizer(tapGestureRecognizer)
        
        //navigationController?.heroNavigationAnimationType = 
        navigationController?.hero.isEnabled = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateUI() {
        
        guard (posts != nil && posts!.count > 0) || (topPosts != nil && topPosts!.count > 0) else {
            //Create a snapshot with no items
            var snapshot = NSDiffableDataSourceSnapshot<Section, Post>()
            snapshot.appendSections([.main])
            datasource?.apply(snapshot)

            collectionView?.backgroundView = emptyView
            return
        }
        
        collectionView?.backgroundView = nil
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Post>()
        
        if let topPosts = topPosts, topPosts.count > 0 {
            snapshot.appendSections([.top])
            snapshot.appendItems(topPosts)
        }
        
        if let posts = posts, posts.count > 0 {
            snapshot.appendSections([.main])
            snapshot.appendItems(posts)
        }
        
        datasource?.apply(snapshot)
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
        
        switch(listingMode) {
        case .posts(let mainRepository, let topRepository):
            mainRepository.getPosts(searchKeyword: keyword, afterId: nil, completionHandler: { [weak self] (result) in
                
                self?.hideLoadingHUD()
                
                switch(result) {
                case .success(let posts):
                    self?.posts = posts
                case .error(_):
                    //TODO: show error
                break
                }
            })
            
            topRepository.getPosts(searchKeyword: keyword, afterId: nil, completionHandler: { [weak self] (result) in
                
                self?.hideLoadingHUD()
                
                switch(result) {
                case .success(let posts):
                    self?.topPosts = posts
                case .error(_):
                    //TODO: show error
                break
                }
            })
            
        case .favorites(let favoritesRepository):
            favoritesRepository.getPosts(searchKeyword: keyword, afterId: nil, completionHandler: { [weak self] (result) in
                
                self?.hideLoadingHUD()
                
                switch(result) {
                case .success(let posts):
                    self?.posts = posts
                case .error(_):
                    //TODO: show error
                break
                }
            })
        }
    }
    
    func setSearchBarPlaceholderText(text: String) {
        searchBarPlaceholderText = text
        searchBar?.placeholder = text
    }
    
    func setEmptyStateMessage(text: String) {
        emptyView?.setMessage(message: text)
    }
    
    func setEmptyStateImage(image: UIImage) {
        emptyView?.setImage(image: image)
    }
    
    func getLastSearchKeyword() -> String {
        return lastSearchKeyword ?? ""
    }
    
    @objc func resignSearchBar() {
        searchBar?.resignFirstResponder()
    }
}

extension ListingViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText != lastSearchKeyword else {
            return
        }
        
        //Invalidate the previous timer (if any) and create a new timer which delays the search to avoid asking the DataRepository new items for every character typed
        searchTimer?.invalidate()
        searchTimer = nil
        searchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { [weak self] (timer) in
    
            //searchController.dismiss(animated: true) {
                self?.search(keyword: searchText)
            //}
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar = searchBar
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar = nil
    }
}

extension ListingViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        var repository: DataRepositoryProtocol?
        
        switch(listingMode) {
        case .posts(let mainRepository, _):
            repository = mainRepository
        case .favorites(let favoritesRepository):
            repository = favoritesRepository
        }
        
        guard let dataRepository = repository, dataRepository.supportsPaging() else {
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
        var repository: DataRepositoryProtocol? //The repository to pass to the PostsPageViewController {
        
        var items: [Post]?
        
        switch(listingMode) {
        case .posts(let mainRepository, let topRepository):
            
            if indexPath.section == 0 {
                repository = topRepository
                items = topPosts
            }
            else {
                repository = mainRepository
                items = posts
            }
            
        case .favorites(let favoritesRepository):
            repository = favoritesRepository
            items = posts
        }
        
        if let items = items, let repository = repository {
            let detailVC = PostsPageViewController(posts: items, initialPostIndex: indexPath.row, dataRepository: repository, favoritesService: favoritesService)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        resignSearchBar()
    }
    
    private func loadMoreResults(afterPostId postId: String) {
        //showLoadingHUD(loadingMessage: NSLocalizedString("listing.loadingMoreResults", comment: "listing.loadingMoreResults"))
        guard let lastSearchKeyword = lastSearchKeyword else {
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        var repository: DataRepositoryProtocol?
        
        switch(listingMode) {
        case .posts(let mainRepository, _):
            repository = mainRepository
        case .favorites(let favoritesRepository):
            repository = favoritesRepository
        }
        
        repository?.getPosts(searchKeyword: lastSearchKeyword, afterId: postId, completionHandler: { [weak self] (result) in
            
            //self?.hideLoadingHUD()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            switch(result) {
            case .success(let posts):
                if posts.count > 0 {
                    self?.posts?.append(contentsOf: posts)
                }
                
            case .error(_):
                break
            }
        })
    }
}

// MARK - Collection View setup and Compositional Layout setup
extension ListingViewController {
    
    func setupCollectionView(layout: UICollectionViewLayout, emptyStateView: UIView?) {
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.delegate = self
        view.addSubview(collectionView!)
        
        collectionView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        collectionView?.register(CollectionHeaderSearchView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SearchHeader")
        collectionView?.register(UINib(nibName: "GalleryItemCell", bundle: nil), forCellWithReuseIdentifier: "GalleryItemCell")
        
        collectionView?.backgroundView = emptyStateView
        
        datasource = UICollectionViewDiffableDataSource<Section, Post>(collectionView: collectionView!, cellProvider: { [weak self] (collectionView, indexPath, post) -> UICollectionViewCell? in
            
            guard let section = self?.datasource?.snapshot().sectionIdentifier(containingItem: post) else {
                return nil
            }
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryItemCell", for: indexPath) as? GalleryItemCell else  {
                return nil
            }
            
            switch(section) {
            case .top:
                cell.setPost(post: post, topItem: true)
            case .main:
                cell.setPost(post: post, topItem: false)
            }
            
            return cell
        })
        
        datasource?.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> UICollectionReusableView? in
            
            if kind == UICollectionView.elementKindSectionHeader {
                if let searchView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SearchHeader", for: indexPath) as? CollectionHeaderSearchView {
                
                    searchView.delegate = self
                    searchView.searchPlaceholder = self?.searchBarPlaceholderText
                    
                    return searchView
                }
            }
            
            return nil
        }
    }
    
    func buildMainSection() -> NSCollectionLayoutSection {
        //First group with 3 horizontal items
        let threeImagesGroup = horizontalItemsGroup() //Height 1/3
        let compositeGroupImgLeft = compositeGroupWithBigImage(bigImageAlignment: .left) // Height 2/3
        let compositeGroupImgRight = compositeGroupWithBigImage(bigImageAlignment: .right) // Height 2/3
        
        let groupsContainer = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(6/3)), //height of each row is 1/3 of the collectionview width
            subitems: [
                threeImagesGroup, //1/3
                compositeGroupImgLeft, //2/3
                threeImagesGroup, //1/3
                compositeGroupImgRight, //2/3
            ])
    
        return NSCollectionLayoutSection(group: groupsContainer)
    }
    
    func buildTopSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8.0, leading: 10.0, bottom: 10.0, trailing: 8.0)
        
        let groupLayoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.9),
            heightDimension: .fractionalHeight(0.3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize:groupLayoutSize, subitems: [item])
    
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
    }
    
    func getCompositionalLayoutSections() -> [NSCollectionLayoutSection] {
        
        switch(listingMode) {
        case .posts(_, _):
            let topSection = buildTopSection()
            let mainSection = buildMainSection()
            return [topSection, mainSection]
        case .favorites(_):
            let mainSection = buildMainSection()
            return [mainSection]
        }
        
    }
    
    func setupCollectionViewLayout() -> UICollectionViewLayout {
    
        let sections = getCompositionalLayoutSections()
        
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(50)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        sections.first?.boundarySupplementaryItems = [headerItem]
        
        return UICollectionViewCompositionalLayout { (sectionNumber, environment) -> NSCollectionLayoutSection? in
            
            guard sectionNumber < sections.count else {
                return nil
            }
            
            return sections[sectionNumber]
        }
    }
    
    func horizontalItemsGroup() -> NSCollectionLayoutGroup {
        let imageItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/3),
                heightDimension: .fractionalHeight(1.0)))
        imageItem.contentInsets = NSDirectionalEdgeInsets(
            top: 2.0,
            leading: 2.0,
            bottom: 2.0,
            trailing: 2.0)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(1/3)),
            subitems: [imageItem, imageItem, imageItem])
        
        return group
    }
    
    func compositeGroupWithBigImage(bigImageAlignment: BigImageAlignment) -> NSCollectionLayoutGroup {
        
        //Big Image
        let bigImageItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(2/3),
                heightDimension: .fractionalHeight(1.0)))
        bigImageItem.contentInsets = NSDirectionalEdgeInsets(
            top: 2.0,
            leading: 2.0,
            bottom: 2.0,
            trailing: 2.0)
        
        //Trailing group
        let smallImageItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)))
        smallImageItem.contentInsets = NSDirectionalEdgeInsets(
            top: 2.0,
            leading: 2.0,
            bottom: 2.0,
            trailing: 2.0)
        
        let verticalSmallImagesGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/3),
                heightDimension: .fractionalHeight(1.0)),
            subitem: smallImageItem,
            count: 2)
        
        let subItems = bigImageAlignment == .left ?
            [bigImageItem, verticalSmallImagesGroup] //Big image on the left
            :
            [verticalSmallImagesGroup, bigImageItem] //Big image on the right
        
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(2/3)),
            subitems: subItems)
        
        return containerGroup
    }
}
