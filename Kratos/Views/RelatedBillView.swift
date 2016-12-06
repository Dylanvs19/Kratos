//
//  RelatedBillView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class RelatedBillView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    var actionBlock: (() -> Void)?
    
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
        Bundle.main.loadNibNamed("RelatedBillView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        translatesAutoresizingMaskIntoConstraints = false
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setupGestureRecognizer()
    }
    
    func configure(with actionBlock: @escaping (() -> Void)) {
        self.actionBlock = actionBlock
    }
    
    func setupGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    
    func handleTap() {
        actionBlock?()
    }
}
