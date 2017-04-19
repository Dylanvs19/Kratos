//
//  BillSponsorsView.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/9/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit


class BillSponsorsView: UIView, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    fileprivate var tableView = UITableView()
    fileprivate var data = [Int: [Person]]()
    fileprivate var lastContentOffset: CGFloat = 0.0
    weak var billInfoViewDelegate: BillInfoViewDelegate?
    
    func configure(with bill: Bill) {
        // add SponsorsView to stackView
        setupTableView()
        
        if let leadSponsor = bill.sponsor {
            data[0] = [leadSponsor]
        }
        if let cosponsors = bill.coSponsors, cosponsors.count > 0 {
            data[1] = cosponsors
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    fileprivate func setupTableView() {
        tableView.pin(to: self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: RepTableViewCell.identifier, bundle: nil) , forCellReuseIdentifier: RepTableViewCell.identifier)
        tableView.rowHeight = 70
    }
    
    //MARK: UITableView Delegate & Datasource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return UIView()
        default:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepTableViewCell.identifier, for: indexPath) as? RepTableViewCell,
              data.count > indexPath.section,
              let section = data[indexPath.section],
              section.count > indexPath.row else { return UITableViewCell() }
        
        let person = section[indexPath.row]
        cell.configure(with: person)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // pass back information to pop RepInfoView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let translation =  offsetY - lastContentOffset
        lastContentOffset = offsetY
        billInfoViewDelegate?.scrollViewDid(translate: translation)
    }
}
