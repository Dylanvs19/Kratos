//
//  RepresentativeTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/16/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class RepresentativeTableViewCell: UITableViewCell {
    
    @IBOutlet var repView: UIView!
    @IBOutlet var representativeImageView: UIImageView!
    @IBOutlet var dividerView: UIView!
    @IBOutlet var legislationLabel: UILabel!
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var representativeLabel: UILabel!
    @IBOutlet var stateLabel: UILabel!
    @IBOutlet var legislationTableView: UITableView!
    
    @IBOutlet var imageViewContractedHeight: NSLayoutConstraint!
    @IBOutlet var imageViewExpandedHeight: NSLayoutConstraint!
    @IBOutlet var imageViewCenterY: NSLayoutConstraint!
    @IBOutlet var imageViewToTop: NSLayoutConstraint!
    
    var representative: Representative?
    var legislationArray: [Legislation]?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        legislationTableView.registerClass(LegislationTableViewCell.self, forCellReuseIdentifier: "LegislationTableViewCell")
    }
    
    func commonInit() {
        
    }
    
    func configure(with representative:Representative) {
        guard let firstName = representative.firstName,
            let lastName = representative.lastName else { return }
        repView.layer.shadowColor = UIColor.blackColor().CGColor
        repView.layer.shadowOffset = CGSize(width: 0, height: 5)
        repView.layer.shadowOpacity = 0.4
        repView.layer.shadowRadius = 2
        firstNameLabel.text = "\(firstName) \(lastName)"
        stateLabel.text = representative.state
        representativeLabel.text = representative.roleType
        
        if let imageURL = representative.imageURL {
            UIImage.downloadedFrom(imageURL, onCompletion: { (image) -> (Void) in
                guard let image = image else { return }
                self.representativeImageView.image = image
                self.representativeImageView.contentMode = .ScaleAspectFill
                self.representativeImageView.layer.cornerRadius = 3.0
                self.representativeImageView.layer.borderWidth = 2.0
                if let party = representative.party {
                    var color = UIColor()
                    switch party {
                    case "Democrat":
                        color = UIColor.borderBlue
                    case "Republican":
                        color = UIColor.borderRed
                    default:
                        color = UIColor.whiteColor()
                    }
                    self.representativeImageView.layer.borderColor = color.CGColor
                } else {
                    self.representativeImageView.layer.borderColor = UIColor.whiteColor().CGColor
                }
                self.reloadInputViews()
            })
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        if selected {
            UIView.animateWithDuration(1, animations: {
                self.legislationTableView.alpha = 1
                self.dividerView.alpha = 1
                self.legislationLabel.alpha = 1
                self.imageViewContractedHeight.active = false
                self.imageViewCenterY.active = false
                self.imageViewToTop.active = true
                self.imageViewExpandedHeight.active = true
                self.imageViewToTop.active = true
                self.layoutIfNeeded()
            })
        } else {
            UIView.animateWithDuration(1, animations: {
                self.legislationTableView.alpha = 0
                self.dividerView.alpha = 0
                self.legislationLabel.alpha = 0
                self.imageViewToTop.active = false
                self.imageViewExpandedHeight.active = false
                self.imageViewToTop.active = false
                self.imageViewContractedHeight.active = true
                self.imageViewCenterY.active = true
                self.layoutIfNeeded()
            })
        }
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
