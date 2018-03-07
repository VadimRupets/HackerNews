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
    
    var storiesRequest = StoriesRequests.topStories
    
    var stories: [Story] = []
    var storiesIds: [Int] = [] {
        didSet {
            fetchStories(startIndex: 0, endIndex: storiesPerPage)
        }
    }
    
    private let storiesPerPage = 20
    private var storiesLoaded = 0
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        cell.configure(with: story)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let story = stories[indexPath.row]
        
        let safariViewController = SFSafariViewController(url: story.url)
        present(safariViewController, animated: true, completion: nil)
    }
    
    // MARK: - Networking
    
    @IBAction func fetchStoriesIds() {
        let storiesOperation = StoriesOperation(request: storiesRequest)
        storiesOperation.execute(in: NetworkDispatcher()) { [weak self] ids, error in
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
            
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
            }
        }
    }
    
    func fetchStories(startIndex: Int, endIndex: Int) {
        let storiesCountBefore = stories.count
        let storiesIdsToFetch = Array(storiesIds[startIndex...endIndex])
        
        let dispatchGroup = DispatchGroup()
        storiesIdsToFetch.forEach {
            dispatchGroup.enter()
            
            let storyOperation = StoryOperation(storyId: String($0))
            storyOperation.execute(in: NetworkDispatcher(), completionHandler: { [weak self] story, error in
                defer {
                    dispatchGroup.leave()
                }
                
                guard let story = story else {
                    print("")
                    return
                }
                
                self?.stories.append(story)
            })
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard startIndex != 0 else {
                self?.tableView.reloadData()
                return
            }
            
            guard let storiesCount = self?.stories.count else { return }
            
            let indexesToReload = storiesCountBefore..<storiesCount
            let indexPathsToInsert = indexesToReload.map { return IndexPath(row: $0, section: 0) }
            
            self?.storiesLoaded += self?.storiesPerPage ?? 0
            self?.tableView.insertRows(at: indexPathsToInsert, with: .automatic)
        }
    }
    
}
