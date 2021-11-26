//
//  HistoryViewController.swift
//  Live
//
//  Created by IPS on 15/06/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var tableViewHistory:UITableView!
    @IBOutlet var buttonBack:UIButton!
    
    var arrayOfHistory:[BookingHistory] = []
    var colors:[UIColor] = [UIColor.red,UIColor.blue,UIColor.yellow]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonBack.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.buttonBack.imageView?.tintColor = UIColor.black
        
        // Do any additional setup after loading the view.
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"History")
        //GET History
        self.getHistoryAPIRequest()
        //Configure History View
        self.configureHistoryView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.lblTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblTitle.adjustsFontForContentSizeCategory = true
        self.lblTitle.adjustsFontSizeToFitWidth = true
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - API Request Methods
    func getHistoryAPIRequest(){
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            let requestHistory = "experience/native/bookingpaymenthistory/\(currentUser.userID)"
            //GetHistory
            APIRequestClient.shared.sendRequest(requestType: .GET, queryString: requestHistory, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let aryOfHistory = successData["history"] as? [[String:Any]]{
                    self.arrayOfHistory = []
                    for objHistory in aryOfHistory{
                        self.arrayOfHistory.append(BookingHistory.init(historyDetail: objHistory))
                    }
                    DispatchQueue.main.async {
                        self.tableViewHistory.reloadData()
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
                        ShowToast.show(toatMessage: kCommonError)
                    }
                }
            })
        }
    }
    // MARK: - Custom Methods
    func configureHistoryView(){
        let objScheduleNib = UINib.init(nibName: "HistoryTableViewCell", bundle: nil)
        self.tableViewHistory.register(objScheduleNib, forCellReuseIdentifier: "HistoryTableViewCell")
        self.tableViewHistory.tableHeaderView = UIView()
        self.tableViewHistory.tableFooterView = UIView()
        self.tableViewHistory.delegate = self
        self.tableViewHistory.dataSource = self
        self.tableViewHistory.separatorStyle = .none
        self.tableViewHistory.backgroundColor = UIColor.init(hexString:"F2F1F1")
        self.tableViewHistory.showsVerticalScrollIndicator = false
    }

    // MARK: - Selector Methods
    @IBAction func btnBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
extension HistoryViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arrayOfHistory.count > 0 {
            tableView.removeMessageLabel()
        }else{
            tableView.showMessageLabel(msg: Vocabulary.getWordFromKey(key: "History.noData"))
        }
        return self.arrayOfHistory.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let historyCell :HistoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as! HistoryTableViewCell
        guard self.arrayOfHistory.count > indexPath.row else {
            return historyCell
        }
        let objHistory = self.arrayOfHistory[indexPath.row]
        historyCell.lblDate.text = "\(objHistory.createdDate.changeDateWithTimeFormat)"
        historyCell.lblHistoryDetail.text = "\(objHistory.message)"
        historyCell.timelineView.backgroundColor = UIColor.init(hexString: "\(objHistory.color)")
        if indexPath.row == 0{
            historyCell.topSpaceConstraint.constant = 20.0
            historyCell.topLineView.isHidden = true
            historyCell.bottomView.isHidden = false
        }else if indexPath.row+1 == self.arrayOfHistory.count{
            historyCell.topSpaceConstraint.constant = 5.0
            historyCell.topLineView.isHidden = false
            historyCell.bottomView.isHidden = true
        }else{
            historyCell.topSpaceConstraint.constant = 5.0
            historyCell.topLineView.isHidden = false
            historyCell.bottomView.isHidden = false
        }
        historyCell.backgroundColor = .clear
        return historyCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.row == 0) ? 110.0 : 95.0
    }
}
extension String {
    var changeDateWithTimeFormat:String{
        var dateFormatter = DateFormatter()
        //let tempLocale = dateFormatter.locale // save locale temporarily
       // dateFormatter.locale = Locale(identifier: "\(tempLocale!)") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        //dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let date = dateFormatter.date(from: self){
            print(dateFormatter.string(from: date))
            dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            //dateFormatter.timeStyle = .medium
            //dateFormatter.dateFormat = "dd MMM yyyy - hh:mm a"
            //dateFormatter.locale = tempLocale // reset the locale
            let dateString = dateFormatter.string(from: date)
            dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            let timeString = dateFormatter.string(from: date)
            return "\(dateString)  \(timeString)"
        }else{
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = dateFormatter.date(from: self){
                print(dateFormatter.string(from: date))
                dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                //dateFormatter.timeStyle = .medium
//                dateFormatter.dateFormat = "dd MMM yyyy - hh:mm a"
//                dateFormatter.locale = tempLocale // reset the locale
                let dateString = dateFormatter.string(from: date)
                dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                let timeString = dateFormatter.string(from: date)
                return "\(dateString)  \(timeString)"
            }else{
                return self
            }
        }
    }
}
class HistoryTableViewCell:UITableViewCell{
    
    @IBOutlet var lblDate:UILabel!
    @IBOutlet var lblHistoryDetail:UILabel!
    @IBOutlet var timelineView:UIView!
    @IBOutlet var topLineView:UIView!
    @IBOutlet var bottomView:UIView!
    @IBOutlet var containerView:UIView!
    @IBOutlet var topSpaceConstraint:NSLayoutConstraint!
    @IBOutlet var shadowView:ShadowView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.timelineView.clipsToBounds = true
        self.timelineView.layer.cornerRadius = 5
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 10.0
        self.shadowView.layer.cornerRadius = 10.0
        DispatchQueue.main.async {
            //self.addDynamicFont()
            //self.addDropShadow()
        }
    }
    func addDropShadow(){
        self.containerView.dropShadow(color: UIColor.init(red: 60.0/255.0, green: 64.0/255.0, blue: 67.0/255.0, alpha:0.3), offSet: CGSize.init(width: 0, height: 1), radius: 2)
        self.containerView.dropShadow(color: UIColor.init(red: 60.0/255.0, green: 64.0/255.0, blue: 67.0/255.0, alpha: 0.15), offSet: CGSize.init(width: 0, height: 2), radius: 6)
//        self.containerView.dropShadow(color: UIColor.red, offSet: CGSize.init(width: 0, height: 1), radius: 2)
//        self.containerView.dropShadow(color: UIColor.red, offSet: CGSize.init(width: 0, height: 2), radius: 6)
        
    }
    func addDynamicFont(){
        self.lblDate.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblDate.adjustsFontForContentSizeCategory = true
        //self.lblDate.adjustsFontSizeToFitWidth = true
        
        self.lblHistoryDetail.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblHistoryDetail.adjustsFontForContentSizeCategory = true
        //self.lblHistoryDetail.adjustsFontSizeToFitWidth = true
    }
}
class BookingHistory: NSObject {
  
    fileprivate let kBookingId:String = "BookingId"
    fileprivate let kUserId:String = "UserId"
    fileprivate let kUserName:String = "UserName"
    fileprivate let kGuideName:String = "GuideName"
    fileprivate let kGuideId:String = "GuideId"
    fileprivate let kBookingDate = "BookingDate"
    fileprivate let kCreatedDate = "CreatedDate"
    fileprivate let kExperienceName = "ExperienceName"
    fileprivate let kExperienceId = "ExperienceId"
    fileprivate let kExperienceImage = "ExperienceImage"
    fileprivate let kBookingStatus = "BookingStatus"
    fileprivate let kPaymentStatus = "PaymentStatus"
    fileprivate let kPayment = "Payment"
    fileprivate let kSeparator = "Separator"
    fileprivate let kMessage  = "Message"
    fileprivate let kColor = "ColorCodeHex"
    
    var bookingId:String = ""
    var userId:String = ""
    var userName:String = ""
    var guideName:String = ""
    var guideId:String = ""
    var bookingDate:String = ""
    var createdDate:String = ""
    var experienceName:String = ""
    var experienceId:String = ""
    var experienceImage:String = ""
    var bookingStatus:String = ""
    var paymentStatus:String = ""
    var payment:String = "0.0"
    var separator:String = ""
    var message:String  = ""
    var color = ""
    
    init(historyDetail:[String:Any]) {
        if let _ = historyDetail[kBookingId],!(historyDetail[kBookingId] is NSNull){
            self.bookingId = "\(historyDetail[kBookingId]!)"
        }
        if let _ = historyDetail[kUserId],!(historyDetail[kUserId] is NSNull){
            self.userId = "\(historyDetail[kUserId]!)"
        }
        if let _ = historyDetail[kUserName],!(historyDetail[kUserName] is NSNull){
            self.userName = "\(historyDetail[kUserName]!)"
        }
        if let _ = historyDetail[kGuideName],!(historyDetail[kGuideName] is NSNull){
            self.guideName = "\(historyDetail[kGuideName]!)"
        }
        if let _ = historyDetail[kGuideId],!(historyDetail[kGuideId] is NSNull){
            self.guideId = "\(historyDetail[kGuideId]!)"
        }
        if let _ = historyDetail[kBookingDate],!(historyDetail[kBookingDate] is NSNull){
            self.bookingDate = "\(historyDetail[kBookingDate]!)"
        }
        if let _ = historyDetail[kCreatedDate],!(historyDetail[kCreatedDate] is NSNull){
            self.createdDate = "\(historyDetail[kCreatedDate]!)"
        }
        if let _ = historyDetail[kExperienceName],!(historyDetail[kExperienceName] is NSNull){
            self.experienceName = "\(historyDetail[kExperienceName]!)"
        }
        if let _ = historyDetail[kExperienceId],!(historyDetail[kExperienceId] is NSNull){
            self.experienceId = "\(historyDetail[kExperienceId]!)"
        }
        if let _ = historyDetail[kExperienceImage],!(historyDetail[kExperienceImage] is NSNull){
            self.experienceImage = "\(historyDetail[kExperienceImage]!)"
        }
        if let _ = historyDetail[kBookingStatus],!(historyDetail[kBookingStatus] is NSNull){
            self.bookingStatus = "\(historyDetail[kBookingStatus]!)"
        }
        if let _ = historyDetail[kPaymentStatus],!(historyDetail[kPaymentStatus] is NSNull){
            self.paymentStatus = "\(historyDetail[kPaymentStatus]!)"
        }
        if let _ = historyDetail[kPayment],!(historyDetail[kPayment] is NSNull){
            self.payment = "\(historyDetail[kPayment]!)"
        }
        if let _ = historyDetail[kSeparator],!(historyDetail[kSeparator] is NSNull){
            self.separator = "\(historyDetail[kSeparator]!)"
        }
        if let _ = historyDetail[kMessage],!(historyDetail[kMessage] is NSNull){
            self.message = "\(historyDetail[kMessage]!)"
        }
        if let _ = historyDetail[kColor],!(historyDetail[kColor] is NSNull){
            self.color = "\(historyDetail[kColor]!)"
        }
    }
}

