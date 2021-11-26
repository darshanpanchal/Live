//
//  LogInTableViewCell.swift
//  Live
//
//  Created by ITPATH on 4/4/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class LogInTableViewCell: UITableViewCell {

    @IBOutlet var textFieldLogIn:TweeActiveTextField!
    @IBOutlet var btnDropDown:UIButton!
    @IBOutlet var btnSelect:UIButton!
    var cellFrame:CGRect?
    @IBOutlet var leadingContainer:NSLayoutConstraint!
    @IBOutlet var trailingContainer:NSLayoutConstraint!
    @IBOutlet var trailingButtonDropDown:NSLayoutConstraint!
    @IBOutlet var imageTick:UIImageView!
    var iconClick = true
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.textFieldLogIn.setRightPaddingPoints(20.0)
        //self.textFieldLogIn.minimumFontSize = 25.0
        self.textFieldLogIn.adjustsFontSizeToFitWidth = false
        self.textFieldLogIn.setNeedsLayout()
        self.textFieldLogIn.layoutIfNeeded()
        DispatchQueue.main.async {
            //self.addDynamicFont()
            self.btnDropDown.imageView?.contentMode = .scaleToFill
            self.imageTick.image = #imageLiteral(resourceName: "tick_select").withRenderingMode(.alwaysTemplate)
            self.imageTick.tintColor = UIColor.init(hexString: "#36527D")
        }
    }
    func addDynamicFont(){
        self.textFieldLogIn.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1).pointSize
        self.textFieldLogIn.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.textFieldLogIn.adjustsFontForContentSizeCategory = true
        //self.textFieldLogIn.maximizePlaceholder()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        DispatchQueue.main.async {
            self.btnDropDown.setImage(#imageLiteral(resourceName: "passwordDisable"), for: .normal)
            self.iconClick = true
            self.btnDropDown.imageView?.tintColor = UIColor.white
            self.addDynamicFont()
        }
    }
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
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
    func setTextFieldColor(textColor:UIColor,placeHolderColor:UIColor){
        self.textFieldLogIn.textColor = textColor
        //self.textFieldLogIn.activeLineColor = textColor
        //self.textFieldLogIn.lineColor = textColor
        self.textFieldLogIn.placeholderColor = placeHolderColor
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
/*
extension TweeActiveTextField {
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}*/
