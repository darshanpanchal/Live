//
//  RootViewController.swift
//  Live
//
//  Created by ITPATH on 4/2/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit



class RootViewController: UIViewController {
    
    @IBOutlet var backgroundImageView:UIImageView!
    @IBOutlet var buttonSkip:UIButton!
    @IBOutlet var buttonFacebookLogin:FBSDKLoginButton!
    @IBOutlet var buttonMyLive:RoundButton!
    @IBOutlet var buttonCreateAccount:RoundButton!
    @IBOutlet var buttonGuideRequest:RoundButton!
    
    @IBOutlet var verticalSpacing:NSLayoutConstraint!
    
    var isDeviceIPhone5:Bool{
        get{
            return (UIScreen.main.bounds.height == 568.0) ? true : false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add Border and Corner
        self.addBorderOnButton()
        //Check Bottom Content Vertical Spacing
        self.checkForVerticalSpacing()
        //Configure random background
        self.configureRandomBackground()
        //Check for loggedIn status
        self.checkForLogInStatus()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Hide NavigationBar
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
    func addBorderOnButton(){
        self.buttonFacebookLogin.layer.cornerRadius = 22.5
        self.buttonFacebookLogin.layer.masksToBounds = true
        self.buttonFacebookLogin.clipsToBounds = true
        self.buttonMyLive.addBorderWith(width: 1.5, color: UIColor.white)
        self.buttonMyLive.setBackgroundColor(color: UIColor.black.withAlphaComponent(0.3), forState: .highlighted)
        self.buttonGuideRequest.setBackgroundColor(color: kDarkOrange, forState: UIControlState.highlighted)
        self.buttonCreateAccount.setBackgroundColor(color: kDarkOrange, forState: UIControlState.highlighted)
        self.buttonFacebookLogin.setBackgroundColor(color: kDarkBlue, forState: UIControlState.highlighted)
    }
    
    func checkForVerticalSpacing(){
        self.verticalSpacing.constant = (isDeviceIPhone5) ? 50.0 : 100.0
    }
    func configureRandomBackground(){
        switch arc4random_uniform(3) {
            case 0:
                self.backgroundImageView.image = #imageLiteral(resourceName: "rootbackground0").withRenderingMode(.alwaysOriginal)
                return
            case 1:
                self.backgroundImageView.image = #imageLiteral(resourceName: "rootbackground1").withRenderingMode(.alwaysOriginal)
                return
            case 2:
                self.backgroundImageView.image = #imageLiteral(resourceName: "rootbackground2").withRenderingMode(.alwaysOriginal)
                return
            default:
                return
        }
    }
    func checkForLogInStatus(){
        if (User.isUserLoggedIn){
            if let homeViewController:HomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController{
                self.navigationController?.pushViewController(homeViewController, animated: false)
            }
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonSkipSelector(sender:UIButton){
        if let whereToNextViewController:WhereToNextViewController = self.storyboard?.instantiateViewController(withIdentifier: "WhereToNextViewController") as? WhereToNextViewController{
            self.navigationController?.pushViewController(whereToNextViewController, animated: false)
        }
    }
    @IBAction func buttonFaceBookLogInSelector(sender:RoundButton){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: "Please check your connection and try again.")
            return
        }
        FaceBookLogIn.basicInfoWithCompletionHandler(self) { (result, error) in
            guard error == nil else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                }
                return
            }
            ShowToast.show(toatMessage: "Success Facebook LogIn.")
            print(FBSDKAccessToken.current().appID)
            print(FBSDKAccessToken.current().tokenString)
        }
    }
    @IBAction func buttonMyLiveSelector(sender:RoundButton){
        
    }
    @IBAction func buttonCreateAccountSelector(sender:RoundButton){
        
    }
    @IBAction func buttonGuideRequestSelector(sender:RoundButton){
        
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
extension RootViewController{
}
