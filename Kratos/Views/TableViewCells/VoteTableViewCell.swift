//
//  LegislationTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/31/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

protocol VoteTableViewCellDelegate {
    func didSelect(lightTally: LightTally)
}

class VoteTableViewCell: UITableViewCell {
    
    @IBOutlet var stackView: UIStackView!
    
    var delegate:VoteTableViewCellDelegate?
    
    var tallies: [LightTally]?
    var firstTally: LightTally?
    
    func configureWith(_ tallies: [LightTally]) {
        selectionStyle = .none
        
        self.stackView.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }

        if let first = tallies.first {
            let view = MainTableViewCellTitleView()
            view.configure(with: first, tapped: tallyViewTapped)
            stackView.addArrangedSubview(view)
        }
        
        var count = 1
        tallies.forEach { (lightTally) in
            let view = MainTableViewCellVoteView()
            view.configure(with: lightTally, tapped: tallyViewTapped)
            stackView.addArrangedSubview(view)
            count += 1
        }
    }
    
    func tallyViewTapped(with lightTally: LightTally) {
        delegate?.didSelect(lightTally: lightTally)
    }
}
