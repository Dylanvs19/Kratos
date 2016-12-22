//
//  LegislationTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class VoteTableViewCell: UITableViewCell {

    @IBOutlet var voteTitleLabel: UILabel!
    
    @IBOutlet var voteImageView: UIImageView!
    
    var tally: LightTally? {
        didSet {
            if tally != nil {
                configureWith(tally!)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureWith(_ tally: LightTally) {
        voteTitleLabel.text = tally.question ?? ""
        if let voteType = tally.vote {
            switch voteType {
            case .yea:
                voteImageView.image = UIImage(named: "Yes")
            case .nay:
                voteImageView.image = UIImage(named: "No")
            case .abstain:
                voteImageView.image = UIImage(named: "Abstain")
            }
        }
    }
}
