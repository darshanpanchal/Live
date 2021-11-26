//
//  ExperienceTableViewCell.swift
//  Live
//
//  Created by ITPATH on 4/17/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class ExperienceTableViewCell: UITableViewCell {

    @IBOutlet var lblExperienceTitle:UILabel!
    @IBOutlet var lblExperienceDiscription:UILabel!
    @IBOutlet var collectionExperience:UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let objExperienceNib = UINib.init(nibName: "ExperienceCollectionViewCell", bundle: nil)
        self.collectionExperience.register(objExperienceNib, forCellWithReuseIdentifier: "ExperienceCollectionViewCell")
        
        let objExploreNib = UINib.init(nibName: "ExploreCollectionViewCell", bundle: nil)
        self.collectionExperience.register(objExploreNib, forCellWithReuseIdentifier: "ExploreCollectionViewCell")
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
