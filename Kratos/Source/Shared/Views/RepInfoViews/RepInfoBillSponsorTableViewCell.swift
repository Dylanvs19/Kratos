//
//  RepInfoBillSponsorTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/27/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class RepInfoBillSponsorTableViewCell: UITableViewCell {

    static let identifier = String(describing: RepInfoBillSponsorTableViewCell.self)
    
    var titleLabel = UILabel()
    var topTermLabel = UILabel()
    var statusLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with bill: Bill) {
        let title = bill.title != nil ? bill.title : bill.officialTitle
        titleLabel.text = title ?? ""
        topTermLabel.text = String((bill.topTerm ?? 0))
        statusLabel.text = bill.status ?? ""
    }
}

extension RepInfoBillSponsorTableViewCell: ViewBuilder {
    func buildViews() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(5)
        }
        addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().offset(-5)
        }
        addSubview(topTermLabel)
        topTermLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.trailing.lessThanOrEqualTo(statusLabel.snp.leading).offset(3)
        }
        style()
    }
    
    func style() {
        titleLabel.font = Font.futura(size: 16).font
        statusLabel.font = Font.avenirNext(size: 14).font
        topTermLabel.font = Font.avenirNext(size: 14).font
        titleLabel.numberOfLines = 3
        topTermLabel.numberOfLines = 2
    }
}
