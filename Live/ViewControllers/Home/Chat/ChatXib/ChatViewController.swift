//
//  GroupChannelListViewController.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/10/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import SendBirdSDK

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate, CreateGroupChannelUserListViewControllerDelegate, SBDChannelDelegate, SBDConnectionDelegate, ConnectionManagerDelegate,UIGestureRecognizerDelegate {
    
    private var channel: SBDGroupChannel!
    // @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navTitle: UILabel!
    @IBOutlet weak var defaultImg: UIImageView?
    @IBOutlet weak var noLoginView: UIView?
    @IBOutlet weak var noChatHintLbl: UILabel!
    private var refreshControl: UIRefreshControl?
    @IBOutlet var lblplsLogin: UILabel?
    @IBOutlet var buttonAddChat:UIButton!
    
    @IBOutlet var objUISegementController:UISegmentedControl!
    @IBOutlet var lblChatCount:UILabel!
    @IBOutlet var badgeView:UIView!
    
    //@IBOutlet var objChatView:UIView!
   // @IBOutlet var objHistoryView:UIView!
   // @IBOutlet var tableViewHistory:UITableView!
   // @IBOutlet var objNotificationView:UIView!
  //  @IBOutlet var tableViewNotification:UITableView!
    let currentPageSize:Int = 20
    var notificationPageIndex:Int = 0
    var arrayOfHistory:[BookingHistory] = []
    var arrayOfNotification:[NotificationModel] = []
    var selectedIndex:Int = 0
    var currentSelectedIndex:Int{
        get{
            return selectedIndex
        }
        set{
            self.selectedIndex = newValue
            DispatchQueue.main.async {
                self.configureSelectedIndex()
            }
        }
    }
    var isNotificationLoadMore:Bool = false
    
    private var channels: [SBDGroupChannel] = []
    var timer = Timer()
    var currentUnreadCount:Int = 0
    private var editableChannel: Bool = false
    private var groupChannelListQuery: SBDGroupChannelListQuery?
    private var typingAnimationChannelList: [String] = []
    private var cachedChannels: Bool = false
    private var firstLoading: Bool = false
    var notificationCellHeight:CGFloat{
        get{
            return 150.0
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // let users = User.getUserFromUserDefault()
        DispatchQueue.main.async {
            ProgressHud.show()
        }
        self.CreateConnect()
        ProgressHud.hide()
        if User.isUserLoggedIn {
            
            //            ConnectionManager.add(connectionObserver: self as ConnectionManagerDelegate)
            //            if SBDMain.getConnectState() == .closed {
            //                ConnectionManager.login { (user, error) in
            //                    guard error == nil else {
            //                        return;
            //                    }
            //                }
            //            }else {
            //                self.firstLoading = false;
            //                self.showList()
            //            }
            self.defaultImg?.isHidden = true
            noChatHintLbl.isHidden = true
            //tableView.tableHeaderView = UIView.init()
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action: #selector(refreshChannelList), for: UIControlEvents.valueChanged)
            self.tableView.addSubview(self.refreshControl!)
            self.setDefaultNavigationItems()
            self.tableView.separatorStyle = .none
            
            
        }else{
            self.defaultImg?.isHidden = true
            noChatHintLbl.isHidden = true
            self.tableView.isHidden = true
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isEditing = false
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = self.notificationCellHeight
        let btnSettings = UIButton()
        btnSettings.setImage(UIImage(named: "Plus"), for: .normal)
        btnSettings.frame = CGRect(x: self.view.frame.width - 40, y: 11.0, width: 22, height: 22)
        btnSettings.addTarget(self, action: #selector(self.onclickplusBtn(sender:)), for: .touchUpInside)
        if User.isUserLoggedIn{
         //   self.navigationController?.navigationBar.addSubview(btnSettings)
        }
        guard User.isUserLoggedIn else {
            return
        }
        self.tableView.register(GroupChannelListTableViewCell.nib(), forCellReuseIdentifier:GroupChannelListTableViewCell.cellReuseIdentifier())
        self.addDelegates()
        if User.isUserLoggedIn{
            badgeView.clipsToBounds = true
            badgeView.layer.cornerRadius = 10.0
            badgeView.layer.borderWidth = 1.0
            badgeView.layer.borderColor = UIColor.white.cgColor
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
    }
    @objc func timerAction() {
        DispatchQueue.main.async {
            self.getUnreadcount()
        }
    }
    // MARK: Custom Methods
    func configureHistoryandNotificationTableView(){
 
        //Register History Cell
        let objScheduleNib = UINib.init(nibName: "HistoryTableViewCell", bundle: nil)
        self.tableView.register(objScheduleNib, forCellReuseIdentifier: "HistoryTableViewCell")
        
        let objNotification = UINib.init(nibName: "NotificationTableViewCell", bundle: nil)
        self.tableView.register(objNotification, forCellReuseIdentifier: "NotificationTableViewCell")
        
        self.tableView.separatorStyle = .none
        //self.tableView.tableHeaderView = UIView()
        self.tableView.tableFooterView = UIView()
        //Register Notification Cell
        
    }
    func configureSegmentController(){
        if UIScreen.main.bounds.height > 568.0{
            self.objUISegementController.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 14)!], for: .selected)
            self.objUISegementController.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 14)!], for: .normal)
        }else{
            self.objUISegementController.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 12)!], for: .selected)
            self.objUISegementController.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 12)!], for: .normal)
        }
        self.objUISegementController.setTitle(Vocabulary.getWordFromKey(key: "Chat"), forSegmentAt: 0)
        self.objUISegementController.setTitle(Vocabulary.getWordFromKey(key: "History"), forSegmentAt: 1)
        self.objUISegementController.setTitle(Vocabulary.getWordFromKey(key: "notifications.hint"), forSegmentAt: 2)
        self.configureSelectedIndex()
    }
    func configureSelectedIndex(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        if self.currentSelectedIndex == 0{
            if self.channels.count == 0 {
                self.defaultImg?.isHidden = false
                self.noChatHintLbl.isHidden = false
            }else {
                self.defaultImg?.isHidden = true
                self.noChatHintLbl.isHidden = true
            }
            self.buttonAddChat.isHidden = false
        }else{
            self.defaultImg?.isHidden = true
            self.noChatHintLbl.isHidden = true
            self.buttonAddChat.isHidden = true
        }
    }
    private func showList() {
        ProgressHud.show()
//        let dumpLoadQueue: DispatchQueue = DispatchQueue(label: "com.sendbird.dumploadqueue", attributes: .concurrent)
//        dumpLoadQueue.async {
//          self.channels = Utils.loadGroupChannels()
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
            
            if self.channels.count > 0 {
                DispatchQueue.main.async {
                    //self.tableView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(20), execute: {
                     self.refreshChannelList()
                        ProgressHud.hide()
                    })
                }
            }else {
                self.cachedChannels = false
               self.refreshChannelList()
                ProgressHud.hide()
            }
            self.firstLoading = true;
        //}
        
    }
    
    deinit {
        ConnectionManager.remove(connectionObserver: self as ConnectionManagerDelegate)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        Utils.dumpChannels(channels: self.channels)
        self.tabBarController?.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        DispatchQueue.main.async {
//            self.channels.removeAll()
//            self.tableView.reloadData()
//        }
        navigationController?.setNavigationBarHidden(false, animated: false)
        if #available(iOS 11.0, *) {
            DispatchQueue.main.async {
                self.navigationController?.navigationBar.prefersLargeTitles = true
                
                self.navigationController?.navigationBar.topItem?.title = Vocabulary.getWordFromKey(key: "messages.hint")
                self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
                let attributes = [
                    NSAttributedStringKey.foregroundColor : UIColor.black, NSAttributedStringKey.font : UIFont(name: "Avenir-Black", size: 34.0)
                ]
                self.navigationController?.navigationBar.largeTitleTextAttributes = attributes
            }
        } else {
            // Fallback on earlier versions
        }
        self.navigationController?.navigationBar.isHidden = false
        guard User.isUserLoggedIn else {
            self.objUISegementController.isHidden = true
            self.noLoginView?.isHidden = false
            return
        }
        self.lblplsLogin?.text = "\(Vocabulary.getWordFromKey(key: "PleaseLogIn.Chathint"))"
        self.noLoginView?.isHidden = true
        self.objUISegementController.isHidden = false
//        if self.firstLoading == true {
//           self.CreateConnect()
            //self.showList()
//        }
        
        self.changeTextAsLanguage()
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"NoInternet"))
            self.defaultImg?.isHidden = false
            noChatHintLbl.isHidden = false
            return
        }
        
        
//        self.firstLoading = false
        DispatchQueue.main.async {
            self.notificationPageIndex = 0
            self.addDynamicFont()
            self.configureSegmentController()
            self.configureHistoryandNotificationTableView()
            self.getHistoryAPIRequest()
            self.getNotificationListingAPIRequest()
        }
    }
    @IBAction func buttonLogInSelector(sender:UIButton){
        self.tabBarController?.navigationController?.popToRootViewController(animated: true)
    }
    func addDynamicFont(){
        self.navTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.navTitle.adjustsFontForContentSizeCategory = true
        self.navTitle.adjustsFontSizeToFitWidth = true
    }
    func changeTextAsLanguage() {
        self.navTitle.text = Vocabulary.getWordFromKey(key: "messages.hint")
        self.noChatHintLbl.text = Vocabulary.getWordFromKey(key: "NoChatHintText")
    }
    
    func addDelegates() {
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)
    }
    
    private func setDefaultNavigationItems() {
        
    }
    
    private func setEditableNavigationItems() {
        
    }
    
    @objc private func refreshChannelList() {
        DispatchQueue.main.async {
            self.getUnreadcount()
        }
        
        self.groupChannelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        self.groupChannelListQuery?.limit = 20
        self.groupChannelListQuery?.order = SBDGroupChannelListOrder.latestLastMessage
        
        self.groupChannelListQuery?.loadNextPage(completionHandler: { (channels, error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }
            self.channels.removeAll()
            self.cachedChannels = false
            
            for channel in channels! {
                self.channels.append(channel)
            }
            DispatchQueue.main.async {
                if self.channels.count == 0,self.currentSelectedIndex == 0{
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
                    self.defaultImg?.isHidden = false
                    self.noChatHintLbl.isHidden = false
                }else {
                    self.defaultImg?.isHidden = true
                    self.noChatHintLbl.isHidden = true
                }
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        })
    }
    func changeDateFormat(dateStr: String) -> String {
        var dateFormatter = DateFormatter()
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
    private func loadChannels() {
        if self.cachedChannels == true {
            return
        }
        
        if self.groupChannelListQuery != nil {
            if self.groupChannelListQuery?.hasNext == false {
                return
            }
            
            self.groupChannelListQuery?.loadNextPage(completionHandler: { (channels, error) in
                
                if error != nil {
                    if error?.code != 800170 {
                        DispatchQueue.main.async {
                            self.refreshControl?.endRefreshing()
                        }
                        
                        let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                        vc.addAction(closeAction)
                        DispatchQueue.main.async {
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                    return
                }
                for channel in channels! {
                    self.channels.append(channel)
                    
                }
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            })
        }
    }
    // MARK: Selector Methods
    @objc private func back() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc private func createGroupChannel() {
        let vc = CreateGroupChannelUserListViewController(nibName: "CreateGroupChannelUserListViewController", bundle: Bundle.main)
        vc.delegate = self
        vc.userSelectionMode = 0
        self.present(vc, animated: false, completion: nil)
    }
    @IBAction func buttonSegmentControllerSelector(sender:UISegmentedControl){
        self.currentSelectedIndex = sender.selectedSegmentIndex
        
        switch sender.selectedSegmentIndex {
        case 0: //Chats
            break
        case 1: //History
            break
        case 2: //Notifications
            break
        default:
            break
        }
    }
    @IBAction func onclickplusBtn(sender:UIButton){
        let stroryboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = stroryboard.instantiateViewController(withIdentifier: "UserListViewController") as? UserListViewController
        {
            vc.passchannels = self.channels
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    // MARK: APIRequestMethods
    func getHistoryAPIRequest(){
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            let requestHistory = "experience/native/bookingpaymenthistory/\(currentUser.userID)"
            //GetHistory
            APIRequestClient.shared.sendRequest(requestType: .GET, queryString: requestHistory, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let aryOfHistory = successData["history"] as? [[String:Any]]{
                    self.arrayOfHistory = []
                    for objHistory in aryOfHistory{
                        self.arrayOfHistory.append(BookingHistory.init(historyDetail: objHistory))
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }else{
                    DispatchQueue.main.async {
                        //ShowToast.show(toatMessage:kCommonError)
                    }
                }
                
            }, fail: { (responseFail) in
                if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: "\(errorMessage)")
                    }
                }else{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: kCommonError)
                    }
                }
            })
        }
    }
    func getNotificationListingAPIRequest(){
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
              let requestNotificationAPI = "notifications/native/users/\(currentUser.userID)/all?pageIndex=\(self.notificationPageIndex)&pageSize=\(self.currentPageSize)"
            //GetNotificationHistory
            APIRequestClient.shared.sendRequest(requestType: .GET, queryString: requestNotificationAPI, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let aryOfNotification = successData["Notifications"] as? [[String:Any]]{
                    if self.notificationPageIndex == 0{
                        self.arrayOfNotification = []
                    }
                    self.isNotificationLoadMore = (aryOfNotification.count == self.currentPageSize)
                    for objNotification in aryOfNotification{
                        self.arrayOfNotification.append(NotificationModel.init(notificationDetail:objNotification))
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }else{
                    DispatchQueue.main.async {
                        //ShowToast.show(toatMessage:kCommonError)
                    }
                }
                
            }, fail: { (responseFail) in
                if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: "\(errorMessage)")
                    }
                }else{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: kCommonError)
                    }
                }
            })
        }
    }
    func deleteNotificationRequest(objNotification:NotificationModel){
        let requestNotificationDeleteAPI = "notifications/\(objNotification.id)/native/delete"
        //GetNotificationHistory
        APIRequestClient.shared.sendRequest(requestType: .DELETE, queryString: requestNotificationDeleteAPI, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let strMSG = successData["Message"]{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(strMSG)")
                    self.notificationPageIndex = 0
                    self.isNotificationLoadMore = true
                    self.getNotificationListingAPIRequest()
                }
            }else{
                DispatchQueue.main.async {
                    //ShowToast.show(toatMessage:kCommonError)
                }
            }
            
        }, fail: { (responseFail) in
            if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: kCommonError)
                }
            }
        })
    }
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.selectedIndex == 1{
            return (indexPath.row == 0) ? 110.0 : 95.0
        }else if self.selectedIndex == 2{
            return UITableViewAutomaticDimension
        }else if self.selectedIndex == 0{
            return 90.0
        }else{
            return 0
        }
    }
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 90
//    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0
//    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.selectedIndex == 1{
            return false
        }else if self.selectedIndex == 2{
            return true
        }else{
            return true
        }
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: Vocabulary.getWordFromKey(key:"delete")) { (rowAction, indexPath) in
            let refreshAlert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
            refreshAlert.view.layer.cornerRadius = 14.0
            let titleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17.0)!]
            let messageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
            var titleAttrString = NSMutableAttributedString()
            var messageAttrString = NSMutableAttributedString()
            if self.selectedIndex == 0{
                titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key:"Delete.Chat"), attributes: titleFont)
                messageAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key:"deleteConfirmation"), attributes: messageFont)
            }else{
                titleAttrString = NSMutableAttributedString(string:"Delete", attributes: titleFont)
                messageAttrString = NSMutableAttributedString(string:"Are you sure you want to delete this notification?", attributes: messageFont)
            }
            refreshAlert.setValue(titleAttrString, forKey: "attributedTitle")
            refreshAlert.setValue(messageAttrString, forKey: "attributedMessage")
            refreshAlert.view.tintColor = UIColor(hexString: "#36527D")
            refreshAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (action: UIAlertAction!) in
                if self.selectedIndex == 0{
                    let selectedChannel: SBDGroupChannel = self.channels[indexPath.row] as SBDGroupChannel
                    selectedChannel.leave(completionHandler: { (error) in
                        if error == nil {
                            
                            if let index = self.channels.index(of: selectedChannel) {
                                self.channels.remove(at: index)
                            }
                            DispatchQueue.main.async {
                                if self.channels.count == 0,self.channels.count == 0{
                                    self.defaultImg?.isHidden = false
                                    self.noChatHintLbl.isHidden = false
                                }else{
                                    self.defaultImg?.isHidden = true
                                    self.noChatHintLbl.isHidden = true
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    })
                }else{
                    if self.arrayOfNotification.count > indexPath.row{
                        let objNotification = self.arrayOfNotification[indexPath.row]
                        self.deleteNotificationRequest(objNotification: objNotification)
                    }
                }
            }))
            refreshAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"no"), style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            self.present(refreshAlert, animated: true, completion: nil)
        }
        deleteAction.backgroundColor = UIColor(red: CGFloat(210.0/255.0), green: CGFloat(49.0/255.0), blue: CGFloat(80.0/255.0), alpha: CGFloat(1.0))//UIColor(red: 210, green: 49, blue: 80, alpha: 1)
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedIndex == 1{ //History
            if self.arrayOfHistory.count > indexPath.row{
                let objHistory = self.arrayOfHistory[indexPath.row]
                self.checkForChannelAlreadyCreateNavigateToChat(objHistory: objHistory)
            }
        }else{
            tableView.deselectRow(at: indexPath, animated: false)
            UserDefaults.standard.set(1, forKey: "navigationScreen")
            UserDefaults.standard.synchronize()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(20), execute: {
                let vc = GroupChannelChattingViewController(nibName: "GroupChannelChattingViewController", bundle: Bundle.main)
                vc.groupChannel = self.channels[indexPath.row]
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc,animated: true)
//                self.present(vc, animated: false, completion: nil)
            })
        }
    }
    func checkForChannelAlreadyCreateNavigateToChat(objHistory:BookingHistory){
        var isChannelAvailable:Bool = false
        self.groupChannelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        let guideId = "\(objHistory.guideId)"
        let userId = "\(objHistory.userId)"
        //(self.groupChannelListQuery?.channelNameContainsFilter(self.exp_name))
        
        self.groupChannelListQuery?.loadNextPage(completionHandler: { (channels, error) in
            
           isChannelAvailable = false
            if channels?.count == 0 || channels == nil {
                self.createChannelNavigateToChat(objHistory: objHistory)
            }else{
                for objChannel:SBDGroupChannel in channels!{
                    
                    if let strChannelData = objChannel.data,let data = strChannelData.data(using: .utf8){
                        do{
                            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                            if let success = json as? [String:Any],let guideID = success["guide"],let userID = success["user"]{
                                
                                if guideId == "\(guideID)",userId == "\(userID)",objChannel.memberCount > 1{
                                   isChannelAvailable = true
                                    self.navigateToChatWithChannel(objChannel: objChannel)
                                    //self.sendMessageToCreatedChannel(objChannel: objChannel)
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
                
                if !isChannelAvailable{
                    self.createChannelNavigateToChat(objHistory: objHistory)
                }
                
            }
        })
    }
    func navigateToChatWithChannel(objChannel:SBDGroupChannel){
        UserDefaults.standard.set(1, forKey: "navigationScreen")
        UserDefaults.standard.synchronize()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(20), execute: {
            let vc = GroupChannelChattingViewController(nibName: "GroupChannelChattingViewController", bundle: Bundle.main)
            vc.groupChannel = objChannel
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc,animated: true)
            //                self.present(vc, animated: false, completion: nil)
        })
    }
    func createChannelNavigateToChat(objHistory:BookingHistory){
        let arreyofid: [String] = [objHistory.userId,  objHistory.guideId]
        let dict = ["user" : objHistory.userId, "guide" : objHistory.guideId]
        let dataobject =  try! JSONSerialization.data(withJSONObject: dict, options: [])
        let exp_name = objHistory.experienceName
        let exp_Image = objHistory.experienceImage
        
        let jsonString = String(data: dataobject, encoding: .utf8)
        print(exp_Image)
        print(arreyofid)
        print(exp_name)
        SBDGroupChannel.createChannel(withName: exp_name, isDistinct: false, userIds: arreyofid, coverUrl:exp_Image , data: jsonString, customType: nil) { (channel, error) in
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
                print("******************SUCCESSFULL CREATE CHANNEL *****************")
                self.navigateToChatWithChannel(objChannel: channel!)
                //self.openGroupChannel(channel: channel!, vc: self)
            }
        }
    }
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if self.selectedIndex == 1{
            if self.arrayOfHistory.count > 0 {
                tableView.removeMessageLabel()
            }else{
                tableView.showMessageLabel(msg: Vocabulary.getWordFromKey(key: "History.noData"))
            }
            return self.arrayOfHistory.count
        }else if self.selectedIndex == 0{
            tableView.removeMessageLabel()
            if self.channels.count > 0{
                self.defaultImg?.isHidden = true
                self.noChatHintLbl.isHidden = true
            }else {
                if User.isUserLoggedIn{
                    self.defaultImg?.isHidden = false
                    self.noChatHintLbl.isHidden = false
                }else{
                    self.defaultImg?.isHidden = true
                    self.noChatHintLbl.isHidden = true
                }
            }
            return self.channels.count
        }else if self.selectedIndex == 2{
            if self.arrayOfNotification.count > 0 {
                tableView.removeMessageLabel()
            }else{
                tableView.showMessageLabel(msg:"No notification found")
            }
            return self.arrayOfNotification.count
        }else{
            tableView.removeMessageLabel()
            return 0
        }
    }
    /*
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let objView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        objView.backgroundColor = UIColor.red
        return objView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         if self.selectedIndex == 1{
            let historyCell :HistoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as! HistoryTableViewCell
            guard self.arrayOfHistory.count > indexPath.row else {
                return historyCell
            }
            let objHistory = self.arrayOfHistory[indexPath.row]
            historyCell.lblDate.text = "\(objHistory.createdDate.changeDateWithTimeFormat)"
            historyCell.lblHistoryDetail.text = "\(objHistory.message)"
            historyCell.timelineView.backgroundColor = UIColor.init(hexString: "\(objHistory.color)")
            if indexPath.row == 0{
                historyCell.topSpaceConstraint.constant = 20.0
                historyCell.topLineView.isHidden = true
                historyCell.bottomView.isHidden = false
            }else if indexPath.row+1 == self.arrayOfHistory.count{
                historyCell.topSpaceConstraint.constant = 5.0
                historyCell.topLineView.isHidden = false
                historyCell.bottomView.isHidden = true
            }else{
                historyCell.topSpaceConstraint.constant = 5.0
                historyCell.topLineView.isHidden = false
                historyCell.bottomView.isHidden = false
            }
            historyCell.backgroundColor = .clear
            return historyCell
        }else if self.selectedIndex == 2{
            let notificationCell :NotificationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
            guard self.arrayOfNotification.count > indexPath.row else {
                return notificationCell
            }
            let objNotification = self.arrayOfNotification[indexPath.row]
            let statusWithColor:(String,UIColor) = self.getStatusForNotificationWithColor(status: "\(objNotification.title)")
            notificationCell.lblStatus.text = "\(statusWithColor.0)"
            notificationCell.lblDate.text = "\(objNotification.messageSentDate.changeDateWithTimeFormat)"//"\(self.changeDateFormat(dateStr: objNotification.messageSentDate))"
            notificationCell.lblStatus.textColor = statusWithColor.1
            notificationCell.lblNotificationDescription.text = "\(objNotification.description)"
            if indexPath.row == (self.arrayOfNotification.count - 1) , self.isNotificationLoadMore{ //last index
                DispatchQueue.global(qos: .background).async {
                    self.notificationPageIndex += 1
                    self.getNotificationListingAPIRequest()
                }
            }
            return notificationCell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelListTableViewCell") as! GroupChannelListTableViewCell
            channel = self.channels[indexPath.row]
            print(channel.name)
            if self.channels[indexPath.row].isTyping() == true {
                if self.typingAnimationChannelList.index(of: self.channels[indexPath.row].channelUrl) == nil {
                    self.typingAnimationChannelList.append(self.channels[indexPath.row].channelUrl)
                }
            }else {
                print(self.channels[indexPath.row].channelUrl)
                if self.typingAnimationChannelList.index(of: self.channels[indexPath.row].channelUrl) != nil {
                    self.typingAnimationChannelList.remove(at: self.typingAnimationChannelList.index(of: self.channels[indexPath.row].channelUrl)!)
                }
            }
            cell.setModel(aChannel: self.channels[indexPath.row])
            if self.channels.count > 0 && indexPath.row + 1 == self.channels.count {
                self.loadChannels()
            }
            
            return cell
        }
    }
    func getStatusForNotificationWithColor(status:String)->(String,UIColor){
        if(status == "RequestedByTraveler"){
            return ("By Traveller",UIColor.init(hexString: "36527D"))
        }else if(status == "RequestedByGuide"){
            return ("By Guide",UIColor.init(hexString:"36527D"))
        }else if(status == "Booking"){
            return (status,UIColor.black)
        }else if (status == "Accepted") || (status == "Confirmed"){
            return (status,UIColor.init(hexString:"367D4A"))
        }else{
            return (status,UIColor.init(hexString:"FF3B30")) //Booking Canceled By Traveler Booking Canceled By Guide
        }
    }
    // MARK: GroupChannelChattingViewController\
    func didConnect(isReconnection: Bool) {
        let vc = UIApplication.shared.keyWindow?.rootViewController
        let bestVC = Utils.findBestViewController(vc: vc!)
        
        if bestVC == self {
            self.refreshChannelList()
        }
    }
    
    // MARK: CreateGroupChannelUserListViewControllerDelegate
    func openGroupChannel(channel: SBDGroupChannel, vc: UIViewController) {
        DispatchQueue.main.async {
            let vc = GroupChannelChattingViewController(nibName: "GroupChannelChattingViewController", bundle: Bundle.main)
            vc.groupChannel = channel
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    // MARK: GroupChannelChattingViewController.
    func CreateConnect(){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "NoInternet"))
            self.defaultImg?.isHidden = false
            noChatHintLbl.isHidden = false
            return
        }
        if let user = User.getUserFromUserDefault(){
            ConnectionManager.login(userId: (user.userID), completionHandler: { (user, error) in
                
                guard error == nil else {
                    let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                    vc.addAction(closeAction)
                    DispatchQueue.main.async {
                        self.present(vc, animated: true, completion: nil)
                    }
                    
                    return
                }
                
                DispatchQueue.main.async {
                    self.refreshChannelList()
                }
                
            })
        }
    }
    func getUnreadcount(){
        SBDGroupChannel.getTotalUnreadMessageCount { (count, error) in
            guard error == nil else {    // Error.
                
                return
            }
            print("==== \(count) ====")
            if Int(count) > 0{
                 self.badgeView.isHidden = false
//                if self.currentUnreadCount == Int(count){
//                    return
//                }
                self.currentUnreadCount = Int(count)
                self.lblChatCount.text = "\(Int(count))"
            }else{
                self.badgeView.isHidden = true
            }
        }
        
    }
    func didStartReconnection() {
        
    }
    func didDisconnect() {
        
    }
    //    func didSucceedReconnection() {
    //        let vc = UIApplication.shared.keyWindow?.rootViewController
    //        let bestVC = Utils.findBestViewController(vc: vc!)
    //
    //        if bestVC == self {
    //            let query = SBDGroupChannel.createMyGroupChannelListQuery()
    //            query?.limit = 20
    //            query?.order = SBDGroupChannelListOrder.latestLastMessage
    //            query?.loadNextPage(completionHandler: { (channels, error) in
    //                if error != nil {
    //                    return
    //                }
    //                self.channels.removeAll()
    //                self.channels.append(contentsOf: channels!)
    //                DispatchQueue.main.async {
    //                    self.groupChannelListQuery = query
    //                    self.tableView.reloadData()
    //                }
    //            })
    //        }
    //    }
    //
    func didFailReconnection() {
        
    }
    
    // MARK: SBDChannelDelegate
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        if sender is SBDGroupChannel {
            let messageReceivedChannel = sender as! SBDGroupChannel
            if self.channels.index(of: messageReceivedChannel) != nil {
                self.channels.remove(at: self.channels.index(of: messageReceivedChannel)!)
            }
            self.channels.insert(messageReceivedChannel, at: 0)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
        
    }
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        
        let row = self.channels.index(of: sender)
        if row != nil {
            let cell = self.tableView.cellForRow(at: IndexPath(row: row!, section: 0)) as! GroupChannelListTableViewCell
            cell.startTypingAnimation()
        }
    }
    
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        DispatchQueue.main.async {
            if self.channels.index(of: sender) == nil {
                self.channels.append(sender)
            }
            self.tableView.reloadData()
        }
    }
    
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        if user.userId == SBDMain.getCurrentUser()?.userId {
            if let index = self.channels.index(of: sender) {
                self.channels.remove(at: index)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
        
    }
    
    private func channel(_ sender: SBDOpenChannel, userWasMuted user: SBDUser) {
        
    }
    
    private func channel(_ sender: SBDOpenChannel, userWasUnmuted user: SBDUser) {
        
    }
    
    private func channel(_ sender: SBDOpenChannel, userWasBanned user: SBDUser) {
        
    }
    
    private func channel(_ sender: SBDOpenChannel, userWasUnbanned user: SBDUser) {
        
    }
    
    private func channelWasFrozen(_ sender: SBDOpenChannel) {
        
    }
    
    private func channelWasUnfrozen(_ sender: SBDOpenChannel) {
        
    }
    
    func channelWasChanged(_ sender: SBDBaseChannel) {
        if sender is SBDGroupChannel {
            let messageReceivedChannel = sender as! SBDGroupChannel
            if self.channels.index(of: messageReceivedChannel) != nil {
                self.channels.remove(at: self.channels.index(of: messageReceivedChannel)!)
            }
            self.channels.insert(messageReceivedChannel, at: 0)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        
    }
    
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        
    }
}
class NotificationModel {
    
    fileprivate var kTitle = "Title"
    fileprivate var kId = "Id"
    fileprivate var kDescription = "Description"
    fileprivate var kMessageSentDate = "MessageSentDate"
    fileprivate var kCouponCode = "CouponCode"
    fileprivate var kIsNotificationRead = "IsNotificationRead"
    
    var title = ""
    var id = ""
    var description = ""
    var messageSentDate = ""
    var couponCode = ""
    var isNotificationRead:Bool = false
    
    init(notificationDetail:[String:Any]) {
        if let objTitle = notificationDetail[kTitle],!(objTitle is NSNull) {
            self.title = "\(objTitle)"
        }
        if let objId = notificationDetail[kId],!(objId is NSNull) {
            self.id = "\(objId)"
        }
        if let objDescription = notificationDetail[kDescription],!(objDescription is NSNull) {
            self.description = "\(objDescription)"
        }
        if let objMessageSentDate = notificationDetail[kMessageSentDate],!(objMessageSentDate is NSNull) {
            self.messageSentDate = "\(objMessageSentDate)"
        }
        if let objCouponCode = notificationDetail[kCouponCode],!(objCouponCode is NSNull) {
            self.couponCode = "\(objCouponCode)"
        }
        if let objNotificationRead = notificationDetail[kIsNotificationRead],!(objNotificationRead is NSNull) {
            self.isNotificationRead = Bool.init("\(objNotificationRead)")
        }
    }
}
class NotificationTableViewCell:UITableViewCell{
    @IBOutlet var lblStatus:UILabel!
    @IBOutlet var lblNotificationDescription:UILabel!
    @IBOutlet var lblDate:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}
