//
//  VoteViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 10/20/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//
import UIKit

class VoteViewController: UIViewController {
    
    var vote: Vote?
    var representative: DetailedRepresentative?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        enableSwipeBack()
        if let vote = vote,
            let representative = representative {
            configureView(with: vote, and: representative)
        }
        
    }

    func configureView(with vote: Vote, and representative: DetailedRepresentative) {
        // add headerView
        let headerView = VoteHeaderView()
        headerView.configure(with: vote)
        
        if let _ = vote.vote {
            let view = RepVoteView()
            view.configure(with: representative, and: vote)
        }
        
    }
    
    @IBAction func relatedBillButtonPressed(_ sender: AnyObject) {
        let vc: BillViewController = BillViewController.instantiate()
        if let relatedBill = vote?.relatedBill {
            vc.billId = relatedBill
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
