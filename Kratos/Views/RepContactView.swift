//
//  RepContactView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/1/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class RepContactView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    var rep: DetailedRepresentative?
    
    @IBOutlet var phoneButton: UIButton!
    @IBOutlet var websiteButton: UIButton!
    @IBOutlet var homeButton: UIButton!
    @IBOutlet var twitterButton: UIButton!
    
    @IBOutlet var phoneHeightConstraint: NSLayoutConstraint!
    @IBOutlet var websiteHeightConstraint: NSLayoutConstraint!
    @IBOutlet var twitterHeightConstraint: NSLayoutConstraint!
    @IBOutlet var homeHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    func customInit() {
        Bundle.main.loadNibNamed("RepContactView", owner: self, options: nil)
        addSubview(contentView)
        translatesAutoresizingMaskIntoConstraints = false
        contentView.frame = bounds
        autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin]
        
        websiteButton.setBackgroundImage(UIImage(named: "WebsiteLogo") , for: .normal)
        twitterButton.setBackgroundImage(UIImage(named: "TwitterLogo") , for: .normal)
        phoneButton.setBackgroundImage(UIImage(named: "PhoneLogo") , for: .normal)
        homeButton.setBackgroundImage(UIImage(named: "HouseLogo") , for: .normal)
        let array = [phoneHeightConstraint, websiteHeightConstraint, twitterHeightConstraint, homeHeightConstraint]
        array.forEach { (constraint) in
            constraint?.constant = 0
        }
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }
    
    func configure(with representative: DetailedRepresentative) {
        rep = representative
    }
    
    func animateIn() {
        let array = [phoneHeightConstraint, websiteHeightConstraint, twitterHeightConstraint, homeHeightConstraint]
        var count = 0.2
        array.forEach { (constraint) in
            UIView.animate(withDuration: 0.2, delay: count, options: .curveEaseInOut, animations: { 
                constraint?.constant = 40
                self.layoutIfNeeded()
            }, completion: nil)
            count += 0.1
        }
    }
    
    func animateOut() {
        let array = [phoneHeightConstraint, websiteHeightConstraint, twitterHeightConstraint, homeHeightConstraint]
        var count = 0.0
        array.forEach { (constraint) in
            UIView.animate(withDuration: 0.1, delay: count, options: .curveEaseInOut, animations: {
                constraint?.constant = 0
                self.layoutIfNeeded()
            }, completion: nil)
            count += 0.05
        }
    }
    
    @IBAction func phoneButtonPressed(_ sender: Any) {
        if let phone = rep?.phoneNumber,
            let url = URL(string: "telprompt://\(phone)") {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func websiteButtonPressed(_ sender: Any) {
        if let website = rep?.website,
            let url = URL(string: website) {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func homeButtonPressed(_ sender: Any) {
        
    }
    @IBAction func twitterButtonPressed(_ sender: Any) {
        
    }
}