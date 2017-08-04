//
//  RepVoteView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit
import SnapKit

class RepVoteTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: RepVoteTableViewCell.self)
    let billTitleLabel = UILabel()
    let billStatus = UILabel()
    let statusImageView = UIImageView()
    let statusImageViewSize: CGFloat = 30
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        constrainViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with lightTallies: [LightTally]) {
        guard let first = lightTallies.first else { return }
        let status = (first.resultText ?? "") + " - " + "\(first.topSubject ?? 0)"
        billTitleLabel.text = first.billTitle
        billStatus.text = status
        statusImageView.image = first.voteValue?.image
    }
}

extension RepVoteTableViewCell: ViewBuilder {
    func addSubviews() {
        addSubview(billTitleLabel)
        addSubview(billStatus)
        addSubview(statusImageView)
        style()
    }
    func constrainViews() {
        billTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-40)
        }
        billStatus.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.top.equalTo(billTitleLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
        statusImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-5)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(self.statusImageViewSize)
        }
    }
    
    func style() {
        selectionStyle = .none
        billTitleLabel.style(with: [.numberOfLines(3), .font(.cellTitle)])
        billTitleLabel.style(with: .font(.cellTitle))
        billStatus.style(with: [.font(.cellSubTitle), .titleColor(.gray)])
    }
}
