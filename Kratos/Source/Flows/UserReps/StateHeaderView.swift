//
//  StateHeaderView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/30/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import UIKit

class StateHeaderView: UITableViewHeaderFooterView {
    // MARK: - Properties -
    static let identifier = String(describing: StateHeaderView.self)
    let title = UILabel()
    let imageView = UIImageView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubviews()
        constrainViews()
        styleViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with state: State) {
        title.text = state.fullName
        imageView.image = state.grayImage
    }
}

extension StateHeaderView: ViewBuilder {
    func addSubviews() {
        contentView.addSubview(title)
        contentView.addSubview(imageView)
    }
    func constrainViews() {
        title.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
        }
        imageView.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
        }
    }
    func styleViews() {
        
    }
}
