//
//  YourVoteTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/8/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class YourVoteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var yourVoteImageView: UIImageView!
    
    @IBOutlet weak var repVoteImageViewOne: UIImageView!
    @IBOutlet weak var repVoteImageViewTwo: UIImageView!
    @IBOutlet weak var repVoteImageViewThree: UIImageView!
    
    func configureWith(userVote: UserVote) {
        label.text = userVote.billTitle
        
        if let userVote = userVote.vote {
            yourVoteImageView.image = UIImage.imageFor(vote: userVote)
        }
        
        repVoteImageViewOne.image = UIImage.imageFor(vote: userVote.repOneVote?.voteValue ?? .abstain)
        
        // currently not going to be implementing repVotes 2 & 3
        repVoteImageViewTwo.isHidden = true
        repVoteImageViewThree.isHidden = true
    }
    
}
