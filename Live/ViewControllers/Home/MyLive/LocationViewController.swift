//
//  LocationViewController.swift
//  Live
//
//  Created by IPS on 22/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class LocationViewController: UIViewController {

    @IBOutlet var buttonRequestLocation:UIButton!
    @IBOutlet var buttonClose:UIButton!
    @IBOutlet var navTitle:UILabel!
    @IBOutlet var requestLocationDescription:UILabel!
    @IBOutlet var locationTableView:UITableView!
    @IBOutlet var bottomConstraintTableView:NSLayoutConstraint!
    @IBOutlet weak var searchTextField: TweeActiveTextField!

    var arrayOfCountryDetail:[CountyDetail] = []
    var arrayOfFilterCountryDetail:[CountyDetail]=[]
    var typpedString:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonRequestLocation.setTitle(Vocabulary.getWordFromKey(key: "requestLocation"), for: .normal)
        requestLocationDescription.text = Vocabulary.getWordFromKey(key: "requestLocation.msg")
        navTitle.text = Vocabulary.getWordFromKey(key: "SelectLocation")
        searchTextField.placeholder = Vocabulary.getWordFromKey(key: "searchLocation")
        // Do any additional setup after loading the view.
        self.configureLocationView()
        NotificationCenter.default.addObserver(self, selector: #selector(LocationViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LocationViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = false
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.navTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.navTitle.adjustsFontForContentSizeCategory = true
        self.navTitle.adjustsFontSizeToFitWidth = true
        
        self.searchTextField.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.searchTextField.adjustsFontForContentSizeCategory = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomConstraintTableView.constant = keyboardSize.height + 50
                print(UIScreen.main.bounds.height)
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomConstraintTableView.constant = 0
                print(keyboardSize)
                print(UIScreen.main.bounds.height)
                self.view.layoutIfNeeded()
            })
        }
    }
    func configureLocationView(){
        self.locationTableView.delegate = self
        self.locationTableView.dataSource = self
        self.locationTableView.tableFooterView = UIView()
        self.searchTextField.delegate = self
        self.buttonRequestLocation.setAttributedTitle(self.attributedString(), for: .normal)
        defer{
            //GET Locations
            self.getExperienceLocations()
        }
    }
    private func attributedString() -> NSAttributedString? {
        let attributes : [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.font : UIFont(name: "Avenir-Heavy", size: 17)!,
            NSAttributedStringKey.foregroundColor : UIColor.black,
            NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue
        ]
        let attributedString = NSAttributedString(string:Vocabulary.getWordFromKey(key:"requestLocation"), attributes: attributes)
        return attributedString
    }
    // MARK: - Selector Methods
    func getExperienceLocations(){
        let reqestLocationURL = kAllLocation+"/country/\(User.getUserFromUserDefault()!.userCurrentCountryID)"
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString: reqestLocationURL, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let arraySuccess = successDate["location"] as? NSArray{
                for objCountry in arraySuccess{
                    if let jsonCountry = objCountry as? [String:Any]{
                        let countryDetail = CountyDetail.init(objJSON: jsonCountry)
                        self.arrayOfCountryDetail.append(countryDetail)
                    }
                }
                DispatchQueue.main.async {
                    self.arrayOfFilterCountryDetail = self.arrayOfCountryDetail
                    self.locationTableView.reloadData()
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
    // MARK: - Selector Methods
    @IBAction func buttonCloseSelector(sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func buttonLocationRequestSelector(sender:UIButton){
        //PushToLocationRequest
        self.pushToLocationRequest()
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "unwindToAddExperienceFromLocation",let objCountry = sender as? CountyDetail{
            if let discoverViewController: AddExperienceViewController = segue.destination as? AddExperienceViewController{
                discoverViewController.selectedCountryDetail = objCountry
            }
        }
    }
    func pushToLocationRequest(){ // Push to Location Request ViewController
        if let locationRequestViewController = self.storyboard?.instantiateViewController(withIdentifier:"LocationRequestViewController") as? LocationRequestViewController {
            self.navigationController?.pushViewController(locationRequestViewController, animated: true)
        }
    }
}
extension LocationViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfFilterCountryDetail.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
                return UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            return cell
        }()
        guard self.arrayOfFilterCountryDetail.count > indexPath.row else {
            return cell
        }
        let objectCountryDetail = self.arrayOfFilterCountryDetail[indexPath.row]
        cell.textLabel?.font = UIFont.init(name: "Avenir Heavy", size: 18.0)
        cell.textLabel?.text = "\(objectCountryDetail.defaultCity)" + " ," + " \(objectCountryDetail.countyName)"
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.textLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.arrayOfFilterCountryDetail.count > indexPath.row else {
            return
        }
        let selectedCountry = self.arrayOfFilterCountryDetail[indexPath.row]
        self.performSegue(withIdentifier: "unwindToAddExperienceFromLocation", sender: selectedCountry)
    }
}
extension LocationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard !self.typpedString.isContainWhiteSpace() else{
            return false
        }
        guard self.typpedString.count > 0 else {
            self.arrayOfFilterCountryDetail = self.arrayOfCountryDetail
            DispatchQueue.main.async {
                self.locationTableView.reloadData()
            }
            return true
        }
        let filtered = self.arrayOfCountryDetail.filter { $0.defaultCity.localizedCaseInsensitiveContains("\(typpedString)") }
        self.arrayOfFilterCountryDetail = filtered
        DispatchQueue.main.async {
            self.locationTableView.reloadData()
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.arrayOfFilterCountryDetail = self.arrayOfCountryDetail
        DispatchQueue.main.async {
            self.locationTableView.reloadData()
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}
