//
//  RepVotesView.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/29/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class RepVotesView: UIView, Loadable, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showMoreButton: UIButton!
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    var votes: [Vote]? {
        didSet {
            if votes != nil {
                tableView.reloadData()
            }
        }
    }
    
    var shouldExpand = true  {
        didSet {
            tableView.isUserInteractionEnabled = !shouldExpand
        }
    }
    var actionBlock: (() -> ())?
    var cellsToShow: Int = 1
    var maxTableViewHeight: CGFloat = 400
    var rowHeight: CGFloat = 50
    var presentRepInfoView: ((LightPerson) -> ())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    func configure(with title: String, topVote: Vote? = nil, votes: [Vote], cellsToShow: Int = 1, actionBlock: (() -> ())? = nil, presentRepInfoView: ((LightPerson) -> ())?) {
        titleLabel.text = title
        self.cellsToShow = cellsToShow
        setupTableView()

            var votesArray = votes
            if let topVote = topVote {
                for (idx, vote) in votes.enumerated() {
                    if vote.person?.firstName == topVote.person?.firstName
                        && vote.person?.lastName == topVote.person?.lastName
                        && vote.person?.state == topVote.person?.state {
                        votesArray.remove(at: idx)
                    }
                }
                votesArray.insert(topVote, at: 0)
            }
            self.votes = votesArray
        
        if let actionBlock = actionBlock {
            self.actionBlock = actionBlock
        }
        
        configureCells(with: votes.count)
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isUserInteractionEnabled = false
        tableView.register(UINib(nibName: String(describing: RepVoteTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: RepVoteTableViewCell.self))
        showMoreButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / Double(2)))
    }
    
    func configureCells(with count: Int) {
        if cellsToShow >= count {
            showMoreButton.isHidden = true
            tableViewBottomConstraint.constant = 0
            maxTableViewHeight = CGFloat(count) * rowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return votes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let vote = votes?[indexPath.row],
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepVoteTableViewCell.self), for: indexPath) as? RepVoteTableViewCell else { return UITableViewCell() }
            cell.configure(with: vote)
            return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
            return rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let person = votes?[indexPath.row].person {
            presentRepInfoView?(person)
        }
    }
    
    @IBAction func showMoreButtonPressed(_ sender: Any) {
        if shouldExpand {
            self.tableViewHeightConstraint.constant = self.maxTableViewHeight
        } else {
            self.tableViewHeightConstraint.constant = CGFloat(self.cellsToShow) * self.rowHeight
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        shouldExpand = !shouldExpand
        if !shouldExpand {
            self.showMoreButton.transform = CGAffineTransform(rotationAngle: CGFloat(3 * M_PI / Double(2)))
        } else {
            self.showMoreButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / Double(2)))
        }
        actionBlock?()
    }
}
