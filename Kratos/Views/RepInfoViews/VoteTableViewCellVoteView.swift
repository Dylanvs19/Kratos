//
//  MainTableViewCellVoteView.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/1/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class VoteTableViewCellVoteView: UIView, Tappable {
    
    var questionLabel =  UILabel()
    var voteView = UIImageView()
    var statusLabel = UILabel()
    var selector: Selector = #selector(viewTapped)
    var tapped: ((LightTally) -> ())?
    var lightTally: LightTally?
    
    func configure(with lightTally: LightTally, tapped: @escaping ((LightTally) -> ())) {
        addTap()
        self.tapped = tapped
        self.lightTally = lightTally
        buildViews()
        questionLabel.text = lightTally.question
        statusLabel.text = lightTally.resultText
        
        if let voteType = lightTally.voteValue {
            switch voteType {
            case .yea:
                voteView.image = #imageLiteral(resourceName: "Yes")
            case .nay:
                voteView.image = #imageLiteral(resourceName: "No")
            case .abstain:
                voteView.image = #imageLiteral(resourceName: "Abstain")
            }
        }
        style()
    }
    
    func buildViews() {
        questionLabel.pin(to: self, for: [.top(5), .leading(5)])
        statusLabel.pin(to: self, for: [.leading(5), .bottom(-5)])
        questionLabel.bottomAnchor.constrain(equalTo: statusLabel.topAnchor, constant: -3, priority: 999)
        
        voteView.pin(to: self, for: [.trailing(-5)])
        voteView.centerYAnchor.constrain(equalTo: centerYAnchor)
        voteView.heightAnchor.constrain(equalTo: 30)
        voteView.widthAnchor.constrain(equalTo: 30)
        
        let dividerView = UIView()
        dividerView.backgroundColor = UIColor.lightGray
        dividerView.pin(to: self, for: [.bottom(-5)])
        dividerView.widthAnchor.constrain(equalTo: 1)
        dividerView.topAnchor.constrain(equalTo: topAnchor, priority: 999)
        voteView.leadingAnchor.constrain(equalTo: dividerView.trailingAnchor, constant: 3, priority: 999)
        
        dividerView.leadingAnchor.constrain(equalTo:statusLabel.trailingAnchor , constant: 3)
        dividerView.leadingAnchor.constrain(equalTo: questionLabel.trailingAnchor, constant: 3)
    }
    
    func viewTapped() {
        if let lightTally = lightTally {
            tapped?(lightTally)
        }
    }
    
    func style() {
        questionLabel.font = Font.avenirNext(size: 13).font
        questionLabel.textColor = UIColor.lightGray
        questionLabel.numberOfLines = 10
        statusLabel.font = Font.futura(size: 10).font
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        questionLabel.preferredMaxLayoutWidth = questionLabel.frame.size.width
        statusLabel.preferredMaxLayoutWidth = statusLabel.frame.size.width
        super.layoutSubviews()
    }
}
