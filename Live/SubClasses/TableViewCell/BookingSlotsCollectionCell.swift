//
//  BookingSlotsCollectionCell.swift
//  Live
//
//  Created by ips on 23/04/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class BookingSlotsCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var slotTitleLbl: UILabel!
    @IBOutlet weak var slotTimeLbl: UILabel!
    var isInstant:Bool = false{
        didSet{
            self.configureInstant()
        }
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 25.0
        self.layer.borderWidth = 1.0
        self.layer.masksToBounds = true
        DispatchQueue.main.async {
            //self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.slotTitleLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
        self.slotTitleLbl.adjustsFontForContentSizeCategory = true
        self.slotTitleLbl.adjustsFontSizeToFitWidth = true
        
        self.slotTimeLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
        self.slotTimeLbl.adjustsFontForContentSizeCategory = true
        self.slotTimeLbl.adjustsFontSizeToFitWidth = true
    }
    func configureInstant(){
        if self.isInstant{
            self.layer.borderColor = UIColor.red.cgColor
        }else{
            self.layer.borderColor = UIColor.black.cgColor
        }
    }
}

