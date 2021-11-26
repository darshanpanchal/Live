    //
    //  MenuViewController.swift
    //  Live
    //
    //  Created by ips on 11/04/18.
    //  Copyright © 2018 ITPATH. All rights reserved.
    //
    
    import UIKit
    import ZendeskSDK
    import ZendeskCoreSDK
    import IQKeyboardManagerSwift
    
    class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource ,UIGestureRecognizerDelegate{
        @IBOutlet weak var lblNavTitle: UILabel!
        @IBOutlet weak var menuTableView: UITableView!
        @IBOutlet weak var objSegmentController: UISegmentedControl!
        @IBOutlet var imgProfile:ImageViewForURL!
        var imageForCrop: UIImage!
        @IBOutlet var editImageIcon:UIImageView!
        @IBOutlet var lblUserName:UILabel!
        @IBOutlet var lblUserCityName:UILabel!
        @IBOutlet var anonymousName:UILabel!
        var menuArrForTraveller: [String] = []
        var menuArrForLogOut: [String] = []
        @IBOutlet var buttonUserProfile:UIButton!
        var menuArrForGuide: [String] = []
        var menuArr = [String]()
        var guide:Bool = false
        var login: Bool = false
        var currentUser:User?
        let objectImagePicker:UIImagePickerController = UIImagePickerController()
        var isLogin:Bool{
            get{
                return login
            }
            set {
                self.login = newValue
                self.configureTable()
            }
            
        }
        var tableViewRowHeight:CGFloat{
            get{
                return 88.0
            }
        }
        var isGuide:Bool{
            get{
                return guide
            }
            set{
                self.guide = newValue
                self.configureTable()
            }
        }
        var indexOfSettings:Int{
            if isLogin {
                return 2
            } else {
                return -1
            }
        }
        var indexOfAboutUS:Int{
            if isLogin {
                return 6
            } else {
                return 3
            }
        }
        var indexOfLogOut:Int{
            if isLogin {
                return 6+1
            } else {
                return 3+1
            }
        }
        var indexOfTermsConditions:Int{
            if isLogin {
                return 3
            } else {
                return 0
            }
        }
        var indexOfBecomeGuide:Int{
            if isLogin {
                return 1
            } else {
                return -1
            }
        }
        var indexOfMySchedule:Int{
            if isLogin {
                return  0
            } else {
                return -1
            }
        }
        var indexOfMyTours:Int{
            if isLogin {
                return  1
            } else {
                return -1
            }
        }
        //    var indexOfRequestLocation:Int{
        //        if isLogin {
        //            return 3
        //        } else {
        //            return -1
        //        }
        //    }
        var indexOfUpcomingExperience:Int{
            if isLogin {
                return 0
            } else {
                return -1
            }
        }
        var indexOfContactUs:Int{
            if isLogin {
                return 5
            } else {
                return 2
            }
        }
        var indexOfChangeLanguage:Int{
            if isLogin {
                return 4
            } else {
                return 1
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            //self.menuTableView.contentInset = UIEdgeInsets.zero
            self.objectImagePicker.delegate = self
            self.objectImagePicker.allowsEditing = false
            // Do any additional setup after loading the view.
        }
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
        }
        func configureTable() {
            //aboutus.hint
            self.menuArrForGuide = ["\(Vocabulary.getWordFromKey(key:"MySchedule"))","\(Vocabulary.getWordFromKey(key:"MyTours"))","\(Vocabulary.getWordFromKey(key:"Settings"))", "\(Vocabulary.getWordFromKey(key:"TermsandConditions"))","\(Vocabulary.getWordFromKey(key:"Change Language"))", "\(Vocabulary.getWordFromKey(key:"ContactUs"))","\(Vocabulary.getWordFromKey(key:"aboutus.hint"))","\(Vocabulary.getWordFromKey(key:"Logout"))"] // For Guide //"\(Vocabulary.getWordFromKey(key:"RequestLocation"))"
            self.menuArrForTraveller = ["\(Vocabulary.getWordFromKey(key:"UpcomingExperience"))", "\(Vocabulary.getWordFromKey(key:"BecomeGuide"))", "\(Vocabulary.getWordFromKey(key:"Settings"))", "\(Vocabulary.getWordFromKey(key:"TermsandConditions"))","\(Vocabulary.getWordFromKey(key:"Change Language"))", "\(Vocabulary.getWordFromKey(key:"ContactUs"))","\(Vocabulary.getWordFromKey(key:"aboutus.hint"))","\(Vocabulary.getWordFromKey(key:"Logout"))"] // For Traveller
            self.menuArrForLogOut = ["\(Vocabulary.getWordFromKey(key:"TermsandConditions"))", "\(Vocabulary.getWordFromKey(key:"Change Language"))","\(Vocabulary.getWordFromKey(key:"ContactUs"))","\(Vocabulary.getWordFromKey(key:"aboutus.hint"))","\(Vocabulary.getWordFromKey(key:"title.signIn"))"] // For Anonymous
            if User.isUserLoggedIn {
                if self.currentUser!.userType == .guide{
                    self.menuArr = self.menuArrForGuide
                } else if self.currentUser!.userType == .traveller{
                    self.menuArr = self.menuArrForTraveller
                }
            } else {
                self.menuArr = self.menuArrForLogOut
            }
            DispatchQueue.main.async {
                self.menuTableView.reloadData()
            }
            self.menuTableView.delegate = self
            self.menuTableView.dataSource = self
            
        }
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            self.tabBarController?.navigationController?.setNavigationBarHidden(true, animated: false)
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
        
        func openEditor(_ sender: UIBarButtonItem?, pickingViewTag: Int) {
            guard let image = self.imageForCrop else {
                return
            }
            // Use view controller
            let controller = CropViewController()
            controller.delegate = self
            controller.image = image
            if pickingViewTag == 1 { // Profile
                controller.isBadge = false
                kUserDefault.set(false, forKey: "isBadge")
            } else { // Badge
                controller.isBadge = true
                kUserDefault.set(true, forKey: "isBadge")
            }
            let navController = UINavigationController(rootViewController: controller)
            present(navController, animated: false, completion: nil)
        }
//        override func viewDidAppear(_ animated: Bool) {
//            super.viewDidAppear(animated)
//            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
//            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
//
//        }
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            return false
        }
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.navigationController?.view.backgroundColor = UIColor.white

            self.getUsertype()
            DispatchQueue.main.async {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                //self.navigationController?.navigationBar.prefersLargeTitles = true
                self.navigationController?.navigationBar.topItem?.title = Vocabulary.getWordFromKey(key: "More")
                //self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
                let attributes = [
                    NSAttributedStringKey.foregroundColor : UIColor.black, NSAttributedStringKey.font : UIFont(name: "Avenir-Black", size: 34.0)
                ]
                //self.navigationController?.navigationBar.largeTitleTextAttributes = attributes
            }
            //self.menuTableView.register(MenuNameTableViewCell.self, forCellReuseIdentifier: "MenuNameTableViewCell")
            
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            
            //self.lblNavTitle.text = Vocabulary.getWordFromKey(key: "More")
            //self.navigationController?.navigationBar.isHidden = false
            UIApplication.shared.statusBarStyle = .default
            if !User.isUserLoggedIn {
                self.isLogin = false
                self.editImageIcon.isHidden = true
            } else {
                self.editImageIcon.isHidden = false
                self.login = true
                self.guide = true
                self.currentUser = User.getUserFromUserDefault()
                if self.currentUser!.userType == .guide{
                    self.isGuide = true // guide
                }else if self.currentUser!.userType == .traveller{
                    self.isGuide = false // traveller
                }
            }
            DispatchQueue.main.async {
                self.menuTableView.reloadData()
            }
            DispatchQueue.main.async {
                self.addDynamicFont()
                IQKeyboardManager.shared.enable = true
                IQKeyboardManager.shared.enableAutoToolbar = true

            }
            imgProfile.contentMode = .scaleAspectFill
            imgProfile.clipsToBounds = true
            DispatchQueue.main.async {
                if let imgURL = self.currentUser?.userImageURL,imgURL.count > 0{
                    self.imgProfile.imageFromServerURL(urlString:self.currentUser!.userImageURL,placeHolder:UIImage.init(named:"updatedProfilePlaceholder")!)
                }else{
                    self.imgProfile.image = UIImage.init(named:"updatedProfilePlaceholder")!
                }
                self.configureTableViewHeader()
                //Configure UserRole
                self.configureCurrentUserRole()
                
                self.currentUser = User.getUserFromUserDefault()
                
                //            if self.currentUser!.userDefaultRole.compareCaseInsensitive(str:"User") {
                //                self.objSegmentController.isHidden = true
                //                //self.lblUserCityName.isHidden = true
                //            }else if self.currentUser!.userDefaultRole.compareCaseInsensitive(str:"traveller"){
                //                self.objSegmentController.isHidden = false
                //                //self.lblUserCityName.isHidden = false
                //            }
                if self.currentUser?.userType == .traveller {
                    self.guide = false
                    DispatchQueue.main.async {
                        self.objSegmentController.selectedSegmentIndex = 1
                    }
                } else {
                    self.guide = true
                    DispatchQueue.main.async {
                        self.objSegmentController.selectedSegmentIndex = 0
                    }
                }
            }
            if User.isUserLoggedIn {
                self.objSegmentController.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 13)!], for: .selected)
                self.objSegmentController.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 13)!], for: .normal)
                self.objSegmentController.setTitle(Vocabulary.getWordFromKey(key: "mguide.hint"), forSegmentAt: 0)
                self.objSegmentController.setTitle(Vocabulary.getWordFromKey(key: "mtraveler.hint"), forSegmentAt: 1)
                
                self.lblUserCityName.isHidden = false
                self.lblUserName.isHidden = false
                if self.currentUser!.userDefaultRole == "User" {
                    self.objSegmentController.isHidden = true
                    //profileCell.profileCity.isHidden = true
                }else if self.currentUser!.userDefaultRole == "traveller" {
                    self.objSegmentController.isHidden = false
                    //profileCell.profileCity.isHidden = false
                }else{
                    self.objSegmentController.isHidden = false
                }
                if self.currentUser!.userType == .guide{
                    self.objSegmentController.selectedSegmentIndex = 0
                } else if self.currentUser!.userType == .traveller{
                    self.objSegmentController.selectedSegmentIndex = 1
                }
            } else {
                self.objSegmentController.isHidden = true
                self.lblUserCityName.isHidden = true
                self.lblUserName.isHidden = true
                self.anonymousName.text = Vocabulary.getWordFromKey(key: "Anonymous")
            }
        }
        func addDynamicFont(){
            // self.lblNavTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
            // self.lblNavTitle.adjustsFontForContentSizeCategory = true
            // self.lblNavTitle.adjustsFontSizeToFitWidth = true
            
            self.anonymousName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
            self.anonymousName.adjustsFontForContentSizeCategory = true
            self.anonymousName.adjustsFontSizeToFitWidth = true
            
            self.lblUserName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
            self.lblUserName.adjustsFontForContentSizeCategory = true
            self.lblUserName.adjustsFontSizeToFitWidth = true
            self.menuTableView.reloadData()
        }
        func changeSegment() {
            self.configureTable()
        }
        func configureTableViewHeader(){
            //self.tableviewSetting.estimatedSectionHeaderHeight = 100.0
            self.imgProfile.layer.borderColor = UIColor.clear.cgColor
            self.imgProfile.layer.borderWidth = 0.5
            self.imgProfile.layer.cornerRadius = 30.0
            self.imgProfile.clipsToBounds = true
            
            if let _ = self.menuTableView.tableHeaderView{
                //self.menuTableView.tableHeaderView?.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.menuTableView.bounds.width, height: self.isGuide ? 120.0 :100.0))
                //self.view.layoutIfNeeded()
            }
        }
        func configureCurrentUserRole(){
            guard (User.isUserLoggedIn),let userDetail = User.getUserFromUserDefault() else{
                self.buttonUserProfile.isHidden = true
                return
            }
            self.buttonUserProfile.isHidden = false
            self.lblUserName.text = "\(userDetail.userFirstName) \(userDetail.userLastName)"
            self.lblUserCityName.text = "\(userDetail.userCurrentCity), \(userDetail.userCurrentCountry)"
        }
        // MARK:- UITableViewDataSource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.menuArr.count
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            /*
             if indexPath.row == 0 {
             // Round Profile Image
             let profileCell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! MenuTableViewCustomCell
             profileCell.selectionStyle = .none
             profileCell.profileImg.layer.cornerRadius = profileCell.profileImg.frame.size.width / 2
             profileCell.profileImg.clipsToBounds = true
             profileCell.profileImg.layer.borderColor = UIColor.black.cgColor
             profileCell.profileImg.layer.borderWidth = 1.0
             if User.isUserLoggedIn {
             profileCell.objSegmentController.setTitle(Vocabulary.getWordFromKey(key: "GUIDE"), forSegmentAt: 0)
             profileCell.objSegmentController.setTitle(Vocabulary.getWordFromKey(key: "TRAVELER"), forSegmentAt: 1)
             profileCell.profileEditImg.isHidden = false
             profileCell.anonymousName.isHidden = true
             profileCell.buttonProfileImage.isEnabled = true
             profileCell.objSegmentController.isHidden = false
             profileCell.profileCity.isHidden = false
             if self.currentUser!.userDefaultRole == "User" {
             profileCell.objSegmentController.isHidden = true
             //profileCell.profileCity.isHidden = true
             }else if self.currentUser!.userDefaultRole == "traveller" {
             profileCell.objSegmentController.isHidden = false
             //profileCell.profileCity.isHidden = false
             }
             if self.currentUser!.userType == .guide{
             profileCell.objSegmentController.selectedSegmentIndex = 0
             } else if self.currentUser!.userType == .traveller{
             profileCell.objSegmentController.selectedSegmentIndex = 1
             }
             } else {
             profileCell.buttonProfileImage.isEnabled = false
             profileCell.profileEditImg.isHidden = true
             profileCell.objSegmentController.isHidden = true
             profileCell.profileCity.isHidden = true
             profileCell.anonymousName.text = Vocabulary.getWordFromKey(key: "Anonymous")
             }
             profileCell.objSegmentController.addTarget(self, action:  #selector(segmentChanged), for:.valueChanged)
             //profileCell.buttonProfileImage.addTarget(self, action: #selector(profileButtonClicked), for: .touchUpInside)
             DispatchQueue.main.async {
             if let imgUrl = self.currentUser?.userImageURL,imgUrl.count > 0 {
             profileCell.profileImg.imageFromServerURL(urlString: imgUrl,placeHolder:UIImage.init(named:"ic_profile")!)
             }else{
             profileCell.profileImg.image = UIImage.init(named:"ic_profile")
             }
             }
             if(User.isUserLoggedIn),let currentUser = User.getUserFromUserDefault(){
             profileCell.profileCity.text = "\(currentUser.userCurrentCity),\(currentUser.userCurrentCountry)"
             profileCell.profileName.text = "\(currentUser.userFirstName) \(currentUser.userLastName)"
             }
             profileCell.profileEditImg.isHidden = true
             DispatchQueue.main.async {
             profileCell.addDynamicFont()
             }
             return profileCell
             }
             else */
            if indexPath.row == indexOfLogOut {
                let titleCell = tableView.dequeueReusableCell(withIdentifier: "MenuNameTableViewCell") as! MenuNameTableViewCell
                //let titleCell = tableView.dequeueReusableCell(withIdentifier: "MenuNameCell") as! MenuNameTableViewCell
                //titleCell.menuTitleLbl.text = menuArr[indexPath.row]
                titleCell.menuTitleLbl.isHidden = true
                titleCell.lblDetail?.text = menuArr[indexPath.row]
                DispatchQueue.main.async {
                    titleCell.detailImg.isHidden = true
                    //titleCell.menuTitleLbl.textColor = UIColor(red: 41/255, green: 99/255, blue: 175/255, alpha: 1.0)
                }
                return titleCell
            } else {
                let titleCell = tableView.dequeueReusableCell(withIdentifier: "MenuNameTableViewCell") as! MenuNameTableViewCell
                //let titleCell = tableView.dequeueReusableCell(withIdentifier: "MenuNameCell") as! MenuNameTableViewCell
                DispatchQueue.main.async {
                    titleCell.detailImg.isHidden = false
                }
                //titleCell.menuTitleLbl.textColor = UIColor.black
                
                if indexPath.row == indexOfBecomeGuide,User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(),self.currentUser!.userType == .traveller{
                    if currentUser.userDefaultRole.compareCaseInsensitive(str:"Guide"), currentUser.guideRequestStatus == "2" {
                        let strBecomeGuide = "\(self.menuArr[indexPath.row])" + " \(Vocabulary.getWordFromKey(key: "Approved"))"
                        let strMutableString = NSMutableAttributedString.init(string: strBecomeGuide)
                        let attributes:[NSAttributedStringKey : Any]
                            = [NSAttributedStringKey.foregroundColor:UIColor.init(hexString: "#367D4A") as Any]
                        
                        strMutableString.addAttributes(attributes, range:NSRange(location:"\(self.menuArr[indexPath.row])".count,length:" \(Vocabulary.getWordFromKey(key: "Approved"))".count) )
                        titleCell.selectionStyle = .none
                        titleCell.lblDetail?.attributedText = strMutableString
                    }
                    else {
                        if self.currentUser?.guideRequestStatus == "1" {
                            let strBecomeGuide = "\(self.menuArr[indexPath.row])" + " \(Vocabulary.getWordFromKey(key: "Pending.status"))"
                            let strMutableString = NSMutableAttributedString.init(string: strBecomeGuide)
                            let attributes:[NSAttributedStringKey : Any]
                                = [NSAttributedStringKey.foregroundColor:UIColor.red as Any]
                            
                            strMutableString.addAttributes(attributes, range:NSRange(location:"\(self.menuArr[indexPath.row ])".count,length:" \(Vocabulary.getWordFromKey(key: "Pending.status"))".count) )
                            titleCell.selectionStyle = .none
                            titleCell.lblDetail?.attributedText = strMutableString
                        } else {
                            titleCell.lblDetail?.text = self.menuArr[indexPath.row]
                        }
                    }
                }else{
                    titleCell.lblDetail?.text = self.menuArr[indexPath.row]
                }
                titleCell.menuTitleLbl.isHidden = true
                return titleCell
            }
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return tableViewRowHeight
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if indexPath.row == indexOfLogOut, User.isUserLoggedIn {
                let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"Logout"), message: Vocabulary.getWordFromKey(key:"logout.msg"), preferredStyle: .alert)
                alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (_) in
                    kUserDefault.removeObject(forKey: "isLocationPushToHome")
                    User.removeUserFromUserDefault()
                    kUserDefault.removeObject(forKey: kExperienceDetail)
                    kUserDefault.synchronize()
                    FaceBookLogIn.logoutFromFacebook()
                    self.tabBarController?.navigationController?.popToRootViewController(animated: true)
                }))
                alertController.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler: nil))
                let titleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17.0)!]
                let messageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
                let titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key:"Logout"), attributes: titleFont)
                let messageAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key:"logout.msg"), attributes: messageFont)
                
                alertController.setValue(titleAttrString, forKey: "attributedTitle")
                alertController.setValue(messageAttrString, forKey: "attributedMessage")
                alertController.view.tintColor = UIColor.init(hexString: "#36527D")
                self.present(alertController, animated: true, completion: nil)
            }
            if indexPath.row == indexOfLogOut, !User.isUserLoggedIn {
                self.pushToSignInController()
            }
            if indexPath.row == indexOfBecomeGuide, User.isUserLoggedIn, self.currentUser!.userType == .traveller, self.currentUser!.guideRequestStatus == "0" {  // Become Guide
                if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(),currentUser.userDefaultRole.compareCaseInsensitive(str:"User"){
                    isFromRequestLocation = false
                    self.presentSearchCountry()
                }
            }else if indexPath.row == indexOfBecomeGuide,User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(),self.currentUser!.userType == .traveller{
                if currentUser.userDefaultRole.compareCaseInsensitive(str:"Guide"), currentUser.guideRequestStatus == "2" {
                    self.presentApprovedGuideAlertController()
                }
            }
            else if indexPath.row == indexOfSettings, User.isUserLoggedIn {  //Settings
                self.pushToSettingViewController()
            }
            else if indexPath.row == indexOfUpcomingExperience, User.isUserLoggedIn, self.currentUser!.userType == .traveller { // Upcoming Experience
                self.pushToMyLiveController()
            }
            if indexPath.row == indexOfTermsConditions { //TermsAndConditions
                self.presentTermsAndConditions()
            }
            if indexPath.row == indexOfChangeLanguage { // Change Language
                pushToChangeLanguage()
            }
            //        if indexPath.row == indexOfRequestLocation { //LocationRequest
            //            self.pushToLocationRequest()
            //        }
            if indexPath.row == indexOfMySchedule, User.isUserLoggedIn, self.currentUser!.userType == .guide { //MySchedule
                self.pushToScheduleController()
            }
            if indexPath.row == indexOfMyTours, User.isUserLoggedIn, self.currentUser!.userType == .guide { //MyTours
                self.pushToMyLiveController()
            }
            if indexPath.row == indexOfAboutUS{
                self.pushToAboutUsController()
            }
            if indexPath.row == indexOfContactUs { // Contact Us
                guard User.isUserLoggedIn else {
                    let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"notLogin.title"), message: Vocabulary.getWordFromKey(key:"nologinContactus.hint"), preferredStyle: .alert)
                    alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (_) in
                       self.pushToSignInController()
                    })) //
                    alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler: nil))
                    alertController.view.tintColor = UIColor.init(hexString: "36527D")
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                self.pushToContactUs()
            }
            defer{
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        //Remove Profile Image
        func removeImageRequest(){
            if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
                
                let removeProfileRequest = "users/\(currentUser.userID)/native/userprofileimage"
                APIRequestClient.shared.sendRequest(requestType: .PUT, queryString:removeProfileRequest, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                    if let response = responseSuccess as? [String:Any],let successData = response["data"] as? [String:Any],let updatedImageURL = successData["ProfileImageUrl"],let strMSG = successData["Message"]{
                        DispatchQueue.main.async {
                            self.imgProfile.imageFromServerURL(urlString: "https://s3-us-west-2.amazonaws.com/live-placeholder-images/profile.png",placeHolder:#imageLiteral(resourceName: "ic_profile").withRenderingMode(.alwaysOriginal))
                        }
                        currentUser.userImageURL = ""
                        currentUser.setUserDataToUserDefault()
                        DispatchQueue.main.async {
                            ShowToast.show(toatMessage: "\(strMSG)")
                        }
                    }
                }, fail: { (responseFail) in
                    if let failData = responseFail as? [String:Any],let failMessage = failData["Message"]{
                        DispatchQueue.main.async {
                            ShowToast.show(toatMessage: "\(failMessage)")
                        }
                    }
                })
            }
            
        }
        func presentApprovedGuideAlertController(){
            
            let alertController = UIAlertController.init(title:"Qualified Guide", message:"You are a approved guide", preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key: "ok.title"), style: .cancel, handler: { (_) in
            }))
            alertController.view.tintColor = UIColor.init(hexString: "36527D")
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
        }
        // MARK:- Selector Methods
        
        @IBAction func buttonProfileSelector(sender:UIButton){
            //Present ImagePicker
            let actionSheet = UIAlertController.init(title:"", message:Vocabulary.getWordFromKey(key:"updateprofilePic.hint"), preferredStyle: .actionSheet)
            let cancel = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler: nil)
            actionSheet.addAction(cancel)
            let photoLiberary = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Photos"), style: .default) { (_) in
                self.objectImagePicker.sourceType = .photoLibrary
                self.present(self.objectImagePicker, animated: true, completion: nil)
            }
            actionSheet.addAction(photoLiberary)
            let camera = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"takePhoto.hint"), style: .default) { (_) in
                if CommonClass.isSimulator{
                    DispatchQueue.main.async {
                        let noCamera = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"Cameranotsupported"), message: "", preferredStyle: .alert)
                        noCamera.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .cancel, handler: nil))
                        self.present(noCamera, animated: true, completion: nil)
                    }
                }else{
                    self.objectImagePicker.sourceType = .camera
                    self.present(self.objectImagePicker, animated: true, completion: nil)
                }
            }
            actionSheet.addAction(camera)
            if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
                let removeProfilePic = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"deletePhoto.hint"), style: .default) { (_) in
                    self.removeImageRequest()
                }
                if "\(currentUser.userImageURL)".count > 0{
                    removeProfilePic.setValue(UIColor.init(hexString: "FF3B30"), forKey: "titleTextColor")
                    actionSheet.addAction(removeProfilePic)
                }
            }
            actionSheet.view.tintColor = UIColor.init(hexString: "36527D")
            self.present(actionSheet, animated: true, completion: nil)
        }
        
        
        @objc func profileButtonClicked(sender: UIButton?) {
            let actionSheet = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"ProfileImage"), message:Vocabulary.getWordFromKey(key:"Chooseprofilefrom"), preferredStyle: .actionSheet)
            let cancel = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler: nil)
            actionSheet.addAction(cancel)
            let photoLiberary = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Photos"), style: .default) { (_) in
                self.objectImagePicker.sourceType = .photoLibrary
                self.present(self.objectImagePicker, animated: true, completion: nil)
            }
            actionSheet.addAction(photoLiberary)
            let camera = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Camera"), style: .default) { (_) in
                if CommonClass.isSimulator{
                    DispatchQueue.main.async {
                        let noCamera = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"Cameranotsupported"), message: "", preferredStyle: .alert)
                        noCamera.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .cancel, handler: nil))
                        self.present(noCamera, animated: true, completion: nil)
                    }
                }else{
                    self.objectImagePicker.sourceType = .camera
                    self.present(self.objectImagePicker, animated: true, completion: nil)
                }
            }
            actionSheet.addAction(camera)
            self.present(actionSheet, animated: true, completion: nil)
        }
        @IBAction func segmentChangeSelector(sender:UISegmentedControl){
            switch sender.selectedSegmentIndex {
            case 0: //Guide
                self.currentUser!.userType = .guide
                self.guide = true
                self.currentUser!.setUserDataToUserDefault()
                self.configureTable()
                break
            case 1: //Traveler
                self.guide = false
                self.currentUser!.userType = .traveller
                self.currentUser!.setUserDataToUserDefault()
                self.configureTable()
                break
            default:
                break
            }
        }
        @objc func segmentChanged(sender: UISegmentedControl) {
            switch sender.selectedSegmentIndex {
            case 0: //Guide
                self.currentUser!.userType = .guide
                self.guide = true
                self.currentUser!.setUserDataToUserDefault()
                self.configureTable()
                break
            case 1: //Traveler
                self.guide = false
                self.currentUser!.userType = .traveller
                self.currentUser!.setUserDataToUserDefault()
                self.configureTable()
                break
            default:
                break
            }
        }
        
        func getUsertype(){
            if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
                let userTypeParameters = ["email":"\(currentUser.userEmail)"]
                
                APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kGetUserType, parameter:userTypeParameters as [String : AnyObject],isHudeShow: false,success: { (responseSuccess) in
                    
                    if let success = responseSuccess as? [String:Any],let userDetail = success["data"] as? [String:Any]{
                        if let _ = userDetail["UserType"]{
                            //                        currentUser.userRole = "\(userDetail["UserType"]!)"
                            currentUser.userDefaultRole = "\(userDetail["UserType"]!)"
                            DispatchQueue.main.async {
                                if currentUser.userDefaultRole == "User" {
                                    self.objSegmentController.isHidden = true
                                }else if self.currentUser!.userDefaultRole == "traveller" {
                                    self.objSegmentController.isHidden = false
                                }else{
                                    self.objSegmentController.isHidden = false
                                }
                            }
                        }
                        if let strProvision = userDetail["Provision"],!(strProvision is NSNull) {
                            currentUser.userProvision = "\(strProvision)"
                        }
                        if let _ = userDetail["GuideRequestStatus"]{
                            currentUser.guideRequestStatus = "\(userDetail["GuideRequestStatus"]!)"
                        }
                        if let _ = userDetail["RoleId"]{
                            currentUser.userRoleID = "\(userDetail["RoleId"]!)"
                        }
                        if let _ = userDetail["ProfileImage"],!(userDetail["ProfileImage"]! is  NSNull) {
                            currentUser.userImageURL = "\(userDetail["ProfileImage"]!)"
                        }else{
                            currentUser.userImageURL = ""
                        }
                        currentUser.setUserDataToUserDefault()
                        
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
        
        func uploadImageRequest(imageData:Data,imageName:String){
            if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
                let parameters = [
                    "file_name": "\(imageName)"
                ]
                let uploadGuideProfileRequest = "guides/\(currentUser.userID)/native/image/upload/\(imageName)"
                APIRequestClient.shared.uploadImage(requestType: .PUT, queryString: uploadGuideProfileRequest, parameter: parameters as [String : AnyObject], imageData: imageData, isHudeShow: true, success: { (sucessResponse) in
                    DispatchQueue.main.async {
                        ProgressHud.hide()
                    }
                    if let response = sucessResponse as? [String:Any],let successData = response["data"] as? [String:Any],let uploadedImageURL = successData["ImageUrl"],let strMSG = successData["Message"]{
                        currentUser.userImageURL = "\(uploadedImageURL)"
                        currentUser.setUserDataToUserDefault()
                        let objAlert = UIAlertController(title:Vocabulary.getWordFromKey(key:"Success"), message: "\(strMSG)",preferredStyle: UIAlertControllerStyle.alert)
                        objAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (action: UIAlertAction!) in
                            DispatchQueue.main.async {
                                self.imgProfile.imageFromServerURL(urlString:"\(uploadedImageURL)", placeHolder:UIImage.init(named:"updatedProfilePlaceholder")!)
                            }
                        }))
                        objAlert.view.tintColor = UIColor(hexString: "#36527D")
                        self.present(objAlert, animated: true, completion: nil)
                    }else{
                        DispatchQueue.main.async {
                            ShowToast.show(toatMessage: "\(kCommonError)")
                        }
                    }
                }) { (failResponse) in
                    DispatchQueue.main.async {
                        ProgressHud.hide()
                    }
                    if let failData = failResponse as? [String:Any],let failMessage = failData["Message"]{
                        DispatchQueue.main.async {
                            ShowToast.show(toatMessage: "\(failMessage)")
                        }
                    }
                }
            }
            
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        // MARK: - Navigation
        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        }
        
        func pushToSignInController(){ // Push to SignIn Screen
            self.tabBarController?.navigationController?.popToRootViewController(animated: true)
        }
        
        func pushToChangeLanguage(){ // Push to Change Language Screen
            if let languageViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChangeLanguageViewController") as? ChangeLanguageViewController{
                languageViewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(languageViewController, animated: true)
            }
        }
        
        func pushToScheduleController(){ // Push to MyLive Controller
            if let scheduleController = self.storyboard?.instantiateViewController(withIdentifier:"FullScheduleViewController") as? FullScheduleViewController {
                scheduleController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(scheduleController, animated: false)
            }
        }
        
        func presentTermsAndConditions(){ // Present TermsAndConditions
            guard CommonClass.shared.isConnectedToInternet else {
                return
            }
            if let termsViewController = self.storyboard?.instantiateViewController(withIdentifier:"TermsViewController") as? TermsViewController{
                self.navigationController?.present(termsViewController, animated: true, completion: nil)
            }
        }
        
        func presentSearchCountry() { // Present SearchCountry
            if let becomGuideViewController = self.storyboard?.instantiateViewController(withIdentifier:"BecomeGuideViewController") as? BecomeGuideViewController {
                becomGuideViewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(becomGuideViewController, animated: true)
            }
        }
        func pushToAboutUsController(){ //push to about us
            if let aboutUS = self.storyboard?.instantiateViewController(withIdentifier: "AboutUSViewController") as? AboutUSViewController{
                aboutUS.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(aboutUS, animated: true)
            }
        }
        func pushToSettingViewController(){ // PushToSettingViewController
            if let settingViewController = self.storyboard?.instantiateViewController(withIdentifier:
                "SettingViewController") as? SettingViewController{
                if self.isGuide {
                    settingViewController.guide = true
                } else {
                    settingViewController.guide = false
                }
                settingViewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(settingViewController, animated: true)
            }
        }
        
        func pushToMyLiveController(){ // Push to MyLive Controller
            if let myLiveViewController = self.storyboard?.instantiateViewController(withIdentifier:"HomeViewController") as? HomeViewController {
                //myLiveViewController.selectedIndex = 2
                //self.navigationController?.pushViewController(myLiveViewController, animated: true)
                self.tabBarController?.selectedIndex = 2
            }
        }
        func pushToLocationRequest(){ // Push to Location Request ViewController
            if let locationRequestViewController = self.storyboard?.instantiateViewController(withIdentifier:"LocationRequestViewController") as? LocationRequestViewController {
                self.navigationController?.pushViewController(locationRequestViewController, animated: true)
            }
        }
        func pushToContactUs(){
            guard CommonClass.shared.isConnectedToInternet else {
                return
            }
            let requestList = RequestUi.buildRequestList(with: [])
            
            // let helpCenter = HelpCenterUi.buildHelpCenterOverview(withConfigs: [])
            let supportViewController = SupportNavController.init(rootViewController: requestList)
            IQKeyboardManager.shared.enable = false
            IQKeyboardManager.shared.enableAutoToolbar = false
            self.present(supportViewController, animated: true, completion: nil)
        }
    }
    class SupportNavController: UINavigationController {
        
        override func viewDidLoad() {
            super.viewDidLoad()
            //pushViewController(helpCenter, animated: true)
        }
    }
    extension MenuViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate, CropViewControllerDelegate {
        
        func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage) {
            let imageData = image.jpeg(.medium)
            self.uploadImageRequest(imageData: imageData!, imageName: "image")
        }
        
        func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect) {
            controller.dismiss(animated: false, completion: nil)
        }
        
        func cropViewControllerDidCancel(_ controller: CropViewController) {
            controller.dismiss(animated: false, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            //        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage,let imageData = editedImage.jpeg(.lowest){
            //            self.uploadImageRequest(imageData: imageData, imageName:"image")
            //            picker.dismiss(animated: true, completion: nil)
            //        }
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                dismiss(animated: false, completion: nil)
                return
            }
            self.imageForCrop = image
            dismiss(animated: false) { [unowned self] in
                self.openEditor(nil, pickingViewTag: 1) // tag 1 = Profile Image
            }
        }
    }

    class AboutUSViewController: UIViewController {
        
        @IBOutlet var lblNavigationTitle:UILabel!
        @IBOutlet var buttonBack:UIButton!
        @IBOutlet var lblAppVersion:UILabel!
        
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            self.configureAboutUsView()
        }
        // MARK: - Configuration
        func configureAboutUsView(){
            self.buttonBack.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
            self.buttonBack.imageView?.tintColor = UIColor.black
            self.lblNavigationTitle.text = Vocabulary.getWordFromKey(key:"aboutus.hint")
            if Env.isProduction(){
                self.lblAppVersion.text = "\(Bundle.main.versionNumber)"
            }else{
                self.lblAppVersion.text = "\(Bundle.main.versionNumber) - STAGGING"
            }
            
        }
        // MARK: - Configuration
        @IBAction func buttonBackSelector(sender:UIButton){
            self.navigationController?.popViewController(animated: true)
        }
    }
    struct Env {
        
        private static let production : Bool = {
            #if DEBUG
            print("DEBUG")
            return false
            #elseif ADHOC
            print("ADHOC")
            return false
            #else
            print("PRODUCTION")
            return true
            #endif
        }()
        
        static func isProduction () -> Bool {
            return self.production
        }
        
    }
