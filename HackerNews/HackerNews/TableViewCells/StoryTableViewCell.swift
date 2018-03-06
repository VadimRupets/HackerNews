//
//  StoryTableViewCell.swift
//  HackerNews
//
//  Created by Vadim Rupets on 3/5/18.
//  Copyright © 2018 Vadim Rupets. All rights reserved.
//

import UIKit

class StoryTableViewCell: UITableViewCell {
    
    public static let identifier = "StoryTableViewCell"

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var isConfigured = false
    var isDownloadingIcon = false

    func configure(with story: Story) {
        titleLabel.text = story.title
        
        guard !isConfigured else {
            return
        }
        
        guard !isDownloadingIcon else {
            activityIndicator.startAnimating()
            return
        }
        
        isDownloadingIcon = true
        activityIndicator.startAnimating()
        
        DispatchQueue.global().async {
            do {
                try IconDownloader().downloadIcon(from: story.url, completionHandler: { icon in
                    DispatchQueue.main.async { [weak self] in
                        self?.iconImageView.image = icon
                        self?.activityIndicator.stopAnimating()
                        self?.isConfigured = true
                        self?.isDownloadingIcon = false
                    }
                })
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.iconImageView.image = #imageLiteral(resourceName: "placeholder")
                    self?.activityIndicator.stopAnimating()
                    self?.isConfigured = true
                    self?.isDownloadingIcon = false
                }
            }
        }
    }
    
}
