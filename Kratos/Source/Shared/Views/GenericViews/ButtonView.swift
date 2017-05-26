//
//  ButtonView.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/28/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class ButtonView: UIView, Tappable, Loadable {
    internal var selector: Selector = #selector(viewTapped)
    @IBOutlet public var contentView: UIView!
    @IBOutlet weak var label: UILabel!
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
    
    func configure(with title: String, font: UIFont, actionBlock: (() -> Void)?) {
        label.text = title
        label.font = font
        self.actionBlock = actionBlock
        addTap()
    }
    
    func viewTapped() {
        actionBlock?()
    }
}
    