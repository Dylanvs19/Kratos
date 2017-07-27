//
//  PieChartView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/6/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class PieChartView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var forHeadingLabel: UILabel!
    @IBOutlet weak var againstHeadingLabel: UILabel!
    @IBOutlet weak var abstainHeadingLabel: UILabel!
    @IBOutlet var forLabel: UILabel!
    @IBOutlet var againstLabel: UILabel!
    @IBOutlet var abstainLabel: UILabel!
    
    var data: [PieChartData]?
    var startAngle: CGFloat = 3 * CGFloat.pi / 2
    var hideLables = false
    
    func configure(with tally: Tally, hideLabels: Bool = false ) {
        
        let votesFor = tally.yea ?? 0
        let against = tally.nay ?? 0
        let abstain = tally.abstain ?? 0
        self.data = [PieChartData(with: votesFor, and: .yea),
                     PieChartData(with: abstain, and: .abstain),
                     PieChartData(with: against, and: .nay)
                    ]
        
        self.hideLables = hideLabels
        self.setNeedsDisplay()
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.white
    }
    
    func setLabels(with data: [PieChartData]) {
        
        if hideLables {
            forHeadingLabel.isHidden = true
            againstHeadingLabel.isHidden = true
            abstainHeadingLabel.isHidden = true
            forLabel.isHidden = true
            againstLabel.isHidden = true
            abstainLabel.isHidden = true
            
        } else {
            
            data.forEach { (datum) in
                switch datum.type {
                case .yea:
                    forLabel.text = "\(Int(datum.value))"
                    forLabel.style(with: .titleColor(.kratosGreen))
                case .nay:
                    againstLabel.text = "\(Int(datum.value))"
                    forLabel.style(with: .titleColor(.kratosRed))
                case .abstain:
                    abstainLabel.text = "\(Int(datum.value))"
                    forLabel.style(with: .titleColor(.lightGray))
                }
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        if let data = data {
            createPaths(from: data)
            setLabels(with: data)
        }
    }
    
    func createPaths(from data: [PieChartData]) {
        var total: CGFloat = 0.0
        data.forEach { (datum) in
            total += datum.value
        }
        
        data.forEach { (datum) in
            let center = CGPoint(x:contentView.bounds.width/2, y: contentView.bounds.height/2)
            let radius: CGFloat = max(contentView.bounds.width, contentView.bounds.height)
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
}
