//
//  LegislationDetailViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//


import UIKit
import SafariServices

class BillViewController: UIViewController, ActivityIndicatorPresentable, RepInfoViewPresentable {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet weak var tallyContainerView: UIView!
    @IBOutlet weak var tallyContainerViewLeadingConstraint: NSLayoutConstraint!
    
    
    var repInfoView: RepInfoView?
    var billID: Int? {
        didSet {
            KratosAnalytics.shared.updateBillAnalyicAction(with: billID)
        }
    }
    var bill: Bill?
    var activityIndicator: KratosActivityIndicator? = KratosActivityIndicator()
    var shadeView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        enableSwipeBack()
        loadData()
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func loadData() {
        if let billId = billID {
            presentActivityIndicator()
            APIManager.getBill(for: billId, success: {[weak self] (bill) -> (Void) in
                self?.hideActivityIndicator()
                self?.configureView(with: bill)
                self?.bill = bill
                }, failure: { (error) -> (Void) in
                    self.hideActivityIndicator()
                    self.showError(error)
                    print("COULD NOT LOAD BILL FROM API, \(error)")
            })
        }
    }
    
    public func configure(with billID: Int, tallyID: Int?) {
        self.billID = billID
        if let tallyID = tallyID {
            // should pop out tallyID
            
        }
    }
    
    private func configureView(with bill:Bill) {
        
        // add HeaderView to stackView
        let headerView = BillHeaderView()
        headerView.configure(with: bill)
        stackView.addArrangedSubview(headerView)
        
        if let summary = bill.summary {
            let summaryView = SummaryView()
            summaryView.configure(with: summary, title: "Bill Summary", showMorePresentable: true, layoutView: layoutStackViewWithAnimation)
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
            sponsorView.configure(with: leadSponsor, presentRepInfoView: configureLeadSponsorForRepInfoView)
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
            view.configure(with: title, votes: lightCoSponsors, presentRepInfoView: configureCosponsorsForRepInfoView)
            stackView.addArrangedSubview(view)
        }
        if bill.billTextURL != nil {
            let relatedBillView = ButtonView()
            relatedBillView.configure(with: "Bill Text", actionBlock: billTextButtonPressed)
            stackView.addArrangedSubview(relatedBillView)
        }
        
        if let actions = bill.actions {
            let actionsView = BillCommitteesView()
            let sortedActions = actions.sorted { $0.date ?? Date() > $1.date ?? Date() }
            actionsView.configure(with: sortedActions, layoutStackView: layoutStackView)
            stackView.addArrangedSubview(actionsView)
        }
    }
    
    private func billTextButtonPressed() {
        if let billUrl = bill?.billTextURL,
           let url = URL(string:billUrl) {
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    private func committeeWebsiteButtonPressed(with url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    //MARK: Tally VC Handling.
    private func pushTallyVC() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: { 
            self.tallyContainerViewLeadingConstraint.constant = -self.view.frame.width + 30
        }, completion: nil)
    }
    
    private func popTallyVC() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.tallyContainerViewLeadingConstraint.constant = 0
        }, completion: nil)
    }
    
    private func layoutStackView() {
        self.stackView.layoutSubviews()
        self.stackView.layoutIfNeeded()
    }
    
    private func layoutStackViewWithAnimation() {
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutSubviews()
            self.view.layoutIfNeeded()
        })
    }
    
    private func configureCosponsorsForRepInfoView(cellRectWithinView: CGRect, image: UIImage, imageRect: CGRect, personID: Int) {
        var repVotesView: RepVotesView?
        for view in stackView.subviews where type(of: view) == RepVotesView.self {
            repVotesView = view as? RepVotesView
        }
        // make sure repVotesView exists
        guard let votesView = repVotesView else { return }
        
        //votesView frame with relation to stackView(i.e. content size of scrollview - Content offset of the scrollview = currect Visibile Votes View in scrollView
        let visibileTableViewYposition = votesView.frame.origin.y - scrollView.contentOffset.y
        
        //votesViewPosition + cellRectWithinView.origin.y = top of cell.
        let topOfCell = visibileTableViewYposition + cellRectWithinView.origin.y
        let rect = CGRect(x: 10, y: topOfCell + 10, width: cellRectWithinView.size.width, height: cellRectWithinView.size.height)
        
        presentRepInfoView(with: rect, personImage: image, initialImageViewPosition: imageRect, personID: personID)
    }
    
    private func configureLeadSponsorForRepInfoView(cellRectWithinView: CGRect, image: UIImage, imageRect: CGRect, personID: Int) {
        var leadSponsorView: LeadSponsorView?
        for view in stackView.subviews where type(of: view) == LeadSponsorView.self {
            leadSponsorView = view as? LeadSponsorView
        }
               // make sure leadSponsorView exists
        guard let sponsorView = leadSponsorView else { return }
        
        //leadSponsorView frame with relation to stackView(i.e. content size of scrollview - Content offset of the scrollview = currect Visibile Votes View in scrollView
        let visibileTableViewYposition = sponsorView.frame.origin.y - scrollView.contentOffset.y
        
        //leadSponsorView + cellRectWithinView.origin.y = top of repViewToPresent.
        let topOfCell = visibileTableViewYposition + cellRectWithinView.origin.y
        let rect = CGRect(x: 10, y: topOfCell + 10, width: cellRectWithinView.size.width, height: cellRectWithinView.size.height)
        
        presentRepInfoView(with: rect, personImage: image, initialImageViewPosition: imageRect, personID: personID)
    }
}
