//
//  ActivityView.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/5/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class ActivityView: UIView, Loadable {
    
    @IBOutlet public var contentView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var label: UILabel!
    
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
    
    func configure(with title: String, activities: [String]) {
        self.title.text = title
        var labelString = ""
        for (idx, activity) in activities.enumerated() {
            if idx == activities.count - 1 {
                labelString += activity
            } else {
                labelString += "\(activity), "
            }
        }
        label.text = labelString
    }
}