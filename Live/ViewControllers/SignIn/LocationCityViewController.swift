//
//  LocationCityViewController.swift
//  Live
//
//  Created by IPS on 09/07/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import CoreLocation
protocol LocationCityDelegate {
    func didSelectedCurrentLocation()
    func notallowCurrentLocation()
    func didSelectCurrentLocationWith(objCountryDetail:CountyDetail)
}

class LocationCityViewController: UIViewController,CLLocationManagerDelegate {
    @IBOutlet weak var bottomConstantOfHint: NSLayoutConstraint!
    var locationManager:CLLocationManager = CLLocationManager()
    var latitude:String = ""
    var longitude:String = ""
    var locationCityDelegate:LocationCityDelegate?
    @IBOutlet var lblLocationAccessHint:UILabel!
    @IBOutlet var btnAllow:UIButton!
    @IBOutlet var btnNotAllow:UIButton!
    @IBOutlet var lblLocationAccessTitle:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
       if self.view.frame.height < 811 {
           self.bottomConstantOfHint.constant = 36
       } else {
            self.bottomConstantOfHint.constant = 136
        }
        
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func addDynamicFont(){
        self.btnAllow.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.btnAllow.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnAllow.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.btnNotAllow.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.btnNotAllow.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnNotAllow.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.lblLocationAccessHint?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblLocationAccessHint?.adjustsFontForContentSizeCategory = true
        self.lblLocationAccessHint.adjustsFontSizeToFitWidth = true

    }
    func checkLocationPermission() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                self.openSetting()
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            }
        } else {
            self.openSetting()
            return false
        }
    }
    func openSetting(){
        let alertController = UIAlertController.init(title:"\(Vocabulary.getWordFromKey(key:"LocationDisable"))", message: "\(Vocabulary.getWordFromKey(key:"locationCity")) \(Vocabulary.getWordFromKey(key:"EnableLocatioFromSetting"))", preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"locationCityDontAllow"), style: .default, handler: { (_) in
            guard User.isUserLoggedIn else{
                self.locationCityDelegate?.notallowCurrentLocation()
                return
            }
            if  let _ = self.locationCityDelegate{
                DispatchQueue.main.async {
                    self.locationCityDelegate?.didSelectedCurrentLocation()
                }
            }
        }))
        alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"Allow"), style: .default, handler: { (_) in
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
        }))
        self.navigationController?.present(alertController, animated:true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .default
        self.configureLocalisation()
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        locationManager.stopUpdatingLocation()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func configureLocalisation(){
        self.lblLocationAccessHint.text = Vocabulary.getWordFromKey(key:"locationCity")
        self.btnAllow.setTitle(Vocabulary.getWordFromKey(key:"locationCityAllow"), for: .normal)
        self.btnNotAllow.setTitle(Vocabulary.getWordFromKey(key:"locationCityDontAllow"), for: .normal)
    }
    // MARK: - Selector Methods
    @IBAction func buttonAllowSelector(sender:UIButton){
        guard self.checkLocationPermission() else {
            return
        }
        guard User.isUserLoggedIn else {
            self.getCurrentCityLocationAPIRequest(lat: latitude, long: longitude, userID:"")
            return
        }
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            self.getCurrentCityLocationAPIRequest(lat: latitude, long: longitude, userID: "\(currentUser.userID)")
        }
    }
    @IBAction func buttonNotAllowSelector(sender:UIButton){
        guard User.isUserLoggedIn else{
            self.locationCityDelegate?.notallowCurrentLocation()
            return
        }
        if  let _ = self.locationCityDelegate{
            DispatchQueue.main.async {
                self.locationCityDelegate?.didSelectedCurrentLocation()
            }
        }
    }
    // MARK: - APIRequestViewController
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
                    if  let _ = self.locationCityDelegate{
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
                            self.locationCityDelegate?.didSelectCurrentLocationWith(objCountryDetail: objCountryDetail)
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
                    kUserDefault.set(true, forKey:"isUserCurrentLocation")
                    kUserDefault.set("\(currentUser.userID)", forKey:"userCurrentLocationUserID")
                    kUserDefault.synchronize()
                }
                if  let _ = self.locationCityDelegate{
                    DispatchQueue.main.async {
                        self.locationCityDelegate?.didSelectedCurrentLocation()
                        //self.dismiss(animated: false, completion: nil)
                        //self.navigationController?.popViewController(animated: false)
                    }
                }
            }else{
                DispatchQueue.main.async {
                    //ShowToast.show(toatMessage:kCommonError)
                     self.locationCityDelegate?.didSelectedCurrentLocation()
                }
            }
        }) { (responseFail) in
            if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
                kUserDefault.set(false, forKey:"isUserCurrentLocation")
                kUserDefault.set("\(currentUser.userID)", forKey:"userCurrentLocationUserID")
                kUserDefault.synchronize()
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
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
  
}
