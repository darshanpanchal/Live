//
//  BookingDetailRateandTimeTableViewCell.swift
//  Live
//
//  Created by ips on 16/04/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import ReadMoreTextView

class BookingDetailRateandTimeTableViewCell: UITableViewCell{
    weak var delegate: CustomCellUpdater?
    @IBOutlet weak var placeTitleLbl: UILabel!
    @IBOutlet weak var profileImgGuide: ImageViewForURL!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var seeMoreBtn: UIButton!
    @IBOutlet weak var timeDuration: UILabel!
    @IBOutlet weak var placeDetailLbl: UILabel!
    @IBOutlet weak var currencyLbl: UILabel!
    @IBOutlet weak var peopleCapacityLbl: UILabel!
    @IBOutlet weak var placeDetailTxtView: ReadMoreTextView!
    @IBOutlet weak var nameGuideLbl: UILabel!
    @IBOutlet weak var maxPeopleLbl: UILabel!
    @IBOutlet weak var minPeopleLbl: UILabel!
    @IBOutlet weak var lblLanguages:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImgGuide.layer.cornerRadius = self.profileImgGuide.frame.width / 2.0
        self.profileImgGuide.clipsToBounds = true
        self.contentView.clipsToBounds = false
        self.profileImgGuide.layer.borderColor = UIColor.white.cgColor
        self.profileImgGuide.layer.borderWidth = 2.0
        DispatchQueue.main.async {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOnLabel(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.delegate = self
            //self.placeDetailTxtView.addGestureRecognizer(tapGesture)
            self.bringSubview(toFront: self.contentView)
            //self.addDynamicFont()
        }
        self.placeDetailTxtView.isUserInteractionEnabled = true
        self.placeDetailTxtView.delegate = self
        self.placeDetailTxtView.isEditable = false
        self.placeDetailTxtView.delaysContentTouches = false
        // required for tap to pass through on to superview & for links to work
        self.placeDetailTxtView.isScrollEnabled = false
        self.placeDetailTxtView.isSelectable = true
    }
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self.placeDetailTxtView) {
            guard let range = self.placeDetailTxtView.text?.range(of: "read more") else {
                return
            }
            let index = self.placeDetailTxtView.layoutManager.characterIndex(for: point, in: self.placeDetailTxtView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            if index < self.placeDetailTxtView.textStorage.length{
                if self.placeDetailTxtView.textStorage.length > 13{
                    if index >= self.placeDetailTxtView.textStorage.length - 13{
                        self.buttonSeemoreSelector()
                    }
                }else{
                     self.buttonSeemoreSelector()
                }
                
                }
            }
            print("====== \(index) =======")
            /*
            if self.placeDetailTxtView.pointIsInTextRange(point: point, range: range as! NSRange, padding: UIEdgeInsets.zero){
                self.buttonSeemoreSelector()
            }*/
        
       // super.touchesEnded(touches, with: event)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    func addDynamicFont(){
        self.placeTitleLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.placeTitleLbl.adjustsFontForContentSizeCategory = true
        self.placeTitleLbl.adjustsFontSizeToFitWidth = true
        
//        self.timeDuration.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Book", textStyle: .title1)
//        self.timeDuration.adjustsFontForContentSizeCategory = true
//        self.timeDuration.adjustsFontSizeToFitWidth = true
//        
//        self.peopleCapacityLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Book", textStyle: .title1)
//        self.peopleCapacityLbl.adjustsFontForContentSizeCategory = true
//        self.peopleCapacityLbl.adjustsFontSizeToFitWidth = true
//        
//        self.effortLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Book", textStyle: .title1)
//        self.effortLbl.adjustsFontForContentSizeCategory = true
//        self.effortLbl.adjustsFontSizeToFitWidth = true
        
//        self.placeDetailLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Book", textStyle: .title1)
//        self.placeDetailLbl.adjustsFontForContentSizeCategory = true
//        self.placeDetailLbl.adjustsFontSizeToFitWidth = true
//
//        self.placeDetailTxtView.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
//
//        self.seeMoreBtn.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
//        self.seeMoreBtn.titleLabel?.adjustsFontForContentSizeCategory = true
//        self.seeMoreBtn.titleLabel?.adjustsFontSizeToFitWidth = true
//
//        self.maxPeopleLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
//        self.maxPeopleLbl.adjustsFontForContentSizeCategory = true
//        self.maxPeopleLbl.adjustsFontSizeToFitWidth = true
//
//        self.minPeopleLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
//        self.minPeopleLbl.adjustsFontForContentSizeCategory = true
//        self.minPeopleLbl.adjustsFontSizeToFitWidth = true
        
    }
    @IBOutlet weak var effortLbl: UILabel!
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        // Configure the view for the selected state
//    }
    
    // See More Button Action
    func buttonSeemoreSelector() {
        //DispatchQueue.main.async {
            self.delegate?.updateTimeAndRateRow()
        //}
    }
    
    @objc func handleTapOnLabel(_ recognizer: UITapGestureRecognizer) {
        
        guard let text = placeDetailTxtView.attributedText?.string else {
            return
        }
        
        if let range = text.range(of: "read more"),
            recognizer.didTapAttributedTextInTextView(label: placeDetailTxtView, inRange: NSRange(range, in: text)) {
            self.buttonSeemoreSelector()
        } else if let range = text.range(of: "_onboarding_privacy"),
            recognizer.didTapAttributedTextInTextView(label: placeDetailTxtView, inRange: NSRange(range, in: text)) {
            //            goToPrivacyPolicy()
        }
    }
    
}
extension BookingDetailRateandTimeTableViewCell:UITextViewDelegate{
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}
