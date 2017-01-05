//
//  BillSponsorsView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class LeadSponsorView: UIView, Loadable {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var stateImageView: UIImageView!
    @IBOutlet var repImageView: UIImageView!
    @IBOutlet var repNameLabel: UILabel!
    @IBOutlet var repStateLabel: UILabel!
    
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
    }

    func configure(with sponsor: Person) {
        if let first = sponsor.firstName,
           let last = sponsor.lastName {
            repNameLabel.text = "\(first) \(last)"
        }
        
        if let repType = sponsor.roles?.first?.representativeType {
            repStateLabel.text = repType.rawValue
        }
        
        if let repImageURL = sponsor.imageURL {
            UIImage.downloadedFrom(repImageURL, onCompletion: { (image) -> (Void) in
                guard let image = image else { return }
                self.repImageView.image = image
                self.repImageView.contentMode = .scaleAspectFill
            })
        }
        
        if let state = sponsor.currentState {
            stateImageView.image = UIImage.imageForState(state)
        }
    }

}
