//
//  RulesVC.swift
//  CalendarAnalytics
//
//  Created by Lucky on 2018/8/5.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit

class RulesVC: UIViewController {
    @IBOutlet weak var tvRules: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        tvRules.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onUseSystemRules(_ sender: UISwitch) {
        /*if !sender.isOn{
            for event in g_sCats{
                if event["default"] == "YES"{
                    g_sCats.remove(at: g_sCats.firstIndex(of: event)!)
                }
            }
            for event in g_sTasks{
                if event["default"] == "YES"{
                    g_sTasks.remove(at: g_sTasks.firstIndex(of: event)!)
                }
            }
        }else{
            g_sCats.insert(contentsOf: g_sCatsDefault, at: 0)
            g_sTasks.insert(contentsOf: g_sTasksDefault, at: 0)
        }*/
        tvRules.reloadData()
    }
    @IBAction func onEdit(_ sender: UIButton) {
        let indexPath = getIndexPathOf(subview: sender, tableView: tvRules)
        performSegue(withIdentifier: "segueRuleDetail", sender: indexPath)
    }
    @IBAction func onDelete(_ sender: UIButton) {
        let indexPath = getIndexPathOf(subview: sender, tableView: tvRules)
        let alert = UIAlertController.init(title: "", message: "Are you sure to delete?", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "YES", style: .default) { (action) in
            if indexPath.section == 0{
                //delete category
                g_sCats.remove(at: indexPath.row)
                saveCategories()
            }else{
                //delete task
                g_sTasks.remove(at: indexPath.row)
                saveTasks()
            }
            self.tvRules.reloadData()
        }
        alert.addAction(okAction)
        let cancelAction = UIAlertAction.init(title: "NO", style: .cancel) { (action) in
            
        }
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueRuleDetail"{
            let vc = segue.destination as! RuleDetailVC
            let indexPath = sender as! IndexPath
            vc.index = indexPath.row
            if indexPath.section == 0{
                vc.isCategory = true
                if indexPath.row == g_sCats.count {
                    vc.isEdit = false
                }else{
                    vc.isEdit = true
                }
            }else{
                vc.isCategory = false
                if indexPath.row == g_sTasks.count{
                    vc.isEdit = false
                }else{
                    vc.isEdit = true
                }
            }
        }
    }
}

extension RulesVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Category Rules"
        }
        return "Task Rules"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return g_sCats.count + 1
        }
        return g_sTasks.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        
        if(indexPath.section == 0 && indexPath.row == g_sCats.count) || (indexPath.section == 1 && indexPath.row == g_sTasks.count){
            cell = tableView.dequeueReusableCell(withIdentifier: "cellAddRule")
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "cellRule")!
            
            let lblName = cell.viewWithTag(100) as! UILabel
            let lblTrigger = cell.viewWithTag(101) as! UILabel
            
            let types = (indexPath.section == 0 ? g_sCats : g_sTasks)
            lblName.text = types[indexPath.row]["key"]
            lblTrigger.text = types[indexPath.row]["keywords"]
            
            if types[indexPath.row]["default"] == "YES"{
                cell.backgroundColor = #colorLiteral(red: 1, green: 0.9176470588, blue: 0.918849349, alpha: 1)
            }else{
                cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //Add Rules
        if(indexPath.section == 0 && indexPath.row == g_sCats.count) || (indexPath.section == 1 && indexPath.row == g_sTasks.count){
            performSegue(withIdentifier: "segueRuleDetail", sender: indexPath)
        }
    }
    
}
