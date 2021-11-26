//
//  MenuTableViewCustomCell.swift
//  Live
//
//  Created by ips on 11/04/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class MenuTableViewCustomCell: UITableViewCell {
    @IBOutlet weak var profileImg: ImageViewForURL!
    @IBOutlet weak var profileName: UILabel!
     @IBOutlet weak var anonymousName: UILabel!
    @IBOutlet weak var profileCity: UILabel!
    @IBOutlet weak var objSegmentController: UISegmentedControl!
    @IBOutlet weak var profileEditImg: UIImageView!
    @IBOutlet weak var buttonProfileImage: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImg.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
        profileImg.layer.borderWidth = 1.0
        profileImg.layer.cornerRadius = 50.0
        profileImg.clipsToBounds = true
        self.objSegmentController.layer.cornerRadius = 14.0
        self.objSegmentController.clipsToBounds = true
        self.objSegmentController.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.lightGray.cgColor
        self.contentView.layer.borderWidth = 0.5
        let profileEditImage = #imageLiteral(resourceName: "editprofile").withRenderingMode(.alwaysTemplate)
        self.profileEditImg.image = profileEditImage
        self.setNeedsLayout()
        profileImg.contentMode = .scaleAspectFill
        profileImg.clipsToBounds = true
        // Initialization code
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        
        self.profileCity.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Book", textStyle: .title1)
        self.profileCity.adjustsFontForContentSizeCategory = true
        self.profileCity.adjustsFontSizeToFitWidth = true
        
        self.profileName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.profileName.adjustsFontForContentSizeCategory = true
        self.profileName.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
