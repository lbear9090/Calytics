//
//  AnalyticsTVCell.swift
//  CalendarAnalytics
//
//  Created by Lucky on 2018/8/20.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit
import Charts

class AnalyticsTVCell: UITableViewCell, ChartViewDelegate {
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblBookedHours: UILabel!
    @IBOutlet weak var lblMeetings: UILabel!
    @IBOutlet weak var lblCalls: UILabel!
    
    @IBOutlet weak var txtCategory: UITextView!
    @IBOutlet weak var txtTask: UITextView!
    
    @IBOutlet weak var chartCategory: PieChartView!
    @IBOutlet weak var chartTask: PieChartView!
    
    @IBOutlet weak var lblPeriod: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        initChartView(chartView: chartCategory)
        initChartView(chartView: chartTask)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initChartView(chartView:PieChartView){
        let l = chartView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .vertical
        l.xEntrySpace = 7
        l.yEntrySpace = 0
        l.yOffset = 0
        chartView.delegate =  self
        chartView.drawCenterTextEnabled = true
    }
    
    func setChartData(isCategory: Bool, eventGroups: [EventGroup]) {
        let chartView = (isCategory ? chartCategory:chartTask)!
        var events = Array(eventGroups)
        
        var totalDuration = 0.0
        for i in 0..<events.count{
//            if totalDuration <= 0{
//                events.remove(at: i)
//            }else{
                totalDuration += events[i].totalDuration
//            }
        }
        
        if events.count <= 0{
            chartView.data = nil
            return
        }
        
        let entries = (0..<events.count).map { (i) -> PieChartDataEntry in
            // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
            let data = ["totalDuration": totalDuration,
                        "groupDuration": events[i].totalDuration]
            
            return PieChartDataEntry(value: Double(events[i].totalDuration * 100 / totalDuration),
                                     label: events[i].title,
                                     data: data as AnyObject)
        }
        
        let set = PieChartDataSet(values: entries, label: nil)
        set.drawIconsEnabled = false
        set.sliceSpace = 2
        
        
        set.colors = ChartColorTemplates.vordiplom()
            + ChartColorTemplates.joyful()
            + ChartColorTemplates.colorful()
            + ChartColorTemplates.liberty()
            + ChartColorTemplates.pastel()
            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
        
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(.systemFont(ofSize: 11, weight: .light))
        data.setValueTextColor(.black)
        
        chartView.data = data
        chartView.highlightValues(nil)
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let data = entry.data as! [String:Double]
        let total = data["totalDuration"]!
        let group = data["groupDuration"]!
        let percent = group * 100.0 / total
        
        let text = (entry as! PieChartDataEntry).label! + "\n" + percent.clean + " %\n" + (group/60.0).clean + " hours"
        (chartView as! PieChartView).centerText = text
    }
}
