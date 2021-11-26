//
//  SignInViewController.swift
//  Live
//
//  Created by ITPATH on 4/3/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import Security

let kLightGray:UIColor = UIColor.rgb(155.0, green: 155.0, blue: 155.0)

class LogIn{
    var placeHolder:String
    var text:String
    var keyboardType:UIKeyboardType
    var returnKey:UIReturnKeyType
    var isSecure:Bool
    init(placeHolder: String, text:String,keyboardType:UIKeyboardType,returnKey:UIReturnKeyType,isSecure:Bool){
        self.placeHolder = placeHolder
        self.text = text
        self.keyboardType = keyboardType
        self.returnKey = returnKey
        self.isSecure = isSecure
    }
}
class SignInViewController: UIViewController {

    @IBOutlet var containerViewTop:NSLayoutConstraint!
    @IBOutlet var containerViewBottom:NSLayoutConstraint!
   
    @IBOutlet var buttonBack:UIButton!
    @IBOutlet var tableViewLogIn:UITableView!
    @IBOutlet var tableViewFooterView:UIView!
    
    @IBOutlet var buttonRememberMe:UIButton!
    @IBOutlet var buttonForgotPassword:UIButton!
    @IBOutlet var buttonSignIn:RoundButton!
    @IBOutlet var buttonSignOn:RoundButton!
    
    let heightOfTableViewFooterView:CGFloat = 180.0
    let heightOfTableViewCell:CGFloat = 80.0
    var isSaved:Bool = true
    var isRememberMe:Bool{
        get{
            return isSaved
        }
        set{
            self.isSaved = newValue
            self.configureRememberMe()
        }
    }
    var arrayOfLogInDetail:[LogIn] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure ContainerWith SafeArea
        self.configureSafeAreaContainer()
        //Configure LoginDetails
        self.configureLogInDetails()
        //Configure TableView
        self.configureTableView()
        //Configure Footer
        self.configureFooterView()
        self.buttonSignIn.setBackgroundColor(color: UIColor.black.withAlphaComponent(0.3), forState: .highlighted)
        self.buttonSignOn.setBackgroundColor(color: UIColor.black.withAlphaComponent(0.3), forState: .highlighted)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //hide navigationBar
        self.navigationController?.navigationBar.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
    func configureSafeAreaContainer(){
        self.containerViewTop.constant = self.containerTopContant
        self.containerViewBottom.constant = self.containerBottomConstant
    }
    func configureLogInDetails(){
        let emailDetail = LogIn.init(placeHolder: "Email", text: "", keyboardType: .emailAddress, returnKey: .next, isSecure: false)
        let passDetail = LogIn.init(placeHolder: "Password", text: "", keyboardType: .default, returnKey: .done, isSecure: true)
        self.arrayOfLogInDetail = [emailDetail,passDetail]
    }
    func configureTableView(){
        self.tableViewLogIn.tableHeaderView = UIView()
        self.tableViewLogIn.rowHeight = UITableViewAutomaticDimension
        self.tableViewLogIn.estimatedRowHeight = 100
        self.tableViewLogIn.delegate = self
        self.tableViewLogIn.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "LogInTableViewCell", bundle: nil)
        self.tableViewLogIn.register(objNib, forCellReuseIdentifier: "LogInTableViewCell")
        self.tableViewLogIn.tableFooterView = UIView()
        self.tableViewLogIn.separatorStyle = .none
        self.tableViewLogIn.reloadData()
    }
    func configureFooterView(){
        self.buttonSignIn.addBorderWith(width: 1.5, color: kLightGray)
        self.buttonSignOn.addBorderWith(width: 1.5, color: kLightGray)
    }
    func configureRememberMe(){
        if(self.isRememberMe){
            self.buttonRememberMe.setImage(#imageLiteral(resourceName: "check").withRenderingMode(.alwaysOriginal), for: .normal)
        }else{
            self.buttonRememberMe.setImage(#imageLiteral(resourceName: "uncheck").withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    // MARK: - API Request Methods
    func postLogInAPIRequest(){
        self.view.endEditing(true)
     //   if(self.isValidLogIn()){
        //Dynamic data
        //let logInParameters = ["Email":"\(self.arrayOfLogInDetail[0].text)","password":"\(self.arrayOfLogInDetail[1].text)"]
        //Static data
    let logInParameters = ["Email":"jinkalr@itpathsolutions.co.in","Password":"1234","DeviceId":"\(UIDevice.current.identifierForVendor!.uuidString)","DeviceType":"iPhone"] as [String : AnyObject]
            APIRequestClient.shared.sendLogInRequest(requestType: .POST, queryString:kLogInString, parameter:logInParameters,isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let accessToken = success["AccessToken"],let userInfo = success["data"] as? [String:Any]{
                
                    let objUser = User.init(accesToken:"\(accessToken)", userDetail: userInfo)
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
         //}
        }
   

    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonRememberMeSelector(sender:UIButton){
        self.isRememberMe = !self.isRememberMe
    }
    @IBAction func buttonForgotPasswordSelector(sender:UIButton){
            self.view.endEditing(true)
            self.pushToForgotPasswordController()
    }
    @IBAction func buttonSignInSelector(sender:UIButton){
        self.postLogInAPIRequest()
    }
    @IBAction func buttonSignUpSelector(sender:UIButton){
        self.view.endEditing(true)
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    func pushToHomeViewController(){
        if let homeViewController:HomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController{
            self.navigationController?.pushViewController(homeViewController, animated: true)
        }
    }
    func pushToForgotPasswordController(){
        if let forgotPasswordViewController:ForgotPasswordViewController = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as? ForgotPasswordViewController{
            self.navigationController?.pushViewController(forgotPasswordViewController, animated: true)
        }
    }
}
extension SignInViewController:UITableViewDelegate,UITableViewDataSource{
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfLogInDetail.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let logInCell:LogInTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LogInTableViewCell", for: indexPath) as! LogInTableViewCell
        guard self.arrayOfLogInDetail.count > indexPath.row else {
            return logInCell
        }
        
        logInCell.tag = indexPath.row
        logInCell.textFieldLogIn.delegate = self
        logInCell.textFieldLogIn.tag = indexPath.row + 10
        let detail = arrayOfLogInDetail[indexPath.row]
            logInCell.textFieldLogIn.tweePlaceholder = "\(detail.placeHolder)"
            logInCell.textFieldLogIn.text = "\(detail.text)"
            logInCell.textFieldLogIn.keyboardType = detail.keyboardType
            logInCell.textFieldLogIn.returnKeyType = detail.returnKey
            logInCell.textFieldLogIn.isSecureTextEntry = detail.isSecure
        
        return logInCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightOfTableViewCell
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.heightOfTableViewFooterView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.tableViewFooterView
    }
}
extension SignInViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard !typpedString.isContainWhiteSpace() else{
            return false
        }
        let tag = textField.tag - 10
        let detail = arrayOfLogInDetail[tag]
        detail.text = "\(typpedString)"
        
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        let tag = textField.tag - 10
        let detail = arrayOfLogInDetail[tag]
        detail.text = ""
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.tag == 10 { //
            self.view.viewWithTag(11)?.becomeFirstResponder()
        }else if textField.tag == 11{
            //PostLogInRequest
            self.postLogInAPIRequest()
        }
        return true
    }
    func isValidLogIn()->Bool{
        let minPasswordLength:Int = 6
        let maxPasswordLength:Int = 15
            let email:LogIn = arrayOfLogInDetail[0]
            let password:LogIn = arrayOfLogInDetail[1]

            guard email.text.count > 0 else{
                ShowToast.show(toatMessage: "please enter email.")
                return false
            }
            guard email.text.isValidEmail() else{
                ShowToast.show(toatMessage: "please enter valid email.")
                return false
            }
            guard password.text.count > 0 else{
                ShowToast.show(toatMessage: "please enter password.")
                return false
            }
            guard password.text.count >= minPasswordLength else{
                ShowToast.show(toatMessage: "please enter minimume 6 characters password.")
                return false
            }
            guard password.text.count <= maxPasswordLength else{
                ShowToast.show(toatMessage: "please enter maximume 15 characters password.")
                return false
            }
            return true
    }
}
