//
//  MenuNameTableViewCell.swift
//  Live
//
//  Created by ips on 11/04/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class MenuNameTableViewCell: UITableViewCell {

    @IBOutlet weak var detailImg: UIImageView!
    @IBOutlet weak var menuTitleLbl: UILabel!
    @IBOutlet var lblDetail:UILabel!
    @IBOutlet var bottomlblDetail:NSLayoutConstraint!
    @IBOutlet var bottomlblDetailImage:NSLayoutConstraint!
    @IBOutlet var lblPayPalCheckOut:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.contentView.layer.borderColor = UIColor.lightGray.cgColor
//        self.contentView.layer.borderWidth = 0.5
//        self.setNeedsLayout()
        // Initialization code
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        DispatchQueue.main.async {
            self.layoutIfNeeded()
        }
    }
    func addDynamicFont(){
        self.menuTitleLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .body)
        self.menuTitleLbl.adjustsFontForContentSizeCategory = true
        self.menuTitleLbl.adjustsFontSizeToFitWidth = true
        if let _ = self.lblDetail{
//            self.lblDetail.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
//            self.lblDetail.adjustsFontForContentSizeCategory = true
//            self.lblDetail.adjustsFontSizeToFitWidth = true
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
