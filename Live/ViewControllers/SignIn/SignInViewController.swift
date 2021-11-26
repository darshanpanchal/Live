//
//  SignInViewController.swift
//  Live
//
//  Created by ITPATH on 4/3/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import Security
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SendBirdSDK
import CoreLocation

let kLightGray:UIColor = UIColor.rgb(155.0, green: 155.0, blue: 155.0)

class TextFieldDetail{
    var placeHolder:String
    var minimumPlaceHolder:String
    var text:String
    var keyboardType:UIKeyboardType
    var returnKey:UIReturnKeyType
    var isSecure:Bool
    init(placeHolder: String,minimumPlaceHolder:String = "", text:String,keyboardType:UIKeyboardType,returnKey:UIReturnKeyType,isSecure:Bool){
        self.placeHolder = placeHolder
        self.minimumPlaceHolder = minimumPlaceHolder.count > 0 ? minimumPlaceHolder:placeHolder
        self.text = text
        self.keyboardType = keyboardType
        self.returnKey = returnKey
        self.isSecure = isSecure
    }
    
}

class SignInViewController: UIViewController {

    @IBOutlet var containerViewTop:NSLayoutConstraint!
    @IBOutlet var containerViewBottom:NSLayoutConstraint!
   
    @IBOutlet weak var tableViewHeaderView: UIView!
    @IBOutlet var buttonSkip:UIButton!
    @IBOutlet var tableViewLogIn:UITableView!
    @IBOutlet var tableViewFooterView:UIView!
    @IBOutlet var butttonCheck:UIButton!
    @IBOutlet var buttonBackgroundShadow:UIButton!
    @IBOutlet var buttonRememberMe:UIButton!
    @IBOutlet var buttonForgotPassword:UIButton!
    
    @IBOutlet var buttonSignIn:UIButton!
    @IBOutlet var buttonSignInShadow:UIButton!
    @IBOutlet var buttonSignOn:UIButton!
    @IBOutlet var buttonSignOnShadow:UIButton!
    @IBOutlet var buttonFacebookLogin: UIButton!
    @IBOutlet var buttonFacebookLoginShadow: UIButton!
    @IBOutlet var buttonGuestRequest: UIButton!
    @IBOutlet var buttonGuestRequestShadow: UIButton!
    
    let heightOfTableViewFooterView:CGFloat = 350.0
    let heightOfTableViewCell:CGFloat = 90.0
    let heightOfTableViewHeaderView:CGFloat = 163.0
    
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
    var arrayOfLogInDetail:[TextFieldDetail] = []
    var locationManager:CLLocationManager = CLLocationManager()
    var latitude:String = ""
    var longitude:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        //Configure LoginDetails
        self.configureLogInDetails(userEmail:"", userPassword:"")
        //Configure TableView
        self.configureTableView()
        //Custom Button
        self.configureButton()
        //Check for login status
        self.checkForLogInStatus()
        //self.tableViewLogIn.isScrollEnabled = (UIScreen.main.bounds.height == 568)
        self.configureLocationManager()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.endEditing(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.buttonRememberMe.setTitle(Vocabulary.getWordFromKey(key: "title.rememberMe"), for: .normal)
            self.buttonSkip.setTitle(Vocabulary.getWordFromKey(key: "title.skip"), for: .normal)
            self.buttonSignIn.setTitle(Vocabulary.getWordFromKey(key: "title.signIn"), for: .normal)
            self.buttonForgotPassword.setTitle(Vocabulary.getWordFromKey(key: "title.forgotpassword"), for: .normal)
            self.buttonGuestRequest.setTitle(Vocabulary.getWordFromKey(key: "QualifiedGuideRequest"), for: .normal)
            self.buttonSignOn.setTitle(Vocabulary.getWordFromKey(key: "registerAsTraveler.hint"), for: .normal)
            self.buttonFacebookLogin.setTitle(Vocabulary.getWordFromKey(key: "title.FBLogIn"), for: .normal)
            
           // self.addDynamicFont()
            
            self.addButtonBorder()
            self.view.endEditing(true)
            if let _ = self.tableViewLogIn.tableHeaderView{
                 self.tableViewLogIn.tableFooterView?.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.tableViewLogIn.bounds.width, height:180.0))
            }
            if let _ = self.tableViewLogIn.tableFooterView{
                self.tableViewLogIn.tableFooterView?.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.tableViewLogIn.bounds.width, height: 400.0))
            }
            //self.tableViewLogIn.setContentOffset(.zero, animated: true)
        }
        
        //hide navigationBar
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .lightContent
        //Fill logindetail if already logged in and remember
        self.fillLogInDetail()
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopUpdatingLocation()
        self.locationManager.delegate = nil
    }
    func configureLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
    }
    func addDynamicFont(){
        self.buttonSkip.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonSkip.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonSkip.titleLabel?.adjustsFontSizeToFitWidth = true
//        self.buttonRememberMe.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman",textStyle: .footnote)
//        self.buttonRememberMe.titleLabel?.adjustsFontForContentSizeCategory = true
//        self.buttonRememberMe.titleLabel?.adjustsFontSizeToFitWidth = true
        self.buttonSignIn.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonSignIn.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonSignIn.titleLabel?.adjustsFontSizeToFitWidth = true
//        self.buttonForgotPassword.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman",textStyle: .footnote)
//        self.buttonForgotPassword.titleLabel?.adjustsFontForContentSizeCategory = true
//        self.buttonForgotPassword.titleLabel?.adjustsFontSizeToFitWidth = true
        self.buttonGuestRequest.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonGuestRequest.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonGuestRequest.titleLabel?.adjustsFontSizeToFitWidth = true
        self.buttonSignOn.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonSignOn.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonSignOn.titleLabel?.adjustsFontSizeToFitWidth = true
        self.buttonFacebookLogin.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonFacebookLogin.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonFacebookLogin.titleLabel?.adjustsFontSizeToFitWidth = true
        self.tableViewLogIn.reloadData()
        
    }
    func addButtonBorder(){
        self.buttonSignIn.clipsToBounds = true
        self.buttonSignIn.layer.cornerRadius = 4.0
        self.buttonGuestRequest.clipsToBounds = true
        self.buttonGuestRequest.layer.cornerRadius = 4.0
        self.buttonSignOn.clipsToBounds = true
        self.buttonSignOn.layer.cornerRadius = 4.0
        self.buttonFacebookLogin.clipsToBounds = true
        self.buttonFacebookLogin.layer.cornerRadius = 4.0
        self.buttonSignInShadow.clipsToBounds = true
        self.buttonSignInShadow.layer.cornerRadius = 4.0
        self.buttonGuestRequestShadow.clipsToBounds = true
        self.buttonGuestRequestShadow.layer.cornerRadius = 4.0
        self.buttonSignOnShadow.clipsToBounds = true
        self.buttonSignOnShadow.layer.cornerRadius = 4.0
        self.buttonFacebookLoginShadow.clipsToBounds = true
        self.buttonFacebookLoginShadow.layer.cornerRadius = 4.0
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
    func fillLogInDetail(){
        if let userName = kUserDefault.value(forKey:kUserName),let password = kUserDefault.value(forKey: kUserPassword){
            self.configureLogInDetails(userEmail: "\(userName)", userPassword:"\(password)")
        }else{
            self.configureLogInDetails(userEmail:"", userPassword:"")
        }
    }
    func checkForLogInStatus(){
        if (User.isUserLoggedIn){
//            guard User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(),!currentUser.isUserBlock else {
//                self.present(CommonClass.shared.userBlockAlert, animated: true, completion: nil)
//                return
//            }
            if let whereToNextController:WhereToNextViewController = self.storyboard?.instantiateViewController(withIdentifier: "WhereToNextViewController") as? WhereToNextViewController{
                whereToNextController.isPushToHome = true
                whereToNextController.isAnimatedPush = false
                self.navigationController?.pushViewController(whereToNextController, animated: false)
            }
        }
    }
    func configureButton(){
        self.buttonFacebookLogin.setBackgroundColor(color: UIColor.lightGray.withAlphaComponent(0.5), forState: UIControlState.highlighted)
        self.buttonSignOn.setBackgroundColor(color: UIColor.lightGray.withAlphaComponent(0.5), forState: UIControlState.highlighted)
        self.buttonSignIn.setBackgroundColor(color: UIColor.lightGray.withAlphaComponent(0.5), forState: UIControlState.highlighted)
        self.buttonGuestRequest.setBackgroundColor(color:UIColor.lightGray.withAlphaComponent(0.5), forState: UIControlState.highlighted)
    }
    
    func configureLogInDetails(userEmail:String,userPassword:String){
        let emailDetail = TextFieldDetail.init(placeHolder: Vocabulary.getWordFromKey(key: "forExistingCustomer.hint"), text: "\(userEmail)", keyboardType: .emailAddress, returnKey: .next, isSecure: false)
        let passDetail = TextFieldDetail.init(placeHolder:  Vocabulary.getWordFromKey(key: "password.placeholder"), text: "\(userPassword)", keyboardType: .default, returnKey: .done, isSecure: true)
        self.arrayOfLogInDetail = [emailDetail,passDetail]
        DispatchQueue.main.async {
            self.tableViewLogIn.reloadData()
        }

    }
    func configureTableView(){
       // self.tableViewLogIn.tableHeaderView = self.tableViewHeaderView
        self.tableViewLogIn.rowHeight = UITableViewAutomaticDimension
        self.tableViewLogIn.estimatedRowHeight = 50.0
        self.tableViewLogIn.delegate = self
        self.tableViewLogIn.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "LogInTableViewCell", bundle: nil)
        self.tableViewLogIn.register(objNib, forCellReuseIdentifier: "LogInTableViewCell")
       // self.tableViewLogIn.tableFooterView = self.tableViewFooterView
        self.tableViewLogIn.separatorStyle = .none
        self.tableViewLogIn.reloadData()
    }
    func configureFooterView(){
        self.buttonSignIn.addBorderWith(width: 1.5, color: kLightGray)
        self.buttonSignOn.addBorderWith(width: 1.5, color: kLightGray)
        self.buttonGuestRequest.addBorderWith(width: 1.5, color: kLightGray)
    }
    func configureRememberMe(){
        if(self.isRememberMe){
            self.butttonCheck.setImage(#imageLiteral(resourceName: "check_new") .withRenderingMode(.alwaysOriginal), for: .normal)
            //self.buttonRememberMe.setImage(#imageLiteral(resourceName: "check").withRenderingMode(.alwaysOriginal), for: .normal)
        }else{
            self.butttonCheck.setImage(#imageLiteral(resourceName: "uncheck_new").withRenderingMode(.alwaysOriginal), for: .normal)
            //self.buttonRememberMe.setImage(#imageLiteral(resourceName: "uncheck").withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    // MARK: - API Request Methods
    func getCurrentCityLocationAPIRequest(lat:String,long:String,userID:String){
        var requestURL:String = ""
        if userID.count > 0{
            requestURL = "base/native/location/latlong?latitude=\(lat)&longitude=\(long)&userId=\(userID)"
        }else{
            requestURL = "base/native/location/latlong?latitude=\(lat)&longitude=\(long)"
        }
        
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:requestURL, parameter: nil , isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let locationDetail = successDate["Location"] as? [String:Any]{
                
                guard User.isUserLoggedIn else{
                        DispatchQueue.main.async {
                            var objCountryDetail = CountyDetail.init(objJSON: [:])
                            if let _ = locationDetail["LocationId"],!(locationDetail["LocationId"]! is NSNull){
                                objCountryDetail.locationID =  "\(locationDetail["LocationId"]!)"
                            }
                            if let _ = locationDetail["CountryId"],!(locationDetail["CountryId"] is NSNull){
                                objCountryDetail.countryID = "\(locationDetail["CountryId"]!)"
                            }
                            if let _ = locationDetail["City"],!(locationDetail["City"] is NSNull){
                                objCountryDetail.defaultCity =  "\(locationDetail["City"]!)"
                            }
                            if let _ = locationDetail["Country"],!(locationDetail["Country"] is NSNull){
                                objCountryDetail.countyName =  "\(locationDetail["Country"]!)"
                            }
                        }
                    
                    return
                }
                if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
                    currentUser.userLocationID = "\(locationDetail["LocationId"] ?? currentUser.userLocationID)"
                    currentUser.userCountryID = "\(locationDetail["CountryId"] ?? currentUser.userCountryID)"
                    currentUser.userCity = "\(locationDetail["City"] ?? currentUser.userCity)"
                    currentUser.userCountry = "\(locationDetail["Country"] ?? currentUser.userCountry)"
                    currentUser.isUserCurrentLocation = true
                    currentUser.setUserDataToUserDefault()
                }
                DispatchQueue.main.async {
                    //Push to Home
                    self.pushToHomeViewController()
                }
            }else{
            }
        }) { (responseFail) in
            DispatchQueue.main.async {
                //Push to Home
                self.pushToHomeViewController()
            }
            if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:"Error something went wrong")
                }
            }
            DispatchQueue.main.async {
                //self.locationCityDelegate?.didSelectedCurrentLocation()
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
    func postLogInAPIRequest(){
        self.view.endEditing(true)
        if(self.isValidLogIn()){
            var pushToken:String = "\(UIDevice.current.identifierForVendor!.uuidString)"
            if let _ = kUserDefault.value(forKey:kPushNotificationToken){
                pushToken = "\(kUserDefault.value(forKey:kPushNotificationToken)!)"
            }
            //"\(UIDevice.current.identifierForVendor!.uuidString)"
            let logInParameters = ["Email":"\(self.arrayOfLogInDetail[0].text)","password":"\(self.arrayOfLogInDetail[1].text)","DeviceId":"\(pushToken)","DeviceType":"iPhone","Culture":"\(self.getDeviceCulture())"] as [String : AnyObject]
            //    let logInParameters = ["Email":"jinkalr@itpathsolutions.co.in","Password":"1234","DeviceId":"\(UIDevice.current.identifierForVendor!.uuidString)","DeviceType":"iPhone"] as [String : AnyObject]
        APIRequestClient.shared.sendLogInRequest(requestType: .POST, queryString:kLogInString, parameter:logInParameters,isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let accessToken = success["AccessToken"],let userInfo = success["data"] as? [String:Any]{
                let objUser = User.init(accesToken:"\(accessToken)", userDetail: userInfo,isRemember: self.isRememberMe,password:"\(self.arrayOfLogInDetail[1].text)")
                objUser.userDefaultRole = objUser.role
                UserDefaults.standard.set("\(objUser.userLanguage)", forKey: "selectedLanguageCode")
                objUser.setUserDataToUserDefault()
                if self.isRememberMe{
                    kUserDefault.set("\(self.arrayOfLogInDetail[0].text)", forKey: kUserName)
                    kUserDefault.set("\(self.arrayOfLogInDetail[1].text)", forKey: kUserPassword)
                }else{
                    kUserDefault.removeObject(forKey: kUserName)
                    kUserDefault.removeObject(forKey: kUserPassword)
                }
      
                DispatchQueue.main.async {
                    if let isCurrentLocation = kUserDefault.value(forKey:"isUserCurrentLocation") as? Bool,isCurrentLocation{
                       self.getCurrentCityLocationAPIRequest(lat: self.latitude, long: self.longitude, userID: "\(objUser.userID)")
                    }else{
                        //Push to Home
                        self.pushToHomeViewController()
                    }
                    
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
    func postAPIFacebookLogin(parameters:[String:AnyObject]){
        var pushToken:String = "\(UIDevice.current.identifierForVendor!.uuidString)"
        if let _ = kUserDefault.value(forKey:kPushNotificationToken){
            pushToken = "\(kUserDefault.value(forKey:kPushNotificationToken)!)"
        }
        if let userEmail = parameters["email"],let facebookID = parameters["id"]{
            let fblogInParameters = ["Email":"\(userEmail)","FacebookId":"\(facebookID)",
                "FacebookSecret":"\(FBSDKAccessToken.current()!.tokenString)","DeviceId":"\(pushToken)","DeviceType":"iPhone","Culture":"\(self.getDeviceCulture())"] as [String : AnyObject]
            APIRequestClient.shared.sendFacebookLogInAPI(requestType: .POST, queryString: kFacebookLogIn, parameter: fblogInParameters, isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let accessToken = success["AccessToken"],let userInfo = success["data"] as? [String:Any]{
                    let objUser:User = User.init(accesToken:"\(accessToken)", userDetail: userInfo,isRemember: self.isRememberMe,password:"")
                    objUser.isFaceBookLogIn = true
                    objUser.setUserDataToUserDefault()
                    DispatchQueue.main.async {
                        if let isCurrentLocation = kUserDefault.value(forKey:"isUserCurrentLocation") as? Bool,isCurrentLocation{
                            self.getCurrentCityLocationAPIRequest(lat: self.latitude, long: self.longitude, userID: "\(objUser.userID)")
                        }else{
                            //Push to Home
                            self.pushToHomeViewController()
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        //Move For Register
                        self.pushToSignUpViewController(parameters: parameters)
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
        }else{
            DispatchQueue.main.async {
                ShowToast.show(toatMessage:kCommonError)
            }
        }
    }
    // MARK: - Transaction Methods
    func pushToHomeViewController(){
//        guard User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(),!currentUser.isUserBlock else {
//            self.present(CommonClass.shared.userBlockAlert, animated: true, completion: nil)
//            return
//        }
        
        if let whereToNextViewController:WhereToNextViewController = self.storyboard?.instantiateViewController(withIdentifier: "WhereToNextViewController") as? WhereToNextViewController{
            whereToNextViewController.isPushToHome = true
            whereToNextViewController.isAnimatedPush = true
            self.navigationController?.pushViewController(whereToNextViewController, animated: false)
        }
        /*
        if let homeViewController:HomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController{
            self.navigationController?.pushViewController(homeViewController, animated: true)
        }*/
    }
    func pushToWhereToNextViewController(){
        if let whereToNextViewController:WhereToNextViewController = self.storyboard?.instantiateViewController(withIdentifier: "WhereToNextViewController") as? WhereToNextViewController{
            self.navigationController?.pushViewController(whereToNextViewController, animated: true)
        }
    }
    func pushToForgotPassword(){
        if let forgotPasswordViewController:ForgotPasswordViewController = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as? ForgotPasswordViewController{
            forgotPasswordViewController.userEmailID = "\(self.arrayOfLogInDetail[0].text)"
            self.navigationController?.pushViewController(forgotPasswordViewController, animated: true)
        }
    }
    func pushToSignUpViewController(parameters:[String:AnyObject]?){
        if let signUpViewController:SignUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController{
            signUpViewController.facebookParameters = parameters
            self.navigationController?.pushViewController(signUpViewController, animated: true)
        }
    }
    func pushToGuideRequestViewController(){
        if let guideSignUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "GuideSignUpViewController") as? GuideSignUpViewController{
            self.navigationController?.pushViewController(guideSignUpViewController, animated: true)
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackgroundShadowSelector(sender:UIButton){
        self.view.endEditing(true)
    }
    @IBAction func buttonSkipSelector(sender:UIButton){
        self.pushToWhereToNextViewController()
    }
    @IBAction func buttonRememberMeSelector(sender:UIButton){
        self.isRememberMe = !self.isRememberMe
    }
    @IBAction func buttonForgotPasswordSelector(sender:UIButton){
        self.view.endEditing(true)
        self.pushToForgotPassword()
    }
    @IBAction func buttonSignInSelector(sender:UIButton){
        self.postLogInAPIRequest()
    }
    @IBAction func buttonSignUpSelector(sender:UIButton){
        self.view.endEditing(true)
        self.pushToSignUpViewController(parameters:nil)
    }
 
    @IBAction func buttonGuideRequestSelector(sender:UIButton){
        self.view.endEditing(true)
        let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"QualifiedGuideRequest"), message: Vocabulary.getWordFromKey(key:"guideRequest.Message"), preferredStyle: .alert)
        let cancel = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler: nil)
        alertController.addAction(cancel)
        alertController.view.tintColor = UIColor(hexString: "#36527D")
    alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"understandAlertBtn"), style: .default, handler: { (_) in
            self.pushToGuideRequestViewController()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func buttonFaceBookLogInSelector(sender:UIButton){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "connectionRequiered"))
            return
        }
        FaceBookLogIn.basicInfoWithCompletionHandler(self) { (result, error) in
            guard error == nil else{
                ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                return
            }
            if let _ = result{
                self.postAPIFacebookLogin(parameters: result!)
            }
        }
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
extension SignInViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfLogInDetail.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let logInCell:LogInTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LogInTableViewCell", for: indexPath) as! LogInTableViewCell
        
        guard self.arrayOfLogInDetail.count > indexPath.row else {
            return logInCell
        }
        if indexPath.row == 1 {
            logInCell.trailingContainer.constant = 0
            logInCell.btnDropDown.isHidden = false
        } else {
            logInCell.trailingContainer.constant = -20
            logInCell.btnDropDown.isHidden = true
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
//        logInCell.btnDropDown.isHidden = true
        logInCell.selectionStyle = .none
        DispatchQueue.main.async {
            if detail.text.count > 0{
                 logInCell.textFieldLogIn.minimizePlaceholder()
            }else{
                 logInCell.textFieldLogIn.maximizePlaceholder()
            }
        }
        logInCell.setTextFieldColor(textColor: UIColor.white, placeHolderColor: UIColor.white)
        logInCell.textFieldLogIn.placeHolderFont = UIFont.init(name: "Avenir-Roman", size: 14.0)
        
        return logInCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightOfTableViewCell
    }
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return self.heightOfTableViewFooterView
//    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return self.heightOfTableViewHeaderView
//    }
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return self.tableViewFooterView
//    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return self.tableViewHeaderView
//    }
    
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
        if textField.tag == 10 { //Email
            let email:TextFieldDetail = arrayOfLogInDetail[0]
            if(!email.text.isValidEmail()){
                DispatchQueue.main.async {
                    (textField as! TweeActiveTextField).activeLineColor = .red
                    (textField as! TweeActiveTextField).lineColor = .red
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "pleaseEnterValidEmail.title"))
                    textField.invalideField()
                }
            }else{
                (textField as! TweeActiveTextField).activeLineColor = UIColor.init(hexString:"C8C7CC")///.white
                (textField as! TweeActiveTextField).lineColor = UIColor.init(hexString:"C8C7CC")///.white
                textField.setBorder(color: .clear)
                self.view.viewWithTag(11)?.becomeFirstResponder()
            }
        }else if textField.tag == 11{ //Password
            //PostLogInRequest
            self.postLogInAPIRequest()
        }else{
            (textField as! TweeActiveTextField).activeLineColor = UIColor.init(hexString:"C8C7CC")///.white
            (textField as! TweeActiveTextField).lineColor = UIColor.init(hexString:"C8C7CC")///.white
            textField.setBorder(color: .clear)
        }
        return true
    }
    func isValidLogIn()->Bool{
        let minPasswordLength:Int = 6
        let maxPasswordLength:Int = 15
            let email:TextFieldDetail = arrayOfLogInDetail[0]
            let password:TextFieldDetail = arrayOfLogInDetail[1]
        
        let emailCell:LogInTableViewCell = self.tableViewLogIn.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! LogInTableViewCell
        let passwordCell:LogInTableViewCell = self.tableViewLogIn.cellForRow(at: IndexPath.init(row: 1, section: 0)) as! LogInTableViewCell
            guard email.text.count > 0 else{
                DispatchQueue.main.async {
                    emailCell.textFieldLogIn.activeLineColor = .red
                    emailCell.textFieldLogIn.lineColor = .red
                    emailCell.textFieldLogIn.invalideField()
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "pleaseEnterValidEmail.title"))
                }
                return false
            }
            guard email.text.isValidEmail() else{
                DispatchQueue.main.async {
                    emailCell.textFieldLogIn.activeLineColor = .red
                    emailCell.textFieldLogIn.lineColor = .red
                    emailCell.textFieldLogIn.invalideField()
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "pleaseEnterValidEmail.title"))
                }
                return false
            }
            guard password.text.count > 0 else{
                DispatchQueue.main.async {
                    passwordCell.textFieldLogIn.activeLineColor = .red
                    passwordCell.textFieldLogIn.lineColor = .red
                    passwordCell.textFieldLogIn.invalideField()
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "pleaseEnterPassword.title"))
                }
                return false
            }
            guard password.text.count >= minPasswordLength else{
                DispatchQueue.main.async {
                    passwordCell.textFieldLogIn.activeLineColor = .red
                    passwordCell.textFieldLogIn.lineColor = .red
                    passwordCell.textFieldLogIn.invalideField()
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "minRequiredPassword"))
                }
                return false
            }
            guard password.text.count <= maxPasswordLength else{
                DispatchQueue.main.async {
                    passwordCell.textFieldLogIn.activeLineColor = .red
                    passwordCell.textFieldLogIn.lineColor = .red
                    passwordCell.textFieldLogIn.invalideField()
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "maxRequiredPassword"))
                }
                return false
            }
        emailCell.textFieldLogIn.activeLineColor = UIColor.init(hexString:"C8C7CC")//.white
        emailCell.textFieldLogIn.lineColor = UIColor.init(hexString:"C8C7CC")///.white
        passwordCell.textFieldLogIn.activeLineColor = UIColor.init(hexString:"C8C7CC")///.white
        passwordCell.textFieldLogIn.lineColor = UIColor.init(hexString:"C8C7CC")///.white
            return true
    }
}
extension SignInViewController:CLLocationManagerDelegate{
    // MARK: - CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        print("user latitude = \(userLocation.coordinate.latitude)")
        self.latitude = "\(userLocation.coordinate.latitude)"
        print("user longitude = \(userLocation.coordinate.longitude)")
        self.longitude = "\(userLocation.coordinate.longitude)"
        manager.stopUpdatingLocation()
        manager.delegate = nil
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}
