//
//  BankDetailViewController.swift
//  Live
//
//  Created by ips on 25/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import GooglePlaces
import GooglePlacePicker

class BankDetailViewController: UIViewController {
    
    
    fileprivate let kBankName:String = "BankName"
    fileprivate let kBankAccountNumber:String = "AccountNumber"
    fileprivate let kBankSwiftBIC:String = "SwiftBIC"
    fileprivate let kBankIBAN:String = "IBAN"
    fileprivate let kBankAddress = "Address"
    fileprivate let kGuideId = "GuideId"
    fileprivate let kBankLatitude = "Latitude"
    fileprivate let kBankLongitude = "Longitude"
    
    @IBOutlet var bankAddressTxtField:TweeActiveTextField!
    var placesClient: GMSPlacesClient = GMSPlacesClient.shared()
    @IBOutlet weak var bankAddressTxtView: UITextView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var bankDetailTblObj: UITableView!
    @IBOutlet weak var navTitleLbl: UILabel!
    var bankName:TextFieldDetail?
    var bankAccount:TextFieldDetail?
    var swiftBicDetail:TextFieldDetail?
    var ibanDetail:TextFieldDetail?
    var bankAddress:TextFieldDetail?
    var detailFieldArr:[TextFieldDetail] = []
    let heightOfTableViewCell:CGFloat = 88.0
    var updateBankDetail:[String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navTitleLbl.text = Vocabulary.getWordFromKey(key:"BankDetail")
        self.btnSave.setTitle(Vocabulary.getWordFromKey(key:"save.title"), for: .normal)
        self.bankAddressTxtField.tweePlaceholder = Vocabulary.getWordFromKey(key:"bankAddress")
        self.bankAddressTxtField.delegate = self
        self.bankAddressTxtView.delegate = self
        self.bankAddressTxtField.placeholderColor = UIColor.black
        self.configureBankDetail()
        self.configureTableView()
//        self.bankAddressTxtField.tweePlaceholder = "Bank Address"
        self.sizeFooterToFit()
        
        //Get Bank Detail
        self.getBankDetailAPIRequest()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.navTitleLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.navTitleLbl.adjustsFontForContentSizeCategory = true
        self.navTitleLbl.adjustsFontSizeToFitWidth = true
        
        self.btnSave.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.btnSave.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnSave.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.bankAddressTxtField.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1).pointSize
        self.bankAddressTxtField.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.bankAddressTxtField.adjustsFontForContentSizeCategory = true
        self.bankAddressTxtView.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
    }
    //MARK:- Custom Methods
    func configureBankDetail(){
        bankName = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "bankName"), text: "", keyboardType: .default, returnKey: .next, isSecure: false)
        bankAccount = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "bankAccount"), text: "", keyboardType: .default, returnKey: .next, isSecure: false)
        swiftBicDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "swiftBic"), text: "", keyboardType: .default, returnKey: .next, isSecure: false)
        ibanDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "iban"), text: "", keyboardType: .default, returnKey: .next, isSecure: false)
        self.detailFieldArr = [bankName!,bankAccount!,swiftBicDetail!,ibanDetail!]
    }
    
    func configureTableView(){
        self.bankDetailTblObj.delegate = self
        self.bankDetailTblObj.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "LogInTableViewCell", bundle: nil)
        self.bankDetailTblObj.register(objNib, forCellReuseIdentifier: "LogInTableViewCell")
        self.bankDetailTblObj.separatorStyle = .none
        self.bankDetailTblObj.reloadData()
        
    }
    
    func invalidTextField(textField:TweeActiveTextField){
        textField.activeLineColor = .red
        textField.lineColor = .red
        textField.invalideField()
    }
    
    func validTextField(textField:TweeActiveTextField){
//        textField.activeLineColor = .black
//        textField.lineColor = .black
    }
    
    func isValidDetail()->Bool{
        
        let bankNameCell:LogInTableViewCell = self.bankDetailTblObj.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! LogInTableViewCell
        let bankAccountCell:LogInTableViewCell = self.bankDetailTblObj.cellForRow(at: IndexPath.init(row: 1, section: 0)) as! LogInTableViewCell
        let swiftBicCell:LogInTableViewCell = self.bankDetailTblObj.cellForRow(at: IndexPath.init(row: 2, section: 0)) as! LogInTableViewCell
        let iBanCell:LogInTableViewCell = self.bankDetailTblObj.cellForRow(at: IndexPath.init(row: 3, section: 0)) as! LogInTableViewCell
        
        guard bankName!.text.count > 0 else{
            DispatchQueue.main.async {
                self.invalidTextField(textField: bankNameCell.textFieldLogIn)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"pleaseEnterBankName."))
            }
            return false
        }
       
        guard bankAccount!.text.count > 0 else{
            DispatchQueue.main.async {
                self.invalidTextField(textField: bankAccountCell.textFieldLogIn)
                ShowToast.show(toatMessage:  Vocabulary.getWordFromKey(key:"pleaseEnterBankAccount."))
            }
            return false
        }

        guard swiftBicDetail!.text.count > 0 else{
            DispatchQueue.main.async {
                self.invalidTextField(textField: swiftBicCell.textFieldLogIn)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"pleaseEnterSwiftBic."))
            }
            return false
        }
        
        guard ibanDetail!.text.count > 0 else{
            DispatchQueue.main.async {
                self.invalidTextField(textField: iBanCell.textFieldLogIn)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"pleaseEnterIban."))
            }
            return false
        }
        guard self.bankAddressTxtView.text.count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.bankAddressTxtField)
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"pleaseEnterBankAddress."))
            }
            return false
        }
        self.updateBankDetail[kBankAddress] = self.bankAddressTxtView?.text
        self.updateBankDetail[kBankName] = self.bankName?.text
        self.updateBankDetail[kBankAccountNumber] = self.bankAccount?.text
        self.updateBankDetail[kBankSwiftBIC] = self.swiftBicDetail?.text
        self.updateBankDetail[kBankIBAN] = self.ibanDetail?.text
        self.validTextField(textField: bankNameCell.textFieldLogIn)
        self.validTextField(textField: bankAccountCell.textFieldLogIn)
        self.validTextField(textField: swiftBicCell.textFieldLogIn)
        self.validTextField(textField: iBanCell.textFieldLogIn)
        
        return true
    }
    
    func sizeFooterToFit() {
        
        if let footerView =  self.bankDetailTblObj.tableFooterView {
            footerView.setNeedsLayout()
            footerView.layoutIfNeeded()
            
            let height = footerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height 
            var frame = footerView.frame
            frame.size.height = height
            footerView.frame = frame
            self.bankDetailTblObj.tableFooterView = footerView
        }
    }
    // MARK:- API Request  methods
    func getBankDetailAPIRequest(){
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            let updateUserNameRequestURL = "guides/\(currentUser.userID)/native/bankdetail"

            APIRequestClient.shared.sendRequest(requestType: .GET, queryString:updateUserNameRequestURL , parameter:nil, isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let bankDetails = successData["BankDetail"] as? [String:Any]{
                    DispatchQueue.main.async {
                         let objBank = BankDetail.init(bankDetail: bankDetails)
                         self.configureBankDetail(objBankDetail: objBank)
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
    func updateBankDetailAPIRequest(){
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            self.updateBankDetail[kGuideId] = "\(currentUser.userID)"
            let updateBankDetailRequest = "guides/native/bankdetail"
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString:updateBankDetailRequest , parameter:self.updateBankDetail as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let strMSG = successData["Message"] {
                    DispatchQueue.main.async {
                        let objAlert = UIAlertController(title:Vocabulary.getWordFromKey(key:"Success"), message: "\(strMSG)",preferredStyle: UIAlertControllerStyle.alert)
                        objAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (action: UIAlertAction!) in
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(objAlert, animated: true, completion: nil)
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
    func configureBankDetail(objBankDetail:BankDetail){
        self.bankName?.text = "\(objBankDetail.bankName)"
        self.bankAccount?.text = "\(objBankDetail.bankAccountNumber)"
        self.swiftBicDetail?.text = "\(objBankDetail.bankSwiftBIC)"
        self.ibanDetail?.text = "\(objBankDetail.bankIBAN)"
        self.bankAddressTxtField.minimizePlaceholder()
        self.bankAddressTxtView.text = "\(objBankDetail.bankAddress)"
        
        self.updateBankDetail[kBankName] = self.bankName?.text
        self.updateBankDetail[kBankAccountNumber] = self.bankAccount?.text
        self.updateBankDetail[kBankSwiftBIC] = self.swiftBicDetail?.text
        self.updateBankDetail[kBankIBAN] = self.ibanDetail?.text
        self.updateBankDetail[kBankAddress] = self.bankAddressTxtView.text
        DispatchQueue.main.async {
            self.bankDetailTblObj.reloadData()
        }
    }
    // MARK:- Selector methods
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func saveBtnPressed(_ sender: Any) {
        if self.isValidDetail() {
            self.updateBankDetailAPIRequest()
        }
    }
    
    @IBAction func buttonLocationSelector(sender:UIButton){
        //Present GoogleLocationPicker
        var config:GMSPlacePickerConfig?
        if let lat = self.updateBankDetail[kBankLatitude],let long = self.updateBankDetail[kBankLongitude]{
            let center = CLLocationCoordinate2D(latitude:Double("\(lat)")!, longitude: Double("\(long)")!)
            let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001,
                                                   longitude: center.longitude + 0.001)
            let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001,
                                                   longitude: center.longitude - 0.001)
            let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            config = GMSPlacePickerConfig(viewport: viewport)
        }else{
            config = GMSPlacePickerConfig(viewport: nil)
        }
        
        let placePicker = GMSPlacePickerViewController(config: config!)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
extension BankDetailViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailFieldArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bankDetailCell:LogInTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LogInTableViewCell", for: indexPath) as! LogInTableViewCell
        guard self.detailFieldArr.count > indexPath.row else {
            return bankDetailCell
        }
//        bankDetailCell.textFieldLogIn.font = UIFont(name: "Avenir-Roman", size: 17.0)
        bankDetailCell.textFieldLogIn.delegate = self
        bankDetailCell.textFieldLogIn.tag = indexPath.row
        let detail = self.detailFieldArr[indexPath.row]
        DispatchQueue.main.async {
            bankDetailCell.textFieldLogIn.tweePlaceholder = "\(detail.placeHolder)"
            if detail.text.count > 0 {
                bankDetailCell.textFieldLogIn.text = "\(detail.text)"
            } else {
            }
           
        }
        bankDetailCell.textFieldLogIn.keyboardType = detail.keyboardType
        bankDetailCell.textFieldLogIn.returnKeyType = detail.returnKey
        bankDetailCell.textFieldLogIn.isSecureTextEntry = detail.isSecure
        bankDetailCell.btnDropDown.setImage(#imageLiteral(resourceName: "passwordDisable_black"), for: .normal)
        bankDetailCell.btnDropDown.isHidden = true
        bankDetailCell.btnDropDown.tag = 101
        bankDetailCell.setTextFieldColor(textColor: .black,placeHolderColor: .black)
        bankDetailCell.selectionStyle = .none
        return bankDetailCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightOfTableViewCell
    }

}
extension BankDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        let tag = textField.tag
        let detail = self.detailFieldArr[tag]
        detail.text = "\(typpedString)"
        if typpedString.count > 0{
            self.validTextField(textField: textField as! TweeActiveTextField)
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        let detail = self.detailFieldArr[tag]
        detail.text = ""
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
            guard (self.detailFieldArr.count-1) != textField.tag else{
                self.bankAddressTxtView.becomeFirstResponder()
                return true 
            }
            self.view.viewWithTag(textField.tag+1)?.becomeFirstResponder()
            return true
    }
    func updateActiveLine(textfield:TweeActiveTextField,color:UIColor){
        textfield.activeLineColor = color
        textfield.lineColor = color
    }
}

extension BankDetailViewController:UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let typpedString = ((textView.text)! as NSString).replacingCharacters(in: range, with: text)
        self.updateBankDetail[kBankAddress] = "\(typpedString)"
        if typpedString.count > 0{
            self.validTextField(textField: self.bankAddressTxtField)
        }
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == self.bankAddressTxtView{
            if textView.text.count == 0{
                self.bankAddressTxtField.resignFirstResponder()
                self.bankAddressTxtField.maximizePlaceholder()
                textView.resignFirstResponder()
            }else{
                self.bankAddressTxtField.minimizePlaceholder()
            }
        }
        defer {
            self.sizeFooterToFit()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == self.bankAddressTxtView{
            self.bankAddressTxtField.resignFirstResponder()
            self.bankAddressTxtField.minimizePlaceholder()
            textView.becomeFirstResponder()
        }
    }
}
class BankDetail: NSObject {
    fileprivate let kBankID:String = "Bank_Id"
    fileprivate let kBankName:String = "BankName"
    fileprivate let kBankAccountNumber:String = "AccountNumber"
    fileprivate let kBankSwiftBIC:String = "SwiftBIC"
    fileprivate let kBankIBAN:String = "IBAN"
    fileprivate let kBankAddress = "Address"
    fileprivate let kGuideId = "GuideId"
    
    var bankID:String = ""
    var bankName:String = ""
    var bankAccountNumber:String = ""
    var bankSwiftBIC:String = ""
    var bankIBAN:String = ""
    var bankAddress:String = ""
    var guideID:String = ""
    
    init(bankDetail:[String:Any]) {
        if let _ = bankDetail[kBankID],!(bankDetail[kBankID] is NSNull){
            self.bankID = "\(bankDetail[kBankID]!)"
        }
        if let _ = bankDetail[kBankName],!(bankDetail[kBankName] is NSNull){
            self.bankName = "\(bankDetail[kBankName]!)"
        }
        if let _ = bankDetail[kBankAccountNumber],!(bankDetail[kBankAccountNumber] is NSNull){
            self.bankAccountNumber = "\(bankDetail[kBankAccountNumber]!)"
        }
        if let _ = bankDetail[kBankSwiftBIC],!(bankDetail[kBankSwiftBIC] is NSNull){
            self.bankSwiftBIC = "\(bankDetail[kBankSwiftBIC]!)"
        }
        if let _ = bankDetail[kBankIBAN],!(bankDetail[kBankIBAN] is NSNull){
            self.bankIBAN = "\(bankDetail[kBankIBAN]!)"
        }
        if let _ = bankDetail[kBankAddress],!(bankDetail[kBankAddress] is NSNull){
            self.bankAddress = "\(bankDetail[kBankAddress]!)"
        }
        if let _ = bankDetail[kGuideId],!(bankDetail[kGuideId] is NSNull){
            self.guideID = "\(bankDetail[kGuideId]!)"
        }
    }
}
extension BankDetailViewController:GMSPlacePickerViewControllerDelegate{
    // To receive the results from the place picker 'self' will need to conform to
    // GMSPlacePickerViewControllerDelegate and implement this code.
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        defer{
            let (strAddress,strPostal) = self.getAddressAndPostalCode(place: place)
            DispatchQueue.main.async {
                self.bankAddressTxtField.minimizePlaceholder()
                self.bankAddressTxtView.text = "\(strAddress)"
//                self.txtPostalZipOfExperience.minimizePlaceholder()
//                self.txtExperiencePostalZip.text = "\(strPostal)"
//                self.sizeFooterToFit()
                
            }
//            self.addExperienceParameters[kExperiencePostal] = "\(strPostal)"
            self.updateBankDetail[kBankAddress] = "\(strAddress)"
            self.updateBankDetail[kBankLatitude] = "\(place.coordinate.latitude)"
            self.updateBankDetail[kBankLongitude] = "\(place.coordinate.longitude)"
            self.validTextField(textField: self.bankAddressTxtField)
        }
    }
    func getAddressAndPostalCode(place: GMSPlace)->(String,String){
        // Get the address components.
        var address:[String] = ["\(place.name)"]
        var postalCode:String = ""
        if let addressLines = place.addressComponents {
            // Populate all of the address fields we can find.
            for field in addressLines {
                switch field.type {
                case kGMSPlaceTypeStreetNumber:
                    let street_number = field.name
                    address.append(street_number)
                case kGMSPlaceTypeRoute:
                    let route = field.name
                    address.append(route)
                case kGMSPlaceTypeNeighborhood:
                    let neighborhood = field.name
                    address.append(neighborhood)
                case kGMSPlaceTypeLocality:
                    let locality = field.name
                    address.append(locality)
                case kGMSPlaceTypeSublocalityLevel1:
                    let subLocality = field.name
                    address.append(subLocality)
                case kGMSPlaceTypeAdministrativeAreaLevel1:
                    let administrative_area_level_1 = field.name
                    address.append(administrative_area_level_1)
                case kGMSPlaceTypeCountry:
                    let country = field.name
                    address.append(country)
                case kGMSPlaceTypePostalCode:
                    postalCode = field.name
                //address.append(postal_code)
                case kGMSPlaceTypePostalCodeSuffix:
                    let postal_code = field.name
                    print(postal_code)
                    //address.append(postal_code)
                // Print the items we aren't using.
                default:
                    print("Type: \(field.type), Name: \(field.name)")
                }
            }
        }
        return ("\(address.joined(separator:","))","\(postalCode)")
    }
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        defer{
            self.bankAddressTxtField.minimizePlaceholder()
            self.sizeFooterToFit()
        }
        
    }
}
