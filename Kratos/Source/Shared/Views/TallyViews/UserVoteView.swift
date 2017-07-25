//
//  UserVoteView.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/4/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class UserVoteView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var yeaView: UIView!
    @IBOutlet weak var nayView: UIView!
    
    fileprivate var tallyID: Int?
    fileprivate var userVote: VoteValue = .abstain {
        didSet {
            setView(with: userVote)
            if let tallyID = tallyID, userVote == .abstain {
//                APIManager.deleteUserTally(with: tallyID, success: { (success) in
//                    print("deleteUserTally for \(tallyID) successful")
//                    self.userVoteExists = false
//                }, failure: { (error) in
//                    self.presentError?(error)
//                })
            }
        }
    }
    fileprivate var shouldAnimate: Bool = false
    fileprivate var userVoteExists: Bool = false
    var presentError: ((KratosError) -> ())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupGestureRecognizers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupGestureRecognizers()
    }
    
    func configure(with tallyID: Int, presentError: @escaping ((KratosError) -> ())) {
        self.presentError = presentError
        self.shouldAnimate = true
        self.tallyID = tallyID
//        APIManager.getUserTally(with: tallyID, success: { (lightTally) in
//            if let userVote = lightTally.voteValue {
//                self.userVote = userVote
//                self.userVoteExists = true
//                //print("getUserTally for vote success \(tallyID)")
//
//            } else {
//                self.setView(with: .abstain)
//            }
//        }) { (error) in
//            self.setView(with: .abstain)
//            self.userVoteExists = false
//            //print("getUserTally for vote Failed \(tallyID)")
//        }
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
        if shouldAnimate {
            DispatchQueue.main.async(execute: { 
                UIView.animate(withDuration: 0.25, animations: {
                    self.layoutIfNeeded()
                })
            })
        }
    }
    
    func setupGestureRecognizers() {
        self.yeaView.alpha = 0.3
        self.nayView.alpha = 0.3
        
        yeaView.isUserInteractionEnabled = true
        let yeaTap = UITapGestureRecognizer(target: self, action: #selector(yeaTapped))
        yeaView.addGestureRecognizer(yeaTap)
        
        nayView.isUserInteractionEnabled = true
        let nayTap = UITapGestureRecognizer(target: self, action: #selector(nayTapped))
        nayView.addGestureRecognizer(nayTap)
    }
    
    func yeaTapped() {
        
        userVote = userVote == .yea ? .abstain : .yea
        guard let tallyID = tallyID else { return }
        if userVoteExists {
//            APIManager.updateUserTally(with: userVote, and: tallyID, success: { (success) in
//                // present Success
//                //print("update yea vote success \(tallyID)")
//            }, failure: { (error) in
//                self.presentError?(error)
//            })
        } else {
//            APIManager.createUserTally(with: userVote, and: tallyID, success: { (lightTally) in
//                // present Success
//                print("create yea vote success \(tallyID)")
//            }, failure: { (error) in
//                self.presentError?(error)
//            })
        }
    }
    
    func nayTapped() {
        
        userVote = userVote == .nay ? .abstain : .nay
        guard let tallyID = tallyID else { return }
        if userVoteExists {
//            APIManager.updateUserTally(with: userVote, and: tallyID, success: { (success) in
//                // present Success
//                print("update nay vote success \(tallyID)")
//            }, failure: { (error) in
//                self.presentError?(error)
//            })
        } else {
//            APIManager.createUserTally(with: userVote, and: tallyID, success: { (lightTally) in
//                // present Success
//                print("create nay vote success \(tallyID)")
//            }, failure: { (error) in
//                self.presentError?(error)
//            })
        }
    }
}
