//
//  ImportVC.swift
//  CalendarAnalytics
//
//  Created by Lucky on 2018/8/1.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn
import ProgressHUD

class ImportVC: UIViewController {
    @IBOutlet weak var lblImport: UILabel!
    @IBOutlet weak var tvCalendar: UITableView!
    
    let service = GTLRCalendarService()
    let scopes = [kGTLRAuthScopeCalendarReadonly]
    let kKeychainItemName = "Google Calendar API"
    let user = GIDSignIn.sharedInstance().currentUser!
    var calendars = [GTLRCalendar_CalendarListEntry]()
    var selected = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ProgressHUD.show("Loading Calendars", interaction: false)
        lblImport.text = user.profile.name + ", Import your calendar"
        
        fetchCalendar()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onImport(_ sender: Any) {
        var entry = [GTLRCalendar_CalendarListEntry]()
        for i in 0..<selected.count{
            if(selected[i]){
                entry.append(calendars[i]);
            }
        }
        
        if(entry.count > 0){
            performSegue(withIdentifier: "segueAnalytics", sender: entry)
        }else{
            showOkAlert(title: "Error", msg: "You need to select at least 1 calendar", vc: self)
        }
    }
    
    func fetchCalendar() {
        service.authorizer = user.authentication.fetcherAuthorizer()
        service.shouldFetchNextPages = true
        service.isRetryEnabled = true
        let query = GTLRCalendarQuery_CalendarListList.query()
        
        service.executeQuery(query) { (ticket, calendarList, error) in
            
            if error != nil{
                showOkAlert(title: "Error", msg: (error?.localizedDescription)!, vc: self)
                return
            }
            
            self.calendars = (calendarList as! GTLRCalendar_CalendarList).items!
            self.selected = [Bool](repeating: false, count: self.calendars.count)
            
            self.tvCalendar.reloadData()
            ProgressHUD.showSuccess()
        }
    }
    
    @IBAction func onLogout(_ sender: Any) {
        ProgressHUD.show("Log out")
        GIDSignIn.sharedInstance().disconnect();
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueAnalytics"{
            let vc = segue.destination as! AnalyticsVC
            vc.gtl_calendar = sender as? [GTLRCalendar_CalendarListEntry]
            vc.gtl_service = service
        }
    }

}

extension ImportVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCalendar")!
        let lblCalendar = cell.viewWithTag(100) as! UILabel
        lblCalendar.text = calendars[indexPath.row].summary
        
        if(selected[indexPath.row]){
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
//        cell.layer.cornerRadius = 30
//        cell.clipsToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.selected[indexPath.row] = !self.selected[indexPath.row]
        tableView.reloadData()
        //performSegue(withIdentifier: "segueAnalytics", sender: calendars[indexPath.row])
    }
}
