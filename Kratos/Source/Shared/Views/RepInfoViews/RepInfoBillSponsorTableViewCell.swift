//
//  RepInfoBillSponsorTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/27/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class RepInfoBillSponsorTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topTermLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    func configure(with bill: Bill) {
        let title = bill.title != nil ? bill.title : bill.officialTitle
        
        titleLabel.text = title ?? ""
        if let term = bill.topTerm {
            topTermLabel.text = String(term)
        }
        statusLabel.text = bill.status ?? ""
    }
    
}
