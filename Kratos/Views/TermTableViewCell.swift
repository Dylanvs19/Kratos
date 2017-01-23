//
//  TermTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/22/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class TermTableViewCell: UITableViewCell {

    @IBOutlet weak var chamberLabel: UILabel!
    @IBOutlet weak var districtLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!
    
    func configure(with term: Term) {
        chamberLabel.text = term.representativeType?.rawValue
        if let district = term.district {
            districtLabel.text = " District \(district)"
        } else {
            districtLabel.text = ""
        }
        if let startDate = term.startDate,
           let endDate = term.endDate {
            dateRangeLabel.text = "\(startDate.yearValue)-\(endDate.yearValue)"
        } else {
            dateRangeLabel.text = ""
        }
    }
}
