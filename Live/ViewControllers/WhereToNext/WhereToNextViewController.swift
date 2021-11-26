//
//  WhereToNextViewController.swift
//  Live
//
//  Created by ITPATH on 4/10/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import FacebookCore
import CoreLocation
import IQKeyboardManagerSwift


class WhereToNextViewController: UIViewController,CLLocationManagerDelegate,UIGestureRecognizerDelegate {

    @IBOutlet var tableViewCountry:UITableView!
    @IBOutlet var buttonBack:UIButton!
    @IBOutlet var buttonClickHere:UIButton!
    @IBOutlet weak var lblWhereToNext: UILabel!
    @IBOutlet weak var lblChooseaCountry: UILabel!
    @IBOutlet var lblInquiryHint:UILabel!
    @IBOutlet var bottomConstraintTableView:NSLayoutConstraint!
    @IBOutlet var widthOfSearch:NSLayoutConstraint!
    
    let tableViewBottomConstraint:CGFloat = 250.0
    var arrayOfCountry:[CountyDetail] = []
    var arrayOfFilterCounty:[CountyDetail] = []
    let heightOfTableViewCell:CGFloat = 40.0
    let sizeOfFont:CGFloat = 17.0
    var isPushToHome:Bool = false
    var isAnimatedPush:Bool = true
    var isUnWindFromHome:Bool = false
    var isDiscoverHasExperienceCity:Bool = false
    var countryDetail:CountyDetail?
    @IBOutlet var txtSeachCountry:TweeActiveTextField!
    @IBOutlet var buttonLocationCity:UIButton!
    var locationManager:CLLocationManager = CLLocationManager()
    var latitude:String = ""
    var longitude:String = ""
    var typpedString:String = ""
    var isFirstLoad:Bool = true
    // MARK: - UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        //ConfigureTableView
        self.configureTableView()
        if self.isPushToHome{
            if let _ = kUserDefault.value(forKey:"isLocationPushToHome"){
                self.performSegue(withIdentifier: "PushToHome", sender: nil)
            }else{
                if let isCurrentLocation = kUserDefault.value(forKey:"isUserCurrentLocation") as? Bool,isCurrentLocation,User.isUserLoggedIn,let userID = kUserDefault.value(forKey:"userCurrentLocationUserID"),let currentUser = User.getUserFromUserDefault(){
                    if "\(currentUser.userID)" ==  "\(userID)"{
                        self.performSegue(withIdentifier: "PushToHome", sender: nil)
                    }else{
                         self.pushToLocationCitySelector()
                    }
                }else{
                    self.pushToLocationCitySelector()
                }
            }
            kUserDefault.synchronize()
            /*
            if let homeViewController:HomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController{
                self.navigationController?.pushViewController(homeViewController, animated: self.isAnimatedPush)
            }*/
        }
        //Configure Search Country
        self.configureSearchCountry()
        //Configure Keyboard hide show
    }
    func swipeToPop() {
        
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.buttonLocationCity.clipsToBounds = true
//        self.buttonLocationCity.layer.cornerRadius = 20.0
        let attributedString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key: "click_here"), attributes: [NSAttributedStringKey.underlineStyle : true])
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor(red: 7 / 255.0, green: 122 / 255.0, blue: 15 / 255.0, alpha: 1.0) , range: NSRange(location: 0, length: Vocabulary.getWordFromKey(key: "click_here").count))
        self.lblInquiryHint.text = Vocabulary.getWordFromKey(key: "dearAll")
        self.buttonClickHere.setTitle(Vocabulary.getWordFromKey(key: "noCountry.hint")+"?", for: .normal)
        //self.buttonClickHere.setAttributedTitle(attributedString, for: .normal)
        self.lblWhereToNext.text = Vocabulary.getWordFromKey(key: "title.whereToNext")
        self.lblChooseaCountry.text = Vocabulary.getWordFromKey(key: "title.chooseCountry")
        self.txtSeachCountry.tweePlaceholder = "  Search by countries, cities, guides"//\(Vocabulary.getWordFromKey(key: "title.searchCountry"))"
/*        self.txtSeachCountry.attributedPlaceholder = NSAttributedString(string: "Search by countries, cities, guides",
                                                               attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)])*/
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .lightContent
        //Get Countries with experience
        self.getExperienceCountries(searchString:"")
        DispatchQueue.main.async {
            self.addDynamicFont()
            self.view.endEditing(true)
            self.typpedString = ""
            self.txtSeachCountry.resignFirstResponder()
        }
        IQKeyboardManager.shared.enableAutoToolbar = false
        NotificationCenter.default.addObserver(self, selector: #selector(WhereToNextViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WhereToNextViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        /*
        if UIScreen.main.bounds.height == 812{
            self.bottomConstraintTableView.constant = 340.0 //+ UIScreen.main.bounds.height == 812 ? 20 : 0
        }else{
            self.bottomConstraintTableView.constant = 190.0//keyboardSize.height //+ UIScreen.main.bounds.height == 812 ? 20 : 0
        }*/
        self.bottomConstraintTableView.constant = 35.0//keyboardSize.height //+ UIScreen.main.bounds.height == 812 ? 20 : 0
        //self.swipeToPop()
        //self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    func addDynamicFont(){
        //self.lblWhereToNext.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        //self.lblWhereToNext.adjustsFontForContentSizeCategory = true
       // self.lblWhereToNext.adjustsFontSizeToFitWidth = false
        self.lblChooseaCountry.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblChooseaCountry.adjustsFontForContentSizeCategory = true
        self.lblChooseaCountry.adjustsFontSizeToFitWidth = true
        
        self.lblInquiryHint.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblInquiryHint.adjustsFontForContentSizeCategory = true
        self.lblInquiryHint.adjustsFontSizeToFitWidth = true
        
        self.buttonClickHere.titleLabel?.font = CommonClass.shared.getScaledWithOutMinimum(forFont: "Avenir-Roman", textStyle: .footnote)//CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
        self.buttonClickHere.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonClickHere.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.txtSeachCountry.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1).pointSize
        self.txtSeachCountry.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtSeachCountry.adjustsFontForContentSizeCategory = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let gradient = CAGradientLayer()
//        gradient.frame = view.bounds
//        gradient.colors = [
//            UIColor(white: 1, alpha: 0).cgColor,
//            UIColor(white: 1, alpha: 1).cgColor,
//            UIColor(white: 1, alpha: 1).cgColor,
//            UIColor(white: 1, alpha: 0).cgColor
//        ]
//        gradient.locations = [0, 0.4, 0.6, 1]
//        self.tableViewCountry.layer.mask = gradient
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil

        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.arrayOfFilterCounty = []
            self.tableViewCountry.reloadData()
            
        }
        NotificationCenter.default.removeObserver(self)
        self.txtSeachCountry.text = ""
        IQKeyboardManager.shared.enableAutoToolbar = true
        self.locationManager.stopUpdatingLocation()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Methods
    func configureTableView(){
        self.tableViewCountry.tableHeaderView = UIView()
        self.tableViewCountry.rowHeight = UITableViewAutomaticDimension
        self.tableViewCountry.estimatedRowHeight = heightOfTableViewCell
        self.tableViewCountry.delegate = self
        self.tableViewCountry.dataSource = self
        self.tableViewCountry.tableFooterView = UIView()
        self.tableViewCountry.separatorStyle = .none
        self.tableViewCountry.reloadData()
    }
    func configureSearchCountry(){
        self.txtSeachCountry.delegate = self
        self.txtSeachCountry.placeholderColor = UIColor.white.withAlphaComponent(0.5)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    /*
                    if UIScreen.main.bounds.height == 812{
                        self.bottomConstraintTableView.constant = keyboardSize.height + 30
                        //self.bottomConstraintTableView.constant = 340.0 //+ UIScreen.main.bounds.height == 812 ? 20 : 0
                    }else{
                        self.bottomConstraintTableView.constant = keyboardSize.height //+ UIScreen.main.bounds.height == 812 ? 20 : 0
                    }
                    */
                    self.bottomConstraintTableView.constant = self.getKeyboardSizeHeight()
                    print("===== keyboardWillShow \(keyboardSize) =====" )
                    print(UIScreen.main.bounds.height)
                    self.view.layoutIfNeeded()
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
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    if self.typpedString.count > 0{
                        self.widthOfSearch.constant =  0.0
                    }else{
                        self.widthOfSearch.constant = 15.0
                    }
                    /*
                    if UIScreen.main.bounds.height == 812{
                        self.bottomConstraintTableView.constant = 340.0 //+ UIScreen.main.bounds.height == 812 ? 20 : 0
                    }else{
                        self.bottomConstraintTableView.constant = 190.0//keyboardSize.height //+ UIScreen.main.bounds.height == 812 ? 20 : 0
                    }*/
                    self.bottomConstraintTableView.constant = 35.0
                    print(keyboardSize)
                    print(UIScreen.main.bounds.height)
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonHideKeyboardSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.tableViewCountry.reloadData()
            //for cell:UITableViewCell in self.tableViewCountry.visibleCells{
                //cell.alpha = 1.0
            //}
        }
    }
    @IBAction func buttonCurrentLocationCity(sender:UIButton){
        self.checkLocationPermission()
    }
    func getCurrentLocationCity(){
        //self.pushToLocationCitySelector()
        guard User.isUserLoggedIn else {
            self.getCurrentCityLocationAPIRequest(lat: latitude, long: longitude, userID:"")
            return
        }
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            self.getCurrentCityLocationAPIRequest(lat: latitude, long: longitude, userID: "\(currentUser.userID)")
        }
    }
    func checkLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                self.openSetting()
            case .authorizedAlways, .authorizedWhenInUse:
                self.getCurrentLocationCity()
            }
        } else {
            self.openSetting()
        }
    }
    func openSetting(){
        let alertController = UIAlertController.init(title:"\(Vocabulary.getWordFromKey(key:"LocationDisable"))", message: "\(Vocabulary.getWordFromKey(key:"locationCity")) \(Vocabulary.getWordFromKey(key:"EnableLocatioFromSetting"))", preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"locationCityDontAllow"), style: .default, handler:nil))
        alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"Allow"), style: .default, handler: { (_) in
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
        }))
        self.navigationController?.present(alertController, animated:true, completion: nil)
    }
    @IBAction func buttonBackSelector(sender:UIButton){
        if self.isDiscoverHasExperienceCity,self.isUnWindFromHome{
            DispatchQueue.main.async {
                ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key:"selectlocation.hint"))
            }
        }else if self.isUnWindFromHome,let _ = self.countryDetail{
            self.performSegue(withIdentifier: "PushToHome", sender:self.countryDetail!)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    @IBAction func buttonClickHere(sender:UIButton){
            let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"noCountry.hint"), message: Vocabulary.getWordFromKey(key: "dearAll"), preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"sendInformation.hint"), style: .default, handler: { (_) in
                if let inquiryController = self.storyboard?.instantiateViewController(withIdentifier: "InquiryViewController") as? InquiryViewController {
                    self.navigationController?.pushViewController(inquiryController, animated: true)
                }
            }))
            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"OK"), style: .default, handler: { (_) in
            }))
            alertController.view.tintColor = UIColor.init(hexString: "36527D")
            self.present(alertController, animated: true, completion: nil)
        
    }
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
        //nothing goes here
        //self.buttonBack.isHidden = true
        if let discoverViewController = segue.source as? DiscoverViewController{
            self.countryDetail = discoverViewController.countryDetail
            self.isDiscoverHasExperienceCity = discoverViewController.isLocationHasExperience
            self.isUnWindFromHome = true
        }
    }
    // MARK: - API Request
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
                            
                            self.performSegue(withIdentifier:"PushToHome", sender: objCountryDetail)
                        }
                    return
                }
                if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
                    currentUser.userLocationID = "\(locationDetail["LocationId"] ?? currentUser.userLocationID)"
                    currentUser.userCountryID = "\(locationDetail["CountryId"] ?? currentUser.userCountryID)"
                    currentUser.userCity = "\(locationDetail["City"] ?? currentUser.userCity)"
                    currentUser.userCountry = "\(locationDetail["Country"] ?? currentUser.userCountry)"
                    currentUser.setUserDataToUserDefault()
                }
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier:"PushToHome", sender: nil)
                        //self.dismiss(animated: false, completion: nil)
                        //self.navigationController?.popViewController(animated: false)
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
            DispatchQueue.main.async {
            }
        }
    }
    func getExperienceCountries(searchString:String){
        var searchParameters:[String:Any] = [:]
        searchParameters["SearchText"] = "\(searchString)"
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kWhereToNextSearch, parameter:searchParameters as [String : AnyObject], isHudeShow: (searchString.count > 0 ? false : true), success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let arraySuccess = successDate["location"] as? NSArray{
                self.arrayOfCountry = []
                for objCountry in arraySuccess{
                    if let jsonCountry = objCountry as? [String:Any]{
                        let countryDetail = CountyDetail.init(objJSON: jsonCountry)
                        self.arrayOfCountry.append(countryDetail)
                    }
                }
                DispatchQueue.main.async {
                    self.arrayOfFilterCounty = self.arrayOfCountry
                    self.tableViewCountry.reloadData()
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
                    ShowToast.show(toatMessage:"Error "+kCommonError)
                }
            }
        }
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PushToHome" && sender != nil{
            if let homeViewController = segue.destination as? HomeViewController,let objCountryDetail = sender as? CountyDetail{
                homeViewController.countrydetail = objCountryDetail
                self.navigationController?.interactivePopGestureRecognizer!.isEnabled = false
            }
        }
    }
    func pushToGuideDetailController(guideID:String){
        guard CommonClass.shared.isConnectedToInternet else {
            return
        }
        guard User.isUserLoggedIn else {
            let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"notLogin.title"), message: Vocabulary.getWordFromKey(key:"notLogin.msg"), preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title:"Ok", style: .default, handler: { (_) in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            let continueSelelector = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"continueBrowsing"), style: .cancel, handler: nil)
            
            alertController.addAction(continueSelelector)
            alertController.view.tintColor = UIColor(hexString: "#36527D")

            self.present(alertController, animated: true, completion: nil)
            return
        }
        if let guideViewController = self.storyboard?.instantiateViewController(withIdentifier: "GuideDetailViewController") as? GuideDetailViewController{
            guideViewController.guideId = guideID
            self.navigationController?.pushViewController(guideViewController, animated: true)
        }
    }
    func pushToNextViewControllerWith(countryDetail:CountyDetail){
        self.performSegue(withIdentifier:"PushToHome", sender: countryDetail)
        /*
        let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        homeViewController.countrydetail = countryDetail
        self.navigationController?.pushViewController(homeViewController, animated: true)
        */
    }
    func pushToLocationCitySelector(){
        if let locationCity = self.storyboard?.instantiateViewController(withIdentifier: "LocationCityViewController") as? LocationCityViewController{
            locationCity.locationCityDelegate = self
            let navigation = UINavigationController.init(rootViewController: locationCity)
            navigation.isNavigationBarHidden = true
            self.present(navigation, animated: false, completion: nil)
            //self.navigationController?.pushViewController(locationCity, animated: false)
        }
    }
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
        print("Error \(error.localizedDescription)")
    }
}

extension WhereToNextViewController:LocationCityDelegate{
    func didSelectedCurrentLocation() {
        DispatchQueue.main.async {
            kUserDefault.set(true, forKey:"isLocationPushToHome")
            self.dismiss(animated: false, completion: nil)
            self.performSegue(withIdentifier: "PushToHome", sender: nil)
        }
    }
    func notallowCurrentLocation() {
        DispatchQueue.main.async {
            kUserDefault.set(true, forKey:"isLocationPushToHome")
            self.dismiss(animated: false, completion: nil)
        }
    }
    func didSelectCurrentLocationWith(objCountryDetail: CountyDetail) {
        DispatchQueue.main.async {
            kUserDefault.set(true, forKey:"isLocationPushToHome")
            self.dismiss(animated: false, completion: nil)
            self.countryDetail = objCountryDetail
            self.performSegue(withIdentifier: "PushToHome", sender: self.countryDetail)
        }
    }
}
extension WhereToNextViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfFilterCounty.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchTableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") else {
                return SearchTableViewCell(style: .default, reuseIdentifier: "SearchTableViewCell")
            }
            return cell as! SearchTableViewCell
        }()
        guard self.arrayOfFilterCounty.count > indexPath.row else {
            return cell
        }
        let objectCountryDetail = self.arrayOfFilterCounty[indexPath.row]
        cell.tag = indexPath.row
        cell.lblSearchResult?.font = UIFont.init(name: "Avenir-Roman", size:sizeOfFont)
        cell.lblSearchResult?.textColor = .white
        if objectCountryDetail.objSearchResponseType == .Country{
            cell.lblSearchResult?.text = "\(objectCountryDetail.countyName)"
        }else if objectCountryDetail.objSearchResponseType == .City{
            cell.lblSearchResult?.text = "\(objectCountryDetail.defaultCity)"
        }else if objectCountryDetail.objSearchResponseType == .Guide{
            cell.lblSearchResult?.text = "\(objectCountryDetail.guideName)"
        }else{
            cell.lblSearchResult?.text = "\(objectCountryDetail.countyName)"
        }
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
//        cell.lblSearchResult?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
//        cell.lblSearchResult?.adjustsFontForContentSizeCategory = true
//        cell.lblSearchResult?.adjustsFontSizeToFitWidth = true
        cell.alpha = 1.0
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 1.0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightOfTableViewCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.arrayOfFilterCounty.count > indexPath.row else {
            return
        }
        let objCountryDetail = self.arrayOfFilterCounty[indexPath.row]
        self.addFireBaseAnalytics(objCountryDetail: objCountryDetail)
        self.addFaceBookAnalytics(objCountryDetail: objCountryDetail)
        if objCountryDetail.objSearchResponseType == .Guide,objCountryDetail.guideID.count > 0{
            self.pushToGuideDetailController(guideID: objCountryDetail.guideID)
        }else{
            self.pushToNextViewControllerWith(countryDetail: objCountryDetail)
        }
       
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for cell:UITableViewCell in self.tableViewCountry.visibleCells{
                if (cell.tag == 0) {
                    cell.alpha = 0.3
                } else if (cell.tag == self.arrayOfFilterCounty.count-1) {
                    cell.alpha = 0.3
                } else {
                    cell.alpha = 1.0
                }
            }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell:UITableViewCell in self.tableViewCountry.visibleCells{
            cell.alpha = 1.0
        }
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
    }
    func addFireBaseAnalytics(objCountryDetail:CountyDetail){
        var parameters:[String:Any] = [:]
        parameters["item_name"] = "Country Change"
        parameters["country"] = "\(objCountryDetail.countyName)"
        parameters["defaultCity"] = "\(objCountryDetail.defaultCity)"
        if User.isUserLoggedIn,let user = User.getUserFromUserDefault(){
            parameters["username"] = "\(user.userFirstName) \(user.userLastName)"
            parameters["userID"] = "\(user.userID)"
        }
        CommonClass.shared.addFirebaseAnalytics(parameters: parameters)
    }
    func addFaceBookAnalytics(objCountryDetail:CountyDetail){
         var params:AppEvent.ParametersDictionary = [
            "country": "\(objCountryDetail.countyName)",
            "defaultCity" : "\(objCountryDetail.defaultCity)"
            ]
        if User.isUserLoggedIn,let user = User.getUserFromUserDefault(){
            params["username"] = "\(user.userFirstName) \(user.userLastName)"
            params["userID"] = "\(user.userID)"
        }
        CommonClass.shared.addFaceBookAnalytics(eventName: "Country Change", parameters: params)
    }
}
extension WhereToNextViewController:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        self.isFirstLoad = false
        DispatchQueue.main.async {
            if self.typpedString.count > 0{
                self.widthOfSearch.constant = 0
            }else{
                self.widthOfSearch.constant = 15.0
            }
        }
//        guard !self.typpedString.isContainWhiteSpace() else{
//            return false
//        }
        guard self.typpedString.count > 0 else {
            self.arrayOfFilterCounty = self.arrayOfCountry
            DispatchQueue.main.async {
                self.getExperienceCountries(searchString: "")
                self.tableViewCountry.reloadData()
            }
            return true
        }
        //let filtered = self.arrayOfCountry.filter { $0.countyName.localizedCaseInsensitiveContains("\(typpedString)") }
        //self.arrayOfFilterCounty = filtered
        self.getExperienceCountries(searchString: "\(typpedString)")
        DispatchQueue.main.async {
            self.tableViewCountry.reloadData()
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        //self.arrayOfFilterCounty = self.arrayOfCountry
        DispatchQueue.main.async {
            self.getExperienceCountries(searchString: "")
            self.tableViewCountry.reloadData()
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            self.tableViewCountry.reloadData()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
class SearchTableViewCell: UITableViewCell {
    @IBOutlet var lblSearchResult:UILabel!
    @IBOutlet var imgSelected:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgSelected.image = #imageLiteral(resourceName: "tick_select").withRenderingMode(.alwaysTemplate)
        imgSelected.tintColor = UIColor.init(hexString:"36527D")
        DispatchQueue.main.async {
            //self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.lblSearchResult.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        //self.lblSearchResult.adjustsFontForContentSizeCategory = true
    }
    
}
/*
struct CountyDetail {
 
    var defaultCity:String = ""
    var countryID:String = ""
    var countryCode:String = ""
    var countyName:String = ""
    var documentNeeded:String = ""
    var locationID:String = ""
    var imageURL:String = ""
    var latitude:String = ""
    var longitude:String = ""
    var stateName:String = ""
    var isVideo:Bool = false
    var isExperience:Bool = false
    
    init(objJSON:[String:Any]){
        if let _ = objJSON["city"]{
            self.defaultCity = "\(objJSON["city"]!)"
        }
        if let countryData = objJSON["country"] as? [String:Any]{
            if let _ = countryData["id"]{
                self.countryID = "\(countryData["id"]!)"
            }
            if let _ = countryData["name"]{
                self.countyName = "\(countryData["name"]!)"
            }
            if let _ = countryData["code"]{
                self.countryCode = "\(countryData["code"]!)"
            }
        }
        if let _ = objJSON["latitude"]{
            self.latitude = "\(objJSON["latitude"]!)"
        }
        if let _ = objJSON["longitude"]{
            self.longitude = "\(objJSON["longitude"]!)"
        }
        if let _ = objJSON["doc_needed"]{
            self.documentNeeded = "\(objJSON["doc_needed"]!)"
        }
        if let _ = objJSON["image"]{
            self.imageURL = "\(objJSON["image"]!)"
        }
        if let _ = objJSON["id"]{
            self.locationID = "\(objJSON["id"]!)"
        }
        if let _ = objJSON["state"]{
            self.stateName = "\(objJSON["state"]!)"
        }
        if let _ = objJSON["isvideo"],!(objJSON["isvideo"] is NSNull){
            self.isVideo = Bool.init("\(objJSON["isvideo"]!)")
        }
        if let _ = objJSON["IsExperience"],!(objJSON["IsExperience"] is NSNull){
            self.isExperience = Bool.init("\(objJSON["IsExperience"]!)")
        }
    }
}*/
//SearchModel
//ResponseType
//1 for country
//2 for city
//3 for guide
enum SearchResultType:String {
    case City
    case Country
    case Guide
}
class CountyDetail:NSObject{
    
    fileprivate let kCity:String = "city"
    fileprivate let kCountry:String = "country"
    fileprivate let kCountryCode:String = "code"
    fileprivate let kCountryId:String = "id"
    fileprivate let kCountryName:String = "name"
    fileprivate let kDocNeeded:String = "doc_needed"
    fileprivate let kID:String = "id"
    fileprivate let kGuideId:String = "guideid"
    fileprivate let kGuideName:String = "guidename"
    fileprivate let kImage:String = "image"
    fileprivate let kLatitude:String = "latitude"
    fileprivate let kLongitude:String = "longitude"
    fileprivate let kState:String = "state"
    fileprivate let kIsVideo:String = "isvideo"
    fileprivate let kIsExperience:String = "IsExperience"
    fileprivate let kText:String = "text"
    fileprivate let kResponseType:String = "responsetype"
    
    var defaultCity:String = ""
    var countryCode:String = ""
    var countryID:String = ""
    var countyName:String = ""
    var documentNeeded:String = ""
    var locationID:String = ""
    var imageURL:String = ""
    var latitude:String = ""
    var longitude:String = ""
    var stateName:String = ""
    var text:String = ""
    var isVideo:Bool = false
    var isExperience:Bool = false
    var responseTypeValue:String = ""
    var responseType:String{
        get{
            return responseTypeValue
        }
        set{
            self.responseTypeValue = newValue
            self.updateSearchResponseType()
        }
    }
    var objSearchResponseType:SearchResultType = .Country
    var guideName:String = ""
    var guideID:String = ""
    
    init(objJSON:[String:Any]){
        super.init()
        if let _ = objJSON[kCity],!(objJSON[kCity] is NSNull){
             self.defaultCity = "\(objJSON[kCity]!)"
        }
        if let countryData = objJSON[kCountry] as? [String:Any]{
            if let _ = countryData[kCountryId],!(objJSON[kCountryId] is NSNull){
                self.countryID = "\(countryData[kCountryId]!)"
            }
            if let _ = countryData[kCountryName],!(objJSON[kCountryName] is NSNull){
                self.countyName = "\(countryData[kCountryName]!)"
            }
            if let _ = countryData[kCountryCode],!(objJSON[kCountryCode] is NSNull){
                self.countryCode = "\(countryData[kCountryCode]!)"
            }
        }
        if let _ = objJSON[kText],!(objJSON[kText] is NSNull){
            self.text = "\(objJSON[kText]!)"
        }
        if let _ = objJSON[kLatitude],!(objJSON[kLatitude] is NSNull){
            self.latitude = "\(objJSON[kLatitude]!)"
        }
        if let _ = objJSON[kLongitude],!(objJSON[kLongitude] is NSNull){
            self.longitude = "\(objJSON[kLongitude]!)"
        }
        if let _ = objJSON[kDocNeeded],!(objJSON[kDocNeeded] is NSNull){
            self.documentNeeded = "\(objJSON[kDocNeeded]!)"
        }
        if let _ = objJSON[kImage],!(objJSON[kImage] is NSNull){
            self.imageURL = "\(objJSON[kImage]!)"
        }
        if let _ = objJSON[kID],!(objJSON[kID] is NSNull){
            self.locationID = "\(objJSON[kID]!)"
        }
        if let _ = objJSON[kState],!(objJSON[kState] is NSNull){
            self.stateName = "\(objJSON[kState]!)"
        }
        if let _ = objJSON[kResponseType],!(objJSON[kResponseType] is NSNull){
            self.responseType = "\(objJSON[kResponseType]!)"
        }
        if let _ = objJSON[kIsVideo],!(objJSON[kIsVideo] is NSNull){
            self.isVideo = Bool.init("\(objJSON[kIsVideo]!)")
        }
        if let _ = objJSON[kIsExperience],!(objJSON[kIsExperience] is NSNull){
            self.isExperience = Bool.init("\(objJSON[kIsExperience]!)")
        }
        if let _ = objJSON[kGuideId],!(objJSON[kGuideId] is NSNull){
            self.guideID = "\(objJSON[kGuideId]!)"
        }
        if let _ = objJSON[kGuideName],!(objJSON[kGuideName] is NSNull){
            self.guideName = "\(objJSON[kGuideName]!)"
        }
    }
    func updateSearchResponseType(){
        if self.responseType.compareCaseInsensitive(str:"1"){
            self.objSearchResponseType = .Country
        }else if self.responseType.compareCaseInsensitive(str:"2"){
            self.objSearchResponseType = .City
        }else if self.responseType.compareCaseInsensitive(str:"3"){
            self.objSearchResponseType = .Guide
        }
    }
}
