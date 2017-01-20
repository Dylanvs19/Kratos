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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with tally: LightTally) {
        label.text = tally.question
        
        if let userVote = tally.voteValue {
            yourVoteImageView.image = UIImage.imageFor(vote: userVote)
        }
        
        // currently not going to be implementing repVotes 2 & 3
        repVoteImageViewOne.isHidden = true
        repVoteImageViewTwo.isHidden = true
        repVoteImageViewThree.isHidden = true
    }
}
