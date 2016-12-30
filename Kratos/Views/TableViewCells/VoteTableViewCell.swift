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
    
    func configureWith(_ tally: LightTally) {
        voteTitleLabel.text = tally.subject ?? ""
        if let voteType = tally.voteValue {
            switch voteType {
            case .yea:
                voteImageView.image = #imageLiteral(resourceName: "Yes")
            case .nay:
                voteImageView.image = #imageLiteral(resourceName: "No")
            case .abstain:
                voteImageView.image = #imageLiteral(resourceName: "Abstain")
            }
        }
    }
}
