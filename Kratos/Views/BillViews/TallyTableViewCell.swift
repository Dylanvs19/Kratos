//
//  TallyTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/28/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class TallyTableViewCell: UITableViewCell {

    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var tallyQuestionLabel: UILabel!
    @IBOutlet weak var tallyDetailsLabel: UILabel!
    

    func configure(with tally: Tally) {
        
        if let votesFor = tally.yea,
            let against = tally.nay,
            let abstain = tally.abstain {
            let data = [PieChartData(with: votesFor, and: .yea),
                        PieChartData(with: abstain, and: .abstain),
                        PieChartData(with: against, and: .nay)
            ]
            pieChartView.configure(with: data, hideLabels: true)
        }
    }
}
