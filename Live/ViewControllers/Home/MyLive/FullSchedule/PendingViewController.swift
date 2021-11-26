//
//  PendingViewController.swift
//  Live
//
//  Created by IPS on 30/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import FacebookCore

class PendingViewController: UIViewController {

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
    
    @IBOutlet var pendingTableView:UITableView!
    var refreshController:UIRefreshControl = UIRefreshControl()
    
    var arrayOfPendingExperience:[Schedule] = []
    var timeDatePicker:UIDatePicker = UIDatePicker()
    var timeDateToolBar:UIToolbar = UIToolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // self.pendingTableView.addSubview(refreshController)
        self.refreshController.tintColor = UIColor.black.withAlphaComponent(0.8)
        self.refreshController.addTarget(self, action:#selector(getPendingExperiences), for: .valueChanged)
        
        DispatchQueue.main.async {
            self.configureDurationPicker()
            //self.presentOfferAnotherDayAlert()
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.pendingTableView.isScrollEnabled = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.pendingTableView.isScrollEnabled = false
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //GetPending Experience
        self.getPendingExperiences()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
    func configureDurationPicker(){
        self.timeDatePicker.sizeToFit()
        self.timeDatePicker.layer.borderColor = UIColor.clear.cgColor
        self.timeDatePicker.layer.borderWidth = 1.0
        self.timeDateToolBar.clipsToBounds = true
        self.timeDateToolBar.backgroundColor = UIColor.white
        self.timeDatePicker.datePickerMode = .dateAndTime
        self.timeDatePicker.locale = Locale(identifier: "en_GB")
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(PendingViewController.doneDateTimePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "Offer Another Day", attributes:[NSAttributedStringKey.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(PendingViewController.cancelDateTimePicker))
        self.timeDateToolBar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
    }
    @objc func cancelDateTimePicker(){
        //cancel button dismiss datepicker dialog
        
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.pendingTableView.reloadData()
        }
    }
    @objc func doneDateTimePicker(){
        let date =  self.timeDatePicker.date
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
            print("\(strHour):\(strMinute)")
            //self.selectedTime = "\(strHour):\(strMinute)"
        }
        //dismiss date picker dialog
        self.view.endEditing(true)
    }
    func presentOfferAnotherDayAlert(){
        let alertController = UIAlertController(title: Vocabulary.getWordFromKey(key:"offerDay.hint"), message: "", preferredStyle: .alert)
        
        // Add a textField to your controller, with a placeholder value & secure entry enabled
        alertController.addTextField { textField in
            textField.placeholder = "Date and Time"
            textField.isSecureTextEntry = true
            textField.textAlignment = .center
            textField.inputView = self.timeDatePicker
            textField.inputAccessoryView = self.timeDateToolBar
        }
        
        // A cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Canelled")
        }
        
        // This action handles your confirmation action
        let confirmAction = UIAlertAction(title: "OK", style: .default) { _ in
            print("Current password value: \(alertController.textFields?.first?.text ?? "None")")
        }
        
        // Add the actions, the order here does not matter
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        // Present to user
        self.present(alertController, animated: true, completion: nil)
    }
    // MARK: - Selector Methods
    @IBAction func unwindToPendingControllerFromOfferAnotherDay(segue: UIStoryboardSegue) {
         self.getPendingExperiences()
    }
    // MARK: - API Methods
    @objc func getPendingExperiences(){
        
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            //http://staging.live.stockholmapplab.com/api/experience/native/guide/26/pendingschedule
            let requestURLPendingExperience = kExperiencePendingSchedule+"\(currentUser.userID)/pendingschedule"
            //GetPendingExperience
            APIRequestClient.shared.sendRequest(requestType: .GET, queryString: "\(requestURLPendingExperience)", parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let arrayOfPendingSchedule = successData["PendingSchedule"] as? [[String:Any]]{
                    
                    DispatchQueue.main.async {
                        self.arrayOfPendingExperience = []
                        for pendingSchedule in arrayOfPendingSchedule{
                            let objExperience = Schedule.init(scheduleDetail: pendingSchedule)
                            self.arrayOfPendingExperience.append(objExperience)
                        }
                        //ConfigurePendingTableView
                        self.configurePendingView()
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
                   
                }
            })
        }
        defer{
            self.refreshController.endRefreshing()
        }
        
    }
    func updatedAcceptPendingScheduleAPIRequest(objSchedule:Schedule){
        var experienceBookingParameters:[String:Any] = [:]
        //let objDateFormatter = DateFormatter()
        //objDateFormatter.dateFormat = "MM/dd/yyyy"
        //let bookingDate = "\(objDateFormatter.string(from: self.selectedDate))"
        experienceBookingParameters[kDate] = "\(objSchedule.bookingDate.changeDateFormateMMddYYYY)"
        experienceBookingParameters[kExperience_id] = "\(objSchedule.experienceID)"
        experienceBookingParameters[kPrice] = "\(objSchedule.price)"
        experienceBookingParameters[kSlots] = "\(objSchedule.slots)"
        experienceBookingParameters[kTime] = "\(objSchedule.time)"
        experienceBookingParameters[kUserID] = "\(objSchedule.userID)"
        let userName = "\(objSchedule.userName)"//"\(User.getUserFromUserDefault()!.userFirstName) \(User.getUserFromUserDefault()!.userLastName)"
        experienceBookingParameters[kUserName] = userName
        experienceBookingParameters[kIsGroupBooking] = "\(objSchedule.isGroupBooking)"
        experienceBookingParameters[kBookingID] = "\(objSchedule.id)"
        experienceBookingParameters[kBookingStatus] = "Accepted" //by guide
        experienceBookingParameters[kNotification_body] = "Your booking for \"\(objSchedule.title)\" has been confirmed by the guide. Please confirm the payment. Your receipt will be sent to you by email."
        experienceBookingParameters[kInstant_booking] = "\(objSchedule.isInstantBooking)"
        experienceBookingParameters[kGuide_id] = "\(objSchedule.guideID)"
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kExperienceBookingWithOutPayment, parameter: experienceBookingParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let strMSG = successData["Message"] as? String {
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:strMSG)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                       self.getPendingExperiences()
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
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
    }
    func acceptPendigScheduleAPIRequest(objSchedule:Schedule,index:Int){
        //http://staging.live.stockholmapplab.com/api/experience/native/booking/2009/approve
        let requestURLAcceptExperience =  kIsValidExperienceTime + "\(objSchedule.id)/approve"
        //Approve PendingExperience
        APIRequestClient.shared.sendRequest(requestType: .PUT, queryString: "\(requestURLAcceptExperience)", parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let successMessage = successData["Message"]{
                let objAlert = UIAlertController.init(title: Vocabulary.getWordFromKey(key:"Approved.title"), message: "\(successMessage)", preferredStyle: .alert)
                objAlert.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (_ ) in
                    DispatchQueue.main.async {
                        var parameters:[String:Any] = [:]
                        parameters["item_name"] = "Pending Approved"
                        parameters["username"] = "\(objSchedule.userName)"
                        parameters["userID"] = "\(objSchedule.userID)"
                        parameters["Tour Name"] = "\(objSchedule.title)"
                        if User.isUserLoggedIn,let user = User.getUserFromUserDefault(){
                            parameters["guidname"] = "\(user.userFirstName) \(user.userLastName)"
                            parameters["guideID"] = "\(user.userID)"
                        }
                        CommonClass.shared.addFirebaseAnalytics(parameters: parameters)
                        self.addFaceBookAnalytics(objSchedule: objSchedule)
                        self.arrayOfPendingExperience.remove(at: index)
                        self.pendingTableView.reloadData()
                    }
                }))
                self.present(objAlert, animated: true, completion: nil)
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
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
    func addFaceBookAnalytics(objSchedule:Schedule){
        var parameters:AppEvent.ParametersDictionary = [:]
        parameters["item_name"] = "Pending Approved"
        parameters["username"] = "\(objSchedule.userName)"
        parameters["userID"] = "\(objSchedule.userID)"
        parameters["Tour Name"] = "\(objSchedule.title)"
        if User.isUserLoggedIn,let user = User.getUserFromUserDefault(){
            parameters["guidname"] = "\(user.userFirstName) \(user.userLastName)"
            parameters["guideID"] = "\(user.userID)"
        }
        CommonClass.shared.addFaceBookAnalytics(eventName:"Pending Approved", parameters: parameters)
    }
    
    func cancelPendingScheduleAPIRequest(objSchedule:Schedule,index:Int){
        //http://staging.live.stockholmapplab.com/api/experience/bookingcancelguide
        let requestURLCacelBooking = "experience/native/bookingcancelguide"
        var cancelBookingParameters:[String:Any] = [:]
        cancelBookingParameters["BookingId"] = "\(objSchedule.id)"
        cancelBookingParameters["ExperienceTitle"] = "\(objSchedule.title)"
        cancelBookingParameters["GuideId"] = "\(User.getUserFromUserDefault()!.userID)"
        cancelBookingParameters["UserId"] = "\(objSchedule.userID)"
        cancelBookingParameters["ExperienceId"] = "\(objSchedule.experienceID)"
        //Cancel PendingExperience
        APIRequestClient.shared.sendRequest(requestType: .PUT, queryString: "\(requestURLCacelBooking)", parameter: cancelBookingParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let successMessage = successData["Message"]{
                let objAlert = UIAlertController.init(title: Vocabulary.getWordFromKey(key:"Cancel"), message: "\(successMessage)", preferredStyle: .alert)
                objAlert.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (_ ) in
                    DispatchQueue.main.async {
                        self.arrayOfPendingExperience.remove(at: index)
                        self.pendingTableView.reloadData()
                    }
                }))
                objAlert.view.tintColor = UIColor.init(hexString:"")
                self.present(objAlert, animated: true, completion: nil)
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
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
    // MARK: - Custom Methods
    func configurePendingView(){
        let objScheduleNib = UINib.init(nibName: "PendingScheduleTableViewCell", bundle: nil)
        self.pendingTableView.register(objScheduleNib, forCellReuseIdentifier: "PendingScheduleTableViewCell")
        
        //self.pendingTableView.tableHeaderView = UIView()
        self.pendingTableView.tableFooterView = UIView()
        self.pendingTableView.delegate = self
        self.pendingTableView.dataSource = self
        self.pendingTableView.separatorStyle = .none
        
        self.pendingTableView.reloadData()
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    func pushToDirectReplyController(objSchedule:Schedule){
        if let objDirectReply = self.storyboard?.instantiateViewController(withIdentifier: "DirectReplyViewController") as? DirectReplyViewController{
            objDirectReply.objSchedule = objSchedule
            self.navigationController?.pushViewController(objDirectReply, animated: true)
        }
    }
}
extension PendingViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pendningScheduleCell :PendingScheduleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PendingScheduleTableViewCell", for: indexPath) as! PendingScheduleTableViewCell
        guard self.arrayOfPendingExperience.count > indexPath.row else {
            return pendningScheduleCell
        }
        pendningScheduleCell.pendingScheduleDelegate = self
        let objSchedule = self.arrayOfPendingExperience[indexPath.row]
        pendningScheduleCell.lblStatus.text = "\(objSchedule.status.compareCaseInsensitive(str:"\(Vocabulary.getWordFromKey(key: "confirmed"))".firstUppercased) ? Vocabulary.getWordFromKey(key: "confirmed").firstUppercased:"\(objSchedule.status)".firstUppercased) "
        //historyScheduleCell.lblLeadingConstraont.constant = 104.0
        pendningScheduleCell.lblStatus.textColor = self.getStatusColor(strStatus:"\(objSchedule.status)")
        let statusWithColor:(String,UIColor) = self.getStatusForGuideWithColor(status: "\(objSchedule.status)")
        pendningScheduleCell.lblStatus.text = objSchedule.isInstantBooking ? "  \(statusWithColor.0)" : "\(statusWithColor.0)"
        pendningScheduleCell.lblStatus.textColor = statusWithColor.1
        pendningScheduleCell.lblScheduledate.text = "\(objSchedule.time.changeTimeformat), \(objSchedule.bookingDate.changeDateFormat)"
        pendningScheduleCell.lblScheduleTitle.text = "\(objSchedule.title)"
        pendningScheduleCell.lblUserName.text = "\(objSchedule.userName)"
        pendningScheduleCell.numberOfPerson.text = "\(objSchedule.slots)" + " \(Vocabulary.getWordFromKey(key: "people"))"
        if (objSchedule.isGroupBooking) {
            if objSchedule.ishourly{
                pendningScheduleCell.lblOfferPricePerPersonGroup.text = "(Offered price per group hourly)"
            }else{
                pendningScheduleCell.lblOfferPricePerPersonGroup.text = "(Offered price per group)"
            }
        } else {
            if objSchedule.ishourly{
                pendningScheduleCell.lblOfferPricePerPersonGroup.text = "(Offered price per person hourly)"
            }else{
                pendningScheduleCell.lblOfferPricePerPersonGroup.text = "(Offered price per person)"
            }
            
        }
        pendningScheduleCell.lblCurrencyAndPrice.text = "\(objSchedule.currency) \(objSchedule.price)"
        pendningScheduleCell.tag = indexPath.row
        pendningScheduleCell.viewContainerSelectorContainer.isHidden = false
        pendningScheduleCell.buttonCancelOnly.isHidden = true
        DispatchQueue.main.async {
            pendningScheduleCell.instantImageWidth.constant = objSchedule.isInstantBooking ? 20.0 : 0.0
            if("\(objSchedule.status)" == "Accepted"){
                pendningScheduleCell.buttonAccept.isHidden = true
                pendningScheduleCell.imageAccept.isHidden = true
                pendningScheduleCell.selectorContainerWidth.constant = 80.0
            }else{
                pendningScheduleCell.buttonAccept.isHidden = false
                pendningScheduleCell.imageAccept.isHidden = false
                pendningScheduleCell.selectorContainerWidth.constant = 125.0
            }
        }
        return pendningScheduleCell
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
            return ("By Traveler",UIColor.init(hexString: "36527D"))
        }else if(status == "RequestedByGuide"){
            return ("Requested",UIColor.init(hexString:"FF3B30"))
        }else if(status == "Canceled"){
            return (status,UIColor.init(hexString:"FF3B30"))
        }else{
            return (status,UIColor.init(hexString:"367D4A")) //Accepted Confirmed
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arrayOfPendingExperience.count > 0 {
            tableView.removeMessageLabel()
        }else{
            tableView.showMessageLabel()
        }
        return self.arrayOfPendingExperience.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190.0
    }
   
}
extension PendingViewController:PendingScheduleDelegate{
    func pendigScheduleAcceptSelector(tag: Int) {
        guard self.arrayOfPendingExperience.count > tag else {
            return
        }
        let objAlert = UIAlertController.init(title: Vocabulary.getWordFromKey(key:"acceptTour_title"), message: Vocabulary.getWordFromKey(key:"accept_tour_message"), preferredStyle: .alert)
        objAlert.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (_ ) in
            let objSchedule = self.arrayOfPendingExperience[tag]
            if objSchedule.isInstantBooking{
                self.presentOfferAnotherday(objSchedule: objSchedule,isForInstant:true)
            }else{
                self.updatedAcceptPendingScheduleAPIRequest(objSchedule: objSchedule)
                //self.acceptPendigScheduleAPIRequest(objSchedule: objSchedule,index:tag)
            }
        }))
        objAlert.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"no"), style: .cancel, handler: nil))
        objAlert.view.tintColor = UIColor.init(hexString: "36527D")
        self.present(objAlert, animated: true, completion: nil)
    }
    func pendingScheduleCancelSelector(tag: Int) {
        guard self.arrayOfPendingExperience.count > tag else {
            return
        }
        let objSchedule = self.arrayOfPendingExperience[tag]
        
        let objAlert = UIAlertController.init(title: Vocabulary.getWordFromKey(key:"CancelTour"), message:Vocabulary.getWordFromKey(key:"cancelTourWithOffer.hint"), preferredStyle: .alert)
        objAlert.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"offerDay.hint"), style: .default, handler: { (_ ) in
            self.presentOfferAnotherday(objSchedule:objSchedule,isForInstant:false)
        }))
        objAlert.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"CancelTour").capitalizingFirstLetter(), style: .default, handler: { (_ ) in
            self.cancelPendingScheduleAPIRequest(objSchedule: objSchedule,index:tag)
        }))
        objAlert.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"close.hint"), style: .default, handler: nil))
        objAlert.view.tintColor = UIColor.init(hexString: "36527D")
        self.present(objAlert, animated: true, completion: nil)
        /*
        let objAlert = UIAlertController.init(title: Vocabulary.getWordFromKey(key:"CancelTour"), message: Vocabulary.getWordFromKey(key:"CancelTour.msg"), preferredStyle: .alert)
        objAlert.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (_ ) in
            let objSchedule = self.arrayOfPendingExperience[tag]
            self.cancelPendingScheduleAPIRequest(objSchedule: objSchedule,index:tag)
        }))
        objAlert.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"no"), style: .cancel, handler: nil))
        self.present(objAlert, animated: true, completion: nil) */
        
    }
    func messageReplySelector(tag: Int) {
        guard self.arrayOfPendingExperience.count > tag else {
            return
        }
        let objSchedule:Schedule = self.arrayOfPendingExperience[tag]
        self.pushToDirectReplyController(objSchedule: objSchedule)
    }
    func presentOfferAnotherday(objSchedule:Schedule,isForInstant:Bool){
        DispatchQueue.main.async {
            //self.dismiss(animated: true, completion: nil)
            if let offerViewController = self.storyboard?.instantiateViewController(withIdentifier: "OfferDayViewController") as? OfferDayViewController{
                offerViewController.modalPresentationStyle = .overFullScreen
                offerViewController.objSchedule = objSchedule
                offerViewController.isForInstantExperience = isForInstant
                self.present(offerViewController, animated: false, completion: nil)
            }
        }
    }
}
@objc protocol PendingScheduleDelegate {
   @objc optional func pendingScheduleCancelSelector(tag:Int)
   @objc optional func pendigScheduleAcceptSelector(tag:Int)
   @objc optional func upcomingScheduleCancelOnlySelector(tag:Int)
   @objc optional func messageReplySelector(tag:Int)
}
class ShadowView:UIView{
    private var theShadowLayer: CAShapeLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.theShadowLayer == nil {
//            self.containerView.dropShadow(color: UIColor.init(red: 60.0/255.0, green: 64.0/255.0, blue: 67.0/255.0, alpha:0.3), offSet: CGSize.init(width: 0, height: 1), radius: 2)
//            self.containerView.dropShadow(color: UIColor.init(red: 60.0/255.0, green: 64.0/255.0, blue: 67.0/255.0, alpha: 0.15), offSet: CGSize.init(width: 0, height: 2), radius: 6)
            let rounding = CGFloat.init(10.0)
            var shadowLayer = CAShapeLayer.init()
            shadowLayer.path = UIBezierPath.init(roundedRect: bounds, cornerRadius: rounding).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowColor = UIColor.init(red: 60.0/255.0, green: 64.0/255.0, blue: 67.0/255.0, alpha:0.3).cgColor
            shadowLayer.shadowRadius = CGFloat.init(2.0)
            shadowLayer.shadowOpacity = Float.init(0.5)
            shadowLayer.shadowOffset = CGSize.init(width: 0.0, height: 1.0)
            //self.layer.insertSublayer(shadowLayer, at: 0)
            self.layer.insertSublayer(shadowLayer, below: nil)
            shadowLayer = CAShapeLayer.init()
            shadowLayer.path = UIBezierPath.init(roundedRect: bounds, cornerRadius: rounding).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowColor = UIColor.init(red: 60.0/255.0, green: 64.0/255.0, blue: 67.0/255.0, alpha:0.15).cgColor
            shadowLayer.shadowRadius = CGFloat.init(6.0)
            shadowLayer.shadowOpacity = Float.init(0.5)
            shadowLayer.shadowOffset = CGSize.init(width: 0.0, height: 2.0)
            self.layer.insertSublayer(shadowLayer, below: nil)

        }
    }
}
class PendingScheduleTableViewCell:UITableViewCell{
    
    @IBOutlet var lblScheduledate:UILabel!
    @IBOutlet var lblScheduleTitle:UILabel!
    @IBOutlet var lblUserName:UILabel!
    @IBOutlet var numberOfPerson:UILabel!
    @IBOutlet var buttonAccept:RoundButton!
    @IBOutlet var buttonCancel:UIButton!
    @IBOutlet var buttonCancelOnly:RoundButton!
    @IBOutlet var viewContainerSelectorContainer:UIView!
    @IBOutlet var cancelImage:UIImageView!
    @IBOutlet var doneImage:UIImageView!
    @IBOutlet var containerView:UIView!
    @IBOutlet var lblStatus:UILabel!
    @IBOutlet var imageAccept:UIImageView!
    @IBOutlet var instantImageWidth:NSLayoutConstraint!
    //@IBOutlet var lblLeadingConstraont:NSLayoutConstraint!
    @IBOutlet var selectorContainerWidth:NSLayoutConstraint! //125 to 80
    @IBOutlet var shadowView:ShadowView!
    @IBOutlet var buttonMessasge:RoundButton!
    @IBOutlet var lblCurrencyAndPrice:UILabel!
    @IBOutlet var lblOfferPricePerPersonGroup:UILabel!
    
    var pendingScheduleDelegate:PendingScheduleDelegate?
    let tintBorderColor:UIColor = UIColor.init(red: 101.0/255.0, green: 131.0/255.0, blue: 191.0/255.0, alpha: 1.0)

    override func awakeFromNib() {
        super.awakeFromNib()
        self.buttonCancelOnly.setTitle(Vocabulary.getWordFromKey(key: "Cancel"), for: .normal)
        //self.buttonAccept.setTitle(Vocabulary.getWordFromKey(key: "accept.hint"), for: .normal)
        
        let imageSelect = #imageLiteral(resourceName: "chat_selected").imageWithColor(color1:UIColor.init(hexString:"36527D"))
        self.doneImage.image = imageSelect
        self.doneImage.tintColor = nil
        //self.doneImage.tintColor = UIColor.init(hexString:"36527D")
        //self.doneImage.isHidden = true
        let imageAccept = #imageLiteral(resourceName: "tick_select").imageWithColor(color1:UIColor.init(hexString:"FFFFFF"))
        self.imageAccept.image = imageAccept
        self.imageAccept.tintColor = nil
        
        let imageClose = #imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate)
        self.cancelImage.image = imageClose
        self.cancelImage.tintColor = .white
      
        self.buttonCancel.tintColor = .black
        //self.buttonCancelOnly.layer.borderColor = UIColor.red.cgColor
        //self.buttonCancelOnly.layer.borderWidth = 0.7
//        self.buttonAccept.layer.cornerRadius = 25.0
//        self.buttonCancel.layer.cornerRadius = 25.0
        self.buttonAccept.layer.borderColor = tintBorderColor.cgColor
        self.buttonCancel.layer.borderColor = tintBorderColor.cgColor
        self.buttonAccept.layer.borderWidth = 0.7
        self.buttonCancel.layer.borderWidth = 0.7
        self.buttonAccept.clipsToBounds = true
        self.buttonCancel.clipsToBounds = true
        self.selectionStyle = .none
       // self.buttonCancel.setImage(#imageLiteral(resourceName: "close_dark").withRenderingMode(.alwaysTemplate), for: .normal)
        //self.buttonCancel.imageView?.tintColor = UIColor.white
        //self.buttonCancel.imageView?.contentMode = .scaleAspectFit
        
        
//        self.buttonMessasge.setImage(#imageLiteral(resourceName: "chat_selected").withRenderingMode(.alwaysTemplate), for: .normal)
//        self.buttonMessasge.imageView?.tintColor = UIColor.init(hexString: "36527D")
//        self.buttonMessasge.imageView?.contentMode = .scaleAspectFit
        self.buttonMessasge.backgroundColor = .clear
        //self.shadowView.clipsToBounds = true
        self.shadowView.layer.cornerRadius = 15.0
        DispatchQueue.main.async {
            self.addDynamicFont()
            //self.addDropShadow()
        }
    }
    func addDropShadow(){
        self.containerView.dropShadow(color: UIColor.init(red: 60.0/255.0, green: 64.0/255.0, blue: 67.0/255.0, alpha:0.3), offSet: CGSize.init(width: 0, height: 1), radius: 2)
        self.containerView.dropShadow(color: UIColor.init(red: 60.0/255.0, green: 64.0/255.0, blue: 67.0/255.0, alpha: 0.15), offSet: CGSize.init(width: 0, height: 2), radius: 6)
//                self.containerView.dropShadow(color: UIColor.red, offSet: CGSize.init(width: 0, height: 1), radius: 2)
//                self.containerView.dropShadow(color: UIColor.red, offSet: CGSize.init(width: 0, height: 2), radius: 6)
       

    }
    func addDynamicFont(){
        
        self.buttonAccept.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonAccept.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonAccept.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.lblScheduleTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblScheduleTitle.adjustsFontForContentSizeCategory = true
        self.lblScheduleTitle.adjustsFontSizeToFitWidth = true
        
        self.lblScheduledate.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblScheduledate.adjustsFontForContentSizeCategory = true
        self.lblScheduledate.adjustsFontSizeToFitWidth = true
        
        self.lblUserName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblUserName.adjustsFontForContentSizeCategory = true
        self.lblUserName.adjustsFontSizeToFitWidth = true
        
        self.lblStatus.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblStatus.adjustsFontForContentSizeCategory = true
        self.lblStatus.adjustsFontSizeToFitWidth = true
        
        self.numberOfPerson.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.numberOfPerson.adjustsFontForContentSizeCategory = true
        self.numberOfPerson.adjustsFontSizeToFitWidth = true
        
    }
    //Selector Methods
    @IBAction func buttonAcceptSelector(sender:UIButton){
        if let _ = self.pendingScheduleDelegate{
            self.pendingScheduleDelegate!.pendigScheduleAcceptSelector!(tag: self.tag)
        }
    }
    @IBAction func buttonCancelSelector(sender:UIButton){
        if let _ = self.pendingScheduleDelegate{
            self.pendingScheduleDelegate!.pendingScheduleCancelSelector!(tag: self.tag)
            }
    }
    @IBAction func buttonCancelOnlySelector(sender:UIButton){
        if let _ = self.pendingScheduleDelegate{
            self.pendingScheduleDelegate!.upcomingScheduleCancelOnlySelector!(tag: self.tag)
        }
    }
    @IBAction func buttonMessageSelector(sender:UIButton){
        if let _ = self.pendingScheduleDelegate{
            self.pendingScheduleDelegate!.messageReplySelector!(tag: self.tag)
        }
    }
}
extension UIImage {
    func imageWithColor(color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
