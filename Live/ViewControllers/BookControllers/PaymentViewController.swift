//
//  PaymentViewController.swift
//  Live
//
//  Created by ips on 09/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet var tableViewPayment:UITableView!
    @IBOutlet var buttonBack:UIButton!
    @IBOutlet var navTitle:UILabel!
    @IBOutlet var objSegmentController:UISegmentedControl!
    @IBOutlet var btnAddCard:UIButton!
    @IBOutlet var btnStripe:UIButton!
    @IBOutlet var stripeHeader:UIView!
    @IBOutlet var payPalHeader:UIView!
    @IBOutlet var collectionViewCard:UICollectionView!
    
    var arrayOfCards:[CreditCard]=[]
    var selectedCard:NSMutableSet = NSMutableSet()
    var objExperience:PendingExperience?
    var numberOfGuest:Int = 1
    var objTimeSlot:Slot?
    var bookingDate:String = ""
    var isFromSettingScreen: Bool = false
    var isGroupBooking:Bool?
    var isInstantBooking:Bool?
    var bookingTimeStr:String = ""
    var isBrainTree:Bool = false
    var arrayOfCardType:[CardType] = [.visa,.mastercard,.americanexpress,.dinnerclub,.discover,.jcb,.unionpay]

    var isBrainTreePayment:Bool{
        get{
            return isBrainTree
        }
        set{
            self.isBrainTree = newValue
            self.configureBrainTree()
        }
    } //= false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navTitle.text = Vocabulary.getWordFromKey(key: "Payment")
        self.btnAddCard.setTitle(Vocabulary.getWordFromKey(key: "addCards"), for: .normal)
        //Configure PaymentView
        self.configurePaymentView()
        self.configureCardCollectionView()
        self.objSegmentController.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 14)!], for: .selected)
        self.objSegmentController.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 14)!], for: .normal)
        self.objSegmentController.setTitle(Vocabulary.getWordFromKey(key: "stripe.hint"), forSegmentAt: 0)
         self.btnStripe.setTitle(Vocabulary.getWordFromKey(key: "stripe.hint"), for: .normal)
        self.objSegmentController.setTitle(Vocabulary.getWordFromKey(key: "paypal.hint"), forSegmentAt: 1)
        self.objSegmentController.isEnabled = true
        if let currentExperience = self.objExperience{
            if currentExperience.paymentGateWayType == .both{
                    if kAppDel.isPaypalEnable{
                        self.objSegmentController.isEnabled = true
                        self.objSegmentController.setEnabled(true, forSegmentAt: 0)
                        self.objSegmentController.setEnabled(true, forSegmentAt: 1)
                        self.btnStripe.isHidden = true
                    }else{
                        self.objSegmentController.selectedSegmentIndex = 0
                        self.objSegmentController.setEnabled(false, forSegmentAt: 1)
                        self.isBrainTreePayment = false
                        self.btnStripe.isHidden = false
                        self.btnStripe.setTitle(Vocabulary.getWordFromKey(key: "stripe.hint"), for: .normal)
                    }
            }else if currentExperience.paymentGateWayType == .stripe{
                    self.objSegmentController.selectedSegmentIndex = 0
                    self.objSegmentController.setEnabled(false, forSegmentAt: 1)
                    self.isBrainTreePayment = false
                    self.btnStripe.isHidden = false
                    self.btnStripe.setTitle(Vocabulary.getWordFromKey(key: "stripe.hint"), for: .normal)
            }else if currentExperience.paymentGateWayType == .braintree{ //
                    if kAppDel.isPaypalEnable{
                        self.objSegmentController.selectedSegmentIndex = 1
                        self.objSegmentController.setEnabled(false, forSegmentAt: 1)
                        self.isBrainTreePayment = true
                        self.btnStripe.isHidden = false
                        self.btnStripe.setTitle(Vocabulary.getWordFromKey(key: "paypal.hint"), for: .normal)
                        if let _ = self.objExperience{
                            self.pushToCheckOutViewController(objCard: nil)
                        }
                    }else{
                        self.objSegmentController.isEnabled = false
                        self.isBrainTreePayment = false
                        self.btnStripe.isHidden = true
                        self.objSegmentController.isHidden = true
                        if let _ = self.objExperience{
                            
                        }
                    }
            }else if currentExperience.paymentGateWayType == .none{
                    self.objSegmentController.isEnabled = false
                    self.isBrainTreePayment = false
                    self.btnStripe.isHidden = true
                    self.objSegmentController.isHidden = true
                    if let _ = self.objExperience{
                        
                    }
            }else{
                    self.objSegmentController.isEnabled = false
            }
        }else{
            
        }
        
    }
    func configureCardCollectionView(){
        self.collectionViewCard.delegate = self
        self.collectionViewCard.dataSource = self
    }
    func configureBrainTree(){
        self.payPalHeader.isHidden = !self.isBrainTreePayment
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.addDynamicFont()
            self.objSegmentController.selectedSegmentIndex = 0
            self.payPalHeader.isHidden = true
            //self.configureBrainTree()
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
    func addDynamicFont(){
        self.buttonBack.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.buttonBack.imageView?.tintColor = UIColor.black
        
        self.navTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.navTitle.adjustsFontForContentSizeCategory = true
        self.navTitle.adjustsFontSizeToFitWidth = true
        
        //self.btnAddCard.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        //self.btnAddCard.titleLabel?.adjustsFontForContentSizeCategory = true
        //self.btnAddCard.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Methods
    func configurePaymentView(){
        self.tableViewPayment.delegate = self
        self.tableViewPayment.dataSource = self
        //self.tableViewPayment.tableHeaderView = UIView()
        //self.tableViewPayment.tableFooterView = UIView()
        self.tableViewPayment.separatorStyle = .none
        let objHeaderViewNIb = UINib.init(nibName:"CardHeaderView", bundle: nil)
        self.tableViewPayment.register(objHeaderViewNIb, forHeaderFooterViewReuseIdentifier:"CardHeaderView")
        let objCardViewNib = UINib.init(nibName: "CardView", bundle: nil)
        self.tableViewPayment.register(objCardViewNib, forHeaderFooterViewReuseIdentifier: "CardView")
        let objCardNib = UINib.init(nibName: "CardTableViewCell", bundle: nil)
        self.tableViewPayment.register(objCardNib, forCellReuseIdentifier:"CardTableViewCell")
        
        let objCardListNib = UINib.init(nibName: "CardListTableViewCell", bundle: nil)
        self.tableViewPayment.register(objCardListNib, forCellReuseIdentifier:"CardListTableViewCell")
        
         //Get Cards
        self.getCardsFromUserID()
        
    }
    // MARK: - API Request Methods
    func getCardsFromUserID(){
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(),currentUser.userID.count > 0{
            //let requestURL = "payment/native/users/30/creditcards"
            let requestURL = "payment/native/users/\(currentUser.userID)/creditcards"
            APIRequestClient.shared.sendRequest(requestType: .GET, queryString: requestURL, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let arraySuccess = successDate["cards"] as? [[String:Any]]{
                    self.arrayOfCards = []
                    for object:[String:Any] in arraySuccess{
                        let cardDetail = CreditCard.init(cardDetail: object)
                        self.arrayOfCards.append(cardDetail)
                    }
                    DispatchQueue.main.async {
                        self.tableViewPayment.reloadData()
                    }
                }else{
                    DispatchQueue.main.async {
                       // ShowToast.show(toatMessage:kCommonError)
                    }
                }
            }) { (responseFail) in
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
    func deleteCardWithCardDetail(objCardDetail:CreditCard){
        let requestURL = "payment/\(objCardDetail.id)/deletecreditcard"
        APIRequestClient.shared.sendRequest(requestType: .DELETE, queryString: requestURL, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let message = successDate["Message"] as? String{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:message)
                }
                self.selectedCard.removeAllObjects()
                self.getCardsFromUserID()
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }) { (responseFail) in
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
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(selector:UIButton){
        self.navigationController?.popViewController(animated: false)
    }
    @IBAction func unwindToPaymentViewController(segue: UIStoryboardSegue) {
        self.selectedCard.removeAllObjects()
        self.getCardsFromUserID()
    }
    @IBAction func buttonAddCardSelector(sender:UIButton){
        self.addNewCardSelector()
    }
    @IBAction func buttonSegmentControllerSelector(sender:UISegmentedControl){
        switch sender.selectedSegmentIndex {
        case 0: //Stripe
            self.isBrainTreePayment = false
            break
        case 1: //Paypal
            self.isBrainTreePayment = true
            self.pushToCheckOutViewController(objCard: nil)
            break
        default:
            break
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    func pushToCheckOutViewController(objCard:CreditCard?){
        if let checkOutViewController = kBookingStoryBoard.instantiateViewController(withIdentifier:"CheckOutViewController") as? CheckOutViewController{
            checkOutViewController.objExperience = self.objExperience!
//            checkOutViewController.objTimeSlot = self.objTimeSlot!
            checkOutViewController.timeStr = self.bookingTimeStr
            checkOutViewController.numberOfGuest = self.numberOfGuest
            checkOutViewController.bookingDate = "\(self.bookingDate)"
            checkOutViewController.isBrainTreePayment = self.isBrainTreePayment
            if let _ = self.isGroupBooking{
                checkOutViewController.isGroupBooking = self.isGroupBooking
            }
            if let _ = self.isInstantBooking{
                checkOutViewController.isInstantBooking = true
            }else{
                checkOutViewController.isInstantBooking = false
            }
            if let _ = objCard{
                checkOutViewController.objCard = objCard
            }
            checkOutViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(checkOutViewController, animated: true)
            defer{
                if let _ = objCard{
                    
                }else{
                   
                }
            }
        }
    }
}
extension PaymentViewController:UITableViewDelegate,UITableViewDataSource{
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return self.arrayOfCards.count+1
//    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfCards.count
//        guard section != 0 else {
//            return 0
//        }
//        if self.selectedCard.contains(section){
//            return 1
//        }else{
//            return 0
//        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
     
        let deleteAction = UITableViewRowAction(style: .destructive, title: Vocabulary.getWordFromKey(key:"delete")) { (rowAction, indexPath) in
            let refreshAlert = UIAlertController(title: Vocabulary.getWordFromKey(key:"deleteCard.title"), message: Vocabulary.getWordFromKey(key:"deleteCardAlertMsg"), preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (action: UIAlertAction!) in
                let objCard = self.arrayOfCards[indexPath.row]
                self.deleteCardWithCardDetail(objCardDetail: objCard)
            }))
            refreshAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            refreshAlert.view.tintColor = UIColor(hexString: "#36527D")
            self.present(refreshAlert, animated: true, completion: nil)
        }
        deleteAction.backgroundColor = .red
        return [deleteAction]
    }
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.0
//    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CardListTableViewCell") as? CardListTableViewCell{
            if self.arrayOfCards.count > indexPath.row{
               let cardDetail = self.arrayOfCards[indexPath.row]
                cell.lblCardNumber.text = "\(cardDetail.brand) \(cardDetail.number)"
                cell.setCardType(cardType: cardDetail.cardType)
            }
            return cell
        }else{
            return UITableViewCell()
        }
        
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "CardTableViewCell") as? CardTableViewCell
//        if indexPath.section > 0{
//            let currentSection = indexPath.section - 1
//            let objCard = self.arrayOfCards[currentSection]
//            cell?.lblCardHolderName.text = "\(objCard.holderName)"
//            cell?.cardDelegate = self
//            cell?.tag = currentSection
//        }
//        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = self.objExperience{
            let objCard = self.arrayOfCards[indexPath.row]
            self.isBrainTreePayment = false
            self.pushToCheckOutViewController(objCard: objCard)
        }else{
            
        }
    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        guard  section != 0 else {
//            return 150.0
//        }
//        return 70.0
//    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0{
//            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier:"CardHeaderView") as? CardHeaderView
//            headerView?.cardHeaderDelegate = self
//            headerView?.backgroundColor = .clear
//            return headerView
//        }else{
//            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier:"CardView") as? CardView
//            if self.isFromSettingScreen {
//                headerView?.btnPay.isHidden = true
//            } else {
//                headerView?.btnPay.isHidden = false
//            }
//            headerView?.backgroundColor = .clear
//            let currentSection = section - 1
//            headerView?.tag = section
//            headerView?.cardDelegate = self
//            if self.arrayOfCards.count > currentSection{
//               let cardDetail = self.arrayOfCards[currentSection]
//                headerView?.lblCardNumber.text = "\(cardDetail.number)"
//                headerView?.setCardType(cardType: cardDetail.cardType)
//            }
//            return headerView
//        }
//    }
}
extension PaymentViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayOfCardType.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cardCell:CardCollectionViewCell =  collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as! CardCollectionViewCell
        cardCell.setCardType(cardType: self.arrayOfCardType[indexPath.item])
        return cardCell
    }
}
extension PaymentViewController:CardHeaderDeledate{
    func addNewCardSelector() {
        if let addNewCardViewController = self.storyboard?.instantiateViewController(withIdentifier:"AddNewCardViewController") as? AddNewCardViewController{
//            addNewCardViewController.modalPresentationStyle = .overCurrentContext
            addNewCardViewController.isNoCardAdded = (self.arrayOfCards.count == 0)
            self.present(addNewCardViewController, animated:false, completion: nil)
        }
    }
}
extension PaymentViewController:CardViewDelegate{
    func cardSelector(tag: Int) {
        let sectionSet = NSMutableIndexSet()
        let sections:[Int] = Array(1...self.arrayOfCards.count)
        sections.forEach(sectionSet.add)
        guard !self.selectedCard.contains(tag) else {
            self.selectedCard.removeAllObjects()
            DispatchQueue.main.async {
                self.tableViewPayment.reloadSections(sectionSet as IndexSet, with: .automatic)
            }
            return
        }
        self.selectedCard.removeAllObjects()
        self.selectedCard.add(tag)
        DispatchQueue.main.async {
            self.tableViewPayment.reloadSections(sectionSet as IndexSet, with: .automatic)
        }
    }
    func paySelector(tag: Int) {
        if self.arrayOfCards.count > tag-1{
             let objCard = self.arrayOfCards[tag-1]
             self.pushToCheckOutViewController(objCard: objCard)
        }
    }
}

extension  PaymentViewController:CardTableViewCellDelegate{
    func deleteCardSelector(tag: Int) {
        if self.arrayOfCards.count > tag{
            let deleteAlert = UIAlertController.init(title: "", message: "", preferredStyle: .alert)
            deleteAlert.view.layer.cornerRadius = 14.0
            let titleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 20.0)!]
            let messageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
            let titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key: "deleteCard.title"), attributes: titleFont)
            let messageAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key: "deleteCardAlertMsg"), attributes: messageFont)
            
            deleteAlert.setValue(titleAttrString, forKey: "attributedTitle")
            deleteAlert.setValue(messageAttrString, forKey: "attributedMessage")

            deleteAlert.view.tintColor = UIColor(hexString: "#36527D")
            deleteAlert.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler: nil))
            deleteAlert.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (_ ) in
                let objCard = self.arrayOfCards[tag]
                self.deleteCardWithCardDetail(objCardDetail: objCard)
            }))
            self.present(deleteAlert, animated: true, completion: nil)            
        }
    }
}
class CardListTableViewCell:UITableViewCell{
    
    @IBOutlet var imageCard:UIImageView!
    @IBOutlet var lblCardNumber:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.selectionStyle = .none
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.lblCardNumber.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblCardNumber.adjustsFontForContentSizeCategory = true
        self.lblCardNumber.adjustsFontSizeToFitWidth = true
    }
    func setCardType(cardType:CardType){
        if cardType == .visa{
            self.imageCard.image = #imageLiteral(resourceName: "visacard").withRenderingMode(.alwaysOriginal)
        }else if cardType == .unionpay{
            self.imageCard.image = #imageLiteral(resourceName: "unionpaycard").withRenderingMode(.alwaysOriginal)
        }else if cardType == .mastercard{
            self.imageCard.image = #imageLiteral(resourceName: "mastercard").withRenderingMode(.alwaysOriginal)
        }else if cardType == .jcb{
            self.imageCard.image = #imageLiteral(resourceName: "jcbcard").withRenderingMode(.alwaysOriginal)
        }else if cardType == .discover{
            self.imageCard.image = #imageLiteral(resourceName: "discover").withRenderingMode(.alwaysOriginal)
        }else if cardType == .dinnerclub{
            self.imageCard.image = #imageLiteral(resourceName: "dinnerclub").withRenderingMode(.alwaysOriginal)
        }else if cardType == .americanexpress{
            self.imageCard.image = #imageLiteral(resourceName: "americanexpress").withRenderingMode(.alwaysOriginal)
        }else if cardType == .defaultCard{
            self.imageCard.image = #imageLiteral(resourceName: "othercard").withRenderingMode(.alwaysOriginal)
        }else{
            self.imageCard.image = #imageLiteral(resourceName: "othercard").withRenderingMode(.alwaysOriginal)
        }
    }
}
