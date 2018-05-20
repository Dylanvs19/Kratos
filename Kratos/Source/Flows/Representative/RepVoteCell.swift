//
//  RepVoteView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit
import SnapKit

class RepVoteCell: UITableViewCell {
    
    static let identifier = String(describing: RepVoteCell.self)
    let billTitleLabel = UILabel()
    let billSubjectLabel = UILabel()
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
        var title: String? = nil
        if let billTitle = first.billTitle {
            title = billTitle
        } else if let question = first.question {
            title = question
        }
        billTitleLabel.text = title
        billStatus.text = first.resultText ?? ""
        billSubjectLabel.text = first.topSubject?.name ?? ""
        statusImageView.image = first.voteValue?.image
    }
}

extension RepVoteCell: ViewBuilder {
    func addSubviews() {
        addSubview(billTitleLabel)
        addSubview(billSubjectLabel)
        addSubview(billStatus)
        addSubview(statusImageView)
        styleViews()
    }
    func constrainViews() {
        billTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(Dimension.smallMargin)
            make.trailing.equalToSuperview().inset(statusImageViewSize + Dimension.smallMargin)
        }
        billSubjectLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Dimension.smallMargin)
            make.top.equalTo(billTitleLabel.snp.bottom).offset(Dimension.smallMargin)
            make.trailing.equalToSuperview().inset(statusImageViewSize + Dimension.smallMargin)
        }
        billStatus.snp.makeConstraints { make in
            make.top.equalTo(billSubjectLabel.snp.bottom).offset(Dimension.smallMargin)
            make.leading.bottom.equalToSuperview().inset(Dimension.smallMargin)
            make.trailing.equalToSuperview().inset(statusImageViewSize + Dimension.smallMargin)
        }
        statusImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Dimension.smallMargin)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(statusImageViewSize)
        }
    }
    
    func styleViews() {
        selectionStyle = .none
        billTitleLabel.style(with: [.numberOfLines(4),
                                    .font(.h5)])
        billTitleLabel.style(with: .font(.h5))
        billStatus.style(with: [.font(.body),
                                .titleColor(.gray)])
        billSubjectLabel.style(with: [.font(.body),
                                      .titleColor(.gray),
                                      .numberOfLines(3)])
    }
}
