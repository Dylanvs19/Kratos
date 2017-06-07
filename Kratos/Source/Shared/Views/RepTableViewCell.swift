//
//  RepTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/10/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class RepTableViewCell: UITableViewCell {
    
    static let identifier = "RepTableViewCell"
    
    @IBOutlet weak var repImageView: RepImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var chamberLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var partyLabel: UILabel!
    @IBOutlet weak var stateImage: UIImageView!

    public func configure(with representative: Person) {
        //repImageView.setRepresentative(person: representative)
        nameLabel.text = "\(representative.firstName ?? "") \(representative.lastName ?? "")"
        chamberLabel.text = representative.currentChamber?.toRepresentativeType().rawValue ?? ""
        var state = ""
        if let district = representative.currentDistrict {
            state = "\(representative.currentState ?? "") - \(district)"
        } else {
            state = representative.currentState ?? ""
        }
        stateLabel.text = state
        partyLabel.text = representative.currentParty?.long ?? ""
        partyLabel.textColor = representative.currentParty?.color ?? UIColor.gray
        stateImage.image = UIImage.imageForState(representative.currentState) ?? UIImage()
        
        setup()
    }
    
    func setup() {
        selectionStyle = .none
    }
}
