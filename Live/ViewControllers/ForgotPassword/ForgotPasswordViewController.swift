//
//  ForgotPasswordViewController.swift
//  Live
//
//  Created by ITPATH on 4/11/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var forgotDescriptionLbl: UILabel!
    @IBOutlet weak var forgotPasswordLbl: UILabel!
    @IBOutlet weak var lblNavTitle: UILabel!
    @IBOutlet var txtEmail:TweeActiveTextField!
    @IBOutlet var btnSend:RoundButton!
    @IBOutlet var btnRecoveryCode:UIButton!
    @IBOutlet var buttonBackgroundShadow:UIButton!
    @IBOutlet var bottomLayOutConstraint:NSLayoutConstraint!
    @IBOutlet var buttonBack:UIButton!
    
    var userEmailID:String = ""
    // MARK: - UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.changeTextAccordingLanguage()
        //Configure View
        self.configureView()
        //Configure Keyboard hide show
        NotificationCenter.default.addObserver(self, selector: #selector(ForgotPasswordViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ForgotPasswordViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.txtEmail.textColor = UIColor.black.withAlphaComponent(0.95)
        self.txtEmail.placeholderColor = UIColor.black
        self.swipeToPop()
    }
    func swipeToPop() {
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        NotificationCenter.default.removeObserver(self)
    }
    func changeTextAccordingLanguage() {
        self.forgotDescriptionLbl.text = Vocabulary.getWordFromKey(key: "forgotPasswordDescription")
        self.lblNavTitle.text = Vocabulary.getWordFromKey(key: "recoverPassword.title")
        self.btnSend.setTitle(Vocabulary.getWordFromKey(key: "next.title"), for: .normal)
        self.btnRecoveryCode.setTitle(Vocabulary.getWordFromKey(key: "alreadygotrecoverycode.hint"), for: .normal)
        self.forgotPasswordLbl.text = Vocabulary.getWordFromKey(key: "title.forgotpassword")
        self.txtEmail.tweePlaceholder = Vocabulary.getWordFromKey(key: "email.placeholder")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .default
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        
        //self.forgotDescriptionLbl.font = CommonClass.shared.getScaledWithOutMinimum(forFont: "Avenir-Roman",textStyle: .caption1)//CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        //self.forgotDescriptionLbl.adjustsFontForContentSizeCategory = true
        //self.forgotDescriptionLbl.adjustsFontSizeToFitWidth = true
        
        self.lblNavTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblNavTitle.adjustsFontForContentSizeCategory = true
        self.lblNavTitle.adjustsFontSizeToFitWidth = true
        self.txtEmail.placeHolderFont = UIFont.init(name: "Avenir-Heavy", size: 14.0)
        //self.txtEmail.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1).pointSize
        self.txtEmail.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtEmail.adjustsFontForContentSizeCategory = true
        
//        self.btnRecoveryCode.titleLabel?.font =  CommonClass.shared.getScaledWithOutMinimum(forFont: "Avenir-Heavy",textStyle: .footnote)
        //CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.btnRecoveryCode.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnRecoveryCode.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.btnSend.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.btnSend.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnSend.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackgroundShadowSelector(sender:UIButton){
        self.view.endEditing(true)
    }
    @IBAction func buttonSendSelector(sender:UIButton){
        self.view.endEditing(true)
        self.postForgotPasswordAPI()
    }
    @IBAction func buttonBackSelector(sender:UIButton){
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonRecoverySelector(sender:UIButton){
        self.view.endEditing(true)
        self.pushToResetPassword()
    }
    // MARK: - Custom Methods
    func configureView(){
        self.buttonBack.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.buttonBack.imageView?.tintColor = UIColor.black
        self.txtEmail.delegate = self
        self.txtEmail.placeHolderFont = UIFont.init(name: "Avenir-Roman", size: 14.0)
        self.btnSend.setBackgroundColor(color: UIColor.lightGray.withAlphaComponent(0.5), forState: UIControlState.highlighted)
        DispatchQueue.main.async {
            self.txtEmail.text = "\(self.userEmailID)"
        }
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    self.bottomLayOutConstraint.constant = -(keyboardSize.height + (UIScreen.main.bounds.height == 568 ? 33:50))
                    print("===== keyboardWillShow \(keyboardSize) =====" )
                    print(UIScreen.main.bounds.height)
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    self.bottomLayOutConstraint.constant = 0
                    print(keyboardSize)
                    print(UIScreen.main.bounds.height)
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    // MARK: - APi Methods
    func postForgotPasswordAPI(){
        if(self.isValidEmail()){
            let requestParam = ["Email":"\(self.userEmailID)"] as [String:AnyObject]
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kRecoveryCode , parameter: requestParam, isHudeShow: true, success: { (responseSuccess) in
                if  let successJSON = responseSuccess as? [String:Any],let successdata = successJSON["data"] as? [String:Any],let _ = successdata["RecoverCodeLength"],let message = successdata["Message"] as? String{
                    
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:message)
                        //Push to Recovery
                        self.pushToRecoveryViewController()
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
    func pushToRecoveryViewController(){
        if let recoveryViewController = self.storyboard?.instantiateViewController(withIdentifier: "RecoverPasswordViewController") as? RecoverPasswordViewController{
            recoveryViewController.userEmailID = "\(self.userEmailID)"
            self.navigationController?.pushViewController(recoveryViewController, animated: true)
        }
    }
    //Push To reset password
    func pushToResetPassword(){
        if let resetPassword = self.storyboard?.instantiateViewController(withIdentifier:"ResetPasswordViewController") as? ResetPasswordViewController{
            resetPassword.userEmailID = "\(self.userEmailID)"
            self.navigationController?.pushViewController(resetPassword, animated: true)
        }
    }
}
extension ForgotPasswordViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard !typpedString.isContainWhiteSpace() else{
            return false
        }
        self.userEmailID = "\(typpedString)"
        
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.userEmailID = ""
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        //PostForgptPassword
        self.postForgotPasswordAPI()
        return true
    }
    func isValidEmail()->Bool{
        guard self.userEmailID.count > 0 else{
            DispatchQueue.main.async {
                self.txtEmail.activeLineColor = .red
                self.txtEmail.lineColor = .red
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "enterEmail.title"))
                self.txtEmail.invalideField()
            }
            return false
        }
        guard self.userEmailID.isValidEmail() else{
            DispatchQueue.main.async {
                self.txtEmail.activeLineColor = .red
                self.txtEmail.lineColor = .red
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "pleaseEnterValidEmail.title"))
                self.txtEmail.invalideField()
            }
            return false
        }
        self.txtEmail.activeLineColor = .black
        self.txtEmail.lineColor = .black
        return true
    }
}
