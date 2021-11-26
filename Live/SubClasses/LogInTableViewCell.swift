//
//  LogInTableViewCell.swift
//  Live
//
//  Created by ITPATH on 4/4/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class LogInTableViewCell: UITableViewCell {

    @IBOutlet var textFieldLogIn:TweeActiveTextField!
    @IBOutlet var btnDropDown:UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setTextFieldColor(color:UIColor){
        self.textFieldLogIn.textColor = color
        self.textFieldLogIn.activeLineColor = color
        self.textFieldLogIn.lineColor = color
        self.textFieldLogIn.placeholderColor = color
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
