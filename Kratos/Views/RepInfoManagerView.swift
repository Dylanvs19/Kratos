//
//  RepInfoManagerView.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/5/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

protocol RepInfoManagerDelegate: class {
    func tallySelected(with lightTally: LightTally)
    func billSelect(with billID: Int)
}

class RepInfoManagerView: UIView, Loadable, UIScrollViewDelegate, RepInfoManagerBarViewDelegate {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var repInfoManagerBarView: RepInfoManagerBarView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet var bottomViewHeightConstraint: NSLayoutConstraint!

    
    var selectedViewType: ViewType = .votes
    var person: Person?
    
    var bioView: RepBioView?
    var votesView: RepInfoLightTallyView?
    var billsView: RepInfoBillSponsorView?
    
    weak var delegate: RepInfoManagerDelegate?
    
    enum ViewType: String {
        case bio = "Bio"
        case votes = "Votes"
        case sponsoredBills = "Bills"
        //case fec = "FEC"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    func configure(with person: Person) {
        
        self.person = person
        
        var views = [ViewType]()
        //Configure RepBioView
        if person.biography != nil || person.terms != nil {
           
            bioView = RepBioView()
            bioView?.configure(with: person)
            bioView?.pin(to: bottomView)
            bioView?.isHidden = true
            views.append(.bio)
        }

        //Configure RepVotesView
        votesView = RepInfoLightTallyView()
        votesView?.pin(to: bottomView)
        votesView?.isHidden = false
        votesView?.configure(with: person, lightTallySelected: lightTallySelected)
        views.append(.votes)
        
        //Configure BillSponsorView
        billsView = RepInfoBillSponsorView()
        billsView?.pin(to: bottomView)
        billsView?.isHidden = true
        billsView?.configure(with: person, billSelected: billSelected)
        views.append(.sponsoredBills)
        
        repInfoManagerBarView.configure(with: views, selectedViewType: selectedViewType)
        repInfoManagerBarView.delegate = self
    }
    
    //MARK: RepInfoManagerBarViewDelegate Method
    func buttonPressed(for viewType: RepInfoManagerView.ViewType) {
        guard selectedViewType != viewType else { return }
        selectedViewType = viewType
        UIView.transition(with: bottomView, duration: 0.5, options: .transitionFlipFromRight, animations: {
            self.bottomView.subviews.forEach({ (view) in
                view.isHidden = true
            })
            switch viewType {
            case .bio:
                self.bioView?.isHidden = false
            case .votes:
                self.votesView?.isHidden = false
            case .sponsoredBills:
                self.billsView?.isHidden = false
            }
        }, completion: nil)
    }
    
    //MARK: Delegate Methods
    func lightTallySelected(lightTally: LightTally) {
        delegate?.tallySelected(with: lightTally)
    }
    
    func billSelected(billID: Int) {
        delegate?.billSelect(with: billID)
    }
}
