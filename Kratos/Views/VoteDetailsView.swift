//
//  VoteDetailsView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class VoteDetailsView: UIView, Loadable {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var requiredLabel: UILabel!
    @IBOutlet weak var chamberLabel: UILabel!
    @IBOutlet weak var questionTextView: UITextView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }

    func configure(with tally: Tally) {
        requiredLabel.text = tally.requires ?? ""
        chamberLabel.text = tally.chamber?.rawValue ?? ""
        questionTextView.text = tally.question ?? ""
        
    }
}
