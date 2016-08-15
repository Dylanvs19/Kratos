//
//  RepresentativeView.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

protocol RepViewDelegate {
    func panGestureYPosition(float: CGFloat, for position: RepresentativeView.Position)
    func shouldExpand(bool: Bool, for position: RepresentativeView.Position)
}

class RepresentativeView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var representativeImageView: UIImageView!
    @IBOutlet var dividerView: UIView!
    @IBOutlet var legislationLabel: UILabel!
    @IBOutlet var representativeViewContentView: UIView!
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var representativeLabel: UILabel!
    @IBOutlet var stateLabel: UILabel!
    @IBOutlet var legislationTableView: UITableView!
    
    @IBOutlet var nameLabelLeadingToImageView: NSLayoutConstraint!
    @IBOutlet var imageViewContractedHeight: NSLayoutConstraint!
    @IBOutlet var imageViewExpandedHeight: NSLayoutConstraint!
    @IBOutlet var imageViewCenterY: NSLayoutConstraint!
    @IBOutlet var imageViewToTop: NSLayoutConstraint!
    
    var repViewDelegate: RepViewDelegate?
    var representative: Representative?
    var legislationArray: [Legislation]?
    var size: Size = .contracted
    var position: Position = .top
    
    enum Size: Int {
        case expanded = 1
        case contracted = 0
    }
    
    enum Position: Int {
        case top = 0
        case middle = 1
        case bottom = 2
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
        guard let firstName = representative.firstName,
            let lastName = representative.lastName else { return }
        firstNameLabel.text = "\(firstName) \(lastName)"
        stateLabel.text = representative.state
        representativeLabel.text = representative.roleType
        transform(size)
        
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
                self.representativeViewContentView.reloadInputViews()
            })
        }
    }
    
    private func transform(size: Size) {
        switch size {
        case .expanded:
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
        case .contracted:
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
    
    private func commonInit() {
        NSBundle.mainBundle().loadNibNamed("RepresentativeView", owner: self, options: nil)
        addSubview(representativeViewContentView)
        representativeViewContentView.translatesAutoresizingMaskIntoConstraints = false
        representativeViewContentView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        representativeViewContentView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        representativeViewContentView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        representativeViewContentView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        layoutIfNeeded()
        
        legislationTableView.registerClass(LegislationTableViewCell.self, forCellReuseIdentifier: "LegislationTableViewCell")
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        representativeViewContentView.addGestureRecognizer(tapRecognizer)
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        representativeViewContentView.addGestureRecognizer(panRecognizer)
    }
    
    //MARK: 
    func handleTap(gesture: UITapGestureRecognizer) {
        size = size == .contracted ? .expanded : .contracted
        transform(size)
        repViewDelegate?.shouldExpand(Bool(size.rawValue), for: self.position)
        print(Bool(size.rawValue))
    }
    
    func handlePan(gesture: UIPanGestureRecognizer) {
        repViewDelegate?.panGestureYPosition(gesture.translationInView(self).y, for: self.position)
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
