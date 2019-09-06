//
//  Global.swift
//  CalendarAnalytics
//
//  Created by Lucky on 2018/8/8.
//  Copyright © 2018 Lucky. All rights reserved.
//

import Foundation

import Foundation
import UIKit

let g_sSep = ","
let g_sizeScreen = UIScreen.main.bounds
var g_eTotal = [Event]()
var g_eTimeFilter = [Event]()
//Tasks - Things I commonly do for these tasks
var g_sTasksDefault = [
    ["default":"YES", "key":"Sales", "keywords":"meeting,drink,lunch,dinner,pitch,sales"],
    ["default":"YES", "key":"Marketing", "keywords": "presentation,education,powerpoint,lead,crm meeting,marketing"],
    ["default":"YES", "key":"Networking", "keywords": "event,cocktail,meetup,meet up,catchup,networking"],
    ["default":"YES", "key":"Research", "keywords": "deep dive,whitepaper,class,research"],
    ["default":"YES", "key":"Strategy", "keywords": "spitball,session,freeform discussion,strategy"]
]

var g_sCatsDefault = [
    ["default":"YES", "key":"Elevated", "keywords":"elevated,acceptance issurance"],
    ["default":"YES", "key":"Quiverr", "keywords":"quiverr"],
    ["default":"YES", "key":"Welk Resorts", "keywords":"welk"],
    ["default":"YES", "key":"Robinhood", "keywords":"robinhood,pureboost"],
    ["default":"YES", "key":"Sock Problems", "keywords":"sock problems"],
    ["default":"YES", "key":"Audacity", "keywords":"audacity"],
    ["default":"YES", "key":"SDSI", "keywords":"sdsi"],
]

var g_sTasks = [[String:String]]()
var g_sCats = [[String:String]]()

var g_dicCustomSelTask = [String:String]()
var g_dicCustomSelCat = [String:String]()

func saveTasks(){
    UserDefaults.standard.set(g_sTasks, forKey: "TASKS")
}

func saveCategories(){
    UserDefaults.standard.set(g_sCats, forKey: "CATS")
}

func saveCustomSelTask(){
    UserDefaults.standard.set(g_dicCustomSelTask, forKey: "TASKS_CUSTOM")
}
func saveCustomSelCat(){
    UserDefaults.standard.set(g_dicCustomSelCat, forKey: "CATS_CUSTOM")
}
func showOkAlert(title: String, msg: String, vc:UIViewController){
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    vc.present(alert, animated: true, completion: nil)
}

func validateEmail(email: String)->Bool{
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailTest.evaluate(with:email)
}

func getIndexPathOf(subview: UIView, tableView: UITableView) ->IndexPath{
    var view = subview
    while !(view is UITableViewCell) {
        view = view.superview!
    }
    return tableView.indexPath(for: view as! UITableViewCell)!
}

func setPadding(toTextField: UITextField, fLeft: CGFloat, fRight: CGFloat){
    toTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: fLeft, height: 0))
    toTextField.leftViewMode = .always
    
    toTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: fRight, height: 0))
    toTextField.rightViewMode = .always
}

func getDateFromString(dateString: String) -> Date{
    let dateFormatter = ISO8601DateFormatter()
    let date = dateFormatter.date(from:dateString)!
    
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
    let finalDate = calendar.date(from:components)
    
    return finalDate!
}

extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.1f", self)
    }
}
