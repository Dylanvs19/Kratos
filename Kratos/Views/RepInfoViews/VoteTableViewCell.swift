//
//  VoteTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/30/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit

protocol VoteTableViewCellDelegate {
    func didSelect(lightTally: LightTally)
}

class VoteTableViewCell: UITableViewCell {
    
    let stackView = UIStackView()
    let topTermLabel = UILabel()
    
    var delegate: VoteTableViewCellDelegate?
    
    var tallies: [LightTally]?
    var firstTally: LightTally?
    
    func configureWith(_ tallies: [LightTally]) {
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        
        addSubview(topTermLabel)
        topTermLabel.translatesAutoresizingMaskIntoConstraints = false
        topTermLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        topTermLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        stackView.bottomAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        
        stackView.bottomAnchor.constraint(equalTo: topTermLabel.topAnchor, constant: 5).isActive = true

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
