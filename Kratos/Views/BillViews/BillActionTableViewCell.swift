//
//  BillActionTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/8/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class BillActionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var nodeView: UIView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var textViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

    
    func setupView() {
        self.selectionStyle = .none
        self.nodeView.layer.borderColor = UIColor.kratosRed.cgColor
        self.nodeView.layer.borderWidth = 3.0
        self.nodeView.backgroundColor = UIColor.white
        self.nodeView.layer.cornerRadius = nodeView.frame.size.width/2
    }
}

