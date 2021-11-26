//
//  SignUpViewController.swift
//  Live
//
//  Created by ITPATH on 4/3/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import IQKeyboardManagerSwift

class SignUpViewController: UIViewController,UIGestureRecognizerDelegate {

    fileprivate let kGuideCountry = "Country"
    fileprivate let kGuideCity = "LocationId"
    
    @IBOutlet weak var navTitleLbl: UILabel!
    @IBOutlet weak var agreeHintLbl: UILabel!
    @IBOutlet var tableViewSingUp:UITableView!
    @IBOutlet var buttonBack:UIButton!
    @IBOutlet var buttonRegister:UIButton!
    @IBOutlet var buttonRegisterShadow:UIButton!
    @IBOutlet var tablViewFooterView:UIView!
    @IBOutlet var buttonBackgroundShadow:UIButton!
    @IBOutlet var buttonAgreeTermsandCondition:UIButton!
    @IBOutlet var buttonReadTermsandCondition:RoundButton!
    @IBOutlet var txtFirstName:TweeActiveTextField!
    @IBOutlet var txtLastName:TweeActiveTextField!
    @IBOutlet var buttonTermsConditions:UIButton!
    @IBOutlet var buttonForgroundShadow:UIButton!
    var selectedCity:CountyDetail?
    
    var arrayOfSignUp:[TextFieldDetail] = []
    var firstNameDetail:TextFieldDetail?
    var lastNameDetail:TextFieldDetail?
    var genderDetail:TextFieldDetail?
    var customGenderDetail:TextFieldDetail?
    var emailDetail:TextFieldDetail?
    var passwordDetail:TextFieldDetail?
    var confirmPasswordDetail:TextFieldDetail?
    var birthDayDetail:TextFieldDetail?
    var countryDetail: TextFieldDetail?
    var cityDetail: TextFieldDetail?
    var arrayOfCountryDetail:[CountyDetail] = [] //Detail of cities
    var arrayOfCountry:[BecomeGuideCountry] = []
    var selectedCountry:BecomeGuideCountry?
    let heightOfTableViewCell:CGFloat = 90.0
    let genderType:[String] = ["\(Vocabulary.getWordFromKey(key: "male"))", "\(Vocabulary.getWordFromKey(key: "female"))", "\(Vocabulary.getWordFromKey(key: "others"))"]
    var selectedGender:String = ""//"\(Vocabulary.getWordFromKey(key: "male"))"
    var currentGender:String = "\(Vocabulary.getWordFromKey(key: "male"))"
    let minPasswordLength:Int = 6
    let maxPasswordLength:Int = 15
    var selectedDate:Date = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
    var currentScrollDate:Date = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
    let alertTitleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17.0)!]
    let alertMessageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
    var objectDatePicker:UIDatePicker{
        get{
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
            //datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
            //datePicker.set18YearValidation()
            datePicker.date = self.selectedDate
            return datePicker
        }
    }
    var isSaved:Bool = false
    var isAgreeWithTermsandCondition:Bool{
        get{
            return isSaved
        }
        set{
            self.isSaved = newValue
            self.configureAgreeWithTermsAndConditions()
        }
    }
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
    var indexOfPassword:Int{
        get{
            if isFaceBookLogin() {
                return isCustomGender ? -1 : -1
            } else {
                return isCustomGender ? 3 : 2
            }
        }
    }
    var indexOfConfirmPassword:Int{
        get{
            if isFaceBookLogin() {
                return isCustomGender ? -1 : -1
            } else {
                return isCustomGender ? 4 : 3
            }
        }
    }
    var indexOfBirthDate:Int{
        get{
            if isFaceBookLogin() {
                return isCustomGender ? 3 : 2
            } else {
                return isCustomGender ? 5 : 4
            }
        }
    }
    var indexOfCountry:Int{
        get{
            if isFaceBookLogin() {
                return isCustomGender ? 4 : 3
            } else {
                return isCustomGender ? 6 : 5
            }
        }
    }
    var indexOfCity:Int{
        get{
            if isFaceBookLogin() {
                return isCustomGender ? 5 : 4
            } else {
                return isCustomGender ? 7 : 6
            }
        }
    }
    var facebookParameters:[String:AnyObject]?
    var facebookProfileImage:String = ""
    var genderPicker:UIPickerView = UIPickerView.init()
    var genderToolBar:UIToolbar = UIToolbar()
    var dobToolBar:UIToolbar = UIToolbar()
    
    // MARK: - UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtFirstName.tweePlaceholder = Vocabulary.getWordFromKey(key: "firstName.title")
        self.txtLastName.tweePlaceholder  = Vocabulary.getWordFromKey(key: "lastName.title")
        self.txtFirstName.placeHolderFont = UIFont.init(name: "Avenir-Roman", size: 14.0)
        self.txtLastName.placeHolderFont = UIFont.init(name: "Avenir-Roman", size: 14.0)
        self.buttonReadTermsandCondition.setTitle(Vocabulary.getWordFromKey(key: "readT&C"), for: .normal)
        self.buttonTermsConditions.setTitle(Vocabulary.getWordFromKey(key: "termsconditions.hint"), for: .normal)
        self.buttonRegister.setTitle(Vocabulary.getWordFromKey(key: "register"), for: .normal)
        self.navTitleLbl.text = Vocabulary.getWordFromKey(key: "createNewAccount")
        self.agreeHintLbl.text = Vocabulary.getWordFromKey(key: "byRegistering")
//        self.buttonAgreeTermsandCondition.setTitle(Vocabulary.getWordFromKey(key: "byRegistering"), for: .normal)
        // Do any additional setup after loading the view.
        //Configure SignUpView
        self.configureSignUpView()
        //Configure TableView
        self.configureTableView()
        //Configure Button
        self.configureButton()
        if let _ = facebookParameters{
            if let firstName = facebookParameters!["first_name"]{
                self.txtFirstName.isEnabled = false
                self.txtFirstName?.text = "\(firstName)"
            }
            if let lastName = facebookParameters!["last_name"]{
                self.txtLastName.isEnabled = false
                self.txtLastName?.text = "\(lastName)"
            }
            if let email = facebookParameters!["email"]{
                self.emailDetail?.text = "\(email)"
            }
            if let picture = facebookParameters!["picture"] as? [String:Any]{
                if let imageData = picture["data"] as? [String:Any]{
                    if let imageURL = imageData["url"]{
                        self.facebookProfileImage = "\(imageURL)"
                    }
                }
            }
        }
        self.getBecomeGuideCountries()
        self.swipeToPop()
    }
    func swipeToPop() {
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .lightContent
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        DispatchQueue.main.async {
            self.addDynamicFont()
            self.addButtonBorder()
            self.view.endEditing(true)
            self.buttonForgroundShadow.isHidden = true
        }
    }
    func addButtonBorder(){
        self.buttonRegisterShadow.clipsToBounds = true
        self.buttonRegisterShadow.layer.cornerRadius = 4.0
    }
    func addDynamicFont(){
        //self.txtFirstName.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1).pointSize
        self.txtFirstName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtFirstName.adjustsFontForContentSizeCategory = true
        
        //self.txtLastName.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1).pointSize
        self.txtLastName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtLastName.adjustsFontForContentSizeCategory = true
        
        self.navTitleLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.navTitleLbl.adjustsFontForContentSizeCategory = true
        self.navTitleLbl.adjustsFontSizeToFitWidth = true
        
//        self.agreeHintLbl.font = CommonClass.shared.getScaledWithOutMinimum(forFont: "Avenir-Roman", textStyle: .caption1)
//        self.agreeHintLbl.adjustsFontForContentSizeCategory = true
//        self.agreeHintLbl.adjustsFontSizeToFitWidth = true
//        self.agreeHintLbl.sizeToFit()
        
        self.buttonReadTermsandCondition.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.buttonReadTermsandCondition.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonReadTermsandCondition.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //buttonTermsConditions
//        self.buttonTermsConditions.titleLabel?.font = CommonClass.shared.getScaledWithOutMinimum(forFont: "Avenir-Heavy", textStyle: .caption1)
//        self.buttonTermsConditions.titleLabel?.adjustsFontForContentSizeCategory = true
//        self.buttonTermsConditions.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.buttonRegister.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonRegister.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonRegister.titleLabel?.adjustsFontSizeToFitWidth = true
        self.tableViewSingUp.reloadData()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.previousNextDisplayMode = .Default

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Methods
    func configureCustomGender(){
        if isFaceBookLogin() {
            if self.isCustomGender{
                self.arrayOfSignUp = [genderDetail!,customGenderDetail!,emailDetail!,birthDayDetail!,countryDetail!,cityDetail!]
            }else{
                self.arrayOfSignUp = [genderDetail!,emailDetail!,birthDayDetail!,countryDetail!,cityDetail!]
            }
        } else {
            if self.isCustomGender{
                self.arrayOfSignUp = [genderDetail!,customGenderDetail!,emailDetail!,passwordDetail!,confirmPasswordDetail!,birthDayDetail!,countryDetail!,cityDetail!]
            }else{
                self.arrayOfSignUp = [genderDetail!,emailDetail!,passwordDetail!,confirmPasswordDetail!,birthDayDetail!,countryDetail!,cityDetail!]
            }
        }
        self.tableViewSingUp.reloadData()
    }
    func stringFromDate(date:Date)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        //dateFormatter.timeStyle = .short
        //dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
    func configureTableView(){
        self.tableViewSingUp.rowHeight = UITableViewAutomaticDimension
        self.tableViewSingUp.estimatedRowHeight = 50.0
        self.tableViewSingUp.delegate = self
        self.tableViewSingUp.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "LogInTableViewCell", bundle: nil)
        self.tableViewSingUp.register(objNib, forCellReuseIdentifier: "LogInTableViewCell")
        // self.tableViewLogIn.tableFooterView = self.tableViewFooterView
        self.tableViewSingUp.separatorStyle = .none
        self.tableViewSingUp.reloadData()
    }
    
    func presentCountyPicker(){
        if let currencyPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
        {
            currencyPicker.modalPresentationStyle = .overFullScreen
            currencyPicker.arrayOfGuideCountry = self.arrayOfCountry
            currencyPicker.objSearchType = .Country
            currencyPicker.isSignUpCountry = true
            self.view.endEditing(true)
            self.present(currencyPicker, animated: false, completion: nil)
        }
    }
    
    func presentCityPicker(){
        if let currencyPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
        {
            currencyPicker.modalPresentationStyle = .overFullScreen
            currencyPicker.arrayOfCountry = self.arrayOfCountryDetail
            currencyPicker.objSearchType = .City
            currencyPicker.isSignUpLocation = true
            self.view.endEditing(true)
            self.present(currencyPicker, animated: false, completion: nil)
        }
    }
    
    func configureSelectedCountry(){
        if let _ = self.selectedCountry{
            let cityCell:LogInTableViewCell = self.tableViewSingUp.cellForRow(at: IndexPath.init(row:indexOfCity, section: 0)) as! LogInTableViewCell
            cityCell.textFieldLogIn.text = ""
            self.countryDetail?.text = "\(self.selectedCountry!.countyName)"
            self.tableViewSingUp.reloadRows(at: [IndexPath.init(row: indexOfCountry, section: 0)], with: .automatic)
            //GET Locations
            self.getLocationRequestWithCountyID(countryID: "\(self.selectedCountry!.countryID)")
        }
    }
    func configureSelectedLocation(){
        if let _ = self.selectedCity{
            self.cityDetail?.text = "\(self.selectedCity!.defaultCity)"
            self.tableViewSingUp.reloadRows(at: [IndexPath.init(row: indexOfCity, section: 0)], with: .automatic)
        }
    }
    
    func configureSignUpView(){
        
        genderPicker.delegate = self
        genderPicker.dataSource = self
        
        self.configureGenderToolBar()
        self.configureDOBToolbar()
        //FirstName LastName Gender Email Address Password (At least 6 characters) Confirm Password birthday by registering, i agree with the Terms and Conditions. Read T&C //REGISTER
         firstNameDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "firstName.title"), text: "", keyboardType: .default, returnKey: .next, isSecure: false)
         lastNameDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "lastName.title"), text: "", keyboardType: .default, returnKey: .next, isSecure: false)
         genderDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "gender.title"), text: "\(selectedGender)", keyboardType: .default, returnKey: .next, isSecure: false)
         emailDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "email.placeholder"), text: "", keyboardType: .emailAddress, returnKey: .next, isSecure: false)
         passwordDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "password.placeholder"), text: "", keyboardType: .default, returnKey: .next, isSecure: true)
         confirmPasswordDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "confirmPassword.title"), text: "", keyboardType: .default, returnKey: .next, isSecure: true)
         birthDayDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "birthDay"), text: "", keyboardType: .default, returnKey: .next, isSecure: false)
        customGenderDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "specifyGender"), text: "", keyboardType: .default, returnKey: .next, isSecure: false)
        
        countryDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "CountryOptional"), text: "", keyboardType: .default, returnKey: .next, isSecure: false)
        cityDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "LocationOptional"), text: "", keyboardType: .default, returnKey: .next, isSecure: false)
        if isFaceBookLogin() {
        self.arrayOfSignUp = [genderDetail!,emailDetail!,birthDayDetail!,countryDetail!,cityDetail!]
        } else {
            self.arrayOfSignUp = [genderDetail!,emailDetail!,passwordDetail!,confirmPasswordDetail!,birthDayDetail!,countryDetail!,cityDetail!]
        }
        self.buttonReadTermsandCondition.layer.cornerRadius = 20.0
        self.buttonReadTermsandCondition.clipsToBounds = true
    }
    func configureGenderToolBar(){
        self.genderToolBar.sizeToFit()
        self.genderToolBar.tintColor = UIColor.init(hexString:"36527D")
        
        self.genderToolBar.layer.borderColor = UIColor.darkGray.cgColor
        self.genderToolBar.layer.borderWidth = 1.0
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
    func configureDOBToolbar(){
        self.dobToolBar.sizeToFit()
        self.dobToolBar.layer.borderColor = UIColor.darkGray.cgColor
        self.dobToolBar.layer.borderWidth = 1.0
        self.dobToolBar.clipsToBounds = true
        self.dobToolBar.backgroundColor = UIColor.white
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(SignUpViewController.doneDOBPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "DOB", attributes:[NSAttributedStringKey.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(SignUpViewController.cancelGenderPicker))
        self.dobToolBar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
    }
    func configureAgreeWithTermsAndConditions(){
        if(self.isAgreeWithTermsandCondition){
            self.buttonAgreeTermsandCondition.setImage(#imageLiteral(resourceName: "check").withRenderingMode(.alwaysOriginal), for: .normal)
        }else{
            self.buttonAgreeTermsandCondition.setImage(#imageLiteral(resourceName: "uncheck").withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    func configureButton(){
        self.buttonReadTermsandCondition.setBackgroundColor(color: UIColor.lightGray.withAlphaComponent(0.5), forState: UIControlState.highlighted)
        self.buttonRegister.setBackgroundColor(color: UIColor.lightGray.withAlphaComponent(0.5), forState: UIControlState.highlighted)
        
    }
    func isFaceBookLogin()->Bool{
        if let _ = facebookParameters{
            return true
        }else{
            return false
        }
    }
    func getAgeDifference()->Int{
        return Calendar.current.dateComponents([.year], from: self.selectedDate, to: Date()).year ?? 0
    }
    func isValidSignUp()->Bool{
        var countryCell:LogInTableViewCell?
        var cityCell:LogInTableViewCell?
        if let _ = self.tableViewSingUp.cellForRow(at: IndexPath.init(row:indexOfCountry, section: 0)) as? LogInTableViewCell{
            countryCell = self.tableViewSingUp.cellForRow(at: IndexPath.init(row:indexOfCountry, section: 0)) as? LogInTableViewCell
        }
        if let _  = self.tableViewSingUp.cellForRow(at: IndexPath.init(row:indexOfCity, section: 0)) as? LogInTableViewCell{
            cityCell = self.tableViewSingUp.cellForRow(at: IndexPath.init(row:indexOfCity, section: 0)) as? LogInTableViewCell
        }
        if !isFaceBookLogin() {
            // let firstNameCell:LogInTableViewCell = self.tableViewSingUp.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! LogInTableViewCell
            // let lastNameCell:LogInTableViewCell = self.tableViewSingUp.cellForRow(at: IndexPath.init(row: 1, section: 0)) as! LogInTableViewCell
            var emailCell:LogInTableViewCell?
            var passwordCell:LogInTableViewCell?
            var confirmPasswordCell:LogInTableViewCell?
          
            var birthDayCell:LogInTableViewCell?
            
            if let _ = self.tableViewSingUp.cellForRow(at: IndexPath.init(row: indexOfEmail, section: 0)) as? LogInTableViewCell{
                emailCell = self.tableViewSingUp.cellForRow(at: IndexPath.init(row: indexOfEmail, section: 0)) as? LogInTableViewCell
            }
            if let _ = self.tableViewSingUp.cellForRow(at: IndexPath.init(row: indexOfPassword, section: 0)) as? LogInTableViewCell{
                passwordCell  = self.tableViewSingUp.cellForRow(at: IndexPath.init(row: indexOfPassword, section: 0)) as? LogInTableViewCell
            }
            if let _ = self.tableViewSingUp.cellForRow(at: IndexPath.init(row: indexOfConfirmPassword, section: 0)) as? LogInTableViewCell{
                confirmPasswordCell = self.tableViewSingUp.cellForRow(at: IndexPath.init(row: indexOfPassword, section: 0)) as? LogInTableViewCell
            }
            
            if let _  = self.tableViewSingUp.cellForRow(at: IndexPath.init(row:indexOfBirthDate, section: 0)) as? LogInTableViewCell{
                birthDayCell = self.tableViewSingUp.cellForRow(at: IndexPath.init(row:indexOfBirthDate, section: 0)) as? LogInTableViewCell
            }
            
            //        let firtNameDetail:TextFieldDetail = self.arrayOfSignUp[0]
            //        let lastNameDetail:TextFieldDetail = self.arrayOfSignUp[1]
            //        let emailDetail:TextFieldDetail = self.arrayOfSignUp[3]
            //        let passwordDetail:TextFieldDetail = self.arrayOfSignUp[4]
            //        let confirmPasswordDetail:TextFieldDetail = self.arrayOfSignUp[5]
            //
            
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
                    if let _ = emailCell{
                        self.invalidTextField(textField: (emailCell?.textFieldLogIn)!)
                    }
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "enterEmail.title"))
                }
                return false
            }
            guard emailDetail!.text.isValidEmail() else{
                DispatchQueue.main.async {
                    if let _ = emailCell{
                        self.invalidTextField(textField: (emailCell?.textFieldLogIn)!)
                    }
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "pleaseEnterValidEmail.title"))
                }
                return false
            }
            guard passwordDetail!.text.count > 0 else{
                DispatchQueue.main.async {
                    if let _ = passwordCell{
                        self.invalidTextField(textField: (passwordCell?.textFieldLogIn)!)
                    }
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "pleaseEnterPassword.title"))
                }
                return false
            }
            guard passwordDetail!.text.count >= minPasswordLength else{
                DispatchQueue.main.async {
                    if let _ = passwordCell{
                        self.invalidTextField(textField: (passwordCell?.textFieldLogIn)!)
                    }
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "minRequiredPassword"))
                }
                return false
            }
            guard passwordDetail!.text.count <= maxPasswordLength else{
                DispatchQueue.main.async {
                    if let _ = passwordCell{
                        self.invalidTextField(textField: (passwordCell?.textFieldLogIn)!)
                    }
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "maxRequiredPassword"))
                }
                return false
            }
            guard confirmPasswordDetail!.text.count > 0 else{
                DispatchQueue.main.async {
                    if let _ = passwordCell{
                        self.invalidTextField(textField: (confirmPasswordCell?.textFieldLogIn)!)
                    }
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "confirmPasswordvalidation"))
                }
                return false
            }
            guard confirmPasswordDetail!.text.count >= minPasswordLength else{
                DispatchQueue.main.async {
                    if let _ = passwordCell{
                        self.invalidTextField(textField: (confirmPasswordCell?.textFieldLogIn)!)
                    }
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "minConfirmPassword"))
                }
                return false
            }
            guard confirmPasswordDetail!.text.count <= maxPasswordLength else{
                DispatchQueue.main.async {
                    if let _ = passwordCell{
                        self.invalidTextField(textField: (confirmPasswordCell?.textFieldLogIn)!)
                    }
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "maxConfirmPassword"))
                }
                return false
            }
            guard confirmPasswordDetail!.text == passwordDetail!.text else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "confirmPasswordAsPassword"))
                }
                return false
            }
            if let cell = birthDayCell,let strBirth = cell.textFieldLogIn.text,strBirth.count > 0{
                guard self.getAgeDifference() > 18 else{
                    DispatchQueue.main.async {
                        self.invalidTextField(textField:(birthDayCell?.textFieldLogIn)!)
                        ShowToast.show(toatMessage:"Its only possible to enter years that are older than 18.")
                    }
                    return false
                }
            }
            guard countryDetail!.text.count > 0 else {
                DispatchQueue.main.async {
                    if let _ = countryCell{
                        self.invalidTextField(textField: countryCell!.textFieldLogIn)
                    }
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "selectCountry"))
                }
                return false
            }
            guard cityDetail!.text.count > 0 else {
                DispatchQueue.main.async {
                    if let _ = cityCell{
                        self.invalidTextField(textField: cityCell!.textFieldLogIn)
                    }
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "locationValidation"))
                }
                return false
            }
            //        guard self.isAgreeWithTermsandCondition else{
            //            DispatchQueue.main.async {
            //                self.buttonAgreeTermsandCondition.invalideField()
            //                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "agreeTC"))
            //            }
            //            return false
            //        }
            //self.validTextField(textField: firstNameCell.textFieldLogIn)
            //self.validTextField(textField: lastNameCell.textFieldLogIn)
            if let _ = emailCell{
                self.validTextField(textField: emailCell!.textFieldLogIn)
            }
            if let _ = passwordCell{
                self.validTextField(textField: passwordCell!.textFieldLogIn)
            }
            if let _ = confirmPasswordCell{
                self.validTextField(textField: confirmPasswordCell!.textFieldLogIn)
            }
            if let _ = countryCell{
                self.validTextField(textField: countryCell!.textFieldLogIn)
            }
            if let _ = cityCell{
                self.validTextField(textField: cityCell!.textFieldLogIn)
            }
            if let _ = birthDayCell{
                self.validTextField(textField: birthDayCell!.textFieldLogIn)
            }
        }
        guard countryDetail!.text.count > 0 else {
            DispatchQueue.main.async {
                if let _ = countryCell{
                    self.invalidTextField(textField: countryCell!.textFieldLogIn)
                }
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "selectCountry"))
            }
            return false
        }
        guard cityDetail!.text.count > 0 else {
            DispatchQueue.main.async {
                if let _ = cityCell{
                    self.invalidTextField(textField: cityCell!.textFieldLogIn)
                }
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "locationValidation"))
            }
            return false
        }
        if let _ = countryCell{
            self.validTextField(textField: countryCell!.textFieldLogIn)
        }
        if let _ = cityCell{
            self.validTextField(textField: cityCell!.textFieldLogIn)
        }
        return true
    }
    func invalidTextField(textField:TweeActiveTextField){
        textField.activeLineColor = .red
        textField.lineColor = .red
        textField.invalideField()
    }
    func validTextField(textField:TweeActiveTextField){
        textField.activeLineColor = UIColor.init(hexString: "C8C7CC")
        textField.lineColor = UIColor.init(hexString: "C8C7CC")
    }
    
    // MARK: - API Request Methods
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
    func getDeviceCulture() -> String {
        let locale = Locale.current
        guard let languageCode = locale.languageCode,
            let regionCode = locale.regionCode else {
                return "de_DE"
        }
        return languageCode + "_" + regionCode
    }
    func postSignUpRequest(){
        if(self.isValidSignUp()){ //Check for valid request
            var facebookID = ""
            var facebookSecret = ""
            if self.isFaceBookLogin(){
                facebookSecret = "\(FBSDKAccessToken.current())"
                if let facebookDetail = self.facebookParameters,let fbID = facebookDetail["id"]{
                    facebookID = "\(fbID)"
                }
            }
            var selectedLanguage = "1"
            if (UserDefaults.standard.value(forKey: "selectedLanguageCode") != nil) {
                selectedLanguage = (UserDefaults.standard.value(forKey: "selectedLanguageCode") as? String)!
            }
            var locationId: String = ""
            if ((self.selectedCity?.locationID) != nil) {
                locationId = (self.selectedCity?.locationID)!
            }
            var pushToken:String = "\(UIDevice.current.identifierForVendor!.uuidString)"
            if let _ = kUserDefault.value(forKey:kPushNotificationToken){
                pushToken = "\(kUserDefault.value(forKey:kPushNotificationToken)!)"
            }
            var passwordStr = self.passwordDetail?.text
            if passwordStr == nil {
                passwordStr = ""
            }
            let signUpParameters =
                ["FirstName":"\(self.txtFirstName!.text!)",
                 "LastName":"\(self.txtLastName!.text!)",
                 "Email":"\(self.emailDetail!.text)",
                 "Gender":"\(self.genderDetail!.text)",
                 "GenderCustom":"\(self.customGenderDetail!.text)",
                "Password":"\(passwordStr!)",
                 "BirthDate":"\(self.birthDayDetail!.text)",
                 "DeviceId":"\(pushToken)",
                "DeviceType":"iPhone",
                "verifiedEmail" : 0,
                "FacebookId":"\(facebookID)",
                "FacebookSecret":"\(facebookSecret)",
                "AppLanguageId":"\(selectedLanguage)",
                "LocationId": "\(locationId)",
                "Image":"\(self.facebookProfileImage)",
                "Culture":"\(self.getDeviceCulture())"
                ] as [String : AnyObject]
          
        APIRequestClient.shared.sendSignUpRequest(requestType: .POST, queryString:kSignUp, parameter:signUpParameters,isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let accessToken = success["AccessToken"],let userInfo = success["data"] as? [String:Any]{
                
                let objUser = User.init(accesToken:"\(accessToken)", userDetail: userInfo,isRemember: true,password:"")
                objUser.userDefaultRole = objUser.role
                objUser.setUserDataToUserDefault()
                DispatchQueue.main.async {
                    //Push to Home
                    self.pushToHomeViewController()
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
            }, fail: { (responseFail) in
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
            })
            
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
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func unwindToSignUpFromCounty(segue:UIStoryboardSegue){
        DispatchQueue.main.async {
            let countryCell:LogInTableViewCell = self.tableViewSingUp.cellForRow(at: IndexPath.init(row:self.indexOfCountry, section: 0)) as! LogInTableViewCell
            countryCell.textFieldLogIn.resignFirstResponder()
            self.configureSelectedCountry()
        }
    }
    @IBAction func unwindToSignUpFromLocation(segue:UIStoryboardSegue){
        DispatchQueue.main.async {
            self.configureSelectedLocation()
        }
    }
    
    func popToBackViewController(){
        self.navigationController?.popViewController(animated: true)
    }
    func pushToHomeViewController(){
        if let whereToNextController:WhereToNextViewController = self.storyboard?.instantiateViewController(withIdentifier: "WhereToNextViewController") as? WhereToNextViewController{
            whereToNextController.isPushToHome = true
            whereToNextController.isAnimatedPush = true
            self.navigationController?.pushViewController(whereToNextController, animated: false)
        }
    }
    func presentTermsAndConditions(){
        guard CommonClass.shared.isConnectedToInternet else {
            return
        }
        if let termsViewController = self.storyboard?.instantiateViewController(withIdentifier:"TermsViewController") as? TermsViewController{
            self.navigationController?.present(termsViewController, animated: true, completion: nil)
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackgroundShadowSelector(sender:UIButton){
        self.view.endEditing(true)
    }
    @objc func dateChanged(_ sender: UIDatePicker) {
        let componenets = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        if let day = componenets.day, let month = componenets.month, let year = componenets.year {
            self.currentScrollDate = sender.date//"\(day)/\(month)/\(year)"
            print("\(day) \(month) \(year)")
        }
    }
    @IBAction func buttonBackSelector(sender:UIButton){
        self.view.endEditing(true)
        self.popToBackViewController()
    }
    @IBAction func buttonReadTermsandConditionselector(sender:UIButton){
        self.view.endEditing(true)
        self.presentTermsAndConditions()
    }
    @IBAction func buttonAgreeTermsandConditionSelector(sender:UIButton){
        self.view.endEditing(true)
        self.isAgreeWithTermsandCondition = !self.isAgreeWithTermsandCondition

    }
    @IBAction func buttonRegisterSelector(sender:UIButton){
        self.view.endEditing(true)
        self.postSignUpRequest()
    }
    @objc func cancelGenderPicker(){
        //cancel button dismiss datepicker dialog
        DispatchQueue.main.async {
            self.buttonForgroundShadow.isHidden = true
            self.view.endEditing(true)
        }
        
    }
    @objc func doneGenderPicker(){
//        print(self.selectedDayTag)
////        //dismiss date picker dialog
//        self.selectedDayOfMonth = "\(self.arrayOfDaysOfMonth[self.selectedDayTag])"
//        self.scheduleType = .Monthly
        self.selectedGender = self.currentGender
        DispatchQueue.main.async {
            self.buttonForgroundShadow.isHidden = true
            self.view.endEditing(true)
        }
    }
    @objc func doneDOBPicker(){
        self.selectedDate = self.currentScrollDate
        DispatchQueue.main.async {
            self.buttonForgroundShadow.isHidden = true
            self.view.endEditing(true)
        }
    }
}
extension SignUpViewController:UITableViewDelegate,UITableViewDataSource{
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
        signUpCell.btnSelect.isHidden = true
        if(indexPath.row == 0){ //Gender
            signUpCell.textFieldLogIn.inputView = genderPicker
            signUpCell.textFieldLogIn .inputAccessoryView = genderToolBar
            signUpCell.btnDropDown.isEnabled = true
            signUpCell.btnDropDown.isUserInteractionEnabled = false
            signUpCell.btnDropDown.imageView?.contentMode = .scaleAspectFit
            signUpCell.btnDropDown.setImage(#imageLiteral(resourceName: "arrow_white"), for: .normal)
        }else if (indexPath.row == indexOfBirthDate){ //Birthdate
            signUpCell.textFieldLogIn.inputView = self.objectDatePicker
            signUpCell.textFieldLogIn .inputAccessoryView = dobToolBar
        }
        else{
            signUpCell.textFieldLogIn.inputView = nil
        }
        if indexPath.row == indexOfEmail{
            signUpCell.textFieldLogIn.isEnabled = self.isFaceBookLogin() ? false : true
        }else{
            signUpCell.textFieldLogIn.isEnabled = true
        }
        signUpCell.textFieldLogIn.delegate = self
        signUpCell.textFieldLogIn.tag = indexPath.row
        let detail = arrayOfSignUp[indexPath.row]
        signUpCell.textFieldLogIn.tweePlaceholder = "\(detail.placeHolder)"
        DispatchQueue.main.async {
            signUpCell.textFieldLogIn.text = "\(detail.text)"
        }
        signUpCell.textFieldLogIn.keyboardType = detail.keyboardType
        signUpCell.textFieldLogIn.returnKeyType = detail.returnKey
        signUpCell.textFieldLogIn.isSecureTextEntry = detail.isSecure
        if((indexPath.row == indexOfPassword) || (indexPath.row == indexOfConfirmPassword)) { //Gender
            signUpCell.btnDropDown.isHidden = false
            signUpCell.btnDropDown.isEnabled = true
        }else{
            signUpCell.btnDropDown.isHidden = true
            signUpCell.btnDropDown.isEnabled = false
        }
        signUpCell.selectionStyle = .none
        
        signUpCell.setTextFieldColor(textColor: UIColor.white, placeHolderColor: UIColor.white)
        //signUpCell.textFieldLogIn.placeHolderFont = UIFont.init(name: "Avenir-Roman", size: 17.0)
        return signUpCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightOfTableViewCell
    }
}

extension SignUpViewController:UIPickerViewDelegate,UIPickerViewDataSource{
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
        self.currentGender = "\(self.genderType[row])"
        //self.selectedGender = "\(self.genderType[row])"
        self.genderPicker.selectRow(row, inComponent: component, animated: true)
    }
}
extension SignUpViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard !typpedString.isContainWhiteSpace() else{
            return false
        }
        if(textField == self.txtFirstName){
            self.firstNameDetail?.text = typpedString
        }else if (textField == self.txtLastName){
            self.lastNameDetail?.text = typpedString
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
        }else{
            let tag = textField.tag
            let detail = self.arrayOfSignUp[tag]
            detail.text = ""
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            if textField.inputView == self.objectDatePicker{
                self.buttonForgroundShadow.isHidden = false
            }else if textField.inputView == genderPicker{
                self.buttonForgroundShadow.isHidden = false
            }else{
                self.buttonForgroundShadow.isHidden = true
            }
            if textField.tag == self.indexOfCity {
                if self.arrayOfCountryDetail.count > 0 {
                    self.view.endEditing(true)
                    self.presentCityPicker()
                } else {
                    self.view.endEditing(true)
                    let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"guideRequest.title"), message: Vocabulary.getWordFromKey(key:"selectCountry"), preferredStyle: .alert)
                    alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler:nil))
                    self.present(alertController, animated: true, completion: nil)
                }
                return false
            }
            else if textField.tag == self.indexOfCountry {
                self.view.endEditing(true)
                self.presentCountyPicker()
                return false
            }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.txtFirstName{
            guard self.firstNameDetail!.text.count > 0 else{
                self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .red)
                textField.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "firstNameValidation"))
                return false
            }
            self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .white)
            self.txtLastName.becomeFirstResponder()
            return true
        }else if textField == self.txtLastName{
            guard self.lastNameDetail!.text.count > 0 else{
                self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .red)
                textField.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "lastNameValidation"))
                return false
            }
            self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .white)
            return true
        }else{
            
        }
        let objectDetail = self.arrayOfSignUp[textField.tag]
        /*
        if textField.tag == 0 { //First Namem
            guard objectDetail.text.count > 0 else{
                self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .red)
                textField.invalideField()
                ShowToast.show(toatMessage: "please enter first name.")
                return false
            }
        }else if textField.tag == 1{ //Last Name
            guard objectDetail.text.count > 0 else{
                self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .red)
                textField.invalideField()
                ShowToast.show(toatMessage: "please enter last name.")
                return false
            }
        }else*/
        if textField.tag == indexOfEmail{ //Email
            guard objectDetail.text.count > 0 else{
                self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .red)
                textField.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "enterEmail.title"))
                return false
            }
            guard objectDetail.text.isValidEmail() else{
                self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .red)
                textField.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "pleaseEnterValidEmail.title"))
                return false
            }
        }else if textField.tag == indexOfPassword || textField.tag == indexOfConfirmPassword{ //Password //Confirm Passoword
            let strPassword = (textField.tag == 4) ? "\(Vocabulary.getWordFromKey(key: "password"))":"\(Vocabulary.getWordFromKey(key:"confirmpassword"))"
            guard objectDetail.text.count > 0 else{
                self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .red)
                textField.invalideField()
                let str = "\(Vocabulary.getWordFromKey(key: "pleaseEnter"))" + "\(strPassword)."
                ShowToast.show(toatMessage: str)
                return false
            }
            guard objectDetail.text.count >= minPasswordLength else{
                self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .red)
                textField.invalideField()
                let str1 = "\(Vocabulary.getWordFromKey(key: "minRequiredPassword"))" + "\(strPassword)."
                ShowToast.show(toatMessage: str1)
                return false
            }
            guard objectDetail.text.count <= maxPasswordLength else{
                self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .red)
                textField.invalideField()
                let str2 = "\(Vocabulary.getWordFromKey(key: "maxRequiredPassword"))" + "\(strPassword)."
                ShowToast.show(toatMessage: str2)
                return false
            }
            if textField.tag == indexOfConfirmPassword {
                guard passwordDetail!.text == objectDetail.text else{
                    self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .red)
                    textField.invalideField()
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "confirmPasswordAsPassword"))
                    return false
                }
            }
        }else{
        }
//       guard (self.arrayOfSignUp.count-1) != textField.tag else{
//            //PostSignUpAPI
//            self.postSignUpRequest()
//            return true
//      }
        self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .white)
        self.view.viewWithTag(textField.tag+1)?.becomeFirstResponder()
    
        return true
    }
    func updateActiveLine(textfield:TweeActiveTextField,color:UIColor){
        textfield.activeLineColor = color
        textfield.lineColor = color
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.buttonForgroundShadow.isHidden = true
        return true
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
        }else if textField.tag == indexOfBirthDate{ //birthDay
            self.objectDatePicker.setDate(self.selectedDate, animated: false)
            textField.text = self.stringFromDate(date: self.selectedDate)
            self.arrayOfSignUp[textField.tag].text = self.stringFromDate(date: self.selectedDate)
            self.tableViewSingUp.reloadRows(at: [IndexPath.init(row: textField.tag, section: 0)], with: .automatic)
        }
        defer {
            if let text = textField.text,text.count > 0{
                self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .white)
            }
        }
    }
}
extension UIDatePicker {
    func set18YearValidation() {
        let currentDate: Date = Date()
        var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var components: DateComponents = DateComponents()
        components.calendar = calendar
        components.year = -18
        let maxDate: Date = calendar.date(byAdding: components, to: currentDate)!
        components.year = -150
        let minDate: Date = calendar.date(byAdding: components, to: currentDate)!
        self.minimumDate = minDate
        self.maximumDate = maxDate
    } }
