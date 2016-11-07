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
    
    @IBOutlet var phoneButton: UIButton!
    @IBOutlet var websiteButton: UIButton!
    @IBOutlet var twitterButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    func customInit() {
        Bundle.main.loadNibNamed("RepContactView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        translatesAutoresizingMaskIntoConstraints = false
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
    }
    
    func configure(with representative: DetailedRepresentative) {
        
    }
    
    func animateIn() {
      
    }
    
    func animateOut() {
        
    }
    
}
