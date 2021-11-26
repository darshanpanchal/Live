//
//  CouponDetailViewController.swift
//  Live
//
//  Created by IPS on 10/10/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class CouponDetailViewController: UIViewController {

    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var lblExpire:UILabel!
    @IBOutlet var lblCoupon:UILabel!
    @IBOutlet var lblCoponDiscription:UILabel!
    @IBOutlet var imgCoupon:ImageViewForURL!
    @IBOutlet var imgQrCode:ImageViewForURL!
    @IBOutlet var tableViewCouponDetail:UITableView!
    
    var objCoupon:Coupon?
    var strExpire:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let _ = self.objCoupon{
            self.configureCoupondetail(objCoupon: self.objCoupon!)
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableViewCouponDetail.updateHeaderViewHeight()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.tableViewCouponDetail.tableFooterView = UIView()
            self.tableViewCouponDetail.estimatedSectionHeaderHeight = UITableViewAutomaticDimension
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Selection Methods
    func configureCoupondetail(objCoupon:Coupon){
        if self.strExpire.count > 0{
            self.lblExpire.text = "\(strExpire)"
            var couponCurrency = ""
            if objCoupon.currency.count > 0 {
                couponCurrency = " (\(objCoupon.currency))"
            }
            self.lblCoupon.text = "\(objCoupon.couponID)" + couponCurrency
            self.lblCoponDiscription.text = "\(objCoupon.discription)"
            self.imgCoupon.imageFromServerURL(urlString: "\(objCoupon.image)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, placeHolder: #imageLiteral(resourceName: "voucher").withRenderingMode(.alwaysOriginal))
            self.imgCoupon.contentMode = .scaleAspectFill
            self.imgQrCode.imageFromServerURL(urlString: "\(objCoupon.qrCode)", placeHolder:UIImage())
        }
    }

    // MARK: - Selection Methods
    @IBAction func buttonCloseSelector(sender:UIButton){
            self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
extension UITableView {
    func updateHeaderViewHeight() {
        if let header = self.tableHeaderView {
            let newSize = header.systemLayoutSizeFitting(CGSize(width: self.bounds.width, height: 0))
            header.frame.size.height = newSize.height
        }
    }
}
