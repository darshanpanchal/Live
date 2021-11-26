//
//  HomeViewController.swift
//  Live
//
//  Created by ITPATH on 4/11/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import SendBirdSDK

class HomeViewController: UITabBarController {

    var countrydetail:CountyDetail?
    var timer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.layer.borderWidth = 0.5
        self.tabBar.layer.borderColor = UIColor(hexString: "4D000000").cgColor
        self.tabBar.clipsToBounds = true
        if let _ = self.viewControllers{
            guard self.viewControllers!.count > 0 else {
                return
            }
            if let discoverViewController = self.viewControllers!.first as? DiscoverViewController{
                discoverViewController.countryDetail = self.countrydetail
            }
        }
//        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        if User.isUserLoggedIn{
            timer.invalidate() // just in case this button is tapped multiple times
            // start the timer
            timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
    }
    @objc func timerAction() {
      self.getUnreadcount()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.tabBar.items![1].badgeValue = "\(kAppDel.totalUnReadMessageCount)"
     
    }
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ConnectionManager.login { (user, error) in
            guard error != nil else {
                print("*****CONNECTION SUCCESSFULLY")
                self.getUnreadcount()
                return;
            }
            
            return;
        }

//        DispatchQueue.main.async {
//            super.viewWillAppear(animated)
//        }
        //Get User Role
        self.getUsertype()
        UIApplication.shared.statusBarStyle = .default
        self.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationController?.navigationBar.isHidden = true
    }
    func getUnreadcount(){
        SBDGroupChannel.getTotalUnreadMessageCount { (count, error) in
            guard error == nil else {
                return
            }
            if Int(count) > 0{
                if let strBadge = self.tabBar.items![1].badgeValue,Int(strBadge) == Int(count){
                    return
                }
                self.tabBar.items![1].badgeValue = "\(Int(count))"
            }else{
                 self.tabBar.items![1].badgeValue = nil
            }
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - API Request Methods
    func getUsertype(){
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            let userTypeParameters = ["email":"\(currentUser.userEmail)"]

            APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kGetUserType, parameter:userTypeParameters as [String : AnyObject],isHudeShow: false,success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let userDetail = success["data"] as? [String:Any]{
                        if let _ = userDetail["UserType"]{
//                            currentUser.userRole = "\(userDetail["UserType"]!)"
                            currentUser.userDefaultRole = "\(userDetail["UserType"]!)"
                        }
                    if let strProvision = userDetail["Provision"],!(strProvision is NSNull) {
                        currentUser.userProvision = "\(strProvision)"
                    }
                    if let _ = userDetail["GuideRequestStatus"]{
                        currentUser.guideRequestStatus = "\(userDetail["GuideRequestStatus"]!)"
                    }
                        if let _ = userDetail["RoleId"]{
                            currentUser.userRoleID = "\(userDetail["RoleId"]!)"
                        }
                    if let _ = userDetail["ProfileImage"],!(userDetail["ProfileImage"]! is  NSNull) {
                        currentUser.userImageURL = "\(userDetail["ProfileImage"]!)"
                    }else{
                        currentUser.userImageURL = ""
                    }
                        currentUser.setUserDataToUserDefault()
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
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
