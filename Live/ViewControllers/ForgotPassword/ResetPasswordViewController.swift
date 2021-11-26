//
//  ResetPasswordViewController.swift
//  Live
//
//  Created by ITPATH on 4/18/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import SVPinView

class ResetPasswordViewController: UIViewController,UIGestureRecognizerDelegate {
    @IBOutlet var buttonBack:UIButton!
    var userEmailID:String = ""
    @IBOutlet var tableViewResetPassword:UITableView!
    @IBOutlet var buttonReset:RoundButton!
    @IBOutlet var buttonBackGround:UIButton!
    @IBOutlet weak var lblNavTitle: UILabel!
    @IBOutlet weak var recoveryCodeLbl: UILabel!
    @IBOutlet weak var pinView: SVPinView!
    @IBOutlet var topUpdatePassword:NSLayoutConstraint!
    @IBOutlet var bottomUpdatePassword:NSLayoutConstraint!
    @IBOutlet var contentView:UIView!
    
    let minPasswordLength:Int = 6
    let maxPasswordLength:Int = 15
    let heightOfTableViewCell:CGFloat = 90.0
    var arrayOfResetPassword:[TextFieldDetail] = []
    var emailDetail:TextFieldDetail?
    var passwordDetail:TextFieldDetail?
    var confirmPasswordDetail:TextFieldDetail?
    var recoverPinDetail:TextFieldDetail?
    //var recoveryDetail:String?
    var tableViewFooterHeight:CGFloat{
        get{
            return UIScreen.main.bounds.height - ((heightOfTableViewCell * 4)+(getSafeInset)+64+20)
        }
    }
    var getSafeInset:CGFloat{
        get{
            return UIScreen.main.bounds.height == 812 ? 44+34 : 20
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonBack.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.buttonBack.imageView?.tintColor = UIColor.black
        self.lblNavTitle.text = Vocabulary.getWordFromKey(key: "recoverPassword.title")
        self.recoveryCodeLbl.text = Vocabulary.getWordFromKey(key: "recoveryCode.title")
        let strUpdatePassword = "\(Vocabulary.getWordFromKey(key: "Update")) \(Vocabulary.getWordFromKey(key: "password.placeholder"))"
        self.buttonReset.setTitle(strUpdatePassword, for: .normal)
        // Do any additional setup after loading the view.
        //Configure ResetPasswordView
        self.configureResetPasswordView()
        //ConfigureTableView
        self.configureTableView()
        self.configurePinView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ResetPasswordViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ResetPasswordViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
        self.view.endEditing(true)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .default
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
        self.topUpdatePassword.isActive = false
        self.bottomUpdatePassword.isActive = true
        if let _ = self.tableViewResetPassword.tableFooterView{
            print("======= \(self.tableViewFooterHeight) =========")
            self.tableViewResetPassword.tableFooterView?.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.tableViewResetPassword.bounds.width, height: self.tableViewFooterHeight))
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    func addDynamicFont(){
        self.lblNavTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblNavTitle.adjustsFontForContentSizeCategory = true
        self.lblNavTitle.adjustsFontSizeToFitWidth = true
        
        self.recoveryCodeLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.recoveryCodeLbl.adjustsFontForContentSizeCategory = true
        self.recoveryCodeLbl.adjustsFontSizeToFitWidth = true
        
        self.buttonReset.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonReset.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonReset.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
    func configureResetPasswordView(){
        self.buttonReset.setBackgroundColor(color: UIColor.lightGray.withAlphaComponent(0.5), forState: UIControlState.highlighted)
        emailDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "email.placeholder"), text: "\(self.userEmailID)", keyboardType: .emailAddress, returnKey: .next, isSecure: false)
        passwordDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "password.placeholder"), text: "", keyboardType: .default, returnKey: .next, isSecure: true)
        confirmPasswordDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "confirmPassword.title"), text: "", keyboardType: .default, returnKey: .next, isSecure: true)
        recoverPinDetail = TextFieldDetail.init(placeHolder:"Recovery Code", text: "", keyboardType: .numberPad, returnKey: .done, isSecure: false)
        self.arrayOfResetPassword = [emailDetail!,passwordDetail!,confirmPasswordDetail!,recoverPinDetail!]
    }
    func configureTableView(){
//        self.tableViewResetPassword.tableHeaderView = UIView()
        self.tableViewResetPassword.rowHeight = UITableViewAutomaticDimension
        self.tableViewResetPassword.estimatedRowHeight = 50.0
        self.tableViewResetPassword.delegate = self
        self.tableViewResetPassword.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "LogInTableViewCell", bundle: nil)
        self.tableViewResetPassword.register(objNib, forCellReuseIdentifier: "LogInTableViewCell")
        // self.tableViewLogIn.tableFooterView = self.tableViewFooterView
        self.tableViewResetPassword.separatorStyle = .none
        self.tableViewResetPassword.reloadData()
    }
    
    func configurePinView() {
        
        pinView.pinLength = 6
        pinView.secureCharacter = "\u{25CF}"
        pinView.interSpace = 5
        pinView.textColor = UIColor.black
        pinView.borderLineColor = UIColor.black
        pinView.borderLineThickness = 1.5
        pinView.shouldSecureText = false
        pinView.style = .box
        pinView.fieldBackgroundColor = UIColor.clear
        pinView.fieldCornerRadius = 0
        
        pinView.font = UIFont.systemFont(ofSize: 18)
        pinView.keyboardType = .numberPad
        pinView.pinInputAccessoryView = { () -> UIView in
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
            doneToolbar.barStyle = UIBarStyle.default
            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(dismissKeyboard))
            
            var items = [UIBarButtonItem]()
            items.append(flexSpace)
            items.append(done)
            
            doneToolbar.items = items
            doneToolbar.sizeToFit()
            return doneToolbar
        }()
        
        pinView.didFinishCallback = didFinishEnteringPin(pin:)
    }
    
    func didFinishEnteringPin(pin:String) {
        //self.recoveryDetail = pin
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
     func isValidResetPassword()->Bool{
        var emailCell:LogInTableViewCell?
        var passwordCell:LogInTableViewCell?
        var confirmPasswordCell:LogInTableViewCell?
        var recoveryCell:LogInTableViewCell?
        if let _ = self.tableViewResetPassword.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? LogInTableViewCell{
            emailCell = self.tableViewResetPassword.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? LogInTableViewCell
        }
        if let _ = self.tableViewResetPassword.cellForRow(at: IndexPath.init(row: 1, section: 0)) as? LogInTableViewCell{
            passwordCell = self.tableViewResetPassword.cellForRow(at: IndexPath.init(row: 1, section: 0)) as? LogInTableViewCell
        }
        if let _ = self.tableViewResetPassword.cellForRow(at: IndexPath.init(row: 2, section: 0)) as? LogInTableViewCell{
            confirmPasswordCell = self.tableViewResetPassword.cellForRow(at: IndexPath.init(row: 2, section: 0)) as? LogInTableViewCell
        }
        if let _ = self.tableViewResetPassword.cellForRow(at: IndexPath.init(row: 3, section: 0)) as? LogInTableViewCell{
            recoveryCell = self.tableViewResetPassword.cellForRow(at: IndexPath.init(row: 3, section: 0)) as? LogInTableViewCell
        }
       
         guard emailDetail!.text.count > 0 else{
         DispatchQueue.main.async {
            if let _  = emailCell{
                self.invalidTextField(textField: emailCell!.textFieldLogIn)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "enterEmail.title"))
            }
         }
         return false
         }
         guard emailDetail!.text.isValidEmail() else{
         DispatchQueue.main.async {
            if let _ = emailCell{
                self.invalidTextField(textField: emailCell!.textFieldLogIn)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "pleaseEnterValidEmail.title"))
            }
         }
         return false
         }
         guard passwordDetail!.text.count > 0 else{
         DispatchQueue.main.async {
            if let _ = passwordCell{
                self.invalidTextField(textField: passwordCell!.textFieldLogIn)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "pleaseEnterPassword.title"))
            }
         }
         return false
         }
         guard passwordDetail!.text.count >= minPasswordLength else{
            DispatchQueue.main.async {
                if let _ = passwordCell{
                    self.invalidTextField(textField: passwordCell!.textFieldLogIn)
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "minRequiredPassword"))
                }
         }
         return false
         }
         guard passwordDetail!.text.count <= maxPasswordLength else{
            DispatchQueue.main.async {
                if let _ = passwordCell{
                    self.invalidTextField(textField: passwordCell!.textFieldLogIn)
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "maxRequiredPassword"))
                }
         }
         return false
         }
     guard confirmPasswordDetail!.text.count > 0 else{
     DispatchQueue.main.async {
        if let _ = confirmPasswordCell{
            self.invalidTextField(textField: confirmPasswordCell!.textFieldLogIn)
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "confirmPasswordvalidation"))
        }
     }
     return false
     }
     guard confirmPasswordDetail!.text.count >= minPasswordLength else{
     DispatchQueue.main.async {
        if let _ = confirmPasswordCell{
            self.invalidTextField(textField: confirmPasswordCell!.textFieldLogIn)
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "minConfirmPassword"))
        }
       
     }
     return false
     }
     guard confirmPasswordDetail!.text.count <= maxPasswordLength else{
     DispatchQueue.main.async {
        if let _ = confirmPasswordCell{
            self.invalidTextField(textField: confirmPasswordCell!.textFieldLogIn)
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "maxConfirmPassword"))
        }
     }
     return false
     }
     guard confirmPasswordDetail!.text == passwordDetail!.text else{
     DispatchQueue.main.async {
        ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "confirmPasswordAsPassword"))
     }
     return false
     }
     guard recoverPinDetail!.text.count > 0 else{
     DispatchQueue.main.async {
        if let _ = recoveryCell{
            self.invalidTextField(textField: recoveryCell!.textFieldLogIn)
            ShowToast.show(toatMessage: "please enter recoverycode.")
        }
       
     }
     return false
     }
        if let _ = emailCell{
            self.validTextField(textField: emailCell!.textFieldLogIn)
        }
        if let _ = passwordCell{
            self.validTextField(textField: passwordCell!.textFieldLogIn)

        }
        if let _ = confirmPasswordCell{
            self.validTextField(textField: confirmPasswordCell!.textFieldLogIn)

        }
        if let _ = recoveryCell{
            self.validTextField(textField: recoveryCell!.textFieldLogIn)

        }
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
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    print("===== keyboardWillShow \(keyboardSize) =====" )
                    print(UIScreen.main.bounds.height)
                    self.tableViewResetPassword.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height+120, 0)
                    self.topUpdatePassword.isActive = true
                    self.bottomUpdatePassword.isActive = false
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    print("===== keyboardWillHide \(keyboardSize) =====" )
                    print(UIScreen.main.bounds.height)
                    self.topUpdatePassword.isActive = false
                    self.bottomUpdatePassword.isActive = true
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackGroundSelector(sender:UIButton){
        self.view.endEditing(true)
    }
    @IBAction func buttonBackSelector(sender:UIButton){
        self.popToBackViewController()
    }
    @IBAction func buttonResetSelector(sender:UIButton){
        //if recoveryDetail != nil {
            self.postResetPasswordAPI()
        //} else {
        //  ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "err_recovery"))
        //}
    }
    // MARK: - API Request Methods
    func postResetPasswordAPI(){
        if self.isValidResetPassword(){
            let resetParameters =
                ["Email":"\(self.emailDetail!.text)",
                 "RecoverCode":"\(self.recoverPinDetail!.text)",
                  "Password":"\(self.passwordDetail!.text)"
                    ] as [String : AnyObject]
            
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kResetPassword, parameter:resetParameters,isHudeShow: true,success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let userInfo = success["data"] as? [String:Any],let strMessage = userInfo["Message"]{
                    DispatchQueue.main.async {
                        let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key: "resetPassword"), message: "\(strMessage)", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key: "ok.title"), style: .default, handler: { (_) in
                            self.navigationController?.popToRootViewController(animated: true)
                        }))
                        self.present(alertController, animated: true, completion: nil)
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
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    func popToBackViewController(){
        let filterd = self.navigationController?.viewControllers.filter { $0 is ForgotPasswordViewController}
        if let arrayFilter = filterd,arrayFilter.count > 0{
            self.navigationController?.popToViewController(arrayFilter.first!, animated: true)
        }
        
        
        //self.navigationController?.popViewController(animated: true)
    }
}
extension ResetPasswordViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfResetPassword.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resetCell:LogInTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LogInTableViewCell", for: indexPath) as! LogInTableViewCell
        guard self.arrayOfResetPassword.count > indexPath.row else {
            return resetCell
        }
        resetCell.textFieldLogIn.delegate = self
        resetCell.textFieldLogIn.tag = indexPath.row
        let detail = self.arrayOfResetPassword[indexPath.row]
        resetCell.textFieldLogIn.tweePlaceholder = "\(detail.placeHolder)"
        DispatchQueue.main.async {
            resetCell.textFieldLogIn.text = "\(detail.text)"
        }
        resetCell.textFieldLogIn.keyboardType = detail.keyboardType
        resetCell.textFieldLogIn.returnKeyType = detail.returnKey
        resetCell.textFieldLogIn.isSecureTextEntry = detail.isSecure
        resetCell.btnDropDown.setImage(#imageLiteral(resourceName: "passwordDisable_black"), for: .normal)
        if indexPath.row == 1 || indexPath.row == 2 {
            resetCell.btnDropDown.alpha = 0.5
            resetCell.btnDropDown.isHidden = false
            resetCell.btnDropDown.tag = 101
        } else {
            resetCell.btnDropDown.alpha = 1.0
            resetCell.btnDropDown.isHidden = true
        }
        resetCell.setTextFieldColor(textColor:UIColor.black.withAlphaComponent(0.95),placeHolderColor: UIColor.black)
        resetCell.selectionStyle = .none
        resetCell.textFieldLogIn.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1).pointSize
        resetCell.textFieldLogIn.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        resetCell.textFieldLogIn.placeHolderFont = UIFont.init(name: "Avenir-Roman", size: 14.0)
        DispatchQueue.main.async {
            resetCell.trailingButtonDropDown.constant = 20.0
        }
        return resetCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightOfTableViewCell
    }
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return  tableView.bounds.height - (self.heightOfTableViewCell * 4)//tableViewFooterHeight
//    }
}
extension ResetPasswordViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard !typpedString.isContainWhiteSpace() else{
            return false
        }
        
        let tag = textField.tag
        let detail = self.arrayOfResetPassword[tag]
        detail.text = "\(typpedString)"
        
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        let detail = self.arrayOfResetPassword[tag]
        detail.text = ""
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if self.isValidResetPassword(){
               guard (self.arrayOfResetPassword.count-1) != textField.tag else{
                    //PostResetPasswordAPI
                    self.postResetPasswordAPI()
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
