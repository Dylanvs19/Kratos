//
//  TrackButton.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/18/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class TrackButton: UIButton {
    
    fileprivate var bill: Bill?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        //TODO
        //Add bill to be tracked
        //API Call - add to set locally.
    }
    
    func set(bill: Bill) {
        style()
        bill.isCurrentlyTracked ? setTitle("Tracking", for: .normal) : setTitle("Track", for: .normal)
    }
    
    func style() {
        titleLabel?.font = .mediumButton
        setTitleColor(UIColor.kratosRed, for: .normal)
        layer.cornerRadius = 5.0
        layer.borderColor = UIColor.kratosRed.cgColor
        layer.borderWidth = 1.0
    }
}
