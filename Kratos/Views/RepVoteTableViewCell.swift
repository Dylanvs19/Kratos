//
//  RepVoteView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class RepVoteTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var repImageView: RepImageView!
    @IBOutlet var repVoteTypeView: UIImageView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var districtLabel: UILabel!
    @IBOutlet weak var partyLabel: UILabel!

    func configure(with vote: Vote) {
        guard let rep = vote.person else { return }
        
        selectionStyle = .none
        
        if let first = rep.firstName,
            let last = rep.lastName {
            nameLabel.text = first + " " + last
        }
        if let stateString = rep.state {
            let state = stateString.trimmingCharacters(in: .decimalDigits)
            stateLabel.text = state
        } else {
            stateLabel.text = ""
        }
        if let party = rep.party {
            partyLabel.text = party.capitalLetter()
            partyLabel.textColor = UIColor.color(for: party)
        } else {
            partyLabel.text = ""
        }
        if let district = rep.district {
            districtLabel.text = "District \(String(district))"
        } else {
            districtLabel.text = ""
        }
        if let imageURL = rep.imageURL {
            UIImage.downloadedFrom(imageURL, onCompletion: { (image) -> (Void) in
                guard let image = image else { return }
                self.repImageView.image = image
                self.repImageView.addRepImageViewBorder()
            })
        }
        if let voteValue = vote.voteValue {
            repVoteTypeView.image = UIImage.imageFor(vote: voteValue)
        }
    }
}
