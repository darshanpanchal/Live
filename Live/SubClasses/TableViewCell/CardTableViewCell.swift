//
//  CardTableViewCell.swift
//  Live
//
//  Created by ips on 09/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
protocol CardTableViewCellDelegate {
    func deleteCardSelector(tag:Int)
}

class CardTableViewCell: UITableViewCell {

    @IBOutlet var lblCardHolderName:UILabel!
    @IBOutlet var buttonDelete:UIButton!
    @IBOutlet var lblCardHolder:UILabel!
    
    var cardDelegate:CardTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        lblCardHolder.text = Vocabulary.getWordFromKey(key: "lblCardHolder")
        buttonDelete.setTitle(Vocabulary.getWordFromKey(key: "delete"), for: .normal)
        // Initialization code
        self.selectionStyle = .none
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.buttonDelete.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonDelete.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonDelete.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.lblCardHolderName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Book", textStyle: .title1)
        self.lblCardHolderName.adjustsFontForContentSizeCategory = true
        self.lblCardHolderName.adjustsFontSizeToFitWidth = true
        
        
//        self.lblCardHolder.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Book", textStyle: .title1)
//        self.lblCardHolder.adjustsFontForContentSizeCategory = true
//        self.lblCardHolder.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func buttonDeleteSelector(sender:UIButton){
        self.cardDelegate?.deleteCardSelector(tag: self.tag)
    }
}
