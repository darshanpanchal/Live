//
//  CountrySearchViewController.swift
//  Live
//
//  Created by ips on 10/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
struct BecomeGuideCountry {
    var countryID:String = ""
    var countyName:String = ""
    var countryCode:String = ""
    
    init(objJSON:[String:Any]){
        if let countryData = objJSON as? [String: Any] {
            if let _ = countryData["Id"]{
                self.countryID = "\(countryData["Id"]!)"
            }
            if let _ = countryData["Name"]{
                self.countyName = "\(countryData["Name"]!)"
            }
            
            if let _ = countryData["Code"]{
                self.countryCode = "\(countryData["Code"]!)"
            }
        }
    }
}

class CountrySearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var countryTblObj: UITableView!
    @IBOutlet weak var searchTextField: TweeActiveTextField!
    var arrayOfFilterCounty:[BecomeGuideCountry] = []
    var arrayOfCountry:[BecomeGuideCountry] = []
    var typpedString:String = ""
    let heightOfTableViewCell:CGFloat = 45.0
    var countryDetail:BecomeGuideCountry?
    @IBOutlet var topConstraint:NSLayoutConstraint!
    var isFromInquiry: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTextField.placeholder = Vocabulary.getWordFromKey(key: "title.searchCountry")
        self.configureTableView()
        self.searchTextField.delegate = self
        let indentView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        self.searchTextField.leftView = indentView
        self.searchTextField.leftViewMode = .always
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getBecomeGuideCountries()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.endEditing(true)
    }
    
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
    
    // MARK: - Custom Methods
    @objc func keyboardWillShow(notification: NSNotification) {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.countryTblObj.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height - 80.0, 0)
            }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
            if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.countryTblObj.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
    
    var topController: UIViewController? {
        if var temp = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = temp.presentedViewController {
                temp = presentedViewController
            }
            return temp
        }
        return nil
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
        cell.textLabel?.font = UIFont.init(name: "Avenir Book", size: 18.0)
        cell.textLabel?.text = "\(objectCountryDetail.countyName)"
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.arrayOfFilterCounty.count > indexPath.row else {
            return
        }
        let objectCountryDetail = self.arrayOfFilterCounty[indexPath.row]
        let countryId = objectCountryDetail.countryID
        
        if !isFromRequestLocation {
            self.dismiss(animated: true, completion: {
                DispatchQueue.main.async {
                    guard let top = self.topController else { return }
                    let becomeGuideAlert = UIAlertController(title: "Become Guide", message: "Are you sure want to become a guide?",preferredStyle: UIAlertControllerStyle.alert)
                    becomeGuideAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                        self.becomeGuide(countryId)  // Become Guide Request API
                    }))
                    becomeGuideAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    top.present(becomeGuideAlert, animated: false,  completion: nil)
                }
                
            })
        } else {
            if isFromInquiry {
                let countryDetailDic = ["name": "\(objectCountryDetail.countyName)", "id": "\(objectCountryDetail.countryID)"]
                isFromRequestLocation = false
                self.performSegue(withIdentifier: "unwindToInquiry", sender: countryDetailDic)
            } else {
                let countryDetailDic = ["name": "\(objectCountryDetail.countyName)", "id": "\(objectCountryDetail.countryID)"]
                isFromRequestLocation = false
                self.performSegue(withIdentifier: "unwindToLocationRequest", sender: countryDetailDic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightOfTableViewCell
    }
    
    
    // MARK: - Selector Methods
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - API Request
    func becomeGuide( _ countryId: String) {  // For Become Guide
        let currentUser: User? = User.getUserFromUserDefault()
        let userId: String = (currentUser?.userID)!
        let urlBookingDetail = "travellers/\(userId)/native/locations/\(countryId)/becomeguide"
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:urlBookingDetail, parameter: [:], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let data = success["data"] as? [String:Any] {
                // Become Guide Suucess Alert
                DispatchQueue.main.async {
                    guard let top = self.topController else { return }
                    let becomeGuideSuccessAlert = UIAlertController(title: Vocabulary.getWordFromKey(key: "BecomeGuide"), message: data["message"] as? String,preferredStyle: UIAlertControllerStyle.alert)
                    becomeGuideSuccessAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"Ok"), style: .default, handler: nil))
                    top.present(becomeGuideSuccessAlert, animated: false, completion: nil)
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
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
    }

    func getBecomeGuideCountries() {  // Get Country list
        APIRequestClient.shared.getCoutriesWithExperience(requestType: .GET, queryString: kBecomGuideCountries, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let arraySuccess = successDate["country"] as? NSArray{
                self.arrayOfCountry = []
                for objCountry in arraySuccess{
                    if let _ = objCountry as? [String:Any]{
                        let countryDetail = BecomeGuideCountry.init(objJSON: objCountry as! [String : Any])
                        self.arrayOfCountry.append(countryDetail)
                    }
                }
                DispatchQueue.main.async {
                    self.arrayOfFilterCounty = self.arrayOfCountry
                    self.countryTblObj.reloadData()
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
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "unwindToLocationRequest" && sender != nil{
            if let locationRequestController = segue.destination as? LocationRequestViewController {
                locationRequestController.locationData = sender as! [String : String]
                self.navigationController?.interactivePopGestureRecognizer!.isEnabled = false
            }
        }
//        if segue.identifier == "unwindToInquiry" && sender != nil{
//            if let locationRequestController = segue.destination as? InquiryViewController {
//                locationRequestController.locationData = sender as! [String : String]
//                self.navigationController?.interactivePopGestureRecognizer!.isEnabled = false
//            }
//        }
    }
}

extension CountrySearchViewController: UITextFieldDelegate {
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
        let filtered = self.arrayOfCountry.filter { $0.countyName.localizedCaseInsensitiveContains("\(typpedString)") }
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
