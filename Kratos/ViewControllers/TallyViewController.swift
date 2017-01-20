//
//  VoteViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 10/20/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//
import UIKit

class TallyViewController: UIViewController, UIScrollViewDelegate, RepInfoViewPresentable {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    var lightTally: LightTally? {
        didSet {
            KratosAnalytics.shared.updateTallyAnalyicAction(with: lightTally?.id)
            loadData()
            
        }
    }
    var tally: Tally? {
        didSet {
            if let tally = tally,
                let rep = representative {
                configureView(with: tally, and: rep)
            }
        }
    }
    var representative: Person?
    @IBOutlet weak var repInfoView: RepInfoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        navigationController?.isNavigationBarHidden = true
        enableSwipeBack()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let id = lightTally?.id else { return }
        FirebaseAnalytics.FlowAnalytic.navigate(to: self, with: .tally, id: id).fireEvent()
    }
    
    func loadData() {
        if let lightTally = lightTally {
            APIManager.getTally(for: lightTally, success: { (tally) in
                self.tally = tally
            }, failure: { (error) in
                //Handle error
            })
        }
    }

    func configureView(with tally: Tally?, and representative: Person?) {
        guard let tally = tally else {
            // showError 
            return
        }
        // add headerView
        let headerView = VoteHeaderView()
        headerView.configure(with: tally)
        stackView.addArrangedSubview(headerView)
        stackView.reloadInputViews()
        
        if let tallyID = tally.id {
            let userVoteView = UserVoteView()
            userVoteView.configure(with: tallyID)
            stackView.addArrangedSubview(userVoteView)
        }
        
        if let _ = tally.billId  {
            let relatedBillView = ButtonView()
            relatedBillView.configure(with: "Bill Information", actionBlock: relatedBillButtonPressed)
            stackView.addArrangedSubview(relatedBillView)
        }
        
        let voteDetailsView = VoteDetailsView()
        voteDetailsView.configure(with: tally)
        stackView.addArrangedSubview(voteDetailsView)

        configureRepVotesTableView()
        
        
    }
    
    func configureRepVotesTableView() {
        let repVotesView = RepVotesView()
    
        var currentRepVote = Vote()
        if let lightTally = lightTally,
            let rep = representative {
            currentRepVote = convert(rep: rep, lightTally: lightTally)
        }
        
        if let votes = tally?.votes {
            repVotesView.configure(with: "Representatives", topVote: currentRepVote, votes: votes, cellsToShow: 1, actionBlock: layoutStackView, presentRepInfoView: presentRepInfoView)
        }
        stackView.addArrangedSubview(repVotesView)
    }
    
    func layoutStackView() {
        UIView.animate(withDuration: 0.4, animations: {
            self.stackView.layoutSubviews()
            self.stackView.layoutIfNeeded()
        }) { (completion) in
            let contentSize = self.scrollView.contentSize
            self.scrollView.scrollRectToVisible(CGRect(x: 0, y: contentSize.height - 1, width: contentSize.width, height: 1.0), animated: true)
        }
    }
    
    func relatedBillButtonPressed() {
        let vc: BillViewController = BillViewController.instantiate()
        if let relatedBill = tally?.billId {
            vc.billId = relatedBill
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: Helper Functions
    func convert(rep: Person, lightTally: LightTally) -> Vote {
        var vote = Vote()
        var person = LightPerson()
        vote.voteValue = lightTally.voteValue
        person.firstName = rep.firstName
        person.lastName = rep.lastName
        person.imageURL = rep.imageURL
        person.district = rep.roles?.first?.district
        person.party = rep.currentParty
        person.state = rep.roles?.first?.state
        person.representativeType = rep.roles?.first?.representativeType
        vote.person = person
        return vote
    }
}
