//
//  BillVotesView.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/27/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class BillVotesView: UIView, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    fileprivate var tableView = UITableView()
    fileprivate var data = [Tally]() {
        didSet {
            tableView.reloadData()
        }
    }
    fileprivate var lastContentOffset: CGFloat = 0.0
    
    func configure(with bill: Bill) {
        guard let tallies = bill.tallies else { return }
        setupTableView()
        data = tallies
    }
    
    fileprivate func setupTableView() {

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(BillTallyTableViewCell.self, forCellReuseIdentifier: BillTallyTableViewCell.identifier)
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.basicSetup()
        tableView.bounces = false
    }
    
    //MARK: UITableView Delegate & Datasource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BillTallyTableViewCell.identifier, for: indexPath) as? BillTallyTableViewCell,
            data.count > indexPath.row else { return UITableViewCell() }
        
        let tally = data[indexPath.row]
        cell.configure(with: tally)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // pass back information to pop RepInfoView
        guard data.count > indexPath.row else { return }
        let tally = data[indexPath.row]
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let translation =  offsetY - lastContentOffset
        lastContentOffset = offsetY
    }
}
