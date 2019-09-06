//
//  RuleDetailVC.swift
//  CalendarAnalytics
//
//  Created by Lucky on 2018/10/12.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit

class RuleDetailVC: UIViewController {
    var isEdit = false
    var isCategory = true
    var index = -1
    
    var dicTypes : [[String: String]]!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfTrigger: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dicTypes = (isCategory ? g_sCats : g_sTasks)
        let sType = (isCategory ? "Category" : "Task")
        if isEdit{
            lblTitle.text = "Edit " + sType + " Rule"
            
            tfName.text = dicTypes[index]["key"]
            tfTrigger.text = dicTypes[index]["keywords"]
        }else{
            lblTitle.text = "Add New " + sType + " Rule"
        }
    }
    
    @IBAction func onOK(_ sender: Any) {
        let sName = tfName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let sTrigger = tfTrigger.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if sName == "" || sTrigger == ""{
            showOkAlert(title: "Error", msg: "Fields can't be empty or filled with whitespaces", vc: self)
            return
        }
        
        if checkSameName(name: sName){
            showOkAlert(title: "Error", msg: "There is already existing name '" + sName + "'", vc: self)
            return
        }
        
        let keywords = sTrigger.components(separatedBy: ",")
        var newKeywords = [String]()
        for i in 0..<keywords.count{
            let keyword = keywords[i].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if keyword == ""{
                continue
            }
            
            if let checkKey = checkSameKeyword(keyword: keyword, checkCategory: true){
                showOkAlert(title: "Error", msg: "Trigger word '\(keyword)' is already existing in Category, named '\(checkKey)'", vc: self)
                return
            }
            if let checkKey = checkSameKeyword(keyword: keyword, checkCategory: false){
                showOkAlert(title: "Error", msg: "Trigger word '\(keyword)' is already existing in Task, named '\(checkKey)'", vc: self)
                return
            }
            
            newKeywords.append(keyword)
        }
        
        if newKeywords.count <= 0{
            showOkAlert(title: "Error", msg: "Please input valid trigger words", vc: self)
            return
        }
        
        var sKeywords = newKeywords[0]
        for i in 1..<newKeywords.count{
            sKeywords += (g_sSep + newKeywords[i])
        }
        
        if isEdit{
            if(isCategory){
                g_sCats[index]["key"] = sName
                g_sCats[index]["keywords"] = sKeywords
            }else{
                g_sTasks[index]["key"] = sName
                g_sTasks[index]["keywords"] = sKeywords
            }
        }else{
            let newType = ["default":"NO", "key":sName, "keywords": sKeywords]
            if(isCategory){
                g_sCats.append(newType)
                saveCategories()
            }else{
                g_sTasks.append(newType)
                saveTasks()
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func checkSameName(name: String) -> Bool{
        for i in 0..<dicTypes.count{
            if i == index {
                continue
            }
            
            if dicTypes[i]["key"]?.lowercased() == name.lowercased(){
                return true
            }
        }
        return false
    }
    
    func checkSameKeyword(keyword: String, checkCategory: Bool)->String?{
        let types = (checkCategory ? g_sCats : g_sTasks)
        
        for i in 0..<types.count{
            if checkCategory == isCategory && i == index{
                continue
            }
            
            let type = types[i]
            let orgKeywords = type["keywords"]!.components(separatedBy: g_sSep)
            for j in 0..<orgKeywords.count{
                if keyword == orgKeywords[j].lowercased(){
                    return type["key"]
                }
            }
        }
        return nil
    }
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
