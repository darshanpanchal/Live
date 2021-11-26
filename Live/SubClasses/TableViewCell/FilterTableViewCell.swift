//
//  FilterTableViewCell.swift
//  Live
//
//  Created by ITPATH on 4/19/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class FilterTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
