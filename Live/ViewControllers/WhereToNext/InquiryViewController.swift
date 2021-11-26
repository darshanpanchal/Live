//
//  InquiryViewController.swift
//  Live
//
//  Created by ips on 27/06/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class InquiryViewController: UIViewController,UIGestureRecognizerDelegate {
    
//    @IBOutlet weak var sendBtnView: UIView!
    @IBOutlet weak var sendBottomConstant: NSLayoutConstraint!
    @IBOutlet var navTitle: UILabel!
    @IBOutlet var sendBtn: UIButton!
    @IBOutlet var inquiryTblObj: UITableView!
    @IBOutlet var buttonForgroundShadow: UIButton!
    @IBOutlet var lblCapcha:UILabel!
    @IBOutlet var viewCapchaContainer:UIView!
    @IBOutlet var txtCapcha:TweeActiveTextField!
    
    let heightOfTableViewCell:CGFloat = 70.0
    var emailDetail:TextFieldDetail?
    var countryDetail:TextFieldDetail?
    var cityDetail:TextFieldDetail?
    var userTypeDetail:TextFieldDetail?
    var arrayOfInquiryField:[TextFieldDetail] = []
    var selectedCountry:BecomeGuideCountry?
    var locationData = [String: String]()
    var arrayOfCountry:[BecomeGuideCountry] = []
    let userType:[String] = ["\(Vocabulary.getWordFromKey(key: "traveler"))", "\(Vocabulary.getWordFromKey(key: "guide"))"]
    var selectedUser:String = "\(Vocabulary.getWordFromKey(key: "traveler"))"
    var selectedCountryId: String = ""
    var UserTypePicker:UIPickerView = UIPickerView.init()
    var genderToolBar:UIToolbar = UIToolbar()
    var userTypeString = "\(Vocabulary.getWordFromKey(key: "traveler"))"
    var captchaCode:String = ""
    var uniqDigit:String = ""
    var fourUniqueDigits: String {
        var result = ""
        repeat {
            // create a string with up to 4 leading zeros with a random number 0...9999
            result = String(format:"%04d", arc4random_uniform(10000) )
            // generate another random number if the set of characters count is less than four
        } while Set<Character>(result.characters).count < 4
        return result    // ran 5 times
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.viewCapchaContainer.clipsToBounds = true
        self.viewCapchaContainer.layer.borderColor = UIColor.black.cgColor
        self.viewCapchaContainer.layer.borderWidth = 1.5
        // Do any additional setup after loading the view.
       // UIApplication.shared.statusBarStyle = .default
        self.sendBtn.setTitle(Vocabulary.getWordFromKey(key: "sendBtn"), for: .normal)
        self.navTitle.text = Vocabulary.getWordFromKey(key: "inquiry")
        NotificationCenter.default.addObserver(self, selector: #selector(ForgotPasswordViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ForgotPasswordViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.getBecomeGuideCountries()
        //Configure InquiryView
        self.configureInquiryView()
//        IQKeyboardManager.sharedManager().enable = false

        //ConfigureTableView
        self.configureTableView()
        self.swipeToPop()
        self.configureCaptcha()
        self.uniqDigit = self.fourUniqueDigits
        self.lblCapcha.text = self.uniqDigit
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
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.navTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.navTitle.adjustsFontForContentSizeCategory = true
        self.navTitle.adjustsFontSizeToFitWidth = true
        
        self.sendBtn.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.sendBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        self.sendBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
        
    }
    //MARK: Custom Methods
    func configureCaptcha(){
        self.txtCapcha.textColor = UIColor.black
        self.txtCapcha.placeholderColor =  UIColor.black
        self.txtCapcha.delegate = self
        DispatchQueue.main.async { //entercaptcha.hint
            self.txtCapcha.tweePlaceholder = Vocabulary.getWordFromKey(key:"entercaptcha.hint")
            //self.txtCapcha.text = Vocabulary.getWordFromKey(key:"entercaptcha.hint")
        }
    }
    func configureTableView(){
        self.inquiryTblObj.rowHeight = UITableViewAutomaticDimension
        self.inquiryTblObj.estimatedRowHeight = 50.0
        self.inquiryTblObj.delegate = self
        self.inquiryTblObj.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "LogInTableViewCell", bundle: nil)
        self.inquiryTblObj.register(objNib, forCellReuseIdentifier: "LogInTableViewCell")
        // self.tableViewLogIn.tableFooterView = self.tableViewFooterView
        self.inquiryTblObj.separatorStyle = .none
        self.inquiryTblObj.reloadData()
    }
    
    func configureInquiryView(){
        UserTypePicker.delegate = self
        UserTypePicker.dataSource = self
        self.configureGenderToolBar()
//        self.sendBtn.setBackgroundColor(color: UIColor.lightGray.withAlphaComponent(0.5), forState: UIControlState.highlighted)
        emailDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "email.placeholder"), text: "", keyboardType: .emailAddress, returnKey: .next, isSecure: false)
        countryDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key:"Country"), text: "", keyboardType: .default, returnKey: .next, isSecure: false)
        cityDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key:"City"), text: "", keyboardType: .default, returnKey: .next, isSecure: false)
        userTypeDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key:"userType"), text: "", keyboardType: .default, returnKey: .next, isSecure: false)
        self.arrayOfInquiryField = [emailDetail!,countryDetail!,cityDetail!,userTypeDetail!]
    }
    
    func configureGenderToolBar(){
        self.genderToolBar.sizeToFit()
        self.genderToolBar.tintColor = UIColor.init(hexString:"36527D")
        
        self.genderToolBar.layer.borderColor = UIColor.init(hexString: "E1E0E0").cgColor
        self.genderToolBar.layer.borderWidth = 0.5
        self.genderToolBar.clipsToBounds = true
        self.genderToolBar.backgroundColor = UIColor.white
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(SignUpViewController.doneGenderPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "\(Vocabulary.getWordFromKey(key:"userType"))", attributes:[NSAttributedStringKey.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(SignUpViewController.cancelGenderPicker))
        self.genderToolBar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
    }
    
    @objc func cancelGenderPicker(){
        //cancel button dismiss datepicker dialog
        DispatchQueue.main.async {
            self.buttonForgroundShadow.isHidden = true
            self.view.endEditing(true)
        }
        
    }
    @objc func doneGenderPicker(){
        self.selectedUser = self.userTypeString
        DispatchQueue.main.async {
            self.buttonForgroundShadow.isHidden = true
            self.view.endEditing(true)
        }
    }
    
    func isValidInquiryField()->Bool{
        
        let emailCell:LogInTableViewCell = self.inquiryTblObj.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! LogInTableViewCell
        let countryCell:LogInTableViewCell = self.inquiryTblObj.cellForRow(at: IndexPath.init(row: 1, section: 0)) as! LogInTableViewCell
        
        let userTypeCell:LogInTableViewCell = self.inquiryTblObj.cellForRow(at: IndexPath.init(row: 3, section: 0)) as! LogInTableViewCell
        
        guard emailDetail!.text.count > 0 else{
            DispatchQueue.main.async {
                self.invalidTextField(textField: emailCell.textFieldLogIn)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "pleaseEnterValidEmail.title"))
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
        guard countryDetail!.text.count > 0 else{
            DispatchQueue.main.async {
                self.invalidTextField(textField: countryCell.textFieldLogIn)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "selectCountry"))
            }
            return false
        }
        guard userTypeDetail!.text.count > 0 else{
            DispatchQueue.main.async {
                self.invalidTextField(textField: userTypeCell.textFieldLogIn)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "selectUserType"))
            }
            return false
        }
        guard self.captchaCode.count > 0 else{
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtCapcha)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "pleaseentercaptcha.hint"))
            }
            return false
        }
        guard self.captchaCode == self.uniqDigit else{
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtCapcha)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "noMatchcaptcha.hint"))
            }
            return false
        }
        self.validTextField(textField: self.txtCapcha)
        self.validTextField(textField: emailCell.textFieldLogIn)
        self.validTextField(textField: countryCell.textFieldLogIn)
        self.validTextField(textField: userTypeCell.textFieldLogIn)
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
    
    func configureSelectedCountry(){
        if let _ = self.selectedCountry{
            self.arrayOfInquiryField[1].text = "\(self.selectedCountry!.countyName)"
            self.selectedCountryId = "\(self.selectedCountry!.countryID)"
        }
        self.inquiryTblObj.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .automatic)
    }
    
    @objc func buttonClicked() {
        //        isFromRequestLocation = true
        guard CommonClass.shared.isConnectedToInternet else {
            return
        }
        self.presentCountyPicker()
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    self.sendBottomConstant.constant = -(UIScreen.main.bounds.height == 568 ? 260.0:226.0)
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    self.sendBottomConstant.constant = 0
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    //MARK: API Calling
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
    
    func submitInquiry() {  // For Inquiry
        let userType = "\(self.selectedUser)"
        let requestParameters =
            ["Country":"\(self.arrayOfInquiryField[1].text)" as AnyObject,
             "Email":"\(self.arrayOfInquiryField[0].text)" as AnyObject,
             "City":"\(self.arrayOfInquiryField[2].text)" as AnyObject,
             "Usertype":"\(userType.lowercased())" as AnyObject
                ] as [String : AnyObject]
            /*
            ["Countryid":"\(selectedCountryId)" as AnyObject,
             "Email":"\(self.arrayOfInquiryField[0].text)" as AnyObject,
                "Usertype": "\(userType.lowercased())"
                ] as [String : AnyObject]*/
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kInquiry, parameter: requestParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let data = success["data"] as? [String:Any] {
                // Inquiry Suucess Alert
                DispatchQueue.main.async {
                    let inquirySuccessAlert = UIAlertController(title: Vocabulary.getWordFromKey(key: "inquiry"), message: data["Message"] as? String,preferredStyle: UIAlertControllerStyle.alert)
                    inquirySuccessAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"Ok"), style: .default, handler: { (action: UIAlertAction!) in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    inquirySuccessAlert.view.tintColor = UIColor.init(hexString:"36527D")
                    self.present(inquirySuccessAlert, animated: false, completion: nil)
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
    
    //MARK: Selector Methods
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        self.view.endEditing(true)
        if self.isValidInquiryField() {
            self.submitInquiry()
        }
    }
    
    // MARK: - Navigation
    func presentCountyPicker(){
        if let currencyPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController {
            currencyPicker.modalPresentationStyle = .overFullScreen
            currencyPicker.arrayOfGuideCountry = self.arrayOfCountry
            currencyPicker.isInquiryCountry = true
            currencyPicker.objSearchType = .Country
            self.view.endEditing(true)
            self.present(currencyPicker, animated: false, completion: nil)
        }
    }
    
    @IBAction func unwindToInquiry(segue: UIStoryboardSegue) {
        DispatchQueue.main.async {
            self.configureSelectedCountry()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension InquiryViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfInquiryField.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let inquiryCell:LogInTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LogInTableViewCell", for: indexPath) as! LogInTableViewCell
        guard self.arrayOfInquiryField.count > indexPath.row else {
            return inquiryCell
        }
        inquiryCell.btnDropDown.isHidden = true
        inquiryCell.textFieldLogIn.isUserInteractionEnabled = true
//        inquiryCell.textFieldLogIn.inputAccessoryView = self.sendBtnView
        if(indexPath.row == 3){ //UserType
            inquiryCell.textFieldLogIn .inputAccessoryView = genderToolBar
            inquiryCell.textFieldLogIn.inputView = UserTypePicker
            inquiryCell.btnDropDown.isEnabled = true
            inquiryCell.btnDropDown.isUserInteractionEnabled = false
            let origImage = #imageLiteral(resourceName: "dropdown")
            let tintedImage = origImage.withRenderingMode(.alwaysTemplate)
            inquiryCell.btnDropDown.setImage(tintedImage, for: .normal)
            inquiryCell.btnDropDown.tintColor = .black
            inquiryCell.btnDropDown.isHidden = true
        }
        /*
        if (indexPath.row == 1) { // Country selection
            inquiryCell.btnDropDown.isHidden = true
            inquiryCell.textFieldLogIn.isUserInteractionEnabled = false
            inquiryCell.btnSelect.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
        }*/
        inquiryCell.textFieldLogIn.delegate = self
        inquiryCell.textFieldLogIn.tag = indexPath.row
        let detail = self.arrayOfInquiryField[indexPath.row]
        DispatchQueue.main.async {
            inquiryCell.textFieldLogIn.tweePlaceholder = "\(detail.placeHolder)"
            inquiryCell.textFieldLogIn.text = "\(detail.text)"
        }
        inquiryCell.textFieldLogIn.keyboardType = detail.keyboardType
        inquiryCell.textFieldLogIn.returnKeyType = detail.returnKey
        inquiryCell.textFieldLogIn.isSecureTextEntry = detail.isSecure
        inquiryCell.btnDropDown.tag = 101
        inquiryCell.setTextFieldColor(textColor: .black,placeHolderColor: UIColor.black)
        inquiryCell.selectionStyle = .none
        return inquiryCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightOfTableViewCell
    }
}
extension InquiryViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.userType[row]
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 150.0
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.userType.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.userTypeString = "\(self.userType[row])"
        self.UserTypePicker.selectRow(row, inComponent: component, animated: true)
    }
}
extension InquiryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard !typpedString.isContainWhiteSpace() else{
            return false
        }
        if self.txtCapcha == textField{
            self.captchaCode = "\(typpedString)"
            return typpedString.count < 5
        }else{
            let tag = textField.tag
            let detail = self.arrayOfInquiryField[tag]
            detail.text = "\(typpedString)"
            
            return true
        }
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if self.txtCapcha == textField{
            return true
        }else{
            let tag = textField.tag
            let detail = self.arrayOfInquiryField[tag]
            detail.text = ""
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if self.txtCapcha == textField{
            return true
        }else if self.isValidInquiryField() && textField.tag != 1 {
            guard (self.arrayOfInquiryField.count-1) != textField.tag else{
                return true
            }
            self.view.viewWithTag(textField.tag+1)?.becomeFirstResponder()
            return true
        }else{
            return false
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            textField.resignFirstResponder()
            isFromRequestLocation = true
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 { //Country selection
//            self.arrayOfInquiryField[textField.tag].text = self.selectedCountry
        }
        if textField.tag == 3{ //User Type selection
            self.arrayOfInquiryField[textField.tag].text = self.selectedUser
            self.inquiryTblObj.reloadRows(at: [IndexPath.init(row: textField.tag, section: 0)], with: .automatic)
        }
        defer {
            if let text = textField.text,text.count > 0{
                self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: UIColor.init(hexString: "C8C7CC"))
            }
        }
    }
    
    func updateActiveLine(textfield:TweeActiveTextField,color:UIColor){
        textfield.activeLineColor = color
        textfield.lineColor = color
    }
}
