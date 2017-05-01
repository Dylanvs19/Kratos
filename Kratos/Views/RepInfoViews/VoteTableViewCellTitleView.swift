//
//  MainTableViewCellTitleView.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/2/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class VoteTableViewCellTitleView: UIView, Tappable {
    
    var titleLabel = UILabel()
    var resultTextLabel = UILabel()
    var selector: Selector = #selector(viewTapped)
    var tappedClosure: ((LightTally) -> ())?
    var lightTally: LightTally?
    
    func configure(with lightTally: LightTally, tapped: @escaping ((LightTally) -> ())) {
        addTap()
        self.tappedClosure = tapped
        self.lightTally = lightTally
        
        buildViews()
        style()
        
        titleLabel.text = lightTally.billTitle
        if lightTally.billID == nil && lightTally.nominationID != nil {
            titleLabel.text = "Nomination"
        }
        
        if let result = lightTally.result,
           let category = lightTally.category,
               category == .passage,
               result == .billPassed || result == .failed {
            resultTextLabel.textColor = result.color
            resultTextLabel.text = lightTally.result?.presentable
            
        } else {
            resultTextLabel.backgroundColor = UIColor.clear
            resultTextLabel.text = "Pending"
        }
    }
    
    func buildViews() {
        titleLabel.pin(to: self, for: [.top(0), .trailing(0), .leading(10)])
        resultTextLabel.pin(to: self, for: [.bottom(0), .trailing(0)])
        titleLabel.bottomAnchor.constrain(equalTo: resultTextLabel.topAnchor, constant: -5)
    }
    
    func style() {
        titleLabel.numberOfLines = 8
        titleLabel.font = Font.futuraStandard.font
        titleLabel.textAlignment = .center
        
        resultTextLabel.font = Font.avenirNextMedium(size: 12).font
        resultTextLabel.textColor = UIColor.lightGray
    }
    
    func viewTapped() {
        if let lightTally = lightTally {
            tappedClosure?(lightTally)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.preferredMaxLayoutWidth = titleLabel.frame.size.width
        resultTextLabel.preferredMaxLayoutWidth = resultTextLabel.frame.size.width
        super.layoutSubviews()
    }

}
