//
//  SummaryView.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/4/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class SummaryView: UIView, Loadable {
    
    @IBOutlet public var contentView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var overlayButton: UIButton!
    @IBOutlet weak var chevronView: UIImageView!
    @IBOutlet var textViewToBottomConstraint: NSLayoutConstraint!
    @IBOutlet var textViewHeightConstraint: NSLayoutConstraint!
    
    var shouldExpand: Bool = true
    var layoutView: (() -> ())?
    
    
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
    
    func configure(with text: String, title: String, showMorePresentable: Bool = false, layoutView: (() -> ())? = nil) {
        label.text = title
        textField.text = text
        if showMorePresentable {
            textViewHeightConstraint.isActive = true
            textViewToBottomConstraint.constant = 35
            self.textViewHeightConstraint.constant = 200
            chevronView.isHidden = false
            overlayButton.isHidden = false
            rotateChevronView(closed: false)
        } else {
            textViewHeightConstraint.isActive = false
            textViewToBottomConstraint.constant = 10
            chevronView.isHidden = true
            overlayButton.isHidden = true
        }
        self.layoutView = layoutView
    }
    @IBAction func overlayButtonPressed(_ sender: Any) {
        //UIView.animate(withDuration: 0.4, animations: {
            if self.shouldExpand {
                self.textField.isScrollEnabled = true
                self.textViewHeightConstraint.constant = 600
            } else {
                self.textField.isScrollEnabled = false
                self.textViewHeightConstraint.constant = 200
            }
            self.rotateChevronView(closed: self.shouldExpand)
        //}) { (success) in
            self.shouldExpand = !self.shouldExpand
            self.layoutView?()
        //}
    }
    
    func rotateChevronView(closed: Bool) {
        if closed {
            self.chevronView.transform = CGAffineTransform(rotationAngle: CGFloat(3 * M_PI / Double(2)))
        } else {
            self.chevronView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / Double(2)))
        }
    }
}
