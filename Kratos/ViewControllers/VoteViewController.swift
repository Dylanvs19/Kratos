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
        stackView.addArrangedSubview(headerView)
        stackView.reloadInputViews()
        
        if let _ = vote.vote {
            let view = RepVoteView()
            view.configure(with: representative, and: vote)
            stackView.addArrangedSubview(view)
        }
        
        let relatedBillView = RelatedBillView()
        relatedBillView.configure(with: relatedBillButtonPressed)
        stackView.addArrangedSubview(relatedBillView)
        
        let userVoteView = UserVoteView()
        userVoteView.configure(with: .abstain)
        stackView.addArrangedSubview(userVoteView)
    }
    
    func relatedBillButtonPressed() {
        let vc: BillViewController = BillViewController.instantiate()
        if let relatedBill = vote?.relatedBill {
            vc.billId = relatedBill
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
