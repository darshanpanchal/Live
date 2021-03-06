//
//  Utils.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/6/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
//import CommonCrypto

class Utils: NSObject {
    static func imageFromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    static func generateNavigationTitle(mainTitle: String, subTitle: String?) -> NSAttributedString? {
        var mainTitleAttribute = [NSAttributedStringKey : Any]()
        var subTitleAttribute = [NSAttributedStringKey : Any]()
        
        if subTitle == nil || subTitle?.count == 0 {
            mainTitleAttribute = [
                NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): Constants.navigationBarTitleFont(),
              //  NSAttributedStringKey.foregroundColorNSAttributedStringKey.foregroundColor.rawValue: UIColor.black
            ]
        }
        else {
            mainTitleAttribute = [
                NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): Constants.navigationBarTitleFont(),
                NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.black
            ]
            
            subTitleAttribute = [
                NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): Constants.navigationBarSubTitleFont(),
                NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): Constants.navigationBarSubTitleColor()
            ]
        }
        
        var fullTitle: NSMutableAttributedString?
        if subTitle == nil || subTitle?.count == 0 {
            fullTitle = NSMutableAttributedString(string: mainTitle)
            fullTitle?.addAttributes(mainTitleAttribute, range: NSMakeRange(0, mainTitle.count))
        }
        else {
            fullTitle = NSMutableAttributedString(string: NSString(format: "%@\n%@", mainTitle, subTitle!) as String)
            
            fullTitle?.addAttributes(mainTitleAttribute, range: NSMakeRange(0, mainTitle.count))
            fullTitle?.addAttributes(subTitleAttribute, range: NSMakeRange(mainTitle.count + 1, (subTitle?.count)!))
        }
        
        return fullTitle
    }
    
    static func dumpMessages(messages: [SBDBaseMessage], resendableMessages: [String: SBDBaseMessage], resendableFileData: [String: [String: Any]], preSendMessages: [String: SBDBaseMessage], channelUrl: String) {
        var startIndex = 0
        var from = 0
        
        if messages.count == 0 {
            return
        }
        
        if messages.count > 100 {
            from = messages.count - 100
        }
        
        var serializedMessages: [String] = []
        for startIndex in from..<messages.count {
            var requestId: String?
            if messages[startIndex] is SBDUserMessage {
                requestId = (messages[startIndex] as! SBDUserMessage).requestId
            }
            else if messages[startIndex] is SBDFileMessage {
                requestId = (messages[startIndex] as! SBDFileMessage).requestId
            }
            
            if requestId != nil && (requestId?.count)! > 0 {
                if resendableMessages[requestId!] != nil {
                    continue
                }
                
                if preSendMessages[requestId!] != nil {
                    continue
                }
                
                if resendableFileData[requestId!] != nil {
                    continue
                }
            }
            
            let messageData = messages[startIndex].serialize()
            let messageString = messageData?.base64EncodedString()
            serializedMessages.append(messageString!)
        }
        
        let dumpedMessages = serializedMessages.joined(separator: "\n")
        let dumpedMessagesHash = Utils.sha256(string: dumpedMessages)
        
        // Save messages to temp file.
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        let appIdDirectory = documentsDirectory.appendingPathComponent(SBDMain.getApplicationId()!) as NSString
        
        let uniqueTempFileNamePrefix = UUID().uuidString
        let tempMessageDumpFileName = String(format: "%@.data", uniqueTempFileNamePrefix)
        let tempMessageHashFileName = String(format: "%@.hash", uniqueTempFileNamePrefix)
        
        let tempMessageDumpFilePath = appIdDirectory.appendingPathComponent(tempMessageDumpFileName)
        let tempMessageHashFilePath = appIdDirectory.appendingPathComponent(tempMessageHashFileName)
        
        if FileManager.default.fileExists(atPath: appIdDirectory as String) == false {
            do {
                try FileManager.default.createDirectory(atPath: appIdDirectory as String, withIntermediateDirectories: false, attributes: nil)
            }
            catch {
                return
            }
        }
        print(channelUrl)
        if let id = SBDMain.getCurrentUser()?.userId.urlencoding(){
            
            let messageFileNamePrefix = Utils.sha256(string: String(format: "%@_%@", (id), channelUrl))
            let messageDumpFileName = String(format: "%@.data", messageFileNamePrefix!)
            let messageHashFileName = String(format: "%@.hash", messageFileNamePrefix!)
            
            let messageDumpFilePath = appIdDirectory.appendingPathComponent(messageDumpFileName)
            let messageHashFilePath = appIdDirectory.appendingPathComponent(messageHashFileName)
            var previousHash: String?
            if FileManager.default.fileExists(atPath: messageDumpFilePath) == false {
                FileManager.default.createFile(atPath: messageDumpFilePath, contents: nil, attributes: nil)
            }
            
            if FileManager.default.fileExists(atPath: messageHashFilePath) == false {
                FileManager.default.createFile(atPath: messageHashFilePath, contents: nil, attributes: nil)
            }
            else {
                do {
                    try previousHash = String.init(contentsOfFile: messageHashFilePath)
                }
                catch {
                    return
                }
            }
            if previousHash == dumpedMessagesHash {
                return
            }
            
            // Write temp file.
            do {
                try dumpedMessages.write(toFile: tempMessageDumpFilePath, atomically: false, encoding: String.Encoding.utf8)
            }
            catch {
                return
            }
            
            do {
                try dumpedMessagesHash?.write(toFile: tempMessageHashFilePath, atomically: false, encoding: String.Encoding.utf8)
            }
            catch {
                return
            }
            
            // Move temp to real file.
            do {
                try FileManager.default.removeItem(atPath: messageDumpFilePath)
                try FileManager.default.moveItem(atPath: tempMessageDumpFilePath, toPath: messageDumpFilePath)
                
                try FileManager.default.removeItem(atPath: messageHashFilePath)
                try FileManager.default.moveItem(atPath: tempMessageHashFilePath, toPath: messageHashFilePath)
                
                try FileManager.default.removeItem(atPath: tempMessageDumpFilePath)
                try FileManager.default.removeItem(atPath: tempMessageHashFilePath)
                try FileManager.default.removeItem(atPath: messageDumpFilePath)
                try FileManager.default.removeItem(atPath: messageHashFilePath)
            }
            catch {
                return
            }
        }
        
        // Check hash
        
    }
    
    static func loadMessagesInChannel(channelUrl: String) -> [SBDBaseMessage] {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        let appIdDirectory = documentsDirectory.appendingPathComponent(SBDMain.getApplicationId()!) as NSString
    
         if let id = SBDMain.getCurrentUser()?.userId.urlencoding(){
            let messageFileNamePrefix = Utils.sha256(string: String(format: "%@_%@", (id), channelUrl))! as NSString
        let dumpFileName = String(format: "%@.data", messageFileNamePrefix) as NSString
        let dumpFilePath = appIdDirectory.appendingPathComponent(dumpFileName as String)
        
        if FileManager.default.fileExists(atPath: dumpFilePath) == false {
            return []
        }
        
        do {
            let messageDump = try String(contentsOfFile: dumpFilePath, encoding: String.Encoding.utf8)
            
            if messageDump.count > 0 {
                let loadMessages = messageDump.components(separatedBy: "\n")
                
                if loadMessages.count > 0 {
                    var messages: [SBDBaseMessage] = []
                    for msgString in loadMessages {
                        if  let msgData = NSData(base64Encoded: msgString, options: NSData.Base64DecodingOptions(rawValue: UInt(0))){
                            
                            if  let message = SBDBaseMessage.build(fromSerializedData: (msgData as Data)){
                                
                                messages.append(message)
                            }
                        }
                    }
                    
                    return messages
                }
            }
        }
        catch {
            return []
        }
        
        }
        return []
    }
    
    static func dumpChannels(channels: [SBDBaseChannel]) {
        // Serialize channels
        var startIndex = 0
        var from = 0
        
        if channels.count == 0 {
            return
        }
        
        if channels.count > 100 {
            from = channels.count - 100
        }
        
        var serializedChannels: [String] = []
        for startIndex in from..<channels.count {
            let channelData = channels[startIndex].serialize()
            let channelString = channelData?.base64EncodedString()
            serializedChannels.append(channelString!)
        }
        
        let dumpedChannels = serializedChannels.joined(separator: "\n")
        let dumpedChannelsHash = Utils.sha256(string: dumpedChannels)
        
        // Save channels to temp file.
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        let appIdDirectory = documentsDirectory.appendingPathComponent(SBDMain.getApplicationId()!) as NSString
        
        let uniqueTempFileNamePrefix = UUID().uuidString
        let tempChannelDumpFileName = String(format: "%@_channellist.data", uniqueTempFileNamePrefix)
        let tempChannelHashFileName = String(format: "%@_channellist.hash", uniqueTempFileNamePrefix)
        
        let tempChannelDumpFilePath = appIdDirectory.appendingPathComponent(tempChannelDumpFileName)
        let tempChannelHashFilePath = appIdDirectory.appendingPathComponent(tempChannelHashFileName)
        
        if FileManager.default.fileExists(atPath: appIdDirectory as String) == false {
            do {
                try FileManager.default.createDirectory(atPath: appIdDirectory as String, withIntermediateDirectories: false, attributes: nil)
            }
            catch {
                return
            }
        }
        if let id = SBDMain.getCurrentUser()?.userId.urlencoding(){
            let channelFileNamePrefix = Utils.sha256(string: String(format: "%@_channellist", (id)))
            let channelDumpFileName = String(format: "%@.data", channelFileNamePrefix!)
            let channelHashFileName = String(format: "%@.hash", channelFileNamePrefix!)
            let channelDumpFilePath = appIdDirectory.appendingPathComponent(channelDumpFileName)
            let channelHashFilePath = appIdDirectory.appendingPathComponent(channelHashFileName)
            var previousHash: String?
            if FileManager.default.fileExists(atPath: channelDumpFilePath) == false {
                FileManager.default.createFile(atPath: channelDumpFilePath, contents: nil, attributes: nil)
            }
            
            if FileManager.default.fileExists(atPath: channelHashFilePath) == false {
                FileManager.default.createFile(atPath: channelHashFilePath, contents: nil, attributes: nil)
            }
            else {
                do {
                    try previousHash = String.init(contentsOfFile: channelHashFilePath)
                }
                catch {
                    return
                }
            }
            
            if previousHash == dumpedChannelsHash {
                return
            }
            
            // Write temp file.
            do {
                try dumpedChannels.write(toFile: tempChannelDumpFilePath, atomically: false, encoding: String.Encoding.utf8)
                try dumpedChannelsHash?.write(toFile: tempChannelHashFilePath, atomically: false, encoding: String.Encoding.utf8)
            }
            catch {
                return
            }
            
            // Move temp to real file.
            do {
                try FileManager.default.removeItem(atPath: channelDumpFilePath)
                try FileManager.default.moveItem(atPath: tempChannelDumpFilePath, toPath: channelDumpFilePath)
                
                try FileManager.default.removeItem(atPath: channelHashFilePath)
                try FileManager.default.moveItem(atPath: tempChannelHashFilePath, toPath: channelHashFilePath)
                
                try FileManager.default.removeItem(atPath: tempChannelDumpFilePath)
                try FileManager.default.removeItem(atPath: tempChannelHashFilePath)
                try FileManager.default.removeItem(atPath: channelDumpFilePath)
                try FileManager.default.removeItem(atPath: channelHashFilePath)
            }
            catch {
                return
            }
        }
        
        // Check hash
    }
    
    static func loadGroupChannels() -> [SBDGroupChannel] {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        guard let _ = SBDMain.getCurrentUser() else {
            return []
        }
        if let id = SBDMain.getCurrentUser()?.userId.urlencoding() {
            let messageFileNamePrefix = Utils.sha256(string: String(format: "%@_channellist",id))! as NSString
            let dumpFileName = String(format: "%@.data", messageFileNamePrefix) as NSString
            let appIdDirectory = documentsDirectory.appendingPathComponent(SBDMain.getApplicationId()!) as NSString
            let dumpFilePath = appIdDirectory.appendingPathComponent(dumpFileName as String)
            
            if FileManager.default.fileExists(atPath: dumpFilePath) == false {
                return []
            }
            
            do {
                let channelDump = try String(contentsOfFile: dumpFilePath, encoding: String.Encoding.utf8)
                
                if channelDump.count > 0 {
                    let loadChannels = channelDump.components(separatedBy: "\n")
                    
                    if loadChannels.count > 0 {
                        var channels: [SBDGroupChannel] = []
                        for channelString in loadChannels {
                            let channelData = NSData(base64Encoded: channelString, options: NSData.Base64DecodingOptions(rawValue: UInt(0)))
                            let channel = SBDGroupChannel.build(fromSerializedData: channelData! as Data)
                            channels.append(channel!)
                        }
                        
                        return channels
                    }
                }
            }
            catch {
                return []
            }
        }
        
        return []
    }
    
    static func sha256(string: String) -> String? {
        var sha256hash: NSMutableString = NSMutableString()
        guard let messageData = string.data(using:String.Encoding.utf8) else { return nil }
        // var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        //  messageData.withUnsafeBytes {
       //     _ = CC_SHA256($0, CC_LONG(messageData.count), &hash)
//        }

       // for i in 0..<32 {
        //    sha256hash.appendFormat("%02x", hash[i])
       // }
        
        return (sha256hash as String)
    }
    
    static func findBestViewController(vc: UIViewController) -> UIViewController? {
        if vc.presentedViewController != nil {
            return Utils.findBestViewController(vc: vc.presentedViewController!)
        }
        else if vc.isKind(of: UISplitViewController.self) {
            let svc = vc as! UISplitViewController
            if svc.viewControllers.count > 0 {
                return Utils.findBestViewController(vc: svc.viewControllers.last!)
            }
            else {
                return vc
            }
        }
        else if vc.isKind(of: UINavigationController.self) {
            let svc = vc as! UINavigationController
            if svc.viewControllers.count > 0 {
                return Utils.findBestViewController(vc: svc.topViewController!)
            }
            else {
                return vc
            }
        }
        else if vc.isKind(of: UITabBarController.self) {
            let svc = vc as! UITabBarController
            if (svc.viewControllers?.count)! > 0 {
                return Utils.findBestViewController(vc: svc.selectedViewController!)
            }
            else {
                return vc
            }
        }
        else {
            return vc
        }
    }
}
