//
//  LegislationDetailViewController.swift
//  Kratos
//
//  Created by Dylan Straughan on 7/30/16.
//  Copyright © 2016 Dylan Straughan. All rights reserved.
//


import UIKit
import Charts
import Realm
import RealmSwift

class LegislationDetailViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet var representativesVotePieChart: PieChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        representativesVotePieChart.delegate = self
        setUpSwipe()
        let options = [
            ["key": "toggleValues", "label": "Toggle Y-Values"],
            ["key": "toggleXValues", "label": "Toggle X-Values"],
            ["key": "togglePercent", "label": "Toggle Percent"],
            ["key": "toggleHole", "label": "Toggle Hole"],
            ["key": "animateX", "label": "Animate X"],
            ["key": "animateY", "label": "Animate Y"],
            ["key": "animateXY", "label": "Animate XY"],
            ["key": "spin", "label": "Spin"],
            ["key": "drawCenter", "label": "Draw CenterText"],
            ["key": "saveToGallery", "label": "Save to Camera Roll"],
            ["key": "toggleData", "label": "Toggle Data"]
        ]
    }
    var billId: Int?
    
    func setupPieChart() {
        representativesVotePieChart.usePercentValuesEnabled = true;
        representativesVotePieChart.drawSlicesUnderHoleEnabled = false;
        representativesVotePieChart.holeRadiusPercent = 0.58;
        representativesVotePieChart.transparentCircleRadiusPercent = 0.61
//        representativesVotePieChart.chartDescription.enabled = false
        representativesVotePieChart.setExtraOffsets(left: 5.0, top: 5.0, right: 5.0, bottom: 5.0)
        
        representativesVotePieChart.drawCenterTextEnabled = false
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineBreakMode = .ByTruncatingTail
        paragraphStyle.alignment = .Center
        
//        let centerText = NSMutableAttributedString(string: "Charts\nby Daniel Cohen Gindi")
//        centerText.setAttributes([UIFont(named:"HelveticaNeue-Light", size:13.f,], range: )
//            NSFontAttributeName: UIFont(named:"HelveticaNeue-Light" size:13.f],
//        NSParagraphStyleAttributeName: paragraphStyle
//        } range:NSMakeRange(0, centerText.length)]
//        [centerText addAttributes:@{
//        NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f],
//        NSForegroundColorAttributeName: UIColor.grayColor
//        } range:NSMakeRange(10, centerText.length - 10)];
//        [centerText addAttributes:@{
//        NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:11.f],
//        NSForegroundColorAttributeName: [UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f]
//        } range:NSMakeRange(centerText.length - 19, 19)]
//        representativesVotePieChart.centerAttributedText = centerText
        
        representativesVotePieChart.drawHoleEnabled = true
        representativesVotePieChart.rotationAngle = 0.0
        representativesVotePieChart.rotationEnabled = true
        representativesVotePieChart.highlightPerTapEnabled = true
        

    }
    
    func setData() {
       let array = [PieChartData(xVals: [1, 2, 3])]
        let dataSet = PieChartDataSet(yVals: array, label: "PieChart Data Set")
        dataSet.sliceSpace = 2.0
        
    }
    
    func setUpSwipe() {
        let swipeGR = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(_:)))
        swipeGR.direction = .Right
        view.addGestureRecognizer(swipeGR)
    }
    
    func handleSwipeRight(gestureRecognizer: UIGestureRecognizer) {
            navigationController?.popViewControllerAnimated(true)
    }
}
