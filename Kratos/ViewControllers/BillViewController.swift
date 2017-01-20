//
//  LegislationDetailViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//


import UIKit


class BillViewController: UIViewController, RepInfoViewPresentable {
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet weak var repInfoView: RepInfoView!
    
    var billId: Int? {
        didSet {
            KratosAnalytics.shared.updateBillAnalyicAction(with: billId)
        }
    }
    var bill: Bill?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        enableSwipeBack()
        loadData()
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let id = billId else { return }
        FirebaseAnalytics.FlowAnalytic.navigate(to: self, with: .bill, id: id).fireEvent()
    }
    
    func loadData() {
        if let billId = billId {
            APIManager.getBill(for: billId, success: { (bill) -> (Void) in
                self.configureView(with: bill)
                self.bill = bill
                }, failure: { (error) -> (Void) in
                    //showError
                    print("COULD NOT LOAD BILL FROM API, \(error)")
            })
        }
    }
    
    func configureView(with bill:Bill) {
        
        // add HeaderView to stackView
        let headerView = BillHeaderView()
        headerView.configure(with: bill)
        stackView.addArrangedSubview(headerView)
        
        if let summary = bill.summary {
            let summaryView = SummaryView()
            summaryView.configure(with: summary, title: "Bill Summary")
            stackView.addArrangedSubview(summaryView)
        }
        
        // add CommitteesView to stackView
        if let committees =  bill.committees {
            let committeesView = BillCommitteesView()
            committeesView.configure(with: committees, layoutStackView: layoutStackView, websiteButtonPressed: committeeWebsiteButtonPressed)
            stackView.addArrangedSubview(committeesView)
        }
        
        // add SponsorsView to stackView
        if let leadSponsor = bill.sponsor {
            let sponsorView = LeadSponsorView()
            sponsorView.configure(with: leadSponsor, presentRepInfoView: presentRepInfoView)
            stackView.addArrangedSubview(sponsorView)
        }
        
        if let cosponsors = bill.coSponsors, cosponsors.count > 0 {
            let lightCoSponsors = cosponsors.map({ (person) -> Vote in
                var vote = Vote()
                vote.person = person.toLightPerson()
                return vote
            })
            let view = RepVotesView()
            let title = lightCoSponsors.count == 1 ? "CoSponsor" : "CoSponsors"
            view.configure(with: title, votes: lightCoSponsors, presentRepInfoView: presentRepInfoView)
            stackView.addArrangedSubview(view)
        }
        
        let relatedBillView = ButtonView()
        relatedBillView.configure(with: "Bill Text", actionBlock: billTextButtonPressed)
        stackView.addArrangedSubview(relatedBillView)
        
        if let actions = bill.actions {
            let actionsView = BillCommitteesView()
            let sortedActions = actions.sorted { $0.date ?? Date() > $1.date ?? Date() }
            actionsView.configure(with: sortedActions, layoutStackView: layoutStackView)
            stackView.addArrangedSubview(actionsView)
        }
        
    }
    
    func billTextButtonPressed() {
        let alertVC = UIAlertController(title: "Push", message: "Push to safariVC url of bill text", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "ok", style: .destructive, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    func committeeWebsiteButtonPressed(with url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func layoutStackView() {
        self.stackView.layoutSubviews()
        self.stackView.layoutIfNeeded()
    }
}
