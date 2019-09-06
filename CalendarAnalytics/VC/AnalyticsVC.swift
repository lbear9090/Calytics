//
//  AnalyticsVC.swift
//  CalendarAnalytics
//
//  Created by Lucky on 2018/8/2.
//  Copyright © 2018 Lucky. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn
import ProgressHUD

class AnalyticsVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewPeriod: UIVisualEffectView!
    @IBOutlet weak var tfFrom: UITextField!
    @IBOutlet weak var tfTo: UITextField!
    
    var gtl_calendar : [GTLRCalendar_CalendarListEntry]!
    var gtl_service : GTLRCalendarService!
    var gtl_events = [GTLRCalendar_Event]()
    
    //var m_nCellCnt = 0
    
    var m_nTotalMins = 0.0
    var m_nTotalBooking = 0.0
    var m_nTotalMeets = 0
    var m_nTotalCalls = 0.0
    //Grouped Events
    var m_eByCategory = [EventGroup]()
    var m_eByTask = [EventGroup]()
    
    //Fetch date when imported the calendar
    var m_dFetch = Date()
    
    //Filter date from Start to End
    var m_dStart = Date()
    var m_dEnd = Date()
    
    var m_sPeriod = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        m_dStart = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        m_dEnd = Date()
        m_sPeriod = "Last 30 days"
        
        setupUI()
        
        ProgressHUD.show("Loading Events", interaction: true)
        gtl_events.removeAll()
        fetchEvent(index: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        if g_eTimeFilter.count > 0 {
            parseEvents(dStart: m_dStart, dEnd: m_dEnd)
        }
    }
    
    func setupUI(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let sDate = dateFormatter.string(from: Date())
        
        let dPickerFrom = UIDatePicker()
        dPickerFrom.datePickerMode = .date
        dPickerFrom.tag = 100
        tfFrom.inputView = dPickerFrom
        tfFrom.text = sDate
        dPickerFrom.addTarget(self, action: #selector(onDate), for: .valueChanged)
        
        let dPickerTo = UIDatePicker()
        dPickerTo.datePickerMode = .date
        dPickerTo.tag = 101
        tfTo.inputView = dPickerTo
        tfTo.text = sDate
        dPickerTo.addTarget(self, action: #selector(onDate), for: .valueChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchEvent(index: Int){
        ProgressHUD.show("Loading Event", interaction: true)
        let calendarID = gtl_calendar[index].identifier! //Can use "primary" for default id
        let eventQuery = GTLRCalendarQuery_EventsList.query(withCalendarId: calendarID)
        eventQuery.singleEvents = true
        eventQuery.timeMin = GTLRDateTime(date: Calendar.current.date(byAdding: .month, value: -6, to: Date())!)
        eventQuery.timeMax = GTLRDateTime(date: Date())//GTLRDateTime(date: Calendar.current.date(byAdding: .month, value: 1, to: Date())!)
        eventQuery.orderBy = kGTLRCalendarOrderByStartTime
        gtl_service.executeQuery(eventQuery) { (ticket, eventList, error) in
            if error != nil{
                //ProgressHUD.showError(error?.localizedDescription)
            }else{
                self.gtl_events.append(contentsOf: (eventList as! GTLRCalendar_Events).items!)
            }
            
            if index < self.gtl_calendar.count - 1{
                self.fetchEvent(index: index + 1)
            }else{
                //self.m_nCellCnt = 1
                self.m_dFetch = Date()
                self.getEventsTotal()
                self.parseEvents(dStart: self.m_dStart, dEnd: self.m_dEnd)
                ProgressHUD.showSuccess()
            }
        }
    }

    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onConfirm(_ sender: Any) {
        performSegue(withIdentifier: "segueConfirm", sender: nil)
    }
    
    func getEventsTotal(){
        g_eTotal.removeAll()
        
        for gtlEvent in gtl_events{
            let event = parseEvent(gtlEvent: gtlEvent)
            if event != nil{
                g_eTotal.append(event!)
            }
        }
    }
    
    func parseEvents(dStart:Date, dEnd:Date){
        g_eTimeFilter.removeAll()
        
        for event in g_eTotal{
            if (dStart.compare(event.dateStart) != .orderedDescending) && (dEnd.compare(event.dateEnd) != .orderedAscending){
                g_eTimeFilter.append(event)
            }
        }
        
        m_eByCategory = deployEvents(events: g_eTimeFilter, isCategory: true)
        m_eByTask = deployEvents(events: g_eTimeFilter, isCategory: false)
        
        calcTotal(events: g_eTimeFilter)
        self.tableView.reloadData()
    }
    
    func calcTotal(events:[Event]){
        m_nTotalMins = 0
        m_nTotalBooking = 0
        m_nTotalMeets = 0
        m_nTotalCalls = 0
        for event in events{
            m_nTotalMins += event.nDuration
            let title = event.sTitle.lowercased()
            if title.contains("call"){
                m_nTotalCalls += event.nDuration
            }else{
                m_nTotalBooking += event.nDuration
            }
            if title.contains("meet"){
                m_nTotalMeets += 1
            }
        }
    }
    
    func parseEvent(gtlEvent : GTLRCalendar_Event)->Event?{
        let event = Event()
        
        var startTime = gtlEvent.start?.dateTime?.date
        var endTime = gtlEvent.end?.dateTime?.date
        if startTime == nil{
            startTime = gtlEvent.start?.date?.date
        }
        if endTime == nil{
            endTime = gtlEvent.end?.date?.date
        }
        
        if(startTime == nil || endTime == nil){
            return nil
        }
        
        let difMin = Calendar.current.dateComponents([.minute], from: startTime!, to: endTime!)
        
        event.dateStart = startTime!
        event.dateEnd = endTime!
        event.nDuration = Double(difMin.minute!)
        
        event.sTitle = (gtlEvent.summary ?? "N/A").trimmingCharacters(in: .whitespacesAndNewlines)
        
        let title = event.sTitle.lowercased()
        //Parse Task
        for task in g_sTasks{
            let keywords = task["keywords"]!.components(separatedBy: g_sSep)
            var bSelected = false
            for keyword in keywords{
                if title.contains(keyword.lowercased()){
                    event.sTask = task["key"]!
                    bSelected = true
                    break
                }
            }
            if bSelected{
                break
            }
        }
        
        //Parse Category
        for category in g_sCats{
            let keywords = category["keywords"]!.components(separatedBy: g_sSep)
            var bSelected = false
            for keyword in keywords{
                if title.contains(keyword.lowercased()){
                    event.sCategory = category["key"]!
                    bSelected = true
                    break
                }
            }
            if bSelected{
                break
            }
        }
        return event
    }
    
    func deployEvents(events: [Event], isCategory: Bool) -> [EventGroup]{
        var eventGroups = [EventGroup]()
        for event in events{
            var sCategory = (isCategory ? event.sCategory : event.sTask)
            
            //Set user selected custom keyname
            let customCategory = (isCategory ? g_dicCustomSelCat[event.sTitle.lowercased()] ?? "" : g_dicCustomSelTask[event.sTitle.lowercased()] ?? "")
            if customCategory != ""{
                sCategory = customCategory
            }
            
            var eventGroup = EventGroup()
            var foundGroup = false
            for eg in eventGroups{
                if(eg.title == sCategory){
                    eventGroup = eg
                    foundGroup = true
                    break
                }
            }
            
            eventGroup.events.append(event)
            eventGroup.title = sCategory
            eventGroup.totalDuration += event.nDuration
            
            if !foundGroup {
                eventGroups.append(eventGroup)
            }
        }
        
        eventGroups.sort { (eg1, eg2) -> Bool in
            eg1.totalDuration > eg2.totalDuration
        }
        return eventGroups
    }
    
    @IBAction func onImportNewData(_ sender: Any) {
        ProgressHUD.show("Loading Events", interaction: true)
        gtl_events.removeAll()
        fetchEvent(index: 0)
    }
    
    @IBAction func onDays(_ sender: UIButton) {
        var days = 30
        if sender.tag == 1000{
            //7 days
            days = 7
        }else if sender.tag == 1001{
            //30 days
            days = 30
        }else if sender.tag == 1002{
            //90 days
            days = 90
        }
        m_sPeriod = "Last \(days) days"
        m_dStart = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        m_dEnd = Date()
        parseEvents(dStart: m_dStart, dEnd: m_dEnd)
    }
    @IBAction func onDaysCustom(_ sender: Any) {
        viewPeriod.isHidden = false
    }
    
    @IBAction func onPeriodOk(_ sender: Any) {
        view.endEditing(true)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        if tfFrom.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || tfTo.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showOkAlert(title: "Error", msg: "Please fill select all dates", vc: self)
            return
        }
        let dStart = dateFormatter.date(from: tfFrom.text!)!
        let dEnd = dateFormatter.date(from: tfTo.text!)!
        
        //if start date is later than end date
        if dStart.compare(dEnd) == .orderedDescending{
            showOkAlert(title: "Error", msg: "From date have to be before than To date", vc: self)
            return
        }
        if dEnd.compare(Date()) == .orderedDescending{
            showOkAlert(title: "Error", msg: "To date can't be future date", vc: self)
            return
        }
        
        if dStart.compare(Calendar.current.date(byAdding: .month, value: -6, to: Date())!) == .orderedAscending{
            showOkAlert(title: "Error", msg: "From date is limited to 6 months", vc: self)
            return
        }
        
        m_dStart = dStart
        m_dEnd = dEnd
        
        m_sPeriod = tfFrom.text! + " - " + tfTo.text!
        parseEvents(dStart: m_dStart, dEnd: m_dEnd)
        viewPeriod.isHidden = true
    }
    @IBAction func onPeriodCancel(_ sender: Any) {
        view.endEditing(true)
        viewPeriod.isHidden = true
    }
    
    @IBAction func onDate(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        if(sender.tag == 100){ //From
            tfFrom.text = dateFormatter.string(from: sender.date)
        }else if(sender.tag == 101){ //To
            tfTo.text = dateFormatter.string(from: sender.date)
        }
        
    }

    // MARK: -  Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "segueConfirm"){
            let vc = segue.destination as! ConfirmVC
            vc.analyticsVC = self
        }
    }
}

extension AnalyticsVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellAnal") as! AnalyticsTVCell
        
        //cell.lblTotal.text = "Since you have logged in last, we have imported " + String(gtl_events.count) + " new calendar meetings"
        //cell.lblTotal.text = "We've imported " + String(gtl_events.count) + " calendar meetings"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        cell.lblTotal.text = "The last time we imported your calendar was " + dateFormatter.string(from: m_dFetch) + " at " + timeFormatter.string(from: m_dFetch)
        
        cell.lblPeriod.text = "Current View Time Period: " + m_sPeriod
        
        cell.lblBookedHours.text = (m_nTotalBooking/60).clean + " Hours"
        cell.lblMeetings.text = String(m_nTotalMeets) + " Meetings"
        cell.lblCalls.text = (m_nTotalCalls/60).clean + " Hours"
        
        var sText = ""
        for i in 0..<m_eByCategory.count{
            let eventGroup = m_eByCategory[i]

            let s = String(i+1) + ".\t" + eventGroup.title + "   " + (eventGroup.totalDuration*100.0/m_nTotalMins).clean + "%   " + (eventGroup.totalDuration / 60.0).clean + " hours\n"
            sText += s
        }
        //cell.lblCategory.text = sText
        cell.txtCategory.text = sText
        cell.setChartData(isCategory: true, eventGroups: m_eByCategory)
        
        sText = ""
        for i in 0..<m_eByTask.count{
            let eventGroup = m_eByTask[i]
            let s = String(i+1) + ".\t" + eventGroup.title + "   " + (eventGroup.totalDuration*100.0/m_nTotalMins).clean + "%   " + (eventGroup.totalDuration/60.0).clean + " hours\n"
            sText += s
        }
        //cell.lblTask.text = sText
        cell.txtTask.text = sText
        cell.setChartData(isCategory: false, eventGroups: m_eByTask)
        return cell
    }
}
