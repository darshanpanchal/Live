//
//  UserListCell.swift
//  Live
//
//  Created by ips on 26/04/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class UserListCell: UITableViewCell {
 @IBOutlet weak var usernameLbl: UILabel!
 @IBOutlet weak var experImg: ImageViewForURL?
 @IBOutlet weak var lblUserName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
