//
//  OfferDayViewController.swift
//  Live
//
//  Created by IPS on 20/09/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class OfferDayViewController: UIViewController {

    fileprivate let kDate:String = "date"
    fileprivate let kExperience_id:String = "experience_id"
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
    
    @IBOutlet var buttonCancel:UIButton!
    @IBOutlet var buttonSuggestion:UIButton!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var txtOfferDate:UITextField!
    @IBOutlet var txtOfferTime:UITextField!
    @IBOutlet var txtOfferPrice:UITextField!
    @IBOutlet var containerView:UIView!
    @IBOutlet var imageDate:UIImageView!
    @IBOutlet var imageTime:UIImageView!
    @IBOutlet var imagePrice:UIImageView!
    @IBOutlet var bottomConstaintContainer:NSLayoutConstraint!
    @IBOutlet var instantExperienceContainer:UIView!
    @IBOutlet var lblInstantMessage:UILabel!
    @IBOutlet var lblIn:UILabel!
    @IBOutlet var lblMin:UILabel!
    @IBOutlet var txtMintues:UITextField!
    @IBOutlet var bottomStackViewContraint:NSLayoutConstraint!
    @IBOutlet var heightOfContainerView:NSLayoutConstraint!
    @IBOutlet var lblRequestedDate:UILabel!
    @IBOutlet var lblOfferDate:UILabel!
    @IBOutlet var lblRequestedDateTime:UILabel!
    @IBOutlet var lblOfferDateTime:UILabel!
    @IBOutlet var lblCurrency:UILabel!
    
    var isForInstantExperience:Bool = false
    var isForTraveler:Bool = false
    var datePicker:UIDatePicker = UIDatePicker()
    var dateToolBar:UIToolbar = UIToolbar()
    var dateFormatter:DateFormatter = DateFormatter()
    var strDate = ""
    var selectedDate:String{
        get{
            return strDate
        }
        set{
            self.strDate = newValue
            DispatchQueue.main.async {
                self.txtOfferDate.text = newValue
            }
            
        }
    }
    
    var objSchedule:Schedule?
    var timePicker:UIDatePicker = UIDatePicker()
    var timeToolBar:UIToolbar = UIToolbar()
    var time:String = ""
    var selectedTime:String {
        get{
           return time
        }
        set{
           self.time = newValue
           DispatchQueue.main.async {
            self.txtOfferTime.text = newValue.converTo12hoursFormate()
            
           }
        }
    }
    var price:String = ""
    var strPrice:String{
        get{
            return price
        }
        set{
            self.price = newValue
            DispatchQueue.main.async {
                self.txtOfferPrice.text = newValue
            }
        }
    }
    var minutesPicker:UIPickerView = UIPickerView()
    var minutesToolBar:UIToolbar = UIToolbar()
    var minutes:String = "30"
    var selectedMinute:String{
        get{
            return minutes
        }
        set{
            self.minutes = newValue
            DispatchQueue.main.async {
                self.txtMintues.text = newValue
            }
        }
    }
    var arrayOfMinutes:[String] = ["10","20","30","40","50","60"]
    var strMinutes:String = ""
    var strTempMinutes:String {
        get{
            return strMinutes
        }
        set{
            strMinutes = newValue
            DispatchQueue.main.async {
                self.configureMinutesScroller()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateFormatter.dateFormat = "MM/dd/yyyy"
        // Do any additional setup after loading the view.
        self.imageDate.image = #imageLiteral(resourceName: "calendar").imageWithColor(color1: .black)
        self.imageTime.image = #imageLiteral(resourceName: "updatedTimeImg").imageWithColor(color1: .black)
        self.imagePrice.image = #imageLiteral(resourceName: "dollar").imageWithColor(color1: .black)
        
        self.containerView.layer.cornerRadius = 14.0
        self.containerView.clipsToBounds = true
        self.configureDatePicker()
        self.txtOfferDate.inputView = self.datePicker
        self.txtOfferDate.inputAccessoryView = self.dateToolBar
        self.configureTimePicker()
        self.txtOfferTime.inputView = self.timePicker
        self.txtOfferTime.inputAccessoryView = self.timeToolBar
        self.txtOfferPrice.delegate = self
        self.configureMinutesPicker()
        self.txtMintues.inputView = self.minutesPicker
        self.txtMintues.inputAccessoryView = self.minutesToolBar
        
        NotificationCenter.default.addObserver(self, selector: #selector(OfferDayViewController.keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OfferDayViewController.keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        if let _ = self.objSchedule{
            self.configureCurrentSchedule(objSchedule: self.objSchedule!)
        }
        self.selectedMinute = "30" //default selected minutes
        self.strTempMinutes = "30"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DispatchQueue.main.async {
            self.addDynamicFont()
            self.addLocalisation()
            self.bottomConstaintContainer.constant = UIScreen.main.bounds.height*192/812
            IQKeyboardManager.shared.enable = false
            self.instantExperienceContainer.isHidden = !self.isForInstantExperience
            self.lblInstantMessage.isHidden = !self.isForInstantExperience
            if self.isForInstantExperience{
                self.bottomStackViewContraint.constant = 0.0
                self.heightOfContainerView.constant = 350.0
            }else{
                self.bottomStackViewContraint.constant = 40.0
                self.heightOfContainerView.constant = 300.0
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: - Custom Methods
    func addDynamicFont(){
        
        self.lblTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblTitle.adjustsFontForContentSizeCategory = true
        self.lblTitle.adjustsFontSizeToFitWidth = true
        
        self.lblInstantMessage.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblInstantMessage.adjustsFontForContentSizeCategory = true
        self.lblInstantMessage.adjustsFontSizeToFitWidth = true
        
        self.lblMin.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblMin.adjustsFontForContentSizeCategory = true
        self.lblMin.adjustsFontSizeToFitWidth = true
        
        self.lblCurrency.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblCurrency.adjustsFontForContentSizeCategory = true
        self.lblCurrency.adjustsFontSizeToFitWidth = true
        
        self.lblIn.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblIn.adjustsFontForContentSizeCategory = true
        self.lblIn.adjustsFontSizeToFitWidth = true
        
        self.buttonSuggestion.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonSuggestion.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonSuggestion.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.buttonCancel.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonCancel.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonCancel.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
    }
    func addLocalisation(){
        var strOfferAnotherDay:String = ""
        if self.isForTraveler{
            strOfferAnotherDay = Vocabulary.getWordFromKey(key:"SuggestAnotherDay.hint")
        }else{
            strOfferAnotherDay = Vocabulary.getWordFromKey(key: "offerDay.hint")
        }
        self.lblTitle.text = (self.isForInstantExperience) ? Vocabulary.getWordFromKey(key: "InstantExperience"):strOfferAnotherDay
        self.buttonSuggestion.setTitle(Vocabulary.getWordFromKey(key: "suggest.hint"), for: .normal)
        self.buttonCancel.setTitle(Vocabulary.getWordFromKey(key: "Cancel"), for: .normal)
        self.lblInstantMessage.text = Vocabulary.getWordFromKey(key: "InstantMessage.hint")
        self.lblIn.text = Vocabulary.getWordFromKey(key: "In.hint")
        self.lblMin.text = Vocabulary.getWordFromKey(key: "minutes.hint")
    }
    func configureCurrentSchedule(objSchedule:Schedule){
        self.selectedTime = objSchedule.time
        self.selectedDate = objSchedule.bookingDate.changeDateFormateMMddYYYY
        self.strPrice = objSchedule.price
        self.lblRequestedDateTime.text = "\(objSchedule.bookingDate.changeDateFormateMMddYYYY) \(objSchedule.time)"
        self.lblOfferDateTime.text = "\(objSchedule.bookingDate.changeDateFormateMMddYYYY) \(objSchedule.time)"
        self.lblCurrency.text = "\(objSchedule.currency)"
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async {
                //self.descriptionTxtView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height + 30.0, 0)
                UIView.animate(withDuration: 0.1, animations: {
                    print("Keyboard Size \(keyboardSize.height)")
                    self.bottomConstaintContainer.constant = self.getKeyboardSizeHeight()
                    self.loadViewIfNeeded()
                }, completion: { (true) in
                })
            }
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, animations: {
                    self.bottomConstaintContainer.constant = UIScreen.main.bounds.height*192/812
                    self.view.endEditing(true)
                    self.loadViewIfNeeded()
                })
            }
            
        }
    }
    func getKeyboardSizeHeight()->CGFloat{
        if UIScreen.main.bounds.height == 812.0{
            return 250.0
        }else if UIScreen.main.bounds.height == 736.0{
            return 250.0
        }else if UIScreen.main.bounds.height == 667.0{
            return 250.0
        }else if UIScreen.main.bounds.height == 568.0{
            return 216.0
        }else{
            return 250.0
        }
    }
    func configureMinutesScroller(){
        if let _ = objSchedule{
            let dateWithMinuteInterval = Calendar.current.date(byAdding: DateComponents(minute:Int(self.strTempMinutes)), to: Date())!
            let datetimeFormate = DateFormatter()
            datetimeFormate.dateFormat = "HH:mm"
            self.lblOfferDateTime.text = "\(objSchedule!.bookingDate.changeDateFormateMMddYYYY) \(datetimeFormate.string(from: dateWithMinuteInterval))"
        }
    }
    func configureDatePicker(){
        self.dateToolBar.sizeToFit()
        self.dateToolBar.layer.borderColor = UIColor.clear.cgColor
        self.dateToolBar.layer.borderWidth = 1.0
        self.dateToolBar.backgroundColor = UIColor.white
        self.dateToolBar.clipsToBounds = true
        self.datePicker.datePickerMode = .date
        self.datePicker.minimumDate = Date()
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(OfferDayViewController.donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(OfferDayViewController.cancelDatePicker))
        self.dateToolBar.setItems([cancelButton,spaceButton,doneButton], animated: false)
    }
    @objc func cancelDatePicker(){
        //cancel button dismiss datepicker dialog
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    @objc func donedatePicker(){
        let date =  self.datePicker.date
        self.dateFormatter.dateFormat = "MM/dd/yyyy"
        self.selectedDate = "\(self.dateFormatter.string(from: date))"
        //dismiss date picker dialog
        self.view.endEditing(true)
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
        self.timeToolBar.setItems([cancelButton,spaceButton,doneButton], animated: false)
    }
    @objc func cancelTimePicker(){
        //cancel button dismiss datepicker dialog
        DispatchQueue.main.async {
            self.view.endEditing(true)
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
            //self.configureScheduleType()
        }
        //self.buttonForgroundShadow.isHidden = true
        //dismiss date picker dialog
        self.view.endEditing(true)
    }
    func configureMinutesPicker(){
        self.minutesPicker.delegate = self
        self.minutesPicker.dataSource = self
        self.minutesToolBar.sizeToFit()
        self.minutesToolBar.tintColor = UIColor.init(hexString:"36527D")
        
        self.minutesToolBar.backgroundColor = UIColor.white
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(OfferDayViewController.doneMinutePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(OfferDayViewController.cancelMinutePicker))
        self.minutesToolBar.setItems([cancelButton,spaceButton,doneButton], animated: false)
    }
    @objc func doneMinutePicker(){
        self.selectedMinute = self.strTempMinutes
        DispatchQueue.main.async {
            self.view.endEditing(true)
            let dateWithMinuteInterval = Calendar.current.date(byAdding: DateComponents(minute:Int(self.selectedMinute)), to: Date())!
            let datetimeFormate = DateFormatter()
            datetimeFormate.dateFormat = "HH:mm"
            self.selectedTime = datetimeFormate.string(from: dateWithMinuteInterval)
        }
    }
    @objc func cancelMinutePicker(){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    func isValidSuggestion()->Bool{
        guard self.strPrice.count > 0 else {
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "Enter offer price")
            }
            return false
        }
        //
        guard self.selectedTime.count > 0 else {
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "Enter offer time")
            }
            return false
        }
        let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
        let compSepByCharInSet = self.strPrice.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        if strPrice == numberFiltered && strPrice.count < 8{
            return true
        }else{
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "Enter offer price")
            }
            return false
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
    func getGetLocalDate(date:Date)->String{
        let objDateFormatter = DateFormatter()
        objDateFormatter.dateStyle = .medium
        objDateFormatter.locale = NSLocale.init(localeIdentifier: "\(self.getDeviceCulture())") as Locale
        let bookingDate = "\(objDateFormatter.string(from: date))"
        
        return bookingDate
    }
    func getGuideUserLocalDate(local:String,date:Date)->String{
        let objDateFormatter = DateFormatter()
        objDateFormatter.dateStyle = .medium
        objDateFormatter.locale = NSLocale.init(localeIdentifier:local) as Locale
        let bookingDate = "\(objDateFormatter.string(from: date))"
        
        return bookingDate
    }
    // MARK: - API Request
    func  getUserGuideCultureAPIRequest(){
        if self.isValidSuggestion(){
            guard  let _ = self.objSchedule else{
                return
            }
            let selectedDateFormate = DateFormatter()
            selectedDateFormate.dateFormat = "MM/dd/YYYY"
            if self.dateFormatter.date(from: "\(self.selectedDate)") != nil{
                let objDate = self.dateFormatter.date(from: "\(self.selectedDate)")
              
         
            
            var guideCultureParameters:[String:AnyObject] = [:]
            if self.isForTraveler{ //request to guide
                guideCultureParameters = ["UserId":"\(self.objSchedule!.guideID)" as AnyObject]
            }else{ // request to traveler
                guideCultureParameters = ["UserId":"\(self.objSchedule!.userID)" as AnyObject]
            }
     
        let getUserCulture = "users/native/userculture"
       
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: getUserCulture, parameter:guideCultureParameters, isHudeShow:true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let userCulture = successData["UserCulture"]{
                
                let guideBookingDate = self.getGuideUserLocalDate(local:"\(userCulture)",date:objDate!)
                self.postSuggestDateTimeandPriceRequest(bookingDate: guideBookingDate)
                //self.experienceBookingWithOutPaymentRequest(bookingDate: guideBookingDate)
            }else{
                self.postSuggestDateTimeandPriceRequest(bookingDate: self.getGetLocalDate(date: objDate!))
                //self.experienceBookingWithOutPaymentRequest(bookingDate: self.getGetLocalDate())
            }
        }) { (responseFail) in
           self.postSuggestDateTimeandPriceRequest(bookingDate: self.getGetLocalDate(date: objDate!))
            }
        }
      }
    }
    func postSuggestDateTimeandPriceRequest(bookingDate:String){
        if self.isValidSuggestion(){
                guard  let _ = self.objSchedule else{
                    return
                }
            
                var experienceBookingParameters:[String:Any] = [:]
                //let objDateFormatter = DateFormatter()
                //objDateFormatter.dateFormat = "MM/dd/yyyy"
                //let bookingDate = "\(objDateFormatter.string(from: self.selectedDate))"
                experienceBookingParameters[kDate] = selectedDate
                experienceBookingParameters[kExperience_id] = "\(self.objSchedule!.experienceID)"
                experienceBookingParameters[kPrice] = "\(self.strPrice)"
                experienceBookingParameters[kSlots] = "\(self.objSchedule!.slots)"
                experienceBookingParameters[kTime] = "\(self.selectedTime)"
                experienceBookingParameters[kUserID] = "\(self.objSchedule!.userID)"
                let userName = "\(objSchedule!.userName)"//"\(User.getUserFromUserDefault()!.userFirstName) \(User.getUserFromUserDefault()!.userLastName)"
                experienceBookingParameters[kUserName] = userName
                experienceBookingParameters[kIsGroupBooking] = "\(self.objSchedule!.isGroupBooking)"
                experienceBookingParameters[kBookingID] = "\(self.objSchedule!.id)"
                if let _ = objSchedule{
                    experienceBookingParameters["bookingduration"] = "\(objSchedule!.bookingDuration)"
                    experienceBookingParameters["ishourly"] = "\(objSchedule!.ishourly)"
                }
            
                if self.isForTraveler{
                    experienceBookingParameters[kBookingStatus] = "RequestedByTraveler"
                    experienceBookingParameters[kNotification_body] = "\(userName) wants to book \"\(self.objSchedule!.title)\" on \(bookingDate) at \(self.selectedTime.converTo12hoursFormate()) and ready to pay \(self.objSchedule!.currency) \(self.strPrice), Do you accept?"
                }else{
                    if self.isForInstantExperience{
                    experienceBookingParameters[kBookingStatus] = "Accepted"
                    experienceBookingParameters[kNotification_body] = "Your booking for \"\(self.objSchedule!.title)\" has been confirmed by the guide. Please confirm the payment. Your receipt will be sent to you by email."
                    }else{
                    experienceBookingParameters[kBookingStatus] = "RequestedByGuide"
                    experienceBookingParameters[kNotification_body] = "Your booking could not be done according to your wishes.The guide suggested this instead: \nBookingDate:\(bookingDate), \(self.selectedTime.converTo12hoursFormate()) \nPrice:\(self.objSchedule!.currency) \(self.strPrice) \n\nDo you accept?"
                    }
                }
                experienceBookingParameters[kInstant_booking] = "\(self.objSchedule!.isInstantBooking)"
                experienceBookingParameters[kGuide_id] = "\(self.objSchedule!.guideID)"
                
                APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kExperienceBookingWithOutPayment, parameter: experienceBookingParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                    if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let strMSG = successData["Message"] as? String {
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                            if self.isForTraveler{
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    ShowToast.show(toatMessage:strMSG)
                                    // your code here
                                    self.performSegue(withIdentifier: "unwindToMyLiveFromOfferAnotherDay", sender: nil)
                                }
                            }else{
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    ShowToast.show(toatMessage:strMSG)
                                    // your code here
                                    self.performSegue(withIdentifier: "unwindToPendingControllerFromOfferAnotherDay", sender: nil)
                                }
                            }
//                            let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key: "Booking"), message: "\(strMSG)", preferredStyle: .alert)
//                            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key: "ok.title"), style: .default, handler: { (_) in
//                                DispatchQueue.main.asyncAfter(deadline: .now())  {
//                                    self.dismiss(animated: true, completion: nil)
//                                }
//                            }))
//                            alertController.view.tintColor = UIColor.init(hexString:"36527D")
//                            self.present(alertController, animated: true, completion: nil)
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
                            ShowToast.show(toatMessage:kCommonError)
                        }
                    }
                }
        }
    }
    
    // MARK: - Selector Methods
    @IBAction func buttonCancelSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func buttonSuggestionSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.getUserGuideCultureAPIRequest()
            //self.postSuggestDateTimeandPriceRequest()
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
extension OfferDayViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.arrayOfMinutes[row]
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 150.0
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.arrayOfMinutes.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.strTempMinutes = self.arrayOfMinutes[row]
    }
}

extension OfferDayViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        guard textField != self.txtOfferPrice else{
            
            let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
            let compSepByCharInSet = typpedString.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            if typpedString == numberFiltered && typpedString.count < 8{
               self.strPrice = "\(typpedString)"
               return true
            }else{
               return false
            }
        }
        return true
    }
}
extension UITextView{
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
extension UITextField {
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
