
//
//  AppDelegate.swift
//  Live
//
//  Created by ITPATH on 4/2/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
import SendBirdSDK
import Firebase
import FacebookCore
import UserNotifications
import ZendeskSDK
import ZendeskCoreSDK
import FirebaseInstanceID
import FirebaseMessaging
import SDWebImage
import UberCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
    var receivedPushChannelUrl: String?
    var isPaypalEnable:Bool = false
    var isPayPalSandBox:Bool = false
    var totalUnReadMessageCount:Int = 0
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        //Configure Facebook delegate //1878173228868539 // 278956509502444
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        IQKeyboardManager.shared.enable = true
        //Configure Tabbar
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().tintColor = UIColor.black
        UITabBar.appearance().backgroundImage = UIColor.white.imageRepresentation
        UITabBar.appearance().shadowImage = UIColor.black.imageRepresentation
        //537F086F-722B-41FF-8D60-8D742E99C912 //staging

        SBDMain.initWithApplicationId("1747852A-4D64-4008-852E-EA17D17A16B2")
        SBDMain.setLogLevel(SBDLogLevel.none)
        SBDOptions.setUseMemberAsMessageSender(true)
        GMSServices.provideAPIKey("AIzaSyC5N0EGpVw0zFQyrTF1alLsSzP07Kygy4E")
        GMSPlacesClient.provideAPIKey("AIzaSyC5N0EGpVw0zFQyrTF1alLsSzP07Kygy4E")

        //Add UserNotification
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
            Messaging.messaging().delegate = (self as MessagingDelegate)
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
        application.registerForRemoteNotifications()
        
        //Configure Firebase
        FirebaseApp.configure()
        
//        SDImageCache.shared().config.maxCacheAge = 3600 * 24 * 7 //1 Week
//
//        SDImageCache.shared().maxMemoryCost = 1024 * 1024 * 1000 //Aprox 20 images
//
        SDImageCache.shared().config.shouldCacheImagesInMemory = true //Default True => Store images in RAM cache for Fast performance
        
        SDImageCache.shared().config.shouldDecompressImages = false
        
        SDWebImageDownloader.shared().shouldDecompressImages = false
//
//        SDImageCache.shared().config.diskCacheReadingOptions = NSData.ReadingOptions.mappedIfSafe

        //Configure Zendesk
        Zendesk.initialize(appId: "49828dfb5177b93f04be49fffbe206a9740c0bbcd455c500",
                           clientId: "mobile_sdk_client_5d937eaca5d78439b050  ",
                           zendeskUrl: "https://liveinternational.zendesk.com")
        /*
        Zendesk.initialize(appId: "065d1024d3572bf95b57bf8d4a5770fdbd51c079a705936c",
                           clientId: "mobile_sdk_client_4b051296eeb82e494d97",
                           zendeskUrl: "https://itpathsolutions.zendesk.com")
        */

        let identity = Identity.createAnonymous()
        Zendesk.instance?.setIdentity(identity)
        
        Support.initialize(withZendesk: Zendesk.instance)
        
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            print(countryCode)
        }
        ConnectionManager.login { (user, error) in
            guard error != nil else {
                print("*****CONNECTION SUCCESSFULLY")
                self.getUnreadcount()
                return;
            }
            
            return;
        }
        
        //self.redirectToDirectreply(userInfo: ["experience_title":"test 123" as AnyObject,"user_id":"24" as AnyObject,"guide_id":"29" as AnyObject,"image":"https://s3-us-west-2.amazonaws.com/live-experiences-image/2e3e8656-0908-4692-8ac7-4fc85d2485c1-image.png" as AnyObject])
       // self.redirectToMYLive(isForScheduleHistory:true)
        /*for family: String in UIFont.familyNames
        {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }*/
        self.checkForApplicationSharing()
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                NSAttributedStringKey.font : UIFont(name: "Avenir-Heavy", size: 15)!,
                NSAttributedStringKey.foregroundColor : UIColor.init(hexString:"36527D"),
                ], for: .normal)
        UIBarButtonItem.appearance().tintColor = UIColor.init(hexString:"36527D")
        self.configurePaypalDynamic()
        /*
        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentSandbox:"AfV_kak_lInnq3ByC19XHiv2u56B6vRHpGWJddI57DYSxlB8Pb5wdZxsEmyGzOaVtkk5iKyX-AVbqnDP",
                                                               PayPalEnvironmentProduction:"AbG1KqUsmDtc7wTZ0rMQxVy6gqOtH35o_BiFE-vIyGsirF4U9Uelzpb7UUNBFqplAHqKa_KiItfmJBXz"])
        */
        
        
        self.requestForAppInstallSummary()
        print("\(self.getLanguageISO())")
        return true
    }
    func getLanguageISO() -> String {
        let locale = Locale.current
        guard let languageCode = locale.languageCode,
            let regionCode = locale.regionCode else {
                return "de_DE"
        }
        return languageCode + "_" + regionCode
    }
    func getUnreadcount(){
        SBDGroupChannel.getTotalUnreadMessageCount { (count, error) in
            guard error == nil else {    // Error.
                print("====\(error?.localizedDescription)=====")
                return
            }
            self.totalUnReadMessageCount = Int(count)
            if let rootNavigationController = self.window?.rootViewController as? UINavigationController{
                for controller in rootNavigationController.viewControllers{
                    if let homeViewController = controller as? HomeViewController{
                        if Int(count) > 0{
                            homeViewController.tabBar.items![1].badgeValue = "\(Int(count))"
                        }
                        break
                    }
                }
            }
           
        }
    }
    func configurePaypalDynamic(){
        let requestConfigurePaypal = "experience/paypalconfiguration"
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString: requestConfigurePaypal, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let clientID = success["ClientId"],let environment = success["Environment"],let isPaypal = success["IsPaypalEnable"]{
                self.isPaypalEnable = Bool.init("\(isPaypal)")
                if "\(environment)".compareCaseInsensitive(str: "sandbox"){
                    self.isPayPalSandBox = true
                    PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentSandbox:"\(clientID)"])
                }else{
                    self.isPayPalSandBox = false
                    PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction:"\(clientID)"])
                }
            }
        }) { (responseFail) in
            if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "Error "+kCommonError)
                }
            }
        }
    }
    func checkForApplicationSharing(){
        if let installDate = kUserDefault.value(forKey: kIsAppShareViaMSG) as? Date{
            let components = Calendar.current.dateComponents([.minute,.day,.second], from: installDate, to: Date())
            if User.isUserLoggedIn{
                if let installedDay = components.day,installedDay >= 4{
                    DispatchQueue.main.async {
                        kUserDefault.removeObject(forKey: kIsAppShareViaMSG)
                        self.shareApplication()
                    }
                }else{
                    self.getAPIRequestforLatestReviewExperience()
                }
            }
        }else{ //First time install
            kUserDefault.set(Date(), forKey: kIsAppShareViaMSG)
        }
        kUserDefault.synchronize()
    }
    func shareApplication(){
        let alert = UIAlertController(title: "\(Vocabulary.getWordFromKey(key: "share.hint"))", message: "\(Vocabulary.getWordFromKey(key: "sharetext.hint"))", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction.init(title: "\(Vocabulary.getWordFromKey(key: "no"))", style: .default, handler: nil))
        alert.addAction(UIAlertAction.init(title: "\(Vocabulary.getWordFromKey(key: "yes"))", style: .default, handler: { (_ ) in
            DispatchQueue.main.async {
                var strShare:String = ""
                if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
                   strShare = "\(currentUser.userFirstName) \(currentUser.userLastName) \(Vocabulary.getWordFromKey(key: "shareBodyAfterDay.hint"))"
                }
                self.shareApplicationWithActivity(shareText:strShare.count > 0 ? strShare:"Live")
            }
        }))
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        self.window?.makeKeyAndVisible()

    }
    func getAPIRequestforLatestReviewExperience(){
        guard User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault() else{
            return
        }
        var latestBookingParam:[String:Any] = [:]
        latestBookingParam["UserId"] = "\(currentUser.userID)"
        latestBookingParam["BookingTime"] = "\(Date())".changeDateFormateDDMMS
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kGetLatestBooking, parameter:latestBookingParam as [String : AnyObject],isHudeShow: false,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let latestBookingData = success["data"] as? [String:Any],let latestBooking = latestBookingData["LatestBooking"] as? [String:Any]{
                let objExperience:Experience = Experience.init(experienceDetail: latestBooking)
                DispatchQueue.main.async {
                    if objExperience.isRated{ //share experience with friends if user rated
                        self.directShareExperience(objExperience: objExperience)
                    }else{ //show experience review popup and manage added review or not
                        self.presentReviewController(objExperience: objExperience)
                    }
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
    func directShareExperience(objExperience:Experience){
        let strShareRated = "\(Vocabulary.getWordFromKey(key: "directsharefirst.hint")) \(objExperience.title) \(Vocabulary.getWordFromKey(key: "directsharesecond.hint"))"
        let alert = UIAlertController(title: "\(Vocabulary.getWordFromKey(key: "share.hint"))", message:strShareRated, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction.init(title: "\(Vocabulary.getWordFromKey(key: "no"))", style: .default, handler: nil))
        alert.addAction(UIAlertAction.init(title: "\(Vocabulary.getWordFromKey(key: "yes"))", style: .default, handler: { (_ ) in
            DispatchQueue.main.async {
                var strShare:String = ""
                if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
                    strShare = "\(currentUser.userFirstName) \(currentUser.userLastName) \(Vocabulary.getWordFromKey(key: "directsharebody.hint"))"
                }
                self.shareApplicationWithActivity(shareText:strShare.count > 0 ? strShare:"Live")
            }
        }))
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        self.window?.makeKeyAndVisible()
    }
    //PresentReview
    func presentReviewController(objExperience:Experience){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let reviewViewController = sb.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController{
            reviewViewController.modalPresentationStyle = .overFullScreen
            reviewViewController.objExperience = objExperience
            reviewViewController.objReviewDelegate = self
            self.window?.rootViewController?.present(reviewViewController, animated: false, completion: nil)
        }
    }
    func shareApplicationWithActivity(shareText:String){
        let myWebsite = NSURL(string:"https://itunes.apple.com/us/app/live-private-guided-tours/id1317979792?ls=1&mt=8")
        let shareAll = ["\(shareText)",myWebsite!] as [Any]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.window // so that iPads won't crash
        self.window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let   tokenString = deviceToken.reduce("", {$0 + String(format: "%02X",    $1)})
       // if let tokenString = InstanceID.instanceID().token() {
            kUserDefault.set("\(tokenString)", forKey: kPushNotificationToken)
            kUserDefault.synchronize()
       // }
        self.requestForAppInstallSummary()
        SBDMain.registerDevicePushToken(deviceToken, unique: true) { (status, error) in
            if error == nil {
                if status == SBDPushTokenRegistrationStatus.pending {
                    
                }
                else {
                    
                }
            }
            else {
                
            }
        }
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        let alert = UIAlertController(title: "Test", message:"didFailToRegisterForRemoteNotificationsWithError \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        // show the alert
        //self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    func requestForAppInstallSummary(){
        
        var appinstallSummary:[String:Any] = [:]
        appinstallSummary["DeviceUniqueId"] = ""
        appinstallSummary["VersionNumber"] = "\(Bundle.main.versionNumber)" //version
        appinstallSummary["VersionCode"] = "\(Bundle.main.buildNumber)"//build
        appinstallSummary["DeviceToken"] = ""
        appinstallSummary["DeviceType"] = "iPhone"
     
        if let token = kUserDefault.value(forKey:kPushNotificationToken){
            appinstallSummary["DeviceToken"] = "\(token)"
        }
        if let udid = UIDevice.current.identifierForVendor{
            appinstallSummary["DeviceUniqueId"] = "\(udid.uuidString)"
        }
        print(appinstallSummary)
        let requestForAppInstall = "base/appinstalls"
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: requestForAppInstall, parameter: appinstallSummary as [String : AnyObject], isHudeShow: false, success: { (responseSuccess) in
            print("\(responseSuccess)")
        }) { (responseFail) in
            print("\(responseFail)")
        }
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        let alert = UIAlertController(title: "Test", message:"didReceiveRemoteNotification \(userInfo)", preferredStyle: UIAlertControllerStyle.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        // show the alert
        //self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        if userInfo["sendbird"] != nil {
            let sendBirdPayload = userInfo["sendbird"] as! Dictionary<String, Any>
            let channel = (sendBirdPayload["channel"]  as! Dictionary<String, Any>)["channel_url"] as! String
            let channelType = sendBirdPayload["channel_type"] as! String
            if channelType == "group_messaging" {
                self.receivedPushChannelUrl = channel
            }
        }
    }
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        debugPrint("method for handling events for background url session is waiting to be process. background session id: \(identifier)")
        completionHandler()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handledUberURL = UberAppDelegate.shared.application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation] as Any)
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options) || handledUberURL
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let handledUberURL = UberAppDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) || handledUberURL
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //FBSDKAppEvents.activateApp()
        //AppEventsLogger.activate(application)
        FBSDKAppEvents.activateApp()
        self.updateUserCultureAPIRequest()
    }
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    //Mark: Update user culture
    func updateUserCultureAPIRequest(){
        guard User.isUserLoggedIn else {
            return
        }
        let updateUserCulture = "users/native/updateuserculture"
        var updateUserParameters:[String:Any] = [:]
        updateUserParameters["UserId"] = "\(User.getUserFromUserDefault()!.userID)"
        updateUserParameters["Culture"] = "\(self.getDeviceCulture())"
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: updateUserCulture, parameter: updateUserParameters as [String : AnyObject], isHudeShow: false, success: { (responseSuccess) in
            
        }) { (responseFail) in
            
        }
        
    }
    func getDeviceCulture() -> String {
        let locale = Locale.current
        guard let languageCode = locale.languageCode,
            let regionCode = locale.regionCode else {
                return "de_DE"
        }
        return languageCode + "_" + regionCode
    }
    func redirectToMYLive(isForScheduleHistory:Bool,objPendingBooking:PendingExperience?){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let bookingStoryboard = UIStoryboard(name: "BooknowDetailSB", bundle: nil)

        let vc = sb.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
        let vc1 = sb.instantiateViewController(withIdentifier: "WhereToNextViewController") as? WhereToNextViewController
        let vc3 = sb.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
        let vc4 = sb.instantiateViewController(withIdentifier: "FullScheduleViewController") as? FullScheduleViewController
        let paymentViewController = bookingStoryboard.instantiateViewController(withIdentifier: "PaymentViewController") as? PaymentViewController

        vc4?.isLoadHistory = false
        vc3?.selectedIndex = 2
        let nav =  UINavigationController.init(rootViewController: vc!)
        nav.isNavigationBarHidden = true
        nav.pushViewController(vc1!, animated: false)
        nav.pushViewController(vc3!, animated: false)
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            if isForScheduleHistory{
                currentUser.userType = .guide
            }else{
                currentUser.userType = .traveller
            }
            currentUser.setUserDataToUserDefault()
        }
        if isForScheduleHistory{
            nav.pushViewController(vc4!, animated: false)
        }
        if let _ = objPendingBooking{
            paymentViewController?.objExperience = objPendingBooking!
            paymentViewController?.bookingTimeStr = "\(objPendingBooking!.time)"
            if let _ = objPendingBooking?.slots {
                paymentViewController?.numberOfGuest = Int("\(objPendingBooking!.slots)")!
            }
            paymentViewController?.bookingDate = changeDateFormat(dateStr: "\(objPendingBooking!.date)")
            paymentViewController?.isGroupBooking = objPendingBooking!.isGroupBooking
            paymentViewController?.hidesBottomBarWhenPushed = true
            nav.pushViewController(paymentViewController!, animated: false)
        }
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window{
            keyWindow.rootViewController = nav
            keyWindow.makeKeyAndVisible()
        }
    }
    func changeDateFormat(dateStr: String) -> String {
        let  dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let  dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        
        if let date = dateFormatter.date(from: dateStr){
            return dateFormatter1.string(from: date)
        }else{
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = dateFormatter.date(from: dateStr){
                return dateFormatter1.string(from: date)
            }
            return dateStr
        }
    }
    func redirectToDirectreply(userInfo:[String:AnyObject]){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
        let vc1 = sb.instantiateViewController(withIdentifier: "WhereToNextViewController") as? WhereToNextViewController
        let vc3 = sb.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
        let vc4 = sb.instantiateViewController(withIdentifier: "DirectReplyViewController") as? DirectReplyViewController
        
        if let directreply = vc4{
            if let _ =  userInfo["experience_title"],!(userInfo["experience_title"] is NSNull){
                directreply.exp_name = "\(userInfo["experience_title"]!)"
            }
            if let userID = userInfo["user_id"],!(userID is NSNull){
                directreply.user_id = "\(userID)"
            }
            if let guideID = userInfo["guide_id"],!(guideID is NSNull){
                directreply.exp_id = "\(guideID)"
            }
            if let experienceImage = userInfo["image"],!(experienceImage is NSNull){
                directreply.exp_Image = "\(experienceImage)"
            }
        }
        let nav =  UINavigationController.init(rootViewController: vc!)
        nav.isNavigationBarHidden = true
        nav.pushViewController(vc1!, animated: false)
        nav.pushViewController(vc3!, animated: false)
        nav.pushViewController(vc4!, animated: false)
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window{
            keyWindow.rootViewController = nav
            keyWindow.makeKeyAndVisible()
        }
    }
    func redirectToGuidePendingSchedule(isLoadUpcoming:Bool = false){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
        let vc1 = sb.instantiateViewController(withIdentifier: "WhereToNextViewController") as? WhereToNextViewController
        let vc3 = sb.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
        let vc4 = sb.instantiateViewController(withIdentifier: "FullScheduleViewController") as? FullScheduleViewController
        vc3?.selectedIndex = 2
        vc4?.isLoadUpcoming = isLoadUpcoming
        let nav =  UINavigationController.init(rootViewController: vc!)
        nav.isNavigationBarHidden = true
        nav.pushViewController(vc1!, animated: false)
        nav.pushViewController(vc3!, animated: false)
        nav.pushViewController(vc4!, animated: false)
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window{
            keyWindow.rootViewController = nav
            keyWindow.makeKeyAndVisible()
        }
    }
}
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
//        var alert = UIAlertController(title: "Test", message:"userNotificationCenter willPresent \(userInfo)", preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
//        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
//        return
        
        if let infoDic = userInfo["aps"] as? [String:AnyObject]  {
            if let infoCat = userInfo["category"] as?  String {
                if let alertMesssage = infoDic["alert"],let alertTitle = infoDic["notification_title"]{
                    var alert = UIAlertController(title: "\(alertTitle)", message:"\(alertMesssage)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.view.tintColor = UIColor.init(hexString: "36527D")
                    if infoCat.compareCaseInsensitive(str:"requested_by_traveler"){
                        alert.addAction(UIAlertAction.init(title: "Confirm", style: .default, handler: { (_ ) in
                            self.redirectToGuidePendingSchedule()
                        }))
                        alert.addAction(UIAlertAction.init(title: "No,reply", style: .default, handler: { (_ ) in
                            self.redirectToDirectreply(userInfo:infoDic)
                        }))
                         alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }else if infoCat.compareCaseInsensitive(str:"requested_by_guide"){
                        alert.addAction(UIAlertAction.init(title: "Confirm", style: .default, handler: { (_ ) in
                            self.redirectToMYLive(isForScheduleHistory: false,objPendingBooking: nil)
                        }))
                        alert.addAction(UIAlertAction.init(title: "No,reply", style: .default, handler: { (_ ) in
                            self.redirectToDirectreply(userInfo:infoDic)
                        }))
                         alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }else if infoCat.compareCaseInsensitive(str:"accepted_by_guide"){
                        
                            alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))
                            alert.addAction(UIAlertAction.init(title: "Confirm", style: .default, handler: { (_ ) in
                                //self.getTravelerBookingRequest(bookingID: strBookingID)
                                var strBookingID:String = ""
                                if let bookingID = infoDic["Id"] {
                                    strBookingID = "\(bookingID)"
                                }
                                self.getTravelerBookingRequest(bookingID: strBookingID)
                            }))
                            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }else if infoCat.compareCaseInsensitive(str:"booking"){
                        alert.addAction(UIAlertAction.init(title: "Confirm", style: .default, handler: { (_ ) in
                            self.redirectToGuidePendingSchedule(isLoadUpcoming: true)
                        }))
                        alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))

                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }else if infoCat.compareCaseInsensitive(str: "booking_confirmed"){
                       
                        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (_ ) in
                            self.redirectToMYLive(isForScheduleHistory: false,objPendingBooking: nil)
                        }))
                         alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }else if infoCat.compareCaseInsensitive(str: "booking_cancelled_by_traveler"){
                        alert.addAction(UIAlertAction.init(title: "Confirm", style: .default, handler: { (_ ) in
                            self.redirectToMYLive(isForScheduleHistory: true,objPendingBooking: nil)
                        }))
                        alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))

                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }else if infoCat.compareCaseInsensitive(str: "booking_cancelled_by_guide"){
                        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }else if infoCat.compareCaseInsensitive(str: "guide_request"){
                        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }else if infoCat.compareCaseInsensitive(str: "server_notification"){
                        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }else if infoCat.compareCaseInsensitive(str: "server_notification_couponcode"){
                        alert = UIAlertController(title: "Voucher accept", message:"Hello, you have received a value voucher, do you want to accept?", preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.view.tintColor = UIColor.init(hexString: "36527D")
                        alert.addAction(UIAlertAction.init(title: "No", style: .default, handler: nil))
                        alert.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: { (_ ) in
                            if let strAddedCoupon = infoDic["coupon_code"]{
                                self.addCouponCodeAPIRequest(strCouponCode:"\(strAddedCoupon)")
                            }
                        }))
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }else{
                        alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                    self.window?.makeKeyAndVisible()
                }
            }
        }
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
//        let alert = UIAlertController(title: "Test", message:"userNotificationCenter didReceive \(userInfo)", preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
//        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
//        return
        if let infoDic = userInfo["aps"] as? [String:AnyObject]  {
            if let infoCat = userInfo["category"] as?  String {
                if let alertMesssage = infoDic["alert"],let alertTitle = infoDic["notification_title"]{
                    var alert = UIAlertController(title: "\(alertTitle)", message:"\(alertMesssage)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.view.tintColor = UIColor.init(hexString: "36527D")
                    if infoCat.compareCaseInsensitive(str:"requested_by_traveler"){
                        alert.addAction(UIAlertAction.init(title: "Confirm", style: .default, handler: { (_ ) in
                            self.redirectToGuidePendingSchedule()
                        }))
                        alert.addAction(UIAlertAction.init(title: "No,reply", style: .default, handler: { (_ ) in
                            self.redirectToDirectreply(userInfo: infoDic)
                        }))
                         alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }else if infoCat.compareCaseInsensitive(str:"requested_by_guide"){
                        alert.addAction(UIAlertAction.init(title: "Confirm", style: .default, handler: { (_ ) in
                            self.redirectToMYLive(isForScheduleHistory: false,objPendingBooking: nil)
                        }))
                        alert.addAction(UIAlertAction.init(title: "No,reply", style: .default, handler: { (_ ) in
                            self.redirectToDirectreply(userInfo: infoDic)
                        }))
                        alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }else if infoCat.compareCaseInsensitive(str:"accepted_by_guide"){
                       
                        alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))
                        alert.addAction(UIAlertAction.init(title: "Confirm", style: .default, handler: { (_ ) in
                            
                        }))
                        var strBookingID:String = ""
                        if let bookingID = infoDic["Id"] {
                            strBookingID = "\(bookingID)"
                        }
                        self.getTravelerBookingRequest(bookingID: strBookingID)
                        //self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }else if infoCat.compareCaseInsensitive(str:"booking"){
                        alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))
                        alert.addAction(UIAlertAction.init(title: "Confirm", style: .default, handler: { (_ ) in
                            self.redirectToGuidePendingSchedule(isLoadUpcoming: true)
                        }))
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }else if infoCat.compareCaseInsensitive(str:"booking"){
                    self.redirectToGuidePendingSchedule()
                }else if infoCat.compareCaseInsensitive(str:"booking_confirmed"){
                    self.redirectToMYLive(isForScheduleHistory: false,objPendingBooking: nil)
                }else if infoCat.compareCaseInsensitive(str: "booking_cancelled_by_traveler"){
                    self.redirectToMYLive(isForScheduleHistory: true,objPendingBooking: nil)
                }else if infoCat.compareCaseInsensitive(str: "server_notification_couponcode"){
                    alert = UIAlertController(title: "Voucher accept", message:"Hello, you have received a value voucher, do you want to accept?", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.view.tintColor = UIColor.init(hexString: "36527D")
                    alert.addAction(UIAlertAction.init(title: "No", style: .default, handler: nil))
                    alert.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: { (_ ) in
                        if let strAddedCoupon = infoDic["coupon_code"]{
                            self.addCouponCodeAPIRequest(strCouponCode:"\(strAddedCoupon)")
                        }
                    }))
                    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }else if infoCat.compareCaseInsensitive(str: "booking_cancelled_by_guide") ||  infoCat.compareCaseInsensitive(str: "guide_request") || infoCat.compareCaseInsensitive(str: "server_notification"){
                    if let alertMesssage = infoDic["alert"],let alertTitle = infoDic["notification_title"]{
                        let alert = UIAlertController(title: "\(alertTitle)", message:"\(alertMesssage)", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                        if User.isUserLoggedIn{
                            let sb = UIStoryboard(name: "Main", bundle: nil)
                            let vc = sb.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
                            let vc1 = sb.instantiateViewController(withIdentifier: "WhereToNextViewController") as? WhereToNextViewController
                            let vc3 = sb.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
                            let nav =  UINavigationController.init(rootViewController: vc!)
                            nav.isNavigationBarHidden = true
                            nav.pushViewController(vc1!, animated: false)
                            nav.pushViewController(vc3!, animated: false)
                            if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window{
                                keyWindow.rootViewController = nav
                                keyWindow.makeKeyAndVisible()
                                keyWindow.rootViewController?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }else{
                        alert.addAction(UIAlertAction.init(title: "Cancel", style: .default, handler: nil))
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        completionHandler()
    }
    func getTravelerBookingRequest(bookingID:String){
        
        let getTravelarBookingURL = "experience/native/traveller/\(bookingID)/pendingBooking"
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString: getTravelarBookingURL, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let strMessage = successData["Message"],let pendingBooking = successData["pendingBooking"] as? [String:Any]{
                DispatchQueue.main.async {
                    let pendingBookingExperience = PendingExperience.init(PendingExperienceDetail: pendingBooking)
                    self.redirectToMYLive(isForScheduleHistory: false,objPendingBooking:pendingBookingExperience)
                }
            }else{
                DispatchQueue.main.async {
                    self.redirectToMYLive(isForScheduleHistory: false,objPendingBooking: nil)
                    self.window?.rootViewController?.view.endEditing(true)
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
            DispatchQueue.main.async {
                self.redirectToMYLive(isForScheduleHistory: false,objPendingBooking: nil)
                self.window?.rootViewController?.view.endEditing(true)
            }
        }
    }
    func addCouponCodeAPIRequest(strCouponCode:String){
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(),currentUser.userID.count > 0{
            var addCouponCodeParameters:[String:Any] = [:]
            addCouponCodeParameters["UserId"] = "\(currentUser.userID)"
            addCouponCodeParameters["CouponCode"] = "\(strCouponCode)"
            
            let requestURL = "payment/couponcode"
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString: requestURL, parameter:addCouponCodeParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let strMessage = successData["Message"]{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:"\(strMessage)")
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
extension AppDelegate:ReviewControlDelegate{
    
    func submitExperienceReview(objExperience: Experience, reviewData: [String : Any]) {
        let strShareRated = "\(Vocabulary.getWordFromKey(key: "shareReview.hint"))"
        let alert = UIAlertController(title: "\(Vocabulary.getWordFromKey(key: "share.hint"))", message:strShareRated, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction.init(title: "\(Vocabulary.getWordFromKey(key: "no"))", style: .default, handler: nil))
        alert.addAction(UIAlertAction.init(title: "\(Vocabulary.getWordFromKey(key: "yes"))", style: .default, handler: { (_ ) in
            DispatchQueue.main.async {
                var strShare:String = "\(objExperience.title) "
                if let review = reviewData["Review"],let comment = reviewData["Comment"]{
                    strShare += "\(review)/5.0"
                    strShare += "\(comment)"
                }
                self.shareApplicationWithActivity(shareText:strShare.count > 0 ? strShare:"Live")
            }
        }))
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        self.window?.makeKeyAndVisible()
    }
    func cancelExperienceReview(objExperience: Experience) {
        self.directShareExperience(objExperience: objExperience)
    }
}
public extension Bundle {
    
    public var versionNumber: String {
        if let result = infoDictionary?["CFBundleShortVersionString"] as? String {
            return result
        } else {
            assert(false)
            return ""
        }
    }
    
    public var buildNumber: String {
        if let result = infoDictionary?["CFBundleVersion"] as? String {
            return result
        } else {
            assert(false)
            return ""
        }
    }
    
    public var fullVersion: String {
        return "\(versionNumber)(\(buildNumber))"
    }
}
