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
    @IBOutlet var representativeImageView: UIImageView!
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
    
    func configure(with representative:Person) {
        self.representative = representative
        guard let firstName = representative.firstName,
            let lastName = representative.lastName else { return }
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 1
        representativeImageView?.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2).cgColor
        representativeImageView?.layer.borderWidth = 2.0
        representativeImageView?.layer.cornerRadius = 2.0
        firstNameLabel.text = "\(firstName) \(lastName)"
        
        representativeLabel.text = representative.roles?.first?.representativeType?.rawValue
        
        if let imageURL = representative.imageURL {
            UIImage.downloadedFrom(imageURL, onCompletion: { (image) -> (Void) in
                guard let image = image else { return }
                self.representativeImageView.image = image
                self.representativeImageView.contentMode = .scaleAspectFill
                if let party = representative.currentParty {
                    var color = UIColor()
                    switch party {
                    case .democrat:
                        color = UIColor.kratosBlue
                    case .republican:
                        color = UIColor.kratosRed
                    case .independent:
                        color = UIColor.gray
                    }
                    self.contentView.backgroundColor = color
                } else {
                    self.contentView.backgroundColor = UIColor.gray
                }
            })
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }
    
}
