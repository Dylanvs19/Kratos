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
    
    @IBOutlet var voteTitleLabel: UILabel!
    @IBOutlet var pieChartView: PieChartView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var repVoteImageView: UIImageView!
    @IBOutlet var repImageView: UIImageView!
    @IBOutlet var representativeLabel: UILabel!
    @IBOutlet var relatedBillLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        enableSwipeBack()
        setupView()
    }
    
    func setupView() {
        voteTitleLabel.text = vote?.questionTitle
        statusLabel.text = vote?.result
        if let date = vote?.date {
            dateLabel.text = DateFormatter.presentationDateFormatter.string(from:date)
        }
        if let votesFor = vote?.votesFor,
           let against = vote?.votesAgainst,
           let abstain = vote?.votesAbstain {
            let data = [PieChartData(with: votesFor, and: .yea),
                        PieChartData(with: abstain, and: .abstain),
                        PieChartData(with: against, and: .nay)
                       ]
                pieChartView.configure(with: data)  
            if let first = representative?.firstName,
                let last = representative?.lastName {
                representativeLabel.text = first + " " + last 
            }
        }
            if let voteType = vote?.vote {
                switch voteType {
                case .yea:
                    repVoteImageView.image = UIImage(named: "Yes")
                case .nay:
                    repVoteImageView.image = UIImage(named: "No")
                case .abstain:
                    repVoteImageView.image = UIImage(named: "Abstain")
                }
            }
        if let imageURL = representative?.imageURL {
            UIImage.downloadedFrom(imageURL, onCompletion: { (image) -> (Void) in
                guard let image = image else { return }
                self.repImageView.image = image
                self.repImageView.contentMode = .scaleAspectFill
                })
        }
        relatedBillLabel.text = vote?.questionDetails
    }
    
    @IBAction func relatedBillButtonPressed(_ sender: AnyObject) {
        let vc: LegislationDetailViewController = LegislationDetailViewController.instantiate()
        if let relatedBill = vote?.relatedBill {
            vc.billId = relatedBill
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
