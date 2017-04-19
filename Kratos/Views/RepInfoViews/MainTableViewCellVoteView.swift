//
//  MainTableViewCellVoteView.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/1/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class MainTableViewCellVoteView: UIView, Loadable, Tappable {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var voteView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    var selector: Selector = #selector(viewTapped)
    var tapped: ((LightTally) -> ())?
    var lightTally: LightTally?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    func configure(with lightTally: LightTally, tapped: @escaping ((LightTally) -> ())) {
        addTap()
        self.tapped = tapped
        self.lightTally = lightTally
        
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
    }
    
    func viewTapped() {
        if let lightTally = lightTally {
            tapped?(lightTally)
        }
    }
}
