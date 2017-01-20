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
    
    var userVotes: [LightTally]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: String(describing: YourVoteTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: YourVoteTableViewCell.self)) }
    
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
