//
//  RepVoteView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class RepTallyTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: RepTallyTableViewCell.self)
    let title = UILabel()
    let status = UIImageView()
    let dividerView = UIView()
    let stackView = UIStackView()
    let showMoreButton = UIButton()
    
    func configure(with lightTallies: Set<LightTally>) {
        
        selectionStyle = .none
        if !subviews.contains { $0 is UIStackView } {
            buildViews()
        }
        
        for (i, lightTally) in lightTallies.enumerated() {
            
            let view = VoteTableViewCellVoteView()
            view.configure(with: lightTally)
            stackView.addArrangedSubview(view)
            view.isHidden = i > 0 ? true : false
        }
    }
    
    func update() {
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.subviews.forEach { $0.removeFromSuperview() }
    }
}

extension RepTallyTableViewCell: ViewBuilder {
    func buildViews() {
        
    }
    func style() {
        
    }
}

extension RepTallyTableViewCell: RxBinder {
    func bind() {
        
    }
}
