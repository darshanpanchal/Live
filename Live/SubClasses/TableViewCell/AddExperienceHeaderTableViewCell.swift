//
//  AddExperienceHeaderTableViewCell.swift
//  Live
//
//  Created by ips on 04/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class AddExperienceHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var addPhotosBtn: RoundButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addPhotosBtn.layer.cornerRadius = 20.0
        self.addPhotosBtn.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
