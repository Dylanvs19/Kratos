//
//  ButtonView.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/28/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class ShowMoreView: UIView, Loadable {
    
    @IBOutlet var button: UIButton!
    var title: String?
    var alternativeTitle: String?
    var actionBlock: ((Bool) -> Void)?
    var selected = false
    
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

    @IBAction func buttonPressed(_ sender: Any) {
        selected = !selected
        actionBlock?(selected)
        if let alternativeTitle = alternativeTitle,
           let title = title {
            let newTitle = selected ? alternativeTitle : title
            button.setTitle(newTitle, for: .normal)
        }
    }
    
    func configure(with buttonTitle: String, alternativeTitle: String? = nil, actionBlock: @escaping ((Bool) -> Void)) {
        self.layer.cornerRadius = 4.0
        title = buttonTitle
        self.alternativeTitle = alternativeTitle
        button.setTitle(buttonTitle, for: .normal)
        self.actionBlock = actionBlock
    }
}
