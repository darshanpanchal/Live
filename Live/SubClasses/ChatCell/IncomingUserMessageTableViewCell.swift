//
//  IncomingUserMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/6/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import TTTAttributedLabel

class IncomingUserMessageTableViewCell: UITableViewCell, TTTAttributedLabelDelegate {
    weak var delegate: MessageDelegate?
    
    @IBOutlet weak var dateSeperatorView: UIView?
    @IBOutlet weak var dateSeperatorLabel: UILabel?
    @IBOutlet weak var profileImageView: ImageViewForURL?
    @IBOutlet weak var messageLabel: TTTAttributedLabel?
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageContainerView: UIView!
    
    @IBOutlet weak var dateSeperatorViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorViewBottomMargin: NSLayoutConstraint!
    
    @IBOutlet weak var profileImageLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var messageContainerLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var profileImageWidth: NSLayoutConstraint!
    @IBOutlet weak var messageDateLabelWidth: NSLayoutConstraint!

    @IBOutlet weak var messageContainerLeftPadding: NSLayoutConstraint!
    @IBOutlet weak var messageContainerBottomPadding: NSLayoutConstraint!
    @IBOutlet weak var messageContainerRightPadding: NSLayoutConstraint!
    @IBOutlet weak var messageContainerTopPadding: NSLayoutConstraint!
    
    @IBOutlet weak var messageDateLabelLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var messageDateLabelRightMargin: NSLayoutConstraint!

    private var message: SBDUserMessage!
    private var prevMessage: SBDBaseMessage?
    private var displayNickname: Bool = true
  
    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    @objc private func clickProfileImage() {
        if self.delegate != nil {
            self.delegate?.clickProfileImage(viewCell: self, user: self.message!.sender!)
        }
    }
    
    @objc private func clickUserMessage() {
        if self.delegate != nil {
//            self.delegate?.clickMessage(view: self, message: self.message!)
        }
    }
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        DispatchQueue.main.async {
//            self.layoutIfNeeded()
//        }
//    }
    func setModel(aMessage: SBDUserMessage) {
        self.dateSeperatorLabel?.layer.masksToBounds = true
        self.dateSeperatorLabel?.layer.cornerRadius = 12
        self.message = aMessage

        // Message Date
        let messageDateAttribute = [
            NSAttributedStringKey.font: Constants.messageDateFont(),
            NSAttributedStringKey.foregroundColor: Constants.messageDateColor()
        ]
        
        let messageTimestamp = Double(self.message.createdAt) / 1000.0
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        let messageCreatedDate = NSDate(timeIntervalSince1970: messageTimestamp)
        let messageDateString = dateFormatter.string(from: messageCreatedDate as Date)
        let messageDateAttributedString = NSMutableAttributedString(string: messageDateString, attributes: messageDateAttribute)
        self.messageDateLabel.attributedText = messageDateAttributedString
        self.messageDateLabel.textColor = UIColor.white
        let df = DateFormatter()
        let format = DateFormatter.dateFormat(
            fromTemplate: "dMMMM", options:0, locale:NSLocale.current)
        df.dateFormat = format
    
        let diffrence = timeAgoSinceDate(messageCreatedDate as Date as Date, currentDate: Date(), numericDates: true)
        if diffrence == "Yesterday"{
             self.dateSeperatorLabel?.text = "Yesterday"
        }else if diffrence == "Today"{
             self.dateSeperatorLabel?.text = "Today"
        }else if diffrence == "Display Date"{
             self.dateSeperatorLabel?.text = " " + df.string(from: messageCreatedDate as Date) + "    "
        }
      
        // Relationship between the current message and the previous message
//        self.profileImageView?.isHidden = false
        self.dateSeperatorView?.isHidden = false
        self.dateSeperatorViewHeight.constant = 24.0
        self.dateSeperatorViewTopMargin.constant = 10.0
        self.dateSeperatorViewBottomMargin.constant = 20.0
        self.displayNickname = true
    
        if self.prevMessage != nil {
            // Day Changed
            let prevMessageDate = NSDate(timeIntervalSince1970: Double((self.prevMessage?.createdAt)!) / 1000.0)
            let currMessageDate = NSDate(timeIntervalSince1970: Double(self.message.createdAt) / 1000.0)
            let prevMessageDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: prevMessageDate as Date)
            let currMessagedateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: currMessageDate as Date)
            
            if prevMessageDateComponents.year != currMessagedateComponents.year || prevMessageDateComponents.month != currMessagedateComponents.month || prevMessageDateComponents.day != currMessagedateComponents.day {
                // Show date seperator.
                self.dateSeperatorView?.isHidden = false
                self.dateSeperatorViewHeight.constant = 24.0
                self.dateSeperatorViewTopMargin.constant = 10.0
               self.dateSeperatorViewBottomMargin.constant = 10.0
            }
            else {
                // Hide date seperator.
                self.dateSeperatorView?.isHidden = true
                self.dateSeperatorViewHeight.constant = 0
                self.dateSeperatorViewBottomMargin.constant = 0
                
                // Continuous Message
                if self.prevMessage is SBDAdminMessage {
                    self.dateSeperatorViewTopMargin.constant = 10.0
                }
                else {
                    var prevMessageSender: SBDUser?
                    var currMessageSender: SBDUser?
                 
                    if self.prevMessage is SBDUserMessage {
                        prevMessageSender = (self.prevMessage as! SBDUserMessage).sender
                    }
                    else if self.prevMessage is SBDFileMessage {
                        prevMessageSender = (self.prevMessage as! SBDFileMessage).sender
                    }
                    
                    currMessageSender = self.message.sender
                   
                   
                    if prevMessageSender != nil && currMessageSender != nil {
                        if prevMessageSender?.userId == currMessageSender?.userId {
                            // Reduce margin
                            self.dateSeperatorViewTopMargin.constant = 5.0
                            self.displayNickname = false
                           //  self.profileImageView?.isHidden = false
                            self.nameLabel.isHidden = true
                        
                        }
                        else {
                         
                            // Set default margin.
                            self.dateSeperatorViewTopMargin.constant = 10.0
                           //  self.profileImageView?.isHidden = false
                            self.nameLabel.isHidden = false
                        }
                    }
                    else {
                        self.dateSeperatorViewTopMargin.constant = 10.0
                    }
                }
            }
        }
        else {
            
            // Show date seperator
            self.dateSeperatorView?.isHidden = false
            self.dateSeperatorViewHeight.constant = 24.0
            self.dateSeperatorViewTopMargin.constant = 10.0
            self.dateSeperatorViewBottomMargin.constant = 10.0
        }
        
        let fullMessage = self.buildMessage()
        self.messageLabel?.attributedText = fullMessage
        self.messageLabel?.isUserInteractionEnabled = true
        self.messageLabel?.linkAttributes = [
            NSAttributedStringKey.font: Constants.messageFont(),
            NSAttributedStringKey.foregroundColor: Constants.incomingMessageColor(),
            NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue
        ]
        
        do {
            let detector: NSDataDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: self.message.message!, options: [], range: NSMakeRange(0, (self.message.message?.characters.count)!))
            if matches.count > 0 {
                self.messageLabel?.delegate = self
                self.messageLabel?.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
                for item in matches {
                    let match = item
                    let rangeOfOriginalMessage = match.range
                    var range: NSRange
                    if self.displayNickname {
                        range = NSMakeRange((self.message.sender?.nickname?.characters.count)! + 1 + rangeOfOriginalMessage.location, rangeOfOriginalMessage.length)
                    }
                    else {
                        range = rangeOfOriginalMessage
                    }
                    
                    self.messageLabel?.addLink(to: match.url, with: range)
                    
                }
            }
        }
        catch {
            
        }
        
        self.layoutIfNeeded()
    }
    func setPreviousMessage(aPrevMessage: SBDBaseMessage?) {
        self.prevMessage = aPrevMessage
    }
    func timeAgoSinceDate(_ date:Date,currentDate:Date, numericDates:Bool) -> String {
        let calendar = Calendar.current
        let now = currentDate
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
         if (components.day! == 1){
                return "Yesterday"
        } else if (components.day! == 0){
            if (components.hour! >= 0){
                return "Today"
            }else{
                return ""
            }
         } else if(components.day! > 1) {
            return "Display Date"
        }else{
            return ""
        }
        
    }
    func buildMessage() -> NSAttributedString {
        var nicknameAttribute = [NSAttributedStringKey : Any]()
        switch (self.message.sender?.nickname?.utf8.count)! % 5 {
        case 0:
            nicknameAttribute = [
                NSAttributedStringKey(rawValue: NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue).rawValue): Constants.nicknameFontInMessage(),
                NSAttributedStringKey(rawValue: NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue).rawValue): Constants.nicknameColorInMessageNo0()
            ]
            break;
        case 1:
            nicknameAttribute = [
                NSAttributedStringKey(rawValue: NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue).rawValue): Constants.nicknameFontInMessage(),
                NSAttributedStringKey(rawValue: NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue).rawValue): Constants.nicknameColorInMessageNo1()
            ]
            break;
        case 2:
            nicknameAttribute = [
                NSAttributedStringKey(rawValue: NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue).rawValue): Constants.nicknameFontInMessage(),
                NSAttributedStringKey(rawValue: NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue).rawValue): Constants.nicknameColorInMessageNo2()
            ]
            break;
        case 3:
            nicknameAttribute = [
                NSAttributedStringKey(rawValue: NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue).rawValue): Constants.nicknameFontInMessage(),
                NSAttributedStringKey(rawValue: NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue).rawValue): Constants.nicknameColorInMessageNo3()
            ]
            break;
        case 4:
            nicknameAttribute = [
                NSAttributedStringKey(rawValue: NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue).rawValue): Constants.nicknameFontInMessage(),
                NSAttributedStringKey(rawValue: NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue).rawValue): Constants.nicknameColorInMessageNo4()
            ]
            break;
        default:
            nicknameAttribute = [
                NSAttributedStringKey(rawValue: NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue).rawValue): Constants.nicknameFontInMessage(),
                NSAttributedStringKey(rawValue: NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue).rawValue): Constants.nicknameColorInMessageNo0()
            ]
            break;
        }
        
        let messageAttribute = [
            NSAttributedStringKey.font: Constants.messageFont()
        ]
     //nameLabel.text = self.message.sender?.nickname
        nameLabel.textColor = UIColor.white
       // let nickname = self.message.sender?.nickname
        let message = self.message.message
        
        var fullMessage: NSMutableAttributedString? = nil
        if self.displayNickname == true {
            //fullMessage = NSMutableAttributedString.init(string: NSString(format: "%@\n%@", message!) as String)
            fullMessage = NSMutableAttributedString.init(string: message!)
            fullMessage?.addAttributes(messageAttribute, range: NSMakeRange(0, (message?.utf16.count)!))
            profileImageView?.imageFromServerURL(urlString:(self.message.sender?.profileUrl)!,placeHolder:UIImage.init(named:"userplaceholder")!)

            //fullMessage?.addAttributes(nicknameAttribute, range: NSMakeRange(0, (nickname?.utf16.count)!))
           // fullMessage?.addAttributes(messageAttribute, range: NSMakeRange((nickname?.utf16.count)! + 1, (message?.utf16.count)!))
        }
        else {
              profileImageView?.imageFromServerURL(urlString:(self.message.sender?.profileUrl)!,placeHolder:UIImage.init(named:"userplaceholder")!)
            fullMessage = NSMutableAttributedString.init(string: message!)
            fullMessage?.addAttributes(messageAttribute, range: NSMakeRange(0, (message?.utf16.count)!))
        }
        
        return fullMessage!
    }
    
    func getHeightOfViewCell() -> CGFloat {
        let fullMessage = self.buildMessage()
        
        var fullMessageSize: CGSize
  
        let framesetter = CTFramesetterCreateWithAttributedString(fullMessage)
        /*
        let test = (self.profileImageLeftMargin.constant + self.profileImageWidth.constant + self.messageContainerLeftMargin.constant + self.messageContainerLeftPadding.constant + self.messageContainerRightPadding.constant + self.messageDateLabelLeftMargin.constant + self.messageDateLabelWidth.constant + self.messageDateLabelRightMargin.constant)
        */
        let messageLabelMaxWidth = (UIScreen.main.bounds.size.width - 100.0)
           
        fullMessageSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0,length: 0), nil, CGSize(width: messageLabelMaxWidth, height: CGFloat(LONG_LONG_MAX)), nil)

        let cellHeight = self.dateSeperatorViewTopMargin.constant + self.dateSeperatorViewHeight.constant + self.dateSeperatorViewBottomMargin.constant + self.messageContainerTopPadding.constant + fullMessageSize.height + self.messageContainerBottomPadding.constant
//        fullMessageSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0,length: 0), nil, CGSize(width: messageLabelMaxWidth, height: CGFloat(LONG_LONG_MAX)), nil)
//
//        let cellHeight = self.dateContainerTopMargin.constant + self.dateContainerHeight.constant + self.dateContainerBottomMargin.constant + self.messageContainerTopPadding.constant + fullMessageSize.height + self.messageContainerBottomPadding.constant
//
        return cellHeight
    }
    
    // MARK: TTTAttributedLabelDelegate
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.openURL(url)
    }
}
