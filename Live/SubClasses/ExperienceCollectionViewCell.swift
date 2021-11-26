//
//  ExperienceCollectionViewCell.swift
//  Live
//
//  Created by ITPATH on 4/17/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class ExperienceCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imgExperience:ImageViewForURL!
    @IBOutlet var lblExperienceDisc:UILabel!
    @IBOutlet var lblExperienceCurrency:UILabel!
    @IBOutlet var ratingView:FloatRatingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
    }

}
