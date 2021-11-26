//
//  BookingViewController.swift
//  Live
//
//  Created by ITPATH on 4/26/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import FacebookCore
import IQKeyboardManagerSwift
import Instructions

class BookingViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    
    
    fileprivate let kDate:String = "date"
    fileprivate let kExperience_id:String = "experience_id"
    fileprivate let kExperience_name:String = "experience_name"
    fileprivate let kExperience_currency:String = "experience_currency"
    fileprivate let kPrice:String = "price"
    fileprivate let kSlots:String = "slots"
    fileprivate let kTime:String = "time"
    fileprivate let kUserID:String = "user_id"
    fileprivate let kUserName:String = "user_name"
    fileprivate let kIsGroupBooking:String = "isgroup_booking"
    fileprivate let kBookingID:String = "id" //first time 0
    fileprivate let kBookingStatus:String = "status" /*Booking status:RequestedByTraveler RequestedByGuide Accepted Confirmed Canceled*/
    fileprivate let kNotification_body:String = "notification_body"
    fileprivate let kInstant_booking:String = "instant_booking"
    fileprivate let kGuide_id:String = "guide_id"
    
    @IBOutlet weak var navTopConstant: NSLayoutConstraint!
    @IBOutlet weak var navHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var shadowViewBtn: UIButton!
    @IBOutlet weak var topConstantOfNavView: NSLayoutConstraint!
    @IBOutlet var lblWhen:UILabel!
    @IBOutlet var lblBooking:UILabel!
    @IBOutlet var lblBokkingOption:UILabel!
    @IBOutlet var lblTime:UILabel!
    @IBOutlet var lblHowManyGuest:UILabel!
    @IBOutlet var navView:UIView!
    @IBOutlet var tableViewBooking:UITableView!
    @IBOutlet var btnBooking:UIButton!
    @IBOutlet var btnBack:UIButton!
    @IBOutlet var lblCurrency:UILabel!
    @IBOutlet var lblExperienceName:UILabel!
    @IBOutlet var txtExperienceDate:UITextField!
    @IBOutlet var txtNumberOfGuest:UITextField!
    @IBOutlet var btnAddGuest:UIButton!
    @IBOutlet var btnRemoveGuest:UIButton!
//    @IBOutlet var bookingOptionsView:UIView!
//    @IBOutlet var bookingPricePerPerson:UIView!
//    @IBOutlet var bookingPricePerGroup:UIView!
//    @IBOutlet var lblPricePerPerson:UILabel!
//    @IBOutlet var lblPricePerGroup:UILabel!
//    @IBOutlet var imgPricePerPerson:UIImageView!
//    @IBOutlet var imgPricePerGroup:UIImageView!
    
    @IBOutlet var txtBookingOptions:UITextField!
    @IBOutlet var txtBookingTimeSlot:UITextField!
//    @IBOutlet var timeCollectionView:UICollectionView!
    @IBOutlet var imgExperience:ImageViewForURL!
    @IBOutlet var lblNumberOfGuest:UILabel!
    @IBOutlet var whenContainer:UIView!
    @IBOutlet var bookingOptionsContainer:UIView!
    @IBOutlet var timeContainer:UIView!
    @IBOutlet var numberOfGuestContainer:UIView!
    @IBOutlet var buttonReviewBooking:RoundButton!
    @IBOutlet var txtExperienceBookingDuration:UITextField!
    @IBOutlet var heightForExpereinceDuration:NSLayoutConstraint! // 0 for price per person and group price
    @IBOutlet var lblDuration:UILabel!
    
    var totalPriceOnHourly:String = ""
    var bookingDurationPicker:UIDatePicker = UIDatePicker()
    var bookingDurationToolbar:UIToolbar = UIToolbar()
    var durationTime:String = ""
    var bookingDurationTime:String{
        get{
            return durationTime
        }
        set{
            durationTime = newValue
            //Configure selected duration time
            DispatchQueue.main.async {
                self.txtExperienceBookingDuration.text = newValue
                self.configureTotalPriceOnHourly()
            }
        }
    }
    
    var bookingOption:UIPickerView = UIPickerView.init()
    var bookingOptionToolbar:UIToolbar = UIToolbar()
    var bookingTimeSlotPicker:UIPickerView = UIPickerView.init()
    var bookingTimeSlotToolbar:UIToolbar = UIToolbar()

    var currentTimeSlotIndex:Int = 0
    var timeSlotIndex:Int = 0
    var selectedTimeSlotIndex:Int{
        get{
            return timeSlotIndex
        }
        set{
            timeSlotIndex = newValue
            self.configureSelectedBookingTimeSlot()
        }
    }
    var timePicker:UIDatePicker = UIDatePicker()
    var timeToolBar:UIToolbar = UIToolbar()
    var selectedTime:String = ""

    let dateFormatter = DateFormatter()
    var selectedDate:Date = Date()
    var objExperience: Experience?
    var instanceTimeSlot:Slot?
    var objOccurence:Occurrences?
    var minGuest:Int = 1
    var numberOfGuest:Int{
        get{
            return minGuest
        }
        set{
            minGuest = newValue
            //ConfigureNumberOfGuest
            self.configureNumberOfGuest()
        }
    }
    var maximumeNumberOfGuest = 5
    var tableViewHeaderHeight:CGFloat{
        get{
            return 256.0
        }
    }
    var tableViewFooterHeight:CGFloat{
        get{
            return 550.0 + 88.0
        }
    }
    let tintBorderColor:UIColor = UIColor.init(red: 101.0/255.0, green: 131.0/255.0, blue: 191.0/255.0, alpha: 1.0)
    let lightGrayColor:UIColor = UIColor.init(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
    var selectedCell:NSMutableSet = NSMutableSet()
    var arrayOfTimeSlot:[Slot] = []
    var isEnable = false
    var isBookingEnable:Bool{
        get{
            return isEnable
        }
        set{
            self.isEnable = newValue
            //Configure DateSlot
            //self.configureDateAndSlots(objTimeSlot: )
        }
    }
    var isPersonPrice = false
    var isPricePerPerson:Bool{
        get{
            return isPersonPrice
        }
        set{
            isPersonPrice = newValue
            self.configurePricePerPerson()
        }
    }
    var pricePersonHourly:Bool = false
    var isPricePerPersonHourly:Bool{
        get{
            return pricePersonHourly
        }
        set{
            pricePersonHourly = newValue
            //Configure PricePerPersonHourly
            DispatchQueue.main.async {
                self.configurePricePerPersonHourly()
            }
            
        }
    }
    var isGrouprice = false
    var isPricePerGroup:Bool{
        get{
            return isGrouprice
        }
        set{
            isGrouprice = newValue
            self.configureGroupPrice()
        }
    }
    var groupPriceHourly:Bool = false
    var isGroupPriceHourly:Bool{
        get{
            return groupPriceHourly
        }
        set{
            groupPriceHourly = newValue
            //COnfigure group price hourly
            DispatchQueue.main.async {
                self.configureGroupPriceHourly()
            }
            
        }
    }
    
//    let leftViewDate = UILabel(frame: CGRect(x: 10, y: 0, width: 7, height: 35))
    let leftViewGuest = UILabel(frame: CGRect(x: 10, y: 0, width: 7, height: 35))
    //pricepergroup //grouppricehourly.hint
    var bookingOptions:[String] = [ "\(Vocabulary.getWordFromKey(key: "priceperperson"))".firstUppercased,"\(Vocabulary.getWordFromKey(key:"priceperpersonhourly.hint"))".firstUppercased,"\(Vocabulary.getWordFromKey(key: "pricepergroup"))".firstUppercased,"\(Vocabulary.getWordFromKey(key: "grouppricehourly.hint"))".firstUppercased]
    var strbookingOptions:String = "\(Vocabulary.getWordFromKey(key: "grouppricehourly.hint"))".firstUppercased
    
    var selectedBookingOption:String{
        get{
            return strbookingOptions
        }
        set{
            strbookingOptions = newValue
            self.configureSelectedBooking()
        }
    }
    var currentBookingOption:String = "\(Vocabulary.getWordFromKey(key: "pricepergroup"))".firstUppercased
    var isHintShow:Bool{
        get{
            guard User.isUserLoggedIn else {
                return true
            }
            if let _ = self.objOccurence{
                return true
            }
            return User.getUserFromUserDefault()!.isBookingHintShown
        }
    }
    var showHintOnTime:Bool = false
    var windowLevel: UIWindowLevel?
    var presentationContext: Context = .independantWindow
    var coachMarksController = CoachMarksController()
    let dateHintText = "Please choose a date"
    let bookingOptionText = "Please choose a booking option"
    let timeHintText = "Choose a time slot or suggest a custom time"
    let guestText = "Please choose number of guests"
    
    var coachMark:CoachMarkHintType = .date
    var objCoachMarkType:CoachMarkHintType{
        get{
            return coachMark
        }
        set{
            coachMark = newValue
            self.updateCoachMarkType()
        }
    }
    
    enum Context {
        case independantWindow, controllerWindow, controller
    }
    public enum ConfigurationChange {
        case nothing, size, statusBar
    }
    public enum CoachMarkHintType{
        case date,booking_options,time,guest
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        shadowViewBtn.isHidden = true
        UIApplication.shared.statusBarStyle = .lightContent
        self.changeTextAsLanguage()
        self.view.layoutIfNeeded()
        self.imgExperience.addShadow(to: [.top], radius: 140.0)
        self.dateFormatter.dateStyle = .medium
        self.btnBooking.layer.cornerRadius = 26.0
        self.btnBooking.clipsToBounds = true
        if self.view.bounds.height > 811 {
            self.navTopConstant.constant = 0.0
            self.navHeightConstant.constant = 88.0
            self.topConstantOfNavView.constant = -44.0
        } else {
            self.navTopConstant.constant = 0.0
            self.navHeightConstant.constant = 64.0
            self.topConstantOfNavView.constant = -20.0
        }
        // Do any additional setup after loading the view.
        //ConfigureTableView
        self.configureTableView()
        //ConfigureBookingView
        self.configureBookingView()
        //ConfigureTimeCollectionView
//        self.configureTimeCollectionView()
        
       //GetInstantBooking
        self.getTodayBookingTimeSlots()
        if let _ = self.objExperience{
            let images = self.objExperience!.images.filter({ $0.mainImage == true})
            if images.count > 0{
                let objImage:Images = images.first!
                self.imgExperience.imageFromServerURL(urlString:objImage.imageURL as String)
                
            }
            if arrayOfTimeSlot.count > 0 {
                self.txtBookingTimeSlot.isEnabled = true
            } else {
                self.txtBookingTimeSlot.isEnabled = false
                self.txtBookingTimeSlot.text = "\(Vocabulary.getWordFromKey(key: "noTimeSlot.title"))"
            }
            self.numberOfGuest = 1//Int(self.objExperience!.groupSizeMin)!
//            self.lblPricePerPerson.text = "\(Vocabulary.getWordFromKey(key: "priceperperson"))" + "(\(self.objExperience!.priceperson))"
//            self.lblPricePerGroup.text = "\(Vocabulary.getWordFromKey(key: "pricepergroup"))" + "(\(self.objExperience!.groupPrice))"
            if self.objExperience!.duration.count > 0{
                DispatchQueue.main.async {
                    self.bookingDurationTime = "\(self.objExperience!.duration)"
                    self.txtExperienceBookingDuration.text = "\(self.objExperience!.duration)"
                }
            }
            if  self.objExperience!.isPricePerPerson,self.objExperience!.isGroupPrice{
                self.isPricePerPerson = true
                self.isPricePerGroup = false
                //bookingOptions = ["\(Vocabulary.getWordFromKey(key: "priceperperson"))".firstUppercased, "\(Vocabulary.getWordFromKey(key: "pricepergroup"))".firstUppercased]
                bookingOptions = ["\(Vocabulary.getWordFromKey(key: "priceperperson"))".firstUppercased]
                if Int("\(objExperience!.pricepersonhourly)") != 0{
                    bookingOptions.append("\(Vocabulary.getWordFromKey(key: "priceperpersonhourly.hint"))".firstUppercased)
                }
                bookingOptions.append("\(Vocabulary.getWordFromKey(key: "pricepergroup"))".firstUppercased)
                if Int("\(objExperience!.groupPricehourly)") != 0{
                    bookingOptions.append("\(Vocabulary.getWordFromKey(key: "grouppricehourly.hint"))".firstUppercased)
                }
                self.selectedBookingOption = "\(Vocabulary.getWordFromKey(key: "priceperperson"))".firstUppercased
                self.currentBookingOption = self.bookingOptions.first!
                self.bookingOption.reloadAllComponents()
                return
            }
            if self.objExperience!.isGroupPrice{
                self.isPricePerPerson = false
                self.isPricePerGroup = true
                bookingOptions = ["\(Vocabulary.getWordFromKey(key: "pricepergroup"))".firstUppercased]
                if Int("\(objExperience!.groupPricehourly)") != 0{
                    bookingOptions.append("\(Vocabulary.getWordFromKey(key: "grouppricehourly.hint"))".firstUppercased)
                }
                
                self.currentBookingOption = "\(Vocabulary.getWordFromKey(key: "pricepergroup"))".firstUppercased
                self.selectedBookingOption = "\(Vocabulary.getWordFromKey(key: "pricepergroup"))".firstUppercased
            }
            if self.objExperience!.isPricePerPerson{
                self.isPricePerPerson = true
                self.isPricePerGroup = false
                bookingOptions = ["\(Vocabulary.getWordFromKey(key: "priceperperson"))".firstUppercased]
                if Int("\(objExperience!.pricepersonhourly)") != 0{
                    bookingOptions.append("\(Vocabulary.getWordFromKey(key: "priceperpersonhourly.hint"))".firstUppercased)
                }
                self.currentBookingOption = "\(Vocabulary.getWordFromKey(key: "priceperperson"))".firstUppercased
                self.selectedBookingOption = "\(Vocabulary.getWordFromKey(key: "priceperperson"))".firstUppercased
            }
            
            self.bookingOption.reloadAllComponents()
        }
        
       // self.sizeFooterToFit()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.addDynamicFont()
            self.configureCoachInstructionHint()
        }
    }
    func updateCoachMarkType(){
        DispatchQueue.main.async {
            self.showCoachMarkHint()
        }
    }
    func showCoachMarkHint(){
        DispatchQueue.main.async {
            if !self.isHintShow{
                if self.instanceTimeSlot != nil{
                    if self.objCoachMarkType == .date{
                        self.objCoachMarkType = .booking_options
                    }else if self.objCoachMarkType == .time{
                        self.objCoachMarkType = .guest
                    }
                    self.coachMarksController.start(on:self)
                    return
                }else{
                    self.coachMarksController.start(on:self)
                }
                
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showCoachMarkHint()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
            self.coachMarksController.stop(immediately: true)
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.shadowViewBtn.isHidden = true
        if textField == self.txtBookingOptions{
            self.objCoachMarkType = .time
        }else if textField == self.txtBookingTimeSlot{
            self.objCoachMarkType = .guest
        }else{
            self.objCoachMarkType = .date
        }
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtBookingTimeSlot{
            self.shadowViewBtn.isHidden = false
            self.currentTimeSlotIndex = 0
            self.bookingTimeSlotPicker.selectRow(0, inComponent: 0, animated: true)

            return true
        }
        if textField.inputView == self.bookingOption || textField.inputView == bookingTimeSlotPicker {
            self.shadowViewBtn.isHidden = false
//            IQKeyboardManager.sharedManager().enable = false
            return true
        }else{
            self.shadowViewBtn.isHidden = true
//            IQKeyboardManager.sharedManager().enable = true
            return true
        }
    }
    
    func addDynamicFont(){
        self.lblExperienceName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblExperienceName.adjustsFontForContentSizeCategory = true
//        self.lblExperienceName.adjustsFontSizeToFitWidth = true
//        self.lblBooking.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
//        self.lblBooking.adjustsFontForContentSizeCategory = true
//        self.lblBooking.adjustsFontSizeToFitWidth = true
//
//        self.lblWhen.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
//        self.lblWhen.adjustsFontForContentSizeCategory = true
//        self.lblWhen.adjustsFontSizeToFitWidth = true
//
//        self.txtExperienceDate.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
//        self.txtExperienceDate.adjustsFontForContentSizeCategory = true
//
//        self.lblBokkingOption.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
//        self.lblBokkingOption.adjustsFontForContentSizeCategory = true
//        self.lblBokkingOption.adjustsFontSizeToFitWidth = true
//
//        self.lblTime.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
//        self.lblTime.adjustsFontForContentSizeCategory = true
//        self.lblTime.adjustsFontSizeToFitWidth = true
//
//        self.lblHowManyGuest.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
//        self.lblHowManyGuest.adjustsFontForContentSizeCategory = true
//        self.lblHowManyGuest.adjustsFontSizeToFitWidth = true
        
        self.btnBooking.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.btnBooking.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnBooking.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    func changeTextAsLanguage() {
        self.lblDuration.text = Vocabulary.getWordFromKey(key: "duration")
        self.lblBooking.text = Vocabulary.getWordFromKey(key: "Booking")
        self.lblWhen.text = Vocabulary.getWordFromKey(key: "when")
        self.lblTime.text = Vocabulary.getWordFromKey(key: "Time")
        self.lblHowManyGuest.text = Vocabulary.getWordFromKey(key: "HowManyGuest")
        self.lblBokkingOption.text = Vocabulary.getWordFromKey(key: "BookingOption")
        self.btnBooking.setTitle(Vocabulary.getWordFromKey(key: "nextSetp"), for: .normal)
    }
    func configureCoachInstructionHint(){
        self.coachMarksController.overlay.allowTap = false
        self.coachMarksController.dataSource = self
        self.coachMarksController.delegate = self
        
    }
    func startInstructions() {
        
        //self.coachMarksController.start(in: .window(over: self))
    }
    func customiseNavigationView() {
        UIApplication.shared.statusBarStyle = .default
        self.navView.backgroundColor = UIColor.white
        self.lblBooking.textColor = UIColor.black
        let backBtnImg = #imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate)
        self.btnBack.setImage(backBtnImg, for: .normal)
        self.btnBack.tintColor = UIColor.black
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        return
        if self.view.bounds.height > 811 { // iPhone X
            if self.tableViewBooking.contentOffset.y == -44.0 {
                DispatchQueue.main.async {
                    UIApplication.shared.statusBarStyle = .lightContent
                    self.navView.backgroundColor = UIColor.clear
                    self.lblBooking.textColor = UIColor.white
                    let backBtnImg = #imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate)
                    self.btnBack.setImage(backBtnImg, for: .normal)
                    self.btnBack.tintColor = UIColor.white
                }
            } else {
                DispatchQueue.main.async {
                    self.customiseNavigationView()
                }
            }
        } else {
            if self.tableViewBooking.contentOffset.y == -20.0 {
                DispatchQueue.main.async {
                    UIApplication.shared.statusBarStyle = .lightContent
                    self.navView.backgroundColor = UIColor.clear
                    self.lblBooking.textColor = UIColor.white
                    let backBtnImg = #imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate)
                    self.btnBack.setImage(backBtnImg, for: .normal)
                    self.btnBack.tintColor = UIColor.white
                }
            } else {
                DispatchQueue.main.async {
                    self.customiseNavigationView()
                }
            }
        }
    }
    
    // MARK: - Custom Methods
    func configureTotalPriceOnHourly(){
        let hourMin = self.getHoursMinute(time: self.bookingDurationTime)
        var hours:CGFloat = CGFloat(hourMin.hours)
        if hourMin.min == 30{
             hours = hours+0.5
        }
        if self.isPricePerPersonHourly{
            if let n = NumberFormatter().number(from: objExperience!.pricepersonhourly) {
                let pricepersonHourly = CGFloat(truncating: n)
                let totalPrice = pricepersonHourly*hours*CGFloat(self.numberOfGuest)
                self.totalPriceOnHourly = "\(totalPrice)"
            }
        }else if self.isGroupPriceHourly{
            if let n = NumberFormatter().number(from: objExperience!.groupPricehourly) {
                 let grouppriceHourly = CGFloat(truncating: n)
                let totalPrice = grouppriceHourly*hours
                self.totalPriceOnHourly = "\(totalPrice)"
            }
        }
    }
    func getHoursMinute(time:String)->(hours:Int,min:Int){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let date = dateFormatter.date(from:time){
            let calendar = Calendar.current
            let comp = calendar.dateComponents([.hour, .minute], from: date)
            var hour = comp.hour
            var minute = comp.minute
            if minute! < 30 {
                if minute! != 0{
                    minute = 30
                }
            }else if minute! > 30{
                minute = 0
                hour! += 1
            }else{
                
            }
            return (hour!,minute!)
        }
        return (0,0)
    }
    func configureTableView(){
        if let _ = self.tableViewBooking.tableHeaderView{
            self.tableViewBooking.tableHeaderView?.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.tableViewBooking.bounds.width, height:self.tableViewHeaderHeight))
        }
        if let _ = self.tableViewBooking.tableFooterView{
            self.tableViewBooking.tableFooterView?.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.tableViewBooking.bounds.width, height: self.tableViewFooterHeight))
        }
        self.bookingOption.delegate = self
        self.bookingOption.dataSource = self
        self.bookingOption.backgroundColor = UIColor(hexString: "#E5D2D5DB")
        self.tableViewBooking.delegate = self
        self.tableViewBooking.dataSource = self
        self.configureBookingOptionToolBar()
        self.txtBookingOptions.inputView = self.bookingOption
        self.txtBookingOptions.delegate = self
        self.txtBookingOptions.inputAccessoryView = self.bookingOptionToolbar
        self.configureSelectedBooking()
        
        self.bookingTimeSlotPicker.delegate = self
        self.bookingTimeSlotPicker.dataSource = self
        self.txtBookingTimeSlot.delegate = self
        self.configureBookingTimeSlotToolBar()
        self.txtBookingTimeSlot.inputView = self.bookingTimeSlotPicker
        self.txtBookingTimeSlot.inputAccessoryView = self.bookingTimeSlotToolbar
        
        //self.configureSelectedBookingTimeSlot()
        self.configureTimePicker()
        
        self.configureBookingDurationPicker()
        self.txtExperienceBookingDuration.inputView = self.bookingDurationPicker
        self.txtExperienceBookingDuration.inputAccessoryView = self.bookingDurationToolbar
        
        self.timePicker.minimumDate = Date()
//        self.txtBookingTimeSlot.inputView = self.timePicker
//        self.txtBookingTimeSlot.inputAccessoryView = self.timeToolBar
        
    }
    func configureTimeCollectionView(){
//        self.timeCollectionView.delegate = self
//        self.timeCollectionView.dataSource = self
        
    }
    func configureBookingOptionToolBar(){
        self.bookingOptionToolbar.sizeToFit()
        self.bookingOptionToolbar.layer.borderColor = UIColor.lightGray.cgColor
        self.bookingOptionToolbar.layer.borderWidth = 0.5
        self.bookingOptionToolbar.clipsToBounds = true
        self.bookingOptionToolbar.backgroundColor = UIColor.white
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(BookingViewController.doneBookingOptionPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let title = UILabel.init()
        title.font = UIFont(name: "Avenir-Heavy", size: 15.0)
        title.text = "\(Vocabulary.getWordFromKey(key:"BookingOption"))"
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(BookingViewController.cancelBookingOptionPicker))
        self.bookingOptionToolbar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
    }
    func configureBookingTimeSlotToolBar(){
        self.bookingTimeSlotToolbar.sizeToFit()
        self.bookingTimeSlotToolbar.layer.borderColor = UIColor.lightGray.cgColor
        self.bookingTimeSlotToolbar.layer.borderWidth = 0.5
        self.bookingTimeSlotToolbar.clipsToBounds = true
        self.bookingTimeSlotToolbar.backgroundColor = UIColor.white
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(BookingViewController.doneBookingTimeSlotPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let title = UILabel.init()
        title.text = "\(Vocabulary.getWordFromKey(key:"Time"))"
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(BookingViewController.cancelBookingOptionPicker))
        self.bookingTimeSlotToolbar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
    }
    func configureInstantBooking(){
        
    }
    func sizeFooterToFit() {
        if let footerView =  self.tableViewBooking.tableFooterView {
            footerView.setNeedsLayout()
            footerView.layoutIfNeeded()
            
            let height = footerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var frame = footerView.frame
            frame.size.height = height
            footerView.frame = frame
            self.tableViewBooking.tableFooterView = footerView
        }
    }
    func configureBookingDurationPicker(){
        
        self.bookingDurationToolbar.sizeToFit()
        self.bookingDurationToolbar.layer.borderColor = UIColor.clear.cgColor
        self.bookingDurationToolbar.layer.borderWidth = 1.0
        self.bookingDurationToolbar.clipsToBounds = true
        self.bookingDurationToolbar.backgroundColor = UIColor.white
        self.bookingDurationPicker.datePickerMode = .time
        self.bookingDurationPicker.locale = Locale(identifier: "en_GB")
        
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(BookingViewController.doneDurationTimePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "\(Vocabulary.getWordFromKey(key:"duration"))", attributes:[NSAttributedStringKey.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(BookingViewController.cancelDurationTimePicker))
        self.bookingDurationToolbar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
    }
    @objc func doneDurationTimePicker(){
        let date =  self.bookingDurationPicker.date
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
            if self.isValidDurationTime(hour: hour, min: minute){
                self.bookingDurationTime = "\(strHour):\(strMinute)"
            }else{
                
            }
            print("\(strHour):\(strMinute)")
        }
        //dismiss date picker dialog
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    @objc func cancelDurationTimePicker(){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    func isValidDurationTime(hour:Int,min:Int)->Bool{
        let hoursMin = self.getHoursMinute(time:"\(self.objExperience!.duration)")
        let exprienceHour = hoursMin.hours
        let experienceMin = hoursMin.min
        let validationMSG = "Selected duration must not be more than \(exprienceHour):\(experienceMin)"
        guard hour <= exprienceHour  else {
            ShowToast.show(toatMessage:"\(validationMSG)")
            return false
        }
        guard experienceMin != 30 else {
            if hour <= exprienceHour{
                if hour == exprienceHour{
                    if min > 30{
                        ShowToast.show(toatMessage:"\(validationMSG)")
                        return false
                    }
                }
                return true
            }else{
                ShowToast.show(toatMessage:"\(validationMSG)")
                return false
            }
        }
        return true
    }
    func configureTimePicker(){
        self.timeToolBar.sizeToFit()
        self.timeToolBar.layer.borderColor = UIColor.clear.cgColor
        self.timeToolBar.layer.borderWidth = 1.0
        self.timeToolBar.clipsToBounds = true
        self.timeToolBar.backgroundColor = UIColor.white
        self.timePicker.datePickerMode = .time
        self.timePicker.locale = Locale(identifier: "en_US")

        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(BookingViewController.doneTimePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "\(Vocabulary.getWordFromKey(key:"pickStartTime"))", attributes:[NSAttributedStringKey.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(BookingViewController.cancelTimePicker))
        self.timeToolBar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
    }
    @objc func cancelTimePicker(){
        //cancel button dismiss datepicker dialog
        
        self.view.endEditing(true)
        DispatchQueue.main.async {
            self.configureCustomTimePicker(isCustomTime: false)
           // self.buttonForgroundShadow.isHidden = true
           // self.tableViewSchedule.reloadData()
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
            self.selectedTimeSlotIndex = self.arrayOfTimeSlot.count - 1
            DispatchQueue.main.async {
                self.txtBookingTimeSlot.text = self.selectedTime.converTo12hoursFormate()
            }
            self.configureCustomTimePicker(isCustomTime: false)
            
            //self.configureScheduleType()
        }
        //self.buttonForgroundShadow.isHidden = true
        //dismiss date picker dialog
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    func configureBookingView(){
//        self.txtExperienceDate.layer.borderColor = self.tintBorderColor.cgColor
//        self.txtExperienceDate.layer.borderWidth = 0.7
//        self.txtNumberOfGuest.layer.borderColor = self.tintBorderColor.cgColor
//        self.txtNumberOfGuest.layer.borderWidth = 0.7
        
//        self.bookingOptionsView.layer.borderColor = self.tintBorderColor.cgColor
//        self.bookingOptionsView.layer.borderWidth = 0.7
//        self.bookingPricePerPerson.layer.borderColor = self.tintBorderColor.cgColor
//        self.bookingPricePerPerson.layer.borderWidth = 0.7
//        self.bookingPricePerGroup.layer.borderColor = self.tintBorderColor.cgColor
//        self.bookingPricePerGroup.layer.borderWidth = 0.7
        
        self.btnAddGuest.layer.borderColor = self.tintBorderColor.cgColor
        self.btnAddGuest.layer.borderWidth = 0.7
        self.btnAddGuest.layer.cornerRadius = 15.0
        self.btnAddGuest.clipsToBounds = true
        
        self.btnRemoveGuest.layer.borderColor = self.tintBorderColor.cgColor
        self.btnRemoveGuest.layer.borderWidth = 0.7
        self.btnRemoveGuest.layer.cornerRadius = 15.0
        self.btnRemoveGuest.clipsToBounds = true
        
//        self.leftViewDate.backgroundColor = .clear
        self.leftViewGuest.backgroundColor = .clear

//        self.txtExperienceDate.leftView = leftViewDate
//        self.txtExperienceDate.leftViewMode = .always
        self.txtExperienceDate.contentVerticalAlignment = .center
        
        self.txtNumberOfGuest.leftView = leftViewGuest
        self.txtNumberOfGuest.leftViewMode = .always
        self.txtNumberOfGuest.contentVerticalAlignment = .center
        
//        self.timeCollectionView.layer.borderColor = self.tintBorderColor.cgColor
//        self.timeCollectionView.layer.borderWidth = 0.7
//        self.timeCollectionView.clipsToBounds = true
//        self.timeCollectionView.backgroundColor = lightGrayColor
        
        self.btnBooking.setBackgroundColor(color:UIColor.lightGray.withAlphaComponent(0.5), forState: UIControlState.highlighted)

        if let _ = self.objExperience{
            self.lblExperienceName.text = "\(objExperience!.title)"
            self.numberOfGuest = 1//Int(self.objExperience!.groupSizeMin)!
            
            var parameters:[String:Any] = [:]
            parameters["item_name"] = "Tour Booking"
            parameters["Tour Name"] = "\(self.objExperience!.title)"
            if User.isUserLoggedIn,let user = User.getUserFromUserDefault(){
                parameters["username"] = "\(user.userFirstName) \(user.userLastName)"
                parameters["userID"] = "\(user.userID)"
            }
            CommonClass.shared.addFirebaseAnalytics(parameters: parameters)
            self.addFaceBookAnayltics()
        }
        
    }
    func addFaceBookAnayltics(){
        var parameters:AppEvent.ParametersDictionary = [:]
        parameters["item_name"] = "Tour Booking"
        parameters["Tour Name"] = "\(self.objExperience!.title)"
        if User.isUserLoggedIn,let user = User.getUserFromUserDefault(){
            parameters["username"] = "\(user.userFirstName) \(user.userLastName)"
            parameters["userID"] = "\(user.userID)"
        }
        CommonClass.shared.addFaceBookAnalytics(eventName:"Tour Booking", parameters: parameters)
    }
    func configureNumberOfGuest(){
        //self.txtNumberOfGuest.text = "\(self.numberOfGuest) Person \(self.maximumeNumberOfGuest) available"
        DispatchQueue.main.async {
            self.configureTotalPriceOnHourly()
            self.txtNumberOfGuest.text = "\(self.numberOfGuest) " + "\(Vocabulary.getWordFromKey(key: "person")) "
            self.lblNumberOfGuest.text = "\(self.numberOfGuest)"
            if let _ = self.objExperience{
                if self.isPricePerPerson{
                    self.txtNumberOfGuest.text?.append("(\(self.objExperience!.currency) \(Double(self.numberOfGuest) * Double("\(self.objExperience!.priceperson)")!))")
                }else{
                    self.txtNumberOfGuest.text?.append("(\(self.objExperience!.currency) \(self.objExperience!.groupPrice))")
                }
//                if self.objExperience!.isPricePerPerson,self.objExperience!.priceperson.count > 0{
//                    //self.lblCurrency.text = "\(self.objExperience!.currency) \(Double(self.numberOfGuest) * Double("\(self.objExperience!.priceperson)")!)"
//                    self.txtNumberOfGuest.text?.append("\(self.objExperience!.currency) \(Double(self.numberOfGuest) * Double("\(self.objExperience!.priceperson)")!)")
//                    return
//                }
//                if self.objExperience!.isGroupPrice,self.objExperience!.groupPrice.count > 0{
//                    self.txtNumberOfGuest.text?.append("\(self.objExperience!.currency) \(self.objExperience!.groupPrice)")
//                    return
//                }
            }
        }
    }
    func configurePricePerPerson(){
        if self.isPricePerPerson{
            DispatchQueue.main.async {
                self.heightForExpereinceDuration.constant = 0.0
                
            }
            
        }
//        if self.isPricePerPerson{
//            bookingPricePerPerson.alpha = 1.0
//            imgPricePerPerson.image = #imageLiteral(resourceName: "radioselect").withRenderingMode(.alwaysOriginal)
//            lblPricePerPerson.textColor = UIColor.black
//        }else{
//            bookingPricePerPerson.alpha = 0.7
//            imgPricePerPerson.image = #imageLiteral(resourceName: "radiodeselect").withRenderingMode(.alwaysOriginal)
//            lblPricePerPerson.textColor = UIColor.lightGray
//        }
    }
    func configurePricePerPersonHourly(){
        if self.isPricePerPersonHourly{
            DispatchQueue.main.async {
                self.heightForExpereinceDuration.constant = 72.0
            }
        }
    }
    func configureGroupPrice(){
        if self.isPricePerGroup{
            DispatchQueue.main.async {
                self.heightForExpereinceDuration.constant = 0.0
            }
        }
//        if self.isPricePerGroup{
//            bookingPricePerGroup.alpha = 1.0
//            imgPricePerGroup.image = #imageLiteral(resourceName: "radioselect").withRenderingMode(.alwaysOriginal)
//            lblPricePerGroup.textColor = UIColor.black
//        }else{
//            bookingPricePerGroup.alpha = 0.7
//            imgPricePerGroup.image = #imageLiteral(resourceName: "radiodeselect").withRenderingMode(.alwaysOriginal)
//            lblPricePerGroup.textColor = UIColor.lightGray
//        }
    }
    func configureGroupPriceHourly(){
        if self.isGroupPriceHourly{
            DispatchQueue.main.async {
                self.heightForExpereinceDuration.constant = 72.0
            }
        }
    }
    func isValidBooking()->Bool{
        return false
    }
    func configureDateAndSlots(objTimeSlot:DateSlot){
        self.selectedCell.removeAllObjects()
        
        self.arrayOfTimeSlot = objTimeSlot.slots.filter({$0.isCustomTime == false})
        let customTimeSlots = objTimeSlot.slots.filter({$0.isCustomTime == true})
        if customTimeSlots.count > 0{
            self.arrayOfTimeSlot.append(customTimeSlots.first!)
        }else if self.arrayOfTimeSlot.count > 0{
            let customSlot = Slot.init(slotDetail: ["Time":"None","Slots":"\(self.objExperience!.groupSizeMax)"])
            self.arrayOfTimeSlot.append(customSlot)
        }
        if self.arrayOfTimeSlot.count > 0{
            self.selectedCell.removeAllObjects()
            self.selectedCell.add(0)
            let objSlot = self.arrayOfTimeSlot[0]
            if let _ = self.objExperience{
                self.numberOfGuest = 1//Int(self.objExperience!.groupSizeMin)!
            }
            self.maximumeNumberOfGuest = (objSlot.isCustomTime) ? Int((self.objExperience!.groupSizeMax as NSString).intValue):Int((objSlot.slotsAvaibility as NSString).intValue)
        }
//        self.timeCollectionView.reloadData()
    }
    // MARK: - Selector Methods
    @IBAction func buttonPricePerPersonSelector(sender:UIButton){
        guard self.objExperience!.isPricePerPerson else{
            return
        }
        self.isPricePerPerson = true
        self.isPricePerGroup = false
        self.configureNumberOfGuest()
    }
    @IBAction func buttonPricePerGroupSelector(sender:UIButton){
        guard self.objExperience!.isGroupPrice else{
            return
        }
        self.isPricePerPerson = false
        self.isPricePerGroup = true
        self.configureNumberOfGuest()
    }
    @IBAction func buttonBackSelector(sender:UIButton){
        //PoptoBackViewController
        self.popToBackController()
    }
    @IBAction func buttonBookingSelector(sender:UIButton){
        if self.arrayOfTimeSlot.count > 0,self.selectedCell.allObjects.count > 0,let selectedIndex = self.selectedCell.allObjects.first as? Int,self.arrayOfTimeSlot.count > selectedIndex{
            let objTimeSlot = self.arrayOfTimeSlot[selectedIndex]
            
            let order = Calendar.current.compare(self.selectedDate, to: Date(), toGranularity: .day)
            
            if order == .orderedSame && self.isTimedPassedAway(slotTime: "\(objTimeSlot.slotTime)"){
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key:"pasttime.hint"))
                }
            }else{
                if objTimeSlot.isCustomTime{
                    if self.selectedTime.count > 0{
                        objTimeSlot.slotTime = "\(self.selectedTime)"
                        self.pushPaymentViewController(objSlot:objTimeSlot)
                    }else{
                        CommonClass.shared.showAlertControllerWith(message:"Please select time slot.", title:"No Time")
                    }
                }else{
                    //self.performSegue(withIdentifier: "unwindToDiscover", sender: self)
                    self.pushPaymentViewController(objSlot:objTimeSlot)
                }
            }
        }else{
            CommonClass.shared.showAlertControllerWith(message:Vocabulary.getWordFromKey(key:"noTimeSlot"), title: Vocabulary.getWordFromKey(key:"noTimeSlot.title"))
        }
    }
    func isTimedPassedAway(slotTime:String)->Bool{
        let datetimeFormate = DateFormatter()
        datetimeFormate.dateFormat = "HH:mm"
        let currentDate = Date()
        if  let bookingDate = datetimeFormate.date(from: slotTime),let currentTime = datetimeFormate.date(from: "\(datetimeFormate.string(from: currentDate))"){
            return   currentTime > bookingDate
        }
        return false
    }
    @IBAction func buttonDateSelector(sender:UIButton){
        if self.instanceTimeSlot != nil{
                return
        }
        self.presentCalenderViewController()
    }
    @IBAction func buttonAddGuestSelector(sender:UIButton){
        if self.arrayOfTimeSlot.count > 0,self.selectedCell.count > 0{
            if self.numberOfGuest < maximumeNumberOfGuest{
                self.numberOfGuest += 1
            }
        }
        
    }
    
    @IBAction func buttonReduceGuestSelector(sender:UIButton){
        if self.arrayOfTimeSlot.count > 0,self.selectedCell.count > 0{
            if let _ = self.objExperience,let minPerson = self.objExperience?.groupSizeMin {
                if self.numberOfGuest > 1{//Int(minPerson)!{
                    self.numberOfGuest -= 1
                }
            }
        }
    }
    @IBAction func buttonReViewBooking(sender:UIButton){
            self.presentBookingPreViewController()
    }
    @IBAction func unwindBookingControlleFromCalendarClose(segue: UIStoryboardSegue){
         self.objCoachMarkType = .booking_options
    }
    @IBAction func unwindFromBookingViewController(segue: UIStoryboardSegue) {
        if let calenderViewController = segue.source as? CalenderViewController{
            self.selectedDate = calenderViewController.selectedDate!
             //Calendar.current.dateComponents([.day], from:self.selectedDate)
            if "\(self.dateFormatter.string(from:self.selectedDate))" == "\(self.dateFormatter.string(from:Date()))"{
                self.timePicker.minimumDate = Date()
            }else{
                self.timePicker.minimumDate = nil
            }
            self.txtExperienceDate.text = "\(self.dateFormatter.string(from:self.selectedDate))"
            self.txtExperienceDate.backgroundColor = UIColor.white
            self.txtNumberOfGuest.text = ""
            self.lblNumberOfGuest.text = "\(self.numberOfGuest)"
            if let dateSlot = calenderViewController.selectedDateSlot{
                self.configureDateAndSlots(objTimeSlot:dateSlot)
            }else{
                self.selectedCell.removeAllObjects()
                self.arrayOfTimeSlot = []
//                self.timeCollectionView.reloadData()
            }
            self.selectedTimeSlotIndex = calenderViewController.selectedIndex
            self.objCoachMarkType = .booking_options
            //self.configureSelectedBookingTimeSlot()
        }
    }
    // MARK: - API Request Methods
    func getTodayBookingTimeSlots() {
        if let _ = self.objExperience,self.objExperience!.id.count > 0{
            let objDateFormatter = DateFormatter()
            objDateFormatter.dateFormat = "MM/dd/yyyy"
        //Get Occurence Date
            let requestURL = "experience/\(self.objExperience!.id)/native/occurrences?startdate=\(objDateFormatter.string(from:Date()))&enddate=\(objDateFormatter.string(from: Date()))"
            //let requestURL = "experience/3/native/occurrences?startdate=\(dateFormatter.string(from:Date()))&enddate=\(dateFormatter.string(from: Date()))"
            APIRequestClient.shared.sendRequest(requestType: .GET, queryString: requestURL, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let arraySuccess = successDate["AvailableCalender"] as? [[String:Any]]{
                    var arrayDateSlots:[DateSlot] = []
                    for dateObject in arraySuccess{
                        let objDateSlot = DateSlot.init(dateSlotDetail: dateObject)
                        arrayDateSlots.append(objDateSlot)
                    }
                    if let _ = self.instanceTimeSlot{
                        self.configureOnlyInstantBooking()
                    }else if arrayDateSlots.count > 0{
                    if let objeDateSlot = arrayDateSlots.first{
                        DispatchQueue.main.async {
//                            if let _ = self.instanceTimeSlot{
//                                let arraySlot = objeDateSlot.slots
//                                var arrayWithInstant:[Slot] = [self.instanceTimeSlot!]
//                                arrayWithInstant.append(contentsOf: arraySlot)
//                                objeDateSlot.slots = arrayWithInstant
//                            }
                            self.configureDateAndSlots(objTimeSlot: objeDateSlot)
                            self.configureSelectedBookingTimeSlot()
                            
                         }
                        }
                        defer{
                            if let _ = self.objOccurence{
                                DispatchQueue.main.async {
                                    self.presentCalenderViewControllerWithOccurence()
                                }
                            }
                        }
                    }else{
                        if let _ = self.instanceTimeSlot{
                           self.configureOnlyInstantBooking()
                        }
                         self.configureSelectedBookingTimeSlot()
                        defer{
                            if let _ = self.objOccurence{
                                DispatchQueue.main.async {
                                    self.presentCalenderViewControllerWithOccurence()
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.txtExperienceDate.text = "\(self.dateFormatter.string(from:Date()))"
                        self.txtExperienceDate.backgroundColor = UIColor.white
                        self.txtNumberOfGuest.text = ""
                        self.lblNumberOfGuest.text = "\(self.numberOfGuest)"

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
    func  getUserGuideCulture(){
        let getUserCulture = "users/native/userculture"
        let guideCultureParameters = ["UserId":"\(self.objExperience!.guide!.guideId)" as AnyObject]
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: getUserCulture, parameter:guideCultureParameters, isHudeShow:true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let userCulture = successData["UserCulture"]{
                
                let guideBookingDate = self.getGuideLocalDate(local:"\(userCulture)")
                self.experienceBookingWithOutPaymentRequest(bookingDate: guideBookingDate)
            }else{
                self.experienceBookingWithOutPaymentRequest(bookingDate: self.getGetLocalDate())
            }
        }) { (responseFail) in
            self.experienceBookingWithOutPaymentRequest(bookingDate: self.getGetLocalDate())
        }
    }
    func getGuideLocalDate(local:String)->String{
        let objDateFormatter = DateFormatter()
        objDateFormatter.dateStyle = .medium
        objDateFormatter.locale = NSLocale.init(localeIdentifier:local) as Locale
        let bookingDate = "\(objDateFormatter.string(from: self.selectedDate))"
        
        return bookingDate
    }
    func isValidTimeSlotSelection(objSlot:Slot,validSlotParameters:[String:Any]){
        let isValidBookingTimeURL = "experience/native/validatebookingtime"
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:isValidBookingTimeURL, parameter: validSlotParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any] {
                if let _ = successData["IsExists"],!(successData["IsExists"] is NSNull){
                    if  Bool.init("\(successData["IsExists"]!)"){
                        if let strMessage = successData["Message"] as? String{
                            DispatchQueue.main.async {
                                ShowToast.show(toatMessage:strMessage)
                            }
                        }
                    }else{
                        self.getUserGuideCulture()
                        //self.experienceBookingWithOutPaymentRequest()
                    }
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }) { (responseFail) in
            if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                        let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key: "isValidTime Error"), message: "Server error \(validSlotParameters)", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key: "ok.title"), style: .cancel, handler: nil))
                        alertController.view.tintColor = UIColor.init(hexString:"36527D")
                        //self.present(alertController, animated: true, completion: nil)
                        ShowToast.show(toatMessage:"Error something went wrong.")
                    
                    //ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
    }
    func getDeviceCulture() -> String {
        let locale = Locale.current
        guard let languageCode = locale.languageCode,
            let regionCode = locale.regionCode else {
                return "de_DE"
        }
        return languageCode + "_" + regionCode
    }
    func getGetLocalDate()->String{
        let objDateFormatter = DateFormatter()
        objDateFormatter.dateStyle = .medium
        objDateFormatter.locale = NSLocale.init(localeIdentifier: "\(self.getDeviceCulture())") as Locale
        //objDateFormatter.locale = NSLocale.init(localeIdentifier: "en_NO") as Locale
        let bookingDate = "\(objDateFormatter.string(from: self.selectedDate))"

       return bookingDate
    }
    func experienceBookingWithOutPaymentRequest(bookingDate:String){
        guard let _ = self.objExperience  else {
            return
        }
        print("\(self.getGetLocalDate())")
        
        DispatchQueue.main.async {
            var experienceBookingParameters:[String:Any] = [:]
            let objDateFormatter = DateFormatter()
            objDateFormatter.dateFormat = "MM/dd/yyyy"
            //objDateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale
            let bookingDateMMDDYY = "\(objDateFormatter.string(from: self.selectedDate))"
            //bookingDate = "\(self.getGetLocalDate())"
            experienceBookingParameters[self.kDate] = bookingDateMMDDYY
            experienceBookingParameters[self.kExperience_id] = "\(self.objExperience!.id)"
            
            var price = ""
            var isHourly:Bool = false
            var bookingDuration:String = ""
            if self.isPricePerGroup{ //group booking
                price = "\(self.objExperience!.groupPrice)"
                experienceBookingParameters[self.kPrice] = "\(self.objExperience!.groupPrice)"
                isHourly = false
                bookingDuration = ""
            }else if self.isPricePerPersonHourly{ //price per person
                isHourly = true
                bookingDuration = self.bookingDurationTime
                price = self.totalPriceOnHourly
                experienceBookingParameters[self.kPrice] = "\(price)"
            }else if self.isGroupPriceHourly{ // price per group
                isHourly = true
                bookingDuration = self.bookingDurationTime
                price = self.totalPriceOnHourly
                experienceBookingParameters[self.kPrice] = "\(price)"
            }else{ //price per person booking
                isHourly = false
                bookingDuration = ""
                price = "\(Int(self.objExperience!.priceperson)! * self.numberOfGuest)"
                experienceBookingParameters[self.kPrice] = "\(price)"
            }
            experienceBookingParameters["bookingduration"] = bookingDuration
            experienceBookingParameters["ishourly"] = "\(isHourly)"
            experienceBookingParameters[self.kSlots] = "\(self.numberOfGuest)"
            var bookingTime = ""
            bookingTime = "\(self.txtBookingTimeSlot.text!)".converTo24hoursFormate()
            
            experienceBookingParameters[self.kUserID] = "\(User.getUserFromUserDefault()!.userID)"
            let userName = "\(User.getUserFromUserDefault()!.userFirstName) \(User.getUserFromUserDefault()!.userLastName)"
            experienceBookingParameters[self.kUserName] = userName
            experienceBookingParameters[self.kIsGroupBooking] = "\(self.isPricePerGroup)"
            experienceBookingParameters[self.kBookingID] = "\(0)"
            experienceBookingParameters[self.kBookingStatus] = "RequestedByTraveler"
            experienceBookingParameters[self.kNotification_body] = "\(userName) wants to book \"\(self.objExperience!.title)\" on \(bookingDate) at \(bookingTime.converTo12hoursFormate()) and ready to pay \(self.objExperience!.currency) \(price), Do you accept?"
            if let _ = self.instanceTimeSlot{
                experienceBookingParameters[self.kInstant_booking] = "true"
            }else{
                experienceBookingParameters[self.kInstant_booking] = "false"
            }
            experienceBookingParameters[self.kTime] = bookingTime
            
            experienceBookingParameters[self.kGuide_id] = "\(self.objExperience!.guide!.guideId)"
            
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kExperienceBookingWithOutPayment, parameter: experienceBookingParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let strMSG = successData["Message"] as? String {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key: "Booking"), message: "\(strMSG)", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key: "ok.title"), style: .default, handler: { (_) in
                            DispatchQueue.main.asyncAfter(deadline: .now())  {
                                if let currentUser = User.getUserFromUserDefault(){
                                    currentUser.isBookingHintShown = true
                                    currentUser.setUserDataToUserDefault()
                                }
                                self.performSegue(withIdentifier: "unwindToDiscover", sender: self)
                            }
                        }))
                        alertController.view.tintColor = UIColor.init(hexString:"36527D")
                        self.present(alertController, animated: true, completion: nil)
                    }
                }else{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:kCommonError)
                    }
                }
            }) { (responseFail) in
                if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: "\(errorMessage)")
                    }
                }else{
                    DispatchQueue.main.async {
                        let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key: "Booking Error"), message: "Server error \(experienceBookingParameters)", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key: "ok.title"), style: .cancel, handler: nil))
                        alertController.view.tintColor = UIColor.init(hexString:"36527D")
                        //self.present(alertController, animated: true, completion: nil)
                        ShowToast.show(toatMessage:"Error something went wrong")
                    }
                }
            }
        }
    }
    func configureOnlyInstantBooking(){
        let dateSlot:DateSlot = DateSlot.init(dateSlotDetail: ["Date":"\(self.dateFormatter.string(from:Date()))"])
        dateSlot.slots = [self.instanceTimeSlot!]
        DispatchQueue.main.async {
            self.configureDateAndSlots(objTimeSlot: dateSlot)
            self.configureSelectedBookingTimeSlot()
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    //PushToBack
    func popToBackController(){
        self.navigationController?.popViewController(animated: true)
    }
    func presentBookingPreViewController(){
        DispatchQueue.main.async {
            if let bookingPreView = self.storyboard?.instantiateViewController(withIdentifier: "BookingPreViewController") as? BookingPreViewController{
                var experienceBookingParameters:[String:Any] = [:]
                let objDateFormatter = DateFormatter()
                objDateFormatter.dateFormat = "MM/dd/yyyy"
                let bookingDate = "\(objDateFormatter.string(from: self.selectedDate))"
                
                experienceBookingParameters[self.kDate] = bookingDate
                experienceBookingParameters[self.kExperience_name] = "\(self.objExperience!.title)"
                experienceBookingParameters[self.kExperience_currency] = "\(self.objExperience!.currency)"
                var price = ""
                if self.isPricePerGroup{
                    price = "\(self.objExperience!.groupPrice)"
                    experienceBookingParameters[self.kPrice] = "\(self.objExperience!.groupPrice)"
                }else{
                    price = "\(Int(self.objExperience!.priceperson)! * self.numberOfGuest)"
                    experienceBookingParameters[self.kPrice] = "\(self.objExperience!.priceperson)"
                }
                 experienceBookingParameters[self.kPrice] = price
                experienceBookingParameters["priceperperson"] = "\(self.objExperience!.priceperson)"
                experienceBookingParameters[self.kSlots] = "\(self.numberOfGuest)"
                var bookingTime = ""
                bookingTime = "\(self.txtBookingTimeSlot.text!)".converTo24hoursFormate()
                experienceBookingParameters[self.kIsGroupBooking] = "\(self.isPricePerGroup)"
                experienceBookingParameters[self.kTime] = bookingTime
                bookingPreView.modalPresentationStyle = .overFullScreen
                self.view.endEditing(true)
                bookingPreView.delegate = self
                bookingPreView.bookingPreViewParameters = experienceBookingParameters
                bookingPreView.isPricePerPersonHourly = self.isPricePerPersonHourly
                bookingPreView.isGroupPriceHourly = self.isGroupPriceHourly
                bookingPreView.objExperience = self.objExperience!
                bookingPreView.duration = self.bookingDurationTime
                bookingPreView.roundOfDuration = self.getHoursMinute(time: self.bookingDurationTime)
                bookingPreView.totoalPriceHourly = self.totalPriceOnHourly
                self.present(bookingPreView, animated: false, completion: nil)
            }
        }
       
    }
    //Present CalenderView
    func presentCalenderViewControllerWithOccurence(){
        self.selectedDate = self.getCalendarSelectedDateOnOccurence()//Calendar.current.date(byAdding: .day, value: 1, to: self.selectedDate) ?? Date()
        if let calenderViewController = self.storyboard?.instantiateViewController(withIdentifier:"CalenderViewController") as? CalenderViewController{
            calenderViewController.selectedDate = self.selectedDate
            if let _ = self.objExperience{
                calenderViewController.objExperience = self.objExperience!
            }
            if let _ = self.objOccurence{
                print(self.objOccurence!.recurrence)
                print(self.objOccurence!.recurrenceDay)
            }
            self.navigationController?.present(calenderViewController, animated: true, completion: nil)
        }
    }
    func getCalendarSelectedDateOnOccurence()->Date{
        if let currentOccurence = self.objOccurence{
            let objDateFormatter = DateFormatter()
            objDateFormatter.dateFormat = "MM/dd/yyyy"
            let occurence = currentOccurence.recurrence
            currentOccurence.recurrenceDay = String(currentOccurence.recurrenceDay.dropFirst())
            currentOccurence.recurrenceDay = String(currentOccurence.recurrenceDay.dropLast())
            if occurence.compareCaseInsensitive(str: "\(Vocabulary.getWordFromKey(key:"Custom"))") ||
                occurence.compareCaseInsensitive(str: "\(Vocabulary.getWordFromKey(key:"Once"))") ||
                occurence.compareCaseInsensitive(str:"\(Vocabulary.getWordFromKey(key:"Monthly"))"){
                let dateArray = currentOccurence.recurrenceDay.components(separatedBy:",")
                var aryDate:[Date] = []
                for strdate in dateArray{
                    let newStrDate = strdate.removingWhitespacesAndNewlines
                    if let objDate = objDateFormatter.date(from: newStrDate.replacingOccurrences(of: "\"", with: "")){
                      aryDate.append(objDate)
                    }
                }
                let currentMonth = Calendar.current.component(.month, from: Date())
                let currentMonthDates = aryDate.filter({$0.month == currentMonth})
                if currentMonthDates.count > 0{
                    let finalaryDate = currentMonthDates.sorted(by: { $0.compare($1) == .orderedDescending })
                    return finalaryDate.first!
                }
                return Date()
            }else if occurence.compareCaseInsensitive(str: "\(Vocabulary.getWordFromKey(key:"Daily"))"){
                print(currentOccurence.recurrenceDay)
                return Date()
            }else if occurence.compareCaseInsensitive(str:"\(Vocabulary.getWordFromKey(key:"Weekly"))"){
                var nextDay = Int(currentOccurence.recurrenceDay.removingWhitespacesAndNewlines) ?? 0
                nextDay += 1
                let weeklyDate = Date().next(Date.Weekday(rawValue: nextDay)!, considerToday: true)
                let currentMonth = Calendar.current.component(.month, from: Date())
                let nextWeeklyMonth = Calendar.current.component(.month, from: weeklyDate)
                if currentMonth == nextWeeklyMonth{
                    return Date().next(Date.Weekday(rawValue: nextDay)!, considerToday: true)
                }else{
                    return Date()
                }
            }else if occurence.compareCaseInsensitive(str:"\(Vocabulary.getWordFromKey(key:"Weekdays"))"){
                print(currentOccurence.recurrenceDay)
                let currentDay = Calendar.current.component(.weekday, from: Date())
                if currentDay == 1 ||  currentDay == 7{
                    return Date().next(.monday)
                }else{
                    return Date()
                }
            }else{
                return Date()
            }
        }else{
            return Date()
        }
    }
    
    func presentCalenderViewController(){
        if let calenderViewController = self.storyboard?.instantiateViewController(withIdentifier:"CalenderViewController") as? CalenderViewController{
            calenderViewController.selectedDate = self.selectedDate
            if let _ = self.objExperience{
                calenderViewController.objExperience = self.objExperience!
            }
            
            self.navigationController?.present(calenderViewController, animated: true, completion: nil)
        }
    }
    //PushToPaymentView
    func pushPaymentViewController(objSlot:Slot){
        var validTimeSlotParameter:[String:Any] = [:]
        validTimeSlotParameter["ExperienceId"] = "\(self.objExperience!.id)"
        let objDateFormatter = DateFormatter()
        objDateFormatter.dateFormat = "MM/dd/yyyy"
        let bookingDate = "\(objDateFormatter.string(from: self.selectedDate))"
        validTimeSlotParameter["BookingDate"] = "\(bookingDate)"
        validTimeSlotParameter["Time"] = "\(objSlot.slotTime)"
        validTimeSlotParameter["UserId"] = "\(User.getUserFromUserDefault()!.userID)"
        self.isValidTimeSlotSelection(objSlot:objSlot,validSlotParameters: validTimeSlotParameter)
        
    }
}
extension BookingViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension BookingViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    /*func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.bookingOption{
            return self.bookingOptions[row]
        }else{
//            if self.arrayOfTimeSlot.count > 0 {
                if self.arrayOfTimeSlot.count > row{
                    let objSlot = self.arrayOfTimeSlot[row]
                    return  (objSlot.isCustomTime) ? "\(Vocabulary.getWordFromKey(key:"pickStartTime"))":"\(objSlot.slotTime)"
                    //( \(objSlot.slotsAvaibility) )"
                }else{
                    return ""
                }
            }
    } */
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if pickerView == self.bookingOption{
            return  NSAttributedString(string: "\(self.bookingOptions[row])", attributes: [NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 17)!,NSAttributedStringKey.foregroundColor: UIColor.black])
        }else{
            if self.arrayOfTimeSlot.count > row{
                let objSlot = self.arrayOfTimeSlot[row]
                if objSlot.isCustomTime{
                    return NSAttributedString(string: "\(Vocabulary.getWordFromKey(key:"pickStartTime"))", attributes: [NSAttributedStringKey.font : UIFont(name: "Avenir-Heavy", size: 17)!,NSAttributedStringKey.foregroundColor: UIColor.init(hexString: "36527D")])
                }else{
                    return NSAttributedString(string: "\(objSlot.slotTime)".converTo12hoursFormate(), attributes: [NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 17)!,NSAttributedStringKey.foregroundColor: UIColor.black])
                }
            }else{
                return NSAttributedString()
            }
        }
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return UIScreen.main.bounds.width
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
          if pickerView == self.bookingOption{
            return self.bookingOptions.count
          }else{
            return self.arrayOfTimeSlot.count
         }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.bookingOption{
            self.currentBookingOption = "\(self.bookingOptions[row])"
        }else{
            self.currentTimeSlotIndex = row
        }
    }
    @objc func cancelBookingOptionPicker(){
        DispatchQueue.main.async {
            self.configureCustomTimePicker(isCustomTime: false)
            self.tableViewBooking.scrollsToTop = true
            self.shadowViewBtn.isHidden = true
            self.view.endEditing(true)
            self.currentTimeSlotIndex = 0
        }
        
    }
    
    @objc func doneBookingOptionPicker(){
        self.selectedBookingOption = self.currentBookingOption
        DispatchQueue.main.async {
            self.shadowViewBtn.isHidden = true
            self.view.endEditing(true)
            self.configureSelectedBooking()
        }
    }
    @objc func doneBookingTimeSlotPicker(){
        DispatchQueue.main.async {
            if self.arrayOfTimeSlot[self.currentTimeSlotIndex].isCustomTime{
                self.configureCustomTimePicker(isCustomTime: true)
                self.txtBookingTimeSlot.resignFirstResponder()
                self.txtBookingTimeSlot.becomeFirstResponder()
            }else{
                self.configureCustomTimePicker(isCustomTime: false)
                self.selectedTimeSlotIndex = self.currentTimeSlotIndex
                self.shadowViewBtn.isHidden = true
                self.view.endEditing(true)
            }
            
            
        }
    }
    func configureCustomTimePicker(isCustomTime:Bool){
            if isCustomTime{
                self.txtBookingTimeSlot.inputView = self.timePicker
                self.txtBookingTimeSlot.inputAccessoryView = self.timeToolBar
            }else{
                if self.arrayOfTimeSlot.count == 1,let objSlot = self.arrayOfTimeSlot.first,objSlot.isCustomTime{
                    self.txtBookingTimeSlot.inputView = self.timePicker
                    self.txtBookingTimeSlot.inputAccessoryView = self.timeToolBar
                }else{
                    self.txtBookingTimeSlot.inputView = self.bookingTimeSlotPicker
                    self.txtBookingTimeSlot.inputAccessoryView = self.bookingTimeSlotToolbar
                }
            }

        
    }
    func configureSelectedBooking(){
        self.numberOfGuest = 1
        self.txtBookingOptions.text = "\(self.selectedBookingOption)"
        if "\(self.selectedBookingOption)" == "\(Vocabulary.getWordFromKey(key: "priceperperson"))".firstUppercased{
            self.isPricePerPerson = true
            self.isPricePerGroup = false
            self.isPricePerPersonHourly = false
            self.isGroupPriceHourly = false
        }else if "\(self.selectedBookingOption)" == "\(Vocabulary.getWordFromKey(key: "priceperpersonhourly.hint"))".firstUppercased{
            self.isPricePerPerson = false
            self.isPricePerGroup = false
            self.isPricePerPersonHourly = true
            self.isGroupPriceHourly = false
        }else if "\(self.selectedBookingOption)" == "\(Vocabulary.getWordFromKey(key: "grouppricehourly.hint"))".firstUppercased{
            self.isPricePerPerson = false
            self.isPricePerGroup = false
            self.isPricePerPersonHourly = false
            self.isGroupPriceHourly = true
        }else{
            self.isPricePerPerson = false
            self.isPricePerGroup = true
            self.isPricePerPersonHourly = false
            self.isGroupPriceHourly = false
        }
    }
    func configureSelectedBookingTimeSlot(){
        DispatchQueue.main.async {
            guard self.arrayOfTimeSlot.count > 0 else {
                self.txtBookingTimeSlot.text = "\(Vocabulary.getWordFromKey(key: "pickStartTime"))"
                self.txtBookingTimeSlot.isEnabled = true
                self.maximumeNumberOfGuest = Int((self.objExperience!.groupSizeMax as NSString).intValue)
                let customSlot = Slot.init(slotDetail: ["Time":"None","Slots":"\(self.objExperience!.groupSizeMax)"])
                self.arrayOfTimeSlot.append(customSlot)
                self.configureCustomTimePicker(isCustomTime: true)
                //self.txtBookingTimeSlot.inputView = self.timePicker
                //self.txtBookingTimeSlot.inputAccessoryView = self.timeToolBar
                
                return
            }
            self.configureCustomTimePicker(isCustomTime: false)
            //self.txtBookingTimeSlot.inputView = self.bookingTimeSlotPicker
            //self.txtBookingTimeSlot.inputAccessoryView = self.bookingTimeSlotToolbar
            self.txtBookingTimeSlot.isEnabled = true
            self.selectedCell.removeAllObjects()
            self.selectedCell.add(self.selectedTimeSlotIndex)
            if self.arrayOfTimeSlot.count > self.selectedTimeSlotIndex{
                let objSlot = self.arrayOfTimeSlot[self.selectedTimeSlotIndex]
                if let _ = self.objExperience{
                    self.numberOfGuest = 1//Int(self.objExperience!.groupSizeMin)!
                }
                self.maximumeNumberOfGuest = Int((objSlot.slotsAvaibility as NSString).intValue)
            }
            if self.arrayOfTimeSlot.count > self.selectedTimeSlotIndex{
                let objSlot = self.arrayOfTimeSlot[self.selectedTimeSlotIndex]
                self.txtBookingTimeSlot.text = (objSlot.isCustomTime) ? "\(Vocabulary.getWordFromKey(key:"pickStartTime"))":"\(objSlot.slotTime)".converTo12hoursFormate()
                //( \(objSlot.slotsAvaibility) )"
            }
        }
    }
}
extension BookingViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.arrayOfTimeSlot.count > 0{
            collectionView.removeMessageLabel()
        }else{
            collectionView.showMessageLabel(msg:Vocabulary.getWordFromKey(key:"noTimeSlot.title"), backgroundColor: .clear)
        }
        return self.arrayOfTimeSlot.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let timeCell:TimeSlotCollectionCell =  collectionView.dequeueReusableCell(withReuseIdentifier: "TimeSlotCollectionCell", for: indexPath) as! TimeSlotCollectionCell
        if selectedCell.contains(indexPath.item){
            timeCell.backgroundColor = UIColor.white
            timeCell.imgSelected.image = #imageLiteral(resourceName: "radioselect").withRenderingMode(.alwaysOriginal)
            timeCell.lblTime.textColor = UIColor.black
        }else{
            timeCell.backgroundColor = lightGrayColor
            timeCell.imgSelected.image = #imageLiteral(resourceName: "radiodeselect").withRenderingMode(.alwaysOriginal)
            timeCell.lblTime.textColor = UIColor.lightGray
        }
        if self.arrayOfTimeSlot.count > indexPath.item{
            let objSlot = self.arrayOfTimeSlot[indexPath.item]
            timeCell.lblTime.text = "\(objSlot.slotTime) ( \(objSlot.slotsAvaibility) )"
        }
        return timeCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize.init(width: collectionView.bounds.size.width/3.0, height: collectionView.bounds.size.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 0.0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.arrayOfTimeSlot.count > 0 else {
             return
        }
        self.selectedCell.removeAllObjects()
        self.selectedCell.add(indexPath.item)
        if self.arrayOfTimeSlot.count > indexPath.item{
            let objSlot = self.arrayOfTimeSlot[indexPath.item]
            if let _ = self.objExperience{
                self.numberOfGuest = 1//Int(self.objExperience!.groupSizeMin)!
            }
            self.maximumeNumberOfGuest = Int((objSlot.slotsAvaibility as NSString).intValue)
        }
        collectionView.reloadData()
    }
}
extension BookingViewController:CoachMarksControllerDelegate,CoachMarksControllerDataSource{
    //DataSource
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch (self.objCoachMarkType) {
            case .date:
                var objCoachMark = coachMarksController.helper.makeCoachMark(for:self.whenContainer)
                objCoachMark.arrowOrientation = .bottom
                return objCoachMark
            case .booking_options:
                var objCoachMark = coachMarksController.helper.makeCoachMark(for:self.bookingOptionsContainer)
                objCoachMark.arrowOrientation = .bottom
                return objCoachMark
            case .time:
                var objCoachMark = coachMarksController.helper.makeCoachMark(for:self.timeContainer)
                objCoachMark.arrowOrientation = .bottom
                return objCoachMark
            case .guest:
                var objCoachMark = coachMarksController.helper.makeCoachMark(for:self.numberOfGuestContainer)
                objCoachMark.arrowOrientation = .bottom
                return objCoachMark
         }
        /*
        switch(index) {
            
        case 0:
            return coachMarksController.helper.makeCoachMark(for: self.navigationController?.navigationBar) { (frame: CGRect) -> UIBezierPath in
                // This will make a cutoutPath matching the shape of
                // the component (no padding, no rounded corners).
                return UIBezierPath(rect: frame)
            }
        case 1:
            return coachMarksController.helper.makeCoachMark(for: self.handleLabel)
        case 2:
            return coachMarksController.helper.makeCoachMark(for: self.emailLabel)
        case 3:
            return coachMarksController.helper.makeCoachMark(for: self.postsLabel)
        case 4:
            return coachMarksController.helper.makeCoachMark(for: self.reputationLabel)
        default:
            return coachMarksController.helper.makeCoachMark()
        }
        */
//        var objCoachMark = coachMarksController.helper.makeCoachMark(for:self.whenContainer)
//        objCoachMark.arrowOrientation = .bottom
//        return objCoachMark//coachMarksController.helper.makeCoachMark(for:self.whenContainer)
        //return CoachMark()
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
      
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        //coachViews.bodyView.isHighlighted = true
        coachViews.bodyView.nextLabel.text = "Ok"
        coachViews.bodyView.nextLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        coachViews.bodyView.hintLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        coachViews.bodyView.nextLabel.textColor = UIColor.init(hexString: "36527D")
        coachViews.bodyView.hintLabel.textColor = UIColor.black
        switch (self.objCoachMarkType) {
        case .date:
            coachViews.bodyView.hintLabel.text = self.dateHintText
        case .booking_options:
            coachViews.bodyView.hintLabel.text = self.bookingOptionText
        case .time:
            coachViews.bodyView.hintLabel.text = self.timeHintText
        case .guest:
            coachViews.bodyView.hintLabel.text = self.guestText

        }
        /*
        switch(index) {
        case 0:
            coachViews.bodyView.hintLabel.text = self.profileSectionText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 1:
            coachViews.bodyView.hintLabel.text = self.handleText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 2:
            coachViews.bodyView.hintLabel.text = self.emailText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 3:
            coachViews.bodyView.hintLabel.text = self.postsText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 4:
            coachViews.bodyView.hintLabel.text = self.reputationText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        default: break
        }
         */
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
 
    }
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              willLoadCoachMarkAt index: Int) -> Bool {
        if index == 0 && presentationContext == .controller {
            return false
        }
        
        return true
    }
    //Delegate
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              configureOrnamentsOfOverlay overlay: UIView) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            switch (self.objCoachMarkType) {
            case .date:
                self.lblWhen.invalideField()
                self.txtExperienceDate.invalideField()
                self.whenContainer.invalideField()
            case .booking_options:
                self.lblBokkingOption.invalideField()
                self.txtBookingOptions.invalideField()
                self.bookingOptionsContainer.invalideField()
            case .time:
                self.lblTime.invalideField()
                self.txtBookingTimeSlot.invalideField()
                self.timeContainer.invalideField()
            case .guest:
                self.btnAddGuest.invalideField()
                self.btnRemoveGuest.invalideField()
            }
            
        })
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              willShow coachMark: inout CoachMark,
                              beforeChanging change: ConfigurationChange,
                              at index: Int) {
       
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              didShow coachMark: CoachMark,
                              afterChanging change: ConfigurationChange,
                              at index: Int) {
        
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              willHide coachMark: CoachMark,
                              at index: Int) {
        
       
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              didHide coachMark: CoachMark,
                              at index: Int) {
        switch (self.objCoachMarkType) {
        case .date:
            if self.instanceTimeSlot != nil{
                return
            }
            DispatchQueue.main.async {
                self.presentCalenderViewController()
            }
        case .booking_options:
            DispatchQueue.main.async {
                self.txtBookingOptions.becomeFirstResponder()
            }
        case .time:
            if self.instanceTimeSlot != nil{
                return
            }
            DispatchQueue.main.async {
                self.txtBookingTimeSlot.becomeFirstResponder()
            }
        case .guest:
            if let currentUser = User.getUserFromUserDefault(){
                currentUser.isBookingHintShown = true
                currentUser.setUserDataToUserDefault()
                DispatchQueue.main.async {
                    //Show Preview Selector
                    //self.buttonReviewBooking.isHidden = false
                }
            }
            print("Hide guest")
        }
       
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              didEndShowingBySkipping skipped: Bool) {
       
    }
    func shouldHandleOverlayTap(in coachMarksController: CoachMarksController,
                                at index: Int) -> Bool {
        
        return true
    }
}
extension BookingViewController:BookingPreViewDelegate{
    func bookingPreViewDidHide(isSend: Bool) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
        if isSend{
            self.buttonBookingSelector(sender: self.btnBooking)
        }
    }
}
class TimeSlotCollectionCell:UICollectionViewCell{
    @IBOutlet var imgSelected:UIImageView!
    @IBOutlet var lblTime:UILabel!
    let tintBorderColor:UIColor = UIColor.init(red: 101.0/255.0, green: 131.0/255.0, blue: 191.0/255.0, alpha: 1.0)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderColor = tintBorderColor.cgColor
        self.layer.borderWidth = 0.8
    }
}
protocol BookingPreViewDelegate {
    func bookingPreViewDidHide(isSend:Bool)
}
class BookingPreViewController: UIViewController{
    
    @IBOutlet var lblExperienceTitle:UILabel!
    @IBOutlet var lblDate:UILabel!
    @IBOutlet var lblDateValue:UILabel!
    @IBOutlet var lblTime:UILabel!
    @IBOutlet var lblTimeValue:UILabel!
    @IBOutlet var lblNumberOfGuest:UILabel!
    @IBOutlet var lblNumberOfGuestValue:UILabel!
    @IBOutlet var lblAmount:UILabel!
    @IBOutlet var lblAmountDetail:UILabel!
    @IBOutlet var lblTotalAmount:UILabel!
    @IBOutlet var containerView:UIView!
    @IBOutlet var heightOfContainerView:NSLayoutConstraint!
    @IBOutlet var durationContainer:UIView!
    @IBOutlet var lblDuration:UILabel!
    @IBOutlet var lblDurationValue:UILabel!
    
    var delegate:BookingPreViewDelegate?
    var bookingPreViewParameters:[String:Any] = [:]
    var isGroupBooking:Bool = false
    var isPricePerPersonHourly:Bool = false
    var isGroupPriceHourly:Bool = false
    var objExperience:Experience?
    var duration:String = ""
    var roundOfDuration:(Int,Int) = (0,0)
    var totoalPriceHourly:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.containerView.layer.cornerRadius = 6.0
            self.containerView.clipsToBounds = true
            self.configureParameters()
            self.lblDuration.text = Vocabulary.getWordFromKey(key:"duration")
            if self.duration.count > 0{
                self.lblDurationValue.text = "\(self.duration)"
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.lblDate.text = Vocabulary.getWordFromKey(key: "date")
            self.lblTime.text = Vocabulary.getWordFromKey(key: "Time")
            self.lblNumberOfGuest.text = Vocabulary.getWordFromKey(key: "NumberOfGuest")
        }
    }
    //Custom Methods
    func configureParameters(){
        if let name = bookingPreViewParameters["experience_name"]{
            self.lblExperienceTitle.text = "\(name)"
        }
        if let isGroupBooking = bookingPreViewParameters["isgroup_booking"]{
            self.isGroupBooking = Bool.init("\(isGroupBooking)")
            var objCurrency = ""
            var objPrice = ""
            var objnumeberOfPerson = ""
            var objPricePerPerson = ""
            if let currency = bookingPreViewParameters["experience_currency"]{
                objCurrency = "\(currency)"
            }
            if let price = bookingPreViewParameters["price"]{
                objPrice = "\(price)"
            }
            if let price = bookingPreViewParameters["priceperperson"]{
                objPricePerPerson = "\(price)"
            }
            if let numberOfGuest = bookingPreViewParameters["slots"]{
                objnumeberOfPerson = "\(numberOfGuest)"
                self.lblNumberOfGuestValue.text = "\(numberOfGuest)"
            }
            if self.isGroupBooking{
                self.lblAmountDetail.text =  "\(objnumeberOfPerson) guest (group booking)"
                self.lblTotalAmount.text = "\(objCurrency) \(objPrice)"
                self.durationContainer.isHidden = true
                self.heightOfContainerView.constant = 409.0
            }else if self.isPricePerPersonHourly{
                self.lblAmountDetail.text = "\(objCurrency) \(objExperience!.pricepersonhourly) x \(roundOfDuration.0):\(roundOfDuration.1) hours x \(objnumeberOfPerson) guest"
                self.lblTotalAmount.text = "\(objCurrency) \(totoalPriceHourly)"
                self.durationContainer.isHidden = false
                self.heightOfContainerView.constant = 409.0 + 65.0
            }else if self.isGroupPriceHourly{
                self.lblAmountDetail.text = "\(objCurrency) \(objExperience!.groupPricehourly) x \(roundOfDuration.0):\(roundOfDuration.1) hours\n\(objnumeberOfPerson) guest (group booking)"
                self.lblTotalAmount.text = "\(objCurrency) \(totoalPriceHourly)"
                self.durationContainer.isHidden = false
                self.heightOfContainerView.constant = 409.0 + 65.0 + 20
            }else{
                self.lblAmountDetail.text = "\(objCurrency) \(objPricePerPerson) x \(objnumeberOfPerson) guest"
                self.lblTotalAmount.text = "\(objCurrency) \(objPrice)"
                self.durationContainer.isHidden = true
                self.heightOfContainerView.constant = 409.0

            }
        }
        
        if let objtime = bookingPreViewParameters["time"]{
            self.lblTimeValue.text = "\(objtime)".converTo12hoursFormate()
        }
        if let objdate = bookingPreViewParameters["date"]{
            self.lblDateValue.text = "\(objdate)"
        }
       
        
    }
    //Selector Methods
    @IBAction func buttonSaveSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.bookingPreViewDidHide(isSend: true)
        }
        
    }
    @IBAction func buttonCancelSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.bookingPreViewDidHide(isSend: false)
        }
    }
}
