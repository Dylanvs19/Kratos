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
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.topAnchor.constraint(equalTo: topAnchor)
        self.contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        self.contentView.leftAnchor.constraint(equalTo: leftAnchor)
        self.contentView.rightAnchor.constraint(equalTo: rightAnchor)
    }
    
    func configure(with representative: DetailedRepresentative) {
        
    }
    
    func animateIn() {
        
    }
    
    func animateOut() {
        
    }
    
}
