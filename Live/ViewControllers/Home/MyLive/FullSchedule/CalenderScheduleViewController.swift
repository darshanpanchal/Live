//
//  CalenderScheduleViewController.swift
//  Live
//
//  Created by IPS on 30/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class CalenderScheduleViewController: UIViewController {

    @IBOutlet var objCalender:FSCalendar!
    @IBOutlet var tableViewCalender:UITableView!
    @IBOutlet var btnNext:UIButton!
    @IBOutlet var btnPrevious:UIButton!
    @IBOutlet var lblTours:UILabel!
    @IBOutlet var heightOfCalendar:NSLayoutConstraint!
    @IBOutlet var topConstraintNext:NSLayoutConstraint!
    @IBOutlet var topConstraintPrevious:NSLayoutConstraint!
    var unit: FSCalendarUnit! //at top of the controller
    let dateFormatter = DateFormatter()
    var arrayOfSchedule:[Schedule] = []
    var selectedSchedules:[Schedule] = []
    var selectedDate:Date = Date()
    let selectedDateFormat = DateFormatter()
    let updateDateFormate = DateFormatter()
    var tableViewHeaderHeight:CGFloat{
        return 424.0
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.dateFormatter.dateFormat = "MM/dd/yyyy"
        self.selectedDateFormat.dateFormat = "dd MMM yyyy"
        self.updateDateFormate.dateFormat = "dd MMM yyyy"
        //Configure FSCalender
        self.configureFSCalender()
        
        //ConfigureTableView
        self.configureTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            
            self.topConstraintNext.constant = 24.0//IsiPhone5 ? 14.0 : 24.0
            self.topConstraintPrevious.constant = 24.0//IsiPhone5 ? 14.0 : 24.0
            self.view.layoutIfNeeded()
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.lblTours.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblTours.adjustsFontForContentSizeCategory = true
        self.lblTours.adjustsFontSizeToFitWidth = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Configure CurrentMonth
        self.configureCurrentMonth()
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
        self.getCalenderExperiences(startDate: self.getFirstDate(objDate: nextMonth!), endDate: self.getLastDate(objDate: nextMonth!),isForCurrentMonth:false)
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
        self.getCalenderExperiences(startDate: self.getFirstDate(objDate: previousMonth!), endDate: self.getLastDate(objDate: previousMonth!),isForCurrentMonth:previousMonth!.month == Date().month)
        self.objCalender.setCurrentPage(previousMonth!, animated: true)
    }
    @IBAction func buttonClearSelector(sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - API request Meethods
    func getCalenderExperiences(startDate:Date,endDate:Date,isForCurrentMonth:Bool){
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            //{{baseUrl}}/api/experience/native/guide/29/schedule?start=2018-06-01&end=2028-06-01
            let requestURLUpcomingExperience = kExperiencePendingSchedule+"\(currentUser.userID)/schedule/calendar?start=\(dateFormatter.string(from:startDate))&end=\(dateFormatter.string(from: endDate))"
            //GetUpcomingExperience
            APIRequestClient.shared.sendRequest(requestType: .GET, queryString: "\(requestURLUpcomingExperience)", parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let arrayOfUpcomingSchedule = successData["Result"] as? [[String:Any]]{
                    DispatchQueue.main.async {
                        self.arrayOfSchedule = []
                        for pendingSchedule in arrayOfUpcomingSchedule{
                            let objExperience = Schedule.init(scheduleDetail: pendingSchedule)
                            self.arrayOfSchedule.append(objExperience)
                        }
                        if isForCurrentMonth{
                             self.selectedDate = Date()
                            self.configureCurrentDate()
                        }else{
                            //self.selectedSchedules = self.arrayOfSchedule
                        }
                        DispatchQueue.main.async {
                            self.objCalender.reloadData()
                            self.tableViewCalender.reloadData()
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        //ShowToast.show(toatMessage:kCommonError)
                    }
                }
                
            }, fail: { (responseFail) in
                if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: "\(errorMessage)")
                    }
                }else{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:kCommonError)
                    }
                }
            })
        }
    }
    // MARK: - Custom Methods
    func configureTableView(){
        let objScheduleNib = UINib.init(nibName: "PendingScheduleTableViewCell", bundle: nil)
        self.tableViewCalender.register(objScheduleNib, forCellReuseIdentifier: "PendingScheduleTableViewCell")
        
        self.tableViewCalender.delegate = self
        self.tableViewCalender.dataSource = self
        self.tableViewCalender.reloadData()
        //self.tableViewCalender.tableHeaderView = UIView()
        self.tableViewCalender.tableFooterView = UIView()
        self.tableViewCalender.separatorStyle = .none

    }
    func configureFSCalender(){
        self.objCalender.dataSource = self
        self.objCalender.delegate = self
        self.objCalender.placeholderType = .none
        self.btnPrevious.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.btnPrevious.imageView?.tintColor = UIColor.init(hexString:"36527D")
        
        self.btnNext.setImage(#imageLiteral(resourceName: "next_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.btnNext.imageView?.tintColor = UIColor.init(hexString:"36527D")
   
        self.objCalender.appearance.titleFont = UIFont.init(name:"Avenir-Roman", size: 14.0)
        self.objCalender.appearance.headerTitleFont = UIFont.init(name: "Avenir-Heavy", size: 17.0)
        self.objCalender.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 14.0)
//        self.objCalender.headerHeight = IsiPhone5 ? 50 : 70
//        self.objCalender.weekdayHeight = IsiPhone5 ? 40 : 50
//        self.heightOfCalendar.constant = UIScreen.main.bounds.height == 568.0 ? 300.0:360.0
        self.objCalender.reloadInputViews()
    }
    func configureCurrentMonth(){
        let comp: DateComponents = Calendar.current.dateComponents([.year, .month], from:self.selectedDate)
        let startOfMonth = Calendar.current.date(from: comp)!
        
        var comps2 = DateComponents()
        comps2.month = 1
        comps2.day = -1
        let endOfMonth = Calendar.current.date(byAdding: comps2, to: startOfMonth)
        self.getCalenderExperiences(startDate: startOfMonth, endDate: endOfMonth!,isForCurrentMonth:true)
    }
    func configureCurrentDate(){
        
        self.objCalender.select(self.selectedDate)
        self.selectedSchedules = []
        let dateSlot = self.arrayOfSchedule.filter(){ "\($0.bookingDate.changeDateFormatCalender)" == "\(self.selectedDateFormat.string(from: self.selectedDate))"}
        self.selectedSchedules = dateSlot
        self.tableViewCalender.reloadData()
        self.objCalender.reloadData()
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
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
extension CalenderScheduleViewController:FSCalendarDelegate,FSCalendarDataSource{
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.selectedDate = date
        self.configureCurrentDate()

    }
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if date.day < Date().day,date.month <= Date().month,date.year <= Date().year{
            return 0
        }
        print("\(self.selectedDateFormat.string(from: date))")
//        for slot in self.arrayOfSchedule{
//            print("Slot Date \(slot.bookingDate.changeDateFormatCalender) Selected date \(self.selectedDateFormat.string(from: date))")
//
//            if "\(slot.bookingDate.changeDateFormatCalender)" == "\(self.selectedDateFormat.string(from: date))"{
//                return 1
//            }else{
//                return 0
//            }
//        }
        let dateSlot = self.arrayOfSchedule.filter(){ "\($0.bookingDate.changeDateFormatCalender)" == "\(self.selectedDateFormat.string(from: date))"}
        if dateSlot.count > 0{
            return 1
        }else{
            return 0
        }
        return 0
    }
}
extension CalenderScheduleViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let calenderscheduleCell :PendingScheduleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PendingScheduleTableViewCell", for: indexPath) as! PendingScheduleTableViewCell
        guard self.selectedSchedules.count > indexPath.row else {
            return calenderscheduleCell
        }
        
        
        let objSchedule = self.selectedSchedules[indexPath.row]
        let strMutableString = NSMutableAttributedString.init(string: "(\(objSchedule.status)) " + "\(objSchedule.bookingDate.changeDateFormatCalender) - \(objSchedule.time.changeTimeformat)")
        let attributes:[NSAttributedStringKey : Any]
            = [NSAttributedStringKey.foregroundColor:self.getStatusColor(strStatus:"\(objSchedule.status)") as Any]
        
        strMutableString.addAttributes(attributes, range:NSRange(location:0,length:"\(objSchedule.status)".count+2) )
        calenderscheduleCell.lblStatus.text = "\(objSchedule.status.compareCaseInsensitive(str:"\(Vocabulary.getWordFromKey(key: "confirmed"))".firstUppercased) ? Vocabulary.getWordFromKey(key: "confirmed").firstUppercased:"\(objSchedule.status)".firstUppercased) "
        //calenderscheduleCell.lblLeadingConstraont.constant = 104.0
        calenderscheduleCell.lblStatus.textColor = self.getStatusColor(strStatus:"\(objSchedule.status)")
        let statusWithColor:(String,UIColor) = self.getStatusForGuideWithColor(status: "\(objSchedule.status)")
        calenderscheduleCell.lblStatus.text = objSchedule.isInstantBooking ? "  \(statusWithColor.0)" : "\(statusWithColor.0)"
        calenderscheduleCell.lblStatus.textColor = statusWithColor.1
        calenderscheduleCell.lblScheduledate.text = "\(objSchedule.time.changeTimeformat), \(objSchedule.bookingDate.changeDateFormat)"
        //calenderscheduleCell.lblScheduledate.attributedText = strMutableString
        calenderscheduleCell.lblScheduleTitle.text = "\(objSchedule.title)"
        calenderscheduleCell.lblUserName.text = "\(objSchedule.userName)"
        calenderscheduleCell.numberOfPerson.text = "\(objSchedule.slots)" + " \(Vocabulary.getWordFromKey(key: "people"))"
        calenderscheduleCell.tag = indexPath.row
        calenderscheduleCell.viewContainerSelectorContainer.isHidden = true
        calenderscheduleCell.buttonCancelOnly.isHidden = true
        return calenderscheduleCell
    }
    func getStatusColor(strStatus:String)->UIColor{
        if strStatus.compareCaseInsensitive(str: "\(Vocabulary.getWordFromKey(key: "confirmed"))"){
            return UIColor.init(hexString:"367D4A")
        }else if strStatus.compareCaseInsensitive(str:"\(Vocabulary.getWordFromKey(key: "pending"))"){
            return UIColor.init(hexString:"FF3B30")//FF3B30
        }else{
            return UIColor.init(hexString:"FF3B30")
        }
    }
    func getStatusForGuideWithColor(status:String)->(String,UIColor){
        if(status == "RequestedByTraveler"){
            return ("By Traveller",UIColor.init(hexString: "36527D"))
        }else if(status == "RequestedByGuide"){
            return ("Requested",UIColor.init(hexString:"FF3B30"))
        }else if(status == "Canceled"){
            return (status,UIColor.init(hexString:"FF3B30"))
        }else{
            return (status,UIColor.init(hexString:"367D4A")) //Accepted Confirmed
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedSchedules.count > 0 {
            self.lblTours.isHidden = false
            self.lblTours.text = "Tours (\(self.selectedDateFormat.string(from: self.selectedDate)))"
            tableView.removeMessageLabel()
        }else{
            self.lblTours.isHidden = true
            tableView.showMessageLabel(msg:"No Tours (\(self.selectedDateFormat.string(from: self.selectedDate)))", backgroundColor: .clear,headerHeight: self.tableViewHeaderHeight)
        }
        return self.selectedSchedules.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190.0
    }
}
