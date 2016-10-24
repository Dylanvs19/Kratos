//
//  LegislationTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class VoteTableViewCell: UITableViewCell {

    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var voteTitleLabel: UILabel!
    
    @IBOutlet var voteImageView: UIImageView!
    
    var vote: Vote? {
        didSet {
            if vote != nil {
                configureWith(vote!)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureWith(_ vote: Vote) {
        voteTitleLabel.text = vote.questionTitle ?? ""
        if let voteType = vote.vote {
            switch voteType {
            case .yea:
                voteImageView.image = UIImage(named: "Yes")
            case .nay:
                voteImageView.image = UIImage(named: "No")
            case .abstain:
                voteImageView.image = UIImage(named: "Abstain")
            }
        }
        if let date = vote.date {
        dateLabel.text = DateFormatter.presentationDateFormatter.string(from: date)
        } else {
            dateLabel.text = ""
        }
    }
    
}
