//
//  VoteHeaderView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class VoteHeaderView: UIView {
    
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
    
    func customInit() {
        Bundle.main.loadNibNamed("VoteHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        translatesAutoresizingMaskIntoConstraints = false
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func configure(with vote: Vote) {
        titleLabel.text = vote.questionTitle
        currentStatusLabel.text = vote.result
        if let date = vote.date {
            currentStatusDateLabel.text = DateFormatter.presentationDateFormatter.string(from:date)
        }
        if let votesFor = vote.votesFor,
            let against = vote.votesAgainst,
            let abstain = vote.votesAbstain {
            let data = [PieChartData(with: votesFor, and: .yea),
                        PieChartData(with: abstain, and: .abstain),
                        PieChartData(with: against, and: .nay)
            ]
            pieChartView.configure(with: data)
        }
    }
}
