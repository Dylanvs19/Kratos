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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configureWith(userVote: UserVote) {
        label.text = userVote.billTitle
        
        if let userVote = userVote.vote {
            yourVoteImageView.image = imageFor(vote: userVote)
        }
        
        let repVoteArray = [userVote.repOneVote, userVote.repTwoVote, userVote.repThreeVote]
        let repVoteViewArray = [repVoteImageViewOne, repVoteImageViewTwo, repVoteImageViewThree]
        let sanitizedRepVoteArray = repVoteArray.flatMap({_ in})
        let final = zip(repVoteViewArray, sanitizedRepVoteArray)
        
        final.forEach {
            if let vote = $0.1 as? VoteType {
                $0.0?.image = imageFor(vote: vote)
            }
        }
        
    }
    
    fileprivate func imageFor(vote: VoteType) -> UIImage {
        switch vote {
        case .yea:
            return #imageLiteral(resourceName: "Yes")
        case .nay:
            return #imageLiteral(resourceName: "No")
        case .abstain:
            return #imageLiteral(resourceName: "Abstain")
        }
    }
    
}
