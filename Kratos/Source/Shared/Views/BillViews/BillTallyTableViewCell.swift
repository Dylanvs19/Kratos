//
//  TallyTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/28/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class BillTallyTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: BillTallyTableViewCell.self)

    var tallyQuestionLabel = UILabel()
    var tallyDetailsLabel = UILabel()
    var stackView = UIStackView()
    var pieChartView = PieChartView()
    
    func configure(with tally: Tally) {
        buildViews()
        tallyQuestionLabel.text = tally.question
        tallyDetailsLabel.text = tally.result?.presentable
        pieChartView.configure(with: tally, hideLabels: true)
        style()
    }
    
    func buildViews() {
        selectionStyle = .none
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally

        
        
        let headerView = UIView()
        
        pieChartView.trailingAnchor.constrain(equalTo: headerView.trailingAnchor, constant: -5, priority: 999)
        pieChartView.widthAnchor.constrain(equalTo: 70)
        pieChartView.heightAnchor.constrain(equalTo: 70)
        
        
        tallyQuestionLabel.trailingAnchor.constrain(equalTo: pieChartView.leadingAnchor, constant: -5)

        
        tallyDetailsLabel.bottomAnchor.constrain(equalTo: headerView.bottomAnchor, constant: -5, priority: 999)
        stackView.addArrangedSubview(headerView)
    }
    
    func style() {
        tallyQuestionLabel.style(with: [.font(.cellTitle), .numberOfLines(10)])
        tallyDetailsLabel.style(with: [.font(.cellSubTitle),
                                       .numberOfLines(10),
                                       .titleColor(.lightGray)])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tallyQuestionLabel.preferredMaxLayoutWidth = tallyQuestionLabel.frame.size.width
        tallyDetailsLabel.preferredMaxLayoutWidth = tallyDetailsLabel.frame.size.width
        super.layoutSubviews()
    }
}
