//
//  TermTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 6/25/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class TermTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: TermTableViewCell.self)
    
    let dateRangeLabel = UILabel()
    let representativeTypeLabel = UILabel()
    let districtLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with term: Term) {
        style()
        representativeTypeLabel.text = term.representativeType?.rawValue
        districtLabel.text = term.formattedDistrict
        dateRangeLabel.text = term.dateRange
        
        if let isCurrent = term.isCurrent, isCurrent {
            dateRangeLabel.textColor = .darkGray
        }
    }
}

extension TermTableViewCell: ViewBuilder {
    func buildViews() {
        contentView.addSubview(representativeTypeLabel)
        representativeTypeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
        }
        
        contentView.addSubview(districtLabel)
        districtLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        contentView.addSubview(dateRangeLabel)
        dateRangeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-5)
        }
    }
    
    func style() {
        dateRangeLabel.font = Font.avenirNextStandard.font
        districtLabel.font = Font.avenirNextStandard.font
        representativeTypeLabel.font = Font.avenirNextStandard.font
        
        dateRangeLabel.textColor = .gray
        districtLabel.textColor = .gray
        representativeTypeLabel.textColor = .gray
    }
}
