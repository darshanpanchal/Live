//
//  ReviewCollectionViewCell.swift
//  Live
//
//  Created by ips on 20/04/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import ReadMoreTextView

protocol ReviewCellUpdater: class {
    func reloadReviewCell(tag: Int)
}
@objc protocol readMoreEvent: class {
    func buttonClicked(sender: UILabel?)
}
class ReviewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var reviewTextLbl: UILabel!
    var delegate: ReviewCellUpdater?
    weak var readMore: readMoreEvent?
    @IBOutlet weak var reviewProfileImg: ImageViewForURL!
    @IBOutlet weak var seeMoreBtn: UIButton!
    @IBOutlet weak var reviewView: FloatRatingView!
    @IBOutlet weak var userNameReviewCell: UILabel!
    @IBOutlet weak var dateReviewCell: UILabel!
    @IBOutlet var reviewDetailTxtView:ReadMoreTextView!
    override func awakeFromNib(){
        super.awakeFromNib()
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(handleTapOnLabel(_:)))
        self.reviewTextLbl?.isUserInteractionEnabled = true
        self.reviewTextLbl?.addGestureRecognizer(tapAction)
        //self.reviewTextLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnLabel(_:))))
        self.reviewDetailTxtView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnLabel(_:))))
        DispatchQueue.main.async {
            self.addDynamicFont()
            //self.backgroundColor = UIColor.red
        }
    }
    func addDynamicFont(){
        self.userNameReviewCell.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.userNameReviewCell.adjustsFontForContentSizeCategory = true
        self.userNameReviewCell.adjustsFontSizeToFitWidth = true
        
        self.dateReviewCell.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.dateReviewCell.adjustsFontForContentSizeCategory = true
        self.dateReviewCell.adjustsFontSizeToFitWidth = true
        
        self.reviewTextLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.reviewTextLbl.adjustsFontForContentSizeCategory = true
//        self.reviewTextLbl.adjustsFontSizeToFitWidth = true
        
        
    }
    
    @objc func handleTapOnLabel(_ recognizer: UITapGestureRecognizer) {
        guard let text = self.reviewDetailTxtView.attributedText?.string else{//reviewTextLbl.attributedText?.string else {
            return
        }
        
        if let range = text.range(of: "read more"){
//            recognizer.didTapAttributedTextInLabel(label: self.reviewDetailTxtView, inRange: NSRange(range, in: text)) {
            self.readMore?.buttonClicked(sender: reviewTextLbl)
        }else if let strText = self.reviewTextLbl.text,let range = strText.range(of: "read more"){
            self.readMore?.buttonClicked(sender: reviewTextLbl)
        }else if let range = text.range(of: NSLocalizedString("_onboarding_privacy", comment: "privacy")),
            recognizer.didTapAttributedTextInLabel(label: reviewTextLbl, inRange: NSRange(range, in: text)) {
//            goToPrivacyPolicy()
        }
    }
    
//    @IBAction func seeMoreBtnPressed(_ sender: Any) {
//        //self.contentView.translatesAutoresizingMaskIntoConstraints = false
//        
//    }
}

