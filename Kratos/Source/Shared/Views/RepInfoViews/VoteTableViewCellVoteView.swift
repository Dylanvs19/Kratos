//
//  MainTableViewCellVoteView.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/1/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit
import SnapKit

class VoteTableViewCellVoteView: UIView {
    
    var questionLabel =  UILabel()
    var voteResultImageView = UIImageView()
    var statusLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildViews()
        style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with vote: LightTally) {
        questionLabel.text = vote.question
        statusLabel.text = vote.resultText
        voteResultImageView.image = vote.voteValue?.image
    }
}

extension VoteTableViewCellVoteView: ViewBuilder {
    func buildViews() {
        addSubview(voteResultImageView)
        voteResultImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.trailing.bottom.equalToSuperview().offset(-5)
            make.height.equalTo(25)
            make.width.equalTo(self.snp.height)
        }
        addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
        addSubview(questionLabel)
        questionLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(5)
            make.trailing.equalTo(voteResultImageView.snp.leading).offset(3)
            make.bottom.equalTo(statusLabel.snp.top).offset(3)
        }
    }
    
    func style() {
        questionLabel.font = Font.avenirNext(size: 13).font
        questionLabel.textColor = UIColor.lightGray
        questionLabel.numberOfLines = 10
        statusLabel.font = Font.futura(size: 10).font
    }
}
