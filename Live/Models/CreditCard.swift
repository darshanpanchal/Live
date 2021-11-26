//
//  CreditCard.swift
//  Live
//
//  Created by ips on 09/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
enum CardType:String{
    case visa
    case unionpay
    case mastercard
    case jcb
    case discover
    case dinnerclub
    case americanexpress
    case defaultCard
}
class CreditCard: NSObject {
    fileprivate let kCardID:String = "Id"
    fileprivate let kCardBrand:String = "Brand"
    fileprivate let kCardNumber:String = "Number"
    fileprivate let kCardCvv:String = "Cvv"
    fileprivate let kCardExpirationYear:String = "ExpirationYear"
    fileprivate let kCardExpirationMonth = "ExpirationMonth"
    fileprivate let kCardHolderName = "HolderName"
    
    var id:String = ""
    var cardBrand = ""
    var brand:String{
        get{
            return cardBrand
        }
        set{
            self.cardBrand = newValue
            self.updateCardType()
        }
    }
    var cardType:CardType = .defaultCard
    func updateCardType(){
        if self.brand.compareCaseInsensitive(str:"VISA"){
            self.cardType = .visa
        }else if self.brand.compareCaseInsensitive(str:"DINERS_CLUB"){
            self.cardType = .dinnerclub
        }else if self.brand.compareCaseInsensitive(str:"MASTERCARD"){
            self.cardType = .mastercard
        }else if self.brand.compareCaseInsensitive(str:"AMERICAN_EXPRESS"){
            self.cardType = .americanexpress
        }else if self.brand.compareCaseInsensitive(str:"UNIONPAY"){
            self.cardType = .unionpay
        }else if self.brand.compareCaseInsensitive(str:"JCB"){
            self.cardType = .jcb
        }else{
            self.cardType = .defaultCard
        }
    }
    var number:String = ""
    var cvv:String = ""
    var expirationYear:String = ""
    var expirationMonth:String = ""
    var holderName:String = ""
    
    init(cardDetail:[String:Any]) {
        super.init()
        if let cardID = cardDetail[kCardID],!(cardID is NSNull){
            self.id = "\(cardID)"
        }
        if let cardBrand = cardDetail[kCardBrand],!(cardBrand is NSNull){
            self.brand = "\(cardBrand)"
        }
        if let cardNumber = cardDetail[kCardNumber],!(cardNumber is NSNull){
            self.number = "\(cardNumber)"
        }
        if let cardCVV = cardDetail[kCardCvv],!(cardCVV is NSNull){
            self.cvv  = "\(cardCVV)"
        }
        if let cardExpirationYear = cardDetail[kCardExpirationYear],!(cardExpirationYear is NSNull){
            self.expirationYear = "\(cardExpirationYear)"
        }
        if let cardExpirationMonth = cardDetail[kCardExpirationMonth],!(cardExpirationMonth is NSNull){
            self.expirationMonth = "\(cardExpirationMonth)"
        }
        if let cardHolderName = cardDetail[kCardHolderName],!(cardHolderName is NSNull){
            self.holderName = "\(cardHolderName)"
        }
    }
}

