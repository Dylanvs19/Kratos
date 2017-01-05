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
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    func configure(with topVote: Vote? = nil, votes: [Vote], actionBlock: (() -> ())? = nil ) {
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
    }
    
//    func configure<T>(with reps: [T], actionBlock: (() -> ())? = nil ) {
//        setupTableView()
//        self.votes = votesArray
//        if let actionBlock = actionBlock {
//            self.actionBlock = actionBlock
//        }
//    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isUserInteractionEnabled = false
        tableView.register(UINib(nibName: String(describing: RepVoteTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: RepVoteTableViewCell.self))
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    @IBAction func showMoreButtonPressed(_ sender: Any) {
        if shouldExpand {
            tableViewHeightConstraint.constant = 400
            showMoreButton.setTitle("Show Less Representatives", for: .normal)
        } else {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            tableViewHeightConstraint.constant = 50
            showMoreButton.setTitle("Show More Representatives", for: .normal)
        }
        shouldExpand = !shouldExpand
        actionBlock?()
    }
}
