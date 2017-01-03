//
//  TemperatureViewController.swift
//  NuBrick
//
//  Created by mwang on 29/12/2016.
//  Copyright © 2016 nuvoton. All rights reserved.
//

import UIKit
import Charts

class TemperatureViewController: UIViewController {
    @IBOutlet weak var lineChartView: LineChartView!
    
    var lineBuffer:[Double] = Array(repeating: 0, count: 100)
    var dataEntries: [ChartDataEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Set Default Line Chart View
        for i in 0..<lineBuffer.count {
            let dataEntry = ChartDataEntry(x: Double(i-3), y: Double(i*i-9))
            dataEntries.append(dataEntry)
        }
        lineChartView.data = LineChartData(dataSet: LineChartDataSet(values: dataEntries, label: "default"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
