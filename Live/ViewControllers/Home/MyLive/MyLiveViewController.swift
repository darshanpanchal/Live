//
//  MyLiveViewController.swift
//  Live
//
//  Created by ITPATH on 4/16/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import UberRides
import CoreLocation

enum PendingBookingStatus:String{
    case RequestedByTraveler
    case RequestedByGuide
    case Accepted
    case Confirmed
    case Canceled
    case pending
}

class MyLiveViewController: UIViewController,UIGestureRecognizerDelegate {
    
    @IBOutlet var tableViewMyLive:UITableView!
    //    @IBOutlet var buttonSetting:UIButton!
    @IBOutlet var imgProfile:ImageViewForURL!
    @IBOutlet var lblUserName:UILabel!
    //    @IBOutlet var lblNavTitle:UILabel!
    @IBOutlet var lblUserCityName:UILabel!
    @IBOutlet var objSegmentController:UISegmentedControl!
    @IBOutlet var anonymousName:UILabel!
    var buttonFullSchedule = UIButton()
    @IBOutlet var buttonAddNewExperience:RoundButton!
    @IBOutlet var tableViewFooterNOLogin:UIView!
    @IBOutlet var lblPleaseLogin:UILabel!
    @IBOutlet var buttonLogIn:UIButton!
    var objPendingExperience: PendingExperience?
    var is_PendingExper: Bool = true
    var pendingCountView = UIView()
    var lblPendingCount = UILabel()
    var arrayOfPendingSchedule:[Schedule] = []
    var expandCollapsSet:NSMutableSet = NSMutableSet()
    var tableViewHeightOfHeaderTraveller:CGFloat{
        get{
            return 130.0
        }
    }
    var tableViewHeightOfHeaderGuide:CGFloat{
        get{
            return 120.0
        }
    }
    var tableviewHeightFooterView:CGFloat{
        get{
            return 52.0
        }
    }
    
    var tableviewExperienceRowHeight:CGFloat{
        get{
            return 380
//            UIScreen.main.bounds.width*0.5+60+100+30
        //UIScreen.main.bounds.height * 360.0/812.0
            //return UIScreen.main.bounds.width*0.6+40+100//UIScreen.main.bounds.height * 360.0/812.0
        }
    }
    var arrayOfExperienceTitle:[String] = []
    var arrayOfExperienceDiscription:[String] = []
    var arrayOfUpcomingExperience:[Experience] = []
    var arrayOfPendingExperience:[PendingExperience] = []
    var arrayOfWishListExperience:[Experience] = []
    var arrayOfLivedExperience:[Experience] = []
    var arrayOfToursTitle:[String] = []
    var arrayOfToursDiscription:[String] = []
    var arrayOfTours:[Experience] = []
    var arrayOfRowSection:NSArray = []
    var currentUser:User?
    var currentPageIndex:Int = 0 //pagination for all experienceA
    var currentPageSize:Int = 10 //pagination for all experience
    var pendingBookingCount:Int = 0 //default 0
    var isMyTourLoadMore = true
    var myTourPageIndex:Int = 0
    var isUpcomingLoadMore = true
    var upcomingPageIndex:Int = 0
    var isWishListLoadMore = true
    var wishListPageIndex:Int = 0
    var isLivedLoadMore = true
    var livedPageIndex:Int = 0
    var locationManager:CLLocationManager = CLLocationManager()
    var latitude:String = ""
    var longitude:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding Pending Count View
        pendingCountView.frame = CGRect(x: 32, y: 6.5, width: 18, height: 18)
        pendingCountView.backgroundColor = UIColor(hexString: "D23150")
        lblPendingCount.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
        lblPendingCount.textAlignment = .center
        lblPendingCount.font = UIFont(name: "Avenir-Heavy", size: 13.0)
        lblPendingCount.textColor = UIColor.white
        lblPendingCount.backgroundColor = UIColor.clear
        
        // Calendar Button
        buttonFullSchedule.setImage(UIImage(named: "myLiveCalendar"), for: .normal)
        buttonFullSchedule.imageView?.contentMode = .scaleAspectFit
        buttonFullSchedule.imageEdgeInsets = UIEdgeInsetsMake(0.0,10.0,20.0,10.0)
        buttonFullSchedule.frame = CGRect(x: 10, y: 11.0, width: 45, height: 45)
//        buttonFullSchedule.backgroundColor = .red
        buttonFullSchedule.addTarget(self, action: #selector(self.buttonFullScheduleSelector), for: .touchUpInside)
        //self.tabBarController?.navigationController?.navigationBar.addSubview(buttonFullSchedule)
        if User.isUserLoggedIn{
            self.navigationController?.navigationBar.addSubview(buttonFullSchedule)
            pendingCountView.addSubview(lblPendingCount)
        }
    
        
        // Settings Button
        let btnSettings = UIButton()
        btnSettings.setImage(UIImage(named: "settings"), for: .normal)
        btnSettings.frame = CGRect(x: self.view.frame.width - 40, y: 11.0, width: 22, height: 22)
        btnSettings.addTarget(self, action: #selector(self.buttonSettingSelector), for: .touchUpInside)
        //self.tabBarController?.navigationController?.navigationBar.addSubview(btnSettings)
        if User.isUserLoggedIn{
            self.navigationController?.navigationBar.addSubview(btnSettings)
            //self.tabBarController?.navigationController?.navigationBar.addSubview(pendingCountView)
            self.navigationController?.navigationBar.addSubview(pendingCountView)
        }
        guard User.isUserLoggedIn else {
//            let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"notLogin.title"), message: Vocabulary.getWordFromKey(key:"login_request_message_mylive"), preferredStyle: .alert)
//            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (_) in
//                self.navigationController?.popToRootViewController(animated: true)
//            }))
//            self.present(alertController, animated: true, completion: nil)
            return
        }
        let attributedText = NSDictionary(object: UIFont(name: "Avenir-Roman", size: 13.0)!, forKey: NSAttributedStringKey.font as NSCopying)
        self.objSegmentController.setTitleTextAttributes(attributedText as [NSObject : AnyObject] , for: .normal)
        
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.view.backgroundColor = UIColor.white
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        if #available(iOS 11.0, *) {
            DispatchQueue.main.async {
                self.navigationController?.navigationBar.prefersLargeTitles = true
                self.navigationController?.navigationBar.topItem?.title = Vocabulary.getWordFromKey(key: "MyLive")
                self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
                let attributes = [
                    NSAttributedStringKey.foregroundColor : UIColor.black, NSAttributedStringKey.font : UIFont(name: "Avenir-Black", size: 34.0)
                ]
                self.navigationController?.navigationBar.largeTitleTextAttributes = attributes
            }
        } else {
            // Fallback on earlier versions
        }
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
        DispatchQueue.main.async {
            self.arrayOfTours = []
            self.arrayOfUpcomingExperience = []
            self.arrayOfPendingExperience = []
            self.arrayOfWishListExperience = []
            self.arrayOfLivedExperience = []
            self.isMyTourLoadMore = true
            self.myTourPageIndex = 0
            self.isUpcomingLoadMore = true
            self.upcomingPageIndex = 0
            self.isWishListLoadMore = true
            self.wishListPageIndex = 0
            self.isLivedLoadMore = true
            self.livedPageIndex = 0
        }
        
        arrayOfExperienceDiscription = ["",Vocabulary.getWordFromKey(key:"UpcomingExperiences"),Vocabulary.getWordFromKey(key:"UpcomingExperiences.msg"),Vocabulary.getWordFromKey(key:"LivedExperiences.msg")]
        arrayOfExperienceTitle = ["Pending Experiences",Vocabulary.getWordFromKey(key: "UpcomingExperiences"),Vocabulary.getWordFromKey(key:"Wishlist"),Vocabulary.getWordFromKey(key:"LivedExperiences")]
        arrayOfToursTitle = [Vocabulary.getWordFromKey(key:"MyTours")]
        arrayOfToursDiscription = [Vocabulary.getWordFromKey(key:"YourTours")]
        self.changeTextAsLanguage()
        DispatchQueue.main.async {
            //ConfigureTableView
            self.configureMyLiveTableView()
        }
        //Configure TableView Header
        self.configureTableViewHeader()
        if User.isUserLoggedIn{
            self.anonymousName.isHidden = true
            self.objSegmentController.isHidden = false
        }else{
            self.objSegmentController.isHidden =  true
            self.anonymousName.isHidden = false
            self.anonymousName.text = Vocabulary.getWordFromKey(key: "Anonymous")
        }
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
        guard User.isUserLoggedIn else {
//            let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"notLogin.title"), message: Vocabulary.getWordFromKey(key:"notLogin.msg"), preferredStyle: .alert)
//            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (_) in
//                self.navigationController?.popToRootViewController(animated: true)
//            }))
//            self.present(alertController, animated: true, completion: nil)
            self.tableViewFooterNOLogin.isHidden = false
            if let _ = self.tableViewMyLive.tableFooterView{
                //self.tableViewMyLive.tableFooterView?.frame = CGRect.init(x: 0, y: 0, width: self.tableViewMyLive.bounds.width, height: 300.0)
                DispatchQueue.main.async {
                    //self.tableViewMyLive.layoutIfNeeded()
                }
            }
            return
        }
        self.tableViewFooterNOLogin.isHidden = true
        if let _ = self.tableViewMyLive.tableFooterView{
           // self.tableViewMyLive.tableFooterView?.frame = CGRect.init(x: 0, y: 0, width: self.tableViewMyLive.bounds.width, height: 52.0)
        }
        DispatchQueue.main.async {
            self.tableViewMyLive.layoutIfNeeded()
        }
        //Get currentUser
        self.currentUser = User.getUserFromUserDefault()
        if self.currentUser!.userDefaultRole == "User" {
            self.objSegmentController.isHidden = true
            //self.lblUserCityName.isHidden = true
        }else if self.currentUser!.userDefaultRole == "traveller" {
            self.objSegmentController.isHidden = false
            //self.lblUserCityName.isHidden = false
        }else{
            self.objSegmentController.isHidden = false
        }
        //        imgProfile.layer.borderWidth = 1.0
        //        imgProfile.layer.borderColor = UIColor.black.withAlphaComponent(0.7).cgColor
        //Configure UserRole
        self.configureArrayOnUserRole()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // your code here
            self.configureRequestUserRole()
        }
      
        self.lblUserName.text = "\(self.currentUser!.userFirstName) \(self.currentUser!.userLastName)"
        
        
        DispatchQueue.main.async {
            if let imgUrl = self.currentUser?.userImageURL,imgUrl.count > 0 {
                self.imgProfile.imageFromServerURL(urlString:self.currentUser!.userImageURL,placeHolder:UIImage.init(named:"updatedProfilePlaceholder")!)
            }else {
                self.imgProfile.image = UIImage.init(named:"updatedProfilePlaceholder")
            }
        }
        //        self.buttonAddNewExperience.layer.borderWidth = 0.5
        //        self.buttonAddNewExperience.layer.borderColor = UIColor.black.cgColor
        //        self.buttonAddNewExperience.setBackgroundColor(color: .lightGray, forState: .highlighted)
        imgProfile.contentMode = .scaleAspectFill
       imgProfile.clipsToBounds = true
       

    }
    func addDynamicFont(){
        
        //        self.lblNavTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        //        self.lblNavTitle.adjustsFontForContentSizeCategory = true
        //        self.lblNavTitle.adjustsFontSizeToFitWidth = true
        
        self.buttonLogIn.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonLogIn.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonLogIn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.buttonAddNewExperience.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonAddNewExperience.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonAddNewExperience.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
        self.lblUserName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblUserName.adjustsFontForContentSizeCategory = true
        self.lblUserName.adjustsFontSizeToFitWidth = true
        
//        self.lblUserCityName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
//        self.lblUserCityName.adjustsFontForContentSizeCategory = true
//        self.lblUserCityName.adjustsFontSizeToFitWidth = true
        
    }
    
    func changeTextAsLanguage() {
        //        self.lblNavTitle.text = Vocabulary.getWordFromKey(key: "MyLive")
        //        self.buttonFullSchedule.setTitle(Vocabulary.getWordFromKey(key: "fullSchedule"), for: .normal)
        self.objSegmentController.setTitle(Vocabulary.getWordFromKey(key: "GUIDE"), forSegmentAt: 0)
        self.objSegmentController.setTitle(Vocabulary.getWordFromKey(key: "TRAVELER"), forSegmentAt: 1)
        self.buttonAddNewExperience.setTitle(Vocabulary.getWordFromKey(key: "AddNewExperiences"), for: .normal)
        self.buttonLogIn.setTitle(Vocabulary.getWordFromKey(key: "title.signIn"), for: .normal)
        self.lblPleaseLogin.text = "\(Vocabulary.getWordFromKey(key: "PleaseLogIn.hint"))"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Methods
    
    @objc func payBtnPressed(Sender: UIButton) {
        print(Sender.tag)
        self.objPendingExperience = self.arrayOfPendingExperience[Sender.tag]
        let bookStoryBoard = UIStoryboard(name: "BooknowDetailSB", bundle: Bundle.main)
        if let paymentViewController = bookStoryBoard.instantiateViewController(withIdentifier:"PaymentViewController") as? PaymentViewController,let _ = self.objPendingExperience{
//            if let _ = objPendingExperience?.isInstantBooking{
//                paymentViewController.isInstantBooking = true
//            }
//            tempExpObj?.isGroupPrice = objPendingExperience!.isGroupBooking
//            tempExpObj?.experienceBookingDate = objPendingExperience!.date
            
            paymentViewController.objExperience = self.objPendingExperience!
            paymentViewController.bookingTimeStr = "\(self.objPendingExperience!.time)"
            if let _ = self.objPendingExperience?.slots {
                paymentViewController.numberOfGuest = Int("\(self.objPendingExperience!.slots)")!
            }
            paymentViewController.bookingDate = changeDateFormat(dateStr: "\(self.objPendingExperience!.date)")
            paymentViewController.isGroupBooking = self.objPendingExperience?.isGroupBooking
            DispatchQueue.main.async {
                paymentViewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(paymentViewController, animated: true)
            }
        }
    }
    
    
    
    // Date Formatter for Review cell
    func changeDateFormat(dateStr: String) -> String {
        var dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let  dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        
        if let date = dateFormatter.date(from: dateStr){
            return dateFormatter1.string(from: date)
        }else{
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = dateFormatter.date(from: dateStr){
                return dateFormatter1.string(from: date)
            }
            return dateStr
        }
    }
    
    func configureRequestUserRole(){
        
        if self.currentUser!.userType == .guide{
            self.objSegmentController.selectedSegmentIndex = 0
        }else if self.currentUser!.userType == .traveller{
            self.objSegmentController.selectedSegmentIndex = 1
        }
        //Configure PendingBookingCount
        self.getPendingBookingCount()
    }
    func configureArrayOnUserRole(){
        self.lblUserCityName.text = "\(self.currentUser!.userCurrentCity), \(self.currentUser!.userCurrentCountry)"
        
        if self.currentUser!.userType == .guide{
            self.arrayOfRowSection = [self.arrayOfTours]
            self.buttonFullSchedule.isHidden = false
            if self.pendingBookingCount > 0{
                self.pendingCountView.isHidden = false
                self.lblPendingCount.text = "\(self.pendingBookingCount)"
            }else{
                self.pendingCountView.isHidden = true
            }
            if let _ = self.tableViewMyLive.tableHeaderView{
                self.tableViewMyLive.tableHeaderView?.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.tableViewMyLive.bounds.width, height: self.tableViewHeightOfHeaderGuide))
            }
            if let _ = self.tableViewMyLive.tableFooterView{
                self.tableViewMyLive.tableFooterView?.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.tableViewMyLive.bounds.width, height: self.tableviewHeightFooterView))
            }
            
        }else if self.currentUser!.userType == .traveller{
            self.arrayOfRowSection = [self.arrayOfPendingExperience,self.arrayOfUpcomingExperience,self.arrayOfWishListExperience,self.arrayOfLivedExperience]
            self.buttonFullSchedule.isHidden = true
            self.pendingCountView.isHidden = true
            if let _ = self.tableViewMyLive.tableHeaderView{
                self.tableViewMyLive.tableHeaderView?.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.tableViewMyLive.bounds.width, height: self.tableViewHeightOfHeaderTraveller))
            }
            if let _ = self.tableViewMyLive.tableFooterView{
                self.tableViewMyLive.tableFooterView?.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.zero)
            }
            
        }
    }
    func configureTableViewHeader(){
        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.width / 2.0
        self.imgProfile.clipsToBounds = true
        //        self.objSegmentController.layer.cornerRadius = 14.0
        //        self.objSegmentController.clipsToBounds = true
        //        self.objSegmentController.layer.borderWidth = 1.0
        self.pendingCountView.layer.cornerRadius = pendingCountView.frame.width / 2.0
        self.pendingCountView.clipsToBounds = true
        self.configurePendingBookingCount()
    }
    func configureMyLiveView(){
        //GET Upcoming Experiences
        self.getTravelerPendingBooking()
        
        //GET Upcoming Experiences
        self.getUpcomingExperiences()
    }
    func configureGuideTours(){
        //GET guide tour
        self.getGuideTours()
    }
    func configurePendingBookingCount(){
        if self.pendingBookingCount > 0,self.currentUser!.userType == .guide{
            self.pendingCountView.transform = CGAffineTransform(scaleX: 0, y: 0)
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.pendingCountView.transform = .identity
            }, completion: nil)
            DispatchQueue.main.async {
                self.pendingCountView.isHidden = false
                self.lblPendingCount.text = "\(self.pendingBookingCount)"
            }
        }else{
            self.pendingCountView.isHidden = true
        }
    }
    func configureMyLiveTableView(){
        self.tableViewMyLive.rowHeight = UITableViewAutomaticDimension
        self.tableViewMyLive.estimatedRowHeight = 150.0
        self.tableViewMyLive.delegate = self
        self.tableViewMyLive.dataSource = self
        //Register Experience TableViewCell
        let objExperienceNib = UINib.init(nibName: "ExperienceTableViewCell", bundle: nil)
        self.tableViewMyLive.register(objExperienceNib, forCellReuseIdentifier: "ExperienceTableViewCell")
        self.tableViewMyLive.separatorStyle = .none
        self.tableViewMyLive.reloadData()
    }
    // MARK: - API Request Methods
    //GET pending booking count
    func getPendingBookingCount(){
        let kURLPendingCount = "\(kPendingBookingCount)\(self.currentUser!.userID)/pendingbooking"
        //DefaultUserID will be 1
        //        let kURLPendingCount = "\(kPendingBookingCount)1/pendingbooking"
        
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:kURLPendingCount, parameter: nil, isHudeShow: false, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let count = successDate["PendingBooking"] as? Int{
                self.pendingBookingCount = count
                DispatchQueue.main.async {
                    self.configurePendingBookingCount()
                }
                //Configure GuideTours
                self.configureGuideTours()
            }else{
                DispatchQueue.main.async {
                    // ShowToast.show(toatMessage:kCommonError)
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
    
    //Get Traveler Pending Booking experiences
    func getTravelerPendingBooking(){
        let requestURL = "\(kTravelerPendingBooking)\(self.currentUser!.userID)/pendingbooking"
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:requestURL, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let array = successDate["PendingSchedule"] as? [[String:Any]] {
                self.arrayOfPendingSchedule = []
                self.arrayOfPendingExperience = []
                for object in array{
                    let objSchedule = Schedule.init(scheduleDetail: object)
                    self.arrayOfPendingSchedule.append(objSchedule)
                    let objectExperience = PendingExperience.init(PendingExperienceDetail: object)
                    self.arrayOfPendingExperience.append(objectExperience)
                }
                DispatchQueue.main.async {
                    self.tableViewMyLive.reloadData()
                }
            }else{
                DispatchQueue.main.async {
                    // ShowToast.show(toatMessage:kCommonError)
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
    
    //GET user's(traveller) upcoming experiences
    func getUpcomingExperiences(){
        let kURLUpcoming = "\(kUserExperience)\(self.currentUser!.userID)/future?pagesize=\(self.currentPageSize)&pageindex=\(self.upcomingPageIndex)"
        //Default UserID will be 3
        //        let kURLUpcoming = "\(kUserExperience)3/future?pagesize=\(self.currentPageSize)&pageindex=\(self.currentPageIndex)"
        var animatedUpcoming:Bool = false
        if self.currentUser!.userType == .traveller,self.upcomingPageIndex == 0{
            animatedUpcoming = true
        }else{
            animatedUpcoming = false
        }
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:kURLUpcoming, parameter: nil, isHudeShow: animatedUpcoming, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let array = successDate["FutureExperiences"] as? [[String:Any]]{
                if self.upcomingPageIndex == 0{
                    self.arrayOfUpcomingExperience = []
                }
                self.isUpcomingLoadMore = (array.count == self.currentPageSize)
                for object in array{
                    let objectExperience = Experience.init(experienceDetail: object)
                    self.arrayOfUpcomingExperience.append(objectExperience)
                }
                DispatchQueue.main.async {
                    //self.tableViewMyLive.reloadData()
                    //GET Wishlist Experiences
                    if self.upcomingPageIndex == 0{
                        self.getWishListExperiences()
                    }else{
                        self.tableViewMyLive.reloadData()
                    }
                }
            }else{
                DispatchQueue.main.async {
                    //ShowToast.show(toatMessage:kCommonError)
                    self.tableViewMyLive.reloadData()
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
    //GET user's(traveller) wishList experiences
    func getWishListExperiences(){
        let kURLWishlist = "\(kUserExperience)\(currentUser!.userID)/wishlist?pagesize=\(self.currentPageSize)&pageindex=\(self.wishListPageIndex)"
        //Default UserID will be 3
        //        let kURLWishlist = "\(kUserExperience)3/wishlist?pagesize=\(self.currentPageSize)&pageindex=\(self.currentPageIndex)"
        
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:kURLWishlist, parameter: nil, isHudeShow: false, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let array = successDate["WishList"] as? [[String:Any]]{
                if self.wishListPageIndex == 0{
                    self.arrayOfWishListExperience = []
                }
                self.isWishListLoadMore = (array.count == self.currentPageSize)
                for object in array{
                    let objectExperience = Experience.init(experienceDetail: object)
                    self.arrayOfWishListExperience.append(objectExperience)
                }
                DispatchQueue.main.async {
                    //self.tableViewMyLive.reloadData()
                    //GET Lived Experiences
                    if self.wishListPageIndex == 0{
                        self.getLivedExperiences()
                    }else{
                        self.tableViewMyLive.reloadData()
                    }
                    
                    //                    if self.arrayOfWishListExperience.count > 0{
                    //                        let strDiscription = self.arrayOfExperienceDiscription[1]
                    //                        self.arrayOfExperienceDiscription[1] = "\(self.arrayOfWishListExperience.count) \(strDiscription)"
                    //                    }
                    //self.tableViewMyLive.reloadRows(at: [IndexPath.init(row: 1, section: 0)],  with: .automatic)
                }
            }else{
                DispatchQueue.main.async {
                    //ShowToast.show(toatMessage:kCommonError)
                    self.tableViewMyLive.reloadData()
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
    //GET user's(traveller) wishlist experiences
    func getLivedExperiences(){
        let kURLLived = "\(kUserExperience)\(currentUser!.userID)/past?pagesize=\(self.currentPageSize)&pageindex=\(self.livedPageIndex)"
        //Default UserID will be 3
        //        let kURLLived = "\(kUserExperience)3/past?pagesize=\(self.currentPageSize)&pageindex=\(self.currentPageIndex)"
        
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:kURLLived, parameter: nil, isHudeShow: self.livedPageIndex == 0 ? false:false, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let array = successDate["PastExperiences"] as? [[String:Any]]{
                if self.livedPageIndex == 0{
                    self.arrayOfLivedExperience = []
                }
                self.isLivedLoadMore = (array.count == self.currentPageSize)
                for object in array{
                    let objectExperience = Experience.init(experienceDetail: object)
                    self.arrayOfLivedExperience.append(objectExperience)
                }
                DispatchQueue.main.async {
                    self.tableViewMyLive.reloadData()
                    //                    if self.arrayOfLivedExperience.count > 0{
                    //                        let strDiscription = self.arrayOfExperienceDiscription[2]
                    //                        self.arrayOfExperienceDiscription[2] = "\(self.arrayOfLivedExperience.count) \(strDiscription)"
                    //                    }
                    //self.tableViewMyLive.reloadRows(at: [IndexPath.init(row: 2, section: 0)],  with: .automatic)
                }
            }else{
                DispatchQueue.main.async {
                    //ShowToast.show(toatMessage:kCommonError)
                    self.tableViewMyLive.reloadData()
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
    //Get user's(guide) tours
    func getGuideTours(){
        //{{baseUrl}}/api/experience/native/guides/3/mytours?pagesize=10&pageindex=0
        let kURLTour = "\(kGuideTours)\(currentUser!.userID)/mytours?pagesize=\(self.currentPageSize)&pageindex=\(self.myTourPageIndex)"
        //Default UserID will be 3
        //        let kURLTour = "\(kGuideTours)3/mytours?pagesize=\(self.currentPageSize)&pageindex=\(self.currentPageIndex)"
        var animatedTour:Bool = false
        if let user = User.getUserFromUserDefault(),user.userType == .guide{
            animatedTour = true
        }else{
            animatedTour = false
        }
        //        if self.currentUser!.userDefaultRole == "User"{
        //            animatedTour = false
        //        }else if self.currentUser!.userDefaultRole == "traveller"{
        //            animatedTour = true
        //        }
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:kURLTour, parameter: nil, isHudeShow: self.myTourPageIndex == 0 ? animatedTour : false , success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let array = successDate["MyTours"] as? [[String:Any]]{
                if self.myTourPageIndex == 0{
                    self.arrayOfTours = []
                }
                self.isMyTourLoadMore = array.count == self.currentPageSize
                for object in array{
                    let objectExperience = Experience.init(experienceDetail: object)
                    self.arrayOfTours.append(objectExperience)
                }
                
                DispatchQueue.main.async {
                    if self.myTourPageIndex == 0{
                        //ConfigureMyLive
                        self.tableViewMyLive.reloadData()
                        self.configureMyLiveView()
                    }else{
                        self.tableViewMyLive.reloadData()
                    }
                    //                    if self.arrayOfTours.count > 0{
                    //                        let strDiscription = self.arrayOfExperienceDiscription[0]
                    //                        self.arrayOfExperienceDiscription[0] = "\(self.arrayOfTours.count) \(strDiscription)"
                    //                    }
                    //self.tableViewMyLive.reloadRows(at: [IndexPath.init(row: 0, section: 0)],  with: .automatic)
                }
            }else{
                DispatchQueue.main.async {
                     self.tableViewMyLive.reloadData()
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
    //Delete Experience
    func deleteExperience(experienceID:String,index:Int,locationID:String){
        //{{baseUrl}}/api/experience/1/native/locations/2
        
        //Default Default location ID will be 2
        let kURLDeleteExperience = "\(kDeleteExperience)\(experienceID)/native/locations/\(locationID)" //\(self.currentUser!.userLocationID)"
        
        APIRequestClient.shared.sendRequest(requestType: .DELETE, queryString:kURLDeleteExperience, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let isDeleted = successDate["ExperienceDeleted"] as? Bool,let strMsg = successDate["Message"] {
                if isDeleted{
                    self.arrayOfTours.remove(at: index)
                    DispatchQueue.main.async {
                        self.tableViewMyLive.reloadRows(at:[IndexPath.init(row: 0, section: 0)], with: .automatic)
                        let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"ExperienceDeleted"), message: "\(strMsg)", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .cancel, handler: nil))
                        alertController.view.tintColor = UIColor.init(hexString: "#36527D")
                        self.present(alertController, animated: true, completion: nil)
                    }
                }else{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:"\(strMsg)")
                    }
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
    //Active InActiveExperience
    func activeInActiveExperience(objExperience:Experience){
        //
        let kURLActiceInActiveExperience = "experience/\(objExperience.id)/native/blockstatus/\(!objExperience.isBlock)/block"
        
        APIRequestClient.shared.sendRequest(requestType: .PUT, queryString:kURLActiceInActiveExperience , parameter:nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let _ = successData["Message"]{
                /*
                 let objAlert = UIAlertController.init(title: Vocabulary.getWordFromKey(key:"Success"), message: "\(successMessage)", preferredStyle: .alert)
                 objAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (action: UIAlertAction!) in
                 }))
                 self.present(objAlert, animated: true, completion: nil)*/
                DispatchQueue.main.async {
                    objExperience.isBlock = !objExperience.isBlock
                    self.tableViewMyLive.reloadData()
                    //self.getGuideTours()
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
    //Cancel Upconing Experience
    func cancelUpcomingExperience(experience:Experience){
        //First Check for valide time for cancel booking if it's 48 hrs remaining for experience then cancel without refund otherwise cancel with
        self.isValideCancelTimeforRefund(experience: experience)
    }
    func isValideCancelTimeforRefund(experience:Experience){
        let requestURL = "\(kIsValidExperienceTime)\(experience.bookingID)/bookingtime"
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:requestURL, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let isNeedRefund = successDate["NeedRefund"]{
                if Bool.init("\(isNeedRefund)"){
                    
                    let objAlert = UIAlertController.init(title: "", message: "", preferredStyle: .alert)
                    objAlert.view.layer.cornerRadius = 14.0
                    let titleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17.0)!]
                    let messageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
                    let titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key:"CancelTour"), attributes: titleFont)
                    let messageAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key:"CancelTour.msg"), attributes: messageFont)
                    
                    objAlert.setValue(titleAttrString, forKey: "attributedTitle")
                    objAlert.setValue(messageAttrString, forKey: "attributedMessage")
                    objAlert.view.tintColor = UIColor(hexString: "#36527D")
                    
                    objAlert.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (_ ) in
                        //Are you sure you want to Cancel this tour?
                        self.cancelBookingWithRefund(objExperience: experience)
                    }))
                    objAlert.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler: nil))
                    self.present(objAlert, animated: true, completion: nil)
                }else{
                    let objAlert = UIAlertController.init(title: "", message: "", preferredStyle: .alert)
                    objAlert.view.layer.cornerRadius = 14.0
                    let titleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17.0)!]
                    let messageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
                    let titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key:"CancelTour"), attributes: titleFont)
                    let messageAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key:"cancellation.msg"), attributes: messageFont)
                    
                    objAlert.setValue(titleAttrString, forKey: "attributedTitle")
                    objAlert.setValue(messageAttrString, forKey: "attributedMessage")
                    objAlert.view.tintColor = UIColor(hexString: "#36527D")

                    objAlert.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (_ ) in
                        self.cancelBookingWithOutRefund(objExperience: experience, is_PendingExper: true)
                        //self.cancelBookingWithRefund(objExperience: experience)
                    }))
                    objAlert.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler: nil))
                    self.present(objAlert, animated: true, completion: nil)
                }
            }else{
                DispatchQueue.main.async {
                    // ShowToast.show(toatMessage:kCommonError)
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
    //Put request for cancel booking withoout refund
    func cancelBookingWithOutRefund(objExperience:Experience, is_PendingExper: Bool){
        
        var cancelBookingParameters:[String:Any] = [:]
        cancelBookingParameters["BookingId"] = "\(objExperience.bookingID)"
        cancelBookingParameters["ExperienceTitle"] = "\(objExperience.title)"
        cancelBookingParameters["GuideId"] = "\(objExperience.guideID)"
        cancelBookingParameters["UserName"] = "\(objExperience.userName)"
        
        APIRequestClient.shared.sendRequest(requestType: .PUT, queryString:kExperienceBookingCancelWithOutRefund , parameter:cancelBookingParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let successMessage = successData["Message"],let _ = successData["CancelBooking"]{
                let backAlert = UIAlertController(title: Vocabulary.getWordFromKey(key:"CancelTour"), message: "\(successMessage)",preferredStyle: UIAlertControllerStyle.alert)
                
                backAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (action: UIAlertAction!) in
                    //                    DispatchQueue.main.async {
                    //                        if let strIndex = objExperience.accessibilityValue{
                    //                            if self.arrayOfUpcomingExperience.count > Int(strIndex)!{
                    //                                self.arrayOfUpcomingExperience.remove(at: Int(strIndex)!)
                    //                                self.tableViewMyLive.reloadData()
                    //                            }
                    //                        }
                    //                    }
                    /*
                    if is_PendingExper == true{
                        if let strIndex = objExperience.accessibilityValue{
                            if self.arrayOfPendingExperience.count > Int(strIndex)!{
                                self.arrayOfPendingExperience.remove(at: Int(strIndex)!)
                                
                            }
                        }
                    }else{
                        if let strIndex = objExperience.accessibilityValue{
                            if self.arrayOfUpcomingExperience.count > Int(strIndex)!{
                                self.arrayOfUpcomingExperience.remove(at: Int(strIndex)!)
                                
                            }
                        }
                    }*/
                    // }
                    DispatchQueue.main.async {
                        self.configureMyLiveView()
                        self.tableViewMyLive.reloadData()
                    }
                }))
                backAlert.view.tintColor = UIColor.init(hexString: "#36527D")
                self.present(backAlert, animated: true, completion: nil)
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
    //Put request for cancel booking with refund
    
    func cancelBookingWithRefund(objExperience:Experience){
        var cancelBookingParameters:[String:Any] = [:]
        cancelBookingParameters["BookingId"] = "\(objExperience.bookingID)"
        cancelBookingParameters["ExperienceTitle"] = "\(objExperience.title)"
        cancelBookingParameters["GuideId"] = "\(objExperience.guideID)"
        cancelBookingParameters["UserName"] = "\(objExperience.userName)"
        cancelBookingParameters["IsCancelByGuide"] = "false"
        cancelBookingParameters["UserId"] = "\(objExperience.userID)"
        
        APIRequestClient.shared.sendRequest(requestType: .PUT, queryString:kExperienceBookingCancelWithRefund , parameter:cancelBookingParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let successMessage = successData["Message"],let _ = successData["CancelBooking"]{
                let backAlert = UIAlertController(title: Vocabulary.getWordFromKey(key:"CancelTour"), message: "\(successMessage)",preferredStyle: UIAlertControllerStyle.alert)
                backAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (action: UIAlertAction!) in
                    DispatchQueue.main.async {
//                        if self.is_PendingExper == true{
//                            if let strIndex = objExperience.accessibilityValue{
//                                if self.arrayOfPendingExperience.count > Int(strIndex)!{
//                                    self.arrayOfPendingExperience.remove(at: Int(strIndex)!)
//
//                                }
//                            }
//                        }else{
//                            if let strIndex = objExperience.accessibilityValue{
//                                if self.arrayOfUpcomingExperience.count > Int(strIndex)!{
//                                    self.arrayOfUpcomingExperience.remove(at: Int(strIndex)!)
//
//                                }
//                            }
//                        }
                    }
                    DispatchQueue.main.async {
                        self.configureMyLiveView()
                        self.tableViewMyLive.reloadData()
                    }
                }))
                self.present(backAlert, animated: true, completion: nil)
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
    //  Favourite API Calling
    func favouriteFunctionality(userID:String, isFavourite: String, experienceId: String) {
        let urlBookingDetail = "experience/native/wishlist"
        let requestParameters =
            ["UserId":userID,
             "ExperienceId":experienceId,
             "IsDelete":isFavourite
                ] as[String : AnyObject]
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:urlBookingDetail, parameter: requestParameters, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let _ = success["data"] as? [String:Any] {
                if let dataDic = success["data"] as? [String:Any] {
                    let resultStr = dataDic["Result"] as? Int
                    DispatchQueue.main.async {
                        self.getWishListExperiences()
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
    // MARK: - Selector Methods
    @objc func buttonSettingSelector(){
        //PushToSettingViewController
        self.pushToSettingViewController()
    }
    @IBAction func buttonLogInSelector(sender:UIButton){
        self.tabBarController?.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func buttonSegmentControllerSelector(sender:UISegmentedControl){
        switch sender.selectedSegmentIndex {
        case 0: //Guide
            self.currentUser!.userType = .guide
            break
        case 1: //Traveler
            self.currentUser!.userType = .traveller
            break
        default:
            break
        }
        self.currentUser!.setUserDataToUserDefault()
        DispatchQueue.main.async {
            self.configureArrayOnUserRole()
            self.tableViewMyLive.reloadData()
        }
    }
    @objc func buttonFullScheduleSelector(){
        //PushToScheduleController
        self.pushToFullScheduleViewController()
    }
    @IBAction func buttonAddNewExperienceSelector(sender:UIButton){
        //PushToAddNewExperience Controller
        self.pushToAddNewExperienceViewController()
    }
    @IBAction func unwindToMyLiveViewFromRatingView(segue:UIStoryboardSegue){
        if User.isUserLoggedIn,let _ = User.getUserFromUserDefault(){
            self.getLivedExperiences()
        }
        
    }
    @IBAction func unwindToMyLiveFromOfferAnotherDay(segue:UIStoryboardSegue){
        if User.isUserLoggedIn,let _ = User.getUserFromUserDefault(){
            self.getTravelerPendingBooking()
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    //PushToSettingViewController
    func pushToSettingViewController(){
        if let settingViewController = self.storyboard?.instantiateViewController(withIdentifier:
            "SettingViewController") as? SettingViewController{
            print(self.objSegmentController.selectedSegmentIndex)
            if self.objSegmentController.selectedSegmentIndex == 0 {
                settingViewController.guide = true
                self.currentUser!.userType = .guide
            } else  {
                settingViewController.guide = false
                self.currentUser!.userType = .traveller
            }
            settingViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(settingViewController, animated: true)
        }
    }
    //PushToAddNewExperienceViewController
    func pushToAddNewExperienceViewController(){
        if let addNewExperienceController = self.storyboard?.instantiateViewController(withIdentifier: "AddExperienceViewController") as? AddExperienceViewController{
            addNewExperienceController.isEdit = false
            addNewExperienceController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(addNewExperienceController, animated: true)
        }
    }
    //PushToEditExperienceViewController
    func pushToEditExperienceViewController(objExperience:Experience){
        if let editExperienceViewController:AddExperienceViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddExperienceViewController") as? AddExperienceViewController{
            editExperienceViewController.isEdit = true
            editExperienceViewController.editExperience = objExperience
            editExperienceViewController.hidesBottomBarWhenPushed = true

            self.navigationController?.pushViewController(editExperienceViewController, animated: true)
            
        }
    }
    //PushToFullScheduleViewController
    func pushToFullScheduleViewController(){
        if let fullSchedule:UIViewController = self.storyboard?.instantiateViewController(withIdentifier: "FullScheduleViewController") as? FullScheduleViewController{
            fullSchedule.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(fullSchedule, animated: true)
        }
    }
    func checkLocationPermission(objExperience:Experience) {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                self.openSetting()
            case .authorizedAlways, .authorizedWhenInUse:
                self.presentUberRideInvitation(objExperience: objExperience)
            }
        } else {
            self.openSetting()
        }
    }
    func openSetting(){
        let alertController = UIAlertController.init(title:"\(Vocabulary.getWordFromKey(key:"LocationDisable"))", message: "\(Vocabulary.getWordFromKey(key:"locationCity")) \(Vocabulary.getWordFromKey(key:"EnableLocatioFromSetting"))", preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"locationCityDontAllow"), style: .default, handler:nil))
        alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"Allow"), style: .default, handler: { (_) in
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
        }))
        self.navigationController?.present(alertController, animated:true, completion: nil)
    }
    //Present UberRide Invitation
    func presentUberRideInvitation(objExperience:Experience){
      
        let builder = RideParametersBuilder()
        let pickupLocation = CLLocation(latitude:Double.init("\(self.latitude)")!, longitude:Double.init("\(self.longitude)")!)
        let dropoffLocation = CLLocation(latitude:Double.init("\(objExperience.latitude)")!, longitude: Double.init("\(objExperience.longitude)")!)
        builder.pickupLocation = pickupLocation
        builder.dropoffLocation = dropoffLocation
        builder.dropoffNickname = "\(objExperience.title)"
        builder.dropoffAddress = "\(objExperience.address)"
        let rideParameters = builder.build()
        
        let button = RideRequestButton(rideParameters: rideParameters)

        let strMSG = Vocabulary.getWordFromKey(key:"bookUberRideMessage.hint")+" \"\(objExperience.title)\" ?"+"\n\n\n"
        
        let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"bookUberRide.hint"), message: Vocabulary.getWordFromKey(key:"bookUberRideMessage.hint")+" \"\(objExperience.title)\" ?", preferredStyle: .alert)
        
        
        let rect = CGRect(x: 1, y:strMSG.height(withConstrainedWidth: 270.0, font: UIFont(name: "Avenir-Roman", size: 15.5)!), width: 268.0, height: 60.0)
        //let customView = UIView(frame: rect)
        button.frame = rect
        button.addTarget(self, action: #selector(uberButtonTapped(_:)), for: .touchUpInside)
        alertController.view.addSubview(button)
        let titleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 20.0)!]
        let messageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 15.0)!]
        alertController.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler: nil))
        print(alertController.view.bounds)
        let titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key:"bookUberRide.hint"), attributes: titleFont)
        
        let messageAttrString = NSMutableAttributedString(string: strMSG, attributes: messageFont)
        
        alertController.setValue(titleAttrString, forKey: "attributedTitle")
        alertController.setValue(messageAttrString, forKey: "attributedMessage")
        alertController.view.tintColor = UIColor.init(hexString: "#36527D")
        self.present(alertController, animated: true, completion: nil)
    }
    @objc func uberButtonTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    //Present InviteUser
    func presentUserInvite(objExperience:Experience){
        if let userInvite = self.storyboard?.instantiateViewController(withIdentifier:"InvitationViewController") as? InvitationViewController{
            userInvite.modalPresentationStyle = .overFullScreen
            userInvite.objExperience  = objExperience
            userInvite.hidesBottomBarWhenPushed = true
            userInvite.invitationDelegate = self
            self.present(userInvite, animated: false, completion: nil)
        }
    }
    //PresentReview
    func  presentReviewController(objExperience: Experience){
        DispatchQueue.main.async {
            self.view.endEditing(true)
            if let _ = objExperience.userReview{
                let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"rateexperience.hint"), message: Vocabulary.getWordFromKey(key:"rateexperiencedetail.hint"), preferredStyle: .alert)
                alertController.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .cancel, handler: nil))
                let titleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17.0)!]
                let messageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
                let titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key:"rateexperience.hint"), attributes: titleFont)
                let messageAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key:"rateexperiencedetail.hint"), attributes: messageFont)
                
                alertController.setValue(titleAttrString, forKey: "attributedTitle")
                alertController.setValue(messageAttrString, forKey: "attributedMessage")
                alertController.view.tintColor = UIColor.init(hexString: "#36527D")
                self.present(alertController, animated: true, completion: nil)
            }else{
                if let reviewViewController = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController{
                    reviewViewController.modalPresentationStyle = .overFullScreen
                    reviewViewController.objExperience = objExperience
                    reviewViewController.hidesBottomBarWhenPushed = true
                    self.present(reviewViewController, animated: false, completion: nil)
                }

            }
        }
        
    }
}
extension MyLiveViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfRowSection.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let experienceCell:ExperienceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ExperienceTableViewCell", for: indexPath)
            as! ExperienceTableViewCell
        guard self.arrayOfRowSection.count > indexPath.row,self.arrayOfExperienceTitle.count > indexPath.row,self.arrayOfExperienceDiscription.count > indexPath.row else {
            return experienceCell
        }
        experienceCell.lblExperienceTitle.text = (self.currentUser!.userType == .guide) ? "\(self.arrayOfToursTitle[indexPath.row])":"\(self.arrayOfExperienceTitle[indexPath.row])"
        experienceCell.lblExperienceDiscription.text = self.getDiscriptionWithItemCountOnRow(row: indexPath.row)
        //(self.currentUser!.userType == .guide) ? "\(self.arrayOfToursDiscription[indexPath.row])":"\(self.arrayOfExperienceDiscription[indexPath.row])"
        if self.arrayOfRowSection.count > 1{ //traveler
            experienceCell.buttonExpandCollaps.tag = indexPath.row
            experienceCell.buttonExpandCollaps.isHidden = self.isExpandCollapsHidden(indexPath: indexPath)
            experienceCell.delegateTableViewCell = self
            experienceCell.collectionExperience.isHidden = self.expandCollapsSet.contains(indexPath.row)
            if self.expandCollapsSet.contains(indexPath.row){
                experienceCell.buttonExpandCollaps.setImage(UIImage.init(named: "expand_button"), for: .normal) //collaps_button
            }else{
                 experienceCell.buttonExpandCollaps.setImage(UIImage.init(named: "collaps_button"), for: .normal)
            }
            //experienceCell.rotedExpandSelector(isExpand: !self.expandCollapsSet.contains(indexPath.row))
        }else{
            experienceCell.collectionExperience.isHidden = false
            experienceCell.buttonExpandCollaps.isHidden = true
        }
        experienceCell.collectionExperience.tag = indexPath.row + 100//0 for pending experience, 1 for upcoming, 2 for wishlist experience, 3 for lived experience
        experienceCell.collectionExperience.delegate = self
        experienceCell.collectionExperience.dataSource = self
        experienceCell.selectionStyle = .none
        DispatchQueue.main.async {
            experienceCell.collectionExperience.reloadData()
        }
        experienceCell.collectionExperience.showsHorizontalScrollIndicator = false
        experienceCell.lblExperienceDiscription.isHidden = true
     
        return experienceCell
    }
    func getDiscriptionWithItemCountOnRow(row:Int)->String{
        if(self.currentUser!.userType == .guide){
            return "\(self.arrayOfTours.count) \(self.arrayOfToursDiscription[row])"
        }else{
            if row == 0{
                return "\(self.arrayOfUpcomingExperience.count) \(self.arrayOfExperienceDiscription[row])"
            }else if row == 1{
                return "\(self.arrayOfWishListExperience.count) \(self.arrayOfExperienceDiscription[row])"
            }else if row == 2{
                return "\(self.arrayOfLivedExperience.count) \(self.arrayOfExperienceDiscription[row])"
            }else{
                return ""
            }
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return User.isUserLoggedIn ? 130 : 0
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getTableviewRowHeight(indexPath: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return User.isUserLoggedIn ? self.getHeightOfFooter() : 0
    }
    func getHeightOfFooter()->CGFloat{
        if let _ = self.currentUser{
            if self.currentUser!.userType == .guide{
                self.buttonAddNewExperience.isHidden = false
                return 0.0
            }else{
                self.buttonAddNewExperience.isHidden = true
                return 0.0
            }
        }else{
            self.buttonAddNewExperience.isHidden = true
            return 0.0
        }
    }
    func getTableviewRowHeight(indexPath:IndexPath)->CGFloat{
        if self.currentUser!.userType == .guide{
            if indexPath.row == 0,self.arrayOfTours.count > 0{
                return tableviewExperienceRowHeight
            }else{
                return 150.0
            }
        }else{
            if self.expandCollapsSet.contains(indexPath.row){
                return 60.0
            }else{
                if indexPath.row == 0,self.arrayOfPendingExperience.count > 0{
                    return tableviewExperienceRowHeight
                }else if indexPath.row == 1,self.arrayOfUpcomingExperience.count > 0{
                    return tableviewExperienceRowHeight
                }else if indexPath.row == 2,self.arrayOfWishListExperience.count > 0{
                    return tableviewExperienceRowHeight
                }else if indexPath.row == 3,self.arrayOfLivedExperience.count > 0 {
                    return tableviewExperienceRowHeight + 20.0
                }else {
                    return 60.0
                }
            }
        }
    }
    func isExpandCollapsHidden(indexPath:IndexPath)->Bool{
        if indexPath.row == 0,self.arrayOfPendingExperience.count > 0{
            return false
        }else if indexPath.row == 1,self.arrayOfUpcomingExperience.count > 0{
            return false
        }else if indexPath.row == 2,self.arrayOfWishListExperience.count > 0{
            return false
        }else if indexPath.row == 3,self.arrayOfLivedExperience.count > 0 {
            return false
        }else {
            return true
        }
    }
}
extension MyLiveViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ExperienceDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.currentUser!.userType == .guide,collectionView.tag == 100{ //Guide tours
            if self.arrayOfTours.count > 0{
                collectionView.removeMessageLabel()
            }else{
                collectionView.showMessageLabel()
            }
            return self.arrayOfTours.count
        }else if collectionView.tag == 100{
            if self.arrayOfPendingExperience.count > 0 { //Pending
                collectionView.removeMessageLabel()
            }else{
                //collectionView.showMessageLabel()
            }
            return self.arrayOfPendingExperience.count
        }else if collectionView.tag == 101{
            if self.arrayOfUpcomingExperience.count > 0 { //Upcoming
                collectionView.removeMessageLabel()
            }else{
                //collectionView.showMessageLabel()
            }
            return self.arrayOfUpcomingExperience.count
        }else if collectionView.tag == 102{ //WishList
            if self.arrayOfWishListExperience.count > 0 {
                collectionView.removeMessageLabel()
            }else{
                //collectionView.showMessageLabel()
            }
            return self.arrayOfWishListExperience.count
        } else if collectionView.tag == 103 { //Lived Experiences
            if self.arrayOfLivedExperience.count > 0 {
                collectionView.removeMessageLabel()
            }else{
                //collectionView.showMessageLabel()
            }
            return self.arrayOfLivedExperience.count
        }
        else{
            collectionView.removeMessageLabel()
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let experienceCell:ExperienceCollectionViewCell =  collectionView.dequeueReusableCell(withReuseIdentifier: "ExperienceCollectionViewCell", for: indexPath) as! ExperienceCollectionViewCell//Upcoming //WishList //Lived Experiences
        
        experienceCell.mainContainerView.layer.borderColor = UIColor(hexString: "D9D9D9").cgColor
        experienceCell.mainContainerView.layer.borderWidth = 1.0
        var objectExperience:Experience?
        var objectPendingExperiences: PendingExperience?
        if self.currentUser!.userType == .guide,collectionView.tag == 100 { //tours
            experienceCell.instantImg.isHidden = true
            if self.arrayOfTours.count > indexPath.item{
                objectExperience = self.arrayOfTours[indexPath.item]
                experienceCell.buttonDelete.isHidden = false
                //                experienceCell.circularView.isHidden = false
                experienceCell.buttonCancel.isHidden = true
                experienceCell.buttonActive.isHidden = false
                experienceCell.avtiveInctiveContainerWidthConstant.constant = 90
                experienceCell.activeInActiveContainer.isHidden = false
                //experienceCell.activeInActiveContainer.isHidden = true
                experienceCell.buttonFav.isHidden = true
                experienceCell.buttonDelete.tag = indexPath.item
                experienceCell.payBtn.isHidden = true
                experienceCell.otherOptionBtn.isHidden = true
                experienceCell.payContainerView.isHidden = true
                experienceCell.buttonDelete.accessibilityValue = "\(collectionView.tag)"
                experienceCell.buttonActive.tag = indexPath.item
                experienceCell.buttonActive.accessibilityValue = "\(collectionView.tag)"
                experienceCell.buttonActiveInActive.tag = indexPath.item
                experienceCell.buttonActiveInActive.accessibilityValue = "\(collectionView.tag)"
                
                if indexPath.item == (self.arrayOfTours.count - 1) , self.isMyTourLoadMore{ //last index
                    DispatchQueue.global(qos: .background).async {
                        self.myTourPageIndex += 1
                        self.getGuideTours()
                    }
                }
            }
        }else if collectionView.tag == 100 { //Pending
            if self.arrayOfPendingExperience.count > indexPath.item{
                objectPendingExperiences = self.arrayOfPendingExperience[indexPath.item]
                experienceCell.buttonDelete.isHidden = true
                experienceCell.buttonCancel.isHidden = true
                experienceCell.avtiveInctiveContainerWidthConstant.constant = 110
                experienceCell.buttonActive.isHidden = false
                experienceCell.payContainerView.isHidden = false
                experienceCell.otherOptionBtn.isHidden = false
                experienceCell.buttonFav.isHidden = true
                experienceCell.lblPendingExperienceDate.isHidden = false
                if let price:String = objectPendingExperiences?.price {
                    experienceCell.lblExperienceCurrency.text = "\(objectPendingExperiences!.currency)" +  " " + "\(price)"
                }
                if (objectPendingExperiences?.isGroupBooking)! {
                    if objectPendingExperiences!.ishourly{
                        experienceCell.lblMinimumPrice.text = "(Offered price per group hourly)"
                    }else{
                        experienceCell.lblMinimumPrice.text = "(Offered price per group)"
                    }
                } else {
                    if objectPendingExperiences!.ishourly{
                        experienceCell.lblMinimumPrice.text = "(Offered price per person hourly)"
                    }else{
                        experienceCell.lblMinimumPrice.text = "(Offered price per person)"

                    }
                }
                experienceCell.payBtn.addTarget(self, action: #selector(payBtnPressed), for: .touchUpInside)
                experienceCell.payBtn.tag = indexPath.item
                let date = changeDateFormat(dateStr: "\(arrayOfPendingExperience[indexPath.item].date)")
                experienceCell.lblPendingExperienceDate.text = "Offered date: " + "\(date)"
                experienceCell.lblPendingExperienceTime.text = "Offered time: " + "\(arrayOfPendingExperience[indexPath.item].time)".converTo12hoursFormate()
                
                
                if objectPendingExperiences?.status == "\(PendingBookingStatus.pending)" {
                    experienceCell.buttonActive.backgroundColor = UIColor.red
                    experienceCell.lblActiveInactive.text = Vocabulary.getWordFromKey(key:"Pending")
                    experienceCell.payBtnBorderView.isHidden = true
                    experienceCell.payBtn.isHidden = true
                }else if objectPendingExperiences?.status == "\(PendingBookingStatus.RequestedByTraveler)" {
                    experienceCell.buttonActive.backgroundColor = UIColor.red
                    experienceCell.lblActiveInactive.text = Vocabulary.getWordFromKey(key:"requested.hint")
                    experienceCell.payBtnBorderView.isHidden = true
                    experienceCell.payBtn.isHidden = true
                }
                else if objectPendingExperiences?.status == "\(PendingBookingStatus.RequestedByGuide)" {
                    experienceCell.buttonActive.backgroundColor = UIColor.init(hexString: "#36527D")
                    experienceCell.lblActiveInactive.text = Vocabulary.getWordFromKey(key:"MyLive.Byguide")
                    experienceCell.payBtnBorderView.isHidden = true
                    experienceCell.payBtn.isHidden = true
                }else if objectPendingExperiences?.status == "\(PendingBookingStatus.Accepted)" {
                    experienceCell.buttonActive.backgroundColor = UIColor.init(hexString:"#4CD964")
                    experienceCell.lblActiveInactive.text = Vocabulary.getWordFromKey(key:"MyLive.Accepted")
                    experienceCell.payBtnBorderView.isHidden = false
                    experienceCell.payBtn.isHidden = false
                } else if objectPendingExperiences?.status == "\(PendingBookingStatus.Confirmed)" {
                    experienceCell.buttonActive.backgroundColor = UIColor.init(hexString: "#4CD964")
                    experienceCell.lblActiveInactive.text = Vocabulary.getWordFromKey(key:"MyLive.Confirmed")
                    experienceCell.payBtnBorderView.isHidden = true
                    experienceCell.payBtn.isHidden = true
                    
                } else if objectPendingExperiences?.status == "\(PendingBookingStatus.Canceled)" {
                    experienceCell.buttonActive.backgroundColor = UIColor.init(hexString: "#36527D")
                    experienceCell.lblActiveInactive.text = Vocabulary.getWordFromKey(key:"MyLive.Cancelled")
                    experienceCell.payBtnBorderView.isHidden = true
                    experienceCell.payBtn.isHidden = true
                }
                else {
                    experienceCell.payBtn.isHidden = true
                }
                if (objectPendingExperiences?.isInstantBooking)! {
                    experienceCell.instantImg.isHidden = false
                } else {
                    experienceCell.instantImg.isHidden = true
                }
//                experienceCell.otherOptionBtn.addTarget(self, action: #selector(showOtherOptionsForTravelerPendigBookingExperiences), for: .touchUpInside)
                experienceCell.activeInActiveContainer.isHidden = false
                experienceCell.lblPendingExperienceTime.isHidden = false
                experienceCell.otherOptionBtn.tag = indexPath.item
                experienceCell.otherOptionBtn.accessibilityValue = "\(collectionView.tag)"
                
            }
        }else if collectionView.tag == 101 { //Upcoming
            experienceCell.instantImg.isHidden = true
            if self.arrayOfUpcomingExperience.count > indexPath.item{
                objectExperience = self.arrayOfUpcomingExperience[indexPath.item]
                experienceCell.buttonDelete.isHidden = true
              
                //                experienceCell.circularView.isHidden = true
                experienceCell.buttonCancel.isHidden = false
                experienceCell.buttonActive.isHidden = true
                experienceCell.activeInActiveContainer.isHidden = true
                experienceCell.payContainerView.isHidden = true
                experienceCell.payBtn.isHidden = true
                experienceCell.buttonFav.isHidden = true
                experienceCell.otherOptionBtn.isHidden = true
                experienceCell.payBtnBorderView.isHidden = true
                experienceCell.activeInActiveContainer.isHidden = true
                experienceCell.buttonCancel.tag = indexPath.item
                experienceCell.buttonUberRide.tag = indexPath.item
                experienceCell.buttonCancel.accessibilityValue = "\(collectionView.tag)"
                if indexPath.item == (self.arrayOfUpcomingExperience.count - 1) , self.isUpcomingLoadMore{ //last index
                    DispatchQueue.global(qos: .background).async {
                        self.upcomingPageIndex += 1
                        self.getUpcomingExperiences()
                    }
                }
            }
        }else if collectionView.tag == 102{ //WishList
            experienceCell.instantImg.isHidden = true
            if self.arrayOfWishListExperience.count > indexPath.item{
                objectExperience = self.arrayOfWishListExperience[indexPath.item]
                experienceCell.buttonDelete.isHidden = true
                experienceCell.buttonFav.isHidden = false
                experienceCell.buttonCancel.isHidden = true
                experienceCell.buttonActive.isHidden = true
                experienceCell.otherOptionBtn.isHidden = true
                experienceCell.activeInActiveContainer.isHidden = true
                experienceCell.payBtn.isHidden = true
                experienceCell.payBtnBorderView.isHidden = true
                experienceCell.payContainerView.isHidden = true
                experienceCell.activeInActiveContainer.isHidden = true
                experienceCell.buttonFav.tag = indexPath.item
                experienceCell.buttonFav.accessibilityValue = "\(indexPath.item)"
                if indexPath.item == (self.arrayOfWishListExperience.count - 1) , self.isWishListLoadMore{ //last index
                    DispatchQueue.global(qos: .background).async {
                        self.wishListPageIndex += 1
                        self.getWishListExperiences()
                    }
                }
            }
        }else if collectionView.tag == 103 { //Lived
            experienceCell.instantImg.isHidden = true
            if self.arrayOfLivedExperience.count > indexPath.item{
                objectExperience = self.arrayOfLivedExperience[indexPath.item]
                experienceCell.buttonDelete.isHidden = true
                experienceCell.buttonFav.isHidden = true
                
                //                experienceCell.circularView.isHidden = true
                experienceCell.buttonCancel.isHidden = true
                experienceCell.activeInActiveContainer.isHidden = true
                experienceCell.buttonActive.isHidden = true
                experienceCell.payBtn.isHidden = true
                experienceCell.otherOptionBtn.isHidden = true
                experienceCell.payContainerView.isHidden = true
                experienceCell.payBtnBorderView.isHidden = true
                experienceCell.activeInActiveContainer.isHidden = true
                if indexPath.item == (self.arrayOfLivedExperience.count - 1) , self.isLivedLoadMore{ //last index
                    DispatchQueue.global(qos: .background).async {
                        self.livedPageIndex += 1
                        self.getLivedExperiences()
                    }
                }
            }
        }else{
            experienceCell.buttonFav.isHidden = true
            experienceCell.payBtn.isHidden = true
            experienceCell.payBtnBorderView.isHidden = true
            experienceCell.payContainerView.isHidden = true
        }
        DispatchQueue.main.async {
            
            if let _ = objectPendingExperiences{
                experienceCell.lblExperienceDisc.text = "\(objectPendingExperiences!.title)"
//                experienceCell.lblExperienceCurrency.text = "\(objectPendingExperiences!.currency) \(self.isPricePerPerson(objectPendingExperiences: objectPendingExperiences!) ? objectPendingExperiences!.priceperson : objectPendingExperiences!.groupPrice)"
                if objectPendingExperiences!.image.count > 0{
                    experienceCell.loadImage(url: objectPendingExperiences!.image)
                    //experienceCell.imgExperience.imageFromServerURL(urlString:objectPendingExperiences!.image)
                }else{
                    experienceCell.imgExperience.image = UIImage.init(named:"expriencePlaceholder")
                }
//                if objectPendingExperiences!.isBlock {
//                    experienceCell.lblActiveInactive.text = Vocabulary.getWordFromKey(key:"InActive")
//                    experienceCell.buttonActive.backgroundColor = UIColor.red
//                }else{
//                    experienceCell.lblActiveInactive.text = Vocabulary.getWordFromKey(key:"Active")
//                    experienceCell.buttonActive.backgroundColor = UIColor.init(hexString:"#4CD964")
//                }
                if let _ = objectPendingExperiences?.averageReview {
                    let str = (objectPendingExperiences!.averageReview)
                    if str != "" {
                        experienceCell.ratingView.rating = Double(str)!
                    }
                }
//                experienceCell.lblMinimumPrice.text = self.getMinimumPriceHint(objExperience: objectPendingExperiences!)
                
            }
            
            if let _ = objectExperience{
                experienceCell.lblExperienceDisc.text = "\(objectExperience!.title)"
                experienceCell.lblExperienceCurrency.text = "\(objectExperience!.currency) \(self.isPricePerPerson(objExperience: objectExperience!) ? objectExperience!.priceperson : objectExperience!.groupPrice)"
                //                let filteredArray:[Images] = objectExperience.images.filter() { $0.mainImage == true}
                //                if let _ = filteredArray.first{
                if objectExperience!.mainImage.count > 0{
                    experienceCell.loadImage(url: objectExperience!.smallmainImage)
                    //experienceCell.imgExperience.imageFromServerURL(urlString:objectExperience!.mainImage)
                }else{
                    experienceCell.imgExperience.image = UIImage.init(named:"expriencePlaceholder")
                }
                if objectExperience!.isBlock {
                    experienceCell.lblActiveInactive.text = Vocabulary.getWordFromKey(key:"InActive")
                    //                    experienceCell.lblActiveInactive.textColor = UIColor.red
                    experienceCell.buttonActive.backgroundColor = UIColor.red
                }else{
                    experienceCell.lblActiveInactive.text = Vocabulary.getWordFromKey(key:"Active")
                    experienceCell.buttonActive.backgroundColor = UIColor.init(hexString:"#4CD964")
                }
                
                //                }
                experienceCell.ratingView.rating = Double(objectExperience!.averageReview)!
                if collectionView.tag == 101{ //upcoming
                    if (objectExperience!.isGroupPrice) {
                        if objectExperience!.ishourly {
                            experienceCell.lblMinimumPrice.text = "(Paid price per group hourly)"
                        }else{
                            experienceCell.lblMinimumPrice.text = "(Paid price per group)"
                        }
                    } else {
                        if objectExperience!.ishourly{
                            experienceCell.lblMinimumPrice.text = "(Paid price per person hourly)"
                        }else{
                            experienceCell.lblMinimumPrice.text = "(Paid price per person)"
                        }
                    }
                    let date = self.changeDateFormat(dateStr: "\(objectExperience!.experienceBookingDate)")
                    experienceCell.payContainerView.isHidden = false
                    experienceCell.lblPendingExperienceDate.isHidden = false
                    experienceCell.lblPendingExperienceTime.isHidden = false
                    experienceCell.lblPendingExperienceDate.text = "Date: " + "\(date) "+"\(objectExperience!.time)".converTo12hoursFormate()
                    experienceCell.lblPendingExperienceTime.text = "Guide Name: " + "\(objectExperience!.guideName)"
                    experienceCell.btnUserInvite.tag = indexPath.row
                    if objectExperience!.isInvited{
                        experienceCell.buttonInvited.isHidden = false
                        experienceCell.buttonCancel.isHidden = true
                        experienceCell.btnUserInvite.isHidden = true
                        experienceCell.buttonUberRideTop.constant = 15.0
                    }else{
                        experienceCell.buttonUberRideTop.constant = 65.0
                        experienceCell.buttonInvited.isHidden = true
                        experienceCell.buttonCancel.isHidden = false
                        experienceCell.btnUserInvite.isHidden = false
                    }
                    if let price:String = objectExperience?.topExperiencePrice {
                        experienceCell.lblExperienceCurrency.text = "\(objectExperience!.currency)" +  " " + "\(price)"
                    }
                    experienceCell.buttonUberRide.isHidden = false
                }else{
                    experienceCell.buttonUberRide.isHidden = true
                    experienceCell.buttonInvited.isHidden = true
                    experienceCell.btnUserInvite.tag = indexPath.row
                    experienceCell.btnUserInvite.isHidden = true
                    experienceCell.payContainerView.isHidden = true
                    experienceCell.lblPendingExperienceDate.isHidden = true
                    experienceCell.lblPendingExperienceTime.isHidden = true
                    experienceCell.lblMinimumPrice.text = self.getMinimumPriceHint(objExperience: objectExperience!)
                }
                
                
            }
    
        }
        experienceCell.delegate = self
        if collectionView.tag == 103{ //lived
            if let _ = objectExperience,let userReview = objectExperience!.userReview{
                experienceCell.lblUserRating.text = "\(userReview)"
                experienceCell.userReviewView.isHidden = false
                experienceCell.shadowViewRating.isHidden = false
            }else{
                experienceCell.userReviewView.isHidden = true
                experienceCell.shadowViewRating.isHidden = true
            }
            
        }else{
            experienceCell.userReviewView.isHidden = true
            experienceCell.shadowViewRating.isHidden = true
        }
        return experienceCell
    }
    func getMinimumPriceHint(objExperience:Experience)->String{
        if self.isPricePerPerson(objExperience: objExperience){
            return "(\(Vocabulary.getWordFromKey(key: "priceperperson")))"
        }else{
            return  "(\(Vocabulary.getWordFromKey(key: "pricepergroup")))"
        }
    }
    func isPricePerPerson(objExperience:Experience)->Bool{
        guard objExperience.priceperson.count > 0 else {
            return false//"(\(Vocabulary.getWordFromKey(key: "pricepergroup")))" //group
        }
        guard objExperience.groupPrice.count > 0 else {
            return true//"(\(Vocabulary.getWordFromKey(key: "priceperperson")))" //person
        }
        if Int(objExperience.groupPrice) ?? 0 > Int(objExperience.priceperson) ?? 0{
            return false//true//"(\(Vocabulary.getWordFromKey(key: "priceperperson")))" //person
        }else{
            return true//false//"(\(Vocabulary.getWordFromKey(key: "pricepergroup")))"
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize.init(width: 260.0, height: 300)
    }
    func getCenterCellForOneRecord()->CGFloat{
        return (UIScreen.main.bounds.width - 260.0)/2.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        if self.currentUser!.userType == .guide,collectionView.tag == 100 { //tours
            if self.arrayOfTours.count == 1{
                 return UIEdgeInsetsMake(0, self.getCenterCellForOneRecord(), 0, 0)
            }else{
                return UIEdgeInsetsMake(0, 20.0, 0, 0)
            }
        }else if collectionView.tag == 100 { //Pending
            if self.arrayOfPendingExperience.count == 1{
                  return UIEdgeInsetsMake(0, self.getCenterCellForOneRecord(), 0, 0)
            }else{
                 return UIEdgeInsetsMake(0, 20.0, 0, 0)
            }
        }else if collectionView.tag == 101 { ////Upcoming
            if self.arrayOfUpcomingExperience.count == 1{
                 return UIEdgeInsetsMake(0, self.getCenterCellForOneRecord(), 0, 0)
            }else{
                 return UIEdgeInsetsMake(0, 20.0, 0, 0)
            }
        }else if collectionView.tag == 102{ //WishList
            if self.arrayOfWishListExperience.count == 1{
                 return UIEdgeInsetsMake(0, self.getCenterCellForOneRecord(), 0, 0)
            }else{
                 return UIEdgeInsetsMake(0, 20.0, 0, 0)
            }
        }else if collectionView.tag == 103 { //Lived
            if self.arrayOfLivedExperience.count == 1{
                 return UIEdgeInsetsMake(0, self.getCenterCellForOneRecord(), 0, 0)
            }else{
                return UIEdgeInsetsMake(0, 20.0, 0, 0)
            }
        }else{
            return UIEdgeInsetsMake(0, 20.0, 0, 0)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 15.0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("DidSelect \(collectionView.tag) \(indexPath.item)")
        
        if self.currentUser!.userType == .guide,collectionView.tag == 100 {   //Tours
            guard self.arrayOfTours.count > indexPath.item else{
                return
            }
            let objExperience = self.arrayOfTours[indexPath.item]
            self.pushToEditExperienceViewController(objExperience: objExperience)
        }
        else if collectionView.tag == 101 { //Upcoming
            guard self.arrayOfUpcomingExperience.count > indexPath.item else{
                return
            }
            let objExperience = self.arrayOfUpcomingExperience[indexPath.item]
            self.presentReviewController(objExperience: objExperience)
            //self.pushToBookDetailController(objExperience: objExperience)
        } else if collectionView.tag == 102 { //WishList
            guard self.arrayOfWishListExperience.count > indexPath.item else{
                return
            }
            let objExperience = self.arrayOfWishListExperience[indexPath.item]
            self.pushToBookDetailController(objExperience: objExperience)
        } else if collectionView.tag == 103{ //Lived
            guard self.arrayOfLivedExperience.count > indexPath.item else{
                return
            }
            //Disable Lived Experience
            let objExperience = self.arrayOfLivedExperience[indexPath.item]
            
            self.presentReviewController(objExperience: objExperience)
            
        }
        
        
    }
    func didSelectFavSelector(sender: UIButton) {
        if let currentUser = User.getUserFromUserDefault(),self.arrayOfWishListExperience.count > 0{
            let objExperience = self.arrayOfWishListExperience[sender.tag]
            self.favouriteFunctionality(userID: "\(currentUser.userID)", isFavourite: "true", experienceId:"\(objExperience.id)")
        }
    }
    func didSelectDeleteSelector(sender: UIButton) {
        if let accessibility  = sender.accessibilityValue as NSString?{
            if self.currentUser!.userType == .guide,accessibility.intValue == 100{ //tours
                if self.arrayOfTours.count > sender.tag{
                    let alertController = UIAlertController.init(title: "", message: "", preferredStyle: .alert)
                    alertController.view.layer.cornerRadius = 14.0
                    let titleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17.0)!]
                    let messageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
                    let strDeleteExperience = "\(Vocabulary.getWordFromKey(key:"delete")) \(Vocabulary.getWordFromKey(key:"Experience.title"))"
                    let titleAttrString = NSMutableAttributedString(string: strDeleteExperience, attributes: titleFont)
                    let messageAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key:"deleteExperenice"), attributes: messageFont)
                    
                    alertController.setValue(titleAttrString, forKey: "attributedTitle")
                    alertController.setValue(messageAttrString, forKey: "attributedMessage")
                    
                    alertController.view.tintColor = UIColor(hexString: "#36527D")
                    alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (_) in
                        let objExperience = self.arrayOfTours[sender.tag]
                        self.deleteExperience(experienceID: objExperience.id,index:sender.tag,locationID:objExperience.locationId)
                    }))
                    alertController.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            }else{
                
            }
        }
    }
    func didActiveInActiveSelector(sender: UIButton) {
        if let accessibility  = sender.accessibilityValue as NSString?{
            if self.currentUser!.userType == .guide,accessibility.intValue == 100{ //tours
                if self.arrayOfTours.count > sender.tag{
                    let objExperience = self.arrayOfTours[sender.tag]
                    let msgActive = "\(Vocabulary.getWordFromKey(key:"Activate")) \(Vocabulary.getWordFromKey(key:"Experience.title"))"
                    let msgDeactive = "\(Vocabulary.getWordFromKey(key:"Deactivate")) \(Vocabulary.getWordFromKey(key:"Experience.title"))"
                    let strTitle = objExperience.isBlock ? msgActive : msgDeactive
                    let strMessage = objExperience.isBlock ? "\(Vocabulary.getWordFromKey(key:"Activate.msg1")) " + "\"" + "\(objExperience.title)" + "\"" + "? " + "\(Vocabulary.getWordFromKey(key:"Activate.msg2"))": "\(Vocabulary.getWordFromKey(key:"DeActivate.msg1")) " + "\"" + "\(objExperience.title)" + "\"" + "? " + "\(Vocabulary.getWordFromKey(key:"DeActivate.msg2"))"
                    
                    let alertController = UIAlertController.init(title: "\(strTitle)", message: "\(strMessage)", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:Vocabulary.getWordFromKey(key:"yes")), style: .default, handler: { (_) in
                        self.activeInActiveExperience(objExperience: objExperience)
                    }))
                    let noTitle =  objExperience.isBlock ? Vocabulary.getWordFromKey(key:"No") : Vocabulary.getWordFromKey(key:"No")
                    alertController.addAction(UIAlertAction.init(title: noTitle, style: .cancel, handler: nil))
                    let titleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 19.0)!]
                    let messageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
                    let titleAttrString = NSMutableAttributedString(string: "\(strTitle)", attributes: titleFont)
                    let messageAttrString = NSMutableAttributedString(string: "\(strMessage)", attributes: messageFont)
                    
                    alertController.setValue(titleAttrString, forKey: "attributedTitle")
                    alertController.setValue(messageAttrString, forKey: "attributedMessage")
                    
                    alertController.view.tintColor = UIColor(hexString: "#36527D")
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            }else{
                
            }
        }
    }
    func didSelectCancelSelector(sender: UIButton) {
        if let accessibility  = sender.accessibilityValue as NSString?{
            if self.currentUser!.userType == .traveller,accessibility.intValue == 101{ //upcoming
                if self.arrayOfUpcomingExperience.count > sender.tag{
                    let objExperience = self.arrayOfUpcomingExperience[sender.tag]
                    objExperience.accessibilityValue = "\(sender.tag)"
                    self.is_PendingExper = false
                    self.cancelUpcomingExperience(experience: objExperience)
                    
                    /*
                     let alertController = UIAlertController.init(title:"Cancel", message: "Are you sure you want to cancel experience?", preferredStyle: .alert)
                     alertController.addAction(UIAlertAction.init(title:"Yes", style: .default, handler: { (_) in
                     }))
                     alertController.addAction(UIAlertAction.init(title: "No", style: .cancel, handler: nil))
                     self.present(alertController, animated: true, completion: nil)
                     */
                }
            }else{
                
            }
        }
    }
    func didSelectUserInvite(sender: UIButton) {
        
        if self.arrayOfUpcomingExperience.count > sender.tag{
            let upcomingExperience = self.arrayOfUpcomingExperience[sender.tag]
            self.presentUserInvite(objExperience: upcomingExperience)
        }
    }
    func didSelectUberRideSelector(sender: UIButton) {
        if self.arrayOfUpcomingExperience.count > sender.tag{
            let upcomingExperience = self.arrayOfUpcomingExperience[sender.tag]
            self.checkLocationPermission(objExperience: upcomingExperience)
            //self.presentUberRideInvitation(objExperience: upcomingExperience)
        }
    }
    func didSelectMoreOption(sender:UIButton){
        if self.arrayOfPendingExperience.count > sender.tag,self.arrayOfPendingSchedule.count > sender.tag{
            let objPendingExp:PendingExperience = self.arrayOfPendingExperience[sender.tag]
            objPendingExp.accessibilityValue = "\(sender.tag)"
            let objSchedule:Schedule = self.arrayOfPendingSchedule[sender.tag]
            self.showOtherOptionsForTravelerPendigBookingExperiences(objPendingExp: objPendingExp,objSchedule:objSchedule)
        }
    }
    
    @objc func showOtherOptionsForTravelerPendigBookingExperiences(objPendingExp:PendingExperience,objSchedule:Schedule){ // Show other option for traveller pending experience
        
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let directreply = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"MyLive.Chat") , style: .default) { (_) in//Vocabulary.getWordFromKey(key:"Photos")
            if let objDirectReply = self.storyboard?.instantiateViewController(withIdentifier: "DirectReplyViewController") as? DirectReplyViewController{
                objDirectReply.objPendingExp = objPendingExp
                objDirectReply.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(objDirectReply, animated: true)
            }
        }
        actionSheet.addAction(directreply)
        
        let offer =  UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"SuggestAnotherDay.hint") , style: .default) { (_) in
            if let offerViewController = self.storyboard?.instantiateViewController(withIdentifier: "OfferDayViewController") as? OfferDayViewController{
                offerViewController.modalPresentationStyle = .overFullScreen
                offerViewController.objSchedule = objSchedule
                offerViewController.isForTraveler = true
                offerViewController.isForInstantExperience = objSchedule.isInstantBooking
                self.present(offerViewController, animated: false, completion: nil)
            }
        }
        actionSheet.addAction(offer)
        
        let cancel = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"MyLive.CancelExperiences") , style: .default) { (_) in
            let tempExp: [String : Any] = [:]
            let objExprience = Experience(experienceDetail: tempExp)
            objExprience.bookingID = objPendingExp.id
            objExprience.title = objPendingExp.title
            objExprience.guideID = objPendingExp.guideID
            objExprience.userName = objPendingExp.userName
            objExprience.userID = objPendingExp.userID
            objExprience.accessibilityValue = objPendingExp.accessibilityValue
            self.is_PendingExper = true
            self.cancelUpcomingExperience(experience: objExprience)
        }
        actionSheet.addAction(cancel)
        
        let close = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"close.hint"), style: .cancel)
        actionSheet.addAction(close)
        
        actionSheet.view.tintColor = UIColor.init(hexString: "36527D")
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func pushToBookDetailController(objExperience:Experience){
        let storyboard = UIStoryboard(name: "BooknowDetailSB", bundle: nil)
        if let bookDetailcontroller = storyboard.instantiateViewController(withIdentifier: "BookDetailViewController") as? BookDetailViewController {
            bookDetailcontroller.bookDetailArr = objExperience
            bookDetailcontroller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(bookDetailcontroller, animated: true)
        }
    }
}
extension MyLiveViewController:ExperienceTableViewCellDelegate{
    func expandCollapsSelector(index: Int) {
        if let objIndexPath:IndexPath = IndexPath.init(row: index, section: 0),
            let cell = self.tableViewMyLive.cellForRow(at: objIndexPath) as? ExperienceTableViewCell{
                if self.expandCollapsSet.contains(index){
                    self.expandCollapsSet.remove(index)
                    //cell.rotedExpandSelector(isExpand: false)
                }else{
                    self.expandCollapsSet.add(index)
                    //cell.rotedExpandSelector(isExpand: true)
                }
            }
                self.tableViewMyLive.reloadSections(IndexSet(integersIn: 0...0), with: .automatic)
        
    }
}
extension MyLiveViewController:InvitationDelegate{
    func dismissInvitationController(){
        DispatchQueue.main.async {
            self.dismiss(animated: false, completion: nil)
        }
    }
    func invitationSentSuccessfully(email: String) {
        DispatchQueue.main.async {
            self.dismiss(animated: false, completion: nil)
            let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"invitationSentTitle"), message: Vocabulary.getWordFromKey(key:"invitationSentMSG")+" \(email).", preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (_) in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            alertController.view.tintColor = UIColor.init(hexString:"36527d")
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
}
extension MyLiveViewController:CLLocationManagerDelegate{
    // MARK: - CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        print("user latitude = \(userLocation.coordinate.latitude)")
        self.latitude = "\(userLocation.coordinate.latitude)"
        print("user longitude = \(userLocation.coordinate.longitude)")
        self.longitude = "\(userLocation.coordinate.longitude)"
        manager.stopUpdatingLocation()
        manager.delegate = nil
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error.localizedDescription)")
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
