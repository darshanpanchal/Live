//
//  AddNewCardViewController.swift
//  Live
//
//  Created by ips on 10/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
enum CreditCardType: String {
    case Unknown, Amex, Visa, MasterCard, Diners, Discover, JCB, UnionPay //Elo, Hipercard
    
    static let allCards = [Amex, Visa, MasterCard, Diners, Discover, JCB, UnionPay] //Elo, Hipercard
    
    var regex : String {
        switch self {
        case .Amex:
            return "^3[47][0-9]{5,}$"
        case .Visa:
            return "^4[0-9]{6,}([0-9]{3})?$"
        case .MasterCard:
            return "^(5[1-5][0-9]{4}|677189)[0-9]{5,}$"
        case .Diners:
            return "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
        case .Discover:
            return "^6(?:011|5[0-9]{2})[0-9]{3,}$"
        case .JCB:
            return "^(?:2131|1800|35\\d{3})\\d{11}$"//"^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"
        case .UnionPay:
            return "^(62|88)[0-9]{5,}$"
//        case .Hipercard:
//            return "^(606282|3841)[0-9]{5,}$"
//        case .Elo:
//            return "^((((636368)|(438935)|(504175)|(451416)|(636297))[0-9]{0,10})|((5067)|(4576)|(4011))[0-9]{0,12})$"
        default:
            return ""
        }
    }
    var cardName:String{
        switch self {
        case .Amex:
            return "AMERICAN_EXPRESS"
        case .Visa:
            return "VISA"
        case .MasterCard:
            return "MASTERCARD"
        case .Diners:
            return "DINERS_CLUB"
        case .Discover:
            return "DISCOVER"
        case .JCB:
            return "JCB"
        case .UnionPay:
            return "UNIONPAY"
        default:
            return "UNKNOWN"
        }
    }
}
class AddNewCardViewController: UIViewController {
    private var kBrand:String = "Brand"
    private var kCVV:String = "Cvv"
    private var kExpirationYear:String = "ExpirationYear"
    private var kExpirationMonth:String = "ExpirationMonth"
    private var kHolderName:String = "HolderName"
    private var kNumber:String = "Number"
 
    private var previousTextFieldContent: String?
    private var previousSelection: UITextRange?
//    @IBOutlet var lblCardNumber:UILabel!
    @IBOutlet var txtCardNumber: TweeActiveTextField!;
//    @IBOutlet var lblCardHolderName:UILabel!
    @IBOutlet var txtCardHolderName:TweeActiveTextField!
//    @IBOutlet var lblExpiryDate:UILabel!
    @IBOutlet var txtExpiryDate:TweeActiveTextField!
//    @IBOutlet var lblCVV:UILabel!
    @IBOutlet var txtCVV:TweeActiveTextField!
    @IBOutlet var contentView:UIView!
    @IBOutlet var btnAdd:UIButton!
//    @IBOutlet var btnCancel:RoundButton!
    @IBOutlet var lblNewCard:UILabel!
    @IBOutlet var tableViewAddCard:UITableView!
    @IBOutlet var collectionViewCard:UICollectionView!
    
    var addNewCardParameters:[String:String] = [ : ]
    var isNoCardAdded:Bool = false
    var arrayOfCardType:[CardType] = [.visa,.mastercard,.americanexpress,.dinnerclub,.discover,.jcb,.unionpay]
    
    var arrayOfYear:[Int] = [Int](Calendar.current.component(.year, from:Date())...(Calendar.current.component(.year, from:Date())+100))
    var arrayOfMonth:[String] = Calendar.current.shortMonthSymbols
    var expireDatePicker:UIPickerView = UIPickerView()
    var expireDateToolBar:UIToolbar = UIToolbar()
    var selectedExpireMonth:String = "\(Calendar.current.component(.month, from:Date()))"
    var selectedExpireYear:String = "\(Calendar.current.component(.year, from:Date()))"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var currentMonth:Int = Calendar.current.component(.month, from:Date())
        currentMonth -= 1
        self.selectedExpireMonth = "\(self.arrayOfMonth[currentMonth])"
       
        if !self.isNoCardAdded{
            self.tableViewAddCard.tableHeaderView = UIView()
        }
        if UIScreen.main.bounds.height == 568.0{
            self.tableViewAddCard.isScrollEnabled = true
        }else{
            self.tableViewAddCard.isScrollEnabled = false
        }
        self.configureCardCollectionView()
        self.changeTextAsLanguage()
        self.configureExpiryDatePicker(currentMonth:currentMonth)
        self.addNewCardParameters = [kBrand:"",kCVV:"",kExpirationYear:"",kExpirationMonth:"",kHolderName:"",kNumber:""]
        self.contentView.layer.cornerRadius = 12.0
        self.contentView.clipsToBounds = true
        self.txtCardHolderName.delegate = self
        self.txtCardNumber.delegate = self
        self.txtExpiryDate.delegate = self
        self.txtCVV.delegate = self
        self.btnAdd.layer.cornerRadius = btnAdd.frame.height / 2.0
        self.txtCardNumber.addTarget(self, action: #selector(reformatAsCardNumber), for: .editingChanged)
//        self.btnAdd.setBackgroundColor(color: UIColor.init(hexString:"2963AF"), forState: .highlighted)
//        self.btnCancel.setBackgroundColor(color: UIColor.init(hexString:"2963AF"), forState: .highlighted)
        
//        self.btnCancel.applyGradient(colours: [UIColor.white.withAlphaComponent(0.1),UIColor.init(hexString:"2963AF").withAlphaComponent(0.2),
//                                                  UIColor.init(hexString:"2963AF").withAlphaComponent(0.5), UIColor.init(hexString:"2963AF")])
//        self.btnAdd.applyGradient(colours: [UIColor.white.withAlphaComponent(0.1),UIColor.init(hexString:"2963AF").withAlphaComponent(0.2),
//                                                  UIColor.init(hexString:"2963AF").withAlphaComponent(0.5),UIColor.init(hexString:"2963AF")])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        
//        self.btnCancel.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
//        self.btnCancel.titleLabel?.adjustsFontForContentSizeCategory = true
//        self.btnCancel.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.btnAdd.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.btnAdd.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnAdd.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
//        self.lblNewCard.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
//        self.lblNewCard.adjustsFontForContentSizeCategory = true
//        self.lblNewCard.adjustsFontSizeToFitWidth = true
//
//        self.lblCardNumber.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Book", textStyle: .title1)
//        self.lblCardNumber.adjustsFontForContentSizeCategory = true
//        self.lblCardNumber.adjustsFontSizeToFitWidth = true
//
//        self.txtCardNumber.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Book", textStyle: .title1)
//        self.txtCardNumber.adjustsFontForContentSizeCategory = true
//
//        self.lblCardHolderName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Book", textStyle: .title1)
//        self.lblCardHolderName.adjustsFontForContentSizeCategory = true
//        self.lblCardHolderName.adjustsFontSizeToFitWidth = true
        
//        self.txtCardHolderName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Book", textStyle: .title1)
//        self.txtCardHolderName.adjustsFontForContentSizeCategory = true
        
//
//        self.lblExpiryDate.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Book", textStyle: .title1)
//        self.lblExpiryDate.adjustsFontForContentSizeCategory = true
//        self.lblExpiryDate.adjustsFontSizeToFitWidth = true
        
//        self.txtExpiryDate.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Book", textStyle: .title1)
//        self.txtExpiryDate.adjustsFontForContentSizeCategory = true
//        
//        self.lblCVV.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Book", textStyle: .title1)
//        self.lblCVV.adjustsFontForContentSizeCategory = true
//        self.lblCVV.adjustsFontSizeToFitWidth = true
        
//        self.txtCVV.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Book", textStyle: .title1)
//        self.txtCVV.adjustsFontForContentSizeCategory = true
        
       
    }
    func changeTextAsLanguage() {
        self.lblNewCard.text = Vocabulary.getWordFromKey(key: "addNewCard") // Vocabulary.getWordFromKey(key: "Payment")
//        self.lblCardNumber.text = Vocabulary.getWordFromKey(key: "card")
        self.txtCardNumber.tweePlaceholder = Vocabulary.getWordFromKey(key: "cardNumber")
        self.txtCVV.tweePlaceholder = Vocabulary.getWordFromKey(key: "CVV")
        self.txtExpiryDate.tweePlaceholder = Vocabulary.getWordFromKey(key: "expiryDate")
        self.txtCardHolderName.tweePlaceholder = Vocabulary.getWordFromKey(key: "lblCardHolder")
//        self.txtCVV.placeholder = Vocabulary.getWordFromKey(key: "CVV")
//        self.txtCardNumber.placeholder = Vocabulary.getWordFromKey(key: "cardNumber")
//        self.txtCardHolderName.placeholder = Vocabulary.getWordFromKey(key: "nameOncard")
//        self.btnCancel.setTitle(Vocabulary.getWordFromKey(key: "Cancel"), for: .normal)
        self.btnAdd.setTitle(Vocabulary.getWordFromKey(key: "addCards")+" and Pay", for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Methods
    func configureExpiryDatePicker(currentMonth:Int){
        self.expireDatePicker.delegate = self
        self.expireDatePicker.dataSource = self
        self.expireDateToolBar.sizeToFit()
        self.expireDateToolBar.backgroundColor = UIColor.white
        self.expireDateToolBar.layer.borderColor = UIColor.clear.cgColor
        self.expireDateToolBar.layer.borderWidth = 1.0
        self.expireDateToolBar.clipsToBounds = true
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddNewCardViewController.doneExpiryPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let title = UILabel.init()
        let detail = Vocabulary.getWordFromKey(key: "expiryDate")
        title.attributedText = NSAttributedString.init(string: "\(detail)", attributes:[NSAttributedStringKey.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddNewCardViewController.cancelExpiryPicker))
        self.expireDateToolBar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
        self.txtExpiryDate.inputView = self.expireDatePicker
        self.txtExpiryDate.inputAccessoryView = self.expireDateToolBar
        DispatchQueue.main.async {
            self.expireDatePicker.reloadAllComponents()
            self.expireDatePicker.selectRow(currentMonth, inComponent: 0, animated: false)
        }
        
    }
    @objc func doneExpiryPicker(){
        var objIndex:Int = 0
        if let index = self.arrayOfMonth.index(where: {$0 == "\(self.selectedExpireMonth)"}){
            objIndex = index+1
            self.addNewCardParameters[kExpirationMonth] = "\(index+1)"
        }
        self.addNewCardParameters[kExpirationYear] = "\(self.selectedExpireYear)"
        DispatchQueue.main.async {
            //self.txtExpiryDate.resignFirstResponder()
            var strIndx = "\(objIndex)"
            if strIndx.count == 1{
                strIndx = "0"+strIndx
            }
            self.txtExpiryDate.text = "\(strIndx) / \(self.selectedExpireYear)"
            self.txtExpiryDate.minimizePlaceholder()
            defer{
                self.view.endEditing(true)
            }
        }
    }
    @objc func cancelExpiryPicker(){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    func configureCardCollectionView(){
        self.collectionViewCard.delegate = self
        self.collectionViewCard.dataSource = self
    }
    func isValidFields()->Bool{
        if self.addNewCardParameters[kNumber]!.count > 0 {
            self.validCardNumber()
            if self.addNewCardParameters[kHolderName]!.count > 0{
                self.validCardHolderName()
                let date = Date()
                let calendar = Calendar.current
                let year = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)
                if let objMonth = self.addNewCardParameters[kExpirationMonth],objMonth.count > 0,
                    let objYear = self.addNewCardParameters[kExpirationYear],objYear.count > 0{
                    
                    if Int(objMonth)! > 0,Int(objMonth)! <= 12,Int(objYear)! >= year{
                        if Int(objYear)! == year{
                            if Int(objMonth)! <   month{
                                self.invalidEmpiryMonthAndYear()
                                return false
                            }
                        }
                        self.validExpiryDate()
                        if self.addNewCardParameters[kCVV]!.count > 0{
                            self.validCVV()
                            return true
                        }else{
                            self.invalidCVV()
                            return false
                        }
                    } else{
                        
                        self.invalidEmpiryMonthAndYear()
                        return false
                    }
                }else{
                    self.invalidEmpiryDate()
                    return false
                }
            }else{
                self.invalidCardHolderName()
                return false
            }
        }else{
            self.invalidCardNumber()
            return false
        }
    }
    func invalidCardNumber(){
//        self.lblCardNumber.textColor = .red
//        self.lblCardNumber.invalideField()
        self.txtCardNumber.lineColor = .red
        self.txtCardNumber.activeLineColor = .red
        self.txtCardNumber.invalideField()
        DispatchQueue.main.async {
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key:"cardNumberValidation"))
        }
    }
    func validCardNumber(){
//        self.lblCardNumber.textColor = .black
        self.txtCardNumber.lineColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.txtCardNumber.activeLineColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    func invalidCardHolderName(){
//        self.lblCardHolderName.textColor = .red
//        self.lblCardHolderName.invalideField()
        self.txtCardHolderName.lineColor = .red
        self.txtCardHolderName.activeLineColor = .red
        self.txtCardHolderName.invalideField()
        DispatchQueue.main.async {
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key:"cardNameValidation"))
        }
    }
    func validCardHolderName(){
//        self.lblCardHolderName.textColor = .black
        self.txtCardHolderName.lineColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.txtCardHolderName.activeLineColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    func invalidEmpiryMonthAndYear (){
//        self.lblExpiryDate.textColor = .red
        self.txtExpiryDate.lineColor = .red
        self.txtExpiryDate.activeLineColor = .red
        self.txtExpiryDate.invalideField()
//        self.lblExpiryDate.invalideField()
        DispatchQueue.main.async {
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key:"cardDateValidation"))
        }
    }
    func invalidEmpiryDate(){
//        self.lblExpiryDate.textColor = .red
        self.txtExpiryDate.lineColor = .red
        self.txtExpiryDate.activeLineColor = .red
        self.txtExpiryDate.invalideField()
//        self.lblExpiryDate.invalideField()
        DispatchQueue.main.async {
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key:"cardExpiryValidation"))
        }
    }
    func validExpiryDate(){
//        self.lblExpiryDate.textColor = .black
        self.txtExpiryDate.lineColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.txtExpiryDate.activeLineColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    func invalidCVV(){
//        self.lblCVV.textColor = .red
        self.txtCVV.lineColor = .red
        self.txtCVV.activeLineColor = .red
        self.txtCVV.invalideField()
//        self.lblCVV.invalideField()
        DispatchQueue.main.async {
            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key:"cardCVVValidation"))
        }
    }
    func validCVV(){
//        self.lblCVV.textColor = .black
        self.txtCVV.lineColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.txtCVV.activeLineColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }

    // MARK: - Selector Methods
    @IBAction func buttonCancelSelector(sender:UIButton){
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func buttonAddSelector(sender:UIButton){
        if self.isValidFields(){
            self.addNewCardRequest()
        }
    }
    @IBAction func buttonSelector(sender:UIButton){
        self.view.endEditing(true)
    }
    // MARK: - API Request
    func addNewCardRequest(){
     
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(),currentUser.userID.count > 0{
            //let requestURL = "payment/native/users/30/createcreditcard"
            let requestURL = "payment/native/users/\(currentUser.userID)/createcreditcard"
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString: requestURL, parameter: self.addNewCardParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let cardDetail = successData["card"] as? [String:Any],let successMessage = successData["Message"] as? String{
                    let objCard = CreditCard.init(cardDetail: cardDetail)
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: "\(successMessage)")
                        self.performSegue(withIdentifier:"unwindToPaymentView", sender: objCard)

                    }

                }else{
                    DispatchQueue.main.async {
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
            }
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
extension AddNewCardViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            return self.arrayOfMonth[row]
        }else{
            return "\(self.arrayOfYear[row])"
        }
        /*
        if pickerView == self.occurencePicker{
            return "\(self.arrayOfScheduleTypes[row])"
        }else if pickerView == self.weekDayPicker{
            return "\(self.arrayOfWeekDays[row])"
        }else{
            return "\(self.arrayOfDaysOfMonth[row])"
        }
        */
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0{
            return 80.0
        }else {
            return 100.0
        }
        
        /*
        if pickerView == self.occurencePicker || pickerView == self.weekDayPicker{
            return UIScreen.main.bounds.width
        }else{
            return 150.0
        }*/
        
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return self.arrayOfMonth.count
        }else{
            return self.arrayOfYear.count
        }
        /*
        if pickerView == self.occurencePicker{
            return self.arrayOfScheduleTypes.count
        }else if pickerView == self.weekDayPicker{
            return self.arrayOfWeekDays.count
        }else{
            return 31
        }*/
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
            
            if self.selectedExpireYear == "\(Calendar.current.component(.year, from:Date()))" &&  row+1 < (Calendar.current.component(.month, from: Date())){
                var currentMonth = Calendar.current.component(.month, from: Date())
                currentMonth -= 1
                self.selectedExpireMonth = "\(self.arrayOfMonth[currentMonth])"
                pickerView.selectRow(currentMonth, inComponent: component, animated: true)
            }else{
                self.selectedExpireMonth = "\(self.arrayOfMonth[row])"
                pickerView.selectRow(row, inComponent: component, animated: true)
            }
            
        }else{
            var objIndex:Int = 0
            if let index = self.arrayOfMonth.index(where: {$0 == "\(self.selectedExpireMonth)"}){
                objIndex = index
            }
            objIndex += 1
            var currentMonth = (Calendar.current.component(.month, from: Date()))
            if row == 0 && objIndex < currentMonth {
                 currentMonth -= 1
                 pickerView.selectRow(currentMonth, inComponent: 0, animated: true)
                self.selectedExpireMonth = "\(self.arrayOfMonth[currentMonth])"
                self.selectedExpireYear = "\(self.arrayOfYear[row])"
            }else{
                self.selectedExpireYear = "\(self.arrayOfYear[row])"
                pickerView.selectRow(row, inComponent: component, animated: true)
            }
        }
        
        /*
        if pickerView == self.occurencePicker{
            self.strTempOccurence = "\(self.arrayOfScheduleTypes[row])"
        }else if pickerView == self.weekDayPicker{
            self.strTempWeekDay = "\(self.arrayOfWeekDays[row])"
        }else{
            self.selectedDayTag = row
        }
        pickerView.selectRow(row, inComponent: component, animated: true)
        */
    }
}
extension AddNewCardViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayOfCardType.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cardCell:CardCollectionViewCell =  collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as! CardCollectionViewCell
        cardCell.setCardType(cardType: self.arrayOfCardType[indexPath.item])
        return cardCell
    }
}
extension AddNewCardViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.viewWithTag(textField.tag+1)?.becomeFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.txtCardNumber{
            if let cardNumber:String = self.addNewCardParameters[kNumber],cardNumber.count > 0{
                
            }
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)

        if textField == self.txtCardNumber{
            self.previousTextFieldContent = textField.text
            self.previousSelection = textField.selectedTextRange
            self.addNewCardParameters[kNumber] = "\(typpedString)"
            let (_,cardName,_ ,_) = self.checkCardNumber(numberOnly:typpedString)
            self.addNewCardParameters[kBrand] = "\(cardName)"
            return true
        }else if textField == txtExpiryDate{
         
            guard typpedString.count != 8 else{
                return false
            }
            if typpedString.count == 2{
              
                if let text = textField.text,text.count > 2{
                    return true
                }
                textField.text = "\(typpedString)/"
                return false
            }
            if typpedString.count == 3{
                if(typpedString.last! != "/"){
                    if let text = textField.text,text.count == 2{
                         textField.text = "\(text)/\(typpedString.last!)"
                        return false
                    }
                  return true
                }
                return true
            }
            let araryMonthYear = typpedString.components(separatedBy:"/")
            if araryMonthYear.count == 2{
                self.addNewCardParameters[kExpirationMonth] = "\(araryMonthYear[0])"
                self.addNewCardParameters[kExpirationYear] = "\(araryMonthYear[1])"
            }
            return true
        }else if textField == self.txtCardHolderName{
            self.addNewCardParameters[kHolderName] = "\(typpedString)"
            return true
        }else if textField == txtCVV{
            if typpedString.count <= 3{
                self.addNewCardParameters[kCVV] = "\(typpedString)"
            }
            return typpedString.count <= 3
        }
        return true
    }
    
    @objc func reformatAsCardNumber(textField: UITextField) {
        var targetCursorPosition = 0
        if let startPosition = textField.selectedTextRange?.start {
            targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: startPosition)
        }
        
        var cardNumberWithoutSpaces = ""
        if let text = textField.text {
            cardNumberWithoutSpaces = self.removeNonDigits(string: text, andPreserveCursorPosition: &targetCursorPosition)
        }
        
        if cardNumberWithoutSpaces.count > 16 {
            textField.text = previousTextFieldContent
            textField.selectedTextRange = previousSelection
            return
        }
        
        let cardNumberWithSpaces = self.insertSpacesEveryFourDigitsIntoString(string: cardNumberWithoutSpaces, andPreserveCursorPosition: &targetCursorPosition)
        textField.text = cardNumberWithSpaces
        
        if let targetPosition = textField.position(from: textField.beginningOfDocument, offset: targetCursorPosition) {
            textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
        }
    }
    
    func removeNonDigits(string: String, andPreserveCursorPosition cursorPosition: inout Int) -> String {
        var digitsOnlyString = ""
        let originalCursorPosition = cursorPosition
        
        for i in Swift.stride(from: 0, to: string.count, by: 1) {
            let characterToAdd = string[string.index(string.startIndex, offsetBy: i)]
            if characterToAdd >= "0" && characterToAdd <= "9" {
                digitsOnlyString.append(characterToAdd)
            }
            else if i < originalCursorPosition {
                cursorPosition -= 1
            }
        }
        
        return digitsOnlyString
    }
    
    func insertSpacesEveryFourDigitsIntoString(string: String, andPreserveCursorPosition cursorPosition: inout Int) -> String {
        var stringWithAddedSpaces = ""
        let cursorPositionInSpacelessString = cursorPosition
        
        for i in Swift.stride(from: 0, to: string.count, by: 1) {
            if i > 0 && (i % 4) == 0 {
                stringWithAddedSpaces.append(" ")
                if i < cursorPositionInSpacelessString {
                    cursorPosition += 1
                }
            }
            let characterToAdd = string[string.index(string.startIndex, offsetBy:i)]
            stringWithAddedSpaces.append(characterToAdd)
        }
        
        return stringWithAddedSpaces
    }
    func matchesRegex(regex: String!, text: String!) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            let nsString = text as NSString
            let match = regex.firstMatch(in: text, options: [], range: NSMakeRange(0, nsString.length))
            return (match != nil)
        } catch {
            return false
        }
    }
    func luhnCheck(number: String) -> Bool {
            var sum = 0
            let digitStrings = number.reversed().map { String($0) }
        
            for tuple in digitStrings.enumerated() {
                guard let digit = Int(tuple.element) else { return false }
                let odd = tuple.offset % 2 == 1
                
                switch (odd, digit) {
                case (true, 9):
                    sum += 9
                case (true, 0...8):
                    sum += (digit * 2) % 9
                default:
                    sum += digit
                }
            }
        
        return sum % 10 == 0
    }
    func checkCardNumber(numberOnly: String) -> (type: CreditCardType,name:String, formatted: String, valid: Bool) {
        // Get only numbers from the input string
        let cardnumberOnly = numberOnly.removeWhiteSpaces().replacingOccurrences(of:"[^0-9]", with:"")
        //let numberOnly = numberOnly.stringByReplacingOccurrencesOfString("[^0-9]", withString: "", options: .RegularExpressionSearch)
    
        var type: CreditCardType = .Unknown
        var formatted = ""
        var valid = false
        var cardName = "UNKNOWN"
        // detect card type
        for card in CreditCardType.allCards {
            
            if (matchesRegex(regex: card.regex, text: cardnumberOnly)) {
                type = card
                cardName = card.cardName
                break
            }
        }
        
        // check validity
        valid = luhnCheck(number: cardnumberOnly)
        
        // format
        var formatted4 = ""
        for character in numberOnly {
        if formatted4.count == 4 {
            formatted += formatted4 + " "
            formatted4 = ""
        }
            formatted4.append(character)
        }
        
        formatted += formatted4 // the rest
    
    // return the tuple
    return (type,cardName, formatted, valid)
    }
}
class CardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var cardImageView:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.clipsToBounds = true
        self.layer.cornerRadius = 6.0
    }
    func setCardType(cardType:CardType){
        if cardType == .visa{
            self.cardImageView.image = #imageLiteral(resourceName: "visacard").withRenderingMode(.alwaysOriginal)
        }else if cardType == .unionpay{
            self.cardImageView.image = #imageLiteral(resourceName: "unionpaycard").withRenderingMode(.alwaysOriginal)
        }else if cardType == .mastercard{
            self.cardImageView.image = #imageLiteral(resourceName: "mastercard").withRenderingMode(.alwaysOriginal)
        }else if cardType == .jcb{
            self.cardImageView.image = #imageLiteral(resourceName: "jcbcard").withRenderingMode(.alwaysOriginal)
        }else if cardType == .discover{
            self.cardImageView.image = #imageLiteral(resourceName: "discover").withRenderingMode(.alwaysOriginal)
        }else if cardType == .dinnerclub{
            self.cardImageView.image = #imageLiteral(resourceName: "dinnerclub").withRenderingMode(.alwaysOriginal)
        }else if cardType == .americanexpress{
            self.cardImageView.image = #imageLiteral(resourceName: "americanexpress").withRenderingMode(.alwaysOriginal)
        }else if cardType == .defaultCard{
            self.cardImageView.image = #imageLiteral(resourceName: "othercard").withRenderingMode(.alwaysOriginal)
        }else{
            self.cardImageView.image = #imageLiteral(resourceName: "othercard").withRenderingMode(.alwaysOriginal)
        }
    }
}

