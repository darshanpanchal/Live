//
//  Schedule.swift
//  Live
//
//  Created by IPS on 05/06/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class Schedule: NSObject {
    fileprivate let kScheduleID:String = "Id"
    fileprivate let kScheduleBookingDate:String = "BookingDate"
    fileprivate let kExpereinceID:String = "ExperienceId"
    fileprivate let kSlots:String = "Slots"
    fileprivate let kScheduleStatus:String = "Status"
    fileprivate let kScheduleTime = "Time"
    fileprivate let kScheduleUserId = "UserId"
    fileprivate let kScheduleUserName = "UserName"
    fileprivate let kScheduleTitle = "Title"
    fileprivate let kScheduleGuideId = "GuideId"
    fileprivate let kScheduleGuideName = "GuideName"
    fileprivate let kImage = "Image"
    fileprivate let kPrice = "Price"
    fileprivate let kIsGroupBooking = "IsGroupBooking"
    fileprivate let kIsInstantBooking = "InstantBooking"
    fileprivate let kCurrency = "Currency"
    fileprivate let kAverageReview = "AverageReview"
    fileprivate let kExperienceIshourly:String = "IsHourly"
    fileprivate let kExperienceBookingDuration:String = "BookingDuration"
    
    var id:String = ""
    var bookingDate:String = ""
    var experienceID:String = ""
    var slots:String = ""
    var status:String = ""
    var time:String = ""
    var userID:String = ""
    var userName:String = ""
    var title:String = ""
    var image:String = ""
    var guideID:String = ""
    var guideName:String = ""
    var price:String = ""
    var currency:String = ""
    var isGroupBooking:Bool = false
    var isInstantBooking:Bool = false
    var averageReview:String = "0"
    var ishourly:Bool = false
    var bookingDuration:String = ""
    
    init(scheduleDetail:[String:Any]) {
        if let _ = scheduleDetail[kScheduleID],!(scheduleDetail[kScheduleID] is NSNull){
            self.id = "\(scheduleDetail[kScheduleID]!)"
        }
        if let _ = scheduleDetail[kScheduleBookingDate],!(scheduleDetail[kScheduleBookingDate] is NSNull){
            self.bookingDate = "\(scheduleDetail[kScheduleBookingDate]!)"
        }
        if let _ = scheduleDetail[kExpereinceID],!(scheduleDetail[kExpereinceID] is NSNull){
            self.experienceID = "\(scheduleDetail[kExpereinceID]!)"
        }
        if let _ = scheduleDetail[kSlots],!(scheduleDetail[kSlots] is NSNull){
            self.slots = "\(scheduleDetail[kSlots]!)"
        }
        if let _ = scheduleDetail[kScheduleStatus],!(scheduleDetail[kScheduleStatus] is NSNull){
            self.status = "\(scheduleDetail[kScheduleStatus]!)"
        }
        if let _ = scheduleDetail[kScheduleTime],!(scheduleDetail[kScheduleTime] is NSNull){
            self.time = "\(scheduleDetail[kScheduleTime]!)"
        }
        if let _ = scheduleDetail[kScheduleUserId],!(scheduleDetail[kScheduleUserId] is NSNull){
            self.userID = "\(scheduleDetail[kScheduleUserId]!)"
        }
        if let _ = scheduleDetail[kScheduleUserName],!(scheduleDetail[kScheduleUserName] is NSNull){
            self.userName = "\(scheduleDetail[kScheduleUserName]!)"
        }
        if let _ = scheduleDetail[kScheduleTitle],!(scheduleDetail[kScheduleTitle] is NSNull){
            self.title = "\(scheduleDetail[kScheduleTitle]!)"
        }
        if let _ = scheduleDetail[kImage],!(scheduleDetail[kImage] is NSNull){
            self.image = "\(scheduleDetail[kImage]!)"
        }
        if let _ = scheduleDetail[kScheduleGuideId],!(scheduleDetail[kScheduleGuideId] is NSNull){
            self.guideID = "\(scheduleDetail[kScheduleGuideId]!)"
        }
        if let _ = scheduleDetail[kScheduleGuideName],!(scheduleDetail[kScheduleGuideName] is NSNull){
            self.guideName = "\(scheduleDetail[kScheduleGuideName]!)"
        }
        if let _ = scheduleDetail[kPrice],!(scheduleDetail[kPrice] is NSNull){
            self.price = "\(scheduleDetail[kPrice]!)"
        }
        if let _ = scheduleDetail[kIsGroupBooking],!(scheduleDetail[kIsGroupBooking] is NSNull){
            self.isGroupBooking = Bool.init("\(scheduleDetail[kIsGroupBooking]!)")
        }
        if let _ = scheduleDetail[kIsInstantBooking],!(scheduleDetail[kIsInstantBooking] is NSNull){
            self.isInstantBooking = Bool.init("\(scheduleDetail[kIsInstantBooking]!)")
        }
        if let _ = scheduleDetail[kCurrency],!(scheduleDetail[kCurrency] is NSNull){
            self.currency = "\(scheduleDetail[kCurrency]!)"
        }
        if let _ = scheduleDetail[kAverageReview],!(scheduleDetail[kAverageReview] is NSNull){
            self.averageReview = "\(scheduleDetail[kAverageReview]!)"
        }
        if let _ = scheduleDetail[kExperienceIshourly],!(scheduleDetail[kExperienceIshourly] is NSNull){
            self.ishourly =  Bool.init("\(scheduleDetail[kExperienceIshourly]!)")
        }
        if let _ = scheduleDetail[kExperienceBookingDuration],!(scheduleDetail[kExperienceBookingDuration] is NSNull){
            self.bookingDuration =  "\(scheduleDetail[kExperienceBookingDuration]!)"
        }
    }
}
