//
//  BillComitteesView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class BillCommitteesView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var committeesLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var committeeArray: [Committee]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit() 
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func customInit() {
        Bundle.main.loadNibNamed("BillCommitteesView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        translatesAutoresizingMaskIntoConstraints = false
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SingleCommitteeTableViewCell", bundle: nil) , forCellReuseIdentifier: "SingleCommitteeTableViewCell")

    }
    
    func configure(with committeeArray: [Committee]) {
        tableViewHeightConstraint.constant = CGFloat(committeeArray.count * 44)
        self.committeeArray = committeeArray
        committeesLabel.text =  committeeArray.count == 1 ? "Committee" : "Committees"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return committeeArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SingleCommitteeTableViewCell", for: indexPath) as? SingleCommitteeTableViewCell,
            let committee = committeeArray?[indexPath.row] else { return UITableViewCell() }
        cell.configure(with: committee)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
