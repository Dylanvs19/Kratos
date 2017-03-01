//
//  RepresentativeTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/16/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

protocol RepViewDelegate: class {
    func repViewTapped(at position: Int, personID: Int, image: UIImage, initialImageViewPosition: CGRect)
}

class RepresentativeView: UIView, Loadable {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var partyView: UIView!
    @IBOutlet var representativeImageView: RepImageView!
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var representativeLabel: UILabel!
    
    var representative: Person?
    var viewPosition: Int = 0
    
    weak var repViewDelegate: RepViewDelegate?
    
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
        guard let rep = representative,
              let image = representativeImageView.image else { return }
        repViewDelegate?.repViewTapped(at: viewPosition, personID: rep.id, image: image, initialImageViewPosition: representativeImageView.frame)
    }
    
    func configure(with representative: Person) {
        self.representative = representative
        guard let firstName = representative.firstName,
            let lastName = representative.lastName else { return }
        
        representativeImageView.addRepImageViewBorder()
        firstNameLabel.text = "\(firstName) \(lastName)"
        
        representativeLabel.text = representative.currentChamber?.toRepresentativeType().rawValue
        representativeImageView.setRepresentative(person: representative)
        if let party = representative.currentParty {
            partyView.backgroundColor = party.color()
        } else {
            partyView.backgroundColor = UIColor.gray
        }
    }
}
