//
//  LegislationDetailViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//


import UIKit


class BillViewController: UIViewController {
    
    @IBOutlet var stackView: UIStackView!
    
    var billId: Int?
    var bill: Bill?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        enableSwipeBack()
        loadData { (bill) -> (Void) in
            if let bill = bill {
                self.configureView(with: bill)
                self.bill = bill
            }
        }
    }
    
    func loadData(_ onCompletion: @escaping (Bill?) -> (Void)) {
        if let billId = billId {
            APIService.loadBill(from: billId, success: { (bill) -> (Void) in
                onCompletion(bill)
                }, failure: { (error) -> (Void) in
                    onCompletion(nil)
                    print("COULD NOT LOAD BILL FROM API, \(error)")
            })
        }
    }
    
    func configureView(with bill:Bill) {
        
        // add HeaderView to stackView
        let headerView = BillHeaderView()
        headerView.configure(with: bill)
        stackView.addArrangedSubview(headerView)
        
        // add CommitteesView to stackView
        if let committees =  bill.committees {
           let committeesView = BillCommitteesView()
            committeesView.configure(with: committees)
            stackView.addArrangedSubview(committeesView)
        }
        
        // add SponsorsView to stackView
        if let leadSponsor = bill.lightSponsor {
            let sponsorView = BillSponsorsView()
            sponsorView.configure(with: leadSponsor, and: bill.coSponsors)
            stackView.addArrangedSubview(sponsorView)
        }
    }
}