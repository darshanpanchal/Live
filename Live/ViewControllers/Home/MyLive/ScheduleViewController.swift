//
//  ScheduleViewController.swift
//  Live
//
//  Created by IPS on 23/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
enum ScheduleType {
    case Free
    case Once
    case Daily
    case Weekly
    case Weekdays
    case Monthly
}
class ScheduleViewController: UIViewController {

    fileprivate  var kRecurrence = "Recurrence"
    fileprivate  var kRecurrenceDay = "RecurrenceDays"
    fileprivate  var kStartDate = "StartDate"
    fileprivate  var kEndDate = "EndDate"
    
    fileprivate  var kTime = "Time"
    @IBOutlet var navTitle:UILabel!
    @IBOutlet var tableViewSchedule:UITableView!
    @IBOutlet var buttonBack:UIButton!
    @IBOutlet var buttonAddSchedule:RoundButton!
    @IBOutlet var buttonForgroundShadow:UIButton!
    
    var addedInputSet:NSMutableSet = NSMutableSet()
    var addScheduleParameters:[String:Any] = [:]
    var type:ScheduleType = .Once
    var scheduleType:ScheduleType{
        get{
            return type
        }
        set{
            type = newValue
            //ConfigureNewType
            self.configureScheduleType()
        }
    }
    var arrayOfScheduleTypes:[String] = ["\(Vocabulary.getWordFromKey(key:"Custom"))","\(Vocabulary.getWordFromKey(key:"Once"))","\(Vocabulary.getWordFromKey(key:"Daily"))","\(Vocabulary.getWordFromKey(key:"Weekly"))","\(Vocabulary.getWordFromKey(key:"Weekdays"))","\(Vocabulary.getWordFromKey(key:"Monthly"))"]
    var arrayOfWeekDays:[String] = ["\(Vocabulary.getWordFromKey(key:"Monday"))","\(Vocabulary.getWordFromKey(key:"Tuesday"))","\(Vocabulary.getWordFromKey(key:"Wednesday"))","\(Vocabulary.getWordFromKey(key:"Thursday"))","\(Vocabulary.getWordFromKey(key:"Friday"))","\(Vocabulary.getWordFromKey(key:"Saturday"))","\(Vocabulary.getWordFromKey(key:"Sunday"))"]
    
    var selectedOccurence:String = ""
    var strTempOccurence:String = ""
    var selectdDaysOfFree:String = ""
    var selectedTime:String = ""
    var selectedDate:String = ""
    var selectedWeekDay:String = ""
    var strTempWeekDay:String = ""
    var selectedDayOfMonth:String = ""
    var strStartDate:String = ""
    var strEndDate:String = ""
    
    var scheduleDetail:TextFieldDetail?
    var freeScheduleDaysDetail:TextFieldDetail?
    var timeDetail:TextFieldDetail?
    var dateDetail:TextFieldDetail?
    var weekDetail:TextFieldDetail?
    var dayOfMonthDetail:TextFieldDetail?
    var startDate:TextFieldDetail?
    var endDate:TextFieldDetail?
    
    var arrayOfOccurence:[TextFieldDetail] = []
    var tableViewHeight:CGFloat{
        return 88.0
    }
    var timePicker:UIDatePicker = UIDatePicker()
    var timeToolBar:UIToolbar = UIToolbar()
    var datePicker:UIDatePicker = UIDatePicker()
    var dateToolBar:UIToolbar = UIToolbar()
    var endDatePicker:UIDatePicker = UIDatePicker()
    var endDateToolBar:UIToolbar = UIToolbar()
    
    var dateFormatter:DateFormatter = DateFormatter()
    var dayOfMonthPickerView:UIPickerView = UIPickerView()
    var dayToolBar:UIToolbar = UIToolbar()
    var occurencePicker:UIPickerView = UIPickerView()
    var occurenceToolBar:UIToolbar = UIToolbar()
    var weekDayPicker:UIPickerView = UIPickerView()
    var weekDayToolBar:UIToolbar = UIToolbar()
    var selectedDayTag:Int = 0
    var arrayOfDaysOfMonth:[Int] =  [Int](1...31)
    var isFreeScheduleNoTime:Bool = false
    var isOnceScheduleNoTime:Bool = false
    var isMonthlyScheduleNoTime:Bool = false
    var isFirstLoad:Bool = true
    var selectedDates:[Date] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonBack.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), for: .normal)
        self.buttonBack.imageView?.tintColor = UIColor.black
        self.buttonBack.imageView?.contentMode = .scaleAspectFit
        // Do any additional setup after loading the view.
        //ConfigureSchedule
        self.buttonAddSchedule.setTitle(Vocabulary.getWordFromKey(key: "addSchedule"), for: .normal)
        self.navTitle.text = Vocabulary.getWordFromKey(key: "newSchedule")
        self.configureScheduleType()
        self.configureScheduleView()
        self.configureDurationPicker()
        self.configureDatePicker()
        self.configureEndDatePicker()
        
        self.configureDayOfMonthPicker()
        self.configureOccurencePicker()
        self.configureWeeklyPicker()
        //self.selectedOccurence = "\(Vocabulary.getWordFromKey(key: "Daily"))"
        self.scheduleType = .Daily
        self.buttonAddScheduleEnable(isEnable: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
             self.buttonForgroundShadow.isHidden = true
            self.addDynamicFont()
           self.strTempOccurence = "\(Vocabulary.getWordFromKey(key:"Custom"))"
          self.strTempWeekDay = Vocabulary.getWordFromKey(key:"Monday")
        }
    }
    func buttonAddScheduleEnable(isEnable:Bool){
        if isEnable{
            self.buttonAddSchedule.backgroundColor = UIColor.init(hexString: "#36527D")
        }else{
            self.buttonAddSchedule.backgroundColor = UIColor.init(hexString: "#B2B2B2")
        }
        self.buttonAddSchedule.isEnabled = isEnable
    }
    func addDynamicFont(){
        self.navTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.navTitle.adjustsFontForContentSizeCategory = true
        self.navTitle.adjustsFontSizeToFitWidth = true
        
        self.buttonAddSchedule.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonAddSchedule.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonAddSchedule.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
    func isValidAddSchedule()->Bool{
        let scheduleCell:LogInTableViewCell = self.tableViewSchedule.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! LogInTableViewCell
        if let _ = self.scheduleDetail{
            guard scheduleDetail!.text.count > 0 else{
                DispatchQueue.main.async {
                    self.invalidTextField(textField: scheduleCell.textFieldLogIn)
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"scheduleType"))
                }
                return false
            }
            
        }
        if self.scheduleType == .Free{
            if let dateCell:LogInTableViewCell = self.tableViewSchedule.cellForRow(at: IndexPath.init(row: 1, section: 0)) as? LogInTableViewCell{
                if let _ = self.dateDetail{
                    guard self.dateDetail!.text.count > 0 else{
                        DispatchQueue.main.async {
                            self.invalidTextField(textField: dateCell.textFieldLogIn)
                            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"scheduleDate"))
                        }
                        return false
                    }
                }
            }
            if self.arrayOfOccurence.count > 1,!self.isFreeScheduleNoTime{
                if let timeCell:LogInTableViewCell = self.tableViewSchedule.cellForRow(at: IndexPath.init(row: 2, section: 0)) as? LogInTableViewCell{
                    if let _ = self.dateDetail{
                        guard self.dateDetail!.text.count > 0 else{
                            DispatchQueue.main.async {
                                self.invalidTextField(textField: timeCell.textFieldLogIn)
                                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"scheduleTime"))
                            }
                            return false
                        }
                    }
                }
            }else{
                return true
            }
            
        }else if self.scheduleType == .Once{
            if let dateCell:LogInTableViewCell = self.tableViewSchedule.cellForRow(at: IndexPath.init(row: 1, section: 0)) as? LogInTableViewCell{
                if let _ = self.dateDetail{
                    guard self.dateDetail!.text.count > 0 else{
                        DispatchQueue.main.async {
                            self.invalidTextField(textField: dateCell.textFieldLogIn)
                            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"scheduleDate"))
                        }
                        return false
                    }
                }
            }
            
        }else if self.scheduleType == .Weekly{
            if let weekCell:LogInTableViewCell = self.tableViewSchedule.cellForRow(at: IndexPath.init(row: 2, section: 0)) as? LogInTableViewCell{
                if let _ = self.weekDetail{
                    guard self.weekDetail!.text.count > 0 else{
                        DispatchQueue.main.async {
                            self.invalidTextField(textField: weekCell.textFieldLogIn)
                            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"scheduleWeekday"))
                        }
                        return false
                    }
                }
            }
        }else if self.scheduleType == .Monthly{
            if let monthCell:LogInTableViewCell = self.tableViewSchedule.cellForRow(at: IndexPath.init(row: 2, section: 0)) as? LogInTableViewCell{
                if let _ = self.dayOfMonthDetail{
                    guard self.dayOfMonthDetail!.text.count > 0 else{
                        DispatchQueue.main.async {
                            self.invalidTextField(textField: monthCell.textFieldLogIn)
                            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"scheduleDay"))
                        }
                        return false
                    }
                }
            }
        }
        return true
    }
    func invalidTextField(textField:TweeActiveTextField){
        textField.activeLineColor = .clear
        textField.lineColor = .red
        textField.placeholderColor = .red
        textField.invalideField()
    }
    func validTextField(textField:TweeActiveTextField){
        textField.activeLineColor = .clear
        textField.lineColor = UIColor.black.withAlphaComponent(0.8)
        textField.placeholderColor = UIColor.black

    }
    func configureScheduleView(){
        let objNib = UINib.init(nibName: "LogInTableViewCell", bundle: nil)
        self.tableViewSchedule.register(objNib, forCellReuseIdentifier: "LogInTableViewCell")
        self.tableViewSchedule.tableHeaderView = UIView()
        self.tableViewSchedule.tableFooterView = UIView()
        self.tableViewSchedule.delegate = self
        self.tableViewSchedule.dataSource = self
        //self.buttonAddSchedule.layer.borderColor = UIColor.black.cgColor
        //self.buttonAddSchedule.layer.borderWidth = 1.0
    }
    
    func configureScheduleType(){
        self.freeScheduleDaysDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key:"PickDay"),minimumPlaceHolder:Vocabulary.getWordFromKey(key:"days.hint").capitalizingFirstLetter(), text: "\(self.selectdDaysOfFree)", keyboardType: .emailAddress, returnKey: .next, isSecure: false)
        self.scheduleDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key:"howOften?"),minimumPlaceHolder:Vocabulary.getWordFromKey(key:"howOften?").capitalizingFirstLetter(), text: "\(self.selectedOccurence)", keyboardType: .emailAddress, returnKey: .next, isSecure: false)
        self.timeDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key:"pickStartTime"),minimumPlaceHolder:Vocabulary.getWordFromKey(key:"startime.hint").capitalizingFirstLetter(), text:"\(self.selectedTime)".converTo12hoursFormate(), keyboardType: .emailAddress, returnKey: .next, isSecure: false)
        self.dateDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key:"SelectDate"),minimumPlaceHolder:Vocabulary.getWordFromKey(key:"SelectDate").capitalizingFirstLetter(), text:"\(self.selectedDate)", keyboardType: .emailAddress, returnKey: .next, isSecure: false)
        self.weekDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key:"PickDay"),minimumPlaceHolder:Vocabulary.getWordFromKey(key:"days.hint").capitalizingFirstLetter(), text:"\(self.selectedWeekDay)", keyboardType: .emailAddress, returnKey: .next, isSecure: false)
        self.dayOfMonthDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key:"PickDay"),minimumPlaceHolder:Vocabulary.getWordFromKey(key:"days.hint").capitalizingFirstLetter(), text:"\(self.selectedDayOfMonth)", keyboardType: .emailAddress, returnKey: .next, isSecure: false)
        self.startDate = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key:"pickstartdate.hint"),minimumPlaceHolder:Vocabulary.getWordFromKey(key:"startdate.hint").capitalizingFirstLetter(), text:"\(self.strStartDate)", keyboardType: .emailAddress, returnKey: .next, isSecure: false)
        self.endDate = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key:"pickenddate.hint"),minimumPlaceHolder:Vocabulary.getWordFromKey(key:"enddate.hint").capitalizingFirstLetter(), text:"\(self.strEndDate)", keyboardType: .emailAddress, returnKey: .next, isSecure: false)
        
        if self.scheduleType == .Free{
            if let _ = self.scheduleDetail,let _ = self.timeDetail,let _ = self.dateDetail{
                if self.isFreeScheduleNoTime{
                    self.arrayOfOccurence = [self.scheduleDetail!,self.freeScheduleDaysDetail!]
                }else{
                    self.arrayOfOccurence = [self.scheduleDetail!,self.freeScheduleDaysDetail!,self.timeDetail!]
                }
            }
        }else if self.scheduleType == .Once{
            if let _ = self.scheduleDetail,let _ = self.timeDetail,let _ = self.dateDetail{
                if self.isOnceScheduleNoTime{
                    self.arrayOfOccurence = [self.scheduleDetail!,self.dateDetail!]
                }else{
                    self.arrayOfOccurence = [self.scheduleDetail!,self.dateDetail!,self.timeDetail!]
                }
            }
        }else if self.scheduleType == .Daily{
            if let _ = self.scheduleDetail,let _ = self.timeDetail{
                self.arrayOfOccurence = [self.scheduleDetail!,self.timeDetail!]
            }
            if self.selectedOccurence.count > 0{
                self.arrayOfOccurence.append(self.startDate!)
                self.arrayOfOccurence.append(self.endDate!)
                
            }
        }else if self.scheduleType == .Weekly{
            if let _ = self.scheduleDetail,let _ = self.timeDetail,let _ = self.weekDetail{
                self.arrayOfOccurence = [self.scheduleDetail!,self.weekDetail!,self.timeDetail!,self.startDate!,self.endDate!]
            }
            
        }else if self.scheduleType == .Weekdays{
            if let _ = self.scheduleDetail,let _ = self.timeDetail{
                self.arrayOfOccurence = [self.scheduleDetail!,self.timeDetail!,self.startDate!,self.endDate!]
            }
            
        }else if self.scheduleType == .Monthly{
            if let _ = self.scheduleDetail,let _ = self.timeDetail,let _ = self.dayOfMonthDetail{
                if self.isMonthlyScheduleNoTime{
                    self.arrayOfOccurence = [self.scheduleDetail!,self.dayOfMonthDetail!]
                }else{
                    self.arrayOfOccurence = [self.scheduleDetail!,self.dayOfMonthDetail!,self.timeDetail!]
                }
                self.arrayOfOccurence.append(self.startDate!)
                self.arrayOfOccurence.append(self.endDate!)
            }
        }
        defer {
            self.tableViewSchedule.reloadData()
        }
    }
    func configureDurationPicker(){
        self.timeToolBar.sizeToFit()
        self.timeToolBar.layer.borderColor = UIColor.clear.cgColor
        self.timeToolBar.layer.borderWidth = 1.0
        self.timeToolBar.clipsToBounds = true
        self.timeToolBar.backgroundColor = UIColor.white
        self.timePicker.datePickerMode = .time
        self.timePicker.locale = Locale(identifier: "en_US")
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ScheduleViewController.doneTimePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "\(Vocabulary.getWordFromKey(key:"pickStartTime"))", attributes:[NSAttributedStringKey.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ScheduleViewController.cancelTimePicker))
        self.timeToolBar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
    }
    @objc func cancelTimePicker(){
        //cancel button dismiss datepicker dialog
        
        self.view.endEditing(true)
        DispatchQueue.main.async {
            self.buttonForgroundShadow.isHidden = true
            self.tableViewSchedule.reloadData()
        }
    }
    @objc func doneTimePicker(){
        let date =  self.timePicker.date
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        if let _ = components.hour,let _ = components.minute{
            let hour = components.hour!
            let minute = components.minute!
            var strHour = "\(hour)"
            var strMinute = "\(minute)"
            if strHour.count == 1{
                strHour = "0\(strHour)"
            }
            if strMinute.count == 1{
                strMinute = "0\(strMinute)"
            }
            self.selectedTime = "\(strHour):\(strMinute)"
            self.configureScheduleType()
        }
        self.buttonForgroundShadow.isHidden = true
        //dismiss date picker dialog
        self.view.endEditing(true)
    }
    func configureDatePicker(){
        self.dateToolBar.sizeToFit()
        self.dateToolBar.layer.borderColor = UIColor.clear.cgColor
        self.dateToolBar.layer.borderWidth = 1.0
        self.dateToolBar.clipsToBounds = true
        self.datePicker.datePickerMode = .date
        self.datePicker.minimumDate = Date()
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ScheduleViewController.donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "\(Vocabulary.getWordFromKey(key:"startdate.hint"))".capitalizingFirstLetter(), attributes:[NSAttributedStringKey.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ScheduleViewController.cancelDatePicker))
        self.dateToolBar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
    }
    func configureEndDatePicker(){
        self.endDateToolBar.sizeToFit()
        self.endDateToolBar.layer.borderColor = UIColor.clear.cgColor
        self.endDateToolBar.layer.borderWidth = 1.0
        self.endDateToolBar.clipsToBounds = true
        self.endDatePicker.datePickerMode = .date
        self.endDatePicker.minimumDate = Date()
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ScheduleViewController.doneEndDatePicker))
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "\(Vocabulary.getWordFromKey(key:"enddate.hint"))".capitalizingFirstLetter(), attributes:[NSAttributedStringKey.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ScheduleViewController.cancelEndDatePicker))
        self.endDateToolBar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
    }
    @objc func cancelEndDatePicker(){
        self.view.endEditing(true)
        DispatchQueue.main.async {
            self.buttonForgroundShadow.isHidden = true
            self.tableViewSchedule.reloadData()
        }
    }
    @objc func doneEndDatePicker(){
        self.buttonForgroundShadow.isHidden = true
        let date =  self.endDatePicker.date
        self.dateFormatter.dateFormat = "MM/dd/yyyy"
        self.strEndDate = "\(self.dateFormatter.string(from: date))"
        self.configureScheduleType()
        //dismiss date picker dialog
        self.view.endEditing(true)
    }
    @objc func cancelDatePicker(){
        //cancel button dismiss datepicker dialog
        self.view.endEditing(true)
        DispatchQueue.main.async {
            self.buttonForgroundShadow.isHidden = true
            self.tableViewSchedule.reloadData()
        }
    }
    @objc func donedatePicker(){
        self.buttonForgroundShadow.isHidden = true
        let date =  self.datePicker.date
        self.endDatePicker.minimumDate = self.datePicker.date
        self.dateFormatter.dateFormat = "MM/dd/yyyy"
        self.selectedDate = "\(self.dateFormatter.string(from: date))"
        self.strStartDate = "\(self.dateFormatter.string(from: date))"
        self.configureScheduleType()
        //dismiss date picker dialog
        self.view.endEditing(true)
    }
    func configureDayOfMonthPicker(){
       self.dayOfMonthPickerView.delegate = self
       self.dayOfMonthPickerView.dataSource = self
        self.dayToolBar.sizeToFit()
        self.dayToolBar.layer.borderColor = UIColor.darkGray.cgColor
        self.dayToolBar.layer.borderWidth = 1.0
        self.dayToolBar.clipsToBounds = true
        let doneButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ScheduleViewController.doneDayPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ScheduleViewController.cancelDayPicker))
        self.dayToolBar.setItems([cancelButton,spaceButton,doneButton], animated: false)
    }
    @objc func cancelDayPicker(){
        //cancel button dismiss datepicker dialog
        DispatchQueue.main.async {
            self.buttonForgroundShadow.isHidden = true
            self.tableViewSchedule.reloadData()
        }
        self.view.endEditing(true)
    }
    @objc func doneDayPicker(){
        print(self.selectedDayTag)
        //dismiss date picker dialog
        self.selectedDayOfMonth = "\(self.arrayOfDaysOfMonth[self.selectedDayTag])"
        self.scheduleType = .Monthly
        self.buttonForgroundShadow.isHidden = true
        self.view.endEditing(true)
    }
    func getDayOfSelectedWeek()->Int{
        if self.selectedWeekDay == Vocabulary.getWordFromKey(key:"Monday"){
           return 1//0
        }else if self.selectedWeekDay == Vocabulary.getWordFromKey(key:"Tuesday"){
            return 2//1
        }else if self.selectedWeekDay == Vocabulary.getWordFromKey(key:"Wednesday"){
            return 3//2
        }else if self.selectedWeekDay == Vocabulary.getWordFromKey(key:"Thursday"){
            return 4//3
        }else if self.selectedWeekDay == Vocabulary.getWordFromKey(key:"Friday"){
            return 5//4
        }else if self.selectedWeekDay == Vocabulary.getWordFromKey(key:"Saturday"){
            return 6//5
        }else if self.selectedWeekDay == Vocabulary.getWordFromKey(key:"Sunday"){
            return 0//6
        }else{
            return 0
        }
    }
    func getSelectedDate()->NSArray{
        guard self.selectedDates.count > 0 else{
            return []
        }
        var strDates:[String] = []
        self.dateFormatter.dateFormat = "MM/dd/yyyy"
        for date in self.selectedDates{
            strDates.append(self.dateFormatter.string(from: date))
        }
        return NSArray.init(array: strDates)
    }
    func configureOccurencePicker(){
        self.occurencePicker.delegate = self
        self.occurencePicker.dataSource = self
        self.occurenceToolBar.sizeToFit()
        self.occurenceToolBar.backgroundColor = UIColor.white
        self.occurenceToolBar.layer.borderColor = UIColor.clear.cgColor
        self.occurenceToolBar.layer.borderWidth = 1.0
        self.occurenceToolBar.clipsToBounds = true
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ScheduleViewController.doneOccurencePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let title = UILabel.init()
        if self.arrayOfOccurence.count > 0{
            let detail = self.arrayOfOccurence[0]
            title.attributedText = NSAttributedString.init(string: "\(detail.placeHolder)", attributes:[NSAttributedStringKey.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        }
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ScheduleViewController.cancelDayPicker))
        self.occurenceToolBar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
    }
    @objc func doneOccurencePicker(){
         self.addedInputSet.removeAllObjects()
         self.selectedOccurence = self.strTempOccurence
         selectdDaysOfFree = ""
         selectedTime = ""
         selectedDate = ""
         selectedWeekDay = ""
         selectedDayOfMonth = ""
         strStartDate  = ""
         strEndDate  = ""
        
        if selectedOccurence == Vocabulary.getWordFromKey(key:"Custom"){
            self.scheduleType = .Free
        }else if selectedOccurence == Vocabulary.getWordFromKey(key:"Once"){
            self.scheduleType = .Once
        }else if selectedOccurence == Vocabulary.getWordFromKey(key:"Daily"){
            self.scheduleType = .Daily
        }else if selectedOccurence == Vocabulary.getWordFromKey(key:"Weekly"){
            self.scheduleType = .Weekly
        }else if selectedOccurence == Vocabulary.getWordFromKey(key:"Weekdays"){
            self.scheduleType = .Weekdays
        }else if selectedOccurence == Vocabulary.getWordFromKey(key:"Monthly"){
            self.scheduleType = .Monthly
        }
        self.view.endEditing(true)
    }
    func configureWeeklyPicker(){
        self.weekDayPicker.delegate = self
        self.weekDayPicker.dataSource = self
        self.weekDayToolBar.sizeToFit()
        self.weekDayToolBar.backgroundColor = UIColor.white
        self.weekDayToolBar.layer.borderColor = UIColor.clear.cgColor
        self.weekDayToolBar.layer.borderWidth = 1.0
        self.weekDayToolBar.clipsToBounds = true
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ScheduleViewController.doneWeeklyPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let title = UILabel.init()
        if self.arrayOfOccurence.count > 0{
            title.attributedText = NSAttributedString.init(string:Vocabulary.getWordFromKey(key:"PickDay"), attributes:[NSAttributedStringKey.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        }
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(ScheduleViewController.cancelDayPicker))
        self.weekDayToolBar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
    }
    @objc func doneWeeklyPicker(){
         self.selectedWeekDay = self.strTempWeekDay
         self.scheduleType = .Weekly
         self.view.endEditing(true)
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        //PopToBackViewController
       
        let backAlert = UIAlertController(title: Vocabulary.getWordFromKey(key:"newSchedule"), message: Vocabulary.getWordFromKey(key:"newSchedule.msg"),preferredStyle: UIAlertControllerStyle.alert)
        backAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (action: UIAlertAction!) in
            self.navigationController?.popViewController(animated: true)
        }))
        backAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"no"), style: .cancel, handler: nil))
        backAlert.view.tintColor = UIColor.init(hexString: "#36527D")
        self.present(backAlert, animated: true, completion: nil)
    }
    @IBAction func buttonAddScheduleSelector(sender:UIButton){
        //if self.isValidAddSchedule(){
            self.addScheduleParameters[kRecurrence] = "\(self.selectedOccurence)"
            self.addScheduleParameters[kTime] = "\(self.selectedTime)"
            if self.scheduleType == .Free{
                self.addScheduleParameters[kRecurrenceDay] = self.getSelectedDate()
            }else if self.scheduleType == .Once{
                self.addScheduleParameters[kRecurrenceDay] = ["\(self.selectedDate)"]
            }else if self.scheduleType == .Daily || self.scheduleType == .Weekdays{
                self.addScheduleParameters[kRecurrenceDay] = ["None"]
                if self.strStartDate.count > 0{
                    self.addScheduleParameters[kStartDate] = "\(self.strStartDate)"
                }
                if self.strEndDate.count > 0{
                    self.addScheduleParameters[kEndDate] = "\(self.strEndDate)"
                }
            }else if self.scheduleType == .Weekly{
                self.addScheduleParameters[kRecurrenceDay] = ["\(self.getDayOfSelectedWeek())"]
                if self.strStartDate.count > 0{
                    self.addScheduleParameters[kStartDate] = "\(self.strStartDate)"
                }
                if self.strEndDate.count > 0{
                    self.addScheduleParameters[kEndDate] = "\(self.strEndDate)"
                }
            }else if self.scheduleType == .Monthly{
                self.addScheduleParameters[kRecurrenceDay] = self.getSelectedDate()
                if self.strStartDate.count > 0{
                    self.addScheduleParameters[kStartDate] = "\(self.strStartDate)"
                }
                if self.strEndDate.count > 0{
                    self.addScheduleParameters[kEndDate] = "\(self.strEndDate)"
                }
            }
            self.performSegue(withIdentifier:"unwindToAddExperienceFromNewSchedule", sender: self.addScheduleParameters)
        //}
    }
    
    @IBAction func unwindFromCalendarToNewSchedule(segue:UIStoryboardSegue){
        if selectedOccurence == Vocabulary.getWordFromKey(key:"Custom"){
            self.selectdDaysOfFree = "\(self.selectedDates.count) days added"
            self.scheduleType = .Free
        }else if selectedOccurence == Vocabulary.getWordFromKey(key:"Once"){
            if self.selectedDates.count > 0{
                self.dateFormatter.dateFormat = "MM/dd/yyyy"
                self.selectedDate = "\(self.dateFormatter.string(from: self.selectedDates.first!))"
            }
            self.scheduleType = .Once
        }else if selectedOccurence == Vocabulary.getWordFromKey(key:"Daily"){
            self.scheduleType = .Daily
        }else if selectedOccurence == Vocabulary.getWordFromKey(key:"Weekly"){
            self.scheduleType = .Weekly
        }else if selectedOccurence == Vocabulary.getWordFromKey(key:"Weekdays"){
            self.scheduleType = .Weekdays
        }else if selectedOccurence == Vocabulary.getWordFromKey(key:"Monthly"){
            self.selectedDayOfMonth = "\(self.selectedDates.count) days added"
            self.scheduleType = .Monthly
        }
    }
    @IBAction func unWindToScheduleFromOccurence(segue:UIStoryboardSegue){
        if selectedOccurence == Vocabulary.getWordFromKey(key:"Once"){
            self.scheduleType = .Once
        }else if selectedOccurence == Vocabulary.getWordFromKey(key:"Daily"){
            self.scheduleType = .Daily
        }else if selectedOccurence == Vocabulary.getWordFromKey(key:"Weekly"){
            self.scheduleType = .Weekly
        }else if selectedOccurence == Vocabulary.getWordFromKey(key:"Weekdays"){
            self.scheduleType = .Weekdays
        }else if selectedOccurence == Vocabulary.getWordFromKey(key:"Monthly"){
            self.scheduleType = .Monthly
        }
    }
    @IBAction func unWindToScheduleFromWeakDay(segue:UIStoryboardSegue){
        if selectedOccurence == Vocabulary.getWordFromKey(key:"Once"){
            self.scheduleType = .Once
        }else if selectedOccurence == Vocabulary.getWordFromKey(key:"Daily"){
            self.scheduleType = .Daily
        }else if selectedOccurence == Vocabulary.getWordFromKey(key:"Weekly"){
            self.scheduleType = .Weekly
        }else if selectedOccurence == Vocabulary.getWordFromKey(key:"Weekdays"){
            self.scheduleType = .Weekdays
        }else if selectedOccurence == Vocabulary.getWordFromKey(key:"Monthly"){
            self.scheduleType = .Monthly
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "unwindToAddExperienceFromNewSchedule",let objNewSchedule = sender as? [String:Any]{
            if let discoverViewController: AddExperienceViewController = segue.destination as? AddExperienceViewController{
                discoverViewController.newScheduleParameters = objNewSchedule
            }
        }
    }
}
extension ScheduleViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return   self.arrayOfOccurence.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resetCell:LogInTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LogInTableViewCell", for: indexPath) as! LogInTableViewCell
        resetCell.hideSeparator()
        guard self.arrayOfOccurence.count > indexPath.row else{
            return resetCell
        }
       
        let detail = self.arrayOfOccurence[indexPath.row]
        resetCell.textFieldLogIn.tweePlaceholder = "\(detail.placeHolder)"
        resetCell.textFieldLogIn.minimumPlaceHolder = "\(detail.minimumPlaceHolder)"
        DispatchQueue.main.async {
            if detail.text.count > 0,detail.text != " "{
                //self.validTextField(textField: resetCell.textFieldLogIn)
                resetCell.textFieldLogIn.text = "\(detail.text)"
                resetCell.imageTick.isHidden = false
                resetCell.textFieldLogIn.minimizePlaceholder()
                
                self.addedInputSet.add(indexPath.row)
                    if self.scheduleType == .Free || self.scheduleType == .Once{
                        resetCell.textFieldLogIn.isEnabled = true
                    }else{
                        if indexPath.row == self.arrayOfOccurence.count - 1{
                            resetCell.textFieldLogIn.isEnabled = self.strStartDate.count > 0
                        }else{
                            resetCell.textFieldLogIn.isEnabled = true
                        }
                    }
                self.buttonAddScheduleEnable(isEnable: self.addedInputSet.count == self.arrayOfOccurence.count)
            }else{
                if self.addedInputSet.contains(indexPath.row){
                    self.addedInputSet.remove(indexPath.row)
                }
                self.buttonAddScheduleEnable(isEnable:false)
                resetCell.textFieldLogIn.text = ""
                resetCell.imageTick.isHidden = true
                resetCell.textFieldLogIn.maximizePlaceholder()
            
            }
        }
        resetCell.textFieldLogIn.delegate = self
        resetCell.setTextFieldColor(textColor: .black,placeHolderColor: .black)
        resetCell.textFieldLogIn.placeholderColor = UIColor.black
       

        resetCell.textFieldLogIn.tag = indexPath.row
        if self.scheduleType == .Free{
            if indexPath.row == 0{ //Free
                resetCell.textFieldLogIn.inputView = self.occurencePicker
                resetCell.textFieldLogIn.inputAccessoryView = self.occurenceToolBar
            }else if indexPath.row == 1{ //Date
                //Present Calendar
                //resetCell.textFieldLogIn.inputView = self.datePicker
                //resetCell.textFieldLogIn.inputAccessoryView = self.dateToolBar
            }else if indexPath.row == 2{ //Time
                self.timePicker.minimumDate = nil
                resetCell.textFieldLogIn.inputView = self.timePicker
                resetCell.textFieldLogIn.inputAccessoryView = self.timeToolBar
            }
            return resetCell
        }else if self.scheduleType == .Once{ //Once - Time - Date
            if indexPath.row == 0{ //Once
                resetCell.textFieldLogIn.inputView = self.occurencePicker
                resetCell.textFieldLogIn.inputAccessoryView = self.occurenceToolBar
            }else if indexPath.row == 1{ //Date
//                resetCell.textFieldLogIn.inputView = self.datePicker
//                resetCell.textFieldLogIn.inputAccessoryView = self.dateToolBar
            }else if indexPath.row == 2{ //Time
                if self.selectedDates.count > 0,self.dateFormatter.string(from: self.selectedDates.first!) == self.dateFormatter.string(from: Date()){
                    self.timePicker.minimumDate = Date()
                }else{
                    self.timePicker.minimumDate = nil
                }
                resetCell.textFieldLogIn.inputView = self.timePicker
                resetCell.textFieldLogIn.inputAccessoryView = self.timeToolBar
              
            }
            return resetCell
        }else if self.scheduleType == .Daily || self.scheduleType == .Weekdays{ //Daily Weekdays - Time
            if indexPath.row == 0{ //Daily
                resetCell.textFieldLogIn.inputView = self.occurencePicker
                resetCell.textFieldLogIn.inputAccessoryView = self.occurenceToolBar
            }else if indexPath.row == 1{ //Time
                self.timePicker.minimumDate = nil
                resetCell.textFieldLogIn.inputView = self.timePicker
                resetCell.textFieldLogIn.inputAccessoryView = self.timeToolBar
            }else if indexPath.row == self.arrayOfOccurence.count - 2{ //start date
                resetCell.textFieldLogIn.inputView = self.datePicker
                resetCell.textFieldLogIn.inputAccessoryView = self.dateToolBar
            }else if indexPath.row == self.arrayOfOccurence.count - 1{ //end date
                resetCell.textFieldLogIn.inputView = self.endDatePicker
                resetCell.textFieldLogIn.inputAccessoryView = self.endDateToolBar
            }
            
            return resetCell
        }else if self.scheduleType == .Weekly{ //Weekly - Time - Weekly
            if indexPath.row == 0{ //Weekly
//                resetCell.textFieldLogIn.inputView = self.occurencePicker
//                resetCell.textFieldLogIn.inputAccessoryView = self.occurenceToolBar
            }else if indexPath.row == 1{ //Weekly
                resetCell.textFieldLogIn.inputView = self.weekDayPicker
                resetCell.textFieldLogIn.inputAccessoryView = self.weekDayToolBar
            }else if indexPath.row == 2{ //Time
                self.timePicker.minimumDate = nil
                resetCell.textFieldLogIn.inputView = self.timePicker
                resetCell.textFieldLogIn.inputAccessoryView = self.timeToolBar
            }else if indexPath.row == self.arrayOfOccurence.count - 2{ //start date
                resetCell.textFieldLogIn.inputView = self.datePicker
                resetCell.textFieldLogIn.inputAccessoryView = self.dateToolBar
            }else if indexPath.row == self.arrayOfOccurence.count - 1{ //end date
                resetCell.textFieldLogIn.inputView = self.endDatePicker
                resetCell.textFieldLogIn.inputAccessoryView = self.endDateToolBar
            }
            return resetCell
        }else if self.scheduleType == .Monthly{ //Month - Time - day
            if indexPath.row == 0{ //Month
                resetCell.textFieldLogIn.inputView = self.occurencePicker
                resetCell.textFieldLogIn.inputAccessoryView = self.occurenceToolBar
            }else if indexPath.row == 1{ //Day
//                resetCell.textFieldLogIn.inputView = self.dayOfMonthPickerView
//                resetCell.textFieldLogIn.inputAccessoryView = self.dayToolBar
            }else if indexPath.row == 2{ //Time
                if isMonthlyScheduleNoTime{
                    resetCell.textFieldLogIn.inputView = self.datePicker
                    resetCell.textFieldLogIn.inputAccessoryView = self.dateToolBar
                }else{
                    self.timePicker.minimumDate = nil
                    resetCell.textFieldLogIn.inputView = self.timePicker
                    resetCell.textFieldLogIn.inputAccessoryView = self.timeToolBar
                }
            }else if indexPath.row == self.arrayOfOccurence.count - 2{ //start date
                resetCell.textFieldLogIn.inputView = self.datePicker
                resetCell.textFieldLogIn.inputAccessoryView = self.dateToolBar
            }else if indexPath.row == self.arrayOfOccurence.count - 1{ //end date
                resetCell.textFieldLogIn.inputView = self.endDatePicker
                resetCell.textFieldLogIn.inputAccessoryView = self.endDateToolBar
            }
            return resetCell

            
        }else{
            return resetCell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select \(indexPath.row)")
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableViewHeight
    }
}
extension ScheduleViewController:UITextFieldDelegate{
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.buttonForgroundShadow.isHidden = true
        if let text = textField.text,text.count > 0{
            DispatchQueue.main.async {
                (textField as! TweeActiveTextField).minimizePlaceholder()
            }
        }else{
            textField.text = " "
        }
        
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.scheduleType == .Monthly || self.scheduleType == .Weekly || self.scheduleType == .Daily || self.scheduleType == .Weekdays,self.strStartDate.count == 0,(textField.tag == self.arrayOfOccurence.count - 1){
            ShowToast.show(toatMessage:"Please select start date")
            return false
        }else if textField.tag == 1,self.scheduleType == .Weekly || self.scheduleType == .Daily || self.scheduleType == .Weekdays {
            //Present Weekly picker
//            if let pricePicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
//                pricePicker.modalPresentationStyle = .overCurrentContext
//                pricePicker.objSearchType = .WeekDays
//                textField.resignFirstResponder()
//                self.present(pricePicker, animated: true, completion: nil)
//            }
            //self.strTempWeekDay = Vocabulary.getWordFromKey(key:"Monday")
            self.buttonForgroundShadow.isHidden = false
            return true
        }else if textField.tag == 0{
            //Present Occurence
            /*if let pricePicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
                pricePicker.modalPresentationStyle = .overCurrentContext
                pricePicker.objSearchType = .Occurence
                textField.resignFirstResponder()
                self.present(pricePicker, animated: true, completion: nil)
            }*/
           // self.strTempOccurence = "\(Vocabulary.getWordFromKey(key:"Free.hint"))"
            //self.selectedOccurence = "\(Vocabulary.getWordFromKey(key:"Free.hint"))"
            let selectedRow = self.occurencePicker.selectedRow(inComponent: 0)
            self.strTempOccurence = self.pickerView(self.occurencePicker, titleForRow: selectedRow, forComponent: 0)!
            self.buttonForgroundShadow.isHidden = false
            return true
        } else if textField.tag == 1,self.scheduleType == .Free || self.scheduleType == .Once || self.scheduleType == .Monthly{
            if let calendarSchedule = self.storyboard?.instantiateViewController(withIdentifier: "AddScheduleCalendarViewController") as? AddScheduleCalendarViewController{
             textField.resignFirstResponder()
             calendarSchedule.scheduleType = self.scheduleType
             self.present(calendarSchedule, animated: true, completion: nil)
             }
            return false
        }else if textField.tag == 2{
            self.buttonForgroundShadow.isHidden = false
            return true
        }else{
            return true
        }
    }
}
extension ScheduleViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.occurencePicker{
            return "\(self.arrayOfScheduleTypes[row])"
        }else if pickerView == self.weekDayPicker{
            return "\(self.arrayOfWeekDays[row])"
        }else{
            return "\(self.arrayOfDaysOfMonth[row])"
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if pickerView == self.occurencePicker || pickerView == self.weekDayPicker{
            return UIScreen.main.bounds.width
        }else{
           return 150.0
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.occurencePicker{
            return self.arrayOfScheduleTypes.count
        }else if pickerView == self.weekDayPicker{
            return self.arrayOfWeekDays.count
        }else{
           return 31
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.occurencePicker{
            self.strTempOccurence = "\(self.arrayOfScheduleTypes[row])"
        }else if pickerView == self.weekDayPicker{
            self.strTempWeekDay = "\(self.arrayOfWeekDays[row])"
        }else{
            self.selectedDayTag = row
        }
         pickerView.selectRow(row, inComponent: component, animated: true)
    }
}

