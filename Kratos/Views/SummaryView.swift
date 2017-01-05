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
    var actionBlock: (() -> ())?
    
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
    
    func configure(with jurisdiction: String, title: String) {
        label.text = title
        textField.text = jurisdiction
    }
}
