//
//  SponsoredBillCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/27/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit

class SponsoredBillCell: UITableViewCell {

    static let identifier = String(describing: SponsoredBillCell.self)
    
    var titleLabel = UILabel()
    var topTermLabel = UILabel()
    var statusLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        topTermLabel.text = bill.topSubject?.name ?? ""
        statusLabel.text = bill.status?.cleanStatus ?? ""
    }
}

extension SponsoredBillCell: ViewBuilder {
    func addSubviews() {
        addSubview(titleLabel)
        addSubview(statusLabel)
        addSubview(topTermLabel)
        styleViews()
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
    
    func styleViews() {
        selectionStyle = .none
        titleLabel.style(with: [.font(.h5), .numberOfLines(3)])
        statusLabel.style(with: [.font(.body),
                                 .titleColor(.gray)])
        topTermLabel.style(with: [.font(.body),
                                  .numberOfLines(2),
                                  .titleColor(.gray)])
    }
}
