//
//  RepVoteView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

protocol RepTallyTableViewCellDelegate: class {
    func lightTallySelected(lightTally: LightTally, tallySelected: Bool)
    func showMorePressed(shouldExpand: Bool, cell: RepTallyTableViewCell)
}

class RepTallyTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: RepTallyTableViewCell.self)
    var stackView = UIStackView()
    weak var delegate: RepTallyTableViewCellDelegate?

    func configure(with lightTallies: [LightTally]) {
        
        selectionStyle = .none
        if !subviews.contains { $0 is UIStackView } {
            buildViews()
        }
        
        if let first = lightTallies.first {
            stackView.addArrangedSubview(VoteTableViewCellTitleView(lightTally: first, tapped: titleTapped))
        }
        
        for (i, lightTally) in lightTallies.enumerated() {
            let view = VoteTableViewCellVoteView(lightTally: lightTally, tapped: tallyTapped)
            stackView.addArrangedSubview(view)
            view.isHidden = i > 0 ? true : false
        }
        
        if lightTallies.count > 1 {
            let view = ShowMoreView()
            stackView.addArrangedSubview(view)
            view.configure(with: "Show \(lightTallies.count - 1) Votes", alternativeTitle: "Hide Votes", actionBlock: showMorePressed)
        }
    }
    
    func buildViews() {
        stackView.pin(to: self, for: [.top(0), .bottom(0), .leading(0), .trailing(0)])
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    //MARK: Delegate Methods
    func titleTapped(lightTally: LightTally) {
        delegate?.lightTallySelected(lightTally: lightTally, tallySelected: false)
    }
    
    func tallyTapped(lightTally: LightTally) {
        delegate?.lightTallySelected(lightTally: lightTally, tallySelected: true)
    }
    
    func showMorePressed(selected: Bool) {
        delegate?.showMorePressed(shouldExpand: selected, cell: self)
    }
}
