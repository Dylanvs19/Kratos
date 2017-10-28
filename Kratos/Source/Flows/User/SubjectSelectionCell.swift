//
//  SubjectSelectionCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/12/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class SubjectSelectionCell: UITableViewCell {
    
    // Identifier
    static let identifier = String(describing: SubjectSelectionCell.self)
    
    // MARK: - Variables -
    let disposeBag = DisposeBag()
    let label = UILabel()
    let clearImage = UIImageView(image: #imageLiteral(resourceName: "clearIcon").af_imageScaled(to: CGSize(width: 15, height: 15)))
    
    override var isSelected: Bool {
        didSet {
            let titleColor: Color = isSelected ? .kratosRed : .gray
            UIView.animate(withDuration: 0.1) {
                self.label.style(with: .titleColor(titleColor))
                self.clearImage.snp.remakeConstraints { make in
                    make.centerY.equalToSuperview()
                    make.trailing.equalToSuperview().inset(10)
                    if self.isSelected {
                        make.width.height.equalTo(15)
                    } else {
                        make.height.equalTo(15)
                        make.width.equalTo(0)
                    }
                }
                self.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Initializer -
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        constrainViews()
        styleViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration -
    func configure(with subject: Subject) {
        label.text = subject.name
    }
}

extension SubjectSelectionCell: ViewBuilder {
    func addSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        contentView.addSubview(clearImage)
    }
    
    func constrainViews() {
        clearImage.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(10)
            make.height.equalTo(15)
            make.width.equalTo(0)

        }
        label.snp.remakeConstraints { make in
            make.leading.equalToSuperview().inset(5)
            make.top.bottom.equalToSuperview().inset(15)
            make.trailing.lessThanOrEqualToSuperview().inset(30)
        }
    }
    
    func styleViews() {
        label.style(with: [.font(.cellTitle),
                                .numberOfLines(5)])
        clearImage.isUserInteractionEnabled = false
        label.numberOfLines = 5
        separatorInset = .zero
        selectionStyle = .none
    }
}
