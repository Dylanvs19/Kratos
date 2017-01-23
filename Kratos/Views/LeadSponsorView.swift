//
//  BillSponsorsView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class LeadSponsorView: UIView, Loadable, Tappable {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var stateImageView: UIImageView!
    @IBOutlet var repImageView: UIImageView!
    @IBOutlet var repNameLabel: UILabel!
    @IBOutlet var repStateLabel: UILabel!
    @IBOutlet weak var districtLabel: UILabel!
    @IBOutlet weak var partyLabel: UILabel!
    var sponsor: Person?
    var selector: Selector = #selector(viewTapped)
    var presentRepInfoView: ((Int) -> ())?
    
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

    func configure(with sponsor: Person, presentRepInfoView: @escaping ((Int) -> ())) {
        self.sponsor = sponsor
        if let first = sponsor.firstName,
            let last = sponsor.lastName {
            repNameLabel.text = first + " " + last
        }
        if let stateString = sponsor.currentState {
            let state = stateString.trimmingCharacters(in: .decimalDigits)
            repStateLabel.text = state
        } else {
            repStateLabel.text = ""
        }
        if let party = sponsor.currentParty {
            partyLabel.text = party.capitalLetter()
            partyLabel.textColor = UIColor.color(for: party)
        } else {
            partyLabel.text = ""
        }
        if let district = sponsor.currentDistrict {
            districtLabel.text = "District \(String(district))"
        } else {
            districtLabel.text = ""
        }
        if let imageURL = sponsor.imageURL {
            UIImage.downloadedFrom(imageURL, onCompletion: { (image) -> (Void) in
                guard let image = image else { return }
                self.repImageView.image = image
                self.repImageView.addRepImageViewBorder()
            })
        }
        if let state = sponsor.currentState {
            stateImageView.image = UIImage.imageForState(state)
        }
        addTap()
        self.presentRepInfoView = presentRepInfoView
    }

    func viewTapped() {
        if let id = sponsor?.id {
            presentRepInfoView?(id)
        }
    }
}
