//
//  BillHeaderView.swift
//  Kratos
//
//  Created by Dylan Straughan on 10/25/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class BillHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet var billTitle: UILabel!
    
    @IBOutlet var staticStatusLabel: UILabel!
    @IBOutlet var currentStatusLabel: UILabel!
    @IBOutlet var currentStatusDateLabel: UILabel!
    
    @IBOutlet var billSummaryTextView: UITextView!
    
    func configure(with bill: Bill) {
        billTitle.text = bill.title
        billSummaryTextView.text = bill.officialTitle
        currentStatusLabel.text = bill.currentStatus
        if let date = bill.currentStatusDate {
            currentStatusDateLabel.text = DateFormatter.presentationDateFormatter.string(from: date)
        }
        
    }
}
