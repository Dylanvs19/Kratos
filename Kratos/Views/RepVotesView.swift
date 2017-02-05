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
                cellMap = votes!.groupBySection(groupBy: { (vote) -> (String) in
                    return vote.person?.state ?? ""
                })
                tableView.reloadData()
            }
        }
    }
    var cellMap = [Int: [Vote]]()
    
    var shouldExpand = true  {
        didSet {
            tableView.isUserInteractionEnabled = !shouldExpand
        }
    }
    var actionBlock: (() -> ())?
    var cellsToShow: Int = 1
    var maxTableViewHeight: CGFloat = 400
    var contractedTableViewHeight: CGFloat = 50
    var rowHeight: CGFloat = 50
    var presentRepInfoView: ((Int) -> ())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    func configure(with title: String, topVote: Vote? = nil, votes: [Vote], cellsToShow: Int = 1, actionBlock: (() -> ())? = nil, presentRepInfoView: ((Int) -> ())?) {
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
        self.presentRepInfoView = presentRepInfoView
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
            contractedTableViewHeight = CGFloat(count) * rowHeight
            tableViewHeightConstraint.constant = CGFloat(count) * rowHeight
            maxTableViewHeight = CGFloat(count) * rowHeight
        }
        if (CGFloat(count) * rowHeight) < maxTableViewHeight {
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
        if let id = votes?[indexPath.row].person?.id {
            FirebaseAnalytics.selectedContent(content: ModelType.person.rawValue, id: id).fireEvent()
            presentRepInfoView?(id)
        }
    }
    
    @IBAction func showMoreButtonPressed(_ sender: Any) {
        if shouldExpand {
            FirebaseAnalytics.selectedContent(content: ModelViewType.repListView.rawValue, id: nil).fireEvent()
            tableViewHeightConstraint.constant = maxTableViewHeight
        } else {
            tableViewHeightConstraint.constant = contractedTableViewHeight
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        shouldExpand = !shouldExpand
        if !shouldExpand {
            showMoreButton.transform = CGAffineTransform(rotationAngle: CGFloat(3 * M_PI / Double(2)))
        } else {
            showMoreButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI / Double(2)))
        }
        actionBlock?()
    }
}
