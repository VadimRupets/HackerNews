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
    
    // MARK: - Internal UI
    
    func configureNavigationBar() {
        
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StoryTableViewCell.identifier, for: indexPath) as? StoryTableViewCell else {
            return UITableViewCell()
        }
        
        let story = stories[indexPath.row]
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
    
    func fetchStoriesIds() {
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
            guard let storiesCount = self?.stories.count else { return }
            
            let indexesToReload = storiesCountBefore..<storiesCount
            let indexPathsToInsert = indexesToReload.map { return IndexPath(row: $0, section: 0) }
            
            self?.storiesLoaded += self?.storiesPerPage ?? 0
            self?.tableView.insertRows(at: indexPathsToInsert, with: .automatic)
        }
    }
    
}
