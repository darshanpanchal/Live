//
//  GroupChannelListTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/10/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
//import AlamofireImage

class GroupChannelListTableViewCell: UITableViewCell {
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadMessageCountLabel: UILabel!
    @IBOutlet weak var coverImageContainerForOne: UIView!
    @IBOutlet weak var coverImageView11: ImageViewForURL!
    
    @IBOutlet weak var coverImageContainerForTwo: UIView!
    @IBOutlet weak var coverImageView21: UIImageView!
    @IBOutlet weak var coverImageView22: UIImageView!
    
    @IBOutlet weak var coverImageContainerForThree: UIView!
    @IBOutlet weak var coverImageView31: UIImageView!
    @IBOutlet weak var coverImageView32: UIImageView!
    @IBOutlet weak var coverImageView33: UIImageView!
    
    @IBOutlet weak var coverImageContainerForFour: UIView!
    @IBOutlet weak var coverImageView41: UIImageView!
    @IBOutlet weak var coverImageView42: UIImageView!
    @IBOutlet weak var coverImageView43: UIImageView!
    @IBOutlet weak var coverImageView44: UIImageView!
    
    @IBOutlet weak var unreadMessageCountContainerView: UIView!
    @IBOutlet weak var typingImageView: UIImageView!
    @IBOutlet weak var typingLabel: UILabel!
   
    private var channel: SBDGroupChannel!

    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            //self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.channelNameLabel.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.channelNameLabel.adjustsFontForContentSizeCategory = true
        self.channelNameLabel.adjustsFontSizeToFitWidth = true
     
        self.lastMessageLabel.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lastMessageLabel.adjustsFontForContentSizeCategory = true
        self.lastMessageLabel.adjustsFontSizeToFitWidth = true
        
        self.dateLabel.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.dateLabel.adjustsFontForContentSizeCategory = true
        self.dateLabel.adjustsFontSizeToFitWidth = true
        
        
        self.typingLabel.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.typingLabel.adjustsFontForContentSizeCategory = true
        self.typingLabel.adjustsFontSizeToFitWidth = true
    }
    func startTypingAnimation() {
        if self.channel == nil {
            return
        }
        
        // Typing indicator
        if self.channel.isTyping() == true {
            var typingLabelText = ""
            if self.channel.getTypingMembers()?.count == 1 {
                typingLabelText = String(format: Bundle.sbLocalizedStringForKey(key: "TypingMessageSingular"), (self.channel.getTypingMembers()?[0].nickname)!)
            }
            else {
                typingLabelText = Bundle.sbLocalizedStringForKey(key: "TypingMessagePlural")
            }
            
            self.typingLabel.text = typingLabelText
            
            if self.typingImageView.isAnimating == false {
                var typingImages: [UIImage] = []
                for i in 1...50 {
                    let typingImageFrameName = String(format: "%02d", i)
                    typingImages.append(UIImage(named: typingImageFrameName)!)
                }
                self.typingImageView.animationImages = typingImages
                self.typingImageView.animationDuration = 1.5
                DispatchQueue.main.async {
                    self.typingImageView.startAnimating()
                }
            }
            self.lastMessageLabel.isHidden = true
            self.typingImageView.isHidden = false
            self.typingLabel.isHidden = false
        }
        else {
            if self.typingImageView.isAnimating == true {
                DispatchQueue.main.async {
                    self.typingImageView.stopAnimating()
                }
            }
            self.lastMessageLabel.isHidden = false
            self.typingImageView.isHidden = true
            self.typingLabel.isHidden = false
            if self.channel.lastMessage is SBDUserMessage {
                let lastMessage = (self.channel.lastMessage as! SBDUserMessage)
                typingLabel.text = lastMessage.sender?.nickname
            }
        }
    }
    
    func setModel(aChannel: SBDGroupChannel) {
        self.channel = aChannel
        //   self.memberCountLabel.text = String(format: "%ld", self.channel.memberCount)
        self.typingImageView.isHidden = true
        self.typingLabel.isHidden = true
        unreadMessageCountLabel.layer.masksToBounds = true
        unreadMessageCountLabel.layer.cornerRadius = 12

        var memberNames: [String] = []
        if self.channel.memberCount == 1 {
            let member = self.channel.members?[0] as! SBDUser
            
        }
        else if self.channel.memberCount == 2 {
           
            for member in self.channel.members! as NSArray as! [SBDUser] {
                if member.userId == SBDMain.getCurrentUser()?.userId {
                    continue
                }
                memberNames.append(member.nickname!)
            }
        }
        
//
//        let user = User.getUserFromUserDefault()
//        let img = user?.userImageURL
//        coverImageView11.imageFromServerURL(urlString: img!)
        if let _ = self.channel.coverUrl {
            print(self.channel.coverUrl!)
            DispatchQueue.main.async {
                self.coverImageView11.imageFromServerURL(urlString: self.channel.coverUrl!)
            }
        }
        channelNameLabel.text = channel.name//memberNames.joined(separator: ", ")
        var lastMessageTimestamp: Int64 = 0
        
        if self.channel.lastMessage is SBDUserMessage {
            let lastMessage = (self.channel.lastMessage as! SBDUserMessage)
            self.lastMessageLabel.text = lastMessage.message
            lastMessageTimestamp = Int64(lastMessage.createdAt)
           
            typingLabel.isHidden = false
            typingLabel.textAlignment = .left
            typingLabel.text = lastMessage.sender?.nickname
            lastMessageTimestamp = Int64(lastMessage.createdAt)
        }
        else if self.channel.lastMessage is SBDAdminMessage {
            let lastMessage = self.channel.lastMessage as! SBDAdminMessage
            self.lastMessageLabel.text = lastMessage.message
            lastMessageTimestamp = Int64(lastMessage.createdAt)
        }
        else {
            self.lastMessageLabel.text = ""
            lastMessageTimestamp = Int64(self.channel.createdAt)
        }
        
        // Last message date time
        let lastMessageDateFormatter = DateFormatter()
        
        var lastMessageDate: Date?
        if String(format: "%lld", lastMessageTimestamp).characters.count == 10 {
            lastMessageDate = Date.init(timeIntervalSince1970: Double(lastMessageTimestamp))
        }
        else {
            lastMessageDate = Date.init(timeIntervalSince1970: Double(lastMessageTimestamp) / 1000.0)
        }
        let currDate = Date()
        
        let lastMessageDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: lastMessageDate! as Date)
        let currDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: currDate as Date)
        
        if lastMessageDateComponents.year != currDateComponents.year || lastMessageDateComponents.month != currDateComponents.month || lastMessageDateComponents.day != currDateComponents.day {
            lastMessageDateFormatter.dateStyle = DateFormatter.Style.short
            lastMessageDateFormatter.timeStyle = DateFormatter.Style.none
            self.dateLabel.text = lastMessageDateFormatter.string(from: lastMessageDate!)
        }
        else {
            lastMessageDateFormatter.dateStyle = DateFormatter.Style.none
            lastMessageDateFormatter.timeStyle = DateFormatter.Style.short
            self.dateLabel.text = lastMessageDateFormatter.string(from: lastMessageDate!)
        }
        
        self.unreadMessageCountContainerView.isHidden = false
        if self.channel.unreadMessageCount == 0 {
            self.unreadMessageCountContainerView.isHidden = true
        }
        else if self.channel.unreadMessageCount <= 9 {
            self.unreadMessageCountLabel.text = String(format: "%ld", self.channel.unreadMessageCount)
        }
        else {
            self.unreadMessageCountLabel.text = "9+"
        }
    }
}
