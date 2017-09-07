//
//  SubjectCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 8/29/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class SubjectCell: UICollectionViewCell {
    // MARK: - Variables -
    
    // Identifier
    static let identifier = String(describing: SubjectCell.self)
    
    // Standard
    let label = UILabel()
    
    // Overrides
    override var isSelected: Bool {
        didSet {
            animateStyle(for: isSelected)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    // MARK: - Animations -
    func animateStyle(for isSelected: Bool) {
        let titleColor: Color = isSelected ? .white : .kratosRed
        let backgroundColor: Color = !isSelected ? .white : .kratosRed
        UIView.animate(withDuration: 0.2) { 
            self.label.style(with: .titleColor(titleColor))
            self.contentView.style(with: .backgroundColor(backgroundColor))
        }
    }
}

// MARK: - ViewBuilder -
extension SubjectCell: ViewBuilder {
    func addSubviews() {
        contentView.addSubview(label)
    }
    
    func constrainViews() {
        label.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(3)
        }
    }
    
    func styleViews() {
        label.style(with: [.font(.cellTitle),
                           .titleColor(.kratosRed)])
        contentView.style(with: [.borderColor(.gray),
                                 .borderWidth(1),
                                 .cornerRadius(12)])
    }
}
