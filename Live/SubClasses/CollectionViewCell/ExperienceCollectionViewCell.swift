//
//  ExperienceCollectionViewCell.swift
//  Live
//
//  Created by ITPATH on 4/17/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import SDWebImage
import MapleBacon

@objc protocol ExperienceDelegate{
     @objc optional func didSelectDeleteSelector(sender:UIButton)
     @objc optional func didSelectCancelSelector(sender:UIButton)
     @objc optional func didActiveInActiveSelector(sender:UIButton)
     @objc optional func didSelectMoreOption(sender:UIButton)
     @objc optional func didSelectFavSelector(sender:UIButton)
     @objc optional func didSelectUserInvite(sender:UIButton)
     @objc optional func didSelectUberRideSelector(sender:UIButton)
     @objc optional func didSelectShareExperienceSelector(sender:UIButton)
     @objc optional func didSelectLikeExperienceSelector(sender:UIButton)
}
class ExperienceCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var circularView: UIView!
    @IBOutlet weak var payBtnBorderView: UIView!
    @IBOutlet weak var imgExperience:ImageViewForURL!
    @IBOutlet var lblExperienceDisc:UILabel!
    @IBOutlet var lblExperienceCurrency:UILabel!
    @IBOutlet var ratingView:FloatRatingView!
    @IBOutlet var buttonDelete:UIButton!
    @IBOutlet var buttonCancel:UIButton!
    @IBOutlet var buttonActive:UIButton!
    @IBOutlet var activeInActiveContainer:UIView!
    @IBOutlet var lblActiveInactive:UILabel!
    @IBOutlet var buttonActiveInActive:UIButton!
    @IBOutlet var lblMinimumPrice:UILabel!
    @IBOutlet var otherOptionBtn:UIButton!
    @IBOutlet var payContainerView:UIView!
    @IBOutlet var payBtn:UIButton!
    @IBOutlet var lblPendingExperienceDate:UILabel!
    @IBOutlet var lblPendingExperienceTime:UILabel!
    @IBOutlet var instantImg:UIImageView!
    @IBOutlet weak var avtiveInctiveContainerWidthConstant: NSLayoutConstraint!
    @IBOutlet var buttonFav:UIButton!
    @IBOutlet var mainContainerView:UIView!
    @IBOutlet var userReviewView:UIView!
    @IBOutlet var shadowViewRating:UIView!
    @IBOutlet var lblUserRating:UILabel!
    
    @IBOutlet var btnUserInvite:UIButton!
    @IBOutlet var buttonInvited:RoundButton! //invited
    var delegate:ExperienceDelegate?
    @IBOutlet var buttonUberRide:RoundButton!
    @IBOutlet var buttonUberRideTop:NSLayoutConstraint! //15 65
    
    @IBOutlet var viewContainerForShareAndLike:UIView!
    @IBOutlet var btnAddToLike:UIButton!
    @IBOutlet var btnShare:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userReviewView.clipsToBounds = true
        self.userReviewView.layer.cornerRadius = 15.0
        self.otherOptionBtn.layer.cornerRadius = self.otherOptionBtn.frame.size.height / 2
        self.otherOptionBtn.clipsToBounds = true
        self.payBtn.layer.cornerRadius = self.payBtn.frame.size.height / 2
//        self.payBtn.setBorder(width: 1.0, color: .white)
        self.payBtn.clipsToBounds = true
        self.payBtnBorderView.layer.cornerRadius = self.payBtnBorderView.frame.size.height / 2
        self.payBtnBorderView.clipsToBounds = true
        self.buttonInvited.setTitle(Vocabulary.getWordFromKey(key: "invited.hint"), for: .normal)
        self.buttonCancel.setTitle(Vocabulary.getWordFromKey(key: "Cancel"), for: .normal)
        self.circularView.layer.cornerRadius = self.circularView.frame.size.width / 2
        self.circularView.clipsToBounds = true
        self.mainContainerView.layer.borderColor = UIColor(hexString: "#D9D9D9").cgColor
        self.mainContainerView.layer.borderWidth = 0.5
        self.mainContainerView.clipsToBounds = true
        self.buttonCancel.layer.cornerRadius = 15.0
        self.buttonActive.clipsToBounds = true
        self.buttonActive.layer.cornerRadius = buttonActive.frame.width / 2.0
//        self.buttonActive.layer.borderWidth = 1.0
        self.mainContainerView.layer.cornerRadius = 4.0
        self.clipsToBounds = false
        self.buttonDelete.clipsToBounds = true
        self.buttonDelete.layer.cornerRadius = 15.0
        self.buttonActive.layer.borderColor = UIColor.white.cgColor
        self.activeInActiveContainer.layer.cornerRadius = 15.0
        self.activeInActiveContainer.clipsToBounds = true
        //Add Shadow on delete button
//        self.addShadowOnDelete()
        self.btnAddToLike.imageView?.contentMode = .scaleAspectFit
        DispatchQueue.main.async {
//            self.addDynamicFont()
        }
    }
    override func prepareForReuse() {
//        self.imgExperience = nil
        super.prepareForReuse()
        self.viewContainerForShareAndLike.isHidden = true
        self.btnUserInvite.isHidden = true
        self.buttonInvited.isHidden = true
        self.payBtn.isHidden = true
        self.payBtnBorderView.isHidden = true
        self.payContainerView.isHidden = true
        self.buttonUberRide.isHidden = true
//        self.imgExperience.sd_cancelCurrentImageLoad()
//        self.imgExperience.image = UIImage(named: "expriencePlaceholder")!
//        let imageCache = SDImageCache.shared()
//        imageCache.clearMemory()
//        imageCache.clearDisk {
//
//        }
    }
    func addDynamicFont(){
//        self.lblExperienceDisc.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
//        self.lblExperienceDisc.adjustsFontForContentSizeCategory = true
//        self.lblExperienceDisc.adjustsFontSizeToFitWidth = true
//        
//        self.lblExperienceCurrency.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
//        self.lblExperienceCurrency.adjustsFontForContentSizeCategory = true
//        self.lblExperienceCurrency.adjustsFontSizeToFitWidth = true
    }
    func loadImage(url:String?){
        DispatchQueue.main.async {
            if url != nil {
                self.imgExperience.sd_setImage(with: URL.init(string: url!), placeholderImage: UIImage(named: "expriencePlaceholder")!) { (image: UIImage?, error: Error?, cacheType:SDImageCacheType!, imageURL: URL?) in
                    if let _ = image{
                        //new size
                        
                        self.imgExperience.image = self.resizeImage(image: image!, newWidth: self.imgExperience.bounds.width*3)
                    }else{
                        //new size
                        self.imgExperience.image = self.resizeImage(image:UIImage(named: "expriencePlaceholder")!, newWidth:  self.imgExperience.bounds.width)
                    }
                }
            }else{
                self.imgExperience.image = UIImage(named: "expriencePlaceholder")!
            }
        }
    }
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    func addShadowOnDelete(){
        buttonDelete.layer.shadowColor = UIColor.white.cgColor
        buttonDelete.layer.shadowOffset = CGSize.init(width: 0, height:5.0)
        buttonDelete.layer.shadowOpacity = 1.0
        buttonDelete.layer.shadowRadius = 5.0
        buttonDelete.layer.masksToBounds = false
    }
    @IBAction func buttonCancelSelector(sender:UIButton){
        if let _ = delegate{
            delegate?.didSelectCancelSelector!(sender: sender)
        }
    }
    @IBAction func buttonDeleteSelector(sender:UIButton){
        if let _ = delegate{
            delegate?.didSelectDeleteSelector!(sender: sender)
        }
    }
    @IBAction func buttonActiveInActiveSelector(sender:UIButton){
        if let _ = delegate{
            delegate?.didActiveInActiveSelector!(sender: sender)
        }
    }
    @IBAction func didSelectMoreOption(sender:UIButton){
        if let _ = delegate{
            
            delegate?.didSelectMoreOption!(sender: sender)
        }
    }
    @IBAction func didSelectFavSelector(sender:UIButton){
        if let _ = delegate{
            delegate?.didSelectFavSelector!(sender: sender)
        }
    }
    @IBAction func buttonUserInviteSelector(sender:UIButton){
        if let _ = delegate{
            delegate?.didSelectUserInvite!(sender: sender)
        }
    }
    @IBAction func buttonUberRideSelector(sender:UIButton){
        if let _ = delegate{
            delegate?.didSelectUberRideSelector!(sender: sender)
        }
    }
    @IBAction func buttonShareSelector(sender:UIButton){
        if let _ = delegate{
            delegate?.didSelectShareExperienceSelector!(sender: sender)
        }
    }
    @IBAction func buttonLikeSelector(sender:UIButton){
        if let _ = delegate{
            delegate?.didSelectLikeExperienceSelector!(sender: sender)
        }
    }
}
