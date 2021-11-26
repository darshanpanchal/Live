//
//  ChattingView.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/7/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK


protocol ChattingViewDelegate: class {
    func loadMoreMessage(view: UIView)
    func startTyping(view: UIView)
    func endTyping(view: UIView)
    func hideKeyboardWhenFastScrolling(view: UIView)
}

class ChattingView: ReusableViewFromXib, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate,UIGestureRecognizerDelegate {
    @IBOutlet weak var messageVTxtVew: UITextView!
    @IBOutlet weak var chatTbl: UITableView!
    @IBOutlet weak var inputContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var senderView: UIView?
    @IBOutlet weak var reciverView: UIView?
    @IBOutlet weak var incomeUserLbl:UILabel?
    @IBOutlet weak var outgoUserLbl:UILabel?
    @IBOutlet weak var lblReceiverLeft:UILabel?
    
    var messages: [SBDBaseMessage] = []
    private var message: SBDUserMessage!
    var resendableMessages: [String:SBDBaseMessage] = [:]
    var preSendMessages: [String:SBDBaseMessage] = [:]
    
    var resendableFileData: [String:[String:AnyObject]] = [:]
    var preSendFileData: [String:[String:AnyObject]] = [:]
  //  @IBOutlet weak var fileAttachButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    var stopMeasuringVelocity: Bool = true
    var initialLoading: Bool = true
    
    var delegate: (ChattingViewDelegate & MessageDelegate)?

    @IBOutlet weak var typingIndicatorContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var typingIndicatorImageView: UIImageView!
    @IBOutlet weak var typingIndicatorLabel: UILabel!
    @IBOutlet weak var typingIndicatorContainerView: UIView!
    @IBOutlet weak var typingIndicatorImageHeight: NSLayoutConstraint!
    
    var incomingUserMessageSizingTableViewCell: IncomingUserMessageTableViewCell?
    var outgoingUserMessageSizingTableViewCell: OutgoingUserMessageTableViewCell?

    @IBOutlet weak var placeholderLabel: UILabel!
    
    var lastMessageHeight: CGFloat = 0
    var scrollLock: Bool = false
    
    var lastOffset: CGPoint = CGPoint(x: 0, y: 0)
    var lastOffsetCapture: TimeInterval = 0
    var isScrollingFast: Bool = false
    var tapGesture = UITapGestureRecognizer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.chatTbl.addGestureRecognizer(tapGesture)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.chatTbl.addGestureRecognizer(tapGesture)
        self.setup()
    }
  
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.messageVTxtVew.resignFirstResponder()
        self.chatTbl.endEditing(true)
    }
    func setup() {
        placeholderLabel.text = Vocabulary.getWordFromKey(key: "EnterMessage")
      //  self.sendButton.setTitle(Vocabulary.getWordFromKey(key: "SEND"), for: .normal)
        self.chatTbl.contentInset = UIEdgeInsetsMake(0, 0, 10, 0)
      //  self.messageVTxtVew.textContainerInset = UIEdgeInsetsMake(15.5, 0, 14, 0)
    }
    
    func initChattingView() {
        self.initialLoading = true
        self.lastMessageHeight = 0
        self.scrollLock = false
        self.stopMeasuringVelocity = false
        
        self.senderView?.layer.masksToBounds = true
        self.senderView?.layer.cornerRadius = 7
        self.reciverView?.layer.masksToBounds = true
        self.reciverView?.layer.cornerRadius = 7
        self.messageVTxtVew?.delegate = self
        self.chatTbl?.register(IncomingUserMessageTableViewCell.classForCoder(), forCellReuseIdentifier: "IncomingUserMessageTableViewCell")
        self.chatTbl?.register(OutgoingUserMessageTableViewCell.classForCoder(), forCellReuseIdentifier: "outgoingUserMessageSizingTableViewCell")
        self.chatTbl?.register(IncomingUserMessageTableViewCell.nib(), forCellReuseIdentifier: IncomingUserMessageTableViewCell.cellReuseIdentifier())
        self.chatTbl?.register(OutgoingUserMessageTableViewCell.nib(), forCellReuseIdentifier: OutgoingUserMessageTableViewCell.cellReuseIdentifier())
        
        self.chatTbl?.delegate = self
        self.chatTbl?.dataSource = self
        self.initSizingCell()
    }
    @IBAction func onClickbackBtn(sender: UIButton){
       // self.navigationController?.popViewController(animated: true)
    }
    func initSizingCell() {
        self.incomingUserMessageSizingTableViewCell = IncomingUserMessageTableViewCell.nib().instantiate(withOwner: self, options: nil)[0] as? IncomingUserMessageTableViewCell
        self.incomingUserMessageSizingTableViewCell?.isHidden = true
        self.addSubview(self.incomingUserMessageSizingTableViewCell!)
        
        self.outgoingUserMessageSizingTableViewCell = OutgoingUserMessageTableViewCell.nib().instantiate(withOwner: self, options: nil)[0] as? OutgoingUserMessageTableViewCell
        self.outgoingUserMessageSizingTableViewCell?.isHidden = true
        self.addSubview(self.outgoingUserMessageSizingTableViewCell!)
    }
    
    func scrollToBottom(force: Bool) {
        if self.messages.count == 0 {
            return
        }
        
        if self.scrollLock == true && force == false {
            return
        }
        self.chatTbl.scrollToRow(at: IndexPath.init(row: self.messages.count - 1, section: 0), at: .bottom, animated: false)
    }
    
    func scrollToPosition(position: Int) {
        if self.messages.count == 0 {
            return
        }
        self.chatTbl.scrollToRow(at: IndexPath.init(row: position, section: 0), at: UITableViewScrollPosition.top, animated: false)
    }
   
    func startTypingIndicator(_ text: String?) {
        // Typing indicator
        typingIndicatorContainerView.isHidden = false
        typingIndicatorLabel.text = text
        typingIndicatorContainerViewHeight.constant = 26
        typingIndicatorImageHeight.constant = 26
        typingIndicatorContainerView.layoutIfNeeded()
        if typingIndicatorImageView.isAnimating == false {
            var typingImages = [AnyHashable]() as? [UIImage]
            for i in 1...50 {
                let typingImageFrameName = String(format: "%02d", i)
                if let aName = UIImage(named: typingImageFrameName) {
                    typingImages?.append(aName)
                }
            }
            typingIndicatorImageView.animationImages = typingImages
            typingIndicatorImageView.animationDuration = 1.5
            DispatchQueue.main.async(execute: {() -> Void in
                self.typingIndicatorImageView.startAnimating()
            })
        }
    }
    func endTypingIndicator() {
        DispatchQueue.main.async {
            self.typingIndicatorImageView.stopAnimating()
        }
        self.typingIndicatorContainerView.isHidden = true
        self.typingIndicatorContainerViewHeight.constant = 0
        self.typingIndicatorImageHeight.constant = 0
        
        self.typingIndicatorContainerView.layoutIfNeeded()
    }
  
    // MARK: UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        let test = textView.text.trim()
        if textView == self.messageVTxtVew {
            if test.count > 0 {
                self.placeholderLabel.isHidden = true
                self.sendButton.setImage(UIImage(named: "send_icon"), for: .normal)
                if self.delegate != nil {
                    self.delegate?.startTyping(view: self)
                }
            }
            else {
                textView.text = test
                 self.sendButton.setImage(UIImage(named: "white_send_icon"), for: .normal)
                self.placeholderLabel.isHidden = false
                if self.delegate != nil {
                    self.delegate?.endTyping(view: self)
                }
            }
        }
    }
    
    // MARK: UITableViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.stopMeasuringVelocity = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.stopMeasuringVelocity = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.chatTbl {
            if self.stopMeasuringVelocity == false {
                let currentOffset = scrollView.contentOffset
                let currentTime = NSDate.timeIntervalSinceReferenceDate
                
                let timeDiff = currentTime - self.lastOffsetCapture
                if timeDiff > 0.1 {
                    let distance = currentOffset.y - self.lastOffset.y
                    let scrollSpeedNotAbs = distance * 10 / 1000
                    let scrollSpeed = fabs(scrollSpeedNotAbs)
                    if scrollSpeed > 0.5 {
                        self.isScrollingFast = true
                    }
                    else {
                        self.isScrollingFast = false
                    }
                    
                    self.lastOffset = currentOffset
                    self.lastOffsetCapture = currentTime
                }
                
                if self.isScrollingFast {
                    if self.delegate != nil {
                        self.delegate?.hideKeyboardWhenFastScrolling(view: self)
                    }
                }
            }
            
            if scrollView.contentOffset.y + scrollView.frame.size.height + self.lastMessageHeight < scrollView.contentSize.height {
                self.scrollLock = true
            }
            else {
                self.scrollLock = false
            }
            
            if scrollView.contentOffset.y == 0 {
                if self.messages.count > 0 && self.initialLoading == false {
                    if self.delegate != nil {
                        self.delegate?.loadMoreMessage(view: self)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 102
        
        let msg = self.messages[indexPath.row]
        print(msg)
        if msg is SBDUserMessage {
            let userMessage = msg as! SBDUserMessage
            let sender = userMessage.sender
            if sender?.userId == SBDMain.getCurrentUser()?.userId{
           
                    if indexPath.row > 0 {
                        self.outgoingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.outgoingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                      print(userMessage)
                    self.outgoingUserMessageSizingTableViewCell?.setModel(aMessage: userMessage)
                    height =  CGFloat((self.outgoingUserMessageSizingTableViewCell?.getHeightOfViewCell())!)
            }
            else {
                // Incoming
               
                    if indexPath.row > 0 {
                        self.incomingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                    }
                    else {
                        self.incomingUserMessageSizingTableViewCell?.setPreviousMessage(aPrevMessage: nil)
                    }
                  
                    self.incomingUserMessageSizingTableViewCell?.setModel(aMessage: userMessage)
                height = CGFloat((self.incomingUserMessageSizingTableViewCell?.getHeightOfViewCell())!)
                 print(height)
                 print(height+15)
            }
        }
       
        return height
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 7
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
   
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "")
        let msg = self.messages[indexPath.row]
       print(" ========= \(msg) ========== ")
        if msg is SBDUserMessage {
            let userMessage = msg as! SBDUserMessage
            let sender = userMessage.sender
            if sender?.userId == SBDMain.getCurrentUser()?.userId {
                // OutGoing
                cell = tableView.dequeueReusableCell(withIdentifier: OutgoingUserMessageTableViewCell.cellReuseIdentifier())!
                cell.frame = CGRect(x: (cell.frame.origin.x), y: (cell.frame.origin.y), width: (cell.frame.size.width), height: (cell.frame.size.height))
                if indexPath.row > 0 {
                    (cell as! OutgoingUserMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                }
                else {
                    (cell as! OutgoingUserMessageTableViewCell).setPreviousMessage(aPrevMessage: nil)
                }
                (cell as! OutgoingUserMessageTableViewCell).setModel(aMessage: userMessage)
                (cell as! OutgoingUserMessageTableViewCell).delegate = self.delegate
                
                if self.preSendMessages[userMessage.requestId!] != nil {
                    (cell as! OutgoingUserMessageTableViewCell).showSendingStatus()
                }
                else {
                    if self.resendableMessages[userMessage.requestId!] != nil {
                        (cell as! OutgoingUserMessageTableViewCell).showMessageControlButton()
                    }
                    else {
                        (cell as! OutgoingUserMessageTableViewCell).showMessageDate()
                        (cell as! OutgoingUserMessageTableViewCell).showUnreadCount()
                    }
                }
               
                return cell
            }else{
                //InComing
                cell = tableView.dequeueReusableCell(withIdentifier: IncomingUserMessageTableViewCell.cellReuseIdentifier())
                
                cell.frame = CGRect(x: (cell.frame.origin.x), y: (cell.frame.origin.y), width: (cell.frame.size.width), height: (cell.frame.size.height))
                if indexPath.row > 0 {
                    print("Incominng Messages \(self.messages[indexPath.row])")
                    
                    (cell as! IncomingUserMessageTableViewCell).setPreviousMessage(aPrevMessage: self.messages[indexPath.row - 1])
                 
        
                }else {
                    (cell as? IncomingUserMessageTableViewCell)?.setPreviousMessage(aPrevMessage: nil)
                    
                }
                (cell as! IncomingUserMessageTableViewCell).setModel(aMessage: userMessage)
                (cell as! IncomingUserMessageTableViewCell).delegate = self.delegate
                
                (cell as! IncomingUserMessageTableViewCell).profileImageView?.isHidden = self.isShowSenderImage(nextMessageIndex: indexPath.row + 1)
                 (cell as! IncomingUserMessageTableViewCell).layer.zPosition = CGFloat(indexPath.row)
                return cell
            
            }
        }
        return cell
    }
    func isShowSenderImage(nextMessageIndex:Int)->Bool{
        guard self.messages.count > nextMessageIndex else {
            return false
        }
        let nextmessage = self.messages[nextMessageIndex] as SBDBaseMessage
        if nextmessage is SBDUserMessage{
            let userMessage = nextmessage as! SBDUserMessage
            let sender = userMessage.sender
            if sender?.userId == SBDMain.getCurrentUser()?.userId { //Outgoing
                return false
            }else{ //Incoming
                return true
            }
        }else{
            return true
        }
    }
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}
