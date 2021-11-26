//
//  CheckOutViewController.swift
//  Live
//
//  Created by ips on 11/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import Alamofire

class CheckOutViewController: UIViewController,UIGestureRecognizerDelegate {
    
    private var kBookingDate:String = "date"
    private var kExperienceID:String = "experience_id"
    private var kLocationID:String = "location_id"
    private var kPaymentID:String = "payment_method_id"
    private var kPrice:String = "price"
    private var kNumberOfSlot:String = "slots"
    private var kBookingTime:String = "time"
    private var kUserID:String = "user_id"
    private var kUserName:String = "user_name"
    private var kIsInstant:String = "isinstant"
    private var kIsGroupBooking:String = "isgroup_booking"
    private var kCoupen:String = "coupon"
    private var kIsBrainTreePayment:String = "isPaypalPayment"
    private var kPaymentTransactionID:String = "transaction_id"
    
    @IBOutlet var btnBack:UIButton!
    @IBOutlet var btnBook:UIButton!
    @IBOutlet var lblExperienceTitle:UILabel!
    @IBOutlet var lblDate:UILabel!
    @IBOutlet var lblDateValue:UILabel!
    @IBOutlet var lblTime:UILabel!
    @IBOutlet var lblTimeValue:UILabel!
    @IBOutlet var lblNumberOfGuest:UILabel!
    @IBOutlet var lblNumberOfGuestValue:UILabel!
    @IBOutlet var lblLanguage:UILabel!
    @IBOutlet var lblLanguageValue:UILabel!
    @IBOutlet var lblCreditCard:UILabel!
    @IBOutlet var lblCrediCardNUmber:UILabel!
    @IBOutlet var imgCreditCard:UIImageView!
    @IBOutlet var lblAmount:UILabel!
    @IBOutlet var lblAmountDetail:UILabel!
    @IBOutlet var lblTotalAmount:UILabel!
    @IBOutlet var lblNavTitle:UILabel!
    @IBOutlet var tableViewCheckOut:UITableView!
    @IBOutlet var ammountContainerView:UIView!
    @IBOutlet var noInterNetView:UIView!
    @IBOutlet var tryAgainButton:UIButton!
    @IBOutlet var languageContainerView:UIView!
    @IBOutlet var widthOfCloseConstraint:NSLayoutConstraint!
    @IBOutlet var buttonClearCouponCode:UIButton!
    @IBOutlet var txtCoupenCode:TweeActiveTextField!
    @IBOutlet var buttonApply:UIButton!
    @IBOutlet var lblOrignalPrice:UILabel!
    @IBOutlet var lblDiscount:UILabel!
    @IBOutlet var viewCouponContainer:UIView!
    @IBOutlet var shadowView:UIView!
    @IBOutlet var trailingApplyConstraint:NSLayoutConstraint!
    @IBOutlet var bottomOfTotalAmountConstraint:NSLayoutConstraint!
    @IBOutlet var tableViewHeaderContainer:UIView!
    @IBOutlet var gradientContainer:UIView!
    @IBOutlet var creditCardContainer:UIView!
    @IBOutlet var tableViewHeaderHeight:NSLayoutConstraint!
    @IBOutlet var tableViewHeaderShadowHeight:NSLayoutConstraint!
    @IBOutlet var durationContainer:UIView!
    @IBOutlet var lblDuration:UILabel!
    @IBOutlet var lblDurationValue:UILabel!
    
    
    var isBookingWith100Discount:Bool = false
    var coupen:String = ""
    var timeStr:String = ""
    var strCouponCurrency:String = ""
    var strCoupenCode:String {
        get{
            return self.coupen
        }
        set{
            self.coupen = newValue
            if newValue.count == 0{
                self.experienceBookingParameters[self.kCoupen] = newValue
            }
            self.enableDisableBooking(isEnable:newValue.count == 0)
        }
    }
    var originalPrice:String = ""
    var discountPrice:String = ""
    var isGroupBooking:Bool?
    var objExperience:PendingExperience?
    var numberOfGuest:Int = 1
    var objTimeSlot:Slot?
    var bookingDate:String = ""
    var objCard:CreditCard?
    var experienceBookingParameters:[String:String] = [ : ]
    var validCoupenCodeParameters:[String:String] = [:]
    var isInstantBooking:Bool = false
    var isBrainTreePayment:Bool = false
    var payPalConfiguration:PayPalConfiguration = PayPalConfiguration()
    var paymentID:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //paypalConfiguration
        payPalConfiguration.acceptCreditCards = false

        
        self.lblNavTitle.text = Vocabulary.getWordFromKey(key: "checkOut")
        self.lblDate.text = Vocabulary.getWordFromKey(key: "date")
        self.lblTime.text = Vocabulary.getWordFromKey(key: "Time")
        self.lblNumberOfGuest.text = Vocabulary.getWordFromKey(key: "NumberOfGuest")
        self.lblLanguage.text = Vocabulary.getWordFromKey(key: "whichLanguage")
        if let _ = objCard{
            self.lblCreditCard.text = Vocabulary.getWordFromKey(key: "creditCard")
        }else{
            self.lblCreditCard.text = Vocabulary.getWordFromKey(key: "")
        }
        self.lblAmount.text = Vocabulary.getWordFromKey(key: "amount")
        self.btnBook.setTitle(Vocabulary.getWordFromKey(key: "bookAndPay"), for: .normal)
        self.lblDuration.text = Vocabulary.getWordFromKey(key: "duration")
        if let _ = self.objExperience{
            if let _ = self.isGroupBooking,self.isGroupBooking!{
              self.originalPrice =  "\(self.objExperience!.price)"//"\(Double(self.numberOfGuest) * Double("\(self.objExperience!.priceperson)")!)"
            }else{
              self.originalPrice =  "\(self.objExperience!.price)"//"\(Double(self.numberOfGuest) * Double("\(self.objExperience!.price)")!)"
            }
        }
        self.discountPrice = self.originalPrice
        //Configure CheckOutView
        self.configureCheckOutView()
        self.buttonClearCouponCode.setImage(#imageLiteral(resourceName: "close_dark").withRenderingMode(.alwaysTemplate), for: .normal)
        self.buttonClearCouponCode.imageView?.tintColor = UIColor.black
        self.buttonClearCouponCode.imageView?.contentMode = .scaleAspectFit
        self.btnBack.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.btnBack.imageView?.tintColor = UIColor.black
        self.hideCloseSelector()
        self.viewCouponContainer.isHidden = false//self.isBrainTreePayment
        self.creditCardContainer.isHidden = self.isBrainTreePayment
        DispatchQueue.main.async {
            if self.isBrainTreePayment{
                if let _ = self.objExperience{
                    if self.objExperience!.ishourly{
                        self.tableViewHeaderHeight.constant = 536 + 75
                        self.tableViewHeaderShadowHeight.constant = 536 + 75
                        self.durationContainer.isHidden = false
                    }else{
                        self.tableViewHeaderHeight.constant = 536
                        self.tableViewHeaderShadowHeight.constant = 536
                        self.durationContainer.isHidden = true
                    }
                }
            }else{
                if self.objExperience!.ishourly{
                    self.tableViewHeaderHeight.constant = 608 + 75
                    self.tableViewHeaderShadowHeight.constant = 608 + 75
                    self.durationContainer.isHidden = false
                }else{
                    self.tableViewHeaderHeight.constant = 608
                    self.tableViewHeaderShadowHeight.constant = 608
                    self.durationContainer.isHidden = true
                }
            }
            
            if let _ = self.tableViewCheckOut.tableHeaderView{
                self.tableViewCheckOut.tableHeaderView?.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.tableViewCheckOut.bounds.width, height:self.objExperience!.ishourly ? 765 : 690))
            }
        }
        self.addGradient()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if kAppDel.isPayPalSandBox{
            PayPalMobile.preconnect(withEnvironment:PayPalEnvironmentSandbox)
        }else{
            PayPalMobile.preconnect(withEnvironment:PayPalEnvironmentProduction)
        }
        
//        self.buttonApply.layer.borderWidth = 1.0
//        self.buttonApply.layer.borderColor = UIColor.clear.cgColor
//        self.buttonApply.setTitle(Vocabulary.getWordFromKey(key: "apply"), for: .normal)
        self.txtCoupenCode.tweePlaceholder = Vocabulary.getWordFromKey(key: "enterCoupon.hint")
        self.txtCoupenCode.minimumPlaceHolder = Vocabulary.getWordFromKey(key: "enterCoupon.hint")
//        DispatchQueue.main.async {
//            if UIScreen.main.bounds.height == 568{
//                self.txtCoupenCode.originalPlaceholderFontSize = 16.0
//            }else{
//                self.txtCoupenCode.originalPlaceholderFontSize = 18.0
//            }
//        }
        DispatchQueue.main.async {
            self.addDynamicFont()
            self.swipeToPop()
        }
    }
    func swipeToPop() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func addGradient(){
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame.size = self.gradientContainer.frame.size
        gradientLayer.colors =
            [UIColor.init(hexString: "f4f2f3").withAlphaComponent(1.0),UIColor.init(hexString: "f4f2f3").withAlphaComponent(0.1)]
        //Use diffrent colors
        self.gradientContainer.layer.addSublayer(gradientLayer)
    }
    func addDynamicFont(){
        self.lblNavTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblNavTitle.adjustsFontForContentSizeCategory = true
        self.lblNavTitle.adjustsFontSizeToFitWidth = true
        
//        self.lblExperienceTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
//        self.lblExperienceTitle.adjustsFontForContentSizeCategory = true
//        self.lblExperienceTitle.adjustsFontSizeToFitWidth = true
        
        self.lblDate.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblDate.adjustsFontForContentSizeCategory = true
        self.lblDate.adjustsFontSizeToFitWidth = true
        
        self.lblDateValue.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblDateValue.adjustsFontForContentSizeCategory = true
        self.lblDateValue.adjustsFontSizeToFitWidth = true
        
        self.lblTime.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblTime.adjustsFontForContentSizeCategory = true
        self.lblTime.adjustsFontSizeToFitWidth = true
        
        self.lblTimeValue.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblTimeValue.adjustsFontForContentSizeCategory = true
        self.lblTimeValue.adjustsFontSizeToFitWidth = true
        
        self.lblNumberOfGuest.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblNumberOfGuest.adjustsFontForContentSizeCategory = true
        self.lblNumberOfGuest.adjustsFontSizeToFitWidth = true
        
        self.lblNumberOfGuestValue.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblNumberOfGuestValue.adjustsFontForContentSizeCategory = true
        self.lblNumberOfGuestValue.adjustsFontSizeToFitWidth = true
        
        self.lblLanguage.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblLanguage.adjustsFontForContentSizeCategory = true
        self.lblLanguage.adjustsFontSizeToFitWidth = true
        
        self.lblLanguageValue.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblLanguageValue.adjustsFontForContentSizeCategory = true
        self.lblLanguageValue.adjustsFontSizeToFitWidth = true
        
        self.lblCreditCard.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblCreditCard.adjustsFontForContentSizeCategory = true
        self.lblCreditCard.adjustsFontSizeToFitWidth = true
        
        self.lblDuration.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblDuration.adjustsFontForContentSizeCategory = true
        self.lblDuration.adjustsFontSizeToFitWidth = true
        
        self.lblDurationValue.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblDurationValue.adjustsFontForContentSizeCategory = true
        self.lblDurationValue.adjustsFontSizeToFitWidth = true
        
        self.lblCrediCardNUmber.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblCrediCardNUmber.adjustsFontForContentSizeCategory = true
        self.lblCrediCardNUmber.adjustsFontSizeToFitWidth = true
        
        self.buttonApply.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonApply.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonApply.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.btnBook.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.btnBook.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnBook.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.txtCoupenCode.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1).pointSize
        self.txtCoupenCode.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtCoupenCode.adjustsFontForContentSizeCategory = true
        
        self.tryAgainButton.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.tryAgainButton.titleLabel?.adjustsFontForContentSizeCategory = true
        self.tryAgainButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Methods
    func showCloseSelector(){
        self.trailingApplyConstraint.constant = 70.0
        self.widthOfCloseConstraint.constant = 35.0
    }
    func hideCloseSelector(){
        self.trailingApplyConstraint.constant = 20.0
        self.widthOfCloseConstraint.constant = 0.0
        self.txtCoupenCode.text = ""
        self.strCoupenCode = ""
        self.txtCoupenCode.resignFirstResponder()
        self.lblOrignalPrice.text = ""
        self.lblDiscount.text = ""
        self.lblOrignalPrice.isHidden = true
        self.lblDiscount.isHidden = true
        self.configureCheckOutView()
        self.lblTotalAmount.text = "\(self.objExperience!.currency) \(self.originalPrice)"
        self.bottomOfTotalAmountConstraint.constant = 35.0
        self.isBookingWith100Discount = false
    }
    func configureCheckOutView(){
        self.txtCoupenCode.delegate = self
        //self.tableViewCheckOut.isScrollEnabled = UIScreen.main.bounds.height <= 568.0
        self.btnBook.setBackgroundColor(color: UIColor.lightGray.withAlphaComponent(0.5), forState: .highlighted)
        self.tableViewHeaderContainer.layer.cornerRadius = 10.0
        self.tableViewHeaderContainer.clipsToBounds = true
        //self.tableViewCheckOut.layer.cornerRadius = 10.0
        self.tableViewCheckOut.clipsToBounds = true
        self.ammountContainerView.layer.cornerRadius = 10.0
        self.ammountContainerView.clipsToBounds = true
        self.shadowView.layer.cornerRadius = 10.0
        if let _ = self.objExperience{
            self.lblDurationValue.text = "\(self.objExperience!.bookingDuration)"
            self.lblExperienceTitle.text = "\(self.objExperience!.title)"
            if self.objExperience!.languages.count > 0{
                var arrayLanguage:[String] = []
                if let language = objExperience?.languages {
                    arrayLanguage = language
                }
                self.languageContainerView.isHidden = false
                self.lblLanguageValue.text = "\(arrayLanguage.joined(separator:","))"
            }else{
                self.languageContainerView.isHidden = true
                self.lblLanguageValue.text = ""
            }
            self.lblNumberOfGuestValue.text = "\(self.numberOfGuest)"
            if self.objExperience!.currency.count > 0{
                print("\(self.objExperience!.ishourly) \(objExperience!.bookingDuration)")
                if let _ = self.isGroupBooking,self.isGroupBooking!{
                    if objExperience!.ishourly{
                        if self.objExperience!.bookingDuration.count > 0{
                            let roundOfDuration = self.getHoursMinute(time: self.objExperience!.bookingDuration)
                            self.lblAmountDetail.text = "\(self.objExperience!.currency) \(self.objExperience!.actualPrice) x \(roundOfDuration.0):\(roundOfDuration.1) hours\n\(self.numberOfGuest) guest (group booking)"
                        }
                    }else{
                        self.lblAmountDetail.text = "\(self.objExperience!.currency) \(self.objExperience!.price) \(self.numberOfGuest) " + "\(Vocabulary.getWordFromKey(key:"groupBooking"))"
                    }
                    self.lblTotalAmount.text = "\(self.objExperience!.currency) \(self.discountPrice)"
                    self.experienceBookingParameters[kIsGroupBooking] = "\(self.isGroupBooking!)"
                }else{ //price per person
                    if objExperience!.ishourly{
                        if self.objExperience!.bookingDuration.count > 0{
                            let roundOfDuration = self.getHoursMinute(time: self.objExperience!.bookingDuration)
                           self.lblAmountDetail.text = "\(self.objExperience!.currency) \(self.objExperience!.actualPrice) x \(roundOfDuration.0):\(roundOfDuration.1) hours x \(self.numberOfGuest) guest"
                        }
                    }else{
                        let pricePerPerson = Double("\(self.objExperience!.price)")! / Double(self.numberOfGuest)
                        self.lblAmountDetail.text = "\(self.objExperience!.currency) \(pricePerPerson) x \(self.numberOfGuest) guest"
                    }
                    self.lblTotalAmount.text = ("\(self.objExperience!.currency) \(self.discountPrice)")
                    self.experienceBookingParameters[kIsGroupBooking] = "false"
                }
                self.experienceBookingParameters[kExperienceID] = "\(self.objExperience!.experienceID)"
                if let _ = self.isGroupBooking,self.isGroupBooking!{
                    self.experienceBookingParameters[kPrice] = "\(self.objExperience!.price)"
                }else{
                    self.experienceBookingParameters[kPrice] = "\(self.objExperience!.price)"//"\(Double(self.numberOfGuest) * Double("\(self.objExperience!.price)")!)"
                }
                
                self.experienceBookingParameters[kNumberOfSlot] = "\(self.numberOfGuest)"
                self.experienceBookingParameters[kLocationID] = "\(self.objExperience!.locationId)"
                self.experienceBookingParameters[kIsInstant] = "\(self.isInstantBooking)"
                self.experienceBookingParameters[kIsBrainTreePayment] = "\(self.isBrainTreePayment)"
            }
        }
        if self.timeStr != "" {
            self.lblTimeValue.text = "\(self.timeStr)".converTo12hoursFormate()
            self.experienceBookingParameters[kBookingTime] = "\(self.timeStr)"
            let objDateFormate = DateFormatter()
            objDateFormate.dateFormat = "MM/dd/yyyy"
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            if let objMediumDate = dateFormatter.date(from: "\(self.bookingDate)"){
                let strDate = objDateFormate.string(from: objMediumDate)
                self.experienceBookingParameters[kBookingDate] = "\(strDate)"
            }
//            if let objDate = objDateFormate.date(from: "\(self.bookingDate)"){
//                self.experienceBookingParameters[kBookingDate] = "\(objDateFormate.string(from: objDate))"
//            }else{
//                self.experienceBookingParameters[kBookingDate] = "\(self.bookingDate)"
//            }
        }
        
        self.lblDateValue.text = "\(self.bookingDate)"
        if let _ = self.objCard{
            
            self.lblCrediCardNUmber.text = "\(self.objCard!.brand) "+"\(self.objCard!.number)".suffix(9)
            self.configureCreditCardImage()
            self.experienceBookingParameters[kPaymentID] = "\(self.objCard!.id)"
        }else{
            self.experienceBookingParameters[kPaymentID] = ""
        }
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            self.experienceBookingParameters[kUserID] = "\(currentUser.userID)"
            self.experienceBookingParameters[kUserName] = "\(currentUser.userFirstName) \(currentUser.userLastName)"
        }
    }
    func configureCreditCardImage(){
        if let _ = self.objCard,let cardType = self.objCard?.cardType {
                if cardType == .visa{
                    self.imgCreditCard.image = #imageLiteral(resourceName: "visacard").withRenderingMode(.alwaysOriginal)
                }else if cardType == .unionpay{
                    self.imgCreditCard.image = #imageLiteral(resourceName: "unionpaycard").withRenderingMode(.alwaysOriginal)
                }else if cardType == .mastercard{
                    self.imgCreditCard.image = #imageLiteral(resourceName: "mastercard").withRenderingMode(.alwaysOriginal)
                }else if cardType == .jcb{
                    self.imgCreditCard.image = #imageLiteral(resourceName: "jcbcard").withRenderingMode(.alwaysOriginal)
                }else if cardType == .discover{
                    self.imgCreditCard.image = #imageLiteral(resourceName: "discover").withRenderingMode(.alwaysOriginal)
                }else if cardType == .dinnerclub{
                    self.imgCreditCard.image = #imageLiteral(resourceName: "dinnerclub").withRenderingMode(.alwaysOriginal)
                }else if cardType == .americanexpress{
                    self.imgCreditCard.image = #imageLiteral(resourceName: "americanexpress").withRenderingMode(.alwaysOriginal)
                }else if cardType == .defaultCard{
                    self.imgCreditCard.image = #imageLiteral(resourceName: "othercard").withRenderingMode(.alwaysOriginal)
                }else{
                    self.imgCreditCard.image = #imageLiteral(resourceName: "othercard").withRenderingMode(.alwaysOriginal)
                }
        }
    }
    func enableDisableBooking(isEnable:Bool){
        self.btnBook.isEnabled = isEnable
        if isEnable{
            self.btnBook.setBackgroundColor(color:UIColor.init(hexString:"#36527D"), forState: .normal)
        }else{
            self.btnBook.setBackgroundColor(color:UIColor.lightGray, forState: .disabled)
        }
    }
    func updateForCoupenCode(){
        
    }
    func getHoursMinute(time:String)->(hours:Int,min:Int){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let date = dateFormatter.date(from:time){
            let calendar = Calendar.current
            let comp = calendar.dateComponents([.hour, .minute], from: date)
            var hour = comp.hour
            var minute = comp.minute
            if minute! < 30 {
                minute = 30
            }else if minute! > 30{
                minute = 0
                hour! += 1
            }else{
                
            }
            return (hour!,minute!)
        }
        return (0,0)
    }
    func presentCouponListController() {
        if let couponListVC = self.storyboard?.instantiateViewController(withIdentifier: "CouponCodeListViewController") as? CouponCodeListViewController {
            self.present(couponListVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonBookSelector(sender:UIButton){
        guard CommonClass.shared.isConnectedToInternet else {
            self.noInterNetView.isHidden = false
            return
        }
        DispatchQueue.main.async {
            self.view.endEditing(true)
            let bookingAlert = UIAlertController(title: Vocabulary.getWordFromKey(key: "bookAndPay"), message:Vocabulary.getWordFromKey(key: "experienceBook.hint"), preferredStyle: UIAlertControllerStyle.alert)
            
            bookingAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (action: UIAlertAction!) in
                if self.isBookingWith100Discount{
                    //Request for experience booking
                    self.requestExperienceBooking()
                }else if self.isBrainTreePayment{ //Paypal payment
                    
                    self.requestPaypalPayment()
                }else{
                    //Request for experience booking
                    self.requestExperienceBooking()
                }
                
            }))
            bookingAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler:nil))
            bookingAlert.view.tintColor = UIColor(hexString: "#36527D")
            self.present(bookingAlert, animated: true, completion: nil)
        }
    }
    func requestPaypalPayment(){
        if let _ = self.objExperience{
            var number:NSDecimalNumber = NSDecimalNumber(string:"0")
            if let _ = self.isGroupBooking,self.isGroupBooking!{
                number = NSDecimalNumber(string: "\(self.objExperience!.price)")
                
            }else{
                number =  NSDecimalNumber(string:"\(self.objExperience!.price)")//"\(Double(self.numberOfGuest) * Double("\(self.objExperience!.price)")!)")
            }
            let payment:PayPalPayment = PayPalPayment.init(amount: number, currencyCode:  "\(self.objExperience!.currency)", shortDescription: "\(self.objExperience!.title)", intent: .sale)
            if self.objExperience!.currency.count > 0{
                
               // payment.amount  = number
                //payment.currencyCode = "\(self.objExperience!.currency)"
                //payment.shortDescription =
               // payment.intent = .order
                if (!payment.processable) {
                    //If payment not acceptable
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: "Sorry for inconvenience. Your booking is not processed.")//"This payment would not be processable.")
                    }
                    self.requestFailPaypal()
                }else{
                    DispatchQueue.main.async {
                        if let paymentController = PayPalPaymentViewController.init(payment: payment, configuration: self.payPalConfiguration, delegate: self as PayPalPaymentDelegate){
                            self.present(paymentController, animated: true, completion: nil)
                        }else{
                            ShowToast.show(toatMessage: "Sorry for inconvenience. Your booking is not processed.")
                            //ShowToast.show(toatMessage: "PayPalPaymentViewController nil.")
                        }
                }
            }
            }
        }
    }
    func requestFailPaypal(){
        var paypalRequestFailParameters:[String:Any] = [:]
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: self.experienceBookingParameters, options: .prettyPrinted) as NSData
            let jsonStr = (NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)!)
            paypalRequestFailParameters["UserId"] = "\(User.getUserFromUserDefault()!.userID)"
            paypalRequestFailParameters["DeviceType"] = "\(UIDevice().type)"
            paypalRequestFailParameters["DeviceVersion"] = "\(UIDevice.current.systemVersion)"
            paypalRequestFailParameters["LogMessage"] = "\(jsonStr)"
            paypalRequestFailParameters["CustomMessage"] = "\(self.paymentID)"
            let requestURL = "base/errorlog"
            
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString: requestURL, parameter: paypalRequestFailParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                print("\(responseSuccess)")
           
            }) { (responseFail) in
                if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: "\(errorMessage)")
                    }
                }else{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:"Error "+kCommonError)
                    }
                }
                self.bottomOfTotalAmountConstraint.constant = 35.0
            }
        }catch{
            print("\(error.localizedDescription)")
        }
    }
    @IBAction func buttonTryAgainSelector(sender:UIButton){
        guard CommonClass.shared.isConnectedToInternet else {
            return
        }
        self.noInterNetView.isHidden = true
        self.buttonBookSelector(sender: self.btnBook)
    }
    @IBAction func buttonCloseSelector(sender:UIButton){
         DispatchQueue.main.async {
            self.hideCloseSelector()
        }
    }
    @IBAction func hideKeyBoardSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    @IBAction func buttonApplySelector(sender:UIButton){
       self.pushToQrCodeScannerController()
    }
    @IBAction func unwindToCheckOutFromQRCodeScanner(segue:UIStoryboardSegue){
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                self.txtCoupenCode.text = "\(self.strCoupenCode)"
                self.txtCoupenCode.minimizePlaceholder()
                self.discountPrice = self.originalPrice
                self.showCloseSelector()
                self.view.endEditing(true)
            }
            self.requestForCoupenValidation()
        }
    }
    @IBAction func unwindCheckOutFromCouponList(segue:UIStoryboardSegue){
        DispatchQueue.main.async {
            self.txtCoupenCode.text = "\(self.strCoupenCode)"
            self.txtCoupenCode.minimizePlaceholder()
            self.discountPrice = self.originalPrice
            self.showCloseSelector()
        }
         self.requestForCoupenValidation()
    }
    // MARK: - API Request Methods
    func requestForCoupenValidation(){
        if self.strCoupenCode.count > 0,CommonClass.shared.isConnectedToInternet{
            
            if let strPrice = self.experienceBookingParameters[kPrice]{
                self.validCoupenCodeParameters["amount"] = "\(strPrice)"
                self.validCoupenCodeParameters["coupon"] = "\(strCoupenCode)"
                self.validCoupenCodeParameters["experienceCurrency"] = "\(self.objExperience!.currency)"
            }
            let requestURL = "users/native/validatecoupon"
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString: requestURL, parameter: self.validCoupenCodeParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let successMessage = successData["Message"] as? String
                    ,let coupenData = successData["CouponCode"] as? [String:Any],let isValid = coupenData["isvalid"],let amount = coupenData["amount"],let strCoupen = coupenData["coupon"]{
                    DispatchQueue.main.async {
                        if Bool.init("\(isValid)"){
                            var couponCurrency = ""
                            if let objCurency = coupenData["currency"]{
                                couponCurrency = "\(objCurency)"
                            }
                            self.experienceBookingParameters["price"] = "\(amount)"
                            self.experienceBookingParameters[self.kCoupen] = "\(strCoupen)"
                            self.lblOrignalPrice.isHidden = false
                            self.lblDiscount.isHidden = false
//                            if let _ = self.isGroupBooking,self.isGroupBooking!{
//                               self.objExperience!.groupPrice = "\(amount)"
//                            }else{
//                                self.objExperience!.priceperson = "\(amount)"
//                            }
                            self.lblOrignalPrice.text = "\(self.objExperience!.currency) \(self.originalPrice)"
                            let strOriginalPrice = "\(self.originalPrice)"
                            let strAmount = "\(amount)"
                            self.lblDiscount.text = "\(couponCurrency) "+"- \((strOriginalPrice as NSString).intValue - (strAmount as NSString).intValue)"
                            self.experienceBookingParameters["discount_amount"] = "\((strOriginalPrice as NSString).intValue - (strAmount as NSString).intValue)"
                            self.discountPrice = "\(amount)"
                            self.bottomOfTotalAmountConstraint.constant = 3.0
                            if "\(amount)" == "0"{
                                self.isBookingWith100Discount = true
                            }else{
                                self.isBookingWith100Discount = false
                            }
                        }else{
                            self.isBookingWith100Discount = false
                            self.bottomOfTotalAmountConstraint.constant = 35.0
                            self.objExperience!.price = "\(self.originalPrice)"
                             self.lblOrignalPrice.text = ""
                             self.lblDiscount.text = ""
                            self.lblOrignalPrice.isHidden = true
                            self.lblDiscount.isHidden = true
                            
                        }
                        self.configureCheckOutView()
                        self.enableDisableBooking(isEnable:Bool.init("\(isValid)"))
                        if Bool.init("\(isValid)"){
                            self.experienceBookingParameters["price"] = "\(amount)"
                        }
                        DispatchQueue.main.async {
                            ShowToast.show(toatMessage:"\(successMessage)")
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.bottomOfTotalAmountConstraint.constant = 35.0
                        //ShowToast.show(toatMessage:kCommonError)
                    }
                }
            }) { (responseFail) in
                if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: "\(errorMessage)")
                    }
                }else{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:"Error "+kCommonError)
                    }
                }
                self.bottomOfTotalAmountConstraint.constant = 35.0
            }
        }
    }
    func requestExperienceBooking(){
        if let bookingId = self.objExperience?.id {
            self.experienceBookingParameters["id"] = bookingId
            if self.objExperience!.ishourly,self.objExperience!.bookingDuration.count >  0{
                self.experienceBookingParameters["ishourly"] = "\(self.objExperience!.ishourly)"
                self.experienceBookingParameters["bookingDuration"] = "\(self.objExperience!.bookingDuration)"
            }
        }
        self.experienceBookingParameters["coupon"] = "\(self.strCoupenCode)"
        
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(),currentUser.userID.count > 0,let _ = self.objExperience,self.objExperience!.currency.count > 0{
            
            //let requestURL = "users/1/native/currency/GBP/booking"
           let requestURL = "users/\(currentUser.userID)/native/currency/\(self.objExperience!.currency)/booking"
            
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString: requestURL, parameter: self.experienceBookingParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
//                DispatchQueue.main.async {
//                    ShowToast.show(toatMessage: "\(responseSuccess)")
//                }
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let successMessage = successData["Message"] as? String{
                        if self.isBrainTreePayment,!self.isBookingWith100Discount{
                            DispatchQueue.main.async {
                                if let trasactionID = successData["TransactionId"]{
                                    self.paymentID = "\(trasactionID)"
                                }
                                self.showTransactionAlert(isSucess: true)
                            }
                        }else{
                            DispatchQueue.main.async {
                                let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key: "Booking"), message: "\(successMessage)", preferredStyle: .alert)
                                alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key: "ok.title"), style: .default, handler: { (_) in
                                    
                                    //PopToHomeViewController
                                    self.popToHomeViewController()
                                    //self.navigationController?.popToRootViewController(animated: false)
                                }))
                                alertController.view.tintColor = UIColor.init(hexString: "36527D")
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    
                }else{
                    DispatchQueue.main.async {
                        //ShowToast.show(toatMessage:kCommonError)
                    }
                }
            }) { (responseFail) in
//                DispatchQueue.main.async {
//                    ShowToast.show(toatMessage: "\(responseFail)")
//                }
                if self.isBrainTreePayment,!self.isBookingWith100Discount{
                    DispatchQueue.main.async {
                        self.showTransactionAlert(isSucess: false)
                        self.requestFailPaypal()
                    }
                }else{
                    if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                        DispatchQueue.main.async {
                            ShowToast.show(toatMessage: "\(errorMessage)")
                        }
                    }else{
                        DispatchQueue.main.async {
                            ShowToast.show(toatMessage:kCommonError)
                        }
                    }
                }
                
            }
        }
    }
    
    func showTransactionAlert(isSucess:Bool){
        let strTitle = isSucess ? "\(Vocabulary.getWordFromKey(key: "PaymentSuccess.hint"))":"\(Vocabulary.getWordFromKey(key: "BookingFail.hint"))"
        let strMSG = "\(Vocabulary.getWordFromKey(key: "PaymentSuccessMSG.hint")) \n\n \(Vocabulary.getWordFromKey(key: "TransactionID.hint"))\n\(self.paymentID)"
        let alertController = UIAlertController.init(title:"\(strTitle)", message:"\(strMSG)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key: "Copy.hint"), style: .default, handler: { (_) in
            UIPasteboard.general.string = "\(self.paymentID)"
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "Copied to clipboard")
                self.dismiss(animated: true, completion: nil)
                self.popToHomeViewController()
            }
        }))
        alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key: "ok.title"), style: .default, handler: { (_) in
            //PopToHomeViewController
            self.popToHomeViewController()
            //self.navigationController?.popToRootViewController(animated: false)
        }))
        alertController.view.tintColor = UIColor.init(hexString: "36527D")
        self.present(alertController, animated: true, completion: nil)
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    func presentCSRPopUpConntroller(){
       if let objCSR = self.storyboard?.instantiateViewController(withIdentifier: "CSRViewController") as? CSRViewController{
            if let bookingId = self.objExperience?.id {
                objCSR.bookingID = "\(bookingId)"
            }
            if let price = self.experienceBookingParameters[kPrice]{
                objCSR.objExperiencePrice = "\(price)"
            }
            if let currency = self.objExperience?.currency{
                objCSR.objCurrency = "\(currency)"
            }
            if let title = self.objExperience?.title{
                objCSR.objExperienceTitle = "\(title)"
            }
        
            objCSR.objCSRDelegate = self
            self.navigationController?.present(objCSR, animated: true, completion: nil)
        }
    }
    func popToHomeViewController(){
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            if self.isBookingWith100Discount{
                self.exitCSRDelegate()
            }else{
                self.presentCSRPopUpConntroller()
            }
            
        }
        //self.performSegue(withIdentifier: "unwindToDiscover", sender: self)

        //self.navigationController?.popToRootViewController(animated: false)
    }
    func pushToQrCodeScannerController(){
        let objMainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        if let qrCodeController = objMainStoryBoard.instantiateViewController(withIdentifier: "QRScannerController") as? QRScannerController{
            qrCodeController.isForAddCouponCode = false
            self.navigationController?.pushViewController(qrCodeController, animated: true)
        }
    }
}
extension CheckOutViewController:CSRDelegate{
    func exitCSRDelegate() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "unwindToDiscover", sender: nil)
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
}
extension CheckOutViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.strCoupenCode = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard !self.strCoupenCode.isContainWhiteSpace() else{
            return false
        }
       
        DispatchQueue.main.async {
            self.lblOrignalPrice.text = ""
            self.lblDiscount.text = ""
            self.lblOrignalPrice.isHidden = true
            self.lblDiscount.isHidden = true
            self.objExperience!.price = "\(self.originalPrice)"
            self.configureCheckOutView()
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.strCoupenCode = ""
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            self.txtCoupenCode.maximizePlaceholder()
            self.presentCouponListController()
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.requestForCoupenValidation()
        return true
    }
}
extension CheckOutViewController:PayPalPaymentDelegate{
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        DispatchQueue.main.async {
            ShowToast.show(toatMessage:"payPalPaymentDidCancel")
            self.dismiss(animated: true, completion: nil)
        }
    }
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                let objConfirmation = completedPayment.confirmation
                if let response = objConfirmation["response"] as? [String:Any]{
                    if let payID = response["id"]{
                        self.experienceBookingParameters[self.kPaymentTransactionID] = "\(payID)"
                        self.experienceBookingParameters["isIos"] = "true"
                        self.paymentID = "\(payID)"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.requestExperienceBooking()
                        }
                    }
                }
            })
            print("\(completedPayment.confirmation)")
            //ShowToast.show(toatMessage:"payPalPaymentViewController didComplete")
        }
    }
}
