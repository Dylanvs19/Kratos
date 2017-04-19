//
//  BillHeaderView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/19/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class BillHeaderView: UIView {
    
    var billNumber = UILabel()
    var billTitle = UILabel()
    var currentStatusLabel = UILabel()
    var currentStatusDateLabel = UILabel()
    let dividerView = UIView()
    
    var bill: Bill? {
        didSet {
            if bill != nil {
                configure(with: bill!)
            }
        }
    }
    
    func configure(with bill: Bill) {
        let title = bill.title != nil ? bill.title : bill.officialTitle
        
        billTitle.text = title
        billNumber.text = bill.billNumber
        currentStatusLabel.text = bill.status
        if let date = bill.statusDate {
            currentStatusDateLabel.text = DateFormatter.presentationDateFormatter.string(from: date)
        }
    }
    
    func buildViews(with bill: Bill) {
        addSubview(billNumber)
        billNumber.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        billNumber.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        billNumber.widthAnchor.constraint(equalTo: widthAnchor, constant: -20).isActive = true
        
        addSubview(billTitle)
        billTitle.topAnchor.constraint(equalTo: billNumber.bottomAnchor, constant: 5).isActive = true
        billTitle.widthAnchor.constraint(equalTo: widthAnchor, constant: -20).isActive = true
        billTitle.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        billTitle.numberOfLines = 8
        
        dividerView.backgroundColor = UIColor.kratosRed
        addSubview(dividerView)
        dividerView.topAnchor.constraint(equalTo: billTitle.bottomAnchor, constant: 5).isActive = true
        dividerView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        dividerView.widthAnchor.constraint(equalTo: widthAnchor, constant: -20).isActive = true
        
        if let status = bill.status {
            addSubview(currentStatusLabel)
            currentStatusLabel.topAnchor.constraint(equalTo: dividerView.topAnchor, constant: 2).isActive = true
            currentStatusLabel.leadingAnchor.constraint(equalTo: dividerView.leadingAnchor).isActive = true
            currentStatusLabel.topAnchor.constraint(equalTo: dividerView.topAnchor, constant: 2).isActive = true
            currentStatusLabel.text = status
        }
        
        addSubview(currentStatusDateLabel)
        billNumber.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
    }
    
    func translate(with height: CGFloat) {
        
    }
    
    func style() {
        
    }
    
    func followBillPressed(sender: UIButton) {
    
    }
    
}
