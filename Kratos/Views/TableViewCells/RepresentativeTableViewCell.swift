//
//  RepresentativeTableViewCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/16/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

protocol RepresentativeTableViewCellDelegate {
    func didSelectVote(_ vote: Vote)
}

class RepresentativeTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var repView: UIView!
    @IBOutlet var representativeImageView: UIImageView!
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var representativeLabel: UILabel!
    @IBOutlet var stateImageView: UIImageView!
    
    @IBOutlet var legislationTableView: UITableView!
    
    @IBOutlet var repImageViewCenterY: NSLayoutConstraint!
    @IBOutlet var repImageViewToTop: NSLayoutConstraint!
    
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
    var delegate: RepresentativeTableViewCellDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        legislationTableView.delegate = self
        legislationTableView.dataSource = self
        legislationTableView.register(UINib(nibName: "VoteTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.VOTE_TABLEVIEWCELL_IDENTIFIER)
        legislationTableView.estimatedRowHeight = 80
        legislationTableView.rowHeight = UITableViewAutomaticDimension
        legislationTableView.setNeedsLayout()
        legislationTableView.layoutIfNeeded()
        
    }
    
    func configure(with representative:Representative) {
        self.representative = representative
        guard let firstName = representative.firstName,
            let lastName = representative.lastName else { return }
        repView.layer.shadowColor = UIColor.black.cgColor
        repView.layer.shadowOffset = CGSize(width: 0, height: 3)
        repView.layer.shadowOpacity = 0.3
        repView.layer.shadowRadius = 1
        representativeImageView?.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3).cgColor
        representativeImageView?.layer.borderWidth = 3.0
        representativeImageView?.layer.cornerRadius = 3.0
        firstNameLabel.text = "\(firstName) \(lastName)"
        if let state = representative.state {
            stateImageView.image = UIImage.imageForState(state)
        }
        representativeLabel.text = representative.roleType
        
        if let imageURL = representative.imageURL {
            UIImage.downloadedFrom(imageURL, onCompletion: { (image) -> (Void) in
                guard let image = image else { return }
                self.representativeImageView.image = image
                self.representativeImageView.contentMode = .scaleAspectFill
                if let party = representative.party {
                    var color = UIColor()
                    switch party {
                    case .democrat:
                        color = UIColor.kratosBlue
                    case .republican:
                        color = UIColor.kratosRed
                    case .independent:
                        color = UIColor.gray
                    }
                    self.repView.backgroundColor = color
                } else {
                    self.repView.backgroundColor = UIColor.gray
                }
                self.reloadInputViews()
            })
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            legislationTableView.reloadData()
            UIView.animate(withDuration: 0.2, animations: {
                
                self.repViewDeselectedWidth.isActive = false
                self.repViewSelectedWidth.isActive = true
                
                self.repViewTopWithSpacing.isActive = false
                self.repViewToTop.isActive = true
                
                self.tableViewHeightEnabled.isActive = false
                self.legislationTableViewToBottom.isActive = true
                
                self.repImageViewToTop.isActive = true
                self.repImageViewCenterY.isActive = false
                
                self.repViewToBottomWithSpacing.isActive = false
                self.repViewContractedHeight.isActive = true
                
                self.layoutIfNeeded()
            })
            
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                
                self.repViewSelectedWidth.isActive = false
                self.repViewDeselectedWidth.isActive = true
                
                self.repViewToTop.isActive = false
                self.repViewTopWithSpacing.isActive = true

                self.legislationTableViewToBottom.isActive = false
                self.tableViewHeightEnabled.isActive = true
                
                self.repImageViewCenterY.isActive = true
                self.repImageViewToTop.isActive = false

                self.repViewContractedHeight.isActive = false
                self.repViewToBottomWithSpacing.isActive = true

                self.layoutIfNeeded()
            })
        }
    }
    
    //MARK: UITableViewDelegate & Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return representative?.votes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundView = nil
        cell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.VOTE_TABLEVIEWCELL_IDENTIFIER, for: indexPath) as? VoteTableViewCell else { return UITableViewCell() }
        guard let votesArray = representative?.votes else { return UITableViewCell()}
        let vote = votesArray[(indexPath as IndexPath).row]
        cell.vote = vote
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let votesArray = representative?.votes else { return }
        let vote = votesArray[(indexPath as IndexPath).row]
        delegate?.didSelectVote(vote)
    }
}
