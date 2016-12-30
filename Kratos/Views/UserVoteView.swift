//
//  UserVoteView.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/4/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class UserVoteView: UIView, Loadable {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var yeaView: UIView!
    @IBOutlet weak var nayView: UIView!
    
    var userVote: VoteValue = .abstain {
        didSet {
            switch userVote {
            case .abstain:
                UIView.animate(withDuration: 0.25, animations: { 
                    self.yeaView.alpha = 0.5
                    self.nayView.alpha = 0.5
                    self.layoutIfNeeded()
                })
            case .yea:
                UIView.animate(withDuration: 0.25, animations: {
                    self.yeaView.alpha = 1
                    self.nayView.alpha = 0.5
                    self.layoutIfNeeded()
                })
            case .nay:
                UIView.animate(withDuration: 0.25, animations: {
                    self.yeaView.alpha = 0.5
                    self.nayView.alpha = 1
                    self.layoutIfNeeded()
                })
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
        setupGestureRecognizers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
        setupGestureRecognizers()
    }
    
    func configure(with userVote: VoteValue) {
        self.userVote = userVote
        // Parse out if User has voted on this && pass in
    }
    
    func setupGestureRecognizers() {
        yeaView.isUserInteractionEnabled = true
        nayView.isUserInteractionEnabled = true
        let yeaTap = UITapGestureRecognizer(target: self, action: #selector(yeaTapped))
        let nayTap = UITapGestureRecognizer(target: self, action: #selector(nayTapped))
        yeaView.addGestureRecognizer(yeaTap)
        nayView.addGestureRecognizer(nayTap)
    }
    
    func yeaTapped() {
        userVote = userVote == .yea ? .abstain : .yea
    }
    
    func nayTapped() {
        userVote = userVote == .nay ? .abstain : .nay
    }
    
}
