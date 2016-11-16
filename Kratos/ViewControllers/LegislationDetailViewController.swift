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
            if bill != nil {
                tableView.reloadData()
            }
        }
    }
    
    var cellMap = [(cellType: cellType, data: AnyObject)]()
    
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
        tableView.delegate = self
        tableView.dataSource = self
        loadData { (bill) -> (Void) in
            if let bill = bill {
                self.setUpView(with: bill)
                self.bill = bill
            }
        }
        
        tableView.register(UINib(nibName: "BillHeaderTableViewCell", bundle: nil) , forCellReuseIdentifier: "BillHeaderTableViewCell")
        tableView.register(UINib(nibName: "CommitteesTableViewCell", bundle: nil) , forCellReuseIdentifier: "CommitteesTableViewCell")
        tableView.tableFooterView = UIView()

    }
    
    func loadData(_ onCompletion: @escaping (Bill?) -> (Void)) {
        if let billId = billId {
            APIClient.loadBill(from: billId, success: { (bill) -> (Void) in
                onCompletion(bill)
                }, failure: { (error) -> (Void) in
                    onCompletion(nil)
                    print("COULD NOT LOAD BILL FROM API, \(error)")
            })
        }
    }
    
    func configureCellMap(with bill:Bill) {
        cellMap.append((cellType: .header, data: bill as AnyObject))
        if let committees =  bill.committees {
            cellMap.append((cellType: .committee, data: committees as AnyObject))
        }
        
        tableView.reloadData()
    }
    
    func setUpView(with bill: Bill) {
        configureCellMap(with: bill)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellMap.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = cellMap[indexPath.row]
        
        switch row.cellType {
        case .header:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BillHeaderTableViewCell", for: indexPath) as? BillHeaderTableViewCell,
            let bill = row.data as? Bill else { return UITableViewCell() }
            cell.bill = bill
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
        }
        return UITableViewCell() 
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = cellMap[indexPath.row].cellType
        switch cellType {
        case .header:
            return 400
        case .committee:
            return 400
        case .sponsor:
            return 100
        case .action:
            return 100
        case .misc:
            return 100
        }
    }
}
