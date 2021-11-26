//
//  CouponCodeListViewController.swift
//  Live
//
//  Created by ips on 20/07/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class CouponCodeListViewController: UIViewController {
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblOR: UILabel!
    @IBOutlet weak var txtCouponCode: TweeActiveTextField!
    @IBOutlet weak var tableCoupon: UITableView!
    @IBOutlet weak var txtSearchField: TweeActiveTextField!
    @IBOutlet weak var btnUse: RoundButton!
    @IBOutlet var bottomConstraint:NSLayoutConstraint!
    @IBOutlet var buttonSelectFromList:RoundButton!
    var isUse:Bool = false
    var isUserCouponEnable:Bool{
        get{
            return isUse
        }
        set{
            self.isUse = newValue
            DispatchQueue.main.async {
                self.updateUseCoponCodeSelector()
            }
        }
    }
    var isSelectFromList:Bool = false
    var isSelectFromListEnable:Bool{
        get{
            return isSelectFromList
        }
        set{
            self.isSelectFromList = newValue
            DispatchQueue.main.async {
                self.updateSelectfromListSelector()
            }
        }
    }
    var strCouponCode:String = ""
    var arrayOfCoupon:[Coupon] = []
    var arrayOfFilterCoupon:[Coupon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault() else {
            return
        }
        NotificationCenter.default.addObserver(self, selector: #selector(CouponCodeListViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CouponCodeListViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        //Configure TableView
        self.txtCouponCode.delegate = self
        self.txtSearchField.delegate = self
        self.configureTableView()
        self.configureSelector()
        //GET Couponds
        self.getCouponCodeAPIRequest(userID: currentUser.userID)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
         self.addLocalisation()
         IQKeyboardManager.shared.enableAutoToolbar = false
    }
    func updateUseCoponCodeSelector(){
        if !self.isUserCouponEnable{
            self.btnUse.isEnabled = false
            self.btnUse.backgroundColor = UIColor.lightGray
        }else{
            self.btnUse.isEnabled = true
            self.btnUse.backgroundColor = UIColor.init(hexString:"36527D")
        }
    }
    func updateSelectfromListSelector(){
        self.buttonSelectFromList.isEnabled = self.isSelectFromListEnable
        if self.isSelectFromListEnable{
            let selectFromList = Vocabulary.getWordFromKey(key: "selectFromList.hint")
            self.buttonSelectFromList.setTitle("    \(selectFromList)    ", for: .normal)
            //self.buttonSelectFromList.titleLabel?.text = "  Select from list  "
            self.buttonSelectFromList.layer.borderColor = UIColor.init(hexString:"36527D").cgColor
            self.buttonSelectFromList.setTitleColor(UIColor.init(hexString:"36527D"), for: .normal)
            //self.buttonSelectFromList.titleLabel?.textColor = UIColor.init(hexString:"36527D")
        }else{
            let noavailableList = Vocabulary.getWordFromKey(key: "noavailablecoupon.hint")
            self.buttonSelectFromList.setTitle("    \(noavailableList)    ", for: .normal)
            //self.buttonSelectFromList.titleLabel?.text = "  No available coupons  "
            self.buttonSelectFromList.layer.borderColor = UIColor.lightGray.cgColor
            self.buttonSelectFromList.setTitleColor(UIColor.lightGray, for: .normal)
            //self.buttonSelectFromList.titleLabel?.textColor = UIColor.lightGray
        }
    }
    func addDynamicFont(){
        self.lblTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblTitle.adjustsFontForContentSizeCategory = true
        self.lblTitle.adjustsFontSizeToFitWidth = true
        
        self.txtCouponCode.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1).pointSize
        self.txtCouponCode.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.txtCouponCode.adjustsFontForContentSizeCategory = true
        
        self.btnUse.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
        self.btnUse.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnUse.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.lblOR.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblOR.adjustsFontForContentSizeCategory = true
        self.lblOR.adjustsFontSizeToFitWidth = true
        
        self.txtSearchField.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.txtSearchField.adjustsFontForContentSizeCategory = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        IQKeyboardManager.shared.enableAutoToolbar = true
        NotificationCenter.default.removeObserver(self)

    }
    // MARK: - Custom Methods
    func addLocalisation(){
        self.lblTitle.text = "\(Vocabulary.getWordFromKey(key: "couponcode.hint"))"
        self.btnUse.setTitle("\(Vocabulary.getWordFromKey(key: "usercc.hint"))", for: .normal)
        self.lblOR.text = "\(Vocabulary.getWordFromKey(key: "or.hint"))"
        self.txtSearchField.tweePlaceholder = "\(Vocabulary.getWordFromKey(key: "searchCouponCode.hint"))"
        self.txtCouponCode.tweePlaceholder = "\(Vocabulary.getWordFromKey(key: "yourCouponcode.hint"))"
        
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomConstraint.constant = self.getKeyboardSizeHeight() + 10
                print(keyboardSize)
                print(UIScreen.main.bounds.height)
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomConstraint.constant = 0
                print(keyboardSize)
                print(UIScreen.main.bounds.height)
                self.view.layoutIfNeeded()
            })
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
    func configureTableView(){
        let footerView = UIView()
        footerView.backgroundColor = UIColor.init(hexString:"F5F5F5")
        self.tableCoupon.tableFooterView = footerView
        self.tableCoupon.delegate = self
        self.tableCoupon.dataSource = self
        self.tableCoupon.separatorStyle = .none
    }
    func configureSelector(){
        self.isUserCouponEnable = false
        self.buttonSelectFromList.layer.borderWidth = 1.0
    }
    // MARK: - Selector Methods
    @IBAction func CancelBtnPressed(_ sender: Any) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func useBtnPressed(_ sender: Any) {
        guard self.strCouponCode.count > 0 else{
            return
        }
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        self.performSegue(withIdentifier: "unwindCheckOutFromCouponList", sender: nil)
    }
    @IBAction func buttonHideKeyBoardSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    @IBAction func buttonSelectFromList(sender:UIButton){
        DispatchQueue.main.async {
            self.presentCouponPicker()
        }
        
    }
    @IBAction func unwindToCouponCodeListFromSearch(segue:UIStoryboardSegue){
        self.performSegue(withIdentifier: "unwindCheckOutFromCouponList", sender: nil)
    }
    func presentCouponPicker(){
        if let currencyPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
            currencyPicker.modalPresentationStyle = .overFullScreen
            currencyPicker.objSearchType = .Coupon
            currencyPicker.arrayOfCoupon = self.arrayOfCoupon
            self.view.endEditing(true)
            
            self.present(currencyPicker, animated: true, completion: nil)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - API Request Methods
    func getCouponCodeAPIRequest(userID:String){
        
        let kGETCouponCodeURL = "payment/native/users/\(userID)/couponcodelist"
        //Default UserID will be 3
        //        let kURLWishlist = "\(kUserExperience)3/wishlist?pagesize=\(self.currentPageSize)&pageindex=\(self.currentPageIndex)"
        
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:kGETCouponCodeURL, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let array = successDate["Coupons"] as? [[String:Any]]{
                self.arrayOfCoupon = []
                for coupon in array{
                    let objCoupon = Coupon.init(couponDetail: coupon)
                    self.arrayOfCoupon.append(objCoupon)
                }
                DispatchQueue.main.async {
                    self.arrayOfFilterCoupon = self.arrayOfCoupon
                    self.tableCoupon.reloadData()
                }
                self.isSelectFromListEnable = array.count > 0
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "unwindCheckOutFromCouponList"{
            if let checkOutViewController: CheckOutViewController = segue.destination as? CheckOutViewController{
                checkOutViewController.strCoupenCode = self.strCouponCode
            }
        }
    }
}
extension CouponCodeListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arrayOfFilterCoupon.count > 0 {
            tableView.removeMessageLabel()
        }else{
            tableView.showMessageLabel(msg: Vocabulary.getWordFromKey(key:"noCouponCode.hint"), backgroundColor: .clear)
        }
        return self.arrayOfFilterCoupon.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let objCoupon = self.arrayOfFilterCoupon[indexPath.row]
        cell.textLabel?.text = "\(objCoupon.couponID)"
        cell.backgroundColor = UIColor.init(hexString: "F5F5F5")
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        let objCoupon = self.arrayOfFilterCoupon[indexPath.row]
        self.strCouponCode = "\(objCoupon.couponID)"
        self.performSegue(withIdentifier: "unwindCheckOutFromCouponList", sender: nil)
    }
}
extension CouponCodeListViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.strCouponCode = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
//        guard self.txtSearchField == textField else {
//            return true
//        }
        guard self.strCouponCode.count > 0 else {
            self.isUserCouponEnable = false
            self.arrayOfFilterCoupon = self.arrayOfCoupon
            DispatchQueue.main.async {
                self.tableCoupon.reloadData()
            }
            return true
        }
        self.isUserCouponEnable = true
        let filtered = self.arrayOfCoupon.filter { $0.couponID.localizedCaseInsensitiveContains("\(self.strCouponCode)") }
        self.arrayOfFilterCoupon = filtered
        DispatchQueue.main.async {
            self.tableCoupon.reloadData()
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.strCouponCode = ""
        guard self.txtSearchField == textField else {
            return true
        }
        self.arrayOfFilterCoupon = self.arrayOfCoupon
        DispatchQueue.main.async {
            self.tableCoupon.reloadData()
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
