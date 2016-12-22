//
//  RepVoteView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class RepVoteView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var repImageView: UIImageView!
    @IBOutlet var repVoteTypeView: UIImageView!
    
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
        Bundle.main.loadNibNamed("RepVoteView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        translatesAutoresizingMaskIntoConstraints = false
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func configure(with representative: Person, and vote: LightTally) {
        if let first = representative.firstName,
            let last = representative.lastName {
            nameLabel.text = first + " " + last
        }
        if let voteType = vote.vote {
            switch voteType {
            case .yea:
                repVoteTypeView.image = UIImage(named: "Yes")
            case .nay:
                repVoteTypeView.image = UIImage(named: "No")
            case .abstain:
                repVoteTypeView.image = UIImage(named: "Abstain")
            }
        }
        if let imageURL = representative.imageURL {
            UIImage.downloadedFrom(imageURL, onCompletion: { (image) -> (Void) in
                guard let image = image else { return }
                self.repImageView.image = image
                self.repImageView.contentMode = .scaleAspectFill
            })
        }
    }
}
