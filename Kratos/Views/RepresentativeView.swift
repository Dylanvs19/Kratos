//
//  RepresentativeView.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class RepresentativeView: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var representativeViewContentView: UIView!
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var lastNameLabel: UILabel!
    @IBOutlet var representativeLabel: UILabel!
    @IBOutlet var stateLabel: UILabel!
    @IBOutlet var legislationTableView: UITableView!
    
    var representative: Representative?
    var legislationArray: [Legislation]?
    var size: Size = .contracted
    
    enum Size {
        case expanded
        case contracted
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func configure(with representative:Representative) {
        lastNameLabel.text = representative.lastName
        firstNameLabel.text = representative.firstName
        stateLabel.text = representative.state
        representativeLabel.text = representative.roleType

        switch size {
        case .expanded:
            legislationTableView.alpha = 1
        case .contracted:
            legislationTableView.alpha = 0
        }
    }
    
    func commonInit() {
        NSBundle.mainBundle().loadNibNamed("RepresentativeView", owner: self, options: nil)
        addSubview(representativeViewContentView)
        pin(representativeViewContentView)
        legislationTableView.registerClass(LegislationTableViewCell.self, forCellReuseIdentifier: "LegislationTableViewCell")
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        representativeViewContentView.addGestureRecognizer(tapRecognizer)
    }
    
    func handleTap(sender: AnyObject) {
        size = size == .contracted ? .expanded : .contracted
    }
    
    //MARK: UITableViewDelegate & Datasource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("LegislationTableViewCell", forIndexPath: indexPath) as? LegislationTableViewCell else {
            fatalError("Why are you returning something other than a LegislationTableViewCell??")
        }
        guard let legislationArray = legislationArray else { return UITableViewCell() }
        let legislation = legislationArray[indexPath.row]
        cell.legislation = legislation
        return cell
    }
}
