//
//  YourVotesViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/8/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class YourVotesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var userVotes: [LightTally]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        loadData()
        setupTableView()
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: String(describing: YourVoteTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: YourVoteTableViewCell.self))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 75
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func loadData() {
        APIManager.getUserVotingRecord(success: { (tallies) in
            self.userVotes = tallies
        }) { (error) in
            self.showError(error: error)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userVotes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vote = userVotes?[indexPath.row],
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: YourVoteTableViewCell.self), for: indexPath) as? YourVoteTableViewCell else { return UITableViewCell() }
        cell.configure(with: vote)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let lightTally = userVotes?[indexPath.row] else { return }
        let vc: TallyViewController = TallyViewController.instantiate()
        vc.lightTally = lightTally
        FirebaseAnalytics.selectedUserVote(userVoteId: lightTally.id).fireEvent()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
