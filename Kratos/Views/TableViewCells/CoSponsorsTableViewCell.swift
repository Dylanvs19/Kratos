//
//  SponsorsTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 10/27/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class CoSponsorsTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with coSponsor: LightRepresentative) {
        if let first = coSponsor.firstName,
            let last = coSponsor.lastName,
            let title = coSponsor.fullTitle {
            nameLabel.text = "\(title)"
        }
        
        if let state = coSponsor.state,
            let district = coSponsor.district,
            let party = coSponsor.party {
            detailLabel.text = "\(party.rawValue) \(state)\(district)"
        } else {
            detailLabel.text = ""
        }
    }
}
