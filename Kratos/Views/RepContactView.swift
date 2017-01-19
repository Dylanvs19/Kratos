//
//  RepContactView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/1/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class RepContactView: UIView, Loadable {
    
    @IBOutlet var contentView: UIView!
    
    var representative: Person?
    var presentTwitter: ((Person) -> ())?
    var presentHome: ((Person) -> ())?
    
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
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
        setupView()
    }
    
    func setupView() {
        
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
    
    func configure(with representative: Person) {
        self.representative = representative
        KratosAnalytics.shared.updateRepAnalyicAction(with: representative.id)
    }
    func configureActionBlocks(presentTwitter: @escaping ((Person) -> ()), presentHome: @escaping ((Person) -> ())) {
        self.presentHome = presentHome
        self.presentTwitter = presentTwitter
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
        if let phone = representative?.roles?.first?.phone,
            let url = URL(string: "tel://\(phone)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        KratosAnalytics.ContactAnalyticType.phone.fireEvent()
    }
    @IBAction func websiteButtonPressed(_ sender: Any) {
        if let website = representative?.roles?.first?.website,
            let url = URL(string: website) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        KratosAnalytics.ContactAnalyticType.website.fireEvent()
    }
    @IBAction func homeButtonPressed(_ sender: Any) {
        guard let rep = representative else { fatalError("RepContactView without Rep") }
        presentHome?(rep)
        KratosAnalytics.ContactAnalyticType.officeAddress.fireEvent()

    }
    @IBAction func twitterButtonPressed(_ sender: Any) {
        guard let rep = representative else { fatalError("RepContactView without Rep") }
        presentTwitter?(rep)
        KratosAnalytics.ContactAnalyticType.twitter.fireEvent()
    }
}
