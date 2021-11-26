//
//  RecoverPasswordViewController.swift
//  Live
//
//  Created by ITPATH on 4/18/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class RecoverPasswordViewController: UIViewController {
    @IBOutlet var soonYouWillLbl:UILabel!
    @IBOutlet var receiveEmailLbl:UILabel!
    @IBOutlet var buttonRecoveryCode:RoundButton!
    @IBOutlet var buttonBack:UIButton!
    var userEmailID:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        //Configure Button
        self.soonYouWillLbl.text = Vocabulary.getWordFromKey(key: "SoonYouWill.title")
        self.receiveEmailLbl.text = Vocabulary.getWordFromKey(key: "emailReceive.title")
        self.buttonRecoveryCode.setTitle(Vocabulary.getWordFromKey(key: "gotCode.title"), for: .normal)
        self.buttonRecoveryCode.setBackgroundColor(color: UIColor.lightGray.withAlphaComponent(0.5), forState: UIControlState.highlighted)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.endEditing(true)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .default
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.receiveEmailLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.receiveEmailLbl.adjustsFontForContentSizeCategory = true
        self.receiveEmailLbl.adjustsFontSizeToFitWidth = true
        
        self.buttonRecoveryCode.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonRecoveryCode.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonRecoveryCode.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.popToBackViewController()
    }
    @IBAction func buttonRecoverySelector(sender:UIButton){
        //Push to reset password if user got recovery code
        self.pushToResetPassword()
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    //Push To reset password
    func pushToResetPassword(){
        if let resetPassword = self.storyboard?.instantiateViewController(withIdentifier:"ResetPasswordViewController") as? ResetPasswordViewController{
            resetPassword.userEmailID = "\(self.userEmailID)"
            self.navigationController?.pushViewController(resetPassword, animated: true)
        }
    }
    func popToBackViewController(){
        self.navigationController?.popViewController(animated: true)
    }
}
