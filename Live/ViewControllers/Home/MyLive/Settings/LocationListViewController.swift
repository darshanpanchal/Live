//
//  LocationListViewController.swift
//  Live
//
//  Created by ips on 23/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

struct CityList {
    var cityName:String = ""
    var countryName: String = ""
    init(objJSON:[String:Any]){
        if let countryData = objJSON as? [String: Any] {
            if let _ = countryData["city"]{
                self.cityName = "\(countryData["city"]!)"
            }
            if let _ = countryData["city"]{
                self.cityName = "\(countryData["city"]!)"
            }
        }
    }
}

class LocationListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var countryTblObj: UITableView!
    @IBOutlet weak var searchTextField: TweeActiveTextField!
    var arrayOfFilterCounty:[CountyDetail] = []
    var arrayOfCountry:[CountyDetail] = []
    var typpedString:String = ""
    let heightOfTableViewCell:CGFloat = 45.0
    @IBOutlet var navTitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTextField.placeholder = Vocabulary.getWordFromKey(key: "SearchHere")
        self.navTitle.text = Vocabulary.getWordFromKey(key: "SelectLocation")
        self.configureTableView()
        self.searchTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getLocationsbyCountryId()
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.navTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.navTitle.adjustsFontForContentSizeCategory = true
        self.navTitle.adjustsFontSizeToFitWidth = true
        self.searchTextField.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1).pointSize
        self.searchTextField.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.searchTextField.adjustsFontForContentSizeCategory = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.endEditing(true)
    }
    
    
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfFilterCounty.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
                return UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            return cell
        }()
        guard self.arrayOfFilterCounty.count > indexPath.row else {
            return cell
        }
        let objectCountryDetail = self.arrayOfFilterCounty[indexPath.row]
        cell.textLabel?.font = UIFont.init(name: "Avenir Heavy", size: 18.0)
        cell.textLabel?.text = "\(objectCountryDetail.defaultCity)" + " -" + " \(objectCountryDetail.countyName)"
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.textLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.arrayOfFilterCounty.count > indexPath.row else {
            return
        }
        let objectCountryDetail = self.arrayOfFilterCounty[indexPath.row]
        let cityId = objectCountryDetail.locationID
        self.selectedLocation(cityId, objectCountryDetail.defaultCity, objectCountryDetail.countyName)  // Location Change Request API
    }
    
    // MARK:- Custom Methods
    func configureTableView(){
        self.countryTblObj.tableHeaderView = UIView()
        self.countryTblObj.rowHeight = UITableViewAutomaticDimension
        self.countryTblObj.estimatedRowHeight = heightOfTableViewCell
        self.countryTblObj.delegate = self
        self.countryTblObj.dataSource = self
        self.countryTblObj.tableFooterView = UIView()
        self.countryTblObj.separatorStyle = .none
        self.countryTblObj.reloadData()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.countryTblObj.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height + 40.0, 0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.countryTblObj.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
    
    //MARK:-  Get Locations by country id
    
    func getLocationsbyCountryId(){
        let currentUser: User? = User.getUserFromUserDefault()
        let userCountryId: String? = currentUser?.userCurrentCountryID
        let url = "\(kAllLocation)/\(userCountryId!)"
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString: url, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
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
                    self.countryTblObj.reloadData()
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
    
    // Change Location
    func selectedLocation( _ cityId: String, _ cityName: String, _ countryName: String) {
        let currentUser: User? = User.getUserFromUserDefault()
        let userId: String = (currentUser?.userID)!
        let urlBookingDetail = "users/\(userId)/native/location/\(cityId)/userlocation"
        
        APIRequestClient.shared.sendRequest(requestType: .PUT, queryString:urlBookingDetail, parameter: [:], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let _ = success["data"] as? [String:Any] {
                // Location Change Suucess Alert
                currentUser!.userLocationID = cityId
                currentUser!.userCity = cityName
                currentUser!.userCountry = countryName
                currentUser!.userCurrentCountryID = cityId
                currentUser!.userCurrentCity = cityName
                currentUser!.userCurrentCountry = countryName
                currentUser!.setUserDataToUserDefault()
                self.performSegue(withIdentifier: "unwindToLocationList", sender: nil)
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
    
    // MARK:- Selector Methods
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension LocationListViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard !self.typpedString.isContainWhiteSpace() else{
            return false
        }
        guard self.typpedString.count > 0 else {
            self.arrayOfFilterCounty = self.arrayOfCountry
            DispatchQueue.main.async {
                self.countryTblObj.reloadData()
            }
            return true
        }
        let filtered = self.arrayOfCountry.filter { $0.defaultCity.localizedCaseInsensitiveContains("\(typpedString)") }
        self.arrayOfFilterCounty = filtered
        DispatchQueue.main.async {
            self.countryTblObj.reloadData()
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.arrayOfFilterCounty = self.arrayOfCountry
        DispatchQueue.main.async {
            self.countryTblObj.reloadData()
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}
