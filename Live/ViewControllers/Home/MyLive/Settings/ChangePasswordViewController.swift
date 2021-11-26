//
//  ChangePasswordViewController.swift
//  Live
//
//  Created by ips on 21/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
class ChangePasswordViewController: UIViewController,UIGestureRecognizerDelegate {
    @IBOutlet weak var navTitleLbl: UILabel!
    @IBOutlet weak var btnSave: RoundButton!
    @IBOutlet weak var changePwdTblObj: UITableView!
    @IBOutlet var buttonBack:UIButton!
    @IBOutlet var bottomConstraintSave:NSLayoutConstraint!
    let heightOfTableViewCell:CGFloat = 88.0
    var arrayOfChangePassword:[TextFieldDetail] = []
    var currentPasswordDetail:TextFieldDetail?
    var confirmPasswordDetail:TextFieldDetail?
    var newPasswordDetail:TextFieldDetail?
    let minPasswordLength:Int = 6
    let maxPasswordLength:Int = 15
    var currentPassword: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnSave.setTitle(Vocabulary.getWordFromKey(key: "save.title"), for: .normal)
        self.navTitleLbl.text = Vocabulary.getWordFromKey(key: "ChangePassword")
        if let value = kUserDefault.value(forKey: kUserPassword) {
            self.currentPassword = (value as? String)!
        }
        //Configure ChangePasswordView
        self.configureChangePasswordView()
        //ConfigureTableView
        self.configureTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(ChangePasswordViewController.keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChangePasswordViewController.keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    func swipeToPop() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.addDynamicFont()
            self.swipeToPop()
        }
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
        NotificationCenter.default.removeObserver(self)
    }
    func addDynamicFont(){
        self.buttonBack.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.buttonBack.imageView?.tintColor = UIColor.black
        
        self.navTitleLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.navTitleLbl.adjustsFontForContentSizeCategory = true
        self.navTitleLbl.adjustsFontSizeToFitWidth = true
        
        self.btnSave.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.btnSave.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnSave.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    // MARK: - Custom Methods
    func configureChangePasswordView(){
        self.btnSave.setBackgroundColor(color: UIColor.lightGray.withAlphaComponent(0.5), forState: UIControlState.highlighted)
        currentPasswordDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "CurrentPassword"), text: "", keyboardType: .default, returnKey: .next, isSecure: true)
        newPasswordDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key:"NewPassword"), text: "", keyboardType: .default, returnKey: .next, isSecure: true)
        confirmPasswordDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key:"ConfirmPassword"), text: "", keyboardType: .default, returnKey: .next, isSecure: true)
        self.arrayOfChangePassword = [currentPasswordDetail!,newPasswordDetail!,confirmPasswordDetail!]
    }
    func configureTableView(){
        self.changePwdTblObj.rowHeight = UITableViewAutomaticDimension
        self.changePwdTblObj.estimatedRowHeight = 88.0
        self.changePwdTblObj.delegate = self
        self.changePwdTblObj.dataSource = self
        //Register TableViewCell
//        let objNib = UINib.init(nibName: "LogInTableViewCell", bundle: nil)
//        self.changePwdTblObj.register(objNib, forCellReuseIdentifier: "LogInTableViewCell")
        
        let objNib = UINib.init(nibName: "MDCTextFieldTableViewCell", bundle: nil)
        self.changePwdTblObj.register(objNib, forCellReuseIdentifier: "MDCTextFieldTableViewCell")
        
        // self.tableViewLogIn.tableFooterView = self.tableViewFooterView
        self.changePwdTblObj.separatorStyle = .none
        self.changePwdTblObj.reloadData()
//        let tapGR = UITapGestureRecognizer(target: self, action: #selector(ChangePasswordViewController.handleTap))
//        tapGR.delegate = self
//        tapGR.numberOfTapsRequired = 1
        //self.changePwdTblObj.addGestureRecognizer(tapGR)
    }
    @objc func handleTap(_ gesture: UITapGestureRecognizer){
        DispatchQueue.main.async {
            //self.view.endEditing(true)
        }
    }
    func isValidChangePassword()->Bool{
        if let value = kUserDefault.value(forKey: kUserPassword) {
            self.currentPassword = (value as? String)!
        }
        let currentPasswordCell:MDCTextFieldTableViewCell = self.changePwdTblObj.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! MDCTextFieldTableViewCell
        let newPasswordCell:MDCTextFieldTableViewCell = self.changePwdTblObj.cellForRow(at: IndexPath.init(row: 1, section: 0)) as! MDCTextFieldTableViewCell
        let confirmPasswordCell:MDCTextFieldTableViewCell = self.changePwdTblObj.cellForRow(at: IndexPath.init(row: 2, section: 0)) as! MDCTextFieldTableViewCell
        
        guard currentPasswordDetail!.text.count > 0 else{
            DispatchQueue.main.async {
                //self.invalidTextField(textField: currentPasswordCell.textFieldLogIn)
                //ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "enterCurrentPassword"))
                currentPasswordCell.textFieldError(strError:Vocabulary.getWordFromKey(key: "enterCurrentPassword"))
                //currentPasswordCell.textFieldOutliine?.setErrorText(Vocabulary.getWordFromKey(key: "enterCurrentPassword"), errorAccessibilityValue: nil)
            }
            return false
        }
        /*
        guard currentPasswordDetail!.text == currentPassword else{
            DispatchQueue.main.async {
                self.invalidTextField(textField: currentPasswordCell.textFieldLogIn)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "enterValidCurrentPassword"))
            }
            return false
        }*/
        guard newPasswordDetail!.text.count > 0 else{
            DispatchQueue.main.async {
                //self.invalidTextField(textField: newPasswordCell.textFieldLogIn)
                //ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "enterNewPassword"))
                newPasswordCell.textFieldError(strError:Vocabulary.getWordFromKey(key: "enterNewPassword"))
                //newPasswordCell.textFieldOutliine?.setErrorText(Vocabulary.getWordFromKey(key: "enterNewPassword"), errorAccessibilityValue: nil)
            }
            return false
        }
        guard newPasswordDetail!.text.count >= minPasswordLength else{
            DispatchQueue.main.async {
                //self.invalidTextField(textField: newPasswordCell.textFieldLogIn)
                //ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "minNewPassword"))
                newPasswordCell.textFieldError(strError:Vocabulary.getWordFromKey(key: "minNewPassword"))
                //newPasswordCell.textFieldOutliine?.setErrorText(Vocabulary.getWordFromKey(key: "minNewPassword"), errorAccessibilityValue: nil)

            }
            return false
        }
        guard newPasswordDetail!.text.count <= maxPasswordLength else{
            DispatchQueue.main.async {
                //self.invalidTextField(textField: newPasswordCell.textFieldLogIn)
                //ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "maxNewPassword"))
                newPasswordCell.textFieldError(strError:Vocabulary.getWordFromKey(key: "maxNewPassword"))
                //newPasswordCell.textFieldOutliine?.setErrorText(Vocabulary.getWordFromKey(key: "maxNewPassword"), errorAccessibilityValue: nil)

            }
            return false
        }
        guard confirmPasswordDetail!.text.count > 0 else{
            DispatchQueue.main.async {
                //self.invalidTextField(textField: confirmPasswordCell.textFieldLogIn)
                //ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "confirmPasswordvalidation"))
                 confirmPasswordCell.textFieldError(strError:Vocabulary.getWordFromKey(key: "confirmPasswordvalidation"))
                //confirmPasswordCell.textFieldOutliine?.setErrorText(Vocabulary.getWordFromKey(key: "confirmPasswordvalidation"), errorAccessibilityValue: nil)

            }
            return false
        }
        guard confirmPasswordDetail!.text.count >= minPasswordLength else{
            DispatchQueue.main.async {
                //self.invalidTextField(textField: confirmPasswordCell.textFieldLogIn)
                //ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "minConfirmPassword"))
                 confirmPasswordCell.textFieldError(strError:Vocabulary.getWordFromKey(key: "minConfirmPassword"))
                //confirmPasswordCell.textFieldOutliine?.setErrorText(Vocabulary.getWordFromKey(key: "minConfirmPassword"), errorAccessibilityValue: nil)
            }
            return false
        }
        guard confirmPasswordDetail!.text.count <= maxPasswordLength else{
            DispatchQueue.main.async {
                //self.invalidTextField(textField: confirmPasswordCell.textFieldLogIn)
                //ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "maxConfirmPassword"))
                confirmPasswordCell.textFieldError(strError:Vocabulary.getWordFromKey(key: "maxConfirmPassword"))
                //confirmPasswordCell.textFieldOutliine?.setErrorText(Vocabulary.getWordFromKey(key: "maxConfirmPassword"), errorAccessibilityValue: nil)
            }
            return false
        }
        guard confirmPasswordDetail!.text == newPasswordDetail!.text else{
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "confirmPasswordAsPassword"))
            }
            return false
        }
        guard currentPasswordDetail!.text != newPasswordDetail!.text else{
            DispatchQueue.main.async {
                //self.invalidTextField(textField: currentPasswordCell.textFieldLogIn)
                //ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "enterValidCurrentPassword"))
                
            }
            return false
        }
        currentPasswordCell.textFieldOutliine?.setErrorText(nil, errorAccessibilityValue: nil)
        newPasswordCell.textFieldOutliine?.setErrorText(nil, errorAccessibilityValue: nil)
        confirmPasswordCell.textFieldOutliine?.setErrorText(nil, errorAccessibilityValue: nil)
        //self.validTextField(textField: currentPasswordCell.textFieldLogIn)
        //self.validTextField(textField: newPasswordCell.textFieldLogIn)
        //self.validTextField(textField: confirmPasswordCell.textFieldLogIn)
        return true
    }
    func invalidTextField(textField:TweeActiveTextField){
        textField.activeLineColor = .red
        textField.lineColor = .red
        textField.invalideField()
    }
    func validTextField(textField:TweeActiveTextField){
        textField.activeLineColor = .black
        textField.lineColor = .black
    }
    
    // MARK: - API Request Methods
    func postChangePasswordAPI(){
        if self.isValidChangePassword(){
            let currentUser: User = User.getUserFromUserDefault()!
            let userId: String = currentUser.userID
            let url = "users/\(userId)/native/changedpassword"

            let changeParameters = ["CurrentPassword": "\(currentPasswordDetail!.text)", "NewPassword": "\(newPasswordDetail!.text)"] as [String : AnyObject]
            APIRequestClient.shared.sendRequest(requestType: .PUT, queryString:url, parameter:changeParameters,isHudeShow: true,success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let userInfo = success["data"] as? [String:Any],let strMessage = userInfo["Message"]{
                    kUserDefault.set("\(self.newPasswordDetail!.text)", forKey: kUserPassword)
                    DispatchQueue.main.async {
                        let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key: "ChangePassword"), message: "\(strMessage)", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key: "ok.title"), style: .default, handler: { (_) in
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
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
    }
    
    // MARK:- Selector methods
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async {
                //self.descriptionTxtView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height + 30.0, 0)
                UIView.animate(withDuration: 0.1, animations: {
                    print("Keyboard Size \(keyboardSize.height)")
                    self.bottomConstraintSave.constant = self.getKeyboardSizeHeight()
                    self.loadViewIfNeeded()
                }, completion: { (true) in
                })
            }
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, animations: {
                    self.bottomConstraintSave.constant = 0.0
                    self.view.endEditing(true)
                    self.loadViewIfNeeded()
                })
            }
            
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func saveBtnPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.postChangePasswordAPI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getKeyboardSizeHeight()->CGFloat{
        if UIScreen.main.bounds.height == 812.0{
            return 250.0
        }else if UIScreen.main.bounds.height == 736.0{
            return 226.0
        }else if UIScreen.main.bounds.height == 667.0{
            return 216.0
        }else if UIScreen.main.bounds.height == 568.0{
            return 216.0
        }else{
            return 250.0
        }
    }
}

extension ChangePasswordViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfChangePassword.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let changeCell:MDCTextFieldTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MDCTextFieldTableViewCell", for: indexPath) as! MDCTextFieldTableViewCell
        //let changeCell:LogInTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LogInTableViewCell", for: indexPath) as! LogInTableViewCell
        guard self.arrayOfChangePassword.count > indexPath.row else {
            return changeCell
        }
        changeCell.textFieldLogIn.delegate = self
        changeCell.textFieldLogIn.tag = indexPath.row
        let detail = self.arrayOfChangePassword[indexPath.row]
        DispatchQueue.main.async {
            changeCell.textFieldLogIn.placeholder = "\(detail.placeHolder)"
            changeCell.textFieldLogIn.text = "\(detail.text)"
        }
//        changeCell.textFieldLogIn.layer.borderColor = UIColor.red.cgColor
//        changeCell.textFieldLogIn.layer.borderWidth = 1.0
//        changeCell.textFieldLogIn.clipsToBounds = false
        changeCell.textFieldLogIn.keyboardType = detail.keyboardType
        changeCell.textFieldLogIn.returnKeyType = detail.returnKey
        changeCell.textFieldLogIn.isSecureTextEntry = detail.isSecure
        changeCell.btnDropDown.setImage(#imageLiteral(resourceName: "passwordDisable_black").withRenderingMode(.alwaysTemplate), for: .normal)
        changeCell.btnDropDown.imageView?.tintColor = UIColor.black.withAlphaComponent(0.5)
        changeCell.btnDropDown.isHidden = false
        changeCell.btnDropDown.tag = 101
        //changeCell.setTextFieldColor(textColor: .black,placeHolderColor: UIColor.black)
        changeCell.selectionStyle = .none
        changeCell.trailingButtonDropDown.constant = 20.0
        if indexPath.row == 0{
           // changeCell.textFieldOutliine?.helperText = nil //setHelperText(nil, helperAccessibilityLabel: nil)
        }else{
           // changeCell.textFieldOutliine?.helperText = Vocabulary.getWordFromKey(key:"onlyUserlettersAndNumber.hint") //setHelperText(Vocabulary.getWordFromKey(key:"onlyUserlettersAndNumber.hint"), helperAccessibilityLabel: nil)
        }
        return changeCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightOfTableViewCell
    }
}


extension ChangePasswordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard !typpedString.isContainWhiteSpace() else{
            return false
        }
        let tag = textField.tag
        let detail = self.arrayOfChangePassword[tag]
        detail.text = "\(typpedString)"
        let currentPasswordCell:MDCTextFieldTableViewCell = self.changePwdTblObj.cellForRow(at: IndexPath.init(row: textField.tag, section: 0)) as! MDCTextFieldTableViewCell
        currentPasswordCell.textFieldResignFirstResponder(strError:"")
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        let detail = self.arrayOfChangePassword[tag]
        detail.text = ""
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let currentPasswordCell:MDCTextFieldTableViewCell = self.changePwdTblObj.cellForRow(at: IndexPath.init(row: textField.tag, section: 0)) as! MDCTextFieldTableViewCell
        currentPasswordCell.textFieldResignFirstResponder(strError:"")
        currentPasswordCell.textFieldOutliine?.setHelperText(nil, helperAccessibilityLabel: nil)

        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let currentPasswordCell:MDCTextFieldTableViewCell = self.changePwdTblObj.cellForRow(at: IndexPath.init(row: textField.tag, section: 0)) as! MDCTextFieldTableViewCell
        currentPasswordCell.textFieldBecomeFirstResponder(strHelper: textField.tag != 0 ? "\(Vocabulary.getWordFromKey(key:"onlyUserlettersAndNumber.hint"))" : "")
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if self.isValidChangePassword(){
            guard (self.arrayOfChangePassword.count-1) != textField.tag else{
                //PostResetPasswordAPI
                self.postChangePasswordAPI()
                return true
            }
            self.view.viewWithTag(textField.tag+1)?.becomeFirstResponder()
            return true
        }else{
            return false
        }
    }
    func updateActiveLine(textfield:TweeActiveTextField,color:UIColor){
        textfield.activeLineColor = color
        textfield.lineColor = color
    }
}

