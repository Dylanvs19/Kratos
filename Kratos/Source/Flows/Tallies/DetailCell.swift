//
//  DetailCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/27/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import UIKit

class DetailCell: UITableViewCell {
    // MARK: - Variables -
    // Identifier
    static let identifier = String(describing: DetailCell.self)
    
    let titleLabel = UILabel()
    let detailLabel = UILabel()
    
    // MARK: - Initializer -
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        constrainViews()
        styleViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configuration -
    func configure(with detail: (String, String)) {
        titleLabel.text = detail.0
        detailLabel.text = detail.1
        layoutIfNeeded()
    }
}

extension DetailCell: ViewBuilder {
    func addSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
    }
    func constrainViews() {
        titleLabel.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(5)
            make.top.bottom.greaterThanOrEqualToSuperview().inset(5)
            make.width.equalTo(100)
        }
        detailLabel.snp.remakeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(5).priority(999)
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
        }
    }
    
    func styleViews() {
        titleLabel.style(with: [.font(.cellTitle),
                                .numberOfLines(2),
                                .textAlignment(.left)])
        detailLabel.style(with: [.font(.tab),
                                 .titleColor(.gray),
                                 .numberOfLines(10),
                                 .textAlignment(.center)])
        selectionStyle = .none
    }
}
