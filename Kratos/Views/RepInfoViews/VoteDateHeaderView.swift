//
//  VoteDateHeaderView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/8/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class VoteDateHeaderView: UITableViewHeaderFooterView {

    @IBOutlet var dateLabel: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with date: Date) {
        dateLabel.text = DateFormatter.presentationDateFormatter.string(from: date)
    }
}
