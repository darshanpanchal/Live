//
//  LocationRequestTableViewCell.swift
//  Live
//
//  Created by ips on 14/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class LocationRequestTableViewCell: UITableViewCell {
    @IBOutlet var locationRequestFields:TweeActiveTextField!
    @IBOutlet var selectCountry:UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
