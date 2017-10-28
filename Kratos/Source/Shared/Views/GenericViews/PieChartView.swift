//
//  PieChartView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/6/16.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

struct PieChartData {
    var type: VoteValue
    var value: CGFloat
    
    init(with value: Int, type: VoteValue) {
        self.type = type
        self.value = CGFloat(value)
    }
}

class PieChartView: UIView {
    // MARK: - Variables -
    fileprivate let forLabel = UILabel()
    fileprivate let againstLabel = UILabel()
    fileprivate let abstainLabel = UILabel()
    
    fileprivate var data: [PieChartData]?
    fileprivate var startAngle: CGFloat = 3 * CGFloat.pi / 2
    
    // MARK: - Initialization -
    convenience init() {
        self.init(frame: .zero)
        addSubviews()
        constrainViews()
        styleViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration -
    func configure(with data: [PieChartData]) {
        self.data = data
        self.setNeedsDisplay()
        backgroundColor = UIColor.white
    }
    
    // MARK: - Helpers -
    private func setLabels(with data: [PieChartData]) {
        
        data.forEach { (datum) in
            switch datum.type {
            case .yea:
                forLabel.text = "\(Int(datum.value))"
                forLabel.style(with: .titleColor(datum.type.color))
            case .nay:
                againstLabel.text = "\(Int(datum.value))"
                againstLabel.style(with: .titleColor(datum.type.color))
            case .abstain:
                abstainLabel.text = "\(Int(datum.value))"
                abstainLabel.style(with: .titleColor(datum.type.color))
            }
        }
    }
    
    private func createPaths(from data: [PieChartData]) {
        var total: CGFloat = 0.0
        data.forEach { (datum) in
            total += datum.value
        }
        
        data.forEach { (datum) in
            let center = CGPoint(x:self.bounds.width/2, y: self.bounds.height/2)
            let radius: CGFloat = max(self.bounds.width, self.bounds.height)
            let arcWidth: CGFloat = 7
            
            let additionToStartAngle = datum.value/total * 2 * CGFloat.pi
            
            let endAngle = startAngle + additionToStartAngle
            
            let path = UIBezierPath(arcCenter: center,
                                    radius: radius/2 - arcWidth/2,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: true)
            path.lineWidth = arcWidth
            switch datum.type {
            case .yea:
                UIColor.kratosGreen.setStroke()
            case .nay:
                UIColor.kratosRed.setStroke()
            case .abstain:
                UIColor.gray.setStroke()
            }
            path.stroke()
            
            startAngle = endAngle
        }
    }

    // MARK: - Draw -
    override func draw(_ rect: CGRect) {
        if let data = data {
            createPaths(from: data)
            setLabels(with: data)
        }
    }
}

// MARK: - ViewBuilder -
extension PieChartView: ViewBuilder {
    func addSubviews() {
        addSubview(forLabel)
        addSubview(againstLabel)
        addSubview(abstainLabel)
    }
    func constrainViews() {
        againstLabel.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
        forLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(againstLabel.snp.top).offset(-2)
        }
        abstainLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(againstLabel.snp.bottom).offset(2)
        }
    }
    func styleViews() {
        forLabel.style(with: [.font(.text),
                              .titleColor(.kratosGreen)])
        againstLabel.style(with: [.font(.text),
                              .titleColor(.kratosRed)])
        abstainLabel.style(with: [.font(.text),
                              .titleColor(.lightGray)])
    }
}

extension Reactive where Base: PieChartView {
    var data: UIBindingObserver<Base, [PieChartData]> {
        return UIBindingObserver(UIElement: self.base, binding: { (pieChartView, data) in
            pieChartView.configure(with: data)
        })
    }
}

