//
//  EditUserNameViewController.swift
//  Live
//
//  Created by IPS on 07/06/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class EditUserNameViewController: UIViewController,UIGestureRecognizerDelegate {

    private var kFirstName:String = "FirstName"
    private var kLastName:String = "LastName"
    
    @IBOutlet var lblEditName:UILabel!
    @IBOutlet var txtFirstName:TweeActiveTextField!
    @IBOutlet var txtLastName:TweeActiveTextField!
    @IBOutlet var btnCancel:RoundButton!
    @IBOutlet var btnSave:RoundButton!
    @IBOutlet var btnCancelAll:UIButton!
    @IBOutlet var containerView:UIView!
    @IBOutlet var bottomConstraintSave:NSLayoutConstraint!
    @IBOutlet weak var editUserNameTableView: UITableView!
    let heightOfTableViewCell:CGFloat = 88.0
    var arrayOfEditUserName:[TextFieldDetail] = []
    var firstNameDetail:TextFieldDetail?
    var lastNameDetail:TextFieldDetail?
    
    var updateUserNameParameters:[String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblEditName.text = Vocabulary.getWordFromKey(key: "EditName")
        self.txtLastName.tweePlaceholder = Vocabulary.getWordFromKey(key: "lastName.title")
        self.txtFirstName.tweePlaceholder = Vocabulary.getWordFromKey(key: "firstName.title")
        self.btnSave.isEnabled = true
        self.btnSave.setTitle(Vocabulary.getWordFromKey(key: "save.title"), for: .normal)
        self.btnCancel.setTitle(Vocabulary.getWordFromKey(key: "Cancel"), for: .normal)
        NotificationCenter.default.addObserver(self, selector: #selector(EditUserNameViewController.keyboardWillShowEditProfile(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditUserNameViewController.keyboardWillHideEditProfile(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        //Configure Edit UserName
        self.configureEditUserName()
        
        self.configureTableView()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        NotificationCenter.default.removeObserver(self)
    }
    func addDynamicFont(){
        
        self.lblEditName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblEditName.adjustsFontForContentSizeCategory = true
        self.lblEditName.adjustsFontSizeToFitWidth = true
        
        self.btnCancel.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
        self.btnCancel.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnCancel.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.btnSave.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.btnSave.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnSave.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //self.txtFirstName.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1).pointSize
        self.txtFirstName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.txtFirstName.adjustsFontForContentSizeCategory = true
        self.txtFirstName.minimizePlaceholder()
        //self.txtLastName.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1).pointSize
        self.txtLastName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.txtLastName.adjustsFontForContentSizeCategory = true
        self.txtLastName.minimizePlaceholder()
    }
    // MARK: - Custom Methods
    func configureTableView(){
        self.editUserNameTableView.rowHeight = UITableViewAutomaticDimension
        self.editUserNameTableView.estimatedRowHeight = 88.0
        self.editUserNameTableView.delegate = self
        self.editUserNameTableView.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "LogInTableViewCell", bundle: nil)
        self.editUserNameTableView.register(objNib, forCellReuseIdentifier: "LogInTableViewCell")
        // self.tableViewLogIn.tableFooterView = self.tableViewFooterView
        self.editUserNameTableView.separatorStyle = .none
        self.editUserNameTableView.reloadData()
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(EditUserNameViewController.handleTap))
        tapGR.delegate = self
        tapGR.numberOfTapsRequired = 1
        self.editUserNameTableView.addGestureRecognizer(tapGR)
    }
    @objc func handleTap(_ gesture: UITapGestureRecognizer){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    func configureEditUserName(){
        self.txtFirstName.delegate = self
        self.txtLastName.delegate = self
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 12.0
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            self.updateUserNameParameters[kFirstName] = "\(currentUser.userFirstName)"
            self.updateUserNameParameters[kLastName] = "\(currentUser.userLastName)"
            DispatchQueue.main.async {
                self.txtFirstName.text = "\(currentUser.userFirstName)"
                self.txtLastName.text = "\(currentUser.userLastName)"
            }
            firstNameDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "firstName.title"), text: "\(currentUser.userFirstName)", keyboardType: .default, returnKey: .next, isSecure: false)
            lastNameDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key:"lastName.title"), text: "\(currentUser.userLastName)", keyboardType: .default, returnKey: .done, isSecure: false)
            self.arrayOfEditUserName = [firstNameDetail!,lastNameDetail!]

            self.btnCancel.setBackgroundColor(color:UIColor.init(hexString:"2963AF"), forState: .highlighted)
            //self.btnSave.setBackgroundColor(color:UIColor.init(hexString:"2963AF"), forState: .highlighted)
            self.btnCancel.applyGradient(colours: [UIColor.white.withAlphaComponent(0.1),UIColor.init(hexString:"2963AF").withAlphaComponent(0.2),
                                                      UIColor.init(hexString:"2963AF").withAlphaComponent(0.5), UIColor.init(hexString:"2963AF")])
            /*self.btnSave.applyGradient(colours: [UIColor.white.withAlphaComponent(0.1),UIColor.init(hexString:"2963AF").withAlphaComponent(0.2),
                                                      UIColor.init(hexString:"2963AF").withAlphaComponent(0.5),UIColor.init(hexString:"2963AF")])*/
        }
    }
    func isValidUserName()->Bool{
        guard let userFirstName = self.updateUserNameParameters[kFirstName] as? String,userFirstName.count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFirstName)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "firstNameValidation"))
            }
            return false
        }
        guard let userLasttName = self.updateUserNameParameters[kLastName] as? String,userLasttName.count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtLastName)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"lastNameValidation"))
            }
            return false
        }
        self.validTextField(textField: self.txtFirstName)
        self.validTextField(textField: self.txtLastName)
        return true
    }
    func invalidTextField(textField:TweeActiveTextField){
        textField.placeholderColor = .red
        textField.activeLineColor = .red
        textField.lineColor = .red
        textField.invalideField()
    }
    func validTextField(textField:TweeActiveTextField){
        textField.placeholderColor = UIColor.darkGray
        textField.activeLineColor = .darkGray
        textField.lineColor = .darkGray
    }
    
    // MARK: - API Request Methods
    func updateUserNameAPIRequest(){
        if self.isValidUserName(),User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            let updateUserNameRequestURL = "guides/\(currentUser.userID)/native/guidename"
            APIRequestClient.shared.sendRequest(requestType: .PUT, queryString:updateUserNameRequestURL , parameter: self.updateUserNameParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let guideDetail = successData["Guide"] as? [String:Any], let strMsg = successData["Message"]{
                    DispatchQueue.main.async {
                        if let firstName = guideDetail[self.kFirstName],let lastName = guideDetail[self.kLastName]{
                            currentUser.userFirstName = "\(firstName)"
                            currentUser.userLastName = "\(lastName)"
                            currentUser.setUserDataToUserDefault()
                        }
                        let objAlert = UIAlertController(title:Vocabulary.getWordFromKey(key:"Success"), message: "\(strMsg)",preferredStyle: UIAlertControllerStyle.alert)
                        objAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (action: UIAlertAction!) in
                            self.performSegue(withIdentifier: "unwindToSettingViewFromChangeUserName", sender: nil)

                            self.dismiss(animated:true, completion: nil)
                        }))
                        objAlert.view.tintColor = UIColor.init(hexString: "#36527D")
                        self.present(objAlert, animated: true, completion: nil)
                    }
                }else{
                    DispatchQueue.main.async {
                       // ShowToast.show(toatMessage:kCommonError)
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
    
    // MARK: - Selector Methods
    @objc func keyboardWillShowEditProfile(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async {
                //self.descriptionTxtView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height + 30.0, 0)
                UIView.animate(withDuration: 0.1, animations: {
                    print("Keyboard height \(keyboardSize.height)")
                    self.bottomConstraintSave.constant = self.getKeyboardSizeHeight()
                    self.loadViewIfNeeded()
                }, completion: { (true) in
                })
            }
            
        }
    }
    
    @objc func keyboardWillHideEditProfile(notification: NSNotification) {
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
    @IBAction func buttonCancelSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func buttonSaveSelector(sender:RoundButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        self.updateUserNameAPIRequest()
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
extension EditUserNameViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfEditUserName.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let changeCell:LogInTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LogInTableViewCell", for: indexPath) as! LogInTableViewCell
        guard self.arrayOfEditUserName.count > indexPath.row else {
            return changeCell
        }
        changeCell.textFieldLogIn.delegate = self
        changeCell.textFieldLogIn.tag = indexPath.row
        let detail = self.arrayOfEditUserName[indexPath.row]
        DispatchQueue.main.async {
            changeCell.textFieldLogIn.tweePlaceholder = "\(detail.placeHolder)"
            changeCell.textFieldLogIn.text = "\(detail.text)"
        }
        changeCell.textFieldLogIn.keyboardType = detail.keyboardType
        changeCell.textFieldLogIn.returnKeyType = detail.returnKey
        changeCell.textFieldLogIn.isSecureTextEntry = detail.isSecure
        //changeCell.btnDropDown.setImage(#imageLiteral(resourceName: "passwordDisable_black").withRenderingMode(.alwaysTemplate), for: .normal)
        //changeCell.btnDropDown.imageView?.tintColor = UIColor.black.withAlphaComponent(0.5)
        changeCell.btnDropDown.isHidden = true
        //changeCell.btnDropDown.tag = 101
        changeCell.setTextFieldColor(textColor: .black,placeHolderColor: UIColor.black)
        changeCell.selectionStyle = .none
        return changeCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightOfTableViewCell
    }
}
extension EditUserNameViewController:UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard !typpedString.isContainWhiteSpace() else{
            return false
        }
        if textField.tag == 0{//if textField == self.txtFirstName{
            //self.validTextField(textField: self.txtFirstName)
            self.updateUserNameParameters[kFirstName] = "\(typpedString)"
        }else if textField.tag == 1{//textField == self.txtLastName{
            //self.validTextField(textField: self.txtLastName)
            self.updateUserNameParameters[kLastName] = "\(typpedString)"
        }else{
            
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField.tag == 0{//if textField == self.txtFirstName{
            self.updateUserNameParameters[kFirstName] = ""
        }else if textField.tag == 1{//textField == self.txtLastName{
            self.updateUserNameParameters[kLastName] = ""
        }else{
            
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.tag == 0{//if textField == self.txtFirstName{
            self.view.viewWithTag(textField.tag+1)?.becomeFirstResponder()
            return true
            //self.txtLastName.becomeFirstResponder()
        }else if textField.tag == 1{//}else if textField == self.txtLastName{
            self.updateUserNameAPIRequest()
        }
        return true
    }
}

