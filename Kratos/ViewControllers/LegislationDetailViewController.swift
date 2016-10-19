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
        
        
    }
    var billId: Int?
    
    
    func setData() {
        var realm = RLMRealm.defaultRealm()
        var realmPieDataSet = RealmPieData(results: <#T##RLMResults?#>, xValueField: <#T##String#>, dataSets: <#T##[IChartDataSet]?#>)
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
