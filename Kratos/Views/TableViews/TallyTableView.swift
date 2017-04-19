//
//  TallyTableView.swift
//  Kratos
//
//  Created by Dylan Straughan on 3/30/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

protocol TallyTableViewDelegate: class {
    func selectedTally(tally: Tally)
}

class TallyTableView: UITableView, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    var data = [Tally]() {
        didSet {
            reloadData()
        }
    }
    weak var tallyTableViewDelegate: TallyTableViewDelegate?
    weak var billInfoViewDelegate: BillInfoViewDelegate?
    
    func configure(with data: [Tally]) {
        delegate = self
        dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard data.count  < indexPath.row else { return }
        let tally = data[indexPath.row]
        tallyTableViewDelegate?.selectedTally(tally: tally)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: self).y
        billInfoViewDelegate?.scrollViewDid(translate: translation)
    }
    
}
