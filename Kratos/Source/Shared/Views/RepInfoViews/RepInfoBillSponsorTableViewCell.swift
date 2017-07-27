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
        addSubviews()
        constrainViews()
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
    func addSubviews() {
        addSubview(titleLabel)
        addSubview(statusLabel)
        addSubview(topTermLabel)
        style()
    }
    
    func constrainViews() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(5)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().offset(-5)
        }
        
        topTermLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.trailing.lessThanOrEqualTo(statusLabel.snp.leading).offset(3)
        }
    }
    
    func style() {
        selectionStyle = .none
        titleLabel.style(with: [.font(.title), .numberOfLines(3)])
        statusLabel.style(with: .font(.body))
        topTermLabel.style(with: [.font(.body), .numberOfLines(2)])
    }
}
