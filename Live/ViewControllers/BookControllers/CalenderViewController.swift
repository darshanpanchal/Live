//
//  CalenderViewController.swift
//  Live
//
//  Created by ITPATH on 5/1/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class CalenderViewController: UIViewController {

    @IBOutlet var objCalender:FSCalendar!
    @IBOutlet var tableViewCalender:UITableView!
    @IBOutlet var lblTimeSlots:UILabel!
    @IBOutlet var btnNext:UIButton!
    @IBOutlet var btnPrevious:UIButton!
    @IBOutlet var btnDone:UIButton!
    @IBOutlet var navTitleLbl:UILabel!
    @IBOutlet var heightOfCalendar:NSLayoutConstraint!
    @IBOutlet var heightOfFSCalendar:NSLayoutConstraint!
    @IBOutlet var topConstraintNext:NSLayoutConstraint!
    @IBOutlet var topConstraintPrevious:NSLayoutConstraint!
    @IBOutlet var buttonDoneHeight:NSLayoutConstraint!
    var unit: FSCalendarUnit! //at top of the controller
    let dateFormatter = DateFormatter()
    var arrayOfDateSlot:[DateSlot] = []
    var selectedDateSlot:DateSlot?
    var selectedDate:Date?
    let selectedDateFormat = DateFormatter()
    var objExperience:Experience?
    var tableViewHeaderHeight:CGFloat{
        return 424.0
    }
    var selectedIndex:Int = 0
    var isSelected:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.dateFormatter.dateStyle = .medium
//        self.selectedDateFormat.dateStyle = .medium
        self.dateFormatter.dateFormat = "MM/dd/yyyy"
        self.selectedDateFormat.dateFormat = "dd MMMM yyyy"
        //Configure FSCalender
        self.configureFSCalender()
        //Configure CurrentMonth
        self.configureCurrentMonth()
        //ConfigureTableView
        self.configureTableView()
        self.btnDone.setBackgroundColor(color:UIColor.lightGray.withAlphaComponent(0.5), forState: UIControlState.highlighted)
        self.lblTimeSlots.text = "Time slots (\(self.selectedDateFormat.string(from: self.selectedDate ?? Date())))"
        self.btnPrevious.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.btnPrevious.imageView?.tintColor = UIColor.init(hexString:"36527D")
        
        self.btnNext.setImage(#imageLiteral(resourceName: "next_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.btnNext.imageView?.tintColor = UIColor.init(hexString:"36527D")
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.addDynamicFont()
             UIApplication.shared.statusBarStyle = .default
            self.topConstraintNext.constant = 24.0//IsiPhone5 ? 14.0 : 24.0
            self.topConstraintPrevious.constant = 24.0//IsiPhone5 ? 14.0 : 24.0
            self.view.layoutIfNeeded()
        }
    }
    func addDynamicFont(){
        self.navTitleLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.navTitleLbl.adjustsFontForContentSizeCategory = true
        self.navTitleLbl.adjustsFontSizeToFitWidth = true
        
        self.lblTimeSlots.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblTimeSlots.adjustsFontForContentSizeCategory = true
        self.lblTimeSlots.adjustsFontSizeToFitWidth = true
        
        self.btnDone.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.btnDone.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnDone.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Selector Methods
    @IBAction func buttonNextSelector(sender:UIButton){
        self.unit = (objCalender.scope == FSCalendarScope.month) ? FSCalendarUnit.month : FSCalendarUnit.weekOfYear
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: objCalender.currentPage)
        self.btnPrevious.isHidden = false
        self.getOccurenceFrom(startDate: self.getFirstDate(objDate: nextMonth!), endDate: self.getLastDate(objDate: nextMonth!),isForCurrentMonth:false)
        self.objCalender.setCurrentPage(nextMonth!, animated: true)
    }
    @IBAction func buttonPreviousSelector(sender:UIButton){
        self.unit = (objCalender.scope == FSCalendarScope.month) ? FSCalendarUnit.month : FSCalendarUnit.weekOfYear
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: objCalender.currentPage)
        let currentYear = Calendar.current.date(byAdding: .year, value: 0, to: objCalender.currentPage)
        if currentYear?.year == Date().year{
            if previousMonth!.month == Date().month{
                self.btnPrevious.isHidden = true
            }
            guard previousMonth!.month >= Date().month else {
                return
            }
        }
        self.getOccurenceFrom(startDate: self.getFirstDate(objDate: previousMonth!), endDate: self.getLastDate(objDate: previousMonth!),isForCurrentMonth:false)
        self.objCalender.setCurrentPage(previousMonth!, animated: true)
    }
    @IBAction func buttonClearSelector(sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Custom Methods
    func configureTableView(){
        self.tableViewCalender.delegate = self
        self.tableViewCalender.dataSource = self
        self.tableViewCalender.reloadData()
        self.tableViewCalender.tableFooterView = UIView()
        self.tableViewCalender.separatorStyle = .none
    }
    func configureFSCalender(){
        self.objCalender.dataSource = self
        self.objCalender.delegate = self
        self.objCalender.placeholderType = .none
        self.objCalender.appearance.titleFont = UIFont.init(name:"Avenir-Roman", size: 14.0)
        self.objCalender.appearance.headerTitleFont = UIFont.init(name: "Avenir-Heavy", size: 17.0)
        self.objCalender.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 14.0)
//        self.objCalender.headerHeight = IsiPhone5 ? 50 : 70
//        self.objCalender.weekdayHeight = IsiPhone5 ? 40 : 50
//        self.heightOfCalendar.constant = UIScreen.main.bounds.height == 568.0 ? 300.0:360.0
        self.objCalender.reloadInputViews()
        
    }
    func configureCurrentMonth(){
        let comp: DateComponents = Calendar.current.dateComponents([.year, .month], from:self.selectedDate!)
        let startOfMonth = Calendar.current.date(from: comp)!
        
        var comps2 = DateComponents()
        comps2.month = 1
        comps2.day = -1
        let endOfMonth = Calendar.current.date(byAdding: comps2, to: startOfMonth)
        self.getOccurenceFrom(startDate: startOfMonth, endDate: endOfMonth!,isForCurrentMonth:true)
    }
    func configureCurrentDate(){
        self.objCalender.select(self.selectedDate)
        let dateSlot = self.arrayOfDateSlot.filter(){ $0.date == "\(self.dateFormatter.string(from: self.selectedDate!))"}
        if dateSlot.count > 0{
            self.selectedDateSlot = dateSlot.first
        }else{
            self.selectedDateSlot = nil
        }
    }
    func getFirstDate(objDate:Date)->Date{
        let comp: DateComponents = Calendar.current.dateComponents([.year, .month], from: objDate)
        let startOfMonth = Calendar.current.date(from: comp)!
        return startOfMonth
    }
    func getLastDate(objDate:Date)->Date{
        var comps2 = DateComponents()
        comps2.month = 1
        comps2.day = -1
        let endOfMonth = Calendar.current.date(byAdding: comps2, to: self.getFirstDate(objDate: objDate))
        return endOfMonth!
    }
    // MARK: - API Methods
    //Get Occurence Date
    func getOccurenceFrom(startDate:Date,endDate:Date,isForCurrentMonth:Bool){
        //let requestURL = "experience/3/native/occurrences?startdate=\(dateFormatter.string(from: startDate))&enddate=\(dateFormatter.string(from: endDate))"
        if let experience = self.objExperience,experience.id.count > 0{
            print(experience.id)
     
        let requestURL = "experience/\(experience.id)/native/occurrences?startdate=\(dateFormatter.string(from: startDate))&enddate=\(dateFormatter.string(from: endDate))"
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString: requestURL, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let arraySuccess = successDate["AvailableCalender"] as? [[String:Any]]{
                self.arrayOfDateSlot = []
                for dateObject in arraySuccess{
                    let objDateSlot = DateSlot.init(dateSlotDetail: dateObject)
                    self.arrayOfDateSlot.append(objDateSlot)
                }
                
                DispatchQueue.main.async {
                    if isForCurrentMonth{
                        self.configureCurrentDate()
                    }
                    self.objCalender.reloadData()
                    self.tableViewCalender.reloadData()
                }
            }else{
                DispatchQueue.main.async {
                    //ShowToast.show(toatMessage:kCommonError)
                }
            }
        }) { (responseFail) in
            if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
      }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
extension CalenderViewController:FSCalendarDelegate,FSCalendarDataSource{
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        return "-"
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateSlot = self.arrayOfDateSlot.filter(){ $0.date == "\(self.dateFormatter.string(from: date))"}
        if dateSlot.count > 0{
            self.selectedDateSlot = dateSlot.first
        }else{
            self.selectedDateSlot = nil
        }
        self.selectedDate = date
        DispatchQueue.main.async {
            self.lblTimeSlots.text = "Time slots (\(self.selectedDateFormat.string(from: self.selectedDate ?? Date())))"
            self.tableViewCalender.reloadData()
        }
    }
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
    
        if date.day < Date().day,date.month <= Date().month,date.year <= Date().year{
            return 0
        }else{
            let dateSlot = self.arrayOfDateSlot.filter(){ $0.date == "\(self.dateFormatter.string(from: date))"}
            return dateSlot.count
        }
    }
}
extension CalenderViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.removeMessageLabel()

        guard self.selectedDateSlot != nil else {
            self.lblTimeSlots.isHidden = true
            tableView.showMessageLabel(msg:"No time slots available on \(self.selectedDateFormat.string(from: self.selectedDate ?? Date()))", backgroundColor: .clear,headerHeight: self.tableViewHeaderHeight)
            if let _ = self.tableViewCalender.tableHeaderView{
                //self.tableViewCalender.tableHeaderView?.frame = CGRect.init(x: 0, y: 0, width: tableViewCalender.bounds.width, height: 0)
            }
            self.btnDone.isHidden = false
            self.buttonDoneHeight.constant = 52.0
            return 0
        }
        if self.selectedDateSlot!.slots.count > 0{
            self.lblTimeSlots.isHidden = false
            tableView.removeMessageLabel()
            if let _ = self.tableViewCalender.tableHeaderView{
                //self.tableViewCalender.tableHeaderView?.frame = CGRect.init(x: 0, y: 0, width: tableViewCalender.bounds.width, height: 40.0)
            }
        }else{
            self.lblTimeSlots.isHidden = true
            tableView.showMessageLabel(msg:"No time slots available on \(self.selectedDateFormat.string(from: self.selectedDate ?? Date()))", backgroundColor: .clear,headerHeight: self.tableViewHeaderHeight)
            if let _ = self.tableViewCalender.tableHeaderView{
                //self.tableViewCalender.tableHeaderView?.frame = CGRect.init(x: 0, y: 0, width: tableViewCalender.bounds.width, height: 0.0)
            }
        }
        if self.selectedDateSlot!.slots.count > 0{
            self.buttonDoneHeight.constant = 0.0
        }else{
            self.buttonDoneHeight.constant = 52.0
        }
        self.btnDone.isHidden = self.selectedDateSlot!.slots.count > 0
        return self.selectedDateSlot!.slots.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"TimeSlotTableViewCell") as? TimeSlotTableViewCell
        let objSlot:Slot = self.selectedDateSlot!.slots[indexPath.row]
//        cell.textLabel?.text = "\(objSlot.slotTime) (\(objSlot.slotsAvaibility) slots available)"
//        cell.selectionStyle = .none
        cell!.imageSelect.isHidden = false
        let strTime = (objSlot.isCustomTime) ? "\(Vocabulary.getWordFromKey(key:"Custom"))":"\(objSlot.slotTime)".converTo12hoursFormate()
        if self.isSelected{
            cell!.imageSelect.image = (self.selectedIndex == indexPath.row) ? #imageLiteral(resourceName: "check_update") : #imageLiteral(resourceName: "uncheck_update")
        }else{
            cell!.imageSelect.image = #imageLiteral(resourceName: "uncheck_update")
        }
        cell!.lblTimeSlot.text = "Available time: \(strTime)"
        cell!.lblAvailablePerson.text = "Maximum people: \(objSlot.slotsAvaibility)"
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.isSelected = true
        DispatchQueue.main.async {
            self.tableViewCalender.reloadData()
            
            self.performSegue(withIdentifier: "unwindFromBookingViewController", sender: nil)
        }
    }
}
extension Date {
    var day:Int {return Calendar.current.component(.day, from:self)}
    var month:Int {return Calendar.current.component(.month, from:self)}
    var year:Int {return Calendar.current.component(.year, from:self)}
}
class DateSlot:NSObject{
    fileprivate let kDate = "Date"
    fileprivate let kTimes = "Times"
    var date:String = ""
    var slots:[Slot] = []
    var dateFormatter = DateFormatter()
    init(dateSlotDetail:[String:Any]) {
        super.init()
        if let strDate = dateSlotDetail[kDate]{
            self.dateFormatter.dateFormat = "MM/dd/yyyy"
            let strDate = "\(strDate)"
            if let objDate = self.dateFormatter.date(from: strDate){
                self.date = "\(self.dateFormatter.string(from:objDate))"
            }
        }
        if let times = dateSlotDetail[kTimes] as? [[String:Any]]{
            slots = []
            for time in times{
                let objSlot = Slot.init(slotDetail:time)
                slots.append(objSlot)
            }
        }
    }
}
class Slot:NSObject{
    fileprivate let kSlots = "Slots"
    fileprivate let kTime = "Time"
    
    var slotsAvaibility = ""
    var slotTime = ""
    var isCustomTime:Bool = false
    init(slotDetail:[String:Any]){
        if let strSlot = slotDetail[kSlots]{
            self.slotsAvaibility = "\(strSlot)"
        }
        if let strTime = slotDetail[kTime]{
             self.slotTime = "\(strTime)"
            if "\(strTime)" == "None"{
                self.isCustomTime = true
            }else{
               self.isCustomTime = false
            }
        }
    }
}
