//
//  SubjectSelectionCell.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/12/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit

class SubjectSelectionCell: UITableViewCell {
    
    // Identifier
    static let identifier = String(describing: SubjectCell.self)
    
    let label = UILabel()
    let clearButton = UIButton()
    
    // Overrides
    override var isSelected: Bool {
        didSet {
            animateStyle(for: isSelected)
        }
    }
    
    // MARK: - Initializer -
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration -
    func configure(with subject: Subject) {
        textLabel?.text = subject.name
    }
    
    private func configureCell() {
        textLabel?.style(with: [.font(.title),
                                .titleColor(.gray),
                                .numberOfLines(5)])
        separatorInset = .zero
    }
    
    // MARK: - Animations -
    private func animateStyle(for isSelected: Bool) {
        let titleColor: Color = isSelected ? .gray : .kratosRed
        UIView.animate(withDuration: 0.2) {
            self.textLabel?.style(with: .titleColor(titleColor))
        }
    }
}
