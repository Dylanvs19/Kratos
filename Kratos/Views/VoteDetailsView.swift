//
//  VoteDetailsView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class VoteDetailsView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var voteDescriptionLabel: UILabel!
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
    }
    
    func customInit() {
        Bundle.main.loadNibNamed("VoteDetailsView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        translatesAutoresizingMaskIntoConstraints = false
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func configure(with vote: Vote) {
        
    }
}
