//
//  ConfirmVC.swift
//  CalendarAnalytics
//
//  Created by Lucky on 2018/8/5.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit

class ConfirmVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var analyticsVC : AnalyticsVC!
    var m_eList = [Event]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //List only unduplicated events
        if g_eTimeFilter.count > 0{
            m_eList.append(g_eTimeFilter[0])
            for i in 1..<g_eTimeFilter.count{
                var bExist = false
                for j in 0..<i{
                    if g_eTimeFilter[i].sTitle.lowercased() == g_eTimeFilter[j].sTitle.lowercased() {
                        bExist = true
                        break
                    }
                }
                
                if !bExist{
                    m_eList.append(g_eTimeFilter[i])
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onUpdateRules(_ sender: Any) {
        performSegue(withIdentifier: "segueRules", sender: nil)
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTask(_ sender: UIButton) {
        let indexPath = getIndexPathOf(subview: sender, tableView: tableView)
        updateEvent(index: indexPath.row, isCategory: false)
    }
    
    @IBAction func onCategory(_ sender: UIButton) {
        let indexPath = getIndexPathOf(subview: sender, tableView: tableView)
        updateEvent(index: indexPath.row, isCategory: true)
    }
    
    func updateEvent(index: Int, isCategory: Bool){
        //let event = g_eTimeFilter[index]
        let taskList = (isCategory ? g_sCats : g_sTasks)
        let actionSheet = UIAlertController(title: "Choose correct item", message: "", preferredStyle: .actionSheet)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in print("Cancel") }
        actionSheet.addAction(cancelButton)
        
        for i in 0..<taskList.count{
            let action = UIAlertAction(title: taskList[i]["key"], style: .default){ _ in
                if(isCategory){
                    self.m_eList[index].sCategory = taskList[i]["key"]!
                    g_dicCustomSelCat[self.m_eList[index].sTitle.lowercased()] = taskList[i]["key"]!
                    saveCustomSelCat()
                }else{
                    self.m_eList[index].sTask = taskList[i]["key"]!
                    g_dicCustomSelTask[self.m_eList[index].sTitle.lowercased()] = taskList[i]["key"]!
                    saveCustomSelTask()
                }
                
                self.tableView.reloadData()
            }
            actionSheet.addAction(action)
        }
        
        present(actionSheet, animated: true, completion: nil)
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

extension ConfirmVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_eList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellEvent")!
        let lTitle = cell.viewWithTag(100) as! UILabel
        let bTask = cell.viewWithTag(101) as! UIButton
        let bCategory = cell.viewWithTag(102) as! UIButton
        
        let event = m_eList[indexPath.row]
        
        lTitle.text = event.sTitle
        
        let sTask = event.sTask
        bTask.setTitle(sTask, for:.normal)
        let sCategory = event.sCategory
        bCategory.setTitle(sCategory, for:.normal)
        return cell
    }
}
