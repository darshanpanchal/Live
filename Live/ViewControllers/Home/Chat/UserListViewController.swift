 //
//  UserListViewController.swift
//  Live
//
//  Created by ips on 26/04/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import SendBirdSDK

 class UserListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,SBDConnectionDelegate, SBDChannelDelegate,UIGestureRecognizerDelegate {
    
     @IBOutlet weak var userTbl: UITableView?
     @IBOutlet weak var topView: UIView?
     @IBOutlet weak var selectedUserListHeight: NSLayoutConstraint!
     @IBOutlet weak var tabView: UIView?
     @IBOutlet weak var otherBtn: UIButton?
     @IBOutlet weak var upcomingBtn: UIButton?
     @IBOutlet var ExperienceSegController:UISegmentedControl!
     @IBOutlet weak var lineView: UIView?
    @IBOutlet var buttonBack: UIButton!
    @IBOutlet weak var nodataLbl: UILabel?
    @IBOutlet weak var navTitle: UILabel?
    private var groupChannelListQuery: SBDGroupChannelListQuery?

   // @IBOutlet weak var nodataLbl: UILabel?
        var query: SBDUserListQuery?
        var userSelectionMode: Int = 0
        var namechannel: SBDGroupChannel!
        var experiname = [[String:AnyObject]]()
        var passdata =  [String:AnyObject]()
        var dictData =  [String:AnyObject]()
        var objPendingExperienceDetail :  PendingExperience?
        var usertype: String?
        var users: [SBDUser] = []
        var arrayOffutureexperienceDetail:[PendingExperience] = []
        var selectedUsers = [String:AnyObject]()
        var exp_id: Int?
        var uname: String?
        var exp_Img: String?
        var selectedMutableSet:NSMutableSet = NSMutableSet()
        var tabArrey =  [[String:AnyObject]]()
        var image: String?
        var titles: String?
        var passchannels: [SBDGroupChannel] = []
        var tag : Int?
        var isChannelAvailable:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "NoInternet"))
            return
        }
        self.buttonBack.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.buttonBack.imageView?.tintColor = UIColor.black
//        self.navigationController?.tabBarController?.tabBar.isHidden = true
//        self.navigationController?.tabBarController?.tabBar.tintColor =
        self.getUsertype()
        self.ExperienceSegController.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 13)!], for: .selected)
        self.ExperienceSegController.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 13)!], for: .normal)
        self.ExperienceSegController.setTitle(Vocabulary.getWordFromKey(key: "OTHERSUPCOMING"), forSegmentAt: 0)
        self.ExperienceSegController.setTitle(Vocabulary.getWordFromKey(key: "UPCOMING"), forSegmentAt: 1)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navTitle?.text = Vocabulary.getWordFromKey(key: "SelectExperience")
       if let _ = User.getUserFromUserDefault(){
        userTbl?.delegate = self
        userTbl?.dataSource = self
        self.userTbl?.separatorStyle = .none
        self.tabView?.isHidden = true
     }else{
        self.nodataLbl?.isHidden = false
        self.userTbl?.isHidden = true
        }
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.swipeToPop()
    }
    func swipeToPop() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func addDynamicFont(){
        self.navTitle?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.navTitle?.adjustsFontForContentSizeCategory = true
        self.navTitle?.adjustsFontSizeToFitWidth = true
        
        self.otherBtn?.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
        self.otherBtn?.titleLabel?.adjustsFontForContentSizeCategory = true
        self.otherBtn?.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.upcomingBtn?.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
        self.upcomingBtn?.titleLabel?.adjustsFontForContentSizeCategory = true
        self.upcomingBtn?.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userTbl?.isUserInteractionEnabled = true
    }
     // MARK: - API Request
    
    func getUsertype(){
        if User.isUserLoggedIn,let user = User.getUserFromUserDefault(){
            let mailid = user.userEmail
            let logInParameters = ["email":mailid] as [String : AnyObject]
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kGetUserType, parameter:logInParameters,isHudeShow: true,success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let userInfo = success["data"] as? [String:Any]{
                   
                    DispatchQueue.main.async {
                        self.usertype = userInfo["UserType"] as? String
                        if let strProvision = userInfo["Provision"],!(strProvision is NSNull) {
                            user.userProvision = "\(strProvision)"
                            user.setUserDataToUserDefault()
                            if self.usertype == "User"{
                                self.selectedUserListHeight.constant = 60
                                self.ExperienceSegController?.isHidden = true
                                self.getPendingChat()
                            }else{
                                self.selectedUserListHeight.constant = 90
                                self.ExperienceSegController?.isHidden = false
                                self.getPendingOtherChat()
                            }
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
    }
    func getPendingOtherChat(){
        if let user = User.getUserFromUserDefault(){
            let user_id = user.userID
            let urlInstantExperience = "\(kGetPendingOtherChat)\(user_id)/future/otherchat"
       
        arrayOffutureexperienceDetail.removeAll()
        APIRequestClient.shared.getExperience(requestType: .GET, queryString: urlInstantExperience, isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let array = successDate["OtherFutureExperiences"] as? [[String:Any]]{
                    print(array)
                for object in array{
                    if let jsonfutureexperience = object as? [String : Any]{
                        let experienceDetail = PendingExperience.init(PendingExperienceDetail: jsonfutureexperience)
                        self.arrayOffutureexperienceDetail.append(experienceDetail)
                    }
                }
                DispatchQueue.main.async {
                    print(self.arrayOffutureexperienceDetail)
                    if self.arrayOffutureexperienceDetail.count == 0{
                        self.nodataLbl?.text = Vocabulary.getWordFromKey(key:"noData")
                        self.nodataLbl?.isHidden = false
                        self.userTbl?.isHidden = true
                    }
                    self.userTbl?.reloadData()
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
    }
    func getPendingChat(){
        if let user = User.getUserFromUserDefault(){
            let user_id = user.userID
            let urlInstantExperience = "\(kGetExperience)\(user_id)/future/chat"
        arrayOffutureexperienceDetail.removeAll()
        APIRequestClient.shared.getExperience(requestType: .GET, queryString: urlInstantExperience, isHudeShow: true, success: { (responseSuccess) in
             if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let array = successDate["FutureExperiences"] as? [[String:Any]]{
             
                for object in array{
                    
                        if let jsonfutureexperience = object as? [String : Any]{
                            let experienceDetail = PendingExperience.init(PendingExperienceDetail: jsonfutureexperience)
                            self.arrayOffutureexperienceDetail.append(experienceDetail)
                        }
                }
                DispatchQueue.main.async {
                    print(self.arrayOffutureexperienceDetail)
                    if self.arrayOffutureexperienceDetail.count == 0{
                        self.nodataLbl?.text = Vocabulary.getWordFromKey(key:"noData")
                        self.nodataLbl?.isHidden = false
                        self.userTbl?.isHidden = true
                    }
                   self.userTbl?.reloadData()
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
}

//    func setUp(){
//        if usertype == "User"{
//           self.selectedUserListHeight.constant = 60
//            self.ExperienceSegController?.isHidden = true
//            self.getPendingChat()
//        }else{
//            self.selectedUserListHeight.constant = 90
//            self.ExperienceSegController?.isHidden = false
//        }
//    }
    @IBAction func buttonSegmentControllerSelector(sender:UISegmentedControl){
        switch sender.selectedSegmentIndex {
        case 0: //other upcoming
             self.getPendingOtherChat()
            break
        case 1: //upcoming
           self.getPendingChat()
            break
        default:
            break
        }
    }

    @IBAction func onClickBakBtn(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
     // MARK: - Delegates of TableView
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
//
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 0
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOffutureexperienceDetail.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell") as! UserListCell
        let objectExperineceDetail = self.arrayOffutureexperienceDetail[indexPath.row]
        cell.contentView.isExclusiveTouch = true
        if self.arrayOffutureexperienceDetail.count == 0{
            self.userTbl?.isHidden = true
            self.nodataLbl?.text = Vocabulary.getWordFromKey(key:"noData")
        }else{
            self.userTbl?.isHidden = false
            self.nodataLbl?.isHidden = true
            cell.experImg?.layer.masksToBounds = true
            cell.experImg?.layer.cornerRadius = 30
            cell.usernameLbl.text =  objectExperineceDetail.title
            cell.lblUserName.text = objectExperineceDetail.userName
            cell.experImg?.imageFromServerURL(urlString:objectExperineceDetail.smallmainimage)
        }
        
        return cell
    }
    func contains(a:[(String, String)], v:(String,String)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a { if v1 == c1 && v2 == c2 { return true } }
        return false
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userTbl?.isUserInteractionEnabled = false
        guard self.arrayOffutureexperienceDetail.count > indexPath.row else {
            return
        }
        self.objPendingExperienceDetail = self.arrayOffutureexperienceDetail[indexPath.row]
        
        if let _ = self.objPendingExperienceDetail{
             self.isChannelAlreadyCreated(objExperience: self.objPendingExperienceDetail!)
//            var tempArray:[(String,String)] = []
//
//            for channel in passchannels {
//
//                    for member in channel.members! as NSArray as! [SBDUser] {
//                        print("-------Number of members \(channel.memberCount)------")
//                        print("------- \(channel.channelUrl)------")
//                        print("===== \(member.userId) =====")
//                        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
//                            print("\(currentUser.userID)")
//                        }
//                        if member.userId == SBDMain.getCurrentUser()?.userId {
//
//                        }else{
//                            tempArray.append((channel.name,member.userId))
//                        }
//                    }
//
//
//            }
//            self.objPendingExperienceDetail = self.arrayOffutureexperienceDetail[indexPath.row]
//            self.isChannelAlreadyCreated(objExperience: self.objPendingExperienceDetail!)
            
//            if  self.isChannelAlreadyCreated(objExperience: self.objPendingExperienceDetail!){//self.contains(a: tempArray, v: ("\(self.objPendingExperienceDetail!.title)","\(self.objPendingExperienceDetail!.guideID)")){
//                //if false{//tempArray.contains((self.objPendingExperienceDetail?.title)!){
//                self.showAlreadyCreatedChannelAlert()
//                return
//            }else{
//                UserDefaults.standard.set(2, forKey: "navigationScreen")
//                UserDefaults.standard.synchronize()
//                self.createChannel()
//            }
        }
    }
    func showAlreadyCreatedChannelAlert(){
        let alert = UIAlertController(title: Vocabulary.getWordFromKey(key:"Chat"), message: Vocabulary.getWordFromKey(key:"Chat.msg"), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("OK")
                
            case .destructive:
                print("destructive")
                
            }}))
        
        self.present(alert, animated: true, completion: nil)
        self.userTbl?.reloadData()
        userTbl?.isUserInteractionEnabled = true
        
      
    }
    func isChannelAlreadyCreated(objExperience:PendingExperience){
        
        self.groupChannelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        
        self.groupChannelListQuery?.channelNameContainsFilter = objExperience.title//channelNameContainsFilter(objExperience.title))
        
        self.groupChannelListQuery?.loadNextPage(completionHandler: { (channels, error) in
            
            self.isChannelAvailable = false
            if channels?.count == 0 || channels == nil {
                self.createChannel()
            }else{
                for objChannel:SBDGroupChannel in channels!{
                    
                    if let strChannelData = objChannel.data,let data = strChannelData.data(using: .utf8){
                        do{
                            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                            if let success = json as? [String:Any],let guideID = success["guide"],let userID = success["user"]{
                                
                                if objExperience.guideID == "\(guideID)",objExperience.userID == "\(userID)",objChannel.memberCount > 1{
                                    self.isChannelAvailable = true
                                    self.showAlreadyCreatedChannelAlert()
                                    break
                                }
                            }
                        }
                        catch{
                            //ShowToast.show(toatMessage: kCommonError)
                            //fail(["error":kCommonError])
                        }
                        
                    }
                }
                
                if !self.isChannelAvailable{
                    self.createChannel()
                }
                
            }
        })
    }
    func createChannel() {
        UserDefaults.standard.set(2, forKey: "navigationScreen")
        UserDefaults.standard.synchronize()
        
        var user_id : String?
        var exp_id : String?
        var exp_name: String?
        var exp_img: String?
        if let id = objPendingExperienceDetail?.guideID{
                exp_id = id
        }
        if let name = objPendingExperienceDetail?.title{
                exp_name = name
        }
        if let u_id = objPendingExperienceDetail?.userID {
                user_id = String(u_id)
        }
        if let image = objPendingExperienceDetail?.mainimage{
            exp_img = image
        }
            let arreyofid: [String] = [user_id!, exp_id!]
        let dict = ["user" : user_id, "guide" : exp_id]
            let dataobject =  try! JSONSerialization.data(withJSONObject: dict, options: [])
            let jsonString = String(data: dataobject, encoding: .utf8)
        print(exp_name!)
        
        SBDGroupChannel.createChannel(withName: exp_name, isDistinct: true, userIds: arreyofid, coverUrl: exp_img, data: jsonString, customType: nil) { (channel, error) in
                if error != nil {
                    let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: { (action) in
                    })
                    vc.addAction(closeAction)
                    DispatchQueue.main.async {
                        self.present(vc, animated: true, completion: nil)
                    }
                    return
                }else{
                     print(channel!.isDistinct)
                     self.openGroupChannel(channel: channel!, vc: self)
                }
        }
    }
    func openGroupChannel(channel: SBDGroupChannel, vc: UIViewController) {
        DispatchQueue.main.async {
            let vc = GroupChannelChattingViewController(nibName: "GroupChannelChattingViewController", bundle: Bundle.main)
            vc.groupChannel = channel
            vc.selected = self.objPendingExperienceDetail
            self.navigationController?.pushViewController(vc,animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
}
