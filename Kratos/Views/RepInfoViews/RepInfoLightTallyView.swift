//
//  RepInfoTableView.swift
//  Kratos
//
//  Created by Dylan Straughan on 2/5/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

class RepInfoLightTallyView: UIView, Loadable, UITableViewDelegate, UITableViewDataSource, PagingDataSource, PagingTableViewDelegate, PagingView, VoteTableViewCellDelegate {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
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
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: String(describing: VoteTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: VoteTableViewCell.self))
        tableView.register(UINib(nibName: "VoteDateHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "VoteDateHeaderView")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VoteTableViewCell.self), for: indexPath) as? VoteTableViewCell else { return UITableViewCell() }
        guard let tally = cellMap[indexPath.section]?[indexPath.row] else { return UITableViewCell()}
        cell.configureWith(tally)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "VoteDateHeaderView") as? VoteDateHeaderView,
            let date = cellMap[section]?.first?.first?.date else { return nil }
        view.awakeFromNib()
        view.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 25)
        view.configure(with: date)
        view.contentView.backgroundColor = UIColor.darkGray
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func didSelect(lightTally: LightTally) {
        lightTallySelected?(lightTally)
    }
}
