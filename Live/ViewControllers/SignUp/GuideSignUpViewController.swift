//
//  GuideSignUpViewController.swift
//  Live
//
//  Created by IPS on 20/06/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class GuideSignUpViewController: UIViewController,UIGestureRecognizerDelegate {

    fileprivate let kGuideFirstName = "FirstName"
    fileprivate let kGuideLastName = "LastName"
    fileprivate let kGuideEmail = "Email"
    fileprivate let kGuideGender = "Gender"
    fileprivate let kGuideGenderOptions = "GenderCustom"
    fileprivate let kGuideLanguage = "LanguageIds"
    fileprivate let kGuideCountry = "Country"
    fileprivate let kGuideCiry = "LocationId"
    fileprivate let kGuideProfile = "Image"
    fileprivate let kGuideBadge = "BadgeImage"
    fileprivate let kPhoneNumber = "PhoneNumber"
    
    @IBOutlet var lblAddBadge:UILabel!
    @IBOutlet weak var badgeHintImg: UIImageView!
    @IBOutlet var buttonForgroundShadow:UIButton!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var tableGuideSingUp:UITableView!
    @IBOutlet var txtFirstName:TweeActiveTextField!
    @IBOutlet var txtLastName:TweeActiveTextField!
    @IBOutlet var txtLanguage:TweeActiveTextField!
    @IBOutlet var textOfLanguage:UITextView!
    @IBOutlet var txtCountry:TweeActiveTextField!
    @IBOutlet var textOfCountry:UITextView!
    @IBOutlet var txtLocation:TweeActiveTextField!
    @IBOutlet var textOfLocation:UITextView!
    @IBOutlet var buttonSave:RoundButton!
    @IBOutlet var badgeContainerView:UIView!
    
//    @IBOutlet var profileContainerView:UIView!
    @IBOutlet var userProfileImage:ImageViewForURL!
    @IBOutlet var userAddProfileImage:UIButton!
    @IBOutlet var userBadgeImage:ImageViewForURL!
//    @IBOutlet var lblAddBadgeHint:UILabel!
    @IBOutlet var userAddBadgeImage:UIButton!
    @IBOutlet var viewAddBadge:UIView!
    @IBOutlet var txtGuidePhoneNumber:TweeActiveTextField!
    
    var imageForCrop: UIImage!
    
    var arrayOfSignUp:[TextFieldDetail] = []
    var firstNameDetail:TextFieldDetail?
    var lastNameDetail:TextFieldDetail?
    var genderDetail:TextFieldDetail?
    var customGenderDetail:TextFieldDetail?
    var emailDetail:TextFieldDetail?
    var phoneDetail:TextFieldDetail?
    var arrayOfLanguage:[ExperienceLangauge] = []
    var selectedLangauges:[ExperienceLangauge] = []
    var arrayOfCountry:[BecomeGuideCountry] = []
    var selectedCountry:BecomeGuideCountry?
    var arrayOfCountryDetail:[CountyDetail] = [] //Detail of cities
    var selectedCity:CountyDetail?
    var addGuideParameters:[String:Any] = [:]
    var arrayOfProfileImage:[String] = []
    var arrayOfBadgeImage:[String] = []
    var genderToolBar:UIToolbar = UIToolbar()
    var isBadgeImage: Bool = true

    let genderType:[String] = ["\(Vocabulary.getWordFromKey(key: "male"))", "\(Vocabulary.getWordFromKey(key: "female"))", "\(Vocabulary.getWordFromKey(key: "others"))"]
    var selectedGender:String = "\(Vocabulary.getWordFromKey(key: "male"))"
    let heightOfTableViewCell:CGFloat = 65.0
    let objectImagePicker:UIImagePickerController = UIImagePickerController()
    let alertTitleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17.0)!]
    let alertMessageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
    var customGender:Bool = false
    var isCustomGender:Bool{
        get{
            return customGender
        }
        set{
            self.customGender = newValue
            self.configureCustomGender()
        }
    }
    var indexOfEmail:Int{
        get{
            return isCustomGender ? 2 : 1
        }
    }
    var genderPicker:UIPickerView = UIPickerView.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.userBadgeImage.contentMode = .scaleAspectFill
        self.userProfileImage.layer.borderColor = UIColor.white.cgColor
        self.userProfileImage.layer.borderWidth = 1.5
        self.userProfileImage.clipsToBounds = true
        self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.width / 2.0
//        self.userBadgeImage.image = #imageLiteral(resourceName: "expriencePlaceholder").withRenderingMode(.alwaysOriginal)
        self.getLanguages()
        self.configureSignUp()
//        self.configureBezierPath()
        self.configureTableView()
        self.sizeFooterToFit()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .default
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"QualifiedGuideRequest")
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        self.swipeToPop()
//        DispatchQueue.main.async {
//            self.addDynamicFont()
//        }
    }
    func swipeToPop() {
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func configureGenderToolBar(){
        self.genderToolBar.sizeToFit()
        self.genderToolBar.tintColor = UIColor.init(hexString:"36527D")
        
        //self.genderToolBar.layer.borderColor = UIColor.darkGray.cgColor
//        self.genderToolBar.layer.borderWidth = 1.0
        self.genderToolBar.clipsToBounds = true
        self.genderToolBar.backgroundColor = UIColor.white
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(SignUpViewController.doneGenderPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "\(Vocabulary.getWordFromKey(key:"gender.title"))", attributes:[NSAttributedStringKey.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(SignUpViewController.cancelGenderPicker))
        self.genderToolBar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
    }
    
    @objc func doneGenderPicker(){
//        self.selectedGender = self.currentGender
        DispatchQueue.main.async {
            self.buttonForgroundShadow.isHidden = true
            self.view.endEditing(true)
        }
    }
    
    @objc func cancelGenderPicker(){
        //cancel button dismiss datepicker dialog
        DispatchQueue.main.async {
            self.buttonForgroundShadow.isHidden = true
            self.view.endEditing(true)
        }
    }
    
    func addDynamicFont(){
        self.lblTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblTitle.adjustsFontForContentSizeCategory = true
        self.lblTitle.adjustsFontSizeToFitWidth = true
        
//        self.lblAddBadgeHint.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
//        self.lblAddBadgeHint.adjustsFontForContentSizeCategory = true
//        self.lblAddBadgeHint.adjustsFontSizeToFitWidth = true
        
        self.txtFirstName.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1).pointSize
        self.txtFirstName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtFirstName.adjustsFontForContentSizeCategory = true
        
        self.txtLastName.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1).pointSize
        self.txtLastName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtLastName.adjustsFontForContentSizeCategory = true
        
        self.txtLanguage.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1).pointSize
        self.txtLanguage.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtLanguage.adjustsFontForContentSizeCategory = true
        
        self.txtCountry.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1).pointSize
        self.txtCountry.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtCountry.adjustsFontForContentSizeCategory = true
        
        self.txtLocation.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1).pointSize
        self.txtLocation.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtLocation.adjustsFontForContentSizeCategory = true
        
        self.buttonSave.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonSave.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonSave.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        IQKeyboardManager.shared.previousNextDisplayMode = .Default
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
    func configureBezierPath(){
        let path = UIBezierPath()
        path.move(to: CGPoint.init(x:0, y: self.badgeContainerView.bounds.height))
        path.addLine(to: CGPoint.init(x:self.badgeContainerView.bounds.width, y: self.badgeContainerView.bounds.height-50.0))
        path.addLine(to: CGPoint.init(x:self.badgeContainerView.bounds.width, y: self.badgeContainerView.bounds.height))
        path.close()
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.strokeColor = UIColor.init(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0).cgColor//UIColor.lightGray.cgColor
        layer.fillColor = UIColor.init(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0).cgColor
        layer.lineWidth = 0.0
        self.badgeContainerView.layer.addSublayer(layer)
//        self.profileContainerView.layer.cornerRadius = 50.0
//        self.profileContainerView.clipsToBounds = true
        self.userProfileImage.contentMode = .scaleAspectFill
        self.userProfileImage.layer.cornerRadius = 44.0
        self.userProfileImage.clipsToBounds = true
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
    
    func configureCustomGender(){
        if self.isCustomGender{
            //self.arrayOfSignUp = [firstNameDetail!,lastNameDetail!,genderDetail!,customGenderDetail!,emailDetail!,passwordDetail!,confirmPasswordDetail!,birthDayDetail!]
            self.arrayOfSignUp = [genderDetail!,customGenderDetail!,emailDetail!]
        }else{
            //self.arrayOfSignUp = [firstNameDetail!,lastNameDetail!,genderDetail!,emailDetail!,passwordDetail!,confirmPasswordDetail!,birthDayDetail!]
            self.arrayOfSignUp = [genderDetail!,emailDetail!]
        }
        self.tableGuideSingUp.reloadData()
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
            DispatchQueue.main.async {
                self.textOfLanguage.text = ""
                self.txtLanguage.maximizePlaceholder()
            }
        }
        defer{
            self.sizeFooterToFit()
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
        defer{
            self.sizeFooterToFit()
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
        defer{
            self.sizeFooterToFit()
        }
    }
    func configureSignUp(){
        self.configureGenderToolBar()
        self.viewAddBadge.clipsToBounds = true
        self.viewAddBadge.layer.cornerRadius = 20.0
        self.badgeContainerView.layer.borderColor = UIColor.clear.cgColor
        self.badgeContainerView.layer.borderWidth = 1.0
        self.badgeContainerView.clipsToBounds = true
        userAddBadgeImage.setImage(#imageLiteral(resourceName: "editprofile_update"), for: .normal)
        userAddProfileImage.setImage(#imageLiteral(resourceName: "editprofile_update"), for: .normal)
        self.objectImagePicker.delegate = self
        genderPicker.delegate = self
        genderPicker.dataSource = self
        self.textOfLanguage.delegate = self
        self.textOfCountry.delegate = self
        self.textOfLocation.delegate = self
        self.txtFirstName.textColor = UIColor.black.withAlphaComponent(1.0)
        self.txtFirstName.placeholderColor = UIColor.black.withAlphaComponent(1.0)
        self.txtLastName.textColor = UIColor.black.withAlphaComponent(1.0)
        self.txtLastName.placeholderColor = UIColor.black.withAlphaComponent(1.0)
        self.lblAddBadge.text = Vocabulary.getWordFromKey(key:"badge.hint")
        self.txtFirstName.tweePlaceholder = Vocabulary.getWordFromKey(key: "firstName.title")
        self.txtLastName.tweePlaceholder  = Vocabulary.getWordFromKey(key: "lastName.title")
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
        self.textOfCountry.textColor = UIColor.black.withAlphaComponent(1.0)
        self.txtLocation.textColor = UIColor.black.withAlphaComponent(1.0)
        self.txtLocation.placeholderColor = UIColor.black.withAlphaComponent(1.0)
        self.textOfLocation.textColor = UIColor.black.withAlphaComponent(1.0)
        self.buttonSave.setTitle(Vocabulary.getWordFromKey(key:"save.title"), for: .normal)
//        self.buttonSave.setBackgroundColor(color: UIColor.lightGray.withAlphaComponent(1.0), forState: .highlighted)
       // self.textOfLanguage.textContainerInset = UIEdgeInsets.zero
        self.textOfLanguage.textContainer.lineFragmentPadding = 0
       // self.textOfCountry.textContainerInset = UIEdgeInsets.zero
        self.textOfCountry.textContainer.lineFragmentPadding = 0
        //self.textOfLocation.textContainerInset = UIEdgeInsets.zero
        self.textOfLocation.textContainer.lineFragmentPadding = 0
        firstNameDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "firstName.title"), text: "", keyboardType: .default, returnKey: .next, isSecure: false)
        lastNameDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "lastName.title"), text: "", keyboardType: .default, returnKey: .next, isSecure: false)
        genderDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "gender.title"), text: "\(selectedGender)", keyboardType: .default, returnKey: .next, isSecure: false)
        emailDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "email.placeholder"), text: "", keyboardType: .emailAddress, returnKey: .next, isSecure: false)
        customGenderDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "specifyGender"), text: "", keyboardType: .default, returnKey: .next, isSecure: false)
        phoneDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "phoneNumber.hint"), text: "", keyboardType: .numberPad, returnKey: .next, isSecure: false)
        self.arrayOfSignUp = [genderDetail!,emailDetail!]
        
    }
    func configureTableView(){
       // self.tableGuideSingUp.rowHeight = UITableViewAutomaticDimension
        //self.tableGuideSingUp.estimatedRowHeight = 50.0
        self.tableGuideSingUp.delegate = self
        self.tableGuideSingUp.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "LogInTableViewCell", bundle: nil)
        self.tableGuideSingUp.register(objNib, forCellReuseIdentifier: "LogInTableViewCell")
        // self.tableViewLogIn.tableFooterView = self.tableViewFooterView
        self.tableGuideSingUp.separatorStyle = .none
        self.tableGuideSingUp.reloadData()
    }
    func invalidTextField(textField:TweeActiveTextField){
        textField.placeholderColor = .red
        //textField.lineColor = .red
        textField.invalideField()
    }
    func validTextField(textField:TweeActiveTextField){
        textField.placeholderColor = UIColor.black
        //textField.lineColor = .white
    }
    func isValidGuideRequest()->Bool{
        let emailCell:LogInTableViewCell = self.tableGuideSingUp.cellForRow(at: IndexPath.init(row: indexOfEmail, section: 0)) as! LogInTableViewCell
      
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
        guard self.firstNameDetail!.text.count > 0 else{
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFirstName)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "firstNameValidation"))
            }
            return false
        }
        guard self.lastNameDetail!.text.count > 0 else{
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtLastName)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "lastNameValidation"))
            }
            return false
        }
        guard emailDetail!.text.count > 0 else{
            DispatchQueue.main.async {
                self.invalidTextField(textField: emailCell.textFieldLogIn)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "enterEmail.title"))
            }
            return false
        }
        guard emailDetail!.text.isValidEmail() else{
            DispatchQueue.main.async {
                self.invalidTextField(textField: emailCell.textFieldLogIn)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "pleaseEnterValidEmail.title"))
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
   
    func sizeFooterToFit() {
        if let footerView =  self.tableGuideSingUp.tableFooterView {
            footerView.setNeedsLayout()
            footerView.layoutIfNeeded()
            
            let height = footerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var frame = footerView.frame
            frame.size.height = height
            footerView.frame = frame
            self.tableGuideSingUp.tableFooterView = footerView
        }
    }
    // MARK: - API Request Methods
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
        defer{
            self.getBecomeGuideCountries()
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
                    ShowToast.show(toatMessage:kCommonError)
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
    //Guide SignUp
    func guideSignUpRequest(){
        
        APIRequestClient.shared.addNewExperience(requestType: .POST, queryString: kGuideRequest, parameter: self.addGuideParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let _ = successData["GuideRequest"],let strMSG = successData["Message"]{
                DispatchQueue.main.async {
                    let backAlert = UIAlertController(title: Vocabulary.getWordFromKey(key: "guideRequest.title"), message:"\(strMSG)",preferredStyle: UIAlertControllerStyle.alert)
                    backAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (action: UIAlertAction!) in
                        //PopToBackViewController
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(backAlert, animated: true, completion: nil)
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }) { (responseFail) in
            if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"],let errorCode = fail["ErrorCode"]{
                if "\(errorCode)" == "4110"{
                    let backAlert = UIAlertController(title: Vocabulary.getWordFromKey(key: "passwordRicovery.hint"), message: Vocabulary.getWordFromKey(key: "passwordRicoveryMSG.hint"),preferredStyle: UIAlertControllerStyle.alert)
                    backAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"recover.hint"), style: .default, handler: { (action: UIAlertAction!) in
                        if let objEmailDetail = self.emailDetail{
                            self.resetPasswordAPIRequestWithEmail(email: objEmailDetail.text)
                        }
                    }))
                    self.view.endEditing(true)
                    let titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key: "passwordRicovery.hint"), attributes: self.alertTitleFont)
                    let messageAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key: "passwordRicoveryMSG.hint"), attributes: self.alertMessageFont)
                    
                    backAlert.setValue(titleAttrString, forKey: "attributedTitle")
                    backAlert.setValue(messageAttrString, forKey: "attributedMessage")
                    backAlert.addAction(UIAlertAction.init(title:  Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler: nil))
                    backAlert.view.tintColor = UIColor(hexString: "#36527D")
                    self.present(backAlert, animated: true, completion: nil)
                }else{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: "\(errorMessage)")
                    }
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
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
                self.arrayOfProfileImage.append("\(uploadedImageURL)")
                self.addGuideParameters[self.kGuideProfile] = "\(uploadedImageURL)"
                self.userAddProfileImage.isHidden = false
                DispatchQueue.main.async {
                    self.userProfileImage.imageFromServerURL(urlString: "\(uploadedImageURL)")
                    self.userAddProfileImage.setImage(#imageLiteral(resourceName: "editprofile_update"), for: .normal)
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
    func resetPasswordAPIRequestWithEmail(email:String){
        let requestParam = ["Email":"\(email)"] as [String:AnyObject]
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kRecoveryCode , parameter: requestParam, isHudeShow: true, success: { (responseSuccess) in
            if  let successJSON = responseSuccess as? [String:Any],let successdata = successJSON["data"] as? [String:Any],let _ = successdata["RecoverCodeLength"],let message = successdata["Message"] as? String{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:message)
                    //PopToBackViewController
                    self.navigationController?.popViewController(animated: true)
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
    // MARK: - Selector Methods
    @IBAction func buttonHideKeyboardSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    @IBAction func buttonBackSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonSaveSelector(sender:UIButton){
        if self.isValidGuideRequest(){
            self.addGuideParameters[kGuideFirstName] = "\(self.firstNameDetail!.text)"
            self.addGuideParameters[kGuideLastName] = "\(self.lastNameDetail!.text)"
            self.addGuideParameters[kGuideGender] = "\(self.selectedGender)"
            self.addGuideParameters[kGuideGenderOptions] = "\(self.customGenderDetail!.text)"
            self.addGuideParameters[kGuideEmail] = "\(self.emailDetail!.text)"
            if let _ = self.phoneDetail,let _ = self.selectedCity{
                if self.phoneDetail!.text.count > 0,self.phoneDetail!.text != self.selectedCity!.countryCode{
                    self.addGuideParameters[kPhoneNumber] =  "\(self.phoneDetail!.text)"
                }
            }
            self.guideSignUpRequest()
        }
    }
    @IBAction func buttonAddBadgeSelector(sender:UIButton){
        self.objectImagePicker.allowsEditing = false
        self.objectImagePicker.view.tag = 2
        self.isBadgeImage = true
        self.openImagePicker()
    }
    @IBAction func buttonAddProfileSelector(sender:UIButton){
        self.objectImagePicker.allowsEditing = false
        self.objectImagePicker.view.tag = 1
        self.isBadgeImage = false
        self.openImagePicker()
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
        actionSheet.view.tintColor = UIColor.init(hexString: "36527D")
        actionSheet.addAction(camera)
        self.present(actionSheet, animated: true, completion: nil)
    }
    @IBAction func unwindToGuideRequestFromLangauge(segue:UIStoryboardSegue){
        DispatchQueue.main.async {
            self.configureSelectedLanguage()
        }
        defer{
            self.tableGuideSingUp.scrollToBottom(animated: true)
        }
    }
    @IBAction func unwindToGuideRequestFromCounty(segue:UIStoryboardSegue){
        DispatchQueue.main.async {
            self.configureSelectedCountry()
        }
        defer{
            self.tableGuideSingUp.scrollToBottom(animated: true)
        }
    }
    @IBAction func unwindToGuideRequestFromLocation(segue:UIStoryboardSegue){
        DispatchQueue.main.async {
            self.configureSelectedLocation()
        }
        defer{
            self.tableGuideSingUp.scrollToBottom(animated: true)
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
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
            langaugePicker.isGuideRequestLanguage = true
            self.view.endEditing(true)
            self.present(langaugePicker, animated: true, completion: nil)
        }
    }
    func presentCountyPicker(){
        if let currencyPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
        {
            currencyPicker.modalPresentationStyle = .overFullScreen
            currencyPicker.arrayOfGuideCountry = self.arrayOfCountry
            currencyPicker.objSearchType = .Country
            currencyPicker.isGuideCountry = true
            currencyPicker.noCountryDelegate = self
            self.view.endEditing(true)
            self.present(currencyPicker, animated: false, completion: nil)
        }
    }
    func pushToInquitry(){
        if let inquiryController = self.storyboard?.instantiateViewController(withIdentifier: "InquiryViewController") as? InquiryViewController {
            self.navigationController?.pushViewController(inquiryController, animated: true)
        }
        /*
        let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"noCountry.hint"), message: Vocabulary.getWordFromKey(key: "dearAll"), preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"sendInformation.hint"), style: .default, handler: { (_) in
        }))
        alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"OK"), style: .default, handler: { (_) in
        }))
        alertController.view.tintColor = UIColor.init(hexString: "36527D")
        self.present(alertController, animated: true, completion: nil)*/
    }
    func presentCityPicker(){
        guard let _ = self.selectedCountry else {
            self.invalidTextField(textField: self.txtCountry)
            let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"guideRequest.title"), message: Vocabulary.getWordFromKey(key:"selectCountry"), preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler:nil))
            self.view.endEditing(true)
            self.present(alertController, animated: true, completion: nil)
            return
        }
     
        if let currencyPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
        {
            currencyPicker.modalPresentationStyle = .overFullScreen
            currencyPicker.arrayOfCountry = self.arrayOfCountryDetail
            currencyPicker.objSearchType = .City
            currencyPicker.isGuideRequestLocation = true
            self.view.endEditing(true)
            self.present(currencyPicker, animated: false, completion: nil)
        }
    }
}
extension GuideSignUpViewController:NoCountryDelegate{
    func selectNoCountrySelector() {
        DispatchQueue.main.async {
            self.dismiss(animated: false, completion: {
                self.pushToInquitry()
            })
//            self.view.endEditing(true)
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
//
//            })
        }
        
    }
}
extension GuideSignUpViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfSignUp.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let signUpCell:LogInTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LogInTableViewCell", for: indexPath) as! LogInTableViewCell
        guard self.arrayOfSignUp.count > indexPath.row else {
            return signUpCell
        }
        signUpCell.textFieldLogIn.textColor = UIColor.black.withAlphaComponent(1.0)
        signUpCell.textFieldLogIn.placeholderColor = UIColor.black.withAlphaComponent(1.0)
        self.updateActiveLine(textfield:signUpCell.textFieldLogIn, color: UIColor.init(hexString: "C8C7CC"))

        if(indexPath.row == 0){ //Gender
            signUpCell.textFieldLogIn.inputView = genderPicker
            signUpCell.textFieldLogIn .inputAccessoryView = genderToolBar
            signUpCell.btnDropDown.isEnabled = true
            signUpCell.btnDropDown.isUserInteractionEnabled = false
            signUpCell.btnDropDown.setImage(#imageLiteral(resourceName: "dropdown").withRenderingMode(.alwaysTemplate), for: .normal)
            signUpCell.btnDropDown.tintColor = UIColor.black
        }else{
            signUpCell.textFieldLogIn.inputView = nil
        }
        
        signUpCell.textFieldLogIn.delegate = self
        signUpCell.textFieldLogIn.tag = indexPath.row
        let detail = arrayOfSignUp[indexPath.row]
        DispatchQueue.main.async {
            signUpCell.textFieldLogIn.tweePlaceholder = "\(detail.placeHolder)"
            signUpCell.textFieldLogIn.text = "\(detail.text)"
        }
        signUpCell.textFieldLogIn.keyboardType = detail.keyboardType
        signUpCell.textFieldLogIn.returnKeyType = detail.returnKey
        signUpCell.textFieldLogIn.isSecureTextEntry = detail.isSecure
        if(indexPath.row == 0){ //Gender
            signUpCell.btnDropDown.isHidden = true
            signUpCell.btnDropDown.isEnabled = false
        }else{
            signUpCell.btnDropDown.isHidden = true
            signUpCell.btnDropDown.isEnabled = false
        }
        signUpCell.selectionStyle = .none
        signUpCell.textFieldLogIn.activeLineWidth = 0.0
        signUpCell.textFieldLogIn.activeLineColor = UIColor.clear
        signUpCell.leadingContainer.constant = self.getCellLeftAndRight()
        signUpCell.trailingContainer.constant = self.getCellLeftAndRight()
        signUpCell.clipsToBounds = false
        signUpCell.textFieldLogIn.activeLineColor = .clear
        signUpCell.textFieldLogIn.lineColor = UIColor.init(hexString: "C8C7CC")
        return signUpCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightOfTableViewCell
    }
    func getCellLeftAndRight()->CGFloat{
        return (UIScreen.main.bounds.width - (UIScreen.main.bounds.width*0.85))/2.0
    }
}
extension GuideSignUpViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.genderType[row]
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 150.0
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.genderType.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedGender = "\(self.genderType[row])"
        self.genderPicker.selectRow(row, inComponent: component, animated: true)
    }
}
extension GuideSignUpViewController:UITextViewDelegate{
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
            defer {
                //self.tableGuideSingUp.scrollToBottom(animated: false)
                //self.sizeFooterToFit()
            }
        }
        return false
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
}
extension GuideSignUpViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        if textField != self.txtGuidePhoneNumber!{
            guard !typpedString.isContainWhiteSpace() else{
                return false
            }
        }
        //(textField as? TweeActiveTextField)?.placeholderColor = UIColor.darkGray
        if(textField == self.txtFirstName){
            self.firstNameDetail?.text = typpedString
        }else if (textField == self.txtLastName){
            self.lastNameDetail?.text = typpedString
        }else if(textField == self.txtGuidePhoneNumber!){
            if let _ = self.selectedCountry{
                if typpedString == self.selectedCountry!.countryCode{
                    return false
                }
                if typpedString.count > 20 {
                    return false
                }
            }
            self.phoneDetail?.text = typpedString
        }else{
            let tag = textField.tag
            let detail = self.arrayOfSignUp[tag]
            detail.text = "\(typpedString)"
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if(textField == self.txtFirstName){
            self.firstNameDetail?.text = ""
        }else if (textField == self.txtLastName){
            self.lastNameDetail?.text = ""
        }else if(textField == self.txtGuidePhoneNumber){
            self.phoneDetail?.text = ""
        }else{
            let tag = textField.tag
            let detail = self.arrayOfSignUp[tag]
            detail.text = ""
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.inputView == genderPicker{
            self.buttonForgroundShadow.isHidden = false
        }else if textField == self.txtGuidePhoneNumber{
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
        if textField == self.txtFirstName{
            guard self.firstNameDetail!.text.count > 0 else{
                //self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .red)
                textField.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "firstNameValidation"))
                return false
            }
            self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: UIColor.init(hexString: "C8C7CC"))
            self.txtLastName.becomeFirstResponder()
            return true
        }else if textField == self.txtLastName{
            guard self.lastNameDetail!.text.count > 0 else{
                //self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .red)
                textField.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "lastNameValidation"))
                return false
            }
            self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: UIColor.init(hexString: "C8C7CC"))
            return true
        }else if textField == self.txtGuidePhoneNumber{
            guard self.phoneDetail!.text.count > 0 else{
                textField.invalideField()
                return false
            }
            self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .red)
            return true
        }
        let objectDetail = self.arrayOfSignUp[textField.tag]
       
        if textField.tag == indexOfEmail{ //Email
            guard objectDetail.text.count > 0 else{
                //self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .red)
                textField.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "enterEmail.title"))
                return false
            }
            guard objectDetail.text.isValidEmail() else{
                //self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .red)
                textField.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "pleaseEnterValidEmail.title"))
                return false
            }
        }else{
            
        }
   
        self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: UIColor.init(hexString: "C8C7CC"))
        self.view.viewWithTag(textField.tag+1)?.becomeFirstResponder()
        
        return true
    }
    func updateActiveLine(textfield:TweeActiveTextField,color:UIColor){
        textfield.activeLineColor = .clear
        textfield.lineColor = UIColor.init(hexString: "C8C7CC")
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0{ //gender selection
            self.arrayOfSignUp[textField.tag].text = self.selectedGender
            //self.tableViewSingUp.reloadRows(at: [IndexPath.init(row: textField.tag, section: 0)], with: .automatic)
            if(self.selectedGender == "\(Vocabulary.getWordFromKey(key: "others"))"){
                self.isCustomGender = true
            }else{
                self.isCustomGender = false
            }
        }
        defer {
            if let text = textField.text,text.count > 0{
                self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .black)
            }
        }
    }
}
extension GuideSignUpViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate, CropViewControllerDelegate {
    
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

