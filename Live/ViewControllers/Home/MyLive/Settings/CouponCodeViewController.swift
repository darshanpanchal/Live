//
//  CouponCodeViewController.swift
//  Live
//
//  Created by IPS on 19/07/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

struct Coupon {
    var couponID:String = ""
    var ID:String = ""
    var couponName:String = ""
    var expireDate:String = ""
    var image:String = ""
    var qrCode:String = ""
    var discription:String = ""
    var currency:String = ""
    
    init(couponDetail:[String:Any]) {
        if let id = couponDetail["Id"],!(id is NSNull){
            self.ID = "\(id)"
        }
        if let couponName = couponDetail["CouponName"],!(couponName is NSNull){
            self.couponName = "\(couponName)"
        }
        if let couponId = couponDetail["CouponId"],!(couponId is NSNull){
            self.couponID = "\(couponId)"
        }
        if let expiresOn = couponDetail["ExpiresOn"],!(expiresOn is NSNull){
            self.expireDate = "\(expiresOn)"
        }
        if let objImage = couponDetail["Image"],!(objImage is NSNull){
            self.image = "\(objImage)"
        }
        if let objCurrency = couponDetail["Currency"],!(objCurrency is NSNull){
            self.currency = "\(objCurrency)"
        }
        if let objQRCode = couponDetail["QRCode"],!(objQRCode is NSNull){
            self.qrCode = "\(objQRCode)"
        }
        if let objDescription = couponDetail["Description"],!(objDescription is NSNull){
            self.discription = "\(objDescription)"
        }
    }
}
class TimerView:UIView{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 6.0
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
}
class CouponCodeViewController: UIViewController {

    @IBOutlet var tableViewCouponCode:UITableView!
    @IBOutlet var imgCoupon:UIImageView!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var buttonAddCoponCode1:UIButton!
    @IBOutlet var buttonCamera:UIButton!
    @IBOutlet var buttonAddCoupon:UIButton!
    @IBOutlet var buttonAddCouponRound:RoundButton!
    @IBOutlet var lblNoCouponCode:UILabel!
    
    
    var arrayOfCoupon:[Coupon] = []
    var strCouponCode:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault() else {
            let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"notLogin.title"), message: Vocabulary.getWordFromKey(key:"notLogin.msg"), preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (_) in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            let continueSelelector = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"continueBrowsing"), style: .cancel, handler: nil)
            
            alertController.addAction(continueSelelector)
            alertController.view.tintColor = UIColor(hexString: "#36527D")
            self.present(alertController, animated: true, completion: nil)
            return
        }
        //Configure CouponTableView
        self.configureTableView()
        //GET Coupon
        self.getCouponCodeAPIRequest(userID:currentUser.userID)
        //ConfigureAddCouponCode
        self.configureAddCouponCode()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .default
        DispatchQueue.main.async {
            self.lblTitle.text = "\(Vocabulary.getWordFromKey(key:"couponcode.hint"))"
            self.lblNoCouponCode.text = "\(Vocabulary.getWordFromKey(key:"noCouponCode.hint"))"
            self.buttonAddCouponRound.setTitle(Vocabulary.getWordFromKey(key: "addNewCouponCode.hint"), for: .normal)
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.lblTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblTitle.adjustsFontForContentSizeCategory = true
        self.lblTitle.adjustsFontSizeToFitWidth = true
        
        self.lblNoCouponCode.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblNoCouponCode.adjustsFontForContentSizeCategory = true
        self.lblNoCouponCode.adjustsFontSizeToFitWidth = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
    func configureAddCouponCode(){
        self.buttonAddCoupon.setBackgroundImage(#imageLiteral(resourceName: "plus_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.buttonAddCoupon.imageView?.tintColor = UIColor.black
    }
    func configureTableView(){
        let objScheduleNib = UINib.init(nibName: "CouponTableViewCell", bundle: nil)
        self.tableViewCouponCode.register(objScheduleNib, forCellReuseIdentifier: "CouponTableViewCell")
        let footerView = UIView()
        footerView.backgroundColor = UIColor.init(hexString:"F5F5F5")
        self.tableViewCouponCode.tableFooterView = footerView
        self.tableViewCouponCode.delegate = self
        self.tableViewCouponCode.dataSource = self
        self.tableViewCouponCode.separatorStyle = .none
    }
    func presentAddCouponCodeAlertController(){
        let alertController = UIAlertController(title: Vocabulary.getWordFromKey(key: "addNewCouponCode.hint"), message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = Vocabulary.getWordFromKey(key:"enterCouponcode.hint")
        }
        let cancelAction = UIAlertAction(title: Vocabulary.getWordFromKey(key: "Cancel"), style: UIAlertActionStyle.cancel, handler:nil)
        //add
        let saveAction = UIAlertAction(title: Vocabulary.getWordFromKey(key: "add"), style: UIAlertActionStyle.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            if let strText = firstTextField.text,strText.count > 0{
                self.addCouponCodeAPIRequest(strCouponCode: "\(firstTextField.text!)")
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"validationenterCouponcode.hint"))
                }
            }
        })
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = UIColor.init(hexString:"36527D")
        self.present(alertController, animated: true, completion: nil)
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonCameraSelection(sender:UIButton){
        self.pushToQRCodeScanner()
    }
    @IBAction func buttonAddCouponCodeSelector(sender:UIButton){
        self.presentAddCouponCodeAlertController()
        //self.pushToAddCouponCodeController()
    }
    @IBAction func buttonAddCouponCodeSelector1(sender:UIButton){
        self.pushToQRCodeScanner()
    }
    @IBAction func unwindToAddCouponCodeFromQRCodeScanner(segue:UIStoryboardSegue){
        if self.strCouponCode.count > 0{
            self.addCouponCodeAPIRequest(strCouponCode: self.strCouponCode)
        }
    }
    // MARK: - API Methods
    func getCouponCodeAPIRequest(userID:String){
        
        let kGETCouponCodeURL = "payment/native/users/\(userID)/couponcodelist"
        //Default UserID will be 3
        //        let kURLWishlist = "\(kUserExperience)3/wishlist?pagesize=\(self.currentPageSize)&pageindex=\(self.currentPageIndex)"
        
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:kGETCouponCodeURL, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let array = successDate["Coupons"] as? [[String:Any]]{
                self.arrayOfCoupon = []
                for coupon in array{
                    let objCoupon = Coupon.init(couponDetail: coupon)
                    self.arrayOfCoupon.append(objCoupon)
                }
                DispatchQueue.main.async {
                    self.tableViewCouponCode.reloadData()
                    if self.arrayOfCoupon.count > 0{
                        self.lblNoCouponCode.isHidden = true
                        self.buttonAddCouponRound.isHidden = true
                        self.tableViewCouponCode.isHidden = false
                        self.buttonAddCoupon.isHidden = false
                    }else{
                        self.lblNoCouponCode.isHidden = false
                        self.buttonAddCouponRound.isHidden = false
                        self.tableViewCouponCode.isHidden = true
                        self.buttonAddCoupon.isHidden = true
                    }
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
    func addCouponCodeAPIRequest(strCouponCode:String){
            if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(),currentUser.userID.count > 0{
                var addCouponCodeParameters:[String:Any] = [:]
                addCouponCodeParameters["UserId"] = "\(currentUser.userID)"
                addCouponCodeParameters["CouponCode"] = "\(strCouponCode)"
                
                let requestURL = "payment/couponcode"
                APIRequestClient.shared.sendRequest(requestType: .POST, queryString: requestURL, parameter:addCouponCodeParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                    if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let strMessage = successData["Message"]{
                        DispatchQueue.main.async {
                            ShowToast.show(toatMessage:"\(strMessage)")
                            self.getCouponCodeAPIRequest(userID: "\(currentUser.userID)")
                        }
                    }else{
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
    func pushToAddCouponCodeController(){
        if let addCouponCodeController = self.storyboard?.instantiateViewController(withIdentifier: "AddCouponCodeViewController") as? AddCouponCodeViewController{
            
            self.navigationController?.pushViewController(addCouponCodeController, animated: true)
        }
    }
    
    func pushToQRCodeScanner(){
        if let qrCodeController = self.storyboard?.instantiateViewController(withIdentifier: "QRScannerController") as? QRScannerController{
            qrCodeController.isForAddCouponCode = true
            self.navigationController?.pushViewController(qrCodeController, animated: true)
        }
        /*
        if let qrCodeController = self.storyboard?.instantiateViewController(withIdentifier: "QRCodeViewController") as? QRCodeViewController{
            self.navigationController?.pushViewController(qrCodeController, animated: true)
        }*/
    }
}
extension CouponCodeViewController:UITableViewDelegate,UITableViewDataSource,CouponTableViewCellDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arrayOfCoupon.count > 0 {
            tableView.removeMessageLabel()
        }else{
            tableView.showMessageLabel(msg: Vocabulary.getWordFromKey(key:"noCouponCode.hint"), backgroundColor: .clear)
        }
        return self.arrayOfCoupon.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let couponCell :CouponTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CouponTableViewCell", for: indexPath) as! CouponTableViewCell
        guard self.arrayOfCoupon.count > indexPath.row else {
            return couponCell
        }
        DispatchQueue.global(qos: .background).async {
            let objCoupon = self.arrayOfCoupon[indexPath.row]
            DispatchQueue.main.async {
                couponCell.backgroundColor = UIColor.clear
                couponCell.couponDelegate = self
                var couponCurrency = ""
                if objCoupon.currency.count > 0 {
                    couponCurrency = " (\(objCoupon.currency))"
                }
                couponCell.lblCouponCode.text = "\(objCoupon.couponID)"+couponCurrency
               
                let strDate = "\(objCoupon.expireDate)".changeDateWithTimeFormat+":00"
                couponCell.lblExpireDate.text = "\(strDate) GMT+2"
                couponCell.imageCoupon.imageFromServerURL(urlString: "\(objCoupon.image)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, placeHolder: #imageLiteral(resourceName: "voucher").withRenderingMode(.alwaysOriginal))
                couponCell.lblExpireDate.text = "Expires in \(self.getRemainingDays(expireDate:"\(objCoupon.expireDate)".changeDateFormateDDMMS)) days"
                //couponCell.getRemainingTime(expireDate:"\(objCoupon.expireDate)".changeDateFormateDDMMS)
            }
        }
        return couponCell
    }
    func getRemainingDays(expireDate:String)->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+02:00")
        let currentDate = "\(dateFormatter.string(from: Date().toGlobalTime()))"
        guard dateFormatter.date(from: currentDate)! < dateFormatter.date(from: expireDate)! else {
            return "0"
        }
        let calendar = NSCalendar.current
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: dateFormatter.date(from: currentDate)!)
        let date2 = calendar.startOfDay(for: dateFormatter.date(from: expireDate)!)
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        if let _ = components.day{
            return "\(components.day!)"
        }else{
            return "0"
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 98.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.arrayOfCoupon.count > indexPath.row{
            let objCoupon = self.arrayOfCoupon[indexPath.row]
            self.presentCouponCodeDetail(objCoupon: objCoupon)
        }
    }
    func presentCouponCodeDetail(objCoupon:Coupon){
        if let objCouponDetailViewController:CouponDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "CouponDetailViewController") as? CouponDetailViewController{
            objCouponDetailViewController.objCoupon = objCoupon
            objCouponDetailViewController.strExpire = "Expires in \(self.getRemainingDays(expireDate:"\(objCoupon.expireDate)".changeDateFormateDDMMS)) days"
            self.navigationController?.present(objCouponDetailViewController, animated: true, completion: nil)
        }
    }
    func reloadCouponOnExpire() {
        DispatchQueue.main.async {
            guard User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault() else {
                return
            }
            self.getCouponCodeAPIRequest(userID:"\(currentUser.userID)")
        }
    }
}
protocol CouponTableViewCellDelegate {
    func reloadCouponOnExpire()
}
class CouponTableViewCell: UITableViewCell {
    
    @IBOutlet var lblCouponCode:UILabel!
    @IBOutlet var lblExpireDate:UILabel!
    @IBOutlet var lblDay:UILabel!
    @IBOutlet var lblDayValue:UILabel!
    @IBOutlet var lblHours:UILabel!
    @IBOutlet var lblHoursValue:UILabel!
    @IBOutlet var lblMin:UILabel!
    @IBOutlet var lblMinvalue:UILabel!
    @IBOutlet var lblSecond:UILabel!
    @IBOutlet var lblSecondValue:UILabel!
    @IBOutlet var lblExpired:UILabel!
    @IBOutlet var shadowView:ShadowView!
    @IBOutlet var imageCoupon:ImageViewForURL!
    
//    @IBOutlet var objStackView:UIStackView!
    
    fileprivate var timer: Timer?
    var couponDelegate:CouponTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.clipsToBounds = true
        self.shadowView.layer.cornerRadius = 10.0
        self.lblExpired.layer.cornerRadius = 14.0
        self.lblExpired.clipsToBounds = true
        
        DispatchQueue.main.async {
            self.addLocalisation()
            //self.addDynamicFont()
            self.imageCoupon.layer.cornerRadius = 30.0
            self.imageCoupon.clipsToBounds = true
        }
        
    }
    func addDynamicFont(){
        
        self.lblCouponCode.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblCouponCode.adjustsFontForContentSizeCategory = true
        self.lblCouponCode.adjustsFontSizeToFitWidth = true
        
//        self.lblExpireDate.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
//        self.lblExpireDate.adjustsFontForContentSizeCategory = true
//        self.lblExpireDate.adjustsFontSizeToFitWidth = true
        
        self.lblDay.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblDay.adjustsFontForContentSizeCategory = true
        self.lblDay.adjustsFontSizeToFitWidth = true
        
        self.lblHours.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblHours.adjustsFontForContentSizeCategory = true
        self.lblHours.adjustsFontSizeToFitWidth = true
        
        self.lblMin.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblMin.adjustsFontForContentSizeCategory = true
        self.lblMin.adjustsFontSizeToFitWidth = true
        
        self.lblSecond.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblSecond.adjustsFontForContentSizeCategory = true
        self.lblSecond.adjustsFontSizeToFitWidth = true
        
        self.lblExpired.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblExpired.adjustsFontForContentSizeCategory = true
        self.lblExpired.adjustsFontSizeToFitWidth = true
        
    }
    func addLocalisation(){
        self.lblDay.text = "\(Vocabulary.getWordFromKey(key: "days.hint"))"
        self.lblHours.text = "\(Vocabulary.getWordFromKey(key: "hours.hint"))"
        self.lblMin.text = "\(Vocabulary.getWordFromKey(key: "minutes.hint"))"
        self.lblSecond.text = "\(Vocabulary.getWordFromKey(key: "seconds.hint"))"
        self.lblExpired.text = "\(Vocabulary.getWordFromKey(key: "expired.hint"))"
    }
    func getRemainingDays(expireDate:String)->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+02:00")
        let currentDate = "\(dateFormatter.string(from: Date().toGlobalTime()))"
        guard dateFormatter.date(from: currentDate)! < dateFormatter.date(from: expireDate)! else {
            return "0"
        }
        let calendar = NSCalendar.current
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: dateFormatter.date(from: currentDate)!)
        let date2 = calendar.startOfDay(for: dateFormatter.date(from: expireDate)!)
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        if let _ = components.day{
            return "\(components.day!)"
        }else{
            return "0"
        }
        
    }
    func getRemainingTime(expireDate:String){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+02:00")
        let currentDate = "\(dateFormatter.string(from: Date().toGlobalTime()))"
        
        guard let _ = dateFormatter.date(from: expireDate),let _ = dateFormatter.date(from: currentDate) else{
            self.resetTimer()
            return
        }
        guard dateFormatter.date(from: currentDate)! < dateFormatter.date(from: expireDate)! else {
            self.resetTimer()
            return
        }
        if currentDate != expireDate {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(calculateTime)), userInfo:expireDate, repeats: true)
            RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
            timer?.fire()
        }else {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    @objc func calculateTime(_ timer:Timer) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+02:00")

        if let _ = timer.userInfo{
            let stdate : String = "\(timer.userInfo!)"
            var startDate = dateFormatter.date(from: stdate)!
            startDate = startDate.toGlobalTime()
            let stdate1 : String = "\(dateFormatter.string(from: Date().toGlobalTime()))"
            let currentDate = dateFormatter.date(from: stdate1)!
            
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .month, .year])
            
            let differenceOfDate = Calendar.current.dateComponents(components, from: currentDate, to: startDate)
            
            if differenceOfDate.year == 0, differenceOfDate.month == 0,differenceOfDate.day == 0,differenceOfDate.hour == 0,differenceOfDate.minute == 0,differenceOfDate.second == 0{
                if let _ = self.couponDelegate{
                    //self.couponDelegate?.reloadCouponOnExpire()
                }
                self.resetTimer()
                self.timer?.invalidate()
                self.timer = nil
            }else{
//                self.objStackView.isHidden = false
                self.lblExpired.isHidden = false
                DispatchQueue.main.async {
                    
                    let dateStr: String = "\(differenceOfDate.day!)" + "d" + " " + "\(differenceOfDate.hour!)" + ":" + "\(differenceOfDate.minute!)" + ":" + "\(differenceOfDate.second!)"
                    
                    self.lblExpired.text = dateStr
                    
//                    if let _ = differenceOfDate.day{
//                        self.lblDayValue.text = "\(differenceOfDate.day!)"
//                    }
//                    if let _ = differenceOfDate.hour{
//                        self.lblHoursValue.text = "\(differenceOfDate.hour!)"
//                    }
//                    if let _ = differenceOfDate.minute{
//                        self.lblMinvalue.text = "\(differenceOfDate.minute!)"
//                    }
//                    if let _ = differenceOfDate.second{
//                        self.lblSecondValue.text = "\(differenceOfDate.second!)"
//                    }
                }
            }
        }
    }
    fileprivate func resetTimer(){
        DispatchQueue.main.async {
//            self.objStackView.isHidden = true
            self.lblExpired.isHidden = false
            self.lblDayValue.text = ""
            self.lblHoursValue.text = ""
            self.lblMinvalue.text = ""
            self.lblSecondValue.text = ""
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        if let _ = timer{
            self.resetTimer()
            timer?.invalidate()
            timer = nil
        }
    }
}
extension Date {
    
    
    public func next(_ weekday: Weekday,
                     direction: Calendar.SearchDirection = .forward,
                     considerToday: Bool = false) -> Date
    {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(weekday: weekday.rawValue)
        
        if considerToday &&
            calendar.component(.weekday, from: self) == weekday.rawValue
        {
            return self
        }
        
        return calendar.nextDate(after: self,
                                 matching: components,
                                 matchingPolicy: .nextTime,
                                 direction: direction)!
    }
    
    public enum Weekday: Int {
        case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    }
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self)) 
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
}

extension String{
    var changeDateFormateDDMMS:String{
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = dateFormatter.date(from: self){
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = tempLocale // reset the locale
            let dateString = dateFormatter.string(from: date)
            return dateString
        }else{
            return self
        }
    }
}
