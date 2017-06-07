//
//  DatePickerView.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/3/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol DatePickerViewDelegate: class {
    func selectedDate(date: Date)
}

class DatePickerView: UIView, ViewBuilder {
    
    let datePicker = UIDatePicker()
    let doneButton = UIButton()
    
    weak var delegate: DatePickerViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureDatePicker() {
        setupPickerView()
        buildViews()
        style()
        doneButton.addTarget(self, action: #selector(doneButtonPressed(_:)), for: .touchUpInside)
    }
    
    func buildViews() {
        addSubview(doneButton)
        doneButton.snp.makeConstraints { (make) in
            make.bottom.trailing.leading.equalTo(self)
            make.height.equalTo(40)
        }
        addSubview(datePicker)
        datePicker.snp.makeConstraints { (make) in
            make.top.trailing.leading.equalTo(self)
            make.bottom.equalTo(doneButton.snp.top)
        }
    }
    
    func style() {
        doneButton.setTitleColor(.kratosRed, for: .normal)
        doneButton.setTitleColor(.red, for: .highlighted)
        doneButton.titleLabel?.font = Font.futura(size: 14).font
        doneButton.setTitle("D O N E", for: .normal)
    }
    
    func setupPickerView() {
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        backgroundColor = UIColor.white
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.setDate(Date().addingTimeInterval(-60 * 60 * 24 * 365 * 30) , animated: false)
    }
    
    func doneButtonPressed(_ sender: Any) {
        delegate?.selectedDate(date: datePicker.date)
    }
}
