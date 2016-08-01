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
    
    var representative: Representative? {
        didSet {
            
        }
    }
    var legislationArray: [Legislation]? {
        didSet {
            
        }
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
    
    func commonInit() {
        
        self.legislationTableView.registerClass(LegislationTableViewCell.self, forCellReuseIdentifier: "LegislationTableViewCell")
        pin(representativeViewContentView)
    }
    
    //MARK: UITableViewDelegate & Datasource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("LegislationTableViewCell", forIndexPath: indexPath) as? LegislationTableViewCell else {
            fatalError()
        }
        
        guard let legislationArray = legislationArray else { return UITableViewCell() }
        
        let legislation = legislationArray[indexPath.row]
        cell.legislation = legislation
        
        return cell
    }
    

}
