//
//  LegislationTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class VoteTableViewCell: UITableViewCell {

    @IBOutlet var voteLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var voteTitleLabel: UILabel!
    
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
    
    func configureWith(vote: Vote) {
        voteTitleLabel.text = vote.questionTitle ?? ""
        if let voteType = vote.vote {
            switch voteType {
            case .yea:
                voteLabel.textColor = UIColor.greenColor()
                voteLabel.text = voteType.rawValue
            case .nay:
                voteLabel.textColor = UIColor.kratosRed
                voteLabel.text = voteType.rawValue
            case .abstain:
                voteLabel.textColor = UIColor.kratosBlue
                voteLabel.text = voteType.rawValue
            }
        }
        if let date = vote.date {
        dateLabel.text = NSDateFormatter.presentationDateFormatter.stringFromDate(date)
        } else {
            dateLabel.text = ""
        }
    }
    
}
