//
//  LegislationDetailViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//


import UIKit


class LegislationDetailViewController: UIViewController {
    
    var billId: Int?
    var bill: Bill? {
        didSet {
            if bill != nil {
                setUpView(with: bill!)
            }
        }
    }
    
    @IBOutlet var billTitleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        setUpSwipe()
        loadData()
    }
    
    func loadData() {
        if let billId = billId {
            APIClient.loadBill(from: billId, success: { (bill) -> (Void) in
                self.bill = bill
                }, failure: { (error) -> (Void) in
                    print("COULD NOT LOAD BILL FROM API, \(error)")
            })
        }
    }
    
    func setUpView(with bill: Bill) {
        billTitleLabel.text = bill.title
    }
    
}
