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
    var tapped: ((LightTally) -> Void)?
    var lightTally: LightTally?
    
    init(lightTally: LightTally, tapped: @escaping ((LightTally) -> Void)) {
        super.init(frame: .zero)
        configure(with: lightTally, tapped: tapped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with lightTally: LightTally, tapped: @escaping ((LightTally) -> Void)) {
        addTap()
        self.tapped = tapped
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
        titleLabel.pin(to: self, for: [.top(0), .leading(10)])
        resultTextLabel.pin(to: self, for: [.bottom(0), .trailing(0)])
        titleLabel.trailingAnchor.constrain(equalTo: trailingAnchor, constant: 0, priority: 999)
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
        if let lightTally = lightTally{
            tapped?(lightTally)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.preferredMaxLayoutWidth = titleLabel.frame.size.width
        resultTextLabel.preferredMaxLayoutWidth = resultTextLabel.frame.size.width
        super.layoutSubviews()
    }

}
