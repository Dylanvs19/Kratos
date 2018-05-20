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
    let title = UILabel(style: .h3gray)
    let imageView = UIImageView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        styleViews()
        addSubviews()
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
    func styleViews() {
        imageView.contentMode = .scaleAspectFit
        contentView.backgroundColor = Color.white.value
    }
    
    func addSubviews() {
        addTitle()
        addImageView()
    }
    
    private func addTitle() {
        contentView.addSubview(title)

        title.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
        }
    }
    
    private func addImageView() {
        contentView.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview().inset(5)
            make.height.equalTo(35)
        }
    }
}
