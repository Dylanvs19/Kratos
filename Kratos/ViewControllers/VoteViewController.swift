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
    var representativeName: String?
    
    @IBOutlet var voteTitleLabel: UILabel!
    @IBOutlet var totalForLabel: UILabel!
    @IBOutlet var totalAgainstLabel: UILabel!
    @IBOutlet var totalAbstainLabel: UILabel!
    
    @IBOutlet var representativeLabel: UILabel!
    @IBOutlet var repVoteLabel: UILabel!
    @IBOutlet var relatedBillLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        setUpSwipe()
        setupView()
    }
    
    func setupView() {
        voteTitleLabel.text = vote?.questionTitle
        if let votesFor = vote?.votesFor,
           let against = vote?.votesAgainst,
           let abstain = vote?.votesAbstain {
            totalForLabel.text = String(votesFor)
            totalAgainstLabel.text = String(against)
            totalAbstainLabel.text = String(abstain)
            representativeLabel.text = representativeName
        }
        
        repVoteLabel.text = vote?.vote?.rawValue
    }
    
    @IBAction func relatedBillButtonPressed(_ sender: AnyObject) {
        let vc: LegislationDetailViewController = LegislationDetailViewController.instantiate()
        if let relatedBill = vote?.relatedBill {
            vc.billId = relatedBill
            vc.loadViewIfNeeded()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
