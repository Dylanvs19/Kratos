//
//  DatePickerView.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/3/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

protocol DatePickerViewDelegate: class {
    func selectedDate(date: Date)
}

class DatePickerView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    weak var delegate: DatePickerViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    func customInit() {
        Bundle.main.loadNibNamed("DatePickerView", owner: self, options: nil)
        addSubview(contentView)
        translatesAutoresizingMaskIntoConstraints = false
        contentView.frame = bounds
        layer.cornerRadius = 5.0
        layer.masksToBounds = true 
        backgroundColor = UIColor.gray
        datePicker.maximumDate = Date()
        datePicker.setDate(Date().addingTimeInterval(-60 * 60 * 24 * 365 * 30) , animated: false)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        delegate?.selectedDate(date: datePicker.date)
    }
}
