//
//  APIRequestClient.swift
//  Live
//
//  Created by ITPATH on 4/4/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import Alamofire

let kBaseURL = "http://staging.live.stockholmapplab.com/api/" //"https://app.live-privateguide.com/api/"
/*""//"http://staging1.live.stockholmapplab.com/api/"//"http://1.22.229.11:8112/api/"//"http://staging.live.stockholmapplab.com/api/""""http://prod.live.stockholmapplab.com/api/"""*/
//
let kLogInString = "users/login"
let kFacebookLogIn = "auth/facebook"
let kForgotpassword = "users/update/forgotpassword"
let kRecoveryCode = "users/native/recovery"
let kResetPassword = "users/native/recovery/resetpassword"
let kSignUp = "users/register"
let kCountriesExperience = "base/native/countries/experience" //Get Counties which has experience
let kWhereToNextSearch = "base/native/whereto/freesearch"
let kCityLocations = "base/native/locations/" //Get All cities based on country id(append)
let kInstantExperience = "experience/native/locations/" //Append 1/instantexperiences 10 default pagesize and 0 default page index
let kBestRatedExperience = "experience/native/locations/" // Append 1/bestreview 10 default pagesize and 0 default page index
let kExploreCollection = "experience/native/collection"
let kTopRatedGuides = "guides/native/location/" // append locationid 1/toprated"
let kAllExperience = "experience/native/locations/"// append location1/allexperiences"
let kPendingBookingCount = "users/" //append userID 1/pendingbooking
let kUserExperience = "experience/native/users/" //append (userID)/('future','wishlist','past')?pagesize=10&pageindex=0
let kGuideTours = "experience/native/guides/"    //append (userID)/mytours?pagesize=10&pageindex=0"
let kDeleteExperience = "experience/"  //append ExperieceID 1/native/locations/2(locationID)
let kBecomGuideCountries = "base/native/country"
let kUploadImage = "amazons3/native/experience/image/upload/image"
let kUploadVideo = "amazons3/native/experience/video/upload/video"
let kAllLanguage = "base/native/languages"
let kAllCurrency = "base/native/stripeallowcurrency"
let kAllLocation = "base/native/locations"
let kGetExperience = "experience/native/users/" //Get Experience NameP
let kGetPendingOtherChat = "experience/native/users/" // GetPending Other ChatP
let kGetUserType = "users/native/usertype" //Get UserTypeP
let kAddNewExperience = "experience/native/save" //Add New Experience
let kIsValidExperienceTime = "experience/native/booking/" //Get uppeend 22/bookingtime
let kExperienceBookingCancelWithOutRefund = "experience/native/bookings/cancel"
let kExperienceBookingCancelWithRefund = "experience/native/bookingcancel"
let kExperiencePendingSchedule = "experience/native/guide/"
let kGuideRequest = "travellers/native/guiderequest"
let kGuideUploadImage = "amazons3/native/guide/image/upload/image"
let kGuideBadgeUploadImage = "amazons3/native/guide/badgeimage/upload/image"
let kBecomeGuide = "travellers/native/becomeguide"
let kInquiry = "users/native/inquiry"
let kGetLatestBooking = "experience/native/latestBooking"
let kExperienceBookingWithOutPayment = "users/native/bookingwithoutpayment"
let kTravelerPendingBooking = "experience/native/users/"
let kGETOrganizationList = "experience/native/csrorganisations"
let kSaveOrganization = "experience/native/csrdetails"

class APIRequestClient: NSObject {
    
    enum RequestType {
        case POST
        case GET
        case PUT
        case DELETE
        case PATCH
        case OPTIONS
    }
    
    static let shared:APIRequestClient = APIRequestClient()
    func cancelAllAPIRequest(json:Any?){
        
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
        if let url  = URL.init(string:kBaseURL){
            let task:URLSessionDataTask = URLSession.shared.dataTask(with:url)
            task.cancel()
        }
        if let _ = json{
            if let arrayFail = json as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                    ShowToast.show(toatMessage:"invalid access token")
                }
            }
        }
        if let _ = json{
            DispatchQueue.main.async {
                if let appDel = UIApplication.shared.delegate as? AppDelegate ,let navigation = appDel.window?.rootViewController as? UINavigationController{
                    kUserDefault.removeObject(forKey: "isLocationPushToHome")
                    User.removeUserFromUserDefault()
                    kUserDefault.removeObject(forKey: kExperienceDetail)
                    kUserDefault.synchronize()
                    navigation.popToRootViewController(animated: false)
                }
            }
        }
    }
    //Post LogIn API
    func sendLogInRequest(requestType:RequestType,queryString:String?,parameter:[String:AnyObject]?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        } else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
        if let params = parameter{
            do{
                let parameterData = try JSONSerialization.data(withJSONObject:params, options:.prettyPrinted)
                request.httpBody = parameterData
            }catch{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                //fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        (httpStatus.statusCode == 200) ? success(json):fail(json)
                    }
                    catch{
                        //ShowToast.show(toatMessage: kCommonError)
                        //fail(["error":kCommonError])
                    }
            }else{
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    // GET ExperienceP
    func getExperience(requestType:RequestType,queryString:String?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        } else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            request.setValue("Bearer \(currentUser.userAccessToken)", forHTTPHeaderField: "Authorization")
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    (httpStatus.statusCode == 200) ? success(json): (httpStatus.statusCode == 401) ? self.cancelAllAPIRequest(json: json):fail(json)

                }
                catch{
                    ShowToast.show(toatMessage: kCommonError)
                    fail(["error":kCommonError])
                }
            }else{
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    //Post Facebook LogIn
    func sendFacebookLogInAPI(requestType:RequestType,queryString:String?,parameter:[String:AnyObject]?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        } else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
        if let params = parameter{
            do{
                let parameterData = try JSONSerialization.data(withJSONObject:params, options:.prettyPrinted)
                request.httpBody = parameterData
            }catch{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    (httpStatus.statusCode == 200) ? success(json):fail(json)

                }
                catch{
                    ShowToast.show(toatMessage: kCommonError)
                    fail(["error":kCommonError])
                }
            }else{
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    //Patch Forgotpassword
    func forgotPasswordRequest(requestType:RequestType,queryString:String?,parameter:[String:AnyObject]?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        } else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
        if let params = parameter{
            do{
                let parameterData = try JSONSerialization.data(withJSONObject:params, options:.prettyPrinted)
                request.httpBody = parameterData
            }catch{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    (httpStatus.statusCode == 200) ? success(json): (httpStatus.statusCode == 401) ? self.cancelAllAPIRequest(json: json):fail(json)

                }
                catch{
                    ShowToast.show(toatMessage: kCommonError)
                    fail(["error":kCommonError])
                }
            }else{
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    //Post SignUp Request
    func sendSignUpRequest(requestType:RequestType,queryString:String?,parameter:[String:AnyObject]?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        } else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
        if let params = parameter{
            do{
                let parameterData = try JSONSerialization.data(withJSONObject:params, options:.prettyPrinted)
                request.httpBody = parameterData
            }catch{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    (httpStatus.statusCode == 200) ? success(json):fail(json)

                }
                catch{
                    ShowToast.show(toatMessage: kCommonError)
                    fail(["error":kCommonError])
                }
            }else{
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    //GET Countries with atleast one experiences
    func getCoutriesWithExperience(requestType:RequestType,queryString:String?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        } else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                 ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                 fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    (httpStatus.statusCode == 200) ? success(json): (httpStatus.statusCode == 401) ? self.cancelAllAPIRequest(json: json):fail(json)

                }
                catch{
                    //ShowToast.show(toatMessage: kCommonError)
                    fail(["error":kCommonError])
                }
            }else{
                //ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    //GET Cities on countryid
    func getCitiesOnCountyID(requestType:RequestType,queryString:String?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        } else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    (httpStatus.statusCode == 200) ? success(json): (httpStatus.statusCode == 401) ? self.cancelAllAPIRequest(json: json):fail(json)

                }
                catch{
                    ShowToast.show(toatMessage: kCommonError)
                    fail(["error":kCommonError])
                }
            }else{
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    //Send Request
    func sendRequest(requestType:RequestType,queryString:String?,parameter:[String:AnyObject]?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
//        DispatchQueue.main.async {
//            ShowToast.show(toatMessage: "\(urlString)")
//        }
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        } else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            request.setValue("Bearer \(currentUser.userAccessToken)", forHTTPHeaderField: "Authorization")
            //request.setValue("Bearer 2a34e935-c3a6-4ed3-8c83-0c86ae5b38a9", forHTTPHeaderField: "Authorization")
        }
        if let params = parameter{
            do{
                let parameterData = try JSONSerialization.data(withJSONObject:params, options:.prettyPrinted)
                request.httpBody = parameterData
            }catch{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    (httpStatus.statusCode == 200) ? success(json): (httpStatus.statusCode == 401) ? self.cancelAllAPIRequest(json: json):fail(json)

                }
                catch{
                   ShowToast.show(toatMessage: kCommonError)
                    
                    fail(["error":kCommonError])
                }
            }else{
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    //Add New Experience
    func addNewExperience(requestType:RequestType,queryString:String?,parameter:[String:AnyObject]?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        }else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            request.setValue("Bearer \(currentUser.userAccessToken)", forHTTPHeaderField: "Authorization")
        }
        if let params = parameter{
            do{
                let parameterData = try JSONSerialization.data(withJSONObject:params, options:.prettyPrinted)
                request.httpBody = parameterData
            }catch{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    (httpStatus.statusCode == 200) ? success(json): (httpStatus.statusCode == 401) ? self.cancelAllAPIRequest(json: json):fail(json)

                }
                catch{
                    ShowToast.show(toatMessage: kCommonError)
                    fail(["error":kCommonError])
                }
            }else{
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    //Upload Images
    func uploadImage(requestType:RequestType,queryString:String?,parameter:[String:AnyObject],imageData:Data,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
           // fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
     
        
         //let URL = "http://staging.live.stockholmapplab.com/api/amazons3/native/experience/image/upload/image"
         var headers: HTTPHeaders = ["Content-type": "multipart/form-data"]
         var strAccessToken:String = ""
         if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            strAccessToken = "Bearer \(currentUser.userAccessToken)"
         }
            if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
                headers = ["Content-type": "multipart/form-data","LanguageId": "\(languageId)","Authorization":"\(strAccessToken)"]
            }else{
                headers = ["Content-type": "multipart/form-data","LanguageId": "1","Authorization":"\(strAccessToken)"]
            }
         Alamofire.upload(multipartFormData: { (multipartFormData) in
            
         for (key, value) in parameter {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
         }
         
         // if let data = imageData{
         multipartFormData.append(imageData, withName: "image", fileName: "image.png", mimeType: "image/png")
         //}
         
         }, usingThreshold: UInt64.init(), to: urlString, method:HTTPMethod(rawValue:"\(requestType)")!, headers: headers) { (result) in
           
         switch result{
         case .success(let upload, _, _):
         upload.responseJSON { response in
            
         if let objResponse = response.response,objResponse.statusCode == 200{
            if let successResponse = response.value as? [String:Any]{
                success(successResponse)
            }
         }else if let objResponse = response.response,objResponse.statusCode == 401{
            self.cancelAllAPIRequest(json: response.value)
         }else if let objResponse = response.response,objResponse.statusCode == 400{
            if let failResponse = response.value as? [String:Any]{
                fail(failResponse)
            }
         }else if let error = response.error{
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "\(error.localizedDescription)")
                fail(["error":"\(error.localizedDescription)"])
            }
         }else{
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "\(kCommonError)")
                fail(["error":"\(kCommonError)"])
            }
           }
         }
         case .failure(let error):
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "\(error.localizedDescription)")
                fail(["error":"\(error.localizedDescription)"])
            }
         }
         }
    }
    //Upload Video
    func uploadVideo(requestType:RequestType,queryString:String?,parameter:[String:AnyObject],videoData:Data,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        
        
        //let URL = "http://staging.live.stockholmapplab.com/api/amazons3/native/experience/image/upload/image"
        var headers: HTTPHeaders = ["Content-type": "multipart/form-data"]
        var strAccessToken:String = ""
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            strAccessToken = "Bearer \(currentUser.userAccessToken)"
        }
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            headers = ["Content-type": "multipart/form-data","LanguageId": "\(languageId)","Authorization":"\(strAccessToken)"]
        }else{
            headers = ["Content-type": "multipart/form-data","LanguageId": "1","Authorization":"\(strAccessToken)"]
        }
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            for (key, value) in parameter {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            // if let data = imageData{
            multipartFormData.append(videoData, withName: "video", fileName: "video.mp4", mimeType: "video/mp4")
            //}
            
        }, usingThreshold: UInt64.init(), to: urlString, method: .post, headers: headers) { (result) in
            
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let objResponse = response.response,objResponse.statusCode == 200{
                        if let successResponse = response.value as? [String:Any]{
                            success(successResponse)
                        }
                    }else if let objResponse = response.response,objResponse.statusCode == 401{
                        self.cancelAllAPIRequest(json: response.value)
                    }else if let error = response.error{
                        DispatchQueue.main.async {
                            ShowToast.show(toatMessage: "\(error.localizedDescription)")
                            fail(["error":"\(error.localizedDescription)"])
                        }
                    }else{
                        DispatchQueue.main.async {
                            ShowToast.show(toatMessage: "\(kCommonError)")
                            fail(["error":"\(kCommonError)"])
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    
                    ShowToast.show(toatMessage: "\(error.localizedDescription)")
                    fail(["error":"\(error.localizedDescription)"])
                }
            }
        }
    }
}
