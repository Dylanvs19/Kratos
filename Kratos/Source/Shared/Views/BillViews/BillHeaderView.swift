//
//  BillHeaderView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class BillHeaderView: UIView {
    
    let billNumber = UILabel()
    let billTitle = UILabel()
    let currentStatusLabel = UILabel()
    let currentStatusDateLabel = UILabel()
    let trackButton = TrackButton()
    let dividerView = UIView()
    
    func configure(with bill: Bill) {
        
        let title = bill.title != nil ? bill.title : bill.officialTitle
        billNumber.text = bill.prettyGpoID
        billTitle.text = title
        trackButton.set(bill: bill)
        if let status = bill.status {
            currentStatusLabel.text = status.lowercased().localizedCapitalized
            if let date = bill.statusDate {
                currentStatusDateLabel.text = DateFormatter.presentation.string(from: date)
            }
        }
        style()
        buildViews(with: bill)
    }
}
extension BillHeaderView: ViewBuilder {
    func addSubviews() {
        
    }
    func constrainViews() {
        
    }
    
    func buildViews() {
        
    }
    
    func buildViews(with bill: Bill) {
        
        billNumber.centerXAnchor.constrain(equalTo: centerXAnchor)
        billNumber.widthAnchor.constrain(to: widthAnchor)
        
        billTitle.topAnchor.constrain(equalTo: billNumber.bottomAnchor, constant: 5)

        //DividerView
        dividerView.backgroundColor = UIColor.kratosRed
        addSubview(dividerView)
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.topAnchor.constrain(equalTo: billTitle.bottomAnchor, constant: 5)
        dividerView.heightAnchor.constrain(equalTo: 2)
        dividerView.widthAnchor.constrain(equalTo: widthAnchor, constant: -20)
        dividerView.centerXAnchor.constrain(equalTo: centerXAnchor)
        
        

        trackButton.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 5).isActive = true
        trackButton.widthAnchor.constrain(equalTo: 60)
        trackButton.heightAnchor.constrain(equalTo: 30, priority: 999)
        trackButton.trailingAnchor.constrain(equalTo: dividerView.trailingAnchor)
        
        if bill.status != nil  {
            addSubview(currentStatusLabel)
            currentStatusLabel.translatesAutoresizingMaskIntoConstraints = false
            currentStatusLabel.topAnchor.constrain(equalTo: dividerView.topAnchor, constant: 4)
            currentStatusLabel.leadingAnchor.constrain(equalTo: dividerView.leadingAnchor)
            currentStatusLabel.trailingAnchor.constrain(equalTo: trackButton.leadingAnchor, constant: -10)
            
            if bill.statusDate != nil  {
                addSubview(currentStatusDateLabel)
                currentStatusDateLabel.translatesAutoresizingMaskIntoConstraints = false
                currentStatusDateLabel.topAnchor.constraint(equalTo: currentStatusLabel.bottomAnchor, constant: 2).isActive = true
                currentStatusDateLabel.leadingAnchor.constraint(equalTo: dividerView.leadingAnchor).isActive = true
            }
        }
    }
    
    func style() {
        
        billTitle.numberOfLines = 8
        billTitle.adjustsFontSizeToFitWidth = true
        billTitle.minimumScaleFactor = 2.0
        billTitle.font = Font.futuraStandard.font
        billTitle.textAlignment = .center
        
        currentStatusLabel.font = Font.avenirNextMedium(size: 12).font
        currentStatusLabel.textColor = UIColor.lightGray
        
        currentStatusDateLabel.font = Font.avenirNextMedium(size: 12).font
        currentStatusDateLabel.textColor = UIColor.lightGray
    }
}
