//
//  MDCTextFieldTableViewCell.swift
//  Live
//
//  Created by user on 18/01/19.
//  Copyright © 2019 ITPATH. All rights reserved.
//

import UIKit
import MaterialComponents

class MDCTextFieldTableViewCell: UITableViewCell {
    @IBOutlet var textFieldLogIn:MDCTextField!
    @IBOutlet var btnDropDown:UIButton!
    @IBOutlet var trailingButtonDropDown:NSLayoutConstraint!
    @IBOutlet var imgError:UIImageView!
    
    var iconClick = true
    var textFieldOutliine: MDCTextInputControllerOutlined?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.textFieldLogIn.setRightPaddingPoints(20.0)
        //self.imgError.image = self.imgError.image?.withRenderingMode(.alwaysTemplate)
        //self.imgError.tintColor = UIColor.init(red: 167.0/255.0, green: 0, blue: 29.0/255.0, alpha: 1.0)
        textFieldOutliine = MDCTextInputControllerOutlined(textInput: textFieldLogIn)
        
        textFieldOutliine?.normalColor = UIColor.black.withAlphaComponent(0.5)
        textFieldOutliine?.activeColor = UIColor.init(hexString:"36527D")
        textFieldOutliine?.floatingPlaceholderActiveColor = UIColor.init(hexString:"36527D")
        textFieldOutliine?.errorColor = UIColor.red//UIColor.init(red: 167.0/255.0, green: 0, blue: 29.0/255.0, alpha: 1.0)
        textFieldOutliine?.floatingPlaceholderScale = 0.8
        textFieldOutliine?.leadingUnderlineLabelTextColor = UIColor.init(hexString:"36527D")
        // Initialization code
        textFieldOutliine?.underlineViewMode = .whileEditing

    }
    func addDynamicFont(){
        self.textFieldLogIn.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.textFieldLogIn.adjustsFontForContentSizeCategory = true
        //self.textFieldLogIn.maximizePlaceholder()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    func textFieldBecomeFirstResponder(strHelper:String){
        self.textFieldOutliine?.setHelperText(strHelper, helperAccessibilityLabel: nil)
    }
    func textFieldResignFirstResponder(strError:String){
        self.btnDropDown.isHidden = false
        self.imgError.isHidden = true
        self.textFieldOutliine?.setErrorText(nil, errorAccessibilityValue: nil)
    }
    func textFieldError(strError:String){
        self.textFieldOutliine?.errorColor = UIColor.red
        self.btnDropDown.isHidden = true
        self.imgError.isHidden = false
        self.textFieldOutliine?.setErrorText("\(strError)", errorAccessibilityValue: nil)
    }
    @IBAction func btnForPasswordField(_ sender: Any) {
        if(iconClick == true) {
            self.textFieldLogIn.isSecureTextEntry = false
            if btnDropDown.tag == 101 {
                self.btnDropDown.setImage(#imageLiteral(resourceName: "passwordEnable_black").withRenderingMode(.alwaysTemplate), for: .normal)
                self.btnDropDown.imageView?.tintColor = UIColor.black.withAlphaComponent(0.5)
            } else {
                self.btnDropDown.setImage(#imageLiteral(resourceName: "passwordEnable"), for: .normal)
                self.btnDropDown.imageView?.tintColor = UIColor.white
            }
            iconClick = false
        } else {
            self.textFieldLogIn.isSecureTextEntry = true
            if btnDropDown.tag == 101 {
                self.btnDropDown.setImage(#imageLiteral(resourceName: "passwordDisable_black").withRenderingMode(.alwaysTemplate), for: .normal)
                self.btnDropDown.imageView?.tintColor = UIColor.black.withAlphaComponent(0.5)
            } else {
                self.btnDropDown.setImage(#imageLiteral(resourceName: "passwordDisable"), for: .normal)
                self.btnDropDown.imageView?.tintColor = UIColor.white
            }
            iconClick = true
        }
        DispatchQueue.main.async {
            self.textFieldLogIn.becomeFirstResponder()
            let currentText: String = self.textFieldLogIn.text!
            self.textFieldLogIn.text = "";
            self.textFieldLogIn.text = currentText
        }
    }
}

extension UITextField {
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
