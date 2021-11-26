//
//  User.swift
//  Live
//
//  Created by ITPATH on 4/5/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import ZendeskSDK
import ZendeskCoreSDK

enum UserType:String,Codable{
    case traveller
    case guide
}

class User: NSObject,Codable {
    
    fileprivate let kUserId = "UserId"
    fileprivate let kEmail = "Email"
    fileprivate let kMessage = "Message"
    fileprivate let kFirstName = "FirstName"
    fileprivate let kLastName = "LastName"
    fileprivate let kLocationId = "LocationId"
    fileprivate let kLanguageId = "LanguageId"
    fileprivate let kImage = "Image"
    fileprivate let kRoleId = "RoleId"
    fileprivate let kRole = "Role"
    fileprivate let kCountryId = "CountryId"
    fileprivate let kUserCity = "City"
    fileprivate let kUserCountry = "Country"
    fileprivate let kAppLanguageId = "AppLanguageId"
    fileprivate let kISUserBlock = "IsBlock"
    fileprivate let kGuideRequestStatus = "GuideRequestStatus"
    fileprivate let kGuideProvision = "Provision"
    
    var userAccessToken:String = ""
    var userID:String = ""
    var userEmail:String = ""
    var userMessage:String = ""
    var userFirstName:String = ""
    var userLastName:String = ""
    var userLocationID:String = ""
    var userLanguageID:String = ""
    var userImageURL:String = ""
    var userRoleID:String = ""
    var role:String = ""
    var settingsMenuUserRole = ""
    var userDefaultRole: String = ""
    var userLanguage: String = "1"
    var userRole:String{
        get{
            return role
        }
        set{
            role = newValue
            self.userTypeUpdate()
        }
    }
    var isUserRemember:Bool = true
    var isUserCurrentLocation:Bool = false
    var userPassword:String = ""
    var userCountryID:String = ""
    var userCity:String = ""
    var userCountry:String = ""
    var isUserBlock:Bool = false
    var guideRequestStatus: String = ""
    var userCurrentCityID:String = ""
    var userCurrentCountryID:String = ""
    var userCurrentCity:String = ""
    var userCurrentCountry:String = ""
    var userType:UserType = .traveller
    var userProvision:String = ""
    var isFaceBookLogIn:Bool = false
    var isBookingHintShown:Bool = false
    
    func userTypeUpdate(){
        if self.userRole.compareCaseInsensitive(str:"User"){
            self.userType = .traveller
        }else if self.userRole.compareCaseInsensitive(str:"Guide"){
            self.userType = .guide
        }
    }
    init(accesToken:String,userDetail:[String:Any],isRemember:Bool,password:String){
        super.init()
        self.userAccessToken = "\(accesToken)"
        self.userPassword = "\(password)"
        self.isUserRemember = isRemember
        
        if let _ = userDetail[kUserId]{
            self.userID = "\(userDetail[kUserId]!)"
        }
        if let _ = userDetail[kEmail]{
            self.userEmail = "\(userDetail[kEmail]!)"
        }
        if let _ = userDetail[kMessage]{
            self.userMessage = "\(userDetail[kMessage]!)"
        }
        if let _ = userDetail[kFirstName]{
            self.userFirstName = "\(userDetail[kFirstName]!)"
        }
        if let _ = userDetail[kLastName]{
            self.userLastName = "\(userDetail[kLastName]!)"
        }
        if let _ = userDetail[kLocationId]{
            self.userLocationID = "\(userDetail[kLocationId]!)"
        }
        if let _ = userDetail[kLocationId]{
            self.userCurrentCityID = "\(userDetail[kLocationId]!)"
        }
        if let _ = userDetail[kLanguageId]{
            self.userLanguageID = "\(userDetail[kLanguageId]!)"
        }
        if let image = userDetail[kImage],!(image is NSNull){
            self.userImageURL = "\(userDetail[kImage]!)"
        }
        if let _ = userDetail[kRoleId]{
            self.userRoleID = "\(userDetail[kRoleId]!)"
        }
        if let _ = userDetail[kRole]{
            self.userRole = "\(userDetail[kRole]!)"
        }
        if let _ = userDetail[kCountryId]{
            self.userCountryID = "\(userDetail[kCountryId]!)"
        }
        if let _ = userDetail[kCountryId]{
            self.userCurrentCountryID = "\(userDetail[kCountryId]!)"
        }
        if let _ = userDetail[kGuideRequestStatus]{
            self.guideRequestStatus = "\(userDetail[kGuideRequestStatus]!)"
        }
        if let _ = userDetail[kUserCity]{
            self.userCity = "\(userDetail[kUserCity]!)"
        }
        if let _ = userDetail[kUserCity]{
            self.userCurrentCity = "\(userDetail[kUserCity]!)"
        }
        if let _ = userDetail[kUserCountry]{
            self.userCountry = "\(userDetail[kUserCountry]!)"
        }
        if let _ = userDetail[kUserCountry]{
            self.userCurrentCountry = "\(userDetail[kUserCountry]!)"
        }
        if let _ = userDetail[kAppLanguageId] {
            self.userLanguage = "\(userDetail[kAppLanguageId]!)"
        }
        if let strProvision = userDetail[kGuideProvision],!(strProvision is NSNull) {
            self.userProvision = "\(strProvision)"
        }
        if let isBlock = userDetail[kISUserBlock],!(isBlock is NSNull){
            self.isUserBlock = Bool.init("\(isBlock)")
        }
        let identity = Identity.createAnonymous(name: "\(self.userFirstName) \(self.userLastName)", email: "\(self.userEmail)")
        Zendesk.instance?.setIdentity(identity)
        Support.initialize(withZendesk: Zendesk.instance)
    }
}
extension User{
    static var isUserLoggedIn:Bool{
        if let userdata  = kUserDefault.value(forKey: kUserDetail) as? Data{
            return self.isValidUserData(data: userdata)
        }else{
          return false
        }
    }
    func setUserDataToUserDefault(){
        do{
            let userData = try JSONEncoder().encode(self)
            kUserDefault.setValue(userData, forKey:kUserDetail)
            kUserDefault.synchronize()
        }catch{
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: kCommonError)
            }
        }
    }
    static func isValidUserData(data:Data)->Bool{
        do {
            let _ = try JSONDecoder().decode(User.self, from: data)
            return true
        }catch{
            return false
        }
    }
    static func getUserFromUserDefault() -> User?{
        if let userData = kUserDefault.value(forKey: kUserDetail) as? Data{
            do {
                let user:User = try JSONDecoder().decode(User.self, from: userData)
                return user
            }catch{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: kCommonError)
                }
                return nil
            }
        }
        DispatchQueue.main.async {
            //ShowToast.show(toatMessage: kCommonError)
        }
        return nil
    }
    static func removeUserFromUserDefault(){
        kUserDefault.removeObject(forKey:kUserDetail)
    }
    
}
