//
//  DescriptionViewController.swift
//  Live
//
//  Created by ips on 24/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class DescriptionViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var saveBtn: RoundButton!
    @IBOutlet weak var navTitle: UILabel!
    @IBOutlet weak var descriptionTxtView: UITextView!
    @IBOutlet var bottomConstraintSave:NSLayoutConstraint!
    @IBOutlet var lblHint:UILabel!
    @IBOutlet var buttonBack:UIButton!
    
    var descriptionString: String = ""
    var experienceDescriptionMax:Int{
        get{
            return 150
        }
    }
    let placeHolderString = Vocabulary.getWordFromKey(key: "descriptionPlaceholder")
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonBack.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.buttonBack.imageView?.tintColor = UIColor.black
        self.navTitle.text = Vocabulary.getWordFromKey(key: "yourbio.hint")
        self.saveBtn.setTitle(Vocabulary.getWordFromKey(key: "save.title"), for: .normal)
//        self.descriptionTxtView.layer.borderWidth = 1.0
//        self.descriptionTxtView.layer.borderColor = UIColor.black.cgColor
        self.descriptionTxtView.delegate = self
//        self.saveBtn.layer.cornerRadius = 20.0
//        self.descriptionTxtView.layer.cornerRadius = 10.0
//        self.descriptionTxtView.clipsToBounds = true
        self.saveBtn.clipsToBounds = true
        let discriptionTap = UITapGestureRecognizer(target: self, action:#selector(discriptionTapGesture(_:)))
        discriptionTap.numberOfTapsRequired = 1
        self.descriptionTxtView.addGestureRecognizer(discriptionTap)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.scrollTextViewToBottom(textView: self.descriptionTxtView)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getGuideDescriptionFromId()
        if self.descriptionTxtView.text == "" {
            descriptionTxtView.text = placeHolderString
            descriptionTxtView.textColor = UIColor.lightGray
        } else {
            descriptionTxtView.textColor = UIColor.black
        }
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
        
        self.descriptionTxtView.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        
        self.saveBtn.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.saveBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        self.saveBtn.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self)
    }
    @objc func discriptionTapGesture(_ gesture:UITapGestureRecognizer){
        self.descriptionTxtView.dataDetectorTypes = UIDataDetectorTypes(rawValue: 0)
        self.descriptionTxtView.isEditable = true
        self.descriptionTxtView.becomeFirstResponder()
    }
    
    //MARK:- UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTxtView.textColor == UIColor.lightGray {
            descriptionTxtView.text = ""
            descriptionTxtView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.descriptionTxtView.contentOffset = CGPoint.zero
        self.descriptionTxtView.isEditable = false
        self.descriptionTxtView.dataDetectorTypes = .all
        if descriptionTxtView.text == "" {
            descriptionTxtView.text = placeHolderString
            descriptionTxtView.textColor = UIColor.lightGray
        }
//        let str = self.filterURLs()
//        textView.hyperLink(originalText: self.descriptionTxtView.text, hyperLink: str[0], urlString: str[0])
//        print(str)
    }
    func scrollTextViewToBottom(textView: UITextView) {
        if textView.text.count > 0 {
            let location = textView.text.count - 1
            let bottom = NSMakeRange(location, 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async {
                //self.descriptionTxtView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height + 30.0, 0)
                UIView.animate(withDuration: 0.1, animations: {
                    self.bottomConstraintSave.constant = keyboardSize.height + 30.0
                    self.loadViewIfNeeded()
                }, completion: { (true) in
                    self.scrollTextViewToBottom(textView: self.descriptionTxtView)
                })
            }
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async {
                self.descriptionTxtView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                UIView.animate(withDuration: 0.2, animations: {
                    self.bottomConstraintSave.constant = 10.0
                    self.view.endEditing(true)
                    self.loadViewIfNeeded()
                })
            }
            
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let typpedString = ((textView.text)! as NSString).replacingCharacters(in: range, with: text)
        if text == "\n"{
            textView.resignFirstResponder()
            return true
        }
        if typpedString.count > 0{
            self.lblHint.text = "Tell a little bit about yourself"
        }else{
            self.lblHint.text = "Write your description here, maximum 150 words"
        }
        let components = typpedString.components(separatedBy: .whitespacesAndNewlines)
        let words = components.filter { !$0.isEmpty }
        return  words.count < self.experienceDescriptionMax
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        //let typpedString = ((textView.text)! as NSString).replacingCharacters(in: range, with: text)
        
        return true
    }
    
    //MARK:- API Calling
    func getGuideDescriptionFromId(){
        let currentUser = User.getUserFromUserDefault()
        let userId = currentUser?.userID
        let url = "users/\(userId!)/native/description"

        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:url, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let descriptionText = successDate["Description"] as? String {
                DispatchQueue.main.async {
                    if descriptionText.count > 0{
                        self.lblHint.text = "Tell a little bit about yourself"
                        self.descriptionTxtView.text = descriptionText
                        self.descriptionTxtView.textColor = UIColor.black
                    } else {
                        self.descriptionTxtView.text = self.placeHolderString
                        self.descriptionTxtView.textColor = UIColor.lightGray
                        self.lblHint.text = "Write your description here, maximum 150 words"

                    }
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
    
    // Update Guide Description
    func updateGuideDescritption() {
        let currentUser: User? = User.getUserFromUserDefault()
        let userId: String = (currentUser?.userID)!
        let urlUpdateDescription = "users/\(userId)/native/editdescription"
        let parameters = ["comment": "\(self.descriptionTxtView.text!)"] as [String: AnyObject]
        APIRequestClient.shared.sendRequest(requestType: .PUT, queryString:urlUpdateDescription, parameter: parameters, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let _ = success["data"] as? [String:Any] {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
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
    
    //MARK:- Selector Methods
    @IBAction func saveBtnPressed(_ sender: Any) {
        if descriptionTxtView.text == placeHolderString {
            let validationAlert = UIAlertController(title: Vocabulary.getWordFromKey(key:"Description"), message: Vocabulary.getWordFromKey(key:"Description.noData"),preferredStyle: UIAlertControllerStyle.alert)
            validationAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (_) in
               self.descriptionTxtView.becomeFirstResponder()
            }))
            self.present(validationAlert, animated: false, completion: nil)
        }
       else if descriptionTxtView.text == "" {
                let validationAlert = UIAlertController(title: Vocabulary.getWordFromKey(key:"Description.noData"), message: Vocabulary.getWordFromKey(key:"Description.required"),preferredStyle: UIAlertControllerStyle.alert)
                validationAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: nil))
                self.present(validationAlert, animated: false, completion: nil)
        } else {
            self.updateGuideDescritption()
        }
    }
    @IBAction func cancelBtnPresse(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension UITextView {
    func hyperLink(originalText: String, hyperLink: String, urlString: String) {
        let attributedOriginalText = NSMutableAttributedString(string: originalText)
        let linkRange = attributedOriginalText.mutableString.range(of: hyperLink)
        attributedOriginalText.addAttribute(NSAttributedStringKey.link, value: urlString, range: linkRange)
        self.linkTextAttributes = [
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.blue,
            NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue,
        ]
        self.attributedText = attributedOriginalText
    }
}
