//
//  GuideCollectionViewCell.swift
//  Live
//
//  Created by ITPATH on 4/19/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import ReadMoreTextView

protocol GuideDescriptionReadMore: class {
    func readMorePressedFromGuideDescription(index: Int)
}

class GuideCollectionViewCell: UICollectionViewCell {
    weak var delegate: GuideDescriptionReadMore?
    var guideIndexNumber: Int?
    @IBOutlet weak var readMoreBtn: UIButton!
    @IBOutlet var guideImage:ImageViewForURL!
    @IBOutlet var lblGuideName:UILabel!
    @IBOutlet var lblGuideDiscription:UILabel!
    @IBOutlet var txtGuideDiscription:ReadMoreTextView!
    @IBOutlet weak var guideDescriptionBtn: UIButton!
    @IBOutlet weak var guideRating:FloatRatingView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.layer.borderColor = UIColor.darkGray.cgColor
//        self.layer.borderWidth = 0.5
//        self.clipsToBounds = true
//        self.txtGuideDiscription.textContainer.maximumNumberOfLines = 3
//        txtGuideDiscription.textContainer.lineBreakMode = .byTruncatingTail
        lblGuideDiscription.isUserInteractionEnabled = true
        txtGuideDiscription.isUserInteractionEnabled = true
        self.guideDescriptionBtn.addTarget(self, action: #selector(buttonSeemoreSelector), for: .touchUpInside)
        self.guideImage.layer.cornerRadius = self.guideImage.frame.width / 2.0
        self.guideImage.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        DispatchQueue.main.async {
            self.txtGuideDiscription.textAlignment = .center
            self.txtGuideDiscription.font = UIFont(name: "Avenir-Roman", size: 14.0)
            self.txtGuideDiscription.textColor = UIColor.black
            self.layoutIfNeeded()
        }
    }
    
    func setReadMore(guideComment: NSMutableAttributedString, comment: String) {
        let strCount = comment.characters.count
        if strCount < 150 {
            txtGuideDiscription.attributedText = guideComment
        } else {
            txtGuideDiscription.attributedText = guideComment
            txtGuideDiscription.textContainer.maximumNumberOfLines = 4
            txtGuideDiscription.isUserInteractionEnabled = true
            let readmoreFont = UIFont(name: "Avenir-Roman", size: 14.0)
            let readmoreFontColor = UIColor(red: 56.0/255.0, green: 114.0/255.0, blue: 170.0/255.0, alpha: 1.0)
            DispatchQueue.main.async {
                self.txtGuideDiscription.addTrailing(with: "... ", moreText: "... read more", moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor, characterLimit: 115, isFromGuideDescription: true)
            }
        }
    }
    
    @objc func handleTapOnLabel(_ recognizer: UITapGestureRecognizer) {
        guard let text = txtGuideDiscription.attributedText?.string else {
            return
        }
        
        if let range = text.range(of: "read more"),
            recognizer.didTapAttributedTextInTextView(label: txtGuideDiscription, inRange: NSRange(range, in: text)) {
            self.buttonSeemoreSelector()
        } else if let range = text.range(of: "_onboarding_privacy"),
            recognizer.didTapAttributedTextInTextView(label: txtGuideDiscription, inRange: NSRange(range, in: text)) {
            //            goToPrivacyPolicy()
        }
    }
    
    @objc func buttonSeemoreSelector() {
        DispatchQueue.main.async {
            if self.guideIndexNumber != nil {
                self.delegate?.readMorePressedFromGuideDescription(index: self.guideIndexNumber!)
            }
        }
    }
    
    func addDynamicFont(){
        self.lblGuideName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblGuideName.adjustsFontForContentSizeCategory = true
        self.lblGuideName.adjustsFontSizeToFitWidth = true
        
//        self.lblGuideDiscription.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
//        self.lblGuideDiscription.adjustsFontForContentSizeCategory = true
//        self.lblGuideDiscription.adjustsFontSizeToFitWidth = true
//
//        self.txtGuideDiscription.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
    }
}
