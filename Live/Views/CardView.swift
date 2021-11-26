//
//  CardView.swift
//  TableViewWithMultipleCellTypes
//
//  Created by ips on 09/05/18.
//  Copyright © 2018 Stanislav Ostrovskiy. All rights reserved.
//

import UIKit
protocol CardViewDelegate {
    func cardSelector(tag:Int)
    func paySelector(tag:Int)
}
class CardView: UITableViewHeaderFooterView {
    @IBOutlet var lblCardNumber:UILabel!
    @IBOutlet var imgCard:UIImageView!
    @IBOutlet var btnPay:UIButton!
    @IBOutlet var containerView:UIView!
    var cardDelegate:CardViewDelegate?
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.containerView.layer.cornerRadius = 4.0
        self.containerView.clipsToBounds = true
        self.btnPay.setTitle(Vocabulary.getWordFromKey(key: "Pay"), for: .normal)
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.lblCardNumber.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblCardNumber.adjustsFontForContentSizeCategory = true
        self.lblCardNumber.adjustsFontSizeToFitWidth = true
        
        self.btnPay.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.btnPay.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnPay.titleLabel?.adjustsFontSizeToFitWidth = true
    }

    func setCardType(cardType:CardType){
        if cardType == .visa{
            self.imgCard.image = #imageLiteral(resourceName: "visacard").withRenderingMode(.alwaysOriginal)
        }else if cardType == .unionpay{
             self.imgCard.image = #imageLiteral(resourceName: "unionpaycard").withRenderingMode(.alwaysOriginal)
        }else if cardType == .mastercard{
             self.imgCard.image = #imageLiteral(resourceName: "mastercard").withRenderingMode(.alwaysOriginal)
        }else if cardType == .jcb{
             self.imgCard.image = #imageLiteral(resourceName: "jcbcard").withRenderingMode(.alwaysOriginal)
        }else if cardType == .discover{
             self.imgCard.image = #imageLiteral(resourceName: "discover").withRenderingMode(.alwaysOriginal)
        }else if cardType == .dinnerclub{
             self.imgCard.image = #imageLiteral(resourceName: "dinnerclub").withRenderingMode(.alwaysOriginal)
        }else if cardType == .americanexpress{
             self.imgCard.image = #imageLiteral(resourceName: "americanexpress").withRenderingMode(.alwaysOriginal)
        }else if cardType == .defaultCard{
             self.imgCard.image = #imageLiteral(resourceName: "othercard").withRenderingMode(.alwaysOriginal)
        }else{
             self.imgCard.image = #imageLiteral(resourceName: "othercard").withRenderingMode(.alwaysOriginal)
        }
    }
    @IBAction func buttonSelector(sender:UIButton){
        self.cardDelegate?.cardSelector(tag: self.tag)
    }
    @IBAction func buttonPaySelector(sender:UIButton){
        self.cardDelegate?.paySelector(tag: self.tag)
    }
}
