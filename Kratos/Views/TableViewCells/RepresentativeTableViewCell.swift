//
//  RepresentativeTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/16/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class RepresentativeTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var repView: UIView!
    @IBOutlet var representativeImageView: UIImageView!
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var representativeLabel: UILabel!
    @IBOutlet var stateImageView: UIImageView!
    
    @IBOutlet var legislationTableView: UITableView!
    
    @IBOutlet var imageViewCenterY: NSLayoutConstraint!
    
    @IBOutlet var repViewDeselectedWidth: NSLayoutConstraint!
    @IBOutlet var repViewSelectedWidth: NSLayoutConstraint!
    
    @IBOutlet var repViewTopWithSpacing: NSLayoutConstraint!
    @IBOutlet var repViewToTop: NSLayoutConstraint!
    
    @IBOutlet var repViewToBottomWithSpacing: NSLayoutConstraint!
    @IBOutlet var repViewContractedHeight: NSLayoutConstraint!
    
    @IBOutlet var legislationTableViewToBottom: NSLayoutConstraint!
    @IBOutlet var tableViewHeightEnabled: NSLayoutConstraint!
    
    var representative: Representative? {
        didSet {
            legislationTableView.reloadData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
        legislationTableView.delegate = self
        legislationTableView.dataSource = self
        legislationTableView.registerNib(UINib(nibName: "VoteTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.VOTE_TABLEVIEWCELL_IDENTIFIER)
        legislationTableView.estimatedRowHeight = 80
        legislationTableView.rowHeight = UITableViewAutomaticDimension
        legislationTableView.setNeedsLayout()
        legislationTableView.layoutIfNeeded()
        
    }
    
    func configure(with representative:Representative) {
        self.representative = representative
        guard let firstName = representative.firstName,
            let lastName = representative.lastName else { return }
        repView.layer.shadowColor = UIColor.blackColor().CGColor
        repView.layer.shadowOffset = CGSize(width: 0, height: 5)
        repView.layer.shadowOpacity = 0.4
        repView.layer.shadowRadius = 2
        firstNameLabel.text = "\(firstName) \(lastName)"
        if let state = representative.state {
            stateImageView.image = UIImage.imageForState(state)
        }
        representativeLabel.text = representative.roleType
        
        if let imageURL = representative.imageURL {
            UIImage.downloadedFrom(imageURL, onCompletion: { (image) -> (Void) in
                guard let image = image else { return }
                self.representativeImageView.image = image
                self.representativeImageView.contentMode = .ScaleAspectFill
                if let party = representative.party {
                    var color = UIColor()
                    switch party {
                    case "Democrat":
                        color = UIColor.kratosRed
                    case "Republican":
                        color = UIColor.kratosRed
                    default:
                        color = UIColor.whiteColor()
                    }
                    self.repView.backgroundColor = color
                } else {
                    self.repView.backgroundColor = UIColor.whiteColor()
                }
                self.reloadInputViews()
            })
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        if selected {
            legislationTableView.reloadData()
            UIView.animateWithDuration(0.2, animations: {
                
                self.repViewDeselectedWidth.active = false
                self.repViewSelectedWidth.active = true
                
                self.repViewTopWithSpacing.active = false
                self.repViewToTop.active = true
                
                self.tableViewHeightEnabled.active = false
                self.legislationTableViewToBottom.active = true
                
                self.repViewToBottomWithSpacing.active = false
                self.repViewContractedHeight.active = true
                
                self.layoutIfNeeded()
            })
        } else {
            UIView.animateWithDuration(0.2, animations: {
                
                self.repViewSelectedWidth.active = false
                self.repViewDeselectedWidth.active = true
                
                self.repViewToTop.active = false
                self.repViewTopWithSpacing.active = true

                self.legislationTableViewToBottom.active = false
                self.tableViewHeightEnabled.active = true

                self.repViewContractedHeight.active = false
                self.repViewToBottomWithSpacing.active = true

                self.layoutIfNeeded()
            })
        }
    }
    
    //MARK: UITableViewDelegate & Datasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return representative?.votes?.count ?? 0
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundView = nil
        cell.backgroundColor = UIColor.clearColor()

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(Constants.VOTE_TABLEVIEWCELL_IDENTIFIER, forIndexPath: indexPath) as? VoteTableViewCell else { return UITableViewCell() }
        guard let votesArray = representative?.votes else { return UITableViewCell()}
        let vote = votesArray[indexPath.row]
        cell.vote = vote
        return cell
    }
}
