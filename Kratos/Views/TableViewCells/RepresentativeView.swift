//
//  RepresentativeTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/16/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

protocol RepViewDelegate {
    func repViewTapped(is selected: Bool, at position: Int)
}

class RepresentativeView: UIView, Loadable {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var partyView: UIView!
    @IBOutlet var representativeImageView: RepImageView!
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var representativeLabel: UILabel!
    
    var representative: Person?
    var selected = false
    var viewPosition: Int = 0
    
    var repViewDelegate: RepViewDelegate?
    
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
        setGestureRecognizer()
    }
    
    func setGestureRecognizer() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGR)
    }
    
    func handleTap() {
        selected = !selected
        repViewDelegate?.repViewTapped(is: selected, at: viewPosition)
    }
    
    func configure(with representative:Person, repInfoViewActionBlock: @escaping ((Int) -> ())) {
        self.representative = representative
        guard let firstName = representative.firstName,
            let lastName = representative.lastName else { return }
        
        //layer.cornerRadius = 0
        //layer.borderWidth = 1
        self.backgroundColor = UIColor.clear
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        self.layer.insertSublayer(gradient, at: 0)
        
        representativeImageView.addRepImageViewBorder()
        firstNameLabel.text = "\(firstName) \(lastName)"
        
        representativeLabel.text = representative.currentChamber?.toRepresentativeType().rawValue
        representativeImageView.setRepresentative(person: representative, repInfoViewActionBlock: repInfoViewActionBlock)
        if let party = representative.currentParty {
            partyView.backgroundColor = party.color()
        } else {
            partyView.backgroundColor = UIColor.gray
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }
}
