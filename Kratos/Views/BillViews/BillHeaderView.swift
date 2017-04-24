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
        billNumber.text = bill.billNumber
        billTitle.text = title
        trackButton.set(bill: bill)
        if let status = bill.status {
            currentStatusLabel.text = status.lowercased().localizedCapitalized
            if let date = bill.statusDate {
                currentStatusDateLabel.text = DateFormatter.presentationDateFormatter.string(from: date)
            }
        }
        style()
        buildViews(with: bill)
    }
    
    func buildViews(with bill: Bill) {
        addSubview(billNumber)
        billNumber.translatesAutoresizingMaskIntoConstraints = false
        billNumber.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        billNumber.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        billNumber.widthAnchor.constraint(equalTo: widthAnchor, constant: -20).isActive = true
        
        addSubview(billTitle)
        billTitle.translatesAutoresizingMaskIntoConstraints = false
        billTitle.topAnchor.constraint(equalTo: billNumber.bottomAnchor, constant: 5).isActive = true
        billTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        billTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        
        //DividerView
        dividerView.backgroundColor = UIColor.kratosRed
        addSubview(dividerView)
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.topAnchor.constraint(equalTo: billTitle.bottomAnchor, constant: 5).isActive = true
        dividerView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        dividerView.widthAnchor.constraint(equalTo: widthAnchor, constant: -20).isActive = true
        dividerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addSubview(trackButton)
        trackButton.translatesAutoresizingMaskIntoConstraints = false
        trackButton.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 5).isActive = true
        trackButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        let heightAnchor = trackButton.heightAnchor.constraint(equalToConstant: 30)
        heightAnchor.priority = 999
        heightAnchor.isActive = true
        trackButton.trailingAnchor.constraint(equalTo: dividerView.trailingAnchor).isActive = true
        trackButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        
        if bill.status != nil  {
            addSubview(currentStatusLabel)
            currentStatusLabel.translatesAutoresizingMaskIntoConstraints = false
            currentStatusLabel.topAnchor.constraint(equalTo: dividerView.topAnchor, constant: 4).isActive = true
            currentStatusLabel.leadingAnchor.constraint(equalTo: dividerView.leadingAnchor).isActive = true
            currentStatusLabel.trailingAnchor.constraint(equalTo: trackButton.leadingAnchor, constant: -10).isActive = true
            
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
