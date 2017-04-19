//
//  StackViewView.swift
//  Kratos
//
//  Created by Dylan Straughan on 12/29/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class KratosStackView: UIView {
    
    var stackView: UIStackView?
    
    func configure(with label: String? = nil, labelSize: CGFloat) {
        stackView = UIStackView()
        guard let stackView = stackView else { return }
        stackView.pin(to: self, for: [.bottom, .trailing, .leading])
        if let label = label {
            let titleLabel = UILabel()
            addSubview(titleLabel)
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5)
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10)
            titleLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: 5)
            titleLabel.text = label
            
        } else {
            stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        }
        
    }
    
}
