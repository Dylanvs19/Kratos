//
//  RepInfoBillSponsorView.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/27/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class RepInfoBillSponsorView: UIView, Loadable, UITableViewDelegate, UITableViewDataSource, PagingView, PagingDataSource, PagingTableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var scrollView: UIScrollView {
        return tableView
    }
    var loadMoreSpinnerView: LoadMoreSpinnerView? = LoadMoreSpinnerView()
    var data: [Bill] = [] {
        didSet {
            if !data.isEmpty {
                cellMap = data.singleSection()
                tableView.reloadData()
            }
        }
    }
    var cellMap = [Int: [Bill]]()
    var pager = Pager<RepInfoBillSponsorView, RepInfoBillSponsorView, RepInfoBillSponsorView>()
    var person: Person?
    var billSelected: ((Int) -> ())?
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }

    func configurePager() {
        pager.set(view: self, dataSource: self, delegate: self)
        pager.addLoadMoreSpinnerView()
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: String(describing: RepInfoBillSponsorTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: RepInfoBillSponsorTableViewCell.self))
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }
    
    func configure(with person: Person, billSelected: @escaping ((Int) -> ())) {
        self.person = person
        self.billSelected = billSelected
        configureTableView()
        configurePager()
        loadInitialData()
    }
    
    func loadInitialData() {
        guard let id = person?.id else { return }
        APIManager.getBills(for: id, success: { (bills) in
            self.pager.set(initialData: bills)
        }) { (error) in
            print(error)
        }
    }
    
    func makeRequestForResults(at page: UInt, onComplete: @escaping (([Bill]?) -> Void)) {
        guard let id = person?.id else { return }
        APIManager.getBills(for: id, success: { (bills) in
            onComplete(bills)
        }) { (error) in
            print(error)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellMap.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = cellMap[section]?.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepInfoBillSponsorTableViewCell.self), for: indexPath) as? RepInfoBillSponsorTableViewCell else { return UITableViewCell() }
        guard let bill = cellMap[indexPath.section]?[indexPath.row] else { return UITableViewCell()}
        cell.configure(with: bill)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
    }
}
