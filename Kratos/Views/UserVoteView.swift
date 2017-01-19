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
    
    fileprivate var tallyID: Int?
    fileprivate var userVote: VoteValue = .abstain {
        didSet {
            if shouldAnimate {
                UIView.animate(withDuration: 0.25, animations: {
                    self.setView(with: self.userVote)
                    self.layoutIfNeeded()
                })
            }
        }
    }
    fileprivate var shouldAnimate: Bool = false
    var presentError: ((NetworkError) -> ())?
    
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
    
    func configure(with tallyID: Int) {
        
        APIManager.getUserTally(with: tallyID, success: { (lightTally) in
            if let userVote = lightTally.voteValue {
                self.setView(with: userVote)
                self.userVote = userVote
                self.shouldAnimate = true

            }
        }) { (error) in
            self.presentError?(error)
        }
    }
    
    func setView(with voteValue: VoteValue) {
        switch userVote {
        case .abstain:
            self.yeaView.alpha = 0.3
            self.nayView.alpha = 0.3
        case .yea:
            self.yeaView.alpha = 1
            self.nayView.alpha = 0.3
        case .nay:
            self.yeaView.alpha = 0.3
            self.nayView.alpha = 1
        }
    }
    
    func setupGestureRecognizers() {
        
        yeaView.isUserInteractionEnabled = true
        let yeaTap = UITapGestureRecognizer(target: self, action: #selector(yeaTapped))
        yeaView.addGestureRecognizer(yeaTap)

        nayView.isUserInteractionEnabled = true
        let nayTap = UITapGestureRecognizer(target: self, action: #selector(nayTapped))
        nayView.addGestureRecognizer(nayTap)
    }
    
    func yeaTapped() {
        if let tallyID = tallyID, userVote == .abstain {
            APIManager.createUserTally(with: .yea, and: tallyID, success: { (lightTally) in
                //debugPrint(lightTally)
            }, failure: { (error) in
                self.presentError?(error)
            })
        }
        userVote = userVote == .yea ? .abstain : .yea
    }
    
    func nayTapped() {
        if let tallyID = tallyID, userVote == .abstain {
            APIManager.createUserTally(with: .nay, and: tallyID, success: { (lightTally) in
                //debugPrint(lightTally)
            }, failure: { (error) in
                self.presentError?(error)
            })
        }
        userVote = userVote == .nay ? .abstain : .nay
    }
    
}
