//
//  ReviewsTableViewCell.swift
//  Live
//
//  Created by ips on 20/04/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class ReviewsTableViewCell: UITableViewCell {
    @IBOutlet weak var reviewCollectionView: UICollectionView!
    @IBOutlet weak var reviewCountLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.reviewCountLabel.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.reviewCountLabel.adjustsFontForContentSizeCategory = true
        self.reviewCountLabel.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

//    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize{
//        self.reviewCollectionView.layoutIfNeeded()
//        return self.reviewCollectionView.collectionViewLayout.collectionViewContentSize
//    }
}
