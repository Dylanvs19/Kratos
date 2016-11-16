//
//  BillHeaderView.swift
//  Kratos
//
//  Created by Dylan Straughan on 10/25/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class BillHeaderTableViewCell: UITableViewCell {
    
    var bill: Bill? {
        didSet {
            if bill != nil {
                configure(with: bill!)
            }
        }
    }
    
    @IBOutlet var billTitle: UILabel!
    @IBOutlet var staticStatusLabel: UILabel!
    @IBOutlet var currentStatusLabel: UILabel!
    @IBOutlet var currentStatusDateLabel: UILabel!
    
    @IBOutlet var billSummaryTextView: UITextView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(with bill: Bill) {
        billTitle.text = bill.title
        billSummaryTextView.text = bill.officialTitle
        currentStatusLabel.text = bill.currentStatus
        if let date = bill.currentStatusDate {
            currentStatusDateLabel.text = DateFormatter.presentationDateFormatter.string(from: date)
        }
    }
}
