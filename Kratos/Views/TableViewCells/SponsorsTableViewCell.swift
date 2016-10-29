//
//  SponsorsTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 10/27/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class SponsorsTableViewCell: UITableViewCell {
    
    var cellMap: [(cellType: cellType, data: Representative?)]?
    
    enum cellType {
        case sponsor
        case coSponsor
        case coSponsorToggle
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with sponsors: [Representative]) {
        var holdMap = [(cellType: cellType, data: Representative?)]()
        if let sponsor = sponsors[0] as? DetailedRepresentative {
            holdMap.append((cellType: .sponsor, data: sponsor))
        }
        holdMap.append((cellType: .coSponsorToggle, data: nil))
        // need to continue to fill out cellMap
    }
    
}
