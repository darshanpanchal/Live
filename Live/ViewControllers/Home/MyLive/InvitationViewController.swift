//
//  InvitationViewController.swift
//  Live
//
//  Created by IPS on 25/12/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import ContactsUI
import Foundation

protocol InvitationDelegate {
    func dismissInvitationController()
    func invitationSentSuccessfully(email:String)
}
class InvitationViewController: UIViewController {

    @IBOutlet var invitationContainerView:UIView!
    @IBOutlet var sliderView:UIView!
    @IBOutlet var heightOfContainerView:NSLayoutConstraint!
    @IBOutlet var sliderLine:UIView!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var objSegmentController:UISegmentedControl!
    @IBOutlet var contactContainerView:UIView!
    @IBOutlet var emailInviteContainerView:UIView!
    @IBOutlet var objSearchBar:UISearchBar!
    @IBOutlet var tableContacts:UITableView!
    @IBOutlet var bottomConstraint:NSLayoutConstraint!
    @IBOutlet var txtEmail:TweeActiveTextField!
    @IBOutlet var btnSentInvite:RoundButton!
    @IBOutlet var lblEmailInvitationHint:UILabel!
    
    var email:String = ""
    var userEmailID:String{
        get{
            return email
        }
        set{
            self.email = newValue
            //UserEmailUpdate
            self.configureSendInvationState()
        }
    }
    var strContactSearch:String = ""
    var objExperience:Experience?
    var startingPoint:CGFloat = 0.0
    var currentHeight:CGFloat = 0.0
    var originalHeight:CGFloat = UIScreen.main.bounds.height - 50.0
    var height :CGFloat = UIScreen.main.bounds.height - 50.0
    var containerViewHeight:CGFloat{
        get{
            return height
        }
        set{
            self.height = newValue
            //Update Height
            self.updateContainerHeight()
        }
    }
    var invitationDelegate:InvitationDelegate?
    var phoneContacts = [PhoneContact]() // array of PhoneContact(It is model find it below)
    var filter: ContactsFilter = .mail
    var arycontactFilter:[PhoneContact] = []
    let tableviewCellHeight:CGFloat = 88.0
    var invitedUserEmailSet:NSMutableSet = NSMutableSet()
    override func viewDidLoad() {
        super.viewDidLoad()

        //configure invitationview
        self.configureInvitationView()
        
        //add gesture on slider
        self.addGestureOnSlider()
        
        //Add Dynamic Font
        self.addDynamicFont()
        
        //Fetch DeviceContacts
        self.fetchDeviceContacts()

        self.objSegmentController.selectedSegmentIndex = 0
        self.contactContainerView.isHidden = false
        self.emailInviteContainerView.isHidden = true
        
        //Configure email invitation container
        self.configureEmailInvitationContainer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CouponCodeListViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CouponCodeListViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.currentHeight = 0.0
    }
    // MARK: - Custom Methods
    func configureSendInvationState(){
        if self.userEmailID.count > 0{
            self.btnSentInvite.backgroundColor = UIColor.init(hexString:"36527D")
        }else{
            self.btnSentInvite.backgroundColor = UIColor.init(hexString:"B3B3B3")
        }
        self.btnSentInvite.isEnabled = self.userEmailID.count > 0
    }
    func addDynamicFont(){
        self.lblTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblTitle.adjustsFontForContentSizeCategory = true
        self.lblTitle.adjustsFontSizeToFitWidth = true
        
        
        self.lblTitle.text = "\(Vocabulary.getWordFromKey(key: "inviteFriend.hint"))"
        self.lblEmailInvitationHint.text = "\(Vocabulary.getWordFromKey(key: "userInvitationHint"))"
        
        self.btnSentInvite.setTitle(Vocabulary.getWordFromKey(key: "sendInvitationHint"), for: .normal)
        self.btnSentInvite.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.btnSentInvite.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnSentInvite.titleLabel?.adjustsFontSizeToFitWidth = true
        self.objSegmentController.setTitle(Vocabulary.getWordFromKey(key: "fromContact.hint"), forSegmentAt: 0)
        self.objSegmentController.setTitle(Vocabulary.getWordFromKey(key: "byEmail.hint"), forSegmentAt: 1)
    }
    func updateContainerHeight(){
        DispatchQueue.main.async {
            self.heightOfContainerView.constant = self.containerViewHeight
        }
    }
    func configureEmailInvitationContainer(){
        
        self.txtEmail.placeHolderFont = UIFont.init(name: "Avenir-Heavy", size: 14.0)
        //self.txtEmail.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1).pointSize
        self.txtEmail.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtEmail.adjustsFontForContentSizeCategory = true
        
        self.txtEmail.textColor = UIColor.black.withAlphaComponent(0.95)
        self.txtEmail.placeholderColor = UIColor.black
        
        self.txtEmail.tweePlaceholder = Vocabulary.getWordFromKey(key: "email.placeholder")
        self.txtEmail.delegate = self
        
        self.configureSendInvationState()
    }
    func configureInvitationView(){
        self.invitationContainerView.clipsToBounds = true
        self.invitationContainerView.layer.cornerRadius = 5.0
        
        self.sliderLine.clipsToBounds = true
        self.sliderLine.layer.cornerRadius = 3.0
        
        
        
        //Configure Contact SearchBar
        self.configureContactSearchBar()
        
        //Configure Contact Tableview
        self.configureContactTableView()
        
        
    }
    func configureContactSearchBar(){
        self.objSearchBar.delegate = self
        self.objSearchBar.backgroundImage = UIImage.init()
        self.objSearchBar.backgroundColor = UIColor.white
        self.objSearchBar.placeholder = Vocabulary.getWordFromKey(key:"SearchHint")
        if let textFieldInsideSearchBar = objSearchBar.value(forKey: "searchField") as? UITextField{
            textFieldInsideSearchBar.textColor = UIColor.black
            textFieldInsideSearchBar.backgroundColor = UIColor.init(hexString:"f1f1f1")
        }
    }
    func configureContactTableView(){
        
        self.tableContacts.rowHeight = UITableViewAutomaticDimension
        self.tableContacts.estimatedRowHeight = 50.0
        self.tableContacts.delegate = self
        self.tableContacts.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "InvitationContactCell", bundle: nil)
        self.tableContacts.register(objNib, forCellReuseIdentifier: "InvitationContactCell")
        // self.tableViewLogIn.tableFooterView = self.tableViewFooterView
        self.tableContacts.separatorStyle = .none
        self.tableContacts.reloadData()
        self.tableContacts.sectionIndexColor = UIColor.init(hexString: "36527d")
    }
    func addGestureOnSlider(){
          let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        self.sliderView.addGestureRecognizer(gesture)
        self.sliderView.isUserInteractionEnabled = true
        gesture.delegate = self
    }
    @objc func wasPinch(gestureRecognizer: UIPinchGestureRecognizer){
        let tranform = CGAffineTransform.init(scaleX: gestureRecognizer.scale, y: gestureRecognizer.scale)
        self.invitationContainerView.transform = tranform
    }
     @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        let translation = gestureRecognizer.translation(in: self.sliderView)
        //let velocity:CGPoint = gestureRecognizer.velocity(in: self.invitationContainerView)
        
        if gestureRecognizer.state == .began{
            self.startingPoint = translation.y
        }else if gestureRecognizer.state == UIGestureRecognizerState.changed  {
            
            UIView.animate(withDuration: 0.1) {
                if self.startingPoint + translation.y > self.originalHeight{
                    self.invitationDelegate?.dismissInvitationController()
                }else {
                    let difference = self.originalHeight - (self.startingPoint + translation.y)
                    if difference < self.originalHeight{
                        self.containerViewHeight = difference
                    }else{
                        self.containerViewHeight = self.originalHeight
                    }
                }
            }
            self.currentHeight = self.containerViewHeight
            
        }else if gestureRecognizer.state == .ended{
            if self.currentHeight < UIScreen.main.bounds.height - 300 {
                self.invitationDelegate?.dismissInvitationController()
            }else {
                UIView.animate(withDuration: 0.3) {
                    self.containerViewHeight = self.originalHeight
                }
            }
        }
    }
    func fetchDeviceContacts(){
        
        phoneContacts.removeAll()
        var allContacts = [PhoneContact]()
        for contact in PhoneContacts.getContacts(filter: filter) {
            allContacts.append(PhoneContact(contact: contact))
        }
        
        self.arycontactFilter = [PhoneContact]()
        if self.filter == .mail {
            self.arycontactFilter = allContacts.filter({ $0.email.count > 0 && $0.name.count > 0}) // getting all email
        } else if self.filter == .message {
            self.arycontactFilter = allContacts.filter({ $0.phoneNumber.count > 0 })
        } else {
            self.arycontactFilter = allContacts
        }
        
        phoneContacts.append(contentsOf:  self.arycontactFilter)
            DispatchQueue.main.async {
                self.view.endEditing(true)
                self.tableContacts.reloadData()
            }
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomConstraint.constant = self.getKeyboardSizeHeight() + 30
                print(keyboardSize)
                print(UIScreen.main.bounds.height)
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3, animations: {
                self.bottomConstraint.constant = 0.0
                print(keyboardSize)
                print(UIScreen.main.bounds.height)
                self.view.layoutIfNeeded()
            })
        }
    }
    func getKeyboardSizeHeight()->CGFloat{
        if UIScreen.main.bounds.height == 812.0{
            return 250.0
        }else if UIScreen.main.bounds.height == 736.0{
            return 226.0
        }else if UIScreen.main.bounds.height == 667.0{
            return 216.0
        }else if UIScreen.main.bounds.height == 568.0{
            return 216.0
        }else{
            return 250.0
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonCloseSelector(sender:UIButton){
        self.invitationDelegate?.dismissInvitationController()
    }
    @IBAction func segmentValueChangeSelector(sender:UISegmentedControl){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        switch sender.selectedSegmentIndex {
        case 0: //ByContact
            self.contactContainerView.isHidden = false
            self.emailInviteContainerView.isHidden = true
            break
        case 1: //ByEmail
            self.contactContainerView.isHidden = true
            self.emailInviteContainerView.isHidden = false
            break
        default:
            self.contactContainerView.isHidden = false
            self.emailInviteContainerView.isHidden = true
            break
        }
    }
    @IBAction func buttonSentInvitation(sender:UIButton){
        self.userInviteRequest(index:0, isForEmail: true, userEmail: self.userEmailID)
    }
    // MARK: - API Request
    //  Favourite API Calling
    func userInviteRequest(index:Int,isForEmail:Bool,userEmail:String = ""){
        if isForEmail{
            guard self.isValidEmail() else{
                return
            }
        }
        let objContact = self.arycontactFilter[index]

        let urlBookingDetailInvite = "experience/invite/booking"
          let requestParameters =
            ["BookingId": "\(self.objExperience?.bookingID ?? "0")",
                "Email":isForEmail ? "\(userEmail)":"\(objContact.email.first!)"]
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:urlBookingDetailInvite, parameter: requestParameters as [String : AnyObject], isHudeShow: isForEmail, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successdata = success["data"] as? [String:Any],let strMSg = successdata["Message"]{
                
                if let dataDic = successdata["Data"],Bool.init("\(dataDic)"){
                    if isForEmail{
                        self.invitationDelegate?.invitationSentSuccessfully(email: "\(userEmail)")
                    }else{
                        self.invitedUserEmailSet.add("\(objContact.email)")
                        DispatchQueue.main.async {
                            self.tableContacts.reloadData()
                            ShowToast.show(toatMessage:"\(strMSg)")
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.tableContacts.reloadData()
                        ShowToast.show(toatMessage:"\(strMSg)")
                    }
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }) { (responseFail) in
            DispatchQueue.main.async {
                self.tableContacts.reloadData()
            }
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
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
extension InvitationViewController:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard !typpedString.isContainWhiteSpace() else{
            return false
        }
        self.userEmailID = "\(typpedString)"
        self.txtEmail.activeLineColor = .black
        self.txtEmail.lineColor = .black
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.userEmailID = ""
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        //Post User Invitation Request
        self.userInviteRequest(index: 0, isForEmail: true, userEmail: self.userEmailID)
        return true
    }
    func isValidEmail()->Bool{
        guard self.userEmailID.count > 0 else{
            DispatchQueue.main.async {
                self.txtEmail.activeLineColor = .red
                self.txtEmail.lineColor = .red
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "enterEmail.title"))
                self.txtEmail.invalideField()
            }
            return false
        }
        guard self.userEmailID.isValidEmail() else{
            DispatchQueue.main.async {
                self.txtEmail.activeLineColor = .red
                self.txtEmail.lineColor = .red
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "pleaseEnterValidEmail.title"))
                self.txtEmail.invalideField()
            }
            return false
        }
        self.txtEmail.activeLineColor = .black
        self.txtEmail.lineColor = .black
        return true
    }
}
extension InvitationViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        if self.arycontactFilter.count > 0{
            tableView.removeMessageLabel()
        }else{
            tableView.showMessageLabel()
        }
        return self.arycontactFilter.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let invitationCell:InvitationContactCell = tableView.dequeueReusableCell(withIdentifier: "InvitationContactCell", for: indexPath)
            as! InvitationContactCell
        if self.arycontactFilter.count > indexPath.row{
            let objContact = self.arycontactFilter[indexPath.row]
            invitationCell.lblContactName?.attributedText = self.filterAndModifyTextAttributes(searchStringCharacters:self.strContactSearch, completeStringWithAttributedText: "\(objContact.name)")
            if self.invitedUserEmailSet.contains("\(objContact.email)"){
                invitationCell.lblInvitationSent.isHidden = false
                invitationCell.buttonInvitation.isHidden = true
            }else{
                invitationCell.lblInvitationSent.isHidden = true
                invitationCell.buttonInvitation.isHidden = false
            }
        }
        invitationCell.buttonInvitation.tag = indexPath.row
        invitationCell.delegate = self
        invitationCell.selectionStyle = .none
        
        return invitationCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableviewCellHeight
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if self.strContactSearch.count > 0{
            return []
        }else{
            return ["#","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S", "T","U","V","W","X","Y","Z","#"]
        }
        
    }
}
extension InvitationViewController:UISearchBarDelegate{
    private func filterAndModifyTextAttributes(searchStringCharacters: String, completeStringWithAttributedText: String) -> NSMutableAttributedString {
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: completeStringWithAttributedText)
        let pattern = searchStringCharacters.lowercased()
        let range: NSRange = NSMakeRange(0, completeStringWithAttributedText.count)
        var regex = NSRegularExpression()
        do {
            regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())
            regex.enumerateMatches(in: completeStringWithAttributedText.lowercased(), options: NSRegularExpression.MatchingOptions(), range: range) {
                (textCheckingResult, matchingFlags, stop) in
                let subRange = textCheckingResult?.range
                let attributes : [NSAttributedStringKey : Any] = [.font : UIFont.boldSystemFont(ofSize: 17),.foregroundColor: UIColor.black ]
                attributedString.addAttributes(attributes, range: subRange!)
            }
        }catch{
            print(error.localizedDescription)
        }
        return attributedString
    }
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
          let typpedString = ((searchBar.text)! as NSString).replacingCharacters(in: range, with: text)
        self.strContactSearch = typpedString
        let filtered = self.phoneContacts.filter { $0.name.localizedCaseInsensitiveContains("\(typpedString)")}
        self.arycontactFilter = filtered
        DispatchQueue.main.async {
            self.tableContacts.reloadData()
        }
        return true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0{
            self.strContactSearch = ""
            self.fetchDeviceContacts()
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
extension InvitationViewController:UserInvitationDelegate{
    func didselectInvitationOnIndex(index: Int) {
        if self.arycontactFilter.count > index{
            //let objContact = self.arycontactFilter[index]
            self.userInviteRequest(index:index,isForEmail:false)
        }
    }
}
extension InvitationViewController:UIGestureRecognizerDelegate{
    
}
enum ContactsFilter {
    case none
    case mail
    case message
}
class PhoneContacts {
    
    class func getContacts(filter: ContactsFilter = .none) -> [CNContact] { //  ContactsFilter is Enum find it below
        
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers") // you can use print()
        }
        
        var results: [CNContact] = []
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching containers")
            }
        }
        return results
    }
}
class PhoneContact: NSObject {
    
    var name: String = ""
    var avatarData: Data?
    var phoneNumber: [String] = [String]()
    var email: [String] = [String]()
    var isSelected: Bool = false
    var isInvited = false
    
    init(contact: CNContact) {
        name        = contact.givenName + " " + contact.familyName
        avatarData  = contact.thumbnailImageData
        for phone in contact.phoneNumbers {
            phoneNumber.append(phone.value.stringValue)
        }
        for mail in contact.emailAddresses {
            email.append(mail.value as String)
        }
    }
    
    override init() {
        super.init()
    }
}
protocol UserInvitationDelegate {
    func didselectInvitationOnIndex(index:Int)
}
class InvitationContactCell: UITableViewCell {

    @IBOutlet var lblContactName:UILabel!
    
    @IBOutlet var lblInvitationSent:UILabel!
    @IBOutlet var buttonInvitation:UIButton!
    @IBOutlet var objActivity:UIActivityIndicatorView!
    var delegate:UserInvitationDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    @IBAction func buttonInvitationSelector(sender:UIButton){
        if let _ = self.delegate{
            self.objActivity.startAnimating()
            self.objActivity.isHidden = false
            self.lblInvitationSent.isHidden = true
            self.buttonInvitation.isHidden = true
            self.delegate?.didselectInvitationOnIndex(index: sender.tag)
        }
    }
}
