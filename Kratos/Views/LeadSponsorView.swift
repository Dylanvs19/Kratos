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
        repImageView.setRepresentative(person: sponsor, repInfoViewActionBlock: presentRepInfoView)
        if let state = sponsor.currentState {
            stateImageView.image = UIImage.imageForState(state)
        }
        self.presentRepInfoView = presentRepInfoView
        addTap()
    }

    func viewTapped() {
        if let id = sponsor?.id {
            FirebaseAnalytics.selectedContent(content: ModelViewType.leadSponsor.rawValue, id: id).fireEvent()
            presentRepInfoView?(id)
        }
    }
}
