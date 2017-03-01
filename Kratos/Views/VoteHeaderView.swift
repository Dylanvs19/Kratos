//
//  VoteHeaderView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class VoteHeaderView: UIView, Loadable {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var currentStatusLabel: UILabel!
    @IBOutlet var currentStatusDateLabel: UILabel!
    @IBOutlet var pieChartView: PieChartView!
    
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
        customInit()
    }
    
    func configure(with tally: Tally) {
        
        let title = tally.billShortTitle != nil ? tally.billShortTitle : tally.billOfficialTitle
        titleLabel.text = title ?? ""
        currentStatusLabel.text = tally.result?.rawValue
        
        if let date = tally.date {
            currentStatusDateLabel.text = DateFormatter.presentationDateFormatter.string(from:date)
        } else {
            currentStatusDateLabel.text = ""
        }
        if let votesFor = tally.yea,
            let against = tally.nay,
            let abstain = tally.abstain {
            let data = [PieChartData(with: votesFor, and: .yea),
                        PieChartData(with: abstain, and: .abstain),
                        PieChartData(with: against, and: .nay)
            ]
            pieChartView.configure(with: data)
        }
    }
}
