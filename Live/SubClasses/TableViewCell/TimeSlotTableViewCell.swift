//
//  TimeSlotTableViewCell.swift
//  Live
//
//  Created by ips on 08/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
protocol TimeSlotDelegate {
    func buttonSelector(index:Int)
}

class TimeSlotTableViewCell: UITableViewCell {

    @IBOutlet var lblTimeSlot:UILabel!
    @IBOutlet var lblAvailablePerson:UILabel!
    @IBOutlet var imageSelect:UIImageView!
    @IBOutlet var buttonSelect:UIButton!
    
    var timeSlotDelegate:TimeSlotDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageSelect.image = #imageLiteral(resourceName: "uncheck_update")
    }
    func addDynamicFont(){
        self.lblTimeSlot.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblTimeSlot.adjustsFontForContentSizeCategory = true
        self.lblTimeSlot.adjustsFontSizeToFitWidth = true
        
        self.lblAvailablePerson.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblAvailablePerson.adjustsFontForContentSizeCategory = true
        self.lblAvailablePerson.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func buttonTickSelector(sender:UIButton){
        if let _ = self.timeSlotDelegate?.buttonSelector(index: self.tag){
            self.timeSlotDelegate?.buttonSelector(index: self.tag)
        }
    }
}
