//
//  MinorActionView.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/12/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class MinorActionView: UIView, Loadable  {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var nodeView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var actionTypeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    func configure(with action: BillAction, first: Bool = false, last: Bool = false) {
        topView.isHidden = first
        bottomView.isHidden = last
        actionTypeLabel.text = action.presentableType()
        textView.text = action.text
        if let date = action.date {
            dateLabel.text = DateFormatter.shortPresentationDateFormatter.string(from: date)
        }
        self.backgroundColor = UIColor.clear
        setupNodeView()
    }
    
    func setupNodeView() {
        self.nodeView.layer.borderColor = UIColor.kratosBlue.cgColor
        self.nodeView.layer.borderWidth = 3.0
        self.nodeView.backgroundColor = UIColor.white
        self.nodeView.layer.cornerRadius = nodeView.frame.size.width/2
    }
}
