
//  GroupChannelChattingViewController.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/10/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import AVKit
import AVFoundation
import MobileCoreServices
import IQKeyboardManagerSwift
class GroupChannelChattingViewController: UIViewController, SBDConnectionDelegate, SBDChannelDelegate, ChattingViewDelegate, MessageDelegate, ConnectionManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var groupChannel: SBDGroupChannel!
    
    @IBOutlet weak var chattingView: ChattingView!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var buttonback: UIButton!
//    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
//    @IBOutlet weak var imageViewerLoadingView: UIView!
//    @IBOutlet weak var imageViewerLoadingIndicator: UIActivityIndicatorView!
//    @IBOutlet weak var imageViewerLoadingViewNavItem: UINavigationItem!
    private var refreshInViewDidAppear: Bool = true
    private var messageQuery: SBDPreviousMessageListQuery!
    private var delegateIdentifier: String!
    private var hasNext: Bool = true
    private var isLoading: Bool = false
    private var keyboardShown: Bool = false
    
    @IBOutlet weak var navigationBarHeight: NSLayoutConstraint!
    
    private var minMessageTimestamp: Int64 = Int64.max
    private var dumpedMessages: [SBDBaseMessage] = []
    private var cachedMessage: Bool = true
    var selected:PendingExperience?
    var tapGesture = UITapGestureRecognizer()
    override func viewDidLoad() {
        super.viewDidLoad()
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        self.buttonback.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.buttonback.imageView?.tintColor = UIColor.black
//        if groupChannel != nil{
//            self.lblTitle.text = groupChannel.name
//        }
       
        if self.getReceiverName(objChannel: self.groupChannel) == "Receiver leave"{
            if let _ = selected{
                selected!.setPendingExperienceToUserDefault()
                self.lblTitle.text = selected!.title
            }else{
                self.lblTitle.text = groupChannel.name
            }
        }else{
            self.lblTitle.text = self.getReceiverName(objChannel: self.groupChannel)
        }
        
        let meme = groupChannel.value(forKeyPath: "data") as? String
        let data = meme!.data(using: String.Encoding.utf8)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate(notification:)), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        

        self.delegateIdentifier = self.description
        SBDMain.add(self as SBDChannelDelegate, identifier: self.delegateIdentifier)
        ConnectionManager.add(connectionObserver: self as ConnectionManagerDelegate)
        
      
        self.chattingView.sendButton.addTarget(self, action: #selector(sendMessage), for: UIControlEvents.touchUpInside)
        
        self.hasNext = true
        self.isLoading = false
        
      
//        self.chattingView.sendButton.addTarget(self, action: #selector(sendMessage), for: UIControlEvents.touchUpInside)
        
        //self.dumpedMessages = Utils.loadMessagesInChannel(channelUrl: self.groupChannel.channelUrl)
        
        self.chattingView.initChattingView()
        self.chattingView.delegate = self
        self.minMessageTimestamp = LLONG_MAX
        self.cachedMessage = false
        
//        if self.dumpedMessages.count > 0 {
//            self.chattingView.messages.append(contentsOf: self.dumpedMessages)
//
//            self.chattingView.chatTbl.reloadData()
//            self.chattingView.chatTbl.layoutIfNeeded()
//
//         //   let viewHeight = UIScreen.main.bounds.size.height - self.navigationBarHeight.constant - self.chattingView.inputContainerViewHeight.constant - 10
////            let contentSize = self.chattingView.chatTbl.contentSize
////
////            if contentSize.height > viewHeight {
////                let newContentOffset = CGPoint(x: 0, y: contentSize.height - viewHeight)
////                self.chattingView.chatTbl.setContentOffset(newContentOffset, animated: false)
////            }
////
////            self.cachedMessage = true
//        }

        if SBDMain.getConnectState() == .open {
            ConnectionManager.login { (user, error) in
                guard error == nil else {
                    return
                }
            }
        }else {
            self.loadPreviousMessage(initial: true)
        }
    
    }
    
    deinit {
        ConnectionManager.remove(connectionObserver: self as ConnectionManagerDelegate)
    }
    func getReceiverName(objChannel:SBDGroupChannel)->String{
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            if objChannel.memberCount > 1{
                for member in objChannel.members! as NSArray as! [SBDUser] {
                    if member.userId == currentUser.userID {
                        
                    }else{
                        self.chattingView.lblReceiverLeft?.isHidden = true
                        return member.nickname ?? ""
                    }
                }
                self.chattingView.lblReceiverLeft?.isHidden = true
                return ""
            }else{
                self.chattingView.lblReceiverLeft?.isHidden = false
                return "Receiver leave"
            }
        }else{
            self.chattingView.lblReceiverLeft?.isHidden = true
            return ""
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DispatchQueue.main.async {
            self.view.endEditing(true)
            IQKeyboardManager.shared.enable = true
        }
        if self.chattingView.messages.count > 0{
            Utils.dumpMessages(messages: self.chattingView.messages, resendableMessages: self.chattingView.resendableMessages, resendableFileData: self.chattingView.resendableFileData, preSendMessages: self.chattingView.preSendMessages, channelUrl: self.groupChannel.channelUrl)
        }else{
//            self.groupChannel.hide(withHidePreviousMessages: true) { (error) in
//                guard error == nil else {    // Error.
//                    return
//                }
//            }
        }
        print("\(self.chattingView.messages.count)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        self.swipeToPop()
    }
    func swipeToPop() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        return true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.refreshInViewDidAppear {
            if self.dumpedMessages.count > 0 {
                self.chattingView.messages.append(contentsOf: self.dumpedMessages)
                
                self.chattingView.chatTbl.reloadData()
                self.chattingView.chatTbl.layoutIfNeeded()
                
//                let viewHeight = UIScreen.main.bounds.size.height - self.navigationBarHeight.constant - self.chattingView.inputContainerViewHeight.constant - 10
                let viewHeight = UIScreen.main.bounds.size.height - self.chattingView.inputContainerViewHeight.constant - 10
                let contentSize = self.chattingView.chatTbl.contentSize
                
                if contentSize.height > viewHeight {
                    let newContentOffset = CGPoint(x: 0, y: contentSize.height - viewHeight)
                    self.chattingView.chatTbl.setContentOffset(newContentOffset, animated: false)
                }
                
                self.cachedMessage = true
                self.loadPreviousMessage(initial: true)
                
                return
            }
            else {
                self.cachedMessage = false
                self.minMessageTimestamp = Int64.max
                self.loadPreviousMessage(initial: true)
            }
        }
        
        self.refreshInViewDidAppear = true
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.chattingView.messageVTxtVew.resignFirstResponder()
        self.view.endEditing(true)
    }
    func clickMessage(view: UIView, message: SBDBaseMessage) {
        
    }
    
    @objc private func keyboardDidShow(notification: Notification) {
        self.keyboardShown = true
        let keyboardInfo = notification.userInfo
        let keyboardFrameBegin = keyboardInfo?[UIKeyboardFrameEndUserInfoKey]
        let keyboardFrameBeginRect = (keyboardFrameBegin as! NSValue).cgRectValue
        DispatchQueue.main.async {

            UIView.animate(withDuration: 0.2, animations: {
                self.bottomMargin.constant = (keyboardFrameBeginRect.size.height)
                self.view.layoutIfNeeded()
            })
     
            self.chattingView.stopMeasuringVelocity = true
            self.chattingView.scrollToBottom(force: false)
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification) {
        self.keyboardShown = false
        DispatchQueue.main.async {
            self.bottomMargin.constant = 0
            if self.chattingView.messageVTxtVew.text.count > 0 {
                self.chattingView.sendButton.setImage(UIImage(named: "send_icon"), for: .normal)
            }else{
                self.chattingView.sendButton.setImage(UIImage(named: "white_send_icon"), for: .normal)
            }
            
            self.view.layoutIfNeeded()
            self.chattingView.scrollToBottom(force: false)
        }
    }
    
    @objc private func applicationWillTerminate(notification: Notification) {
        Utils.dumpMessages(messages: self.chattingView.messages, resendableMessages: self.chattingView.resendableMessages, resendableFileData: self.chattingView.resendableFileData, preSendMessages: self.chattingView.preSendMessages, channelUrl: self.groupChannel.channelUrl)
    }
    
    @IBAction func close() {
        DispatchQueue.main.async {
            self.view.endEditing(true)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                SBDMain.removeChannelDelegate(forIdentifier: self.description)
                SBDMain.removeConnectionDelegate(forIdentifier: self.description)
                if self.chattingView.messages.count > 0{
                    
                }else{
                    self.groupChannel.hide(withHidePreviousMessages: true) { (error) in
                        guard error == nil else {    // Error.
                            return
                        }
                    }
                }
                
                let value = UserDefaults.standard.integer(forKey: "navigationScreen")
                if value == 1{
                    //self.dismiss(animated: false) {
                    self.navigationController?.popToRootViewController(animated: true)
                    //}
                }else{
                    //            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    //            let tabBarController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                    //            tabBarController.selectedIndex = 1
                    //            for controller in self.navigationController!.viewControllers as Array {
                    //                if controller.isKind(of: HomeViewController.self) {
                    //                   self.navigationController?.popViewController(animated: false)
                    //                    break
                    //                }
                    //            }
                    self.navigationController?.popToRootViewController(animated: true)
                    //  self.navigationController?.pushViewController(tabBarController, animated: true)
                }
            })
        }
    }
    
    @objc private func openMoreMenu() {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let seeMemberListAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "SeeMemberListButton"), style: UIAlertActionStyle.default) { (action) in

        }
        let inviteUserListAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "InviteUserButton"), style: UIAlertActionStyle.default) { (action) in
            DispatchQueue.main.async {
                let vc = CreateGroupChannelUserListViewController(nibName: "CreateGroupChannelUserListViewController", bundle: Bundle.main)
                vc.userSelectionMode = 1
                vc.groupChannel = self.groupChannel
                self.present(vc, animated: false, completion: nil)
            }
        }
        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
        vc.addAction(seeMemberListAction)
        vc.addAction(inviteUserListAction)
        vc.addAction(closeAction)
        
        self.present(vc, animated: true, completion: nil)
    }
    
    private func loadPreviousMessage(initial: Bool) {
        var timestamp: Int64 = 0
        if initial {
            self.hasNext = true
            timestamp = Int64.max
        }
        else {
            timestamp = self.minMessageTimestamp
        }
        
        if self.hasNext == false {
            return
        }
        
        if self.isLoading {
            return
        }
        
   
        
        self.isLoading = true
        self.groupChannel.getPreviousMessages(byTimestamp: timestamp, limit: 30, reverse: !initial, messageType: SBDMessageTypeFilter.all, customType: "") { (messages, error) in
            if error != nil {
                self.isLoading = false
                
                return
            }
            
            self.cachedMessage = false
            
            if messages?.count == 0 {
                self.hasNext = false
            }
            
            if initial {
                self.chattingView.messages.removeAll()
                
                for item in messages! {
                    let message: SBDBaseMessage = item as SBDBaseMessage
                    self.chattingView.messages.append(message)
                    if self.minMessageTimestamp > message.createdAt {
                        self.minMessageTimestamp = message.createdAt
                    }
                    
                }
                let resendableMessagesKeys = self.chattingView.resendableMessages.keys
                for item in resendableMessagesKeys {
                    let key = item as String
                    self.chattingView.messages.append(self.chattingView.resendableMessages[key]!)
                }
                
                let preSendMessagesKeys = self.chattingView.preSendMessages.keys
                for item in preSendMessagesKeys {
                    let key = item as String
                    self.chattingView.messages.append(self.chattingView.preSendMessages[key]!)
                }
                
                self.groupChannel.markAsRead()
                
                self.chattingView.initialLoading = true
                
                if (messages?.count)! > 0 {
                    DispatchQueue.main.async {
                        self.chattingView.chatTbl.reloadData()
                        self.chattingView.chatTbl.layoutIfNeeded()
                        
                        var viewHeight: CGFloat
                        if self.keyboardShown {
                            viewHeight = self.chattingView.chatTbl.frame.size.height - 10
                        }
                        else {
                            viewHeight = UIScreen.main.bounds.size.height - 44
                        }
                        
                        let contentSize = self.chattingView.chatTbl.contentSize
                        
                        if contentSize.height > viewHeight {
                            let newContentOffset = CGPoint(x: 0, y: contentSize.height - viewHeight)
                            self.chattingView.chatTbl.setContentOffset(newContentOffset, animated: false)
                        }
                        self.chattingView.scrollToBottom(force: true)
                    }
                 
                }
                
                self.chattingView.initialLoading = false
                self.isLoading = false
            }
            else {
                if (messages?.count)! > 0 {
                    for item in messages! {
                        let message: SBDBaseMessage = item as SBDBaseMessage
                        self.chattingView.messages.insert(message, at: 0)
                        
                        if self.minMessageTimestamp > message.createdAt {
                            self.minMessageTimestamp = message.createdAt
                        }
                    }
                    
                    DispatchQueue.main.async {
                        let contentSizeBefore = self.chattingView.chatTbl.contentSize
                        
                        self.chattingView.chatTbl.reloadData()
                        self.chattingView.chatTbl.layoutIfNeeded()
                        
                        let contentSizeAfter = self.chattingView.chatTbl.contentSize
                        
                        let newContentOffset = CGPoint(x: 0, y: contentSizeAfter.height - contentSizeBefore.height)
                        self.chattingView.chatTbl.setContentOffset(newContentOffset, animated: false)
                        
                    }
                }
                
                self.isLoading = false
            }
        }
    }
    
   
    
    private func sendMessageWithReplacement(replacement: OutgoingGeneralUrlPreviewTempModel) {
        let preSendMessage = self.groupChannel.sendUserMessage(replacement.message, data: "", customType:"", targetLanguages: ["ar", "de", "fr", "nl", "ja", "ko", "pt", "es", "zh-CHS"]) { (userMessage, error) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(150), execute: { 
                let preSendMessage = self.chattingView.preSendMessages[(userMessage?.requestId)!] as! SBDUserMessage
                self.chattingView.preSendMessages.removeValue(forKey: (userMessage?.requestId)!)
                
                if error != nil {
                    self.chattingView.resendableMessages[(userMessage?.requestId)!] = userMessage
                    self.chattingView.chatTbl.reloadData()
                    DispatchQueue.main.async {
                        self.chattingView.scrollToBottom(force: true)
                    }
                    return
                }
                self.chattingView.messages[self.chattingView.messages.index(of: preSendMessage)!] = userMessage!
                self.chattingView.chatTbl.reloadData()
                DispatchQueue.main.async {
                    self.chattingView.scrollToBottom(force: true)
                }
            })
        }
        self.chattingView.messages[self.chattingView.messages.index(of: replacement)!] = preSendMessage
        self.chattingView.preSendMessages[preSendMessage.requestId!] = preSendMessage
        DispatchQueue.main.async {
            self.chattingView.chatTbl.reloadData()
            DispatchQueue.main.async {
                self.chattingView.scrollToBottom(force: true)
            }
        }
    }
    
    @objc private func sendMessage() {
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"NoInternet"))
            return
        }
        if self.chattingView.messageVTxtVew.text.count > 0 {
            self.groupChannel.endTyping()
            let message = self.chattingView.messageVTxtVew.text
            self.chattingView.messageVTxtVew.text = ""
            
            do {
                let detector: NSDataDetector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                let matches = detector.matches(in: message!, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, (message?.count)!))
                var url: URL? = nil
                for item in matches {
                    let match = item as NSTextCheckingResult
                    url = match.url
                    break
                }
                
                if url != nil {
                    let tempModel = OutgoingGeneralUrlPreviewTempModel()
                    tempModel.createdAt = Int64(NSDate().timeIntervalSince1970 * 1000)
                    tempModel.message = message
                    
                    self.chattingView.messages.append(tempModel)
                    DispatchQueue.main.async {
                        self.chattingView.chatTbl.reloadData()
                        self.chattingView.placeholderLabel.isHidden = false
                        DispatchQueue.main.async {
                            self.chattingView.scrollToBottom(force: true)
                        }
                    }
                    // Send preview
                 //   self.sendUrlPreview(url: url!, message: message!, aTempModel: tempModel)
                    return
                }
            }
            catch {
                
            }
            
            self.chattingView.sendButton.isEnabled = false
            let preSendMessage = self.groupChannel.sendUserMessage(message, data: "", customType: "", targetLanguages: ["ar", "de", "fr", "nl", "ja", "ko", "pt", "es", "zh-CHS"], completionHandler: { (userMessage, error) in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(150), execute: {
                    let preSendMessage = self.chattingView.preSendMessages[(userMessage?.requestId)!] as! SBDUserMessage
                    self.chattingView.preSendMessages.removeValue(forKey: (userMessage?.requestId)!)
                    
                    if error != nil {
                        self.chattingView.resendableMessages[(userMessage?.requestId)!] = userMessage
                        self.chattingView.chatTbl.reloadData()
                        DispatchQueue.main.async {
                             self.chattingView.placeholderLabel.isHidden = false
                            self.chattingView.scrollToBottom(force: true)
                        }
                        return
                    }
                    
                    let index = IndexPath(row: self.chattingView.messages.index(of: preSendMessage)!, section: 0)
                    self.chattingView.chatTbl.beginUpdates()
                    self.chattingView.messages[self.chattingView.messages.index(of: preSendMessage)!] = userMessage!
                    
                    UIView.setAnimationsEnabled(false)
                    self.chattingView.chatTbl.reloadRows(at: [index], with: UITableViewRowAnimation.none)
                    UIView.setAnimationsEnabled(true)
                    self.chattingView.chatTbl.endUpdates()
                    
                    DispatchQueue.main.async {
                        self.chattingView.placeholderLabel.isHidden = false
                        self.chattingView.scrollToBottom(force: true)
                    }
                })
            })
            
            self.chattingView.preSendMessages[preSendMessage.requestId!] = preSendMessage
            DispatchQueue.main.async {
                if self.chattingView.preSendMessages[preSendMessage.requestId!] == nil {
                    return
                }
                
                self.chattingView.chatTbl.beginUpdates()
                self.chattingView.messages.append(preSendMessage)
                
                UIView.setAnimationsEnabled(false)
                
                self.chattingView.chatTbl.insertRows(at: [IndexPath(row: self.chattingView.messages.index(of: preSendMessage)!, section: 0)], with: UITableViewRowAnimation.none)
                UIView.setAnimationsEnabled(true)
                DispatchQueue.main.async {
                    self.chattingView.chatTbl.endUpdates()
                     self.chattingView.placeholderLabel.isHidden = false
                    self.chattingView.scrollToBottom(force: true)
                    self.chattingView.sendButton.isEnabled = true
                }
            }
        }
        DispatchQueue.main.async {
//            self.view.endEditing(true)
        }
    }
    
    @objc private func sendFileMessage() {
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = UIImagePickerControllerSourceType.photoLibrary
        let mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
        mediaUI.mediaTypes = mediaTypes
        mediaUI.delegate = self
        self.present(mediaUI, animated: true, completion: nil)
    }
    
    @objc func clickReconnect() {
        if SBDMain.getConnectState() != SBDWebSocketConnectionState.open && SBDMain.getConnectState() != SBDWebSocketConnectionState.connecting {
            SBDMain.reconnect()
        }
    }
    
    // MARK: Connection manager delegate
    func didConnect(isReconnection: Bool) {
        self.loadPreviousMessage(initial: true)
        
       // self.groupChannel.refresh { (error) in
//            if error == nil {
//                if self.navItem.titleView is UILabel, let label: UILabel = self.navItem.titleView as? UILabel {
//                    let title: String = NSString.init(format: Bundle.sbLocalizedStringForKey(key: "GroupChannelTitle") as NSString, self.groupChannel.memberCount) as String
//                    let subtitle: String? = Bundle.sbLocalizedStringForKey(key: "ReconnetedSubTitle") as String?
//
//                    DispatchQueue.main.async {
//                        label.attributedText = Utils.generateNavigationTitle(mainTitle: title, subTitle: subtitle)
//
//                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
//                            label.attributedText = Utils.generateNavigationTitle(mainTitle: title, subTitle: nil)
//                        }
//                    }
//                }
//            }
       // }
    }
    
    func didDisconnect() {
//        if self.navItem.titleView is UILabel, let label: UILabel = self.navItem.titleView as? UILabel {
//            let title: String = NSString.init(format: Bundle.sbLocalizedStringForKey(key: "GroupChannelTitle") as NSString, self.groupChannel.memberCount) as String
//            var subtitle: String? = Bundle.sbLocalizedStringForKey(key: "ReconnectionFailedSubTitle") as String?
//
//            DispatchQueue.main.async {
//                label.attributedText = Utils.generateNavigationTitle(mainTitle: title, subTitle: subtitle)
//            }
//
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
//                subtitle = Bundle.sbLocalizedStringForKey(key: "ReconnectingSubTitle")
//                label.attributedText = Utils.generateNavigationTitle(mainTitle: title, subTitle: subtitle)
//            }
//        }
    }
    
    // MARK: SBDChannelDelegate
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        if sender == self.groupChannel {
            self.groupChannel.markAsRead()
            
            DispatchQueue.main.async {
                UIView.setAnimationsEnabled(false)
                self.chattingView.messages.append(message)
                self.chattingView.chatTbl.reloadData()
                UIView.setAnimationsEnabled(true)
                DispatchQueue.main.async {
                    self.chattingView.scrollToBottom(force: false)
                }
            }
        }
    }
    
    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
        if sender == self.groupChannel {
            DispatchQueue.main.async {
                self.chattingView.chatTbl.reloadData()
            }
        }
    }
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        if sender == self.groupChannel {
            if sender.getTypingMembers()?.count == 0 {
                self.chattingView.endTypingIndicator()
            }
            else {
                if sender.getTypingMembers()?.count == 1 {
                  //  self.chattingView.startTypingIndicator(text: String(format: Bundle.sbLocalizedStringForKey(key: "TypingMessageSingular"), (sender.getTypingMembers()?[0].nickname)!))
                    self.chattingView.startTypingIndicator(String(format: Bundle.sbLocalizedStringForKey(key: "TypingMessageSingular"), (sender.getTypingMembers()?[0].nickname)!))
                }
                else {
                    self.chattingView.startTypingIndicator(Bundle.sbLocalizedStringForKey(key: "TypingMessagePlural"))
                }
            }
        }
    }
    
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
//        if self.navItem.titleView != nil && self.navItem.titleView is UILabel {
//            DispatchQueue.main.async {
//                (self.navItem.titleView as! UILabel).attributedText = Utils.generateNavigationTitle(mainTitle: String(format:Bundle.sbLocalizedStringForKey(key: "GroupChannelTitle"), self.groupChannel.memberCount), subTitle: nil)
//            }
//        }
    }
    
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
//        if self.navItem.titleView != nil && self.navItem.titleView is UILabel {
//            DispatchQueue.main.async {
//                (self.navItem.titleView as! UILabel).attributedText = Utils.generateNavigationTitle(mainTitle: String(format:Bundle.sbLocalizedStringForKey(key: "GroupChannelTitle"), self.groupChannel.memberCount), subTitle: nil)
//            }
//        }
    }
    
    func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDBaseChannel, userWasMuted user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDBaseChannel, userWasUnmuted user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDBaseChannel, userWasBanned user: SBDUser) {
        
    }
    
    func channel(_ sender: SBDBaseChannel, userWasUnbanned user: SBDUser) {
        
    }
    
    func channelWasFrozen(_ sender: SBDBaseChannel) {
        
    }
    
    func channelWasUnfrozen(_ sender: SBDBaseChannel) {
        
    }
    
    func channelWasChanged(_ sender: SBDBaseChannel) {
        if sender == self.groupChannel {
            DispatchQueue.main.async {
              //  self.navItem.title = String(format: Bundle.sbLocalizedStringForKey(key: "GroupChannelTitle"), self.groupChannel.memberCount)
            }
        }
    }
    
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ChannelDeletedTitle"), message: Bundle.sbLocalizedStringForKey(key: "ChannelDeletedMessage"), preferredStyle: UIAlertControllerStyle.alert)
        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel) { (action) in
            self.close()
        }
        vc.addAction(closeAction)
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        if sender == self.groupChannel {
            for message in self.chattingView.messages {
                if message.messageId == messageId {
                    self.chattingView.messages.remove(at: self.chattingView.messages.index(of: message)!)
                    DispatchQueue.main.async {
                        self.chattingView.chatTbl.reloadData()
                    }
                    break
                }
            }
        }
    }
    
    // MARK: ChattingViewDelegate
    func loadMoreMessage(view: UIView) {
        if self.cachedMessage {
            return
        }
        
        self.loadPreviousMessage(initial: false)
    }
    
    func startTyping(view: UIView) {
        self.groupChannel.startTyping()
    }
    
    func endTyping(view: UIView) {
        self.groupChannel.endTyping()
    }
    
    func hideKeyboardWhenFastScrolling(view: UIView) {
        if self.keyboardShown == false {
            return
        }
        
        DispatchQueue.main.async {
            self.bottomMargin.constant = 0
            self.view.layoutIfNeeded()
            self.chattingView.scrollToBottom(force: false)
        }
        self.view.endEditing(true)
    }
    
    // MARK: MessageDelegate
    func clickProfileImage(viewCell: UITableViewCell, user: SBDUser) {
        let vc = UIAlertController(title: user.nickname, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let seeBlockUserAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "BlockUserButton"), style: UIAlertActionStyle.default) { (action) in
            SBDMain.blockUser(user, completionHandler: { (blockedUser, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                        vc.addAction(closeAction)
                        DispatchQueue.main.async {
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                    
                    return
                }
                
                DispatchQueue.main.async {
                    let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "UserBlockedTitle"), message: String(format: Bundle.sbLocalizedStringForKey(key: "UserBlockedMessage"), user.nickname!), preferredStyle: UIAlertControllerStyle.alert)
                    let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                    vc.addAction(closeAction)
                    DispatchQueue.main.async {
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            })
        }
        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
        vc.addAction(seeBlockUserAction)
        vc.addAction(closeAction)
        
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    
    func clickResend(view: UIView, message: SBDBaseMessage) {
        let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ResendFailedMessageTitle"), message: Bundle.sbLocalizedStringForKey(key: "ResendFailedMessageDescription"), preferredStyle: UIAlertControllerStyle.alert)
        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
        let resendAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "ResendFailedMessageButton"), style: UIAlertActionStyle.default) { (action) in
            if message is SBDUserMessage {
                let resendableUserMessage = message as! SBDUserMessage
                var targetLanguages:[String] = []
                if resendableUserMessage.translations != nil {
                    targetLanguages = Array(resendableUserMessage.translations!.keys) as! [String]
                }
                
                do {
                    let detector: NSDataDetector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                    let matches = detector.matches(in: resendableUserMessage.message!, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, (resendableUserMessage.message!.count)))
                    var url: URL? = nil
                    for item in matches {
                        let match = item as NSTextCheckingResult
                        url = match.url
                        break
                    }
                    
                    if url != nil {
                        let tempModel = OutgoingGeneralUrlPreviewTempModel()
                        tempModel.createdAt = Int64(NSDate().timeIntervalSince1970 * 1000)
                        tempModel.message = resendableUserMessage.message!
                        
                        self.chattingView.messages[self.chattingView.messages.index(of: resendableUserMessage)!] = tempModel
                        self.chattingView.resendableMessages.removeValue(forKey: resendableUserMessage.requestId!)
                        
                        DispatchQueue.main.async {
                            self.chattingView.chatTbl.reloadData()
                            DispatchQueue.main.async {
                                self.chattingView.scrollToBottom(force: true)
                            }
                        }
                        
                        // Send preview
                      //  self.sendUrlPreview(url: url!, message: resendableUserMessage.message!, aTempModel: tempModel)
                    }
                }
                catch {
                    
                }
                
                let preSendMessage = self.groupChannel.sendUserMessage(resendableUserMessage.message, data: resendableUserMessage.data, customType: resendableUserMessage.customType, targetLanguages: targetLanguages, completionHandler: { (userMessage, error) in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(150), execute: {
                        DispatchQueue.main.async {
                            let preSendMessage = self.chattingView.preSendMessages[(userMessage?.requestId)!]
                            self.chattingView.preSendMessages.removeValue(forKey: (userMessage?.requestId)!)
                            
                            if error != nil {
                                self.chattingView.resendableMessages[(userMessage?.requestId)!] = userMessage
                                self.chattingView.chatTbl.reloadData()
                                DispatchQueue.main.async {
                                    self.chattingView.scrollToBottom(force: true)
                                }
                                
                                let alert = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                                let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                                alert.addAction(closeAction)
                                DispatchQueue.main.async {
                                    self.present(alert, animated: true, completion: nil)
                                }
                                
                                return
                            }
                            
                            if preSendMessage != nil {
                                self.chattingView.messages.remove(at: self.chattingView.messages.index(of: (preSendMessage! as SBDBaseMessage))!)
                                self.chattingView.messages.append(userMessage!)
                            }
                            
                            self.chattingView.chatTbl.reloadData()
                            DispatchQueue.main.async {
                                self.chattingView.scrollToBottom(force: true)
                            }
                        }
                    })
                })
                self.chattingView.messages[self.chattingView.messages.index(of: resendableUserMessage)!] = preSendMessage
                self.chattingView.preSendMessages[preSendMessage.requestId!] = preSendMessage
                self.chattingView.resendableMessages.removeValue(forKey: resendableUserMessage.requestId!)
                self.chattingView.chatTbl.reloadData()
                DispatchQueue.main.async {
                    self.chattingView.scrollToBottom(force: true)
                }
            }
            else if message is SBDFileMessage {
                let resendableFileMessage = message as! SBDFileMessage
                
                var thumbnailSizes: [SBDThumbnailSize] = []
                for thumbnail in resendableFileMessage.thumbnails! as [SBDThumbnail] {
                    thumbnailSizes.append(SBDThumbnailSize.make(withMaxCGSize: thumbnail.maxSize)!)
                }
                let preSendMessage = self.groupChannel.sendFileMessage(withBinaryData: self.chattingView.preSendFileData[resendableFileMessage.requestId!]?["data"] as! Data, filename: resendableFileMessage.name, type: resendableFileMessage.type, size: resendableFileMessage.size, thumbnailSizes: thumbnailSizes, data: resendableFileMessage.data, customType: resendableFileMessage.customType, progressHandler: nil, completionHandler: { (fileMessage, error) in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(150), execute: {
                        let preSendMessage = self.chattingView.preSendMessages[(fileMessage?.requestId)!]
                        self.chattingView.preSendMessages.removeValue(forKey: (fileMessage?.requestId)!)
                        
                        if error != nil {
                            self.chattingView.resendableMessages[(fileMessage?.requestId)!] = fileMessage
                            self.chattingView.resendableFileData[(fileMessage?.requestId)!] = self.chattingView.resendableFileData[resendableFileMessage.requestId!]
                            self.chattingView.resendableFileData.removeValue(forKey: resendableFileMessage.requestId!)
                            self.chattingView.chatTbl.reloadData()
                            DispatchQueue.main.async {
                                self.chattingView.scrollToBottom(force: true)
                            }
                            
                            let alert = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "ErrorTitle"), message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                            let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
                            alert.addAction(closeAction)
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                            return
                        }
                        
                        if preSendMessage != nil {
                            self.chattingView.messages.remove(at: self.chattingView.messages.index(of: (preSendMessage! as SBDBaseMessage))!)
                            self.chattingView.messages.append(fileMessage!)
                        }
                        
                        self.chattingView.chatTbl.reloadData()
                        DispatchQueue.main.async {
                            self.chattingView.scrollToBottom(force: true)
                        }
                    })
                })
                
                self.chattingView.messages[self.chattingView.messages.index(of: resendableFileMessage)!] = preSendMessage
                self.chattingView.preSendMessages[preSendMessage.requestId!] = preSendMessage
                self.chattingView.preSendFileData[preSendMessage.requestId!] = self.chattingView.resendableFileData[resendableFileMessage.requestId!]
                self.chattingView.resendableMessages.removeValue(forKey: resendableFileMessage.requestId!)
                self.chattingView.resendableFileData.removeValue(forKey: resendableFileMessage.requestId!)
                self.chattingView.chatTbl.reloadData()
                DispatchQueue.main.async {
                    self.chattingView.scrollToBottom(force: true)
                }
            }
        }
        
        vc.addAction(closeAction)
        vc.addAction(resendAction)
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func clickDelete(view: UIView, message: SBDBaseMessage) {
        let vc = UIAlertController(title: Bundle.sbLocalizedStringForKey(key: "DeleteFailedMessageTitle"), message: Bundle.sbLocalizedStringForKey(key: "DeleteFailedMessageDescription"), preferredStyle: UIAlertControllerStyle.alert)
        let closeAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "CloseButton"), style: UIAlertActionStyle.cancel, handler: nil)
        let deleteAction = UIAlertAction(title: Bundle.sbLocalizedStringForKey(key: "DeleteFailedMessageButton"), style: UIAlertActionStyle.destructive) { (action) in
            var requestId: String?
            if message is SBDUserMessage {
                requestId = (message as! SBDUserMessage).requestId
            }
            else if message is SBDFileMessage {
                requestId = (message as! SBDFileMessage).requestId
            }
            self.chattingView.resendableFileData.removeValue(forKey: requestId!)
            self.chattingView.resendableMessages.removeValue(forKey: requestId!)
            self.chattingView.messages.remove(at: self.chattingView.messages.index(of: message)!)
            DispatchQueue.main.async {
                self.chattingView.chatTbl.reloadData()
            }
        }
        
        vc.addAction(closeAction)
        vc.addAction(deleteAction)
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
    }
    

}
