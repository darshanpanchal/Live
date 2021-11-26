//
//  AllExperienceTableViewCell.swift
//  Live
//
//  Created by ITPATH on 4/19/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import SDWebImage

class AllExperienceTableViewCell: UITableViewCell,UICollectionViewDelegateFlowLayout {

    @IBOutlet var lblExperienceTitle:UILabel!
    @IBOutlet var collectionExperience:UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let objExperienceNib = UINib.init(nibName: "ExperienceCollectionViewCell", bundle: nil)
        self.collectionExperience.register(objExperienceNib, forCellWithReuseIdentifier: "ExperienceCollectionViewCell")
        self.collectionExperience.isScrollEnabled = false
//        self.collectionExperience.collectionViewLayout.invalidateLayout()
//        self.collectionExperience.layoutIfNeeded()
//        let collectionLayout:UICollectionViewFlowLayout = self.collectionExperience.collectionViewLayout as! UICollectionViewFlowLayout
//        collectionLayout.estimatedItemSize = CGSize.init(width: 1, height: 1)
//        self.layoutSubviews()
        self.selectionStyle = .none
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.lblExperienceTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblExperienceTitle.adjustsFontForContentSizeCategory = true
        self.lblExperienceTitle.adjustsFontSizeToFitWidth = true
    }
//    override func layoutSubviews() {
//        super.layoutSubviews()
//    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        DispatchQueue.main.async {
            //self.collectionExperience.reloadData()
        }
        
    }
//    var collectionViewLayout: UICollectionViewFlowLayout? {
//        return collectionExperience.collectionViewLayout as? UICollectionViewFlowLayout
//    }
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        DispatchQueue.main.async {
//            /*
//            self.collectionExperience.collectionViewLayout.invalidateLayout()
//            self.collectionExperience.layoutIfNeeded()
//
//            let imageCache = SDImageCache.shared()
//            imageCache.clearMemory()
//            imageCache.clearDisk {
//
//            }*/
//           // self.collectionExperience.reloadData()
//        }
//    }
    
    // MARK: -
    // MARK: UIView functions
//    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
//        
//        //self.collectionExperience.layoutIfNeeded()
////        let topConstraintConstant = self.contentView.constraint(byIdentifier: "topAnchor")?.constant ?? 0
////        let bottomConstraintConstant = contentView.constraint(byIdentifier: "bottomAnchor")?.constant ?? 0
////        let trailingConstraintConstant = contentView.constraint(byIdentifier: "trailingAnchor")?.constant ?? 0
////        let leadingConstraintConstant = contentView.constraint(byIdentifier: "leadingAnchor")?.constant ?? 0
////
////        self.collectionExperience.frame = CGRect(x: 0, y: 0, width: targetSize.width - trailingConstraintConstant - leadingConstraintConstant, height: 1)
//        
//        let size = self.collectionExperience.collectionViewLayout.collectionViewContentSize
//        let newSize = CGSize(width: size.width, height: size.height)// + topConstraintConstant + bottomConstraintConstant)
//        return newSize
//    }
    
}
