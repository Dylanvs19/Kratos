//
//  VoteViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 10/20/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//
import UIKit

class VoteViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    
    var lightTally: LightTally? {
        didSet {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        enableSwipeBack()
        if let tally = tally,
            let representative = representative {
            configureView(with: tally, and: representative)
        }
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

    func configureView(with vote: Tally, and representative: Person) {
        // add headerView
        let headerView = VoteHeaderView()
        if let tally = tally {
            headerView.configure(with: tally)
            stackView.addArrangedSubview(headerView)
            stackView.reloadInputViews()
        }
        let userVoteView = UserVoteView()
        userVoteView.configure(with: .abstain)
        stackView.addArrangedSubview(userVoteView)
        
        if let lightTally = lightTally,
           let _ = lightTally.vote {
            let view = RepVoteView()
            view.configure(with: representative, and: lightTally)
            stackView.addArrangedSubview(view)
        }
        if let _ = tally?.billID  {
            let relatedBillView = ButtonView()
            relatedBillView.configure(with: "Bill Information", actionBlock: relatedBillButtonPressed)
            stackView.addArrangedSubview(relatedBillView)
        }
    }
    
    func relatedBillButtonPressed() {
        let vc: BillViewController = BillViewController.instantiate()
        if let relatedBill = tally?.billID {
            vc.billId = relatedBill
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
