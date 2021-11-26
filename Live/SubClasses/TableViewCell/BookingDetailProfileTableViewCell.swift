//
//  BookingDetailProfileTableViewCell.swift
//  Live
//
//  Created by ips on 16/04/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import ReadMoreTextView

protocol CustomCellUpdater: class {
    func updateGuideProfileRow()
    func updateTimeAndRateRow()
}

class BookingDetailProfileTableViewCell: UITableViewCell {
    weak var delegate: CustomCellUpdater?
    @IBOutlet weak var guideDetailTxtView: ReadMoreTextView!
    @IBOutlet weak var guideDetailLbl: UILabel!
    @IBOutlet weak var guideNameLbl: UILabel!
    @IBOutlet weak var theGuideLbl: UILabel!
    @IBOutlet weak var profilePicImage: ImageViewForURL!
    @IBOutlet weak var seeMoreBtn: UIButton!
    @IBOutlet var ratingView:FloatRatingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.theGuideLbl.text = Vocabulary.getWordFromKey(key: "theGuide")
        profilePicImage.contentMode = .scaleAspectFill
        profilePicImage.clipsToBounds = true
        self.profilePicImage.circularImg(imgWidth: self.profilePicImage.frame.size.width)
        guideDetailTxtView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnLabel(_:))))
        // Initialization code
//        DispatchQueue.main.async {
//            self.addDynamicFont()
//        }
    }
    func addDynamicFont(){
        self.theGuideLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.theGuideLbl.adjustsFontForContentSizeCategory = true
        self.theGuideLbl.adjustsFontSizeToFitWidth = true
        
        self.guideNameLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.guideNameLbl.adjustsFontForContentSizeCategory = true
        self.guideNameLbl.adjustsFontSizeToFitWidth = true
        
        self.guideDetailLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.guideDetailLbl.adjustsFontForContentSizeCategory = true
        self.guideDetailLbl.adjustsFontSizeToFitWidth = true
        
        self.guideDetailTxtView.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        
        self.seeMoreBtn.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.seeMoreBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        self.seeMoreBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        DispatchQueue.main.async {
            self.guideDetailTxtView.font = UIFont(name: "Avenir-Roman", size: 14.0)
            self.guideDetailTxtView.textColor = UIColor.black
            self.layoutIfNeeded()
        }
    }
    
    @objc func handleTapOnLabel(_ recognizer: UITapGestureRecognizer) {
        self.guideDetailTxtView.textContainer.maximumNumberOfLines = 0
        self.buttonSeemoreSelector()
        /*
        guard let text = guideDetailTxtView.attributedText?.string else {
            return
        }
        
        if let range = text.range(of: "read more"),
            recognizer.didTapAttributedTextInTextView(label: guideDetailTxtView, inRange: NSRange(range, in: text)) {
            self.buttonSeemoreSelector()
        } else if let range = text.range(of: "_onboarding_privacy"),
            recognizer.didTapAttributedTextInTextView(label: guideDetailTxtView, inRange: NSRange(range, in: text)) {
            //            goToPrivacyPolicy()
        }*/
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    // See More Button Action
    func buttonSeemoreSelector() {
        DispatchQueue.main.async {
            self.delegate?.updateGuideProfileRow()
        }
    }
}
