//
//  AddCouponCodeViewController.swift
//  Live
//
//  Created by IPS on 16/08/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class AddCouponCodeViewController: UIViewController {

    fileprivate var kCouponCode:String = "CouponCode"
    fileprivate var kUserID:String = "UserId"
    
    var addCouponCodeParameters:[String:String] = [:]
    @IBOutlet var txtCouponCode:TweeActiveTextField!
    @IBOutlet var buttonBack:UIButton!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var buttonAddCode:RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCouponCodeParameters[kCouponCode] = ""
        
        //Configure AddCouponCode
        self.configureAddCouponCode()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.buttonBack.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.buttonBack.imageView?.tintColor = UIColor.black
        self.navigationController?.navigationBar.isHidden = true
        DispatchQueue.main.async {
               self.addAppLocalisation()
               self.addDynamicFont()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
    func addDynamicFont(){
        
    }
    func addAppLocalisation(){
        
    }
    func configureAddCouponCode(){
        self.txtCouponCode.delegate = self
    }
    func isValidCouponCode()->Bool{
        if self.addCouponCodeParameters[kCouponCode]!.count > 0{
            return true
        }else{
            return false
        }
    }
    func invalidCouponCodeNumber(){
        self.txtCouponCode.textColor = .red
        self.txtCouponCode.placeholderColor = .red
        self.txtCouponCode.invalideField()
        self.txtCouponCode.lineColor = .red
        self.txtCouponCode.activeLineColor = .red
        DispatchQueue.main.async {
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key:"Enter coupon code"))
        }
    }
    func validCouponCodeNumber(){
        self.txtCouponCode.textColor = .black
        self.txtCouponCode.placeholderColor = .black
        self.txtCouponCode.lineColor = .black
        self.txtCouponCode.activeLineColor = .black
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonAddCodeSelector(selector:UIButton){
        self.addCouponCodeAPIRequest()
    }
    // MARK: - API Request Methods
    func addCouponCodeAPIRequest(){
        if self.isValidCouponCode(){
            self.validCouponCodeNumber()
            if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(),currentUser.userID.count > 0{
                self.addCouponCodeParameters[kUserID] = "\(currentUser.userID)"
                let requestURL = "payment/couponcode"
                APIRequestClient.shared.sendRequest(requestType: .POST, queryString: requestURL, parameter: self.addCouponCodeParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                    if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any]{
                        DispatchQueue.main.async {
                            ShowToast.show(toatMessage:"\(successData)")
                        }
                    }else{
                        
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
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
}
extension AddCouponCodeViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        self.addCouponCodeParameters[kCouponCode] = "\(typpedString)"
        return true
    }
}
