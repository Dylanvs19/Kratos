//
//  RepInfoButtonView.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/18/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class RepInfoButtonView: UIView, Loadable {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var button: UIButton!
    var buttonPressed: ((RepInfoManagerView.ViewType) -> ())?
    var viewType: RepInfoManagerView.ViewType = .bio
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        buttonPressed?(viewType)
    }
    
    func setButton(with viewType: RepInfoManagerView.ViewType, buttonPress: @escaping ((RepInfoManagerView.ViewType) -> ())) {
        button.setTitle(viewType.rawValue, for: .normal)
        buttonPressed = buttonPress
        self.viewType = viewType
    }
}
