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

class DatePickerView: UIView {
    let selectedDate = PublishSubject<Date>()
    fileprivate let disposeBag = DisposeBag()
    fileprivate let datePicker = UIDatePicker()
    fileprivate let doneButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureDatePicker() {
        setupPickerView()
        addSubviews()
        constrainViews()
        styleViews()
        bind()
    }
    
    func setupPickerView() {
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        backgroundColor = UIColor.white
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.setDate(Date(timeIntervalSince1970: 0), animated: false)
    }
}

extension DatePickerView: ViewBuilder {
    func addSubviews() {
        addSubview(doneButton)
        addSubview(datePicker)
    }
    func constrainViews() {
        doneButton.snp.makeConstraints { (make) in
            make.bottom.trailing.leading.equalTo(self)
            make.height.equalTo(40)
        }
        datePicker.snp.makeConstraints { (make) in
            make.top.trailing.leading.equalTo(self)
            make.bottom.equalTo(doneButton.snp.top)
        }
    }
    func styleViews() {
        doneButton.style(with: [.font(.body),
                                .titleColor(.kratosRed),
                                .highlightedTitleColor(.red)
                                ])
        doneButton.setTitle("D O N E", for: .normal)
    }
}

extension DatePickerView: RxBinder {
    func bind() {
        doneButton.rx.tap
            .map { _ in return self.datePicker.date }
            .bind(to: selectedDate)
            .disposed(by: disposeBag)
    }
}

