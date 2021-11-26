//
//  BecomeGuideViewController.swift
//  Live
//
//  Created by ips on 22/06/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class BecomeGuideViewController: UIViewController,UIGestureRecognizerDelegate {
    
    fileprivate let kGuideLanguage = "LanguageIds"
    fileprivate let kGuideCountry = "Country"
    fileprivate let kGuideCiry = "LocationId"
    fileprivate let kGuideProfile = "Image"
    fileprivate let kGuideId = "UserId"
    fileprivate let kGuideBadge = "BadgeImage"
    fileprivate let kPhoneNumber = "PhoneNumber"
    
    @IBOutlet weak var badgeHintImg: UIImageView!
    @IBOutlet var navTitle: UILabel!
    @IBOutlet var tableGuideSingUp:UITableView!
//    @IBOutlet var viewAddBadge:UIView!
    var selectedCountry:BecomeGuideCountry?
    var arrayOfCountry:[BecomeGuideCountry] = []
    var arrayOfLanguage:[ExperienceLangauge] = []
    var selectedLangauges:[ExperienceLangauge] = []
    var addGuideParameters:[String:Any] = [:]
    var arrayOfCountryDetail:[CountyDetail] = [] //Detail of cities
    var selectedCity:CountyDetail?
    var arrayOfProfileImage:[String] = []
    var arrayOfBadgeImage:[String] = []
    @IBOutlet var lblAddBadge:UILabel!
    @IBOutlet var txtLanguage:TweeActiveTextField!
    @IBOutlet var textOfLanguage:UITextView!
    @IBOutlet var txtCountry:TweeActiveTextField!
    @IBOutlet var textOfCountry:UITextView!
    @IBOutlet var txtLocation:TweeActiveTextField!
    @IBOutlet var textOfLocation:UITextView!
    @IBOutlet var txtGuidePhoneNumber:TweeActiveTextField!
    var phoneDetail:TextFieldDetail?
    var isBadgeImage: Bool = true
//    @IBOutlet var badgeContainerView:UIView!
    @IBOutlet var profileContainerView:UIView!
    @IBOutlet var userProfileImage:ImageViewForURL!
    @IBOutlet var userAddProfileImage:UIButton!
    @IBOutlet var userBadgeImage:ImageViewForURL!
//    @IBOutlet var lblAddBadgeHint:UILabel!
    @IBOutlet var userAddBadgeImage:UIButton!
    @IBOutlet var buttonSave:RoundButton!
    var isForBadge:Bool = false
    var currentUser:User?
    var selectedCountryId: String = ""
    let objectImagePicker:UIImagePickerController = UIImagePickerController()
    var imageForCrop: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userBadgeImage.clipsToBounds = true
        self.userBadgeImage.contentMode = .scaleAspectFill
        self.userProfileImage.layer.borderColor = UIColor.white.cgColor
        self.userProfileImage.layer.borderWidth = 1.5

        self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.width / 2.0
//        self.userBadgeImage.image = #imageLiteral(resourceName: "exprienceplaceholder1").withRenderingMode(.alwaysOriginal)
        self.getLanguages()
        self.configureSignUp()
//        self.configureBezierPath()
        self.tableGuideSingUp.separatorStyle = .none
        self.currentUser = User.getUserFromUserDefault()
        self.userProfileImage.imageFromServerURL(urlString:self.currentUser!.userImageURL,placeHolder:UIImage.init(named:"userplaceholder")!)
        if self.currentUser!.userImageURL.count > 0{
            self.addGuideParameters[kGuideProfile] = "\(self.currentUser!.userImageURL)"
        }
        userProfileImage.contentMode = .scaleAspectFill
        userProfileImage.clipsToBounds = true
        if self.currentUser!.userImageURL != "" {
            self.userAddProfileImage.setImage(#imageLiteral(resourceName: "editprofile_update"), for: .normal)
        } else {
            self.userAddProfileImage.setImage(#imageLiteral(resourceName: "editprofile_update"), for: .normal)
        }
        self.userAddProfileImage.isHidden = false
        self.navTitle.text = Vocabulary.getWordFromKey(key: "BecomeGuide")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .default
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        
        DispatchQueue.main.async {
//            self.addDynamicFont()
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
        self.txtLanguage.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1).pointSize
        self.txtLanguage.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.txtLanguage.adjustsFontForContentSizeCategory = true
        self.textOfLanguage.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        
        self.txtCountry.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1).pointSize
        self.txtCountry.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.txtCountry.adjustsFontForContentSizeCategory = true
        self.textOfCountry.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        
        self.txtLocation.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1).pointSize
        self.txtLocation.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.txtLocation.adjustsFontForContentSizeCategory = true
        self.textOfLocation.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        
        self.buttonSave.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
        self.buttonSave.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonSave.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        
        if self.currentUser!.userImageURL == "" {
            print("no profile pic")
        } else {
            self.arrayOfProfileImage.append("\(self.currentUser!.userImageURL)")
        }
        IQKeyboardManager.shared.previousNextDisplayMode = .Default
    }
    
    func configureSelectedLanguage(){
        if selectedLangauges.count > 0{
            var arrayLanID:[String] = []
            var arrayLanName:[String] = []
            for objLan in selectedLangauges{
                arrayLanID.append("\(objLan.langaugeID)")
                arrayLanName.append("\(objLan.langaugeName)")
            }
            defer{
                self.addGuideParameters[kGuideLanguage] = arrayLanID
                self.textOfLanguage.text = "\(arrayLanName.joined(separator: ", "))"
                self.validTextField(textField: txtLanguage)
            }
            self.txtLanguage.minimizePlaceholder()
        }else{
            self.textOfLanguage.text = ""
            self.txtLanguage.maximizePlaceholder()
        }
    }
    
    func configureSelectedCountry(){
        if let _ = self.selectedCountry{
            self.addGuideParameters[kGuideCountry] = "\(self.selectedCountry!.countyName)"
            self.textOfCountry.text = "\(self.selectedCountry!.countyName)"
            self.validTextField(textField: self.txtCountry)
            self.addGuideParameters[kGuideCiry] = ""
            self.textOfLocation.text = ""
            self.txtGuidePhoneNumber.text = "\(self.selectedCountry!.countryCode) "
            self.txtLocation.maximizePlaceholder()
            self.txtCountry.minimizePlaceholder()
            //GET Locations
            self.getLocationRequestWithCountyID(countryID: "\(self.selectedCountry!.countryID)")
        }else{
            self.txtCountry.maximizePlaceholder()
        }
    }
    
    func configureSelectedLocation(){
        if let _ = self.selectedCity{
            self.txtLocation.minimizePlaceholder()
            self.addGuideParameters[kGuideCiry] = "\(self.selectedCity!.locationID)"
            self.textOfLocation.text = "\(self.selectedCity!.defaultCity)"
            self.validTextField(textField: self.txtLocation)
        }else{
            self.txtLocation.maximizePlaceholder()
            
        }
    }
    
    func configureSignUp(){
//        self.viewAddBadge.clipsToBounds = true
//        self.viewAddBadge.layer.cornerRadius = 20.0
//        self.badgeContainerView.layer.borderColor = UIColor.clear.cgColor
//        self.badgeContainerView.clipsToBounds = true
//        userAddBadgeImage.setImage(#imageLiteral(resourceName: "add").withRenderingMode(.alwaysTemplate), for: .normal)
//        userAddProfileImage.setImage(#imageLiteral(resourceName: "add").withRenderingMode(.alwaysTemplate), for: .normal)
//        self.badgeContainerView.layer.borderColor = UIColor.clear.cgColor
//        self.badgeContainerView.layer.borderWidth = 1.0
        self.objectImagePicker.delegate = self
        self.textOfLanguage.delegate = self
        self.textOfCountry.delegate = self
        self.textOfLocation.delegate = self
        self.lblAddBadge.text = Vocabulary.getWordFromKey(key:"badge.hint")
        self.txtLanguage.tweePlaceholder = Vocabulary.getWordFromKey(key: "language")
        self.txtCountry.tweePlaceholder = Vocabulary.getWordFromKey(key: "Country")
        self.txtLocation.tweePlaceholder = Vocabulary.getWordFromKey(key: "Location")
        self.txtGuidePhoneNumber.tweePlaceholder = Vocabulary.getWordFromKey(key: "phoneNumber.hint")
        self.txtGuidePhoneNumber.textColor = UIColor.black.withAlphaComponent(1.0)
        self.txtGuidePhoneNumber.delegate = self
        self.txtLanguage.textColor = UIColor.black.withAlphaComponent(1.0)
        self.textOfLanguage.textColor = UIColor.black.withAlphaComponent(1.0)
        self.txtLanguage.placeholderColor = UIColor.black.withAlphaComponent(1.0)
        self.txtCountry.textColor = UIColor.black.withAlphaComponent(1.0)
        self.txtCountry.placeholderColor = UIColor.black.withAlphaComponent(1.0)
        self.textOfCountry.textColor = UIColor.black.withAlphaComponent(0.8)
        self.txtLocation.textColor = UIColor.black.withAlphaComponent(0.8)
        self.txtLocation.placeholderColor = UIColor.black.withAlphaComponent(1.0)
        self.textOfLocation.textColor = UIColor.black.withAlphaComponent(1.0)
        self.buttonSave.setTitle(Vocabulary.getWordFromKey(key:"save.title"), for: .normal)
//        self.buttonSave.setBackgroundColor(color: UIColor.lightGray.withAlphaComponent(0.5), forState: .highlighted)
        // self.textOfLanguage.textContainerInset = UIEdgeInsets.zero
        self.textOfLanguage.textContainer.lineFragmentPadding = 0
        // self.textOfCountry.textContainerInset = UIEdgeInsets.zero
        self.textOfCountry.textContainer.lineFragmentPadding = 0
        //self.textOfLocation.textContainerInset = UIEdgeInsets.zero
        self.textOfLocation.textContainer.lineFragmentPadding = 0
        phoneDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "phoneNumber.hint"), text: "", keyboardType: .numberPad, returnKey: .next, isSecure: false)
    }
    
    func validTextField(textField:TweeActiveTextField){
        textField.placeholderColor = UIColor.black
        //textField.lineColor = .white
    }
    
    func invalidTextField(textField:TweeActiveTextField){
        textField.placeholderColor = .red
        //textField.lineColor = .red
        textField.invalideField()
    }
    
    func configureBezierPath(){
//        let path = UIBezierPath()
//        path.move(to: CGPoint.init(x:0, y: self.badgeContainerView.bounds.height))
//        path.addLine(to: CGPoint.init(x:self.badgeContainerView.bounds.width, y: self.badgeContainerView.bounds.height-50.0))
//        path.addLine(to: CGPoint.init(x:self.badgeContainerView.bounds.width, y: self.badgeContainerView.bounds.height))
//        path.close()
//        let layer = CAShapeLayer()
//        layer.path = path.cgPath
//        layer.strokeColor = UIColor.init(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0).cgColor//UIColor.lightGray.cgColor
//        layer.fillColor = UIColor.init(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0).cgColor
//        layer.lineWidth = 0.0
//        self.badgeContainerView.layer.addSublayer(layer)
//        self.profileContainerView.layer.cornerRadius = 50.0
//        self.profileContainerView.clipsToBounds = true
//        self.userProfileImage.layer.cornerRadius = 44.0
//        self.userProfileImage.clipsToBounds = true
    }
    
    func isValidGuideRequest()->Bool{
        
        guard self.arrayOfBadgeImage.count > 0 else{
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "BadgeImageValidation"))
            }
            return false
        }
        guard self.arrayOfProfileImage.count > 0 else{
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "ProfileImageValidation"))
            }
            return false
        }
        guard let guideLanguage = self.addGuideParameters[kGuideLanguage] as? [String],guideLanguage.count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtLanguage)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "langaugeValidation"))
            }
            return false
        }
        guard let guideCountry = self.addGuideParameters[kGuideCountry] as? String,guideCountry.count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtCountry)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "selectCountry"))
            }
            return false
        }
        guard let guideCity = self.addGuideParameters[kGuideCiry] as? String,guideCity.count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtLocation)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "locationValidation"))
            }
            return false
        }
        return true
    }
    
    func presentCountyPicker(){
        if let currencyPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
            currencyPicker.modalPresentationStyle = .overFullScreen
            currencyPicker.arrayOfGuideCountry = self.arrayOfCountry
            currencyPicker.objSearchType = .Country
            currencyPicker.isBecomeGuideCountry = true
            self.view.endEditing(true)
            self.present(currencyPicker, animated: false, completion: nil)
        }
    }
    
    // MARK: - API Request Methods
    
    //Guide SignUp
    func becomeGuideRequest(){
        let currentUser: User? = User.getUserFromUserDefault()
        let userId: String = (currentUser?.userID)!
        self.addGuideParameters[self.kGuideId] = "\(userId)"
        print(self.addGuideParameters)
        APIRequestClient.shared.addNewExperience(requestType: .POST, queryString: kBecomeGuide, parameter: self.addGuideParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let strMSG = successData["Message"]{
                
                let backAlert = UIAlertController(title: Vocabulary.getWordFromKey(key: "BecomeGuide"), message:"\(strMSG)",preferredStyle: UIAlertControllerStyle.alert)
                backAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (action: UIAlertAction!) in
                    currentUser?.guideRequestStatus = "1"
                    currentUser?.setUserDataToUserDefault()
                    //PopToBackViewController
                    self.navigationController?.popViewController(animated: false)
                }))
                self.view.endEditing(true)
                backAlert.view.tintColor = UIColor.init(hexString:"36527D")
                self.present(backAlert, animated: true, completion: nil)
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
                    //ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
    }

    func getBecomeGuideCountries() {  // Get Country list
        APIRequestClient.shared.getCoutriesWithExperience(requestType: .GET, queryString: kBecomGuideCountries, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let arraySuccess = successDate["country"] as? NSArray{
                self.arrayOfCountry = []
                for objCountry in arraySuccess{
                    if let _ = objCountry as? [String:Any]{
                        let countryDetail = BecomeGuideCountry.init(objJSON: objCountry as! [String : Any])
                        self.arrayOfCountry.append(countryDetail)
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
                   // ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
    }
    
    //Get Cities
    func getLocationRequestWithCountyID(countryID:String){
        
        let requestURL = "\(kCityLocations)\(countryID)"
        
        APIRequestClient.shared.getCitiesOnCountyID(requestType: .GET, queryString: requestURL, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let arraySuccess = successDate["location"] as? NSArray{
                self.arrayOfCountryDetail = []
                for objCountry in arraySuccess{
                    if let jsonCountry = objCountry as? [String:Any]{
                        let countryDetail = CountyDetail.init(objJSON: jsonCountry)
                        self.arrayOfCountryDetail.append(countryDetail)
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
                    //ShowToast.show(toatMessage:kCommonError)
                }
            }
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
            langaugePicker.isBecomeGuideLanguage = true
            self.view.endEditing(true)
            self.present(langaugePicker, animated: true, completion: nil)
        }
    }
    
    func presentCityPicker(){
        guard let _ = self.selectedCountry else {
            self.invalidTextField(textField: self.txtCountry)
            let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"guideRequest.title"), message: Vocabulary.getWordFromKey(key:"selectCountry"), preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler:nil))
            self.view.endEditing(true)
            alertController.view.tintColor = UIColor.init(hexString:"36527D")
            self.present(alertController, animated: true, completion: nil)
            return
        }
        if let currencyPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
        {
            currencyPicker.modalPresentationStyle = .overFullScreen
            currencyPicker.arrayOfCountry = self.arrayOfCountryDetail
            currencyPicker.objSearchType = .City
            currencyPicker.isBecomeGuideLocation = true
            self.view.endEditing(true)
            self.present(currencyPicker, animated: false, completion: nil)
        }
    }
    
    func getLanguages(){ //Get Languages
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
                    //ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
        defer{
            self.getBecomeGuideCountries()
        }
    }

    //Upload Profile
    func uploadGuideProfileRequest(imageData:Data,imageName:String){
        let parameters = [
            "file_name": "\(imageName)"
        ]
        APIRequestClient.shared.uploadImage(requestType: .POST, queryString: kGuideUploadImage, parameter: parameters as [String : AnyObject], imageData: imageData, isHudeShow: true, success: { (sucessResponse) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if let success = sucessResponse as? [String:Any],let successData = success["data"] as?  [String:Any],let uploadedImageURL = successData["ImageUrl"]{
                self.arrayOfProfileImage = []
                self.userAddProfileImage.isHidden = false
                self.arrayOfProfileImage.append("\(uploadedImageURL)")
                DispatchQueue.main.async {
                    self.userProfileImage.imageFromServerURL(urlString: "\(uploadedImageURL)")
                    self.userAddProfileImage.setImage(#imageLiteral(resourceName: "editprofile_update"), for: .normal)
                    self.addGuideParameters[self.kGuideProfile] = "\(uploadedImageURL)"

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
    //Upload Badge
    func uploadBadgeRequest(imageData:Data,imageName:String){
        let parameters = [
            "file_name": "\(imageName)"
        ]
        APIRequestClient.shared.uploadImage(requestType: .POST, queryString: kGuideBadgeUploadImage, parameter: parameters as [String : AnyObject], imageData: imageData, isHudeShow: true, success: { (sucessResponse) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if let success = sucessResponse as? [String:Any],let successData = success["data"] as?  [String:Any],let uploadedImageURL = successData["ImageUrl"]{
                self.arrayOfBadgeImage = []
                self.arrayOfBadgeImage.append("\(uploadedImageURL)")
                self.addGuideParameters[self.kGuideBadge] = "\(uploadedImageURL)"
                //                self.lblAddBadgeHint.text = Vocabulary.getWordFromKey(key: "ChangeBadge.hint")
                self.badgeHintImg.isHidden = true
                self.lblAddBadge.isHidden = true
                self.userBadgeImage.contentMode = .scaleAspectFill
                self.userBadgeImage.clipsToBounds = true
                DispatchQueue.main.async {
                    self.userBadgeImage.image = self.imageForCrop
                    self.userAddBadgeImage.setImage(#imageLiteral(resourceName: "editprofile_update"), for: .normal)
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
    
    func openImagePicker(){
        var hintStr: String = ""
        if self.isBadgeImage {
            hintStr = Vocabulary.getWordFromKey(key:"update_badge")
        } else {
            hintStr = Vocabulary.getWordFromKey(key:"updateprofilePic.hint")
        }
        let actionSheet = UIAlertController.init(title:"", message: hintStr, preferredStyle: .actionSheet)
        let cancel = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler: nil)
            actionSheet.addAction(cancel)
            let photoLiberary = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Photos"), style: .default) { (_) in
                self.objectImagePicker.sourceType = .photoLibrary
                self.view.endEditing(true)
                self.present(self.objectImagePicker, animated: true, completion: nil)
            }
            actionSheet.addAction(photoLiberary)
            let camera = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Camera"), style: .default) { (_) in
                if CommonClass.isSimulator{
                    DispatchQueue.main.async {
                        let noCamera = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"Cameranotsupported"), message: "", preferredStyle: .alert)
                        noCamera.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .cancel, handler: nil))
                        self.view.endEditing(true)
                        self.present(noCamera, animated: true, completion: nil)
                    }
                }else{
                    self.objectImagePicker.sourceType = .camera
                    self.present(self.objectImagePicker, animated: true, completion: nil)
                }
            }
            actionSheet.view.tintColor = UIColor.init(hexString: "36527D")
            actionSheet.addAction(camera)
            self.present(actionSheet, animated: true, completion: nil)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView)->Bool{
        DispatchQueue.main.async {
            if textView == self.textOfLanguage{
                self.textOfLanguage.resignFirstResponder()
                //PresentLanguagePicker
                self.presentLangaugePicker()
            }else if textView == self.textOfCountry{
                self.textOfCountry.resignFirstResponder()
                //PresentCountryPicker
                self.presentCountyPicker()
            }else if textView == self.textOfLocation{
                self.textOfLocation.resignFirstResponder()
                //PresentLanguagePicker
                self.presentCityPicker()
            }
            defer{
                self.view.endEditing(true)
            }
        }
        return false
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
    
    // MARK: - Navigation
    @IBAction func unwindToBecomeGuideFromLangauge(segue:UIStoryboardSegue){
        DispatchQueue.main.async {
            self.configureSelectedLanguage()
        }

    }
    @IBAction func unwindToBecomeGuideFromCounty(segue:UIStoryboardSegue){
        DispatchQueue.main.async {
            self.configureSelectedCountry()
        }
 
    }
    @IBAction func unwindToBecomeGuideFromLocation(segue:UIStoryboardSegue){
        DispatchQueue.main.async {
            self.configureSelectedLocation()
        }

    }
    
    // MARK: - UITextFieldDelegate
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        return true
//    }
    
    // MARK: - Selector Methods
    @IBAction func buttonHideKeyboardSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    @IBAction func buttonAddProfileSelector(sender:UIButton){
            self.isBadgeImage = false
            self.objectImagePicker.view.tag = 1
            self.objectImagePicker.allowsEditing = false
            self.openImagePicker()
    }
    
    @IBAction func btnBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: false)
    }

    @IBAction func buttonAddBadgeSelector(sender:UIButton){
        self.isBadgeImage = true
        self.objectImagePicker.view.tag = 2
        self.objectImagePicker.allowsEditing = false
        self.openImagePicker()
    }
    
    @IBAction func buttonSaveSelector(sender:UIButton){
        if self.isValidGuideRequest(){
            
            if let _ = self.phoneDetail,let _ = self.selectedCity{
                
                if self.phoneDetail!.text.count > 0,self.phoneDetail!.text != self.selectedCity!.countryCode{
                    self.addGuideParameters[kPhoneNumber] =  "\(self.phoneDetail!.text)"
                }
            }
            
            let confirmationAlert = UIAlertController(title: Vocabulary.getWordFromKey(key: "BecomeGuide"), message: Vocabulary.getWordFromKey(key: "guideRequest.message"),preferredStyle: UIAlertControllerStyle.alert)
            confirmationAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"agreeBtn"), style: .default, handler: { (action: UIAlertAction!) in
                self.becomeGuideRequest()
            }))
            let cancelSelector = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler:nil)
            confirmationAlert.addAction(cancelSelector)
            confirmationAlert.view.tintColor = UIColor.init(hexString:"36527D")
            self.present(confirmationAlert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension BecomeGuideViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        if textField != self.txtGuidePhoneNumber!{
            guard !typpedString.isContainWhiteSpace() else{
                return false
            }
        }
        //(textField as? TweeActiveTextField)?.placeholderColor = UIColor.darkGray
        if(textField == self.txtGuidePhoneNumber!){
            if let _ = self.selectedCountry{
                if typpedString == self.selectedCountry!.countryCode{
                    return false
                }
                if typpedString.count > 20 {
                    return false
                }
            }
            self.phoneDetail?.text = typpedString
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
         if(textField == self.txtGuidePhoneNumber){
            self.phoneDetail?.text = ""
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtGuidePhoneNumber{
            if let _ = self.selectedCountry{
                return true
            }else{
                return false
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.txtGuidePhoneNumber{
            guard self.phoneDetail!.text.count > 0 else{
                //self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .red)
                textField.invalideField()
                return false
            }
            return true
        }

        return true
    }
    func updateActiveLine(textfield:TweeActiveTextField,color:UIColor){
        textfield.activeLineColor = color
        textfield.lineColor = color
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        defer {
            if let text = textField.text,text.count > 0{
                self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .black)
            }
        }
    }
}
extension BecomeGuideViewController:UITextViewDelegate{
    func textViewShouldEndEditing(_ textView: UITextView)->Bool{
        DispatchQueue.main.async {
            
            if textView == self.textOfLanguage{
                if textView.text.count == 0{
                    self.textOfLanguage.resignFirstResponder()
                    self.txtLanguage.maximizePlaceholder()
                    // textView.resignFirstResponder()
                }else{
                    self.txtLanguage.minimizePlaceholder()
                }
            }else if textView == self.textOfCountry{
                if textView.text.count == 0{
                    self.textOfCountry.resignFirstResponder()
                    self.txtCountry.maximizePlaceholder()
                    //textView.resignFirstResponder()
                }else{
                    self.txtCountry.minimizePlaceholder()
                }
            }else if textView == self.textOfLocation{
                if textView.text.count == 0{
                    self.textOfLocation.resignFirstResponder()
                    self.txtLocation.maximizePlaceholder()
                    //textView.resignFirstResponder()
                }else{
                    self.txtLocation.minimizePlaceholder()
                }
            }

        }
        return false
    }
}

extension BecomeGuideViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate, CropViewControllerDelegate{
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage) {
        let imageData = image.jpeg(.lowest)
        if self.objectImagePicker.view.tag == 2 { // Badge
            self.uploadBadgeRequest(imageData: imageData!, imageName:"image")
        } else {
            self.uploadGuideProfileRequest(imageData: imageData!, imageName: "image")
        }
    }
    
    func cropViewController(_ controller: CropViewController, didFinishCroppingImage image: UIImage, transform: CGAffineTransform, cropRect: CGRect) {
        controller.dismiss(animated: false, completion: nil)
        if self.objectImagePicker.view.tag == 2 { // Badge
        self.userBadgeImage.contentMode = .scaleAspectFill
        self.userBadgeImage.clipsToBounds = true
//        self.userBadgeImage.image = image
        } else {
        }
    }
    
    func cropViewControllerDidCancel(_ controller: CropViewController) {
        controller.dismiss(animated: false, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                dismiss(animated: false, completion: nil)
                return
            }
            self.imageForCrop = image
            dismiss(animated: false) { [unowned self] in
                self.openEditor(nil, pickingViewTag: picker.view.tag)
            }
    }
}
