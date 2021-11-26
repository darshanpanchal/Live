//
//  CardHeaderView.swift
//  TableViewWithMultipleCellTypes
//
//  Created by ips on 09/05/18.
//  Copyright © 2018 Stanislav Ostrovskiy. All rights reserved.
//

import UIKit
protocol CardHeaderDeledate {
    func addNewCardSelector()
}

class CardHeaderView: UITableViewHeaderFooterView {

    @IBOutlet var buttonAddNewCard:RoundButton!
    @IBOutlet var savedCardLbl:UILabel!
    var cardHeaderDelegate:CardHeaderDeledate?
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.buttonAddNewCard.setTitle(Vocabulary.getWordFromKey(key: "addCards"), for: .normal)
        self.savedCardLbl.text = Vocabulary.getWordFromKey(key: "savedCards")
        // Drawing code
        self.buttonAddNewCard.setBackgroundColor(color: UIColor.lightGray.withAlphaComponent(0.5), forState: .highlighted)
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.savedCardLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
        self.savedCardLbl.adjustsFontForContentSizeCategory = true
        self.savedCardLbl.adjustsFontSizeToFitWidth = true
        
        self.buttonAddNewCard.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonAddNewCard.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonAddNewCard.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    //Selector Methods
    @IBAction func buttonAddNewCardSelector(sender:UIButton){
        self.cardHeaderDelegate?.addNewCardSelector()
    }
}
