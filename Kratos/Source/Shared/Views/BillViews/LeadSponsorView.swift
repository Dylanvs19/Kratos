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
    @IBOutlet var repImageView: RepImageView!
    @IBOutlet var repNameLabel: UILabel!
    @IBOutlet var repStateLabel: UILabel!
    @IBOutlet weak var districtLabel: UILabel!
    @IBOutlet weak var partyLabel: UILabel!
    var sponsor: Person?
    var selector: Selector = #selector(viewTapped)
    var presentRepInfoView: ((CGRect, UIImage, CGRect, Int) -> ())?
    var distanceFromRepInfoRectFromTop: CGFloat = 21
    
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

    func configure(with sponsor: Person, presentRepInfoView: ((CGRect, UIImage, CGRect, Int) -> ())?) {
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
            partyLabel.text = party.capitalLetter
            partyLabel.textColor = UIColor.color(for: party)
        } else {
            partyLabel.text = ""
        }
        if let district = sponsor.currentDistrict {
            districtLabel.text = "District \(String(district))"
        } else {
            districtLabel.text = ""
        }
        //repImageView.setRepresentative(person: sponsor)
        if let state = sponsor.currentState {
            stateImageView.image = UIImage.imageForState(state)
        }
        self.presentRepInfoView = presentRepInfoView
        addTap()
    }

    func viewTapped() {
        guard let id = sponsor?.id,
              let image = repImageView.image else { return }
         
        var representativeRect: CGRect {
            var rect = frame
            rect.origin.y = distanceFromRepInfoRectFromTop
            rect.size.height -= distanceFromRepInfoRectFromTop
            return rect
        }
        
        var imageRect: CGRect {
            var rect = repImageView.frame
            rect.origin.y -= distanceFromRepInfoRectFromTop
            return rect
        }
        presentRepInfoView?(representativeRect, image, imageRect, id)
    }
}
