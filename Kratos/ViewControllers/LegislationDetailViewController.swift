//
//  LegislationDetailViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//


import UIKit


class LegislationDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var billId: Int?
    var bill: Bill? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var cellMap: [(cellType: cellType, data: AnyObject)]?
    
    enum cellType {
        case header
        case committee
        case sponsor
        case action
        case misc
    }
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        enableSwipeBack()
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
    
    func configureCellMap(with bill:Bill) {
        
    }
    
    func setUpView(with bill: Bill) {
        configureCellMap(with: bill)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellMap?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let row = cellMap?[indexPath.row] else { return UITableViewCell() }
        
        switch row.cellType {
        case .header:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BillHeaderViewTableViewCell", for: indexPath) as? BillHeaderTableViewCell,
            let bill = row.data as? Bill else { return UITableViewCell() }
            cell.configure(with: bill)
            return cell
        case .committee:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommitteesTableViewCell", for: indexPath) as? CommitteesTableViewCell,
                let committees = row.data as? [Committee] else { return UITableViewCell() }
            cell.configure(with: committees)
            return cell
        case .sponsor:
            break
        case .action:
            break
        case .misc:
            break
        default:
            return UITableViewCell()
        }
    }
    
}
