//
//  DirectReplyViewController.swift
//  Live
//
//  Created by ips on 20/09/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SendBirdSDK
class DirectReplyViewController: UIViewController, UITextViewDelegate, SBDChannelDelegate, SBDConnectionDelegate {
    
    
    @IBOutlet var buttonclose : UIButton!
    @IBOutlet var buttonsend: UIButton!
    @IBOutlet var textmessage: UITextView!
    @IBOutlet var placeholderlbl: UILabel!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet var foregroundLayerView : UIView!

    var preSendMessages: [String:SBDBaseMessage] = [:]
    var groupChannel: SBDGroupChannel!
    var exp_name: String = ""
    var user_id: String = ""
    var exp_id: String = "" //guide_id
    var exp_Image: String = ""
    var objSchedule:Schedule?
    var objPendingExp:PendingExperience?
    var isChannelAvailable:Bool = false
    
    private var keyboardShown: Bool = false
    private var groupChannelListQuery: SBDGroupChannelListQuery?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.foregroundLayerView.isHidden = true
        self.textmessage.delegate = self
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = false
        
        self.placeholderlbl.text = Vocabulary.getWordFromKey(key: "directReplyHint")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name:
            NSNotification.Name.UIKeyboardWillHide, object: nil)
        if SBDMain.getConnectState() == .open {
            ConnectionManager.login { (user, error) in
                guard error == nil else {
                    return
                }
                
            }
        }else{
            print("Please Create Connection")
        }
        // Do any additional setup after loading the view.
    }
    
    deinit {
        ConnectionManager.remove(connectionObserver: self as ConnectionManagerDelegate)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            IQKeyboardManager.shared.enableAutoToolbar = true
            IQKeyboardManager.shared.enable = true
        }
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: - Selector Methods
    @IBAction func onClickCloseBtn(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSendBtn(sender:UIButton){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"NoInternet"))
            return
        }
        
        DispatchQueue.main.async {
            self.foregroundLayerView.isHidden = false
        }
        
        guard self.textmessage.text.count > 0 else{
            DispatchQueue.main.async {
                self.foregroundLayerView.isHidden = true
            }
            return
        }
        if let _ = self.objSchedule{
            self.user_id = self.objSchedule!.userID
            self.exp_id = self.objSchedule!.guideID
            self.exp_name = self.objSchedule!.title
            self.exp_Image = self.objSchedule!.image
        }
        else if let _ = self.objPendingExp {
            self.user_id = self.objPendingExp!.userID
            self.exp_id = self.objPendingExp!.guideID
            self.exp_name = self.objPendingExp!.title
            self.exp_Image = self.objPendingExp!.image
        }
        self.groupChannelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        
        //(self.groupChannelListQuery?.channelNameContainsFilter(self.exp_name))
        
        self.groupChannelListQuery?.loadNextPage(completionHandler: { (channels, error) in
            DispatchQueue.main.async {
                self.foregroundLayerView.isHidden = true
            }
            if error != nil{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                }
            }else{
                
            self.isChannelAvailable = false
            if channels?.count == 0 || channels == nil {
                self.createChannel()
            }else{
                for objChannel:SBDGroupChannel in channels!{
                    
                    if let strChannelData = objChannel.data,let data = strChannelData.data(using: .utf8){
                        do{
                            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                            if let success = json as? [String:Any],let guideID = success["guide"],let userID = success["user"]{
                                
                                if self.exp_id == "\(guideID)",self.user_id == "\(userID)",objChannel.memberCount > 1{
                                    self.isChannelAvailable = true
                                    self.sendMessageToCreatedChannel(objChannel: objChannel)
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
          }
        })
        
    }
    func sendMessageToCreatedChannel(objChannel:SBDGroupChannel){
        SBDGroupChannel.getWithUrl(objChannel.channelUrl, completionHandler: { (channel, error) in
            if error != nil{
                return
            }else{
                self.groupChannel = channel
                self.sendMessage()
            }
        })
    }
    func sendMessage(){
        if textmessage.text.count > 0{
            let message = self.textmessage.text
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
                    return
                }
            }
            catch {
                
            }
            let preSendMessage = self.groupChannel.sendUserMessage(message!, data: nil, customType: nil, targetLanguages: ["ar", "de", "fr", "nl", "ja", "ko", "pt", "es", "zh-CHS"], completionHandler: { (userMessage, error) in
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(50), execute: {
                    if error != nil {
                        return
                    }
                    ShowToast.show(toatMessage: "Message Send Successfully")
                    self.foregroundLayerView.isHidden = true
                    self.navigationController?.popViewController(animated: true)
                })
            })
            
        }
        DispatchQueue.main.async {
            
            self.textmessage.text = ""
            self.placeholderlbl.isHidden = false
            self.buttonsend.backgroundColor =  UIColor(hexString: "#B2B2B2")
            self.buttonsend.isUserInteractionEnabled = true
            self.view.endEditing(true)
        }
    }
    
    func createChannel() {
        
        let arreyofid: [String] = [user_id, exp_id]
        let dict = ["user" : user_id, "guide" : exp_id]
        let dataobject =  try! JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = String(data: dataobject, encoding: .utf8)
        print(exp_Image)
        print(arreyofid)
        print(exp_name)
        SBDGroupChannel.createChannel(withName: exp_name, isDistinct: false, userIds: arreyofid, coverUrl: exp_Image, data: jsonString, customType: nil) { (channel, error) in
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
                self.openGroupChannel(channel: channel!, vc: self)
            }
        }
    }
    func openGroupChannel(channel: SBDGroupChannel, vc: UIViewController) {
        DispatchQueue.main.async {
            print(channel)
            self.groupChannel = channel
            print("******************SUCCESSFULL CREATE CHANNEL *****************")
            self.sendMessage()
        }
    }
    // MARK: - TextView Delegate Methods
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        } else if text.count == 0 {
            self.placeholderlbl.isHidden = false
        } else {
            self.placeholderlbl.isHidden = true
        }
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.placeholderlbl.isHidden = true
    }
    func textViewDidChange(_ textView: UITextView) {
        let test = textView.text.trim()
        if textView == self.textmessage{
            if test.count > 0{
                self.placeholderlbl.isHidden = true
                self.buttonsend.backgroundColor =  UIColor(hexString: "#36527D")
            }else{
                textView.text = test
                self.buttonsend.backgroundColor =  UIColor(hexString: "#B2B2B2")
                self.buttonsend.isUserInteractionEnabled = true
            }
        }
    }
    // MARK: -  Keyboard show and Hide method
    @objc private func keyboardDidShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async {
                //self.descriptionTxtView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height + 30.0, 0)
                UIView.animate(withDuration: 0.1, animations: {
                    self.bottomMargin.constant = keyboardSize.height + 25.0
                    self.loadViewIfNeeded()
                }, completion: { (true) in
                    self.scrollTextViewToBottom(textView: self.textmessage)
                })
            }
            
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async {
                self.textmessage.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                UIView.animate(withDuration: 0.2, animations: {
                    self.bottomMargin.constant = 10.0
                    self.view.endEditing(true)
                    self.loadViewIfNeeded()
                })
            }
            
        }
    }
    
    func scrollTextViewToBottom(textView: UITextView) {
        if textView.text.count > 0 {
            let location = textView.text.count - 1
            let bottom = NSMakeRange(location, 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
extension DirectReplyViewController: ConnectionManagerDelegate{
    func didConnect(isReconnection: Bool) {
        
    }
    
    func didDisconnect() {
        
    }
}
