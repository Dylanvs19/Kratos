//
//  BillHeaderView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class BillHeaderView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var billNumber: UILabel!
    @IBOutlet var billTitle: UILabel!
    @IBOutlet var currentStatusLabel: UILabel!
    @IBOutlet var currentStatusDateLabel: UILabel!
    
    @IBOutlet var billSummaryTextView: UITextView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func customInit() {
Bundle.main.loadNibNamed("BillHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        translatesAutoresizingMaskIntoConstraints = false
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 1
    }
    
    var bill: Bill? {
        didSet {
            if bill != nil {
                configure(with: bill!)
            }
        }
    }
    
    func configure(with bill: Bill) {
        billTitle.text = bill.title
        billNumber.text = bill.billNumber
        billSummaryTextView.text = bill.officialTitle
        currentStatusLabel.text = bill.currentStatus
        if let date = bill.currentStatusDate {
            currentStatusDateLabel.text = DateFormatter.presentationDateFormatter.string(from: date)
        }
    }
    
}
