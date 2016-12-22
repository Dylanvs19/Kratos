//
//  CommitteeTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 10/27/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class SingleCommitteeTableViewCell: UITableViewCell {

    @IBOutlet var committeeLabel: UILabel!
    @IBOutlet weak var chamberLabel: UILabel!
    @IBOutlet weak var chamberView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chamberView.backgroundColor = UIColor.kratosBlue
    }
    
    func configure(with committee: Committee) {
        let sanitizedCommitteeName = committee.name?.replacingOccurrences(of: "House Committee on ", with: "").replacingOccurrences(of: "Senate Committee on ", with: "")
        chamberLabel.transform = CGAffineTransform(rotationAngle: CGFloat(3 * M_PI / Double(2)))
        chamberView.layer.cornerRadius = 2.0
        committeeLabel.text = sanitizedCommitteeName
        if committee.commmitteeType == .senate {
            chamberLabel.text = "Sen"
        } else if committee.commmitteeType == .house {
            chamberLabel.text = "HR"
        }
        selectionStyle = .none
    }
}
