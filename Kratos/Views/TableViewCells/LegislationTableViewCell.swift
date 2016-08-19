//
//  LegislationTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class LegislationTableViewCell: UITableViewCell {

    @IBOutlet var LegislationTableViewCellContentView: UIView!
    @IBOutlet var voteLabel: UILabel!
    @IBOutlet var legislationTitleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    
    var legislation: Legislation?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        addSubview(LegislationTableViewCellContentView)
        LegislationTableViewCellContentView.translatesAutoresizingMaskIntoConstraints = false
        LegislationTableViewCellContentView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        LegislationTableViewCellContentView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        LegislationTableViewCellContentView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        LegislationTableViewCellContentView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
    }
}
