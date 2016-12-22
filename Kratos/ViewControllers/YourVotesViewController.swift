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
    
    var userVotes: [UserVote]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadData() {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
