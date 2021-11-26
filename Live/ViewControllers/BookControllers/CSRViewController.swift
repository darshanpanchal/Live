//
//  CSRViewController.swift
//  Live
//
//  Created by IPS on 15/10/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
protocol CSRDelegate {
    func exitCSRDelegate()
}

class CSRViewController: UIViewController {

    var objCSRDelegate:CSRDelegate?
    @IBOutlet var buttonClose:UIButton!
    @IBOutlet var buttonGive:RoundButton!
    @IBOutlet var lblThanksHint:UILabel!
    @IBOutlet var lblDiscriptionHint:UILabel!
    @IBOutlet var tableViewOrganization:UITableView!
    @IBOutlet var lblNoOrganization:UILabel!
    
    var arrayOfOrganization:[CSROrganization] = []
    var heightOfTableView:CGFloat{
        get{
            return 72.0
        }
    }
    var bookingID:String = ""
    var selectedIndex:Int = 0
    var selectedOrganization:Int{
        get{
            return selectedIndex
        }
        set{
            self.selectedIndex = newValue
            DispatchQueue.main.async {
                self.tableViewOrganization.reloadData()
            }
        }
    }
    var objCurrency:String = ""
    var objExperiencePrice:String = ""
    var objExperienceTitle:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.configureTableView()
        self.getOrganizationAPIRequest()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.addDynamicFont()
            //self.addLocalisation()
        }
    }
    // MARK: - Custom Methods
    func addDynamicFont(){
        
    }
    func addLocalisation(){
        self.lblThanksHint.text = Vocabulary.getWordFromKey(key: "")
        self.lblDiscriptionHint.text = Vocabulary.getWordFromKey(key: "")
    }
    func configureTableView(){
        self.tableViewOrganization.tableFooterView = UIView()
        self.tableViewOrganization.delegate = self
        self.tableViewOrganization.dataSource = self
        self.tableViewOrganization.separatorStyle = .none
        let objNib = UINib.init(nibName: "CSROrganizationTableVIewCell", bundle: nil)
        self.tableViewOrganization.register(objNib, forCellReuseIdentifier: "CSROrganizationTableVIewCell")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Selector Methods
    @IBAction func buttonCloseSelector(sender:UIButton){
        DispatchQueue.main.async {
            if let _ = self.objCSRDelegate?.exitCSRDelegate(){
                self.dismiss(animated: true, completion: nil)
                self.objCSRDelegate!.exitCSRDelegate()
            }
        }
    }
    @IBAction func buttonGiveSelector(sender:UIButton){
        if self.arrayOfOrganization.count > 0{
            self.postCSRAPIRequest()
        }
    }
    
    // MARK: - API RequestMethods
    func getOrganizationAPIRequest(){
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:kGETOrganizationList, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let array = successDate["CSROrganisations"] as? [[String:Any]]{
                self.arrayOfOrganization = []
                for organization in array{
                    let objOrganization = CSROrganization.init(organizationDetail: organization)
                    self.arrayOfOrganization.append(objOrganization)
                }
                DispatchQueue.main.async {
                    self.tableViewOrganization.reloadData()
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
    func postCSRAPIRequest(){
        var requestParameters:[String:Any] = [:]
        guard self.arrayOfOrganization.count > self.selectedIndex else{
            return
        }
        let organization = self.arrayOfOrganization[self.selectedIndex]
        requestParameters["OrganisationId"] = "\(organization.id)"
        requestParameters["BookingId"] = "\(self.bookingID)"
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kSaveOrganization, parameter: requestParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let strMessage = successData["Message"]{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(strMessage)")
                    if let _ = self.objCSRDelegate?.exitCSRDelegate(){
                        self.dismiss(animated: true, completion: nil)
                        self.objCSRDelegate!.exitCSRDelegate()
                    }
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
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
extension CSRViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DispatchQueue.main.async {
            if self.arrayOfOrganization.count > 0 {
                self.buttonGive.isHidden = false
                self.lblNoOrganization.isHidden = true
            }else{
                self.buttonGive.isHidden = true
                self.lblNoOrganization.isHidden = false
            }
        }
        
        return self.arrayOfOrganization.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CSROrganizationTableVIewCell") as! CSROrganizationTableVIewCell
        if self.arrayOfOrganization.count > indexPath.row{
            let objOrganization:CSROrganization = self.arrayOfOrganization[indexPath.row]
            cell.btnInformation.tag = indexPath.row
            cell.delegate = self
            DispatchQueue.main.async {
                cell.imageOrganization.imageFromServerURL(urlString: objOrganization.logo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                cell.lblOrganization.text = "\(objOrganization.organisationName)"
                cell.lblOrganizationCurrency.text = "\(self.calculatePercentage(strPrice:self.objExperiencePrice, strPercentage: objOrganization.percentage)) (\(self.objCurrency))"
            }
        }
            if self.selectedOrganization == indexPath.row{
                cell.imageSelect.isHidden = false
            }else{
                cell.imageSelect.isHidden = true
            }
  
           return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedOrganization = indexPath.row
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightOfTableView
    }
    func calculatePercentage(strPrice:String,strPercentage:String)->String{
        let price = CGFloat((strPrice as NSString).floatValue)
        let percentage = CGFloat((strPercentage as NSString).floatValue)/100.0
        return "\(price*percentage)"
    }
}
extension CSRViewController:CSRTableViewDelegate,CSRDetailDelegate{
    func informationSelector(index: Int) {
        guard  self.arrayOfOrganization.count > index else{
            return
        }
        let objOrganization:CSROrganization = self.arrayOfOrganization[index]
        
        if let csrDetailView = self.storyboard?.instantiateViewController(withIdentifier: "CSRDetailViewController") as? CSRDetailViewController{
            csrDetailView.modalPresentationStyle = .overFullScreen
            csrDetailView.delegate = self
            csrDetailView.objOrganization = objOrganization
            csrDetailView.objCurrency = self.objCurrency
            csrDetailView.objExperiencePrice = self.objExperiencePrice
            csrDetailView.objExperienceTitle = self.objExperienceTitle
            self.present(csrDetailView, animated: true, completion: nil)
        }
    }
    func dismissCSRDetailController() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
protocol CSRTableViewDelegate{
    func informationSelector(index:Int)
}
class CSROrganizationTableVIewCell:UITableViewCell{
    @IBOutlet var imageOrganization:ImageViewForURL!
    @IBOutlet var lblOrganization:UILabel!
    @IBOutlet var imageSelect:UIImageView!
    @IBOutlet var lblOrganizationCurrency:UILabel!
    
    @IBOutlet var btnInformation:UIButton!
    
    var delegate:CSRTableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.imageSelect.image = #imageLiteral(resourceName: "tick_select").withRenderingMode(.alwaysTemplate)
            self.imageSelect.tintColor = UIColor.init(hexString: "#36527D")
            self.imageSelect.clipsToBounds = true
            //self.imageOrganization.layer.cornerRadius = 25.0
            self.imageOrganization.clipsToBounds = true
            self.selectionStyle = .none
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageSelect.isHidden = false
    }
    @IBAction func buttonInformationSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.informationSelector(index: sender.tag)
        }
    }
}
class CSROrganization{
        private var kEmail = "Email"
        private var kId = "Id"
        private var kLogo = "Logo"
        private var kOrganisationName = "OrganisationName"
        private var kPercentage = "Percentage"
    
        var email = ""
        var id = ""
        var logo = ""
        var organisationName = ""
        var percentage = ""
    
    init(organizationDetail:[String:Any]) {
        if let objEmail = organizationDetail[kEmail],!(objEmail is NSNull) {
            self.email = "\(objEmail)"
        }
        if let objId = organizationDetail[kId],!(objId is NSNull) {
            self.id = "\(objId)"
        }
        if let objLogo = organizationDetail[kLogo],!(objLogo is NSNull) {
            self.logo = "\(objLogo)"
        }
        if let objOrganisationName = organizationDetail[kOrganisationName],!(objOrganisationName is NSNull) {
            self.organisationName = "\(objOrganisationName)"
        }
        if let objPercentage = organizationDetail[kPercentage],!(objPercentage is NSNull) {
            self.percentage = "\(objPercentage)"
        }
    }
    
}
protocol CSRDetailDelegate {
    func dismissCSRDetailController()
}
class CSRDetailViewController: UIViewController {
    
    @IBOutlet var objContainerView:UIView!
    
    @IBOutlet var lblCSRDetailTitle:UILabel!
    @IBOutlet var lblName:UILabel!
    @IBOutlet var lblNameValue:UILabel!
    @IBOutlet var lblEmail:UILabel!
    @IBOutlet var lblEmailValue:UILabel!
    @IBOutlet var lblExperienceTitle:UILabel!
    @IBOutlet var lblExperienceTitleValue:UILabel!
    @IBOutlet var lblCurrency:UILabel!
    @IBOutlet var lblCurrencyValue:UILabel!
    @IBOutlet var lblPrice:UILabel!
    @IBOutlet var lblPriceValue:UILabel!
    @IBOutlet var lblPercentage:UILabel!
    @IBOutlet var lblPercentageValue:UILabel!
    @IBOutlet var lblDonation:UILabel!
    @IBOutlet var lblDonationValue:UILabel!
    @IBOutlet var btnOkay:UIButton!
    
    
    var csrDetail:[String:Any] = [:]
    var delegate:CSRDetailDelegate?
    var objOrganization:CSROrganization?
    var objCurrency:String = ""
    var objExperiencePrice:String = ""
    var objExperienceTitle:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.objContainerView.clipsToBounds = true
        self.objContainerView.layer.cornerRadius = 6.0
        
        //configure CSR detail
        self.configureCSRDetailView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
               self.addDynamicFont()
               self.addLocalisation()
        }
    }
    // MARK: - Custom Methods
    func addLocalisation(){
        self.lblCSRDetailTitle.text = Vocabulary.getWordFromKey(key: "csrDetail.hint")
        self.lblName.text = Vocabulary.getWordFromKey(key: "name")+" :"
        self.lblEmail.text = Vocabulary.getWordFromKey(key: "email.placeholder")+" :"
        self.lblExperienceTitle.text = Vocabulary.getWordFromKey(key: "experience.hint")+" :"
        self.lblCurrency.text = Vocabulary.getWordFromKey(key: "currency")+" :"
        self.lblPrice.text = Vocabulary.getWordFromKey(key: "price")+" :"
        self.lblPercentage.text = Vocabulary.getWordFromKey(key: "percentage.hint")+" :"
        self.lblDonation.text = Vocabulary.getWordFromKey(key: "donation.hint")+" :"
        
        self.btnOkay.setTitle(Vocabulary.getWordFromKey(key: "ok.tourBtn"), for: .normal)
    }
    func addDynamicFont(){
        self.lblCSRDetailTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblCSRDetailTitle.adjustsFontForContentSizeCategory = true
        self.lblCSRDetailTitle.adjustsFontSizeToFitWidth = true
        
        
        self.lblName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblName.adjustsFontForContentSizeCategory = true
        self.lblName.adjustsFontSizeToFitWidth = true
        
        self.lblNameValue.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblNameValue.adjustsFontForContentSizeCategory = true
        self.lblNameValue.adjustsFontSizeToFitWidth = true
        
        self.lblEmail.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblEmail.adjustsFontForContentSizeCategory = true
        self.lblEmail.adjustsFontSizeToFitWidth = true
        
        self.lblEmailValue.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblEmailValue.adjustsFontForContentSizeCategory = true
        self.lblEmailValue.adjustsFontSizeToFitWidth = true
        
        self.lblExperienceTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblExperienceTitle.adjustsFontForContentSizeCategory = true
        self.lblExperienceTitle.adjustsFontSizeToFitWidth = true
        
        self.lblExperienceTitleValue.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblExperienceTitleValue.adjustsFontForContentSizeCategory = true
        self.lblExperienceTitleValue.adjustsFontSizeToFitWidth = true
        
        self.lblCurrency.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblCurrency.adjustsFontForContentSizeCategory = true
        self.lblCurrency.adjustsFontSizeToFitWidth = true
        
        self.lblCurrencyValue.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblCurrencyValue.adjustsFontForContentSizeCategory = true
        self.lblCurrencyValue.adjustsFontSizeToFitWidth = true
        
        self.lblPrice.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblPrice.adjustsFontForContentSizeCategory = true
        self.lblPrice.adjustsFontSizeToFitWidth = true
        
        self.lblPriceValue.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblPriceValue.adjustsFontForContentSizeCategory = true
        self.lblPriceValue.adjustsFontSizeToFitWidth = true
        
        self.lblPercentage.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblPercentage.adjustsFontForContentSizeCategory = true
        self.lblPercentage.adjustsFontSizeToFitWidth = true
        
        self.lblPercentageValue.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblPercentageValue.adjustsFontForContentSizeCategory = true
        self.lblPercentageValue.adjustsFontSizeToFitWidth = true
        
        self.lblDonation.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblDonation.adjustsFontForContentSizeCategory = true
        self.lblDonation.adjustsFontSizeToFitWidth = true
        
        self.lblDonationValue.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblDonationValue.adjustsFontForContentSizeCategory = true
        self.lblDonationValue.adjustsFontSizeToFitWidth = true
        
        self.btnOkay.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.btnOkay.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnOkay.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    func configureCSRDetailView(){
        if let _ = self.objOrganization{
            
            self.lblNameValue.text = "\(self.objOrganization!.organisationName)"
            self.lblEmailValue.text = "\(self.objOrganization!.email)"
            self.lblExperienceTitleValue.text = "\(self.objExperienceTitle)"
            self.lblCurrencyValue.text = "\(self.objCurrency)"
            self.lblPriceValue.text = "\(self.objExperiencePrice)"
            self.lblPercentageValue.text = "\((self.objOrganization!.percentage as NSString).floatValue) %"
            let price = CGFloat((self.objExperiencePrice as NSString).floatValue)
            let percentage = CGFloat((self.objOrganization!.percentage as NSString).floatValue)/100.0
            self.lblDonationValue.text = "\(price*percentage)"
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonOkaySelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.dismissCSRDetailController()
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
