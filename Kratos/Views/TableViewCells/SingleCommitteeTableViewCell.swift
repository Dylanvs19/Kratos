//
//  CommitteeTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 10/27/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class SingleCommitteeTableViewCell: UITableViewCell {

    @IBOutlet var committeeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with committee: Committee) {
        committeeLabel.text = committee.name
    }

}
