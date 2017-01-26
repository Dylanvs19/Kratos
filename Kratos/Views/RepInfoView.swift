//
//  RepInfoView.swift
//  Kratos
//
//  Created by Dylan Straughan on 1/13/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

protocol RepInfoViewPresentable: class {
    var repInfoView: RepInfoView! { get set }
    func presentRepInfoView(with personID: Int)
}

extension RepInfoViewPresentable where Self: UIViewController {
    func presentRepInfoView(with personID: Int) {
        repInfoView.configure(with: personID)
        repInfoView.repContactView.configureActionBlocks(presentTwitter: self.presentTwitter, presentHome: self.presentHomeAddress)
        FirebaseAnalytics.FlowAnalytic.selectedRepresentative(representativeID: personID).fireEvent()
    }
}

class RepInfoView: UIView, Loadable, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet public var contentView: UIView!
    @IBOutlet weak var repImageView: RepImageView!
    @IBOutlet weak var repName: UILabel!
    @IBOutlet weak var repType: UILabel!
    @IBOutlet weak var repState: UILabel!
    @IBOutlet weak var repParty: UILabel!
    @IBOutlet weak var repStateView: UIImageView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var repContactView: RepContactView!
    @IBOutlet weak var tableView: UITableView!
    
    var terms: [Term]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
        setupTableView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
        setupTableView()
    }
    
    func configure(with personID: Int) {
        addBlurEffect(front: false)
        APIManager.getPerson(for: personID, success: { (person) in
            guard let firstName = person.firstName,
                let lastName = person.lastName else { return }
            self.repName.text = "\(firstName) \(lastName)"
            self.repType.text = person.currentChamber?.toRepresentativeType().rawValue
            self.repState.text = person.currentState?.fullStateName()
            self.repImageView.setRepresentative(person: person, repInfoViewActionBlock: nil)
            self.repParty.text = person.currentParty?.capitalLetter()
            self.repParty.textColor = person.currentParty?.color()
            self.repImageView.isUserInteractionEnabled = false
            if let state =  person.currentState {
                self.repStateView.image = UIImage.imageForState(state)
            }
            self.repContactView.configure(with: person)
            self.terms = person.terms
        }) { (error) in
            print(error)
        }
        alphaOut()
        animateIn()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: String(describing: TermTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TermTableViewCell.self))
        tableView.tableFooterView = UIView() 
        backgroundColor = UIColor.clear
        alphaOut()
    }
    
    func animateIn() {
        UIView.animate(withDuration: 0.2, delay: 0.2, options: [], animations: {
            self.alpha = 1
            self.repImageView.alpha = 1
            self.repName.alpha = 1
            self.repType.alpha = 1
            self.repState.alpha = 1
            self.repStateView.alpha = 1
            self.exitButton.alpha = 1
            self.repContactView.alpha = 1
            self.layoutIfNeeded()
        }) { (success) in
            self.repContactView.animateIn()
        }
    }
    
    func alphaOut() {
        alpha = 0
        repImageView.alpha = 0
        repName.alpha = 0
        repType.alpha = 0
        repState.alpha = 0
        repStateView.alpha = 0
        exitButton.alpha = 0
        repContactView.alpha = 0
    }

    @IBAction func exitButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.2) {
            self.alphaOut()
            self.repImageView.image = nil 
            self.repContactView.animateOut()
            self.layoutIfNeeded()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return terms?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TermTableViewCell.self), for: indexPath) as? TermTableViewCell,
            let term = terms?[indexPath.row] else { return UITableViewCell()}
        cell.configure(with: term)
        cell.backgroundColor = UIColor.clear
        return cell
    }
}
