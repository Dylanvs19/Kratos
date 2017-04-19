//
//  TermView.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/5/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class TermView: UIView, Loadable {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var chamberLabel: UILabel!
    @IBOutlet weak var districtLabel: UILabel!
    @IBOutlet weak var yearRangeLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    func configure(with term: Term) {
        chamberLabel.text = term.representativeType?.rawValue
        if let district = term.district {
            districtLabel.text = " District \(district)"
        } else {
            districtLabel.text = ""
        }
        if let startDate = term.startDate,
            let endDate = term.endDate {
            yearRangeLabel.text = "\(startDate.yearValue)-\(endDate.yearValue)"
        } else {
            yearRangeLabel.text = ""
        }
    }
}

