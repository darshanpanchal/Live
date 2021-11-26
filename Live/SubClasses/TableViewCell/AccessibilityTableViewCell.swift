//
//  AccessibilityTableViewCell.swift
//  Live
//
//  Created by ips on 23/04/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class AccessibilityTableViewCell: UITableViewCell {

    @IBOutlet weak var accessibilityCollectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
