//
//  RepInfoTableView.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/5/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class RepInfoLightTallyView: UIView, UITableViewDelegate, UITableViewDataSource, PagingDataSource, PagingTableViewDelegate, PagingView, RepTallyTableViewCellDelegate {
    
    var tableView = UITableView()
    var scrollView: UIScrollView {
        return tableView
    }
    var loadMoreSpinnerView: LoadMoreSpinnerView? = LoadMoreSpinnerView()
    var tallies: [LightTally] = [] {
        didSet {
            format(tallies: tallies, with: oldValue)
        }
    }
    var data: [LightTally] = [] {
        didSet {
            format(tallies: data, with: oldValue)
        }
    }
    var cellMap = [Int: [[LightTally]]]()
    var pager = Pager<RepInfoLightTallyView, RepInfoLightTallyView, RepInfoLightTallyView>()
    var representative: Person?
    var lightTallySelected: ((LightTally) -> ())?
    
    fileprivate func format(tallies: [LightTally], with oldTallies: [LightTally]) {
        if !tallies.isEmpty {
            let hold = tallies.groupBySection(groupBy: { (datum) -> (Date) in
                // group votes by day of vote
                return datum.date?.computedDayFromDate ?? Date()
            })
            cellMap = [Int: [[LightTally]]]()
            for (idx, value) in hold {
                let dict = value.uniqueGroupBySection(groupBy: { (lightTally) -> (String) in
                    return lightTally.billOfficialTitle ?? ""
                })
                let array = Array(dict.values).map({ (tally) -> [LightTally] in
                    return Array(tally)
                })
                cellMap[idx] = array
            }
            tableView.reloadData()
        }
    }
    
    func configure(with person: Person, lightTallySelected: @escaping ((LightTally) -> ())) {
        self.representative = person
        self.lightTallySelected = lightTallySelected
        configureTableView()
        configurePager()
        loadInitialData()
    }
    
    fileprivate func loadInitialData() {
        guard let id = representative?.id else { return }
        APIManager.getTallies(for: id, nextPage: 1, success: { [weak self] (lightTallies) in
            self?.pager.set(initialData: lightTallies)
        }) { (error) in
            print(error)
        }
    }
    
    func makeRequestForResults(at page: UInt, onComplete: @escaping (([LightTally]?) -> Void)) {
        guard let id = representative?.id else { return }
        APIManager.getTallies(for: id, nextPage: Int(page), success: { (lightTallies) in
            onComplete(lightTallies)
        }) { (error) in
            print(error)
        }
    }
    
    fileprivate func configurePager() {
        pager.set(view: self, dataSource: self, delegate: self)
        pager.addLoadMoreSpinnerView()
    }
    
    fileprivate func configureTableView () {
        //Position Configuration
        tableView.pin(to: self)
        
        //Delegate Configuration
        tableView.delegate = self
        tableView.dataSource = self
        
        //Misc Configuration
        tableView.basicSetup()
        
        //Row Configuration
        tableView.register(RepTallyTableViewCell.self, forCellReuseIdentifier: RepTallyTableViewCell.identifier)
        tableView.register(UINib(nibName: "VoteDateHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "VoteDateHeaderView")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellMap.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = cellMap[section]?.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepTallyTableViewCell.identifier, for: indexPath) as? RepTallyTableViewCell,
            let tallies = cellMap[indexPath.section]?[indexPath.row] else { return UITableViewCell() }
        cell.configure(with: tallies)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "VoteDateHeaderView") as? VoteDateHeaderView,
            let date = cellMap[section]?.first?.first?.date else { return nil }
        view.awakeFromNib()
        view.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 25)
        view.configure(with: date)
        view.contentView.backgroundColor = UIColor.lightGray
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func lightTallySelected(lightTally: LightTally, tallySelected: Bool) {
        lightTallySelected?(lightTally)
    }
    
    func showMorePressed(shouldExpand selected: Bool, cell: RepTallyTableViewCell) {
        for (i, view) in cell.stackView.subviews.enumerated() {
            if i > 1 && i != cell.stackView.subviews.count - 1 {
                view.isHidden = !selected
            }
        }
        tableView.beginUpdates()
        tableView.endUpdates()
                
        if let indexPath = tableView.indexPath(for: cell) {
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}
