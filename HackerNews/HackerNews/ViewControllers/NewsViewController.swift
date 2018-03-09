//
//  NewsViewController.swift
//  HackerNews
//
//  Created by Vadim Rupets on 3/5/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import UIKit
import SafariServices

class NewsViewController: UITableViewController {
    
    lazy var tableViewBackgroundActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.hidesWhenStopped = true
        
        return activityIndicator
    }()
    
    lazy var tableViewFooterActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        activityIndicator.activityIndicatorViewStyle = .gray
        
        return activityIndicator
    }()
    
    let cache = NSCache<AnyObject, UIImage>()
    
    var storiesRequest = StoriesRequests.topStories
    
    var stories: [Story] = []
    var storiesIds: [Int] = [] {
        didSet {
            let endIndex = min(storiesPerPage, storiesIds.count)
            fetchStories(startIndex: 0, endIndex: endIndex)
        }
    }
    
    private let storiesPerPage = 20
    private let reloadDistance: CGFloat = 88
    
    private var storiesLoaded = 0
    
    private var isLoadingNextPage = false
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = tableViewBackgroundActivityIndicator
        tableView.tableFooterView = UIView()
        
        fetchStoriesIds()
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: StoryTableViewCell.identifier, for: indexPath) as? StoryTableViewCell,
            let story = stories[safe: indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.titleLabel.text = story.title
        
        if let cachedIcon = cache.object(forKey: story.id as AnyObject) {
            cell.iconImageView.image = cachedIcon
        } else {
            cell.activityIndicator.startAnimating()
            
            DispatchQueue.global().async {
                IconDownloader().downloadIcon(from: story.url, completionHandler: { icon in
                    DispatchQueue.main.async { [weak self] in
                        self?.cache.setObject(icon, forKey: story.id as AnyObject)
                        
                        cell.activityIndicator.stopAnimating()
                        if let _ = tableView.cellForRow(at: indexPath) {
                            cell.iconImageView.image = icon
                        }
                    }
                })
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let story = stories[indexPath.row]
        
        let safariViewController = SFSafariViewController(url: story.url)
        present(safariViewController, animated: true, completion: nil)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard
            !isLoadingNextPage,
            storiesIds.count > storiesLoaded else { return }
        
        let yOffset = scrollView.contentOffset.y
        let scrollViewHeight = scrollView.bounds.height
        let contentSizeHeight = scrollView.contentSize.height
        let bottomInset = scrollView.contentInset.bottom
        
        if yOffset + scrollViewHeight + bottomInset + reloadDistance > contentSizeHeight {
            let endIndex = min(storiesIds.count, storiesLoaded + storiesPerPage)
            fetchStories(startIndex: storiesLoaded, endIndex: endIndex)
        }
    }
    
    // MARK: - Networking
    
    @IBAction func fetchStoriesIds() {
        tableViewBackgroundActivityIndicator.startAnimating()
        
        let storiesOperation = StoriesOperation(request: storiesRequest)
        storiesOperation.execute(in: NetworkDispatcher()) { [weak self] ids, error in
            defer {
                DispatchQueue.main.async {
                    self?.refreshControl?.endRefreshing()
                    self?.tableViewBackgroundActivityIndicator.stopAnimating()
                }
            }
            
            guard error == nil else {
                self?.showErrorAlert(with: error?.localizedDescription)
                return
            }
            
            guard let storiesIds = ids else {
                self?.showErrorAlert(with: NetworkError.noData.localizedDescription)
                return
            }
            
            self?.storiesIds = storiesIds
            self?.stories = []
        }
    }
    
    func fetchStories(startIndex: Int, endIndex: Int) {
        isLoadingNextPage = true
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.tableFooterView = self?.tableViewFooterActivityIndicator
            self?.tableViewFooterActivityIndicator.startAnimating()
        }
        
        let storiesIdsToFetch = Array(storiesIds[startIndex..<endIndex])
        
        let dispatchGroup = DispatchGroup()
        storiesIdsToFetch.forEach {
            dispatchGroup.enter()
            
            let storyOperation = StoryOperation(storyId: String($0))
            storyOperation.execute(in: NetworkDispatcher(), completionHandler: { [weak self] story, error in
                defer {
                    dispatchGroup.leave()
                }
                
                guard let story = story else {
                    return
                }
                
                self?.stories.append(story)
            })
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            defer {
                self?.isLoadingNextPage = false
                self?.tableView.tableFooterView = UIView()
            }
            
            self?.storiesLoaded = endIndex
            self?.tableView.reloadData()
        }
    }
    
}
