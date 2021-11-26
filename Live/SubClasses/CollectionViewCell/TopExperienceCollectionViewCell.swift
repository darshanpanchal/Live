//
//  ExperienceCollectionViewCell.swift
//  Live
//
//  Created by ITPATH on 4/17/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
@objc protocol TopExperienceDelegate{
     @objc optional func didSelectFavSelector(sender:UIButton)
}
class TopExperienceCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imgExperience:ImageViewForURL!
    @IBOutlet var lblExperienceTitle:UILabel!
    @IBOutlet var lblExperienceDisc:UILabel!
    @IBOutlet var lblExperienceCurrency:UILabel!
    @IBOutlet var ratingView:FloatRatingView!
    @IBOutlet var buttonFavourite:UIButton!
    
    var delegate:TopExperienceDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 0.5
        self.clipsToBounds = true
        //Add Shadow on delete button
        self.addShadowOnFav()
    }
    func addShadowOnFav(){
        buttonFavourite.layer.shadowColor = UIColor.white.cgColor
        buttonFavourite.layer.shadowOffset = CGSize.init(width: 0, height:5.0)
        buttonFavourite.layer.shadowOpacity = 1.0
        buttonFavourite.layer.shadowRadius = 5.0
        buttonFavourite.layer.masksToBounds = false
    }
    @IBAction func buttonFavSelector(sender:UIButton){
        if let _ = delegate{
            delegate?.didSelectFavSelector!(sender: sender)
        }
    }
}
