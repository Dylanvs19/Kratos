//
//  BillSponsorsView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class BillSponsorsView: UIView, Loadable, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var stateImageView: UIImageView!
    @IBOutlet var repImageView: UIImageView!
    @IBOutlet var repNameLabel: UILabel!
    @IBOutlet var repStateLabel: UILabel!
    
    @IBOutlet var coSponsorsLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    
    var coSponsors: [LightRepresentative]? {
        didSet {
            if coSponsors != nil {
                tableView.reloadData()
            }
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
        setupTableView()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CoSponsorsTableViewCell", bundle: nil) , forCellReuseIdentifier: "CoSponsorsTableViewCell")
        tableView.rowHeight = 30
    }
    
    func configure(with sponsor: Person, and coSponsors: [LightRepresentative]) {
        if !coSponsors.isEmpty {
            self.coSponsors = coSponsors
        } else {
            coSponsorsLabel.text = ""
        }
        if let first = sponsor.firstName,
           let last = sponsor.lastName {
            repNameLabel.text = "\(first) \(last)"
        }
        
//        if let repType = sponsor.representativeType {
//            repStateLabel.text = repType.rawValue
//        }
        
        if let repImageURL = sponsor.imageURL {
            UIImage.downloadedFrom(repImageURL, onCompletion: { (image) -> (Void) in
                guard let image = image else { return }
                self.repImageView.image = image
                self.repImageView.contentMode = .scaleAspectFill
            })
        }
        
        if let state = sponsor.currentState {
            stateImageView.image = UIImage.imageForState(state)
        }
        tableViewHeightConstraint.constant = CGFloat(coSponsors.count * 30)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coSponsors?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CoSponsorsTableViewCell", for: indexPath) as? CoSponsorsTableViewCell,
            let coSponsor = coSponsors?[indexPath.row] else { return UITableViewCell() }
        cell.configure(with: coSponsor)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
}
