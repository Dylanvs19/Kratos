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
        addSubviews()
        constrainViews()
        styleViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with term: Term) {
        styleViews()
        representativeTypeLabel.text = term.representativeType?.rawValue
        districtLabel.text = term.formattedDistrict
        dateRangeLabel.text = term.dateRange
        
        if let isCurrent = term.isCurrent, isCurrent {
            dateRangeLabel.textColor = .darkGray
        }
    }
}

extension TermTableViewCell: ViewBuilder {
    func addSubviews() {
        contentView.addSubview(representativeTypeLabel)
        contentView.addSubview(districtLabel)
        contentView.addSubview(dateRangeLabel)
    }
    func constrainViews() {
        representativeTypeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
        }
        districtLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        dateRangeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-5)
        }
    }
    
    func styleViews() {
        dateRangeLabel.style(with: [.font(.body), .titleColor(.gray)])
        districtLabel.style(with: [.font(.body), .titleColor(.gray)])
        representativeTypeLabel.style(with: [.font(.body), .titleColor(.gray)])
    }
}
