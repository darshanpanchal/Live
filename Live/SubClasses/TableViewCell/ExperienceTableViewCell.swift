//
//  ExperienceTableViewCell.swift
//  Live
//
//  Created by ITPATH on 4/17/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
@objc  protocol ExperienceTableViewCellDelegate {
     @objc optional func seeAllGuideSelector()
    @objc optional func expandCollapsSelector(index:Int)
}
class ExperienceTableViewCell: UITableViewCell {

    @IBOutlet var lblExperienceTitle:UILabel!
    @IBOutlet var lblExperienceDiscription:UILabel!
    @IBOutlet var collectionExperience:UICollectionView!
    @IBOutlet var buttonSeeAllGuide:UIButton!
    @IBOutlet var buttonExpandCollaps:UIButton!
//    @IBOutlet var topSpaceCollection:NSLayoutConstraint!
    var delegateTableViewCell:ExperienceTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let objExperienceNib = UINib.init(nibName: "ExperienceCollectionViewCell", bundle: nil)
        self.collectionExperience.register(objExperienceNib, forCellWithReuseIdentifier: "ExperienceCollectionViewCell")
        
        let objExploreNib = UINib.init(nibName: "ExploreCollectionViewCell", bundle: nil)
        self.collectionExperience.register(objExploreNib, forCellWithReuseIdentifier: "ExploreCollectionViewCell")
        
        let objGuideNib = UINib.init(nibName: "GuideCollectionViewCell", bundle: nil)
        self.collectionExperience.register(objGuideNib, forCellWithReuseIdentifier:"GuideCollectionViewCell")
        
        let objTopExperienceNib = UINib.init(nibName: "TopExperienceCollectionViewCell", bundle: nil)
        self.collectionExperience.register(objTopExperienceNib, forCellWithReuseIdentifier: "TopExperienceCollectionViewCell")
        
        
        self.selectionStyle = .none
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    
    func addDynamicFont(){
        self.lblExperienceTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblExperienceTitle.adjustsFontForContentSizeCategory = true
        self.lblExperienceTitle.adjustsFontSizeToFitWidth = true
        
        self.lblExperienceDiscription.font = CommonClass.shared.getScaledWithOutMinimum(forFont:"Avenir-Book", textStyle: .caption1)
        self.lblExperienceDiscription.adjustsFontForContentSizeCategory = true
        self.lblExperienceDiscription.adjustsFontSizeToFitWidth = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func rotedExpandSelector(isExpand:Bool){
        if isExpand{
            self.buttonExpandCollaps.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
            UIView.animate(withDuration: 0.3, animations: {
               self.buttonExpandCollaps.transform = CGAffineTransform(rotationAngle: CGFloat(0))
            }, completion: { (finished) in
                
            })
        }else{
            self.buttonExpandCollaps.transform = CGAffineTransform(rotationAngle: CGFloat(0))
            UIView.animate(withDuration: 0.3, animations: {
                self.buttonExpandCollaps.transform = CGAffineTransform(rotationAngle: (180.0 * .pi) / 180.0)
            }, completion: { (finished) in
                self.buttonExpandCollaps.transform = CGAffineTransform(rotationAngle: CGFloat(0))
            })
        }
       
    }
    @IBAction func buttonSeeAllGuideSelector(sender:UIButton){
        self.delegateTableViewCell?.seeAllGuideSelector!()
    }
    @IBAction func buttonExpandCollapsSelector(sender:UIButton){
        self.delegateTableViewCell?.expandCollapsSelector!(index: sender.tag)
        
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
         DispatchQueue.main.async {
            self.buttonSeeAllGuide.isHidden = true
            //self.rotedExpandSelector(isExpand: false)
            //self.buttonExpandCollaps.isHidden = true
            //self.buttonExpandCollaps.transform = CGAffineTransform(rotationAngle: CGFloat(0))
//                self.collectionExperience.collectionViewLayout.invalidateLayout()
//                self.collectionExperience.layoutIfNeeded()
//                self.collectionExperience.reloadData()
            }
    }
}
