//
//  InfoManagerView.swift
//  Kratos
//
//  Created by Dylan Straughan on 4/18/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import UIKit

protocol InfoManagerViewDelegate {
    func didSelect(title: String, at index: Int)
}

class InfoManagerView: UIView {
    
    fileprivate var viewMap = [String: Int]()
    fileprivate var slideViewConstraint = NSLayoutConstraint()
    var delegate: InfoManagerViewDelegate?
    
    func configure(with titles: [String]) {
        buildViews(with: buildViewMap(with: titles))
    }
    
    fileprivate func buildViewMap(with titles: [String]) -> [String: Int] {
        var count = 0
        titles.forEach {
            viewMap[$0] = count
            count += 1
        }
        return viewMap
    }
    
    fileprivate func buildViews(with viewMap: [String: Int]) {
        translatesAutoresizingMaskIntoConstraints = false
        let stackView = UIStackView()
        stackView.pin(to: self)
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        viewMap.keys.forEach {
            let button = UIButton()
            button.setTitle($0, for: .normal)
            button.titleLabel?.font = Font.futura(size: 15).font
            button.setTitleColor(UIColor.kratosRed, for: .normal)
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            button.backgroundColor = UIColor.clear
            stackView.addArrangedSubview(button)
            
        }
        
        let slideView = UIView()
        slideView.backgroundColor = UIColor.kratosRed
        slideView.pin(to: self, for: [.bottom(0)])
        slideView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        slideView.widthAnchor.constraint(equalToConstant: frame.size.width/CGFloat(viewMap.count)).isActive = true
        slideViewConstraint = slideView.leadingAnchor.constraint(equalTo: leadingAnchor)
        slideViewConstraint.isActive = true
    }
    
    @objc fileprivate func buttonPressed(sender: UIButton) {
        guard let title = sender.titleLabel?.text,
              let index = viewMap[title] else { return }
        UIView.animate(withDuration: 0.2) {
            let buttonWidth = self.frame.size.width/CGFloat(self.viewMap.count)
            self.slideViewConstraint.constant = buttonWidth * CGFloat(index)
            self.layoutIfNeeded()
        }
        delegate?.didSelect(title: title, at: index)
    }
}

