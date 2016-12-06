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
    
    @IBOutlet weak var yeaView: UIImageView!
    @IBOutlet weak var abstainView: UIImageView!
    @IBOutlet weak var nayView: UIImageView!
    
    var userVote: VoteType = .abstain {
        didSet {
            switch userVote {
            case .abstain:
                UIView.animate(withDuration: 0.25, animations: { 
                    self.yeaView.image = #imageLiteral(resourceName: "LightYes")
                    self.nayView.image = #imageLiteral(resourceName: "LightNo")
                    self.abstainView.image = #imageLiteral(resourceName: "Abstain")
                    self.layoutIfNeeded()
                })
            case .yea:
                UIView.animate(withDuration: 0.25, animations: {
                    self.yeaView.image = #imageLiteral(resourceName: "Yes")
                    self.nayView.image = #imageLiteral(resourceName: "LightNo")
                    self.abstainView.image = #imageLiteral(resourceName: "LightAbstain")
                    self.layoutIfNeeded()
                })
            case .nay:
                UIView.animate(withDuration: 0.25, animations: {
                    self.yeaView.image = #imageLiteral(resourceName: "LightYes")
                    self.nayView.image = #imageLiteral(resourceName: "No")
                    self.abstainView.image = #imageLiteral(resourceName: "LightAbstain")
                    self.layoutIfNeeded()
                })
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customInit()
    }
    
    func customInit() {
        Bundle.main.loadNibNamed("UserVoteView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        translatesAutoresizingMaskIntoConstraints = false
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setupGestureRecognizers()
    }
    
    func configure(with userVote: VoteType) {
        self.userVote = userVote
        // Parse out if User has voted on this && pass in
    }
    
    func setupGestureRecognizers() {
        yeaView.isUserInteractionEnabled = true
        abstainView.isUserInteractionEnabled = true
        nayView.isUserInteractionEnabled = true
        let yeaTap = UITapGestureRecognizer(target: self, action: #selector(yeaTapped))
        let abstainTap = UITapGestureRecognizer(target: self, action: #selector(abstainTapped))
        let nayTap = UITapGestureRecognizer(target: self, action: #selector(nayTapped))
        yeaView.addGestureRecognizer(yeaTap)
        abstainView.addGestureRecognizer(abstainTap)
        nayView.addGestureRecognizer(nayTap)
    }
    
    func yeaTapped() {
        userVote = .yea
    }
    
    func abstainTapped() {
        userVote = .abstain
    }
    
    func nayTapped() {
        userVote = .nay
    }
    
}
