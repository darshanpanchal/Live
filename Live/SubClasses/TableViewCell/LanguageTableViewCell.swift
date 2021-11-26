//
//  LanguageTableViewCell.swift
//  Live
//
//  Created by ips on 05/06/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class LanguageTableViewCell: UITableViewCell {
    @IBOutlet weak var lblLanguageName: UILabel!
    @IBOutlet weak var imgRight: UIImageView!
    var language:LocalizableLanguage?
    {
        didSet{
            if let title = language?.title{
                lblLanguageName.text = title
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.imgRight.image = #imageLiteral(resourceName: "tick_select").withRenderingMode(.alwaysTemplate)
            self.imgRight.tintColor = UIColor.init(hexString: "#36527D")
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.lblLanguageName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblLanguageName.adjustsFontForContentSizeCategory = true
        self.lblLanguageName.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
