//
//  Experience.swift
//  Live
//
//  Created by ITPATH on 4/17/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//
import Foundation
import UIKit

enum ExperienceType:String{
    case standard
}
enum ExperienceEffort:String{
    case soft
    case moderate
    case hard
    case extreme
}
enum ExperiencePaymentGateWay:String, Codable{
    case stripe
    case braintree
    case both
    case none
}
class Experience:NSObject{
    //Update Model
    fileprivate let kExperienceMainImage = "MainImage"
    fileprivate let kLargeExperienceMainImage = "LargeMainImage"
    fileprivate let kSmallExperienceMainImage = "SmallMainImage"
    fileprivate let kExperienceID:String = "Id"
    fileprivate let kExperienceTitle:String = "Title"
    fileprivate let kExperienceDescription:String = "Description"
    fileprivate let kExperiencePricePerson:String = "PricePerson"
    fileprivate let kExperienceLocationId:String = "LocationId"
    fileprivate let kExperienceDuration:String = "Duration"
    fileprivate let kExperienceUserId:String = "UserId"
    fileprivate let kExperienceEffort:String = "Effort"
    fileprivate let kExperienceGroupSizeMin:String = "GroupSizeMin"
    fileprivate let kExperienceGroupSizeMax:String = "GroupSizeMax"
    fileprivate let kExperienceAddress:String = "Address"
    fileprivate let kExperienceLatitude:String = "Latitude"
    fileprivate let kExperienceLongitude:String = "Longitude"
    fileprivate let kExperienceAverageReview:String = "AverageReview"
    fileprivate let kExperienceInstant:String = "Instant"
    fileprivate let kExperienceAddressReference:String = "AddressReference"
    fileprivate let kExperienceAccessible:String = "Accessible"
    fileprivate let kExperienceFreeChildren:String = "FreeChildren"
    fileprivate let kExperiencePetFriendly:String = "PetFriendly"
    fileprivate let kExperienceFreeElderly:String = "FreeElderly"
    fileprivate let kExperienceIsActive:String = "IsActive"
    fileprivate let kExperienceCreatedDate:String = "CreatedDate"
    fileprivate let kExperienceModifiedDate:String = "ModifiedDate"
    fileprivate let kExperienceCurrency:String = "Currency"
    fileprivate let kExperiencelanguages:String = "Languages"
    fileprivate let kExperiencereviews:String = "Reviews"
    fileprivate let kExperienceimages:String = "Images"
    fileprivate let kExperienceoccurrences:String = "Occurrences"
    fileprivate let kExperiencecollections:String = "Collections"
    fileprivate let kLocation:String = "Location"
    fileprivate let kVideo:String = "Videos"
    fileprivate let kGuide = "Guide"
    fileprivate let kIsWished = "IsWished"
    fileprivate let kExperienceRatingReview:String = "Review"
    fileprivate let kTopExperienceIsWish = "IsWish"
    fileprivate let kTopExperiencePrice:String = "Price"
    fileprivate let kTopExperienceComment:String = "Comment"
    fileprivate let kExperienceBookingId:String = "BookingId"
    fileprivate let kExperienceGuideId:String = "GuideId"
    fileprivate let kExperienceUserName:String = "UserName"
    fileprivate let kExperienceIsPricePerPerson:String = "IsPricePerPerson"
    fileprivate let kExperienceIsGroupPrice:String = "IsGroupPrice"
    fileprivate let kExperienceGroupPrice:String = "GroupPrice"
    fileprivate let kExperiencePriceGroup:String = "PriceGroup"
    fileprivate let kExperienceComment:String = "Comment"
    fileprivate let kExperienceBlock:String = "IsBlock"
    fileprivate let kExperienceUserReview:String = "UserReview"
    fileprivate let kRatedReview:String = "Rated"
    fileprivate let kIsRated:String = "IsRated"
    fileprivate let kBookingDate:String = "BookingDate"
    fileprivate let kImage:String = "Image"
    fileprivate let kPaymentGatewayType:String = "PaymentGatewayType"
    fileprivate let kGuideName:String = "GuideName"
    fileprivate let kTime:String = "Time"
    fileprivate let kExperienceURL:String = "ExperienceUrl"
    fileprivate let kExperienceInvited:String = "IsInvited"
    fileprivate let kExeriencePricePerPersonHourly:String = "PricePersonHourly"
    fileprivate let kExerienceGroupPriceHourly:String = "GroupPriceHourly"
    fileprivate let kExperienceIshourly:String = "IsHourly"
    fileprivate let kExperienceBookingDuration:String = "BookingDuration"
    
    //Update
    var mainImage:String = ""
    var largemainImage:String = ""
    var smallmainImage:String = ""
    var id:String = ""
    var title:String = ""
    var discription:String = ""
    var priceperson:String = ""
    var groupPrice:String = ""
    var locationId:String = ""
    var duration:String = ""
    var userID:String = ""
    var efforValue:String = ""
    var effort:String{
        get{
            return efforValue
        }
        set{
            efforValue = newValue
            self.updateExperienceEffortType()
        }
    }
    var effortType:ExperienceEffort = .soft
    func updateExperienceEffortType(){
        if self.effort.compareCaseInsensitive(str:"Soft"){
            self.effortType = .soft
        }else if self.effort.compareCaseInsensitive(str:"Moderate"){
            self.effortType = .moderate
        }else if self.effort.compareCaseInsensitive(str:"Hard"){
            self.effortType = .hard
        }else if self.effort.compareCaseInsensitive(str:"Extreme"){
            self.effortType = .extreme
        }
    }
    var paymentGateWay:String = ""
    var paymentGATE:String{
        get{
         return paymentGateWay
        }
        set{
            paymentGateWay = newValue
            self.updateExperiencePaymentGateway()
        }
    }
    var paymentGateWayType:ExperiencePaymentGateWay = .stripe
    func updateExperiencePaymentGateway(){
        if self.paymentGATE.compareCaseInsensitive(str:"1"){
            self.paymentGateWayType = .stripe
        }else if self.paymentGATE.compareCaseInsensitive(str:"2"){
            self.paymentGateWayType = .braintree
        }else if self.paymentGATE.compareCaseInsensitive(str:"3"){
            self.paymentGateWayType = .both
        }else if self.paymentGATE.compareCaseInsensitive(str:"4"){
            self.paymentGateWayType = .none
        }
    }
    var groupSizeMin:String = ""
    var groupSizeMax:String = ""
    var address:String = ""
    var latitude:String = ""
    var longitude:String = ""
    var averageReview:String = "0"
    var instant:Bool = false
    var addressReference:String = ""
    var accessible:Bool = false
    var freechildren:Bool = false
    var petFriendly:Bool = false
    var freeElderly:Bool = false
    var isActive:Bool = false
    var isPricePerPerson:Bool = false
    var isGroupPrice:Bool = false
    var createdDate:String = ""
    var modifiedDate:String = ""
    var currency:String = ""
    var languages:[Language] = []
    var reviews:[Review] = []
    var images:[Images] = []
    var occurrences:[Occurrences] = []
    var collections:[Collections] = []
    var videos:[Video] = []
    var location: Location?
    var guide: GuideForBooking?
    var isWished: String = ""
    var ratingReview: String = "0"
    var isTopExperienceIsWish:Bool = false
    var topExperiencePrice: String = ""
    var topExperienceComment: String = ""
    var bookingID:String = "0"
    var guideID:String = "0"
    var userName:String = ""
    var comment:String = ""
    var isBlock:Bool = false
    var userReview:String?
    var ratedReview:String = "0" 
    var isRated:Bool = false
    var experienceBookingDate:String = ""
    var image:String = ""
    var guideName:String = ""
    var time:String = ""
    var experienceURL:String = ""
    var isInvited:Bool = false
    var pricepersonhourly:String = ""
    var groupPricehourly:String = ""
    var ishourly:Bool = false
    var bookingDuration:String = ""
    
    init(experienceDetail:[String:Any]) {
        super.init()
        
        if let _ = experienceDetail[kExperienceMainImage],!(experienceDetail[kExperienceMainImage] is NSNull){
            self.mainImage = "\(experienceDetail[kExperienceMainImage]!)"
        }
        if let _ = experienceDetail[kLargeExperienceMainImage],!(experienceDetail[kLargeExperienceMainImage] is NSNull){
            self.largemainImage = "\(experienceDetail[kLargeExperienceMainImage]!)"
        }
        if let _ = experienceDetail[kSmallExperienceMainImage],!(experienceDetail[kSmallExperienceMainImage] is NSNull){
            self.smallmainImage = "\(experienceDetail[kSmallExperienceMainImage]!)"
        }
        if let _ = experienceDetail[kExperienceID],!(experienceDetail[kExperienceID] is NSNull){
            self.id = "\(experienceDetail[kExperienceID]!)"
        }
        if let _ = experienceDetail[kExperienceTitle],!(experienceDetail[kExperienceTitle] is NSNull){
            self.title = "\(experienceDetail[kExperienceTitle]!)"
        }
        if let _ = experienceDetail[kExperienceDescription],!(experienceDetail[kExperienceDescription] is NSNull){
            self.discription = "\(experienceDetail[kExperienceDescription]!)"
        }
        if let _ = experienceDetail[kExperiencePricePerson],!(experienceDetail[kExperiencePricePerson] is NSNull){
            self.priceperson = "\(experienceDetail[kExperiencePricePerson]!)"
        }
        if let _ = experienceDetail[kExperienceLocationId],!(experienceDetail[kExperienceLocationId] is NSNull){
            self.locationId = "\(experienceDetail[kExperienceLocationId]!)"
        }
        if let _ = experienceDetail[kExperienceDuration],!(experienceDetail[kExperienceDuration] is NSNull){
            self.duration = "\(experienceDetail[kExperienceDuration]!)"
        }
        if let _ = experienceDetail[kExperienceUserId],!(experienceDetail[kExperienceUserId] is NSNull){
            self.userID = "\(experienceDetail[kExperienceUserId]!)"
        }
        if let _ = experienceDetail[kExperienceEffort],!(experienceDetail[kExperienceEffort] is NSNull){
            self.effort = "\(experienceDetail[kExperienceEffort]!)"
        }
        if let _ = experienceDetail[kExperienceGroupSizeMin],!(experienceDetail[kExperienceGroupSizeMin] is NSNull){
            self.groupSizeMin = "\(experienceDetail[kExperienceGroupSizeMin]!)"
        }
        if let _ = experienceDetail[kExperienceGroupSizeMax],!(experienceDetail[kExperienceGroupSizeMax] is NSNull){
            self.groupSizeMax = "\(experienceDetail[kExperienceGroupSizeMax]!)"
        }
        if let _ = experienceDetail[kExperienceAddress],!(experienceDetail[kExperienceAddress] is NSNull){
            self.address = "\(experienceDetail[kExperienceAddress]!)"
        }
        if let _ = experienceDetail[kExperienceLatitude],!(experienceDetail[kExperienceLatitude] is NSNull){
            self.latitude = "\(experienceDetail[kExperienceLatitude]!)"
        }
        if let _ = experienceDetail[kExperienceLongitude],!(experienceDetail[kExperienceLongitude] is NSNull){
            self.longitude = "\(experienceDetail[kExperienceLongitude]!)"
        }
        if let _ = experienceDetail[kExperienceAverageReview],!(experienceDetail[kExperienceAverageReview] is NSNull){
            self.averageReview = "\(experienceDetail[kExperienceAverageReview]!)"
        }
        if let _ = experienceDetail[kExperienceInstant],!(experienceDetail[kExperienceInstant] is NSNull){
            self.instant = Bool.init("\(experienceDetail[kExperienceInstant]!)")
        }
        if let _ = experienceDetail[kExperienceAddressReference],!(experienceDetail[kExperienceAddressReference] is NSNull){
            self.addressReference = "\(experienceDetail[kExperienceAddressReference]!)"
        }
        if let _ = experienceDetail[kExperienceAccessible],!(experienceDetail[kExperienceAccessible] is NSNull){
            self.accessible = Bool.init("\(experienceDetail[kExperienceAccessible]!)")
        }
        if let _ = experienceDetail[kExperienceFreeChildren],!(experienceDetail[kExperienceFreeChildren] is NSNull){
            self.freechildren = Bool.init("\(experienceDetail[kExperienceFreeChildren]!)")
        }
        if let _ = experienceDetail[kExperiencePetFriendly],!(experienceDetail[kExperiencePetFriendly] is NSNull){
            self.petFriendly = Bool.init("\(experienceDetail[kExperiencePetFriendly]!)")
        }
        if let _ = experienceDetail[kExperienceFreeElderly],!(experienceDetail[kExperienceFreeElderly] is NSNull){
            self.freeElderly = Bool.init("\(experienceDetail[kExperienceFreeElderly]!)")
        }
        if let _ = experienceDetail[kExperienceIsActive],!(experienceDetail[kExperienceIsActive] is NSNull){
            self.isActive = Bool.init("\(experienceDetail[kExperienceIsActive]!)")
        }
        if let _ = experienceDetail[kExperienceBlock],!(experienceDetail[kExperienceBlock] is NSNull){
            self.isBlock = Bool.init("\(experienceDetail[kExperienceBlock]!)")
        }
        if let _ = experienceDetail[kExperienceCreatedDate],!(experienceDetail[kExperienceCreatedDate] is NSNull){
            self.createdDate = "\(experienceDetail[kExperienceCreatedDate]!)"
        }
        if let _ = experienceDetail[kExperienceModifiedDate],!(experienceDetail[kExperienceModifiedDate] is NSNull){
            self.modifiedDate = "\(experienceDetail[kExperienceModifiedDate]!)"
        }
        if let _ = experienceDetail[kExperienceCurrency],!(experienceDetail[kExperienceCurrency] is NSNull){
            self.currency = "\(experienceDetail[kExperienceCurrency]!)"
        }
        if let arrayLanguage = experienceDetail[kExperiencelanguages] as? [[String:Any]]{
            self.languages = []
            for object in arrayLanguage{
                let objLangauge = Language.init(languageDetail: object)
                self.languages.append(objLangauge)
            }
        }
        if let arrayReviews = experienceDetail[kExperiencereviews] as? [[String:Any]]{
            self.reviews = []
            for object in arrayReviews{
                let objReview = Review.init(reviewDetail: object)
                self.reviews.append(objReview)
            }
        }
        if let arrayImages = experienceDetail[kExperienceimages] as? [[String:Any]]{
            self.images = []
            for object in arrayImages{
                let objImage = Images.init(imageDetail: object)
                self.images.append(objImage)
            }
        }
        if let arrayOccurency = experienceDetail[kExperienceoccurrences] as? [[String:Any]]{
            self.occurrences = []
            for object in arrayOccurency{
                let objOccurency = Occurrences.init(occurrenceDetail: object)
                self.occurrences.append(objOccurency)
            }
        }
        if let arrayCollection = experienceDetail[kExperiencecollections] as? [[String:Any]]{
            self.collections = []
            for object in arrayCollection{
                let objCollection = Collections.init(collectionDetail:object)
                self.collections.append(objCollection)
            }
        }
        if let dicLocation = experienceDetail[kLocation] as? [String:Any] {
            self.location = Location.init(locationDetail: dicLocation)
        }
        if let arrayVideo = experienceDetail[kVideo] as? [[String:Any]] {
            self.videos = []
            for object in arrayVideo {
                let objVideo = Video(videoDetail: object)
                self.videos.append(objVideo)
            }
        }
        if let guideDetail = experienceDetail[kGuide] as? [String:Any] {
            self.guide = GuideForBooking.init(bookingGuideDetail: guideDetail)
        }
        if let _ = experienceDetail[kIsWished] {
            self.isWished = "\(experienceDetail[kIsWished]!)"
        }
        if let _ = experienceDetail[kExperienceRatingReview],!(experienceDetail[kExperienceRatingReview] is NSNull) {
            self.ratingReview = "\(experienceDetail[kExperienceRatingReview]!)"
        }
        if let _ = experienceDetail[kTopExperienceIsWish],!(experienceDetail[kTopExperienceIsWish] is NSNull) {
            self.isTopExperienceIsWish = Bool.init("\(experienceDetail[kTopExperienceIsWish]!)")
        }
        if let _ = experienceDetail[kTopExperiencePrice],!(experienceDetail[kTopExperiencePrice] is NSNull) {
            self.topExperiencePrice = "\(experienceDetail[kTopExperiencePrice]!)"
        }
        if let _ = experienceDetail[kTopExperienceComment],!(experienceDetail[kTopExperienceComment] is NSNull) {
            self.topExperienceComment = "\(experienceDetail[kTopExperienceComment]!)"
        }
        if let _ = experienceDetail[kExperienceBookingId],!(experienceDetail[kExperienceBookingId] is NSNull) {
            self.bookingID = "\(experienceDetail[kExperienceBookingId]!)"
        }
        if let _ = experienceDetail[kExperienceGuideId],!(experienceDetail[kExperienceGuideId] is NSNull) {
            self.guideID = "\(experienceDetail[kExperienceGuideId]!)"
        }
        if let _ = experienceDetail[kExperienceUserName],!(experienceDetail[kExperienceUserName] is NSNull) {
            self.userName = "\(experienceDetail[kExperienceUserName]!)"
        }
        if let _ = experienceDetail[kExperienceIsPricePerPerson],!(experienceDetail[kExperienceIsPricePerPerson] is NSNull){
            self.isPricePerPerson = Bool.init("\(experienceDetail[kExperienceIsPricePerPerson]!)")
        }
        if let _ = experienceDetail[kExperienceIsGroupPrice],!(experienceDetail[kExperienceIsGroupPrice] is NSNull){
            self.isGroupPrice = Bool.init("\(experienceDetail[kExperienceIsGroupPrice]!)")
        }
        if let _ = experienceDetail[kExperienceGroupPrice],!(experienceDetail[kExperienceGroupPrice] is NSNull) {
            self.groupPrice = "\(experienceDetail[kExperienceGroupPrice]!)"
        }
        if let _ = experienceDetail[kExperiencePriceGroup],!(experienceDetail[kExperiencePriceGroup] is NSNull) {
            self.groupPrice = "\(experienceDetail[kExperiencePriceGroup]!)"
        }
        if let _ = experienceDetail[kExperienceComment],!(experienceDetail[kExperienceComment] is NSNull) {
            self.comment = "\(experienceDetail[kExperienceComment]!)"
        }
        if let _ = experienceDetail[kExperienceUserReview],!(experienceDetail[kExperienceUserReview] is NSNull) {
            self.userReview = "\(experienceDetail[kExperienceUserReview]!)"
        }
        if let _ = experienceDetail[kRatedReview],!(experienceDetail[kRatedReview] is NSNull){
            self.ratedReview = "\(experienceDetail[kRatedReview]!)"
        }
        if let _ = experienceDetail[kIsRated],!(experienceDetail[kIsRated] is NSNull){
            self.isRated = Bool.init("\(experienceDetail[kIsRated]!)")
        }
        if let _ = experienceDetail[kBookingDate],!(experienceDetail[kBookingDate] is NSNull) {
            self.experienceBookingDate = "\(experienceDetail[kBookingDate]!)"
        }
        if let _ = experienceDetail[kImage],!(experienceDetail[kImage] is NSNull) {
            self.image = "\(experienceDetail[kImage]!)"
        }
        if let _ = experienceDetail[kPaymentGatewayType],!(experienceDetail[kPaymentGatewayType] is NSNull) {
            self.paymentGATE = "\(experienceDetail[kPaymentGatewayType]!)"
        }
        if let _ = experienceDetail[kGuideName],!(experienceDetail[kGuideName] is NSNull){
            self.guideName = "\(experienceDetail[kGuideName]!)"
        }
        if let _ = experienceDetail[kTime],!(experienceDetail[kTime] is NSNull){
            self.time = "\(experienceDetail[kTime]!)"
        }
        if let _ = experienceDetail[kExperienceURL],!(experienceDetail[kExperienceURL] is NSNull){
            self.experienceURL = "\(experienceDetail[kExperienceURL]!)"
        }
        if let _ = experienceDetail[kExperienceInvited],!(experienceDetail[kExperienceInvited] is NSNull){
            self.isInvited = Bool.init("\(experienceDetail[kExperienceInvited]!)")
        }
        if let _ = experienceDetail[kExeriencePricePerPersonHourly],!(experienceDetail[kExeriencePricePerPersonHourly] is NSNull){
            self.pricepersonhourly = "\(experienceDetail[kExeriencePricePerPersonHourly]!)"
        }
        if let _ = experienceDetail[kExerienceGroupPriceHourly],!(experienceDetail[kExerienceGroupPriceHourly] is NSNull){
            self.groupPricehourly = "\(experienceDetail[kExerienceGroupPriceHourly]!)"
        }
        if let _ = experienceDetail[kExperienceIshourly],!(experienceDetail[kExperienceIshourly] is NSNull){
            self.ishourly =  Bool.init("\(experienceDetail[kExperienceIshourly]!)")
        }
        if let _ = experienceDetail[kExperienceBookingDuration],!(experienceDetail[kExperienceBookingDuration] is NSNull){
            self.bookingDuration =  "\(experienceDetail[kExperienceBookingDuration]!)"
        }
    }
    
}

/* Raju*/
class TopGuideData:NSObject{
    //    fileprivate let kFirstName:String = "FirstName"
    fileprivate let kID:String = "Id"
    fileprivate let kGuideName:String = "GuideName"
    fileprivate let kImage:String = "Image"
    fileprivate let kComment:String = "Comment"
    fileprivate let kLocation:String = "Location"
    fileprivate let kLanguage:String = "Language"
    fileprivate let kExperience:String = "Experience"
    fileprivate let kOrganisationLogo:String = "OrganisationLogo"
    fileprivate let kOrganisationName:String = "OrganisationName"
    fileprivate let kSecondaryEmail:String = "SecondaryEmail"
    fileprivate let kGuideAverageReview:String = "AverageReview"
    fileprivate let kIsRated:String = "IsRated"
    fileprivate let kReviews:String = "Reviews"
    fileprivate let kFirstName:String = "FirstName"
    fileprivate let kLastName:String = "LastName"
    
    var id:String = ""
    var guideName:String = ""
    var image:String = ""
    var comment:String = ""
    var location:String = ""
    var language:String = ""
    var topExperience:[Experience] = []
    var reviews:[Review] = []
    var organisationLogo:String = ""
    var organisationName:String = ""
    var averageReview:String = "0"
    var isRated:Bool = false
    var firstName:String = ""
    var lastName:String = ""
    
    init(topGuideDetail:[String:Any]) {
        if let _ = topGuideDetail[kFirstName],!(topGuideDetail[kFirstName] is NSNull){
            self.firstName = "\(topGuideDetail[kFirstName]!)"
        }
        if let _ = topGuideDetail[kLastName],!(topGuideDetail[kLastName] is NSNull){
            self.lastName = "\(topGuideDetail[kLastName]!)"
        }
        if let _ = topGuideDetail[kID],!(topGuideDetail[kID] is NSNull){
            self.id = "\(topGuideDetail[kID]!)"
        }
        if let _ = topGuideDetail[kGuideName],!(topGuideDetail[kGuideName] is NSNull){
            self.guideName = "\(topGuideDetail[kGuideName]!)"
        }
        if let _ = topGuideDetail[kImage],!(topGuideDetail[kImage] is NSNull){
            self.image = "\(topGuideDetail[kImage]!)"
        }
        if let _ = topGuideDetail[kComment],!(topGuideDetail[kComment] is NSNull){
            self.comment = "\(topGuideDetail[kComment]!)"
        }
        if let _ = topGuideDetail[kLocation],!(topGuideDetail[kLocation] is NSNull){
            self.location = "\(topGuideDetail[kLocation]!)"
        }
        if let languages = topGuideDetail[kLanguage] as? [[String:Any]],!(topGuideDetail[kLanguage] is NSNull){
            var arrayLan:[String] = []
            for objLanguage in languages{
                if let name = objLanguage["Name"]{
                    arrayLan.append("\(name)")
                }
            }
            if arrayLan.count > 0{
                self.language = "\(arrayLan.joined(separator: ", "))"
            }
        }
        if let arrayTopExperience = topGuideDetail[kExperience] as? [[String:Any]]{
            self.topExperience = []
            for object in arrayTopExperience{
                let objExperience = Experience.init(experienceDetail:object)
                self.topExperience.append(objExperience)
            }
        }
        if let name = topGuideDetail[kOrganisationName] as? String{
            self.organisationName = name
        }
        if let logo = topGuideDetail[kOrganisationLogo] as? String{
            self.organisationLogo = logo
        }
        if let _ = topGuideDetail[kGuideAverageReview],!(topGuideDetail[kGuideAverageReview] is NSNull){
            self.averageReview = "\(topGuideDetail[kGuideAverageReview]!)"
        }
        if let _ = topGuideDetail[kIsRated],!(topGuideDetail[kIsRated] is NSNull){
            self.isRated = Bool.init("\(topGuideDetail[kIsRated]!)")
        }
        if let arrayReviews = topGuideDetail[kReviews] as? [[String:Any]]{
            self.reviews = []
            for object in arrayReviews{
                let objReview = Review.init(reviewDetail: object)
                self.reviews.append(objReview)
            }
        }
    }
    
}
class Language:NSObject, Codable{
    fileprivate let kID:String = "Id"
    fileprivate let kLanguageID:String = "LanguageId"
    fileprivate let kExperienceID:String = "ExperienceId"
    fileprivate let kLanguageName:String = "Language"
    
    var id:String = ""
    var languageID:String = ""
    var experienceID:String = ""
    var languageName:String = ""
    
    init(languageDetail:[String:Any]){
        if let _ = languageDetail[kID],!(languageDetail[kID] is NSNull){
            self.id = "\(languageDetail[kID]!)"
        }
        if let _ = languageDetail[kLanguageID],!(languageDetail[kLanguageID] is NSNull){
            self.languageID = "\(languageDetail[kLanguageID]!)"
        }
        if let _ = languageDetail[kExperienceID],!(languageDetail[kExperienceID] is NSNull){
            self.experienceID = "\(languageDetail[kExperienceID]!)"
        }
        if let _ = languageDetail[kLanguageName],!(languageDetail[kLanguageName] is NSNull){
            self.languageName = "\(languageDetail[kLanguageName]!)"
        }
    }
}
class Review: NSObject {
    fileprivate let kID:String = "Id"
    fileprivate let kValue:String = "Value"
    fileprivate let kComment:String = "Comment"
    fileprivate let kUserId:String = "UserId"
    fileprivate let kExperienceId:String = "ExperienceId"
    fileprivate let kUserName:String = "UserName"
    fileprivate let kIsActive:String = "IsActive"
    fileprivate let kCreatedDate:String = "CreatedDate"
    fileprivate let kModifiedDate:String = "ModifiedDate"
    fileprivate let kUserImage:String = "UserImage"
    
    var id:String = ""
    var value:String = ""
    var comment:String = ""
    var userID:String = ""
    var experienceID:String = ""
    var userName:String = ""
    var isActive:Bool = false
    var createdDate:String = ""
    var modifiedDate:String = ""
    var userImage: String = ""
    
    init(reviewDetail:[String:Any]){
        if let _ = reviewDetail[kID],!(reviewDetail[kID] is NSNull){
            self.id = "\(reviewDetail[kID]!)"
        }
        if let _ = reviewDetail[kValue],!(reviewDetail[kValue] is NSNull){
            self.value = "\(reviewDetail[kValue]!)"
        }
        if let _ = reviewDetail[kComment],!(reviewDetail[kComment] is NSNull){
            self.comment = "\(reviewDetail[kComment]!)"
        }
        if let _ = reviewDetail[kUserId],!(reviewDetail[kUserId] is NSNull){
            self.userID = "\(reviewDetail[kUserId]!)"
        }
        if let _ = reviewDetail[kExperienceId],!(reviewDetail[kExperienceId] is NSNull){
            self.experienceID = "\(reviewDetail[kExperienceId]!)"
        }
        if let _ = reviewDetail[kUserName],!(reviewDetail[kUserName] is NSNull){
            self.userName = "\(reviewDetail[kUserName]!)"
        }
        if let _ = reviewDetail[kIsActive],!(reviewDetail[kIsActive] is NSNull){
            self.isActive = Bool.init("\(reviewDetail[kIsActive]!)")
        }
        if let _ = reviewDetail[kCreatedDate],!(reviewDetail[kCreatedDate] is NSNull){
            self.createdDate = "\(reviewDetail[kCreatedDate]!)"
        }
        if let _ = reviewDetail[kModifiedDate],!(reviewDetail[kModifiedDate] is NSNull){
            self.modifiedDate = "\(reviewDetail[kModifiedDate]!)"
        }
        if let _ = reviewDetail[kUserImage],!(reviewDetail[kUserImage] is NSNull){
            self.userImage = "\(reviewDetail[kUserImage]!)"
        }
    }
    
    
}
extension Bool {
    init(_ string: String?) {
        guard let string = string else { self = false; return }
        
        switch string.lowercased() {
        case "true", "yes", "1":
            self = true
        default:
            self = false
        }
    }
}
class Images:NSObject{
    fileprivate let kID:String = "Id"
    fileprivate let kImage:String = "Image"
    fileprivate let kLargeImage:String = "LargeImage"
    fileprivate let kSmallImage:String = "SmallImage"
    fileprivate let kMainImage:String = "MainImage" //bool
    fileprivate let kExperienceId:String = "ExperienceId"
    fileprivate let kOrder:String = "Order"
    
    var id:String = ""
    var imageURL:NSString = ""
    var largeimageURL:NSString = ""
    var smallimageURL:String = ""
    var mainImage:Bool = false
    var experienceID:String = ""
    var orderIndex:String = ""
    
    init(imageDetail:[String:Any]){
        if let _ = imageDetail[kID],!(imageDetail[kID] is NSNull){
            self.id = "\(imageDetail[kID]!)"
        }
        if let _ = imageDetail[kImage],!(imageDetail[kImage] is NSNull){
            self.imageURL = "\(imageDetail[kImage]!)" as NSString
        }
        if let _ = imageDetail[kLargeImage],!(imageDetail[kLargeImage] is NSNull){
            self.largeimageURL = "\(imageDetail[kLargeImage]!)" as NSString
        }
        if let _ = imageDetail[kSmallImage],!(imageDetail[kSmallImage] is NSNull){
            self.smallimageURL = "\(imageDetail[kSmallImage]!)"
        }
        if let _ = imageDetail[kMainImage],!(imageDetail[kMainImage] is NSNull){
            self.mainImage = Bool.init("\(imageDetail[kMainImage]!)")
        }
        if let _ = imageDetail[kExperienceId],!(imageDetail[kExperienceId] is NSNull){
            self.experienceID = "\(imageDetail[kExperienceId]!)"
        }
        if let _ = imageDetail[kOrder],!(imageDetail[kOrder] is NSNull){
            self.orderIndex = "\(imageDetail[kOrder]!)"
        }
    }
}
class Occurrences:NSObject{
    fileprivate let kID:String = "Id"
    fileprivate let kRecurrence:String = "Recurrence"
    fileprivate let kRecurrenceDay:String = "RecurrenceDays"
    fileprivate let kTime:String = "Time"
    fileprivate let kExperienceId:String = "ExperienceId"
    
    var id:String = ""
    var recurrence:String = ""
    var recurrenceDay:String = ""
    var time:String = ""
    var experienceID:String = ""
    
    init(occurrenceDetail:[String:Any]){
        if let _ = occurrenceDetail[kID],!(occurrenceDetail[kID] is NSNull){
            self.id = "\(occurrenceDetail[kID]!)"
        }
        if let _ = occurrenceDetail[kRecurrence],!(occurrenceDetail[kRecurrence] is NSNull){
            self.recurrence = "\(occurrenceDetail[kRecurrence]!)"
        }
        if let _ = occurrenceDetail[kRecurrenceDay],!(occurrenceDetail[kRecurrenceDay] is NSNull){
            self.recurrenceDay = "\(occurrenceDetail[kRecurrenceDay]!)"
        }
        if let _ = occurrenceDetail[kTime],!(occurrenceDetail[kTime] is NSNull){
            self.time = "\(occurrenceDetail[kTime]!)"
        }
        if let _ = occurrenceDetail[kExperienceId],!(occurrenceDetail[kExperienceId] is NSNull){
            self.experienceID = "\(occurrenceDetail[kExperienceId]!)"
        }
    }
}
class Collections:NSObject{
    fileprivate let kID:String = "Id"
    fileprivate let kTitle:String = "Title"
    fileprivate let kColor:String = "Color"
    fileprivate let kLocationId:String = "LocationId"
    fileprivate let kCreatedDate:String = "CreatedDate"
    fileprivate let kExpoImage:String = "Image"
    fileprivate let kISVideo:String = "IsVideo"
    fileprivate let kExperiences:String = "Experinces"
    
    var id:String = ""
    var title:String = ""
    var color:String = ""
    var locationId:String = ""
    var createdDate:String = ""
    var imgaeURL:String = ""
    var isVideo:Bool = false
    var expoExperiences:[Experience] = []
    
    init(collectionDetail:[String:Any]){
        if let _ = collectionDetail[kID],!(collectionDetail[kID] is NSNull){
            self.id = "\(collectionDetail[kID]!)"
        }
        if let _ = collectionDetail[kTitle],!(collectionDetail[kTitle] is NSNull){
            self.title = "\(collectionDetail[kTitle]!)"
        }
        if let _ = collectionDetail[kColor],!(collectionDetail[kColor] is NSNull){
            self.color = "\(collectionDetail[kColor]!)"
        }
        if let _ = collectionDetail[kLocationId],!(collectionDetail[kLocationId] is NSNull){
            self.locationId = "\(collectionDetail[kLocationId]!)"
        }
        if let _ = collectionDetail[kCreatedDate],!(collectionDetail[kCreatedDate] is NSNull){
            self.createdDate = "\(collectionDetail[kCreatedDate]!)"
        }
        if let _ = collectionDetail[kExpoImage],!(collectionDetail[kExpoImage] is NSNull){
            self.imgaeURL = "\(collectionDetail[kExpoImage]!)"
        }
        if let _ = collectionDetail[kISVideo],!(collectionDetail[kISVideo] is NSNull){
            self.isVideo = Bool.init("\(collectionDetail[kISVideo]!)")
        }
        if let arrayTopExperience = collectionDetail[kExperiences] as? [[String:Any]],!(collectionDetail[kExperiences] is NSNull){
            self.expoExperiences = []
            for object in arrayTopExperience{
                let objExperience = Experience.init(experienceDetail:object)
                self.expoExperiences.append(objExperience)
            }
        }
    }
}
class Guide:NSObject{
    fileprivate let kID:String = "Id"
    fileprivate let kFirstName:String = "FirstName"
    fileprivate let kLastName:String = "LastName"
    fileprivate let kImage:String = "Image"
    fileprivate let kComment:String = "Comment"
    fileprivate let kGuideAverageReview:String = "AverageReview"

    var id:String = ""
    var firstName:String = ""
    var lastName:String = ""
    var image:String = ""
    var comment:String = ""
    var averageReview:String = "0"
    
    init(guideDetail:[String:Any]) {
        if let _ = guideDetail[kID],!(guideDetail[kID] is NSNull){
            self.id = "\(guideDetail[kID]!)"
        }
        if let _ = guideDetail[kFirstName],!(guideDetail[kFirstName] is NSNull){
            self.firstName = "\(guideDetail[kFirstName]!)"
        }
        if let _ = guideDetail[kLastName],!(guideDetail[kLastName] is NSNull){
            self.lastName = "\(guideDetail[kLastName]!)"
        }
        if let _ = guideDetail[kImage],!(guideDetail[kImage] is NSNull){
            self.image = "\(guideDetail[kImage]!)"
        }
        if let _ = guideDetail[kComment],!(guideDetail[kComment] is NSNull){
            self.comment = "\(guideDetail[kComment]!)"
        }
        if let _ = guideDetail[kGuideAverageReview],!(guideDetail[kGuideAverageReview] is NSNull){
            self.averageReview = "\(guideDetail[kGuideAverageReview]!)"
        }
    }
}
class Location : NSObject{
    fileprivate let kCity:String = "City"
    fileprivate let kCountry:String = "Country"
    fileprivate let kState:String = "State"
    
    var city:String = ""
    var country:String = ""
    var state:String = ""
    
    init(locationDetail:[String:Any]) {
        if let _ = locationDetail[kCity],!(locationDetail[kCity] is NSNull) {
            self.city = "\(locationDetail[kCity]!)"
        }
        if let _ = locationDetail[kCountry],!(locationDetail[kCountry] is NSNull) {
            self.country = "\(locationDetail[kCountry]!)"
        }
        if let _ = locationDetail[kState],!(locationDetail[kState] is NSNull) {
            self.state = "\(locationDetail[kState]!)"
        }
    }
}
class GuideForBooking: NSObject {
    fileprivate let kGuideName: String = "GuideName"
    fileprivate let kCity: String = "City"
    fileprivate let kEmail: String = "Email"
    fileprivate let kImage: String = "Image"
    fileprivate let kDescription: String = "Description"
    fileprivate let kId: String = "Id"
    fileprivate let kGuideAverageReview:String = "AverageReview"
    
    var guideName:String = ""
    var city:String = ""
    var email:String = ""
    var image:String = ""
    var guideDescription:String = ""
    var guideId:String = ""
    var averageReview:String = "0"
    
    init(bookingGuideDetail:[String:Any]) {
        if let _ = bookingGuideDetail[kGuideName],!(bookingGuideDetail[kGuideName] is NSNull){
            self.guideName = "\(bookingGuideDetail[kGuideName]!)"
        }
        if let _ = bookingGuideDetail[kCity],!(bookingGuideDetail[kCity] is NSNull){
            self.city = "\(bookingGuideDetail[kCity]!)"
        }
        if let _ = bookingGuideDetail[kEmail],!(bookingGuideDetail[kEmail] is NSNull){
            self.email = "\(bookingGuideDetail[kEmail]!)"
        }
        if let _ = bookingGuideDetail[kImage],!(bookingGuideDetail[kImage] is NSNull){
            self.image = "\(bookingGuideDetail[kImage]!)"
        }
        if let _ = bookingGuideDetail[kDescription],!(bookingGuideDetail[kDescription] is NSNull){
            self.guideDescription = "\(bookingGuideDetail[kDescription]!)"
        }
        if let _ = bookingGuideDetail[kId],!(bookingGuideDetail[kId] is NSNull){
            self.guideId = "\(bookingGuideDetail[kId]!)"
        }
        if let _ = bookingGuideDetail[kGuideAverageReview],!(bookingGuideDetail[kGuideAverageReview] is NSNull){
            self.averageReview = "\(bookingGuideDetail[kGuideAverageReview]!)"
        }
    }
    
}
class Video : NSObject{
    fileprivate let kId:String = "id"
    fileprivate let kExperienceId:String = "ExperienceId"
    fileprivate let kVideoUrl:String = "VideoUrl"
    fileprivate let kThumbnailUrl:String = "ThumbnailUrl"
    fileprivate let kOrder:String = "Order"
    
    var experienceId: Int?
    var thumbnailUrl: NSString = ""
    var videoUrl: NSString = ""
    var id: Int?
    var orderIndex:String = ""
    
    init(videoDetail:[String:Any]) {
        if let _ = videoDetail[kId],!(videoDetail[kId] is NSNull)  {
            self.id = videoDetail[kId] as? Int
        }
        if let _ = videoDetail[kExperienceId],!(videoDetail[kExperienceId] is NSNull) {
            self.experienceId = videoDetail[kExperienceId] as? Int
        }
        if let _ = videoDetail[kVideoUrl],!(videoDetail[kVideoUrl] is NSNull){
            self.videoUrl = "\(videoDetail[kVideoUrl]!)" as NSString
        }
        if let _ = videoDetail[kThumbnailUrl],!(videoDetail[kThumbnailUrl] is NSNull) {
            self.thumbnailUrl = "\(videoDetail[kThumbnailUrl]!)" as NSString
        }
        if let _ = videoDetail[kOrder],!(videoDetail[kOrder] is NSNull){
            self.orderIndex = "\(videoDetail[kOrder]!)"
        }
    }
    
}
//:-Mark: Pending Experience
class PendingExperience: NSObject, Codable{
    fileprivate let kID:String = "Id"
    fileprivate let kDate:String = "BookingDate"
    fileprivate let kSlots:String = "Slots"
    fileprivate let kUserId:String = "UserId"
    fileprivate let kExperienceId:String = "ExperienceId"
    fileprivate let kUserName:String = "UserName"
    fileprivate let kStatus:String = "Status"
    fileprivate let kTitle:String = "Title"
    fileprivate let kTime:String = "Time"
    fileprivate let kMainimage:String = "MainImage"
    fileprivate let kLargeMainimage:String = "LargeMainImage"
    fileprivate let kSmallMainimage:String = "SmallMainImage"
    fileprivate let kGuide_id:String = "GuideId"
    fileprivate let kCurrency:String = "Currency"
    fileprivate let kImage:String = "Image"
    fileprivate let kAverageReview:String = "AverageReview"
    fileprivate let kIsGroupBooking:String = "IsGroupBooking"
    fileprivate let kPrice:String = "Price"
    fileprivate let kIsInstantBooking:String = "InstantBooking"
    fileprivate let kPaymentGatewayType:String = "PaymentGatewayType"
    fileprivate let kExperiencelanguages:String = "ExperienceLanguages"
    fileprivate let kExperienceLocationId:String = "LocationId"
    fileprivate let kExperienceIshourly:String = "IsHourly"
    fileprivate let kExperienceBookingDuration:String = "BookingDuration"
    fileprivate let kExperienceActualPrice:String = "ActualPrice"
    
    var id:String = ""
    var date:String = ""
    var slots:String = ""
    var userID:String = ""
    var experienceID:String = ""
    var userName:String = ""
    var status:String = ""
    var title:String = ""
    var mainimage:String = ""
    var largemainimage:String = ""
    var smallmainimage:String = ""
    var guideID:String = ""
    var time:String = ""
    var currency:String = ""
    var image:String = ""
    var averageReview:String = "0"
    var isGroupBooking:Bool = true
    var price:String = ""
    var isInstantBooking:Bool = true
    var languages:[String] = []
    var locationId:String = ""
    var ishourly:Bool = false
    var bookingDuration:String = ""
    var paymentGateWay:String = ""
    var paymentGATE:String{
        get{
            return paymentGateWay
        }
        set{
            paymentGateWay = newValue
            self.updateExperiencePaymentGateway()
        }
    }
    var paymentGateWayType:ExperiencePaymentGateWay = .stripe
    var actualPrice:String = ""
    
    func updateExperiencePaymentGateway(){
        if self.paymentGATE.compareCaseInsensitive(str:"1"){
            self.paymentGateWayType = .stripe
        }else if self.paymentGATE.compareCaseInsensitive(str:"2"){
            self.paymentGateWayType = .braintree
        }else if self.paymentGATE.compareCaseInsensitive(str:"3"){
            self.paymentGateWayType = .both
        }else if self.paymentGATE.compareCaseInsensitive(str:"4"){
            self.paymentGateWayType = .none
        }
    }

    init(PendingExperienceDetail:[String:Any]){
        super.init()
        if let _ = PendingExperienceDetail[kID]{
            self.id = "\(PendingExperienceDetail[kID]!)"
        }
        if let _ = PendingExperienceDetail[kSlots]{
            self.slots = "\(PendingExperienceDetail[kSlots]!)"
        }
        if let _ = PendingExperienceDetail[kTitle]{
            self.title = "\(PendingExperienceDetail[kTitle]!)"
        }
        if let _ = PendingExperienceDetail[kUserId]{
            self.userID = "\(PendingExperienceDetail[kUserId]!)"
        }
        if let _ = PendingExperienceDetail[kExperienceId]{
            self.experienceID = "\(PendingExperienceDetail[kExperienceId]!)"
        }
        if let _ = PendingExperienceDetail[kUserName]{
            self.userName = "\(PendingExperienceDetail[kUserName]!)"
        }
        if let _ = PendingExperienceDetail[kGuide_id]{
            self.guideID = ("\(PendingExperienceDetail[kGuide_id]!)")
        }
        if let _ = PendingExperienceDetail[kDate]{
            self.date = "\(PendingExperienceDetail[kDate]!)"
        }
        if let _ = PendingExperienceDetail[kMainimage]{
            self.mainimage = "\(PendingExperienceDetail[kMainimage]!)"
        }
        if let _ = PendingExperienceDetail[kLargeMainimage]{
            self.largemainimage = "\(PendingExperienceDetail[kLargeMainimage]!)"
        }
        if let _ = PendingExperienceDetail[kSmallMainimage]{
            self.smallmainimage = "\(PendingExperienceDetail[kSmallMainimage]!)"
        }
        if let _ = PendingExperienceDetail[kStatus]{
            self.status = "\(PendingExperienceDetail[kStatus]!)"
        }
        if let _ = PendingExperienceDetail[kTime]{
            self.time = "\(PendingExperienceDetail[kTime]!)"
        }
        if let _ = PendingExperienceDetail[kCurrency]{
            self.currency = "\(PendingExperienceDetail[kCurrency]!)"
        }
        if let _ = PendingExperienceDetail[kImage]{
            self.image = "\(PendingExperienceDetail[kImage]!)"
        }
        if let _ = PendingExperienceDetail[kAverageReview],!(PendingExperienceDetail[kAverageReview] is NSNull){
            self.averageReview = "\(PendingExperienceDetail[kAverageReview]!)"
        }
        if let _ = PendingExperienceDetail[kIsGroupBooking],!(PendingExperienceDetail[kIsGroupBooking] is NSNull){
            self.isGroupBooking = Bool.init("\(PendingExperienceDetail[kIsGroupBooking]!)")
        }
        if let _ = PendingExperienceDetail[kPrice],!(PendingExperienceDetail[kPrice] is NSNull){
            self.price = "\(PendingExperienceDetail[kPrice]!)"
        }
        if let _ = PendingExperienceDetail[kIsInstantBooking],!(PendingExperienceDetail[kIsInstantBooking] is NSNull){
            self.isInstantBooking = Bool.init("\(PendingExperienceDetail[kIsInstantBooking]!)")
        }
        if let _ = PendingExperienceDetail[kPaymentGatewayType],!(PendingExperienceDetail[kPaymentGatewayType] is NSNull) {
            self.paymentGATE = "\(PendingExperienceDetail[kPaymentGatewayType]!)"
        }
        if let _ = PendingExperienceDetail[kExperienceLocationId],!(PendingExperienceDetail[kExperienceLocationId] is NSNull){
            self.locationId = "\(PendingExperienceDetail[kExperienceLocationId]!)"
        }
        if let arrayLanguage = PendingExperienceDetail[kExperiencelanguages] as? [String] {
            self.languages = arrayLanguage
        }
        if let _ = PendingExperienceDetail[kExperienceIshourly],!(PendingExperienceDetail[kExperienceIshourly] is NSNull){
            self.ishourly =  Bool.init("\(PendingExperienceDetail[kExperienceIshourly]!)")
        }
        if let _ = PendingExperienceDetail[kExperienceBookingDuration],!(PendingExperienceDetail[kExperienceBookingDuration] is NSNull){
            self.bookingDuration =  "\(PendingExperienceDetail[kExperienceBookingDuration]!)"
        }
        if let _ = PendingExperienceDetail[kExperienceActualPrice],!(PendingExperienceDetail[kExperienceActualPrice] is NSNull){
            self.actualPrice =  "\(PendingExperienceDetail[kExperienceActualPrice]!)"
        }
    }
}
extension PendingExperience {
    static var isPendingExperience:Bool{
        if let pendingExperiencedata  = kUserDefault.value(forKey: kPendingExperience) as? Data{
            return self.isValidPendingExperience(data: pendingExperiencedata)
        }else{
            return false
        }
    }
    func setPendingExperienceToUserDefault(){
        do{
            let userData = try JSONEncoder().encode(self)
            kUserDefault.setValue(userData, forKey:kPendingExperience)
            kUserDefault.synchronize()
        }catch{
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: kCommonError)
            }
        }
    }
    static func isValidPendingExperience(data:Data)->Bool{
        do {
            let _ = try JSONDecoder().decode(PendingExperience.self, from: data)
            return true
        }catch{
            return false
        }
    }
    static func getPendingExperienceUserDefault() -> PendingExperience?{
        if let pendingExperienceData = kUserDefault.value(forKey: kPendingExperience) as? Data{
            do {
                let pendingExperience:PendingExperience = try JSONDecoder().decode(PendingExperience.self, from: pendingExperienceData)
                return pendingExperience
            }catch{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: kCommonError)
                }
                return nil
            }
        }
        DispatchQueue.main.async {
            ShowToast.show(toatMessage: kCommonError)
        }

        return nil
    }
    static func removeUserFromUserDefault(){
        kUserDefault.removeObject(forKey:kPendingExperience)
    }

}












