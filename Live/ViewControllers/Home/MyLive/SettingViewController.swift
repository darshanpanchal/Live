//
//  SettingViewController.swift
//  Live
//
//  Created by ITPATH on 4/24/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import FacebookCore

class SettingViewController: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var objSegmentController: UISegmentedControl!
    @IBOutlet var tableviewSetting:UITableView!
    @IBOutlet var imgProfile:ImageViewForURL!
    @IBOutlet var lblUserName:UILabel!
    @IBOutlet var lblNavTitle:UILabel!
    @IBOutlet var lblUserCityName:UILabel!
    @IBOutlet var buttonBack:UIButton!
    @IBOutlet var buttonUserProfile:UIButton!
    @IBOutlet var tableViewHeader:UIView!
    
    var imageForCrop: UIImage!

    @IBOutlet var imgProfileEdit:UIImageView!
    @IBOutlet var imgUserNameEdit:UIImageView!
    var arrayOfCards:[CreditCard]=[]
    var arrayOfLanguage:[ExperienceLangauge] = []
    var selectedLangauges:[ExperienceLangauge] = []
    let objectImagePicker:UIImagePickerController = UIImagePickerController()
    var currentUser:User?
    var arrayOfCountry:[CountyDetail] = []
    var countryDetail:CountyDetail?
    var tableViewHeightOfHeader:CGFloat{
        get{
            return isGuide ? 100 : 120.0
        }
    }
    var tableViewRowHeight:CGFloat{
        get{
            return 88.0
        }
    }
    var guide:Bool = false
    var isGuide:Bool{
        get{
            return guide
        }
        set{
            self.guide = newValue
        }
    }
    var indexOfPayments:Int{
        get{
            return isGuide ? 3 : 1
        }
    }
    var indexOfProvision:Int{
        get{
            return isGuide ? 1 : -1
        }
    }
    var indexOfLocation:Int{
        if isGuide {
            return 2
        } else {
            return -1
        }
    }
    var indexOfChangePassword:Int{
        get{
            return isGuide ? 8 : 3
        }
    }
    var indexOfCouponCode:Int{
        get{
            return isGuide ? 4 : 2
        }
    }
    
    var indexOfBankDetails:Int{
        if isGuide {
            return 5
        } else {
            return -1
        }
    }
    var indexOfDescription:Int{
        if isGuide {
            return 7
        } else {
            return -1
        }
    }
    var indexOfGuideLanguages:Int{
        if isGuide {
            return 6
        } else {
            return -1
        }
    }
    var arrayOfSettingGuide:[String] = []
    var arrayOfSettingTraveller:[String] = []
    var menuArr = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonBack.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.buttonBack.imageView?.tintColor = UIColor.black
        imgProfile.contentMode = .scaleAspectFill
        imgProfile.clipsToBounds = true
        //self.objSegmentController.layer.cornerRadius = 14.0
        //self.objSegmentController.clipsToBounds = true
        //self.objSegmentController.layer.borderWidth = 1.0
        //Check for currentUser
        guard User.isUserLoggedIn else {
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
//        let profileEditImage = #imageLiteral(resourceName: "editprofile").withRenderingMode(.alwaysTemplate)
//        self.imgProfileEdit.tintColor = UIButton().tintColor.withAlphaComponent(0.6)
//        self.imgProfileEdit.image = profileEditImage
        
//        let profileEditUserName = #imageLiteral(resourceName: "editusername").withRenderingMode(.alwaysTemplate)
//        self.imgUserNameEdit.tintColor = UIButton().tintColor.withAlphaComponent(0.6)
//        self.imgUserNameEdit.image = profileEditUserName
        defer{
            self.getLanguages()
            
        }
        self.objSegmentController.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 13)!], for: .selected)
        self.objSegmentController.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 13)!], for: .normal)
        self.objSegmentController.setTitle(Vocabulary.getWordFromKey(key: "mguide.hint"), forSegmentAt: 0)
        self.objSegmentController.setTitle(Vocabulary.getWordFromKey(key: "mtraveler.hint"), forSegmentAt: 1)
    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getCardsFromUserID()
        if User.isUserLoggedIn{
            self.getLocationsbyCountryId()
        }
        DispatchQueue.main.async {
//            self.objSegmentController.setTitle(Vocabulary.getWordFromKey(key: "GUIDE"), forSegmentAt: 0)
//            self.objSegmentController.setTitle(Vocabulary.getWordFromKey(key: "TRAVELER"), forSegmentAt: 1)
            self.lblNavTitle.text = Vocabulary.getWordFromKey(key: "Settings")
        }
        guard User.isUserLoggedIn else {
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
        self.currentUser = User.getUserFromUserDefault()
        if self.currentUser!.userDefaultRole.compareCaseInsensitive(str:"User") {
            self.objSegmentController.isHidden = true
            //self.lblUserCityName.isHidden = true
        }else if self.currentUser!.userDefaultRole.compareCaseInsensitive(str:"traveller"){
            self.objSegmentController.isHidden = false
            //self.lblUserCityName.isHidden = false
        }else{
            self.objSegmentController.isHidden = false
        }
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
        if self.guide{
            self.menuArr = arrayOfSettingGuide
        } else  {
            self.menuArr = arrayOfSettingTraveller
        }
        //Configure TableViewHeader
        DispatchQueue.main.async {
            if let imgURL = self.currentUser?.userImageURL,imgURL.count > 0{
                self.imgProfile.imageFromServerURL(urlString:self.currentUser!.userImageURL,placeHolder:UIImage.init(named:"updatedProfilePlaceholder")!)
            }else{
                self.imgProfile.image = UIImage.init(named:"updatedProfilePlaceholder")!
            }
            self.configureTableViewHeader()
        }
        //Configure SettingView
        self.configureSettingView()
        //Configure Setting TableView
        DispatchQueue.main.async {
            self.configureTableView()
            //Configure UserRole
            self.configureCurrentUserRole()
        }
        var parameters:[String:Any] = [:]
        parameters["item_name"] = "Setting"
        parameters["username"] = "\(self.currentUser?.userFirstName ?? "") \(self.currentUser?.userLastName ?? "")"
        parameters["userID"] = "\(self.currentUser?.userID ?? "")"
        parameters["userRole"] = "\(self.currentUser?.userDefaultRole ?? "")"
        CommonClass.shared.addFirebaseAnalytics(parameters: parameters)
        self.addFaceBookAnayltics()
        DispatchQueue.main.async {
            self.addDynamicFont()
            self.swipeToPop()
        }
    }
    func swipeToPop() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func addDynamicFont(){
        self.lblNavTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblNavTitle.adjustsFontForContentSizeCategory = true
        self.lblNavTitle.adjustsFontSizeToFitWidth = true
        
        self.lblUserName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblUserName.adjustsFontForContentSizeCategory = true
        self.lblUserName.adjustsFontSizeToFitWidth = true
        
//        self.lblUserCityName.font = CommonClass.shared.getScaledWithOutMinimum(forFont: "Avenir-Roman", textStyle: .body)
//        self.lblUserCityName.adjustsFontForContentSizeCategory = true
//        self.lblUserCityName.adjustsFontSizeToFitWidth = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
    //Configure TableViewHeader
    func configureTableViewHeader(){
        //self.tableviewSetting.estimatedSectionHeaderHeight = 100.0
       // self.imgProfile.layer.borderColor = UIColor.black.cgColor
        //self.imgProfile.layer.borderWidth = 0.5
        self.imgProfile.layer.cornerRadius = 30.0
        self.imgProfile.clipsToBounds = true
        
        if let _ = self.tableviewSetting.tableHeaderView{
            self.tableviewSetting.tableHeaderView?.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.tableviewSetting.bounds.width, height: 120.0))//self.isGuide ? 120.0 :100.0))
        }
    }
    //Configure SettingView
    func configureSettingView(){
        self.objectImagePicker.delegate = self
        self.objectImagePicker.allowsEditing = false
    }
    //Configure Setting TableView
    func configureTableView(){
        self.arrayOfSettingGuide = ["\(Vocabulary.getWordFromKey(key:"email.placeholder"))","\(Vocabulary.getWordFromKey(key:"provision.hint"))","\(Vocabulary.getWordFromKey(key:"Location"))","\(Vocabulary.getWordFromKey(key:"Payment"))",
            "\(Vocabulary.getWordFromKey(key:"couponcode.hint"))","\(Vocabulary.getWordFromKey(key:"Bank Detail"))","\(Vocabulary.getWordFromKey(key:"language"))","\(Vocabulary.getWordFromKey(key:"yourbio.hint"))","\(Vocabulary.getWordFromKey(key:"Change Password"))","\(Vocabulary.getWordFromKey(key: "History"))"]
        
        self.arrayOfSettingTraveller = ["\(Vocabulary.getWordFromKey(key:"email.placeholder"))","\(Vocabulary.getWordFromKey(key:"Payment"))","\(Vocabulary.getWordFromKey(key: "couponcode.hint"))","\(Vocabulary.getWordFromKey(key:"Change Password"))","\(Vocabulary.getWordFromKey(key: "History"))"]
        if self.guide{
            self.menuArr = arrayOfSettingGuide
        } else  {
            self.menuArr = arrayOfSettingTraveller
        }
        self.tableviewSetting.rowHeight = UITableViewAutomaticDimension
        self.tableviewSetting.estimatedRowHeight = 50.0
        self.tableviewSetting.delegate = self
        self.tableviewSetting.dataSource = self
        self.tableviewSetting.separatorStyle = .none
        self.tableviewSetting.reloadData()
    }
    //Configure UserRole
    func configureCurrentUserRole(){
        self.lblUserName.text = "\(self.currentUser!.userFirstName) \(self.currentUser!.userLastName)"
        self.lblUserCityName.text = "\(self.currentUser!.userCurrentCity), \(self.currentUser!.userCurrentCountry)"
    }
    func configureSelectedLanguage(){
        if self.selectedLangauges.count > 0{
            var arrayLanID:[String] = []
            for objLan in selectedLangauges{
                arrayLanID.append("\(objLan.langaugeID)")
            }
            self.postAPIRequestForGuideLanguages(languageIDs: arrayLanID)
        }
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
    
    // MARK: - API Request Methods
    func getCardsFromUserID(){
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(),currentUser.userID.count > 0{
            //let requestURL = "payment/native/users/30/creditcards"
            let requestURL = "payment/native/users/\(currentUser.userID)/creditcards"
            APIRequestClient.shared.sendRequest(requestType: .GET, queryString: requestURL, parameter: nil, isHudeShow: false , success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let arraySuccess = successDate["cards"] as? [[String:Any]]{
                    self.arrayOfCards = []
                    for object:[String:Any] in arraySuccess{
                        let cardDetail = CreditCard.init(cardDetail: object)
                        self.arrayOfCards.append(cardDetail)
                    }
                    DispatchQueue.main.async {
                        self.tableviewSetting.reloadData()
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
    }
    func getLocationsbyCountryId(){
        let currentUser: User? = User.getUserFromUserDefault()
        let userCountryId: String? = currentUser?.userCurrentCountryID
        let url = "\(kAllLocation)/\(userCountryId!)"
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString: url, parameter: nil, isHudeShow: false, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let arraySuccess = successDate["location"] as? NSArray{
                self.arrayOfCountry = []
                for objCountry in arraySuccess{
                    if let jsonCountry = objCountry as? [String:Any]{
                        let countryDetail = CountyDetail.init(objJSON: jsonCountry)
                        self.arrayOfCountry.append(countryDetail)
                    }
                }
                DispatchQueue.main.async {
                    //self.countryTblObj.reloadData()
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
    func getLanguages(){
        //let getlangauge = "base/native/languages"
            APIRequestClient.shared.sendRequest(requestType: .GET, queryString:kAllLanguage, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let arayOfLanguage = successData["Language"] as? [[String:Any]]{
                    self.arrayOfLanguage = []
                    for objLangauge in arayOfLanguage{
                        if let languageID = objLangauge["id"],let langaugeName = objLangauge["name"],let langaugeCode = objLangauge["code"]{
                            
                            let langauge = ExperienceLangauge.init(langaugeID: "\(languageID)", langaugeName:"\(langaugeName)", langaugeCode: "\(langaugeCode)")
                            self.arrayOfLanguage.append(langauge)
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
    //GET Guide Languages
    func getGuideLanguages(){
        //let getlangauge = "base/native/languages"
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            let requestURL = "guides/\(currentUser.userID)/native/languages"
            APIRequestClient.shared.sendRequest(requestType: .GET, queryString:requestURL, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let arayOfLanguage = successData["Language"] as? [[String:Any]]{
                    self.selectedLangauges = []
                    for objLangauge in arayOfLanguage{
                        if let languageID = objLangauge["Id"],let langaugeName = objLangauge["Name"],let langaugeCode = objLangauge["Code"]{
                            
                            let langauge = ExperienceLangauge.init(langaugeID: "\(languageID)", langaugeName:"\(langaugeName)", langaugeCode: "\(langaugeCode)")
                            self.selectedLangauges.append(langauge)
                        }
                    }
                    DispatchQueue.main.async {
                        self.presentLangaugePicker()
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
    //Post Guide Languages
    func postAPIRequestForGuideLanguages(languageIDs:[String]){
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            let requestURL = "guides/\(currentUser.userID)/native/languages"
            var updateGuideLanguage:[String:Any] = [:]
            updateGuideLanguage["Languages"] = languageIDs
            APIRequestClient.shared.addNewExperience(requestType: .PUT, queryString: requestURL, parameter: updateGuideLanguage as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let _ = successData["UpdateLanguages"],let strMessage = successData["Message"]{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:"\(strMessage)")
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
    //Upload Images
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
    //Remove Profile Image
    func removeImageRequest(){
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
          
            let removeProfileRequest = "users/\(currentUser.userID)/native/userprofileimage"
            APIRequestClient.shared.sendRequest(requestType: .PUT, queryString:removeProfileRequest, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                if let response = responseSuccess as? [String:Any],let successData = response["data"] as? [String:Any],let updatedImageURL = successData["ProfileImageUrl"],let strMSG = successData["Message"]{
                    DispatchQueue.main.async {
                        self.imgProfile.imageFromServerURL(urlString: "https://s3-us-west-2.amazonaws.com/live-placeholder-images/profile.png",placeHolder: #imageLiteral(resourceName: "updatedProfilePlaceholder"))
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
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        //popToBackViewController
        self.popToBackViewController()
    }
    @IBAction func unwindToSettingFromGuideLanguage(segue:UIStoryboardSegue){
        self.configureSelectedLanguage()
    }
    @IBAction func buttonSegmentControllerSelector(sender:UISegmentedControl){
        switch sender.selectedSegmentIndex {
        case 0: //Guide
            self.currentUser!.userType = .guide
            self.guide = true
            self.menuArr = self.arrayOfSettingGuide
            self.currentUser!.setUserDataToUserDefault()
            self.tableviewSetting.reloadData()
            break
        case 1: //Traveler
            self.guide = false
            self.menuArr = self.arrayOfSettingTraveller
            self.currentUser!.userType = .traveller
            self.currentUser!.setUserDataToUserDefault()
            self.tableviewSetting.reloadData()
            break
        default:
            break
        }
        var parameters:[String:Any] = [:]
        parameters["item_name"] = "Setting"
        parameters["username"] = "\(self.currentUser?.userFirstName ?? "") \(self.currentUser?.userLastName ?? "")"
        parameters["userID"] = "\(self.currentUser?.userID ?? "")"
        parameters["userRole"] = "\(self.currentUser?.userType ?? .traveller)"
        CommonClass.shared.addFirebaseAnalytics(parameters: parameters)
        self.addFaceBookAnayltics()
        //self.currentUser!.setUserDataToUserDefault()
//        DispatchQueue.main.async
//            self.configureArrayOnUserRole()
//            self.tableViewMyLive.reloadData()
//        }
    }
    func addFaceBookAnayltics(){
        var parameters:AppEvent.ParametersDictionary = [:]
        parameters["item_name"] = "Setting"
        parameters["username"] = "\(self.currentUser?.userFirstName ?? "") \(self.currentUser?.userLastName ?? "")"
        parameters["userID"] = "\(self.currentUser?.userID ?? "")"
        parameters["userRole"] = "\(self.currentUser?.userType ?? .traveller)"
        CommonClass.shared.addFaceBookAnalytics(eventName:"Setting", parameters: parameters)
    }
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
    
    @IBAction func buttonEditUserNameSelector(sender:UIButton){
        self.presentEditUserName()
    }
    @IBAction func unwindToSettingViewFromChangeUserName(segue:UIStoryboardSegue){
        if User.isUserLoggedIn,let user = User.getUserFromUserDefault(){
            self.lblUserName.text = "\(user.userFirstName) \(user.userLastName)"
        }
        
    }
    @IBAction func unwindToSettingFromSearchLocation(segue:UIStoryboardSegue){
            guard User.isUserLoggedIn else {
                return
            }
            self.currentUser = User.getUserFromUserDefault()
            DispatchQueue.main.async {
                self.configureCurrentUserRole()
                self.tableviewSetting.reloadData()
            }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    //PopToBackViewController
    func popToBackViewController(){
        self.navigationController?.popViewController(animated: true)
    }
}
extension SettingViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingCell = tableView.dequeueReusableCell(withIdentifier: "MenuNameTableViewCell") as! MenuNameTableViewCell
        if guide{
            if self.arrayOfSettingGuide.count > indexPath.row{
                settingCell.menuTitleLbl.text = "\(self.arrayOfSettingGuide[indexPath.row])"
            }
        }else {
            if self.arrayOfSettingTraveller.count > indexPath.row{
                settingCell.menuTitleLbl.text = "\(self.arrayOfSettingTraveller[indexPath.row])"
            }
        }
        
        if indexPath.row == 0{ //Email
            settingCell.accessoryType = .none
            settingCell.lblDetail.isHidden = false
            settingCell.lblDetail.text = "\(self.currentUser!.userEmail)"
            //settingCell.lblDetail.textColor = self.view.tintColor
            settingCell.selectionStyle = .none
            settingCell.detailImg.isHidden = true
            settingCell.detailImg.image = #imageLiteral(resourceName: "information").withRenderingMode(.alwaysOriginal)
            DispatchQueue.main.async {
                settingCell.bottomlblDetail.constant = 16.0
                settingCell.bottomlblDetailImage.constant = 50.0
                settingCell.lblPayPalCheckOut.isHidden = true

            }
        }else if indexPath.row == self.indexOfProvision,self.guide{
            settingCell.accessoryType = .none
            settingCell.lblDetail.isHidden = false
            settingCell.lblDetail.text = "\(self.currentUser!.userProvision)%"
            //settingCell.lblDetail.textColor = self.view.tintColor
            settingCell.selectionStyle = .none
            settingCell.detailImg.isHidden = true
            DispatchQueue.main.async {
                settingCell.bottomlblDetail.constant = 16.0
                settingCell.bottomlblDetailImage.constant = 50.0
                settingCell.lblPayPalCheckOut.isHidden = true

            }
        }else if indexPath.row == self.indexOfPayments{
            settingCell.detailImg.image = #imageLiteral(resourceName: "arrow_gray").withRenderingMode(.alwaysOriginal)
            settingCell.accessoryType = .none
            settingCell.lblDetail.isHidden = false
            settingCell.lblDetail.text = (self.arrayOfCards.count > 0) ? "\(self.arrayOfCards.first!.brand) \(self.arrayOfCards.first!.number)": "No Saved Card"
            if self.arrayOfCards.count > 0{
                 settingCell.lblPayPalCheckOut.isHidden = true
            }else{
                
            }
            settingCell.lblPayPalCheckOut.isHidden = false
            //settingCell.lblDetail.textColor = self.view.tintColor
            settingCell.selectionStyle = .none
            settingCell.detailImg.isHidden = false
            DispatchQueue.main.async {
                settingCell.bottomlblDetail.constant = 40.0
                settingCell.bottomlblDetailImage.constant = 50.0
            }
        }else if indexPath.row == self.indexOfLocation,self.guide{
            settingCell.detailImg.image = #imageLiteral(resourceName: "arrow_gray").withRenderingMode(.alwaysOriginal)
            settingCell.accessoryType = .none
            settingCell.lblDetail.isHidden = false
            settingCell.detailImg.isHidden = false
            settingCell.lblDetail.text = "\(self.currentUser!.userCurrentCity), \(self.currentUser!.userCurrentCountry)"
            //settingCell.lblDetail.textColor = self.view.tintColor
            DispatchQueue.main.async {
                settingCell.bottomlblDetail.constant = 16.0
                settingCell.bottomlblDetailImage.constant = 50.0
                settingCell.lblPayPalCheckOut.isHidden = true

            }
        }else{
            settingCell.detailImg.image = #imageLiteral(resourceName: "arrow_gray").withRenderingMode(.alwaysOriginal)
            settingCell.accessoryType = .none
            settingCell.lblDetail.isHidden = false
            settingCell.detailImg.isHidden = false
            DispatchQueue.main.async {
                settingCell.bottomlblDetail.constant = 25.0
                settingCell.bottomlblDetailImage.constant = 30.0
                settingCell.lblPayPalCheckOut.isHidden = true
            }
            settingCell.menuTitleLbl.text  = ""
            if guide{
                if self.arrayOfSettingGuide.count > indexPath.row{
                    settingCell.lblDetail.text = "\(self.arrayOfSettingGuide[indexPath.row])"
                }
            }else {
                if self.arrayOfSettingTraveller.count > indexPath.row{
                    settingCell.lblDetail.text = "\(self.arrayOfSettingTraveller[indexPath.row])"
                }
            }
        }
        settingCell.tintColor = UIColor.black
        return settingCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == indexOfChangePassword { // Change Password
            if let currentUser = User.getUserFromUserDefault(),currentUser.isFaceBookLogIn{
                return 0
            }else{
                if indexPath.row == self.indexOfPayments{
                    return tableViewRowHeight+20.0
                }else{
                    return tableViewRowHeight

                }
            }
        }else{
            if indexPath.row == self.indexOfPayments{
                return tableViewRowHeight+20.0
            }else{
                return tableViewRowHeight

            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == indexOfChangePassword { // Change Password
            self.pushToChangePassword()
        }
        if indexPath.row == indexOfPayments { // Payments
            self.pushToPaymentViewController()
        }
        if indexPath.row == indexOfBankDetails { // Bank Details
            self.pushToBankDetail()
        }
        if indexPath.row == indexOfDescription { // Description
            self.pushToDiscription()
        }
        if indexPath.row == indexOfLocation { // Location
            DispatchQueue.main.async {
                let becomeGuideAlert = UIAlertController(title: Vocabulary.getWordFromKey(key:"ChangeLocation"), message: Vocabulary.getWordFromKey(key:"ChangeLocation.msg"),preferredStyle: UIAlertControllerStyle.alert)
                becomeGuideAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (action: UIAlertAction!) in
                    self.presentLocationList()
                }))
                becomeGuideAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"no"), style: .cancel, handler: nil))
                becomeGuideAlert.view.tintColor = UIColor(hexString: "#36527D")
                self.present(becomeGuideAlert, animated: false,  completion: nil)
            }
        }
        if indexPath.row == indexOfGuideLanguages{
            //PresentLanguages
            self.getGuideLanguages()
        }
        if indexPath.row == indexOfCouponCode{
            self.pushToCouponCodes()
        }
        if (indexPath.row+1 == self.menuArr.count){
            //History
            self.pushToHistoryController()
        }
        defer{
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    // MARK: - Navigation
    
    func pushToChangePassword(){ //Push To reset password
        if let changePassword = self.storyboard?.instantiateViewController(withIdentifier:"ChangePasswordViewController") as? ChangePasswordViewController {
            self.navigationController?.pushViewController(changePassword, animated: true)
        }
    }
    
    func pushToDiscription(){ //Push To Description
        if let discriptionController = self.storyboard?.instantiateViewController(withIdentifier:"DescriptionViewController") as? DescriptionViewController {
            self.navigationController?.pushViewController(discriptionController, animated: true)
        }
    }
    
    func pushToPaymentViewController() { // Push to Payments
        let storyboard = UIStoryboard(name: "BooknowDetailSB", bundle: nil)
        if let paymentViewController = storyboard.instantiateViewController(withIdentifier: "PaymentViewController") as? PaymentViewController {
            paymentViewController.isFromSettingScreen = true
            self.navigationController?.pushViewController(paymentViewController, animated: true)
        }
    }
    
    func presentLocationList() { // Present SearchCountry
        if let locationPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
        {
            locationPicker.modalPresentationStyle = .overFullScreen
            locationPicker.arrayOfCountry = self.arrayOfCountry
            locationPicker.objSearchType = .City
            locationPicker.isChooseCity = true
            self.present(locationPicker, animated: false, completion: nil)
        }
        /*
        if let locationListViewController = self.storyboard?.instantiateViewController(withIdentifier:"LocationListViewController") as? LocationListViewController {
            present(locationListViewController, animated: false, completion: nil)
        }*/
    }
    
    func pushToBankDetail(){ //Push To Bank Detail
        if let bankDetailController = self.storyboard?.instantiateViewController(withIdentifier:"BankDetailViewController") as? BankDetailViewController {
            self.navigationController?.pushViewController(bankDetailController, animated: true)
        }
    }
    func pushToCouponCodes(){
        if let couponCodeViewController = self.storyboard?.instantiateViewController(withIdentifier: "CouponCodeViewController") as? CouponCodeViewController{
            self.navigationController?.pushViewController(couponCodeViewController, animated: true)
        }
    }
    func pushToHistoryController(){
        if let historyController = self.storyboard?.instantiateViewController(withIdentifier: "HistoryViewController") as? HistoryViewController{
            self.navigationController?.pushViewController(historyController, animated: true)
        }
    }
    func presentEditUserName(){
        if let editUserNameViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditUserNameViewController") as? EditUserNameViewController{
            editUserNameViewController.modalPresentationStyle = .overFullScreen
            self.present(editUserNameViewController, animated: false, completion: nil)
        }
    }
    func presentLangaugePicker(){
        if let langaugePicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
            langaugePicker.modalPresentationStyle = .overFullScreen
            langaugePicker.objSearchType = .Langauge
            langaugePicker.arrayOfLanguage = self.arrayOfLanguage
            if self.selectedLangauges.count > 0{
                var arrayLanID:[String] = []
                for objLan in self.selectedLangauges{
                    arrayLanID.append("\(objLan.langaugeID)")
                }
                langaugePicker.selectedLangauges.addObjects(from: arrayLanID)
            }
            langaugePicker.isGuideLanguage = true
            self.present(langaugePicker, animated: true, completion: nil)
        }
    }
    @IBAction func unwindToLocationList(segue: UIStoryboardSegue) {
        self.viewWillAppear(true)
    }
    
}
extension SettingViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate, CropViewControllerDelegate {
    
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
