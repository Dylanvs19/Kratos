//
//  PieChartView.swift
//  Kratos
//
//  Created by Dylan Straughan on 11/6/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//

import UIKit

class PieChartView: UIView, Loadable {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var forLabel: UILabel!
    @IBOutlet var againstLabel: UILabel!
    @IBOutlet var abstainLabel: UILabel!
    
    var data: [PieChartData]?
    var startAngle: CGFloat = CGFloat(3 * M_PI) / 2
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    func configure(with data: [PieChartData]) {
        self.data = data
        self.setNeedsDisplay()
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.white
    }
    
    func setLabels(with data: [PieChartData]) {
        
        data.forEach { (datum) in
            switch datum.type {
            case .yea:
                forLabel.text = "\(Int(datum.value))"
                forLabel.textColor = UIColor.yeaVoteGreen
            case .nay:
                againstLabel.text = "\(Int(datum.value))"
                againstLabel.textColor = UIColor.kratosRed
            case .abstain:
                abstainLabel.text = "\(Int(datum.value))"
                abstainLabel.textColor = UIColor.gray
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
            let arcWidth: CGFloat = 20
            
            let additionToStartAngle = datum.value/total * 2 * CGFloat(M_PI)
            
            let endAngle = startAngle + additionToStartAngle

            let path = UIBezierPath(arcCenter: center,
                                    radius: radius/2 - arcWidth/2,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: true)
            path.lineWidth = arcWidth
            switch datum.type {
            case .yea:
                UIColor.yeaVoteGreen.setStroke()
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
