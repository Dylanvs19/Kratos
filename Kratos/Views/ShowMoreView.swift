//
//  ButtonView.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/28/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class ShowMoreView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit(with: contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit(with: contentView)
    }
}
