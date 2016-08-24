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
        voteTitleLabel.text = vote.question ?? ""
        voteLabel.text = vote.vote ?? ""
        if let date = vote.date {
        dateLabel.text = NSDateFormatter.presentationDateFormatter.stringFromDate(date)
        } else {
            dateLabel.text = ""
        }
    }
    
}
