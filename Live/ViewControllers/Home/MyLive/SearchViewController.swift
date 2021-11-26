//
//  SearchViewController.swift
//  Live
//
//  Created by IPS on 17/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
enum SearchType {
    case City
    case Country
    case Currency
    case Price
    case Effort
    case Langauge
    case Collection
    case Occurence
    case WeekDays
    case Location
    case Coupon
}
protocol NoCountryDelegate {
    func selectNoCountrySelector()
}
protocol SearchDelegate{
     func selectedCity(objCountry:CountyDetail)
}
class SearchViewController: UIViewController {

    @IBOutlet var txtSeachCountry:UITextField!
    @IBOutlet var tableViewSearch:UITableView!
    @IBOutlet var buttonCancel:RoundButton!
    @IBOutlet var buttonSelect:RoundButton!
    @IBOutlet var topConstraint:NSLayoutConstraint!
    @IBOutlet var heightOfSearchView:NSLayoutConstraint!
    @IBOutlet var lblSearchHeader:UILabel!
    @IBOutlet var containerView:UIView!
    @IBOutlet var leadingStackConstraint:NSLayoutConstraint!
    @IBOutlet var trailingStackConstraint:NSLayoutConstraint!
    @IBOutlet var imageSearch:UIImageView!
    @IBOutlet var viewSeprator:UIView!
    
    @IBOutlet var nocountySelectorHeight:NSLayoutConstraint?
    @IBOutlet weak var testButton: UIButton?
    
    var noCountryDelegate:NoCountryDelegate?
    var isGuideCountry:Bool = false
    var isGuideLanguage:Bool = false
    var isGuideRequestLanguage:Bool = false
    var isBecomeGuideLanguage:Bool = false
    var isFilterLanguage:Bool = false
    var isGuideRequestLocation:Bool = false
    var isBecomeGuideLocation:Bool = false
    var isBecomeGuideCountry:Bool = false
    var isInquiryCountry:Bool = false
    var isSignUpCountry:Bool = false
    var isSignUpLocation:Bool = false
    var isCityFreeSearch:Bool = false
    var isFilterCollection:Bool = false
    var objSearchType:SearchType = .City
    var isChooseCity:Bool = false
    var arrayOfCountry:[CountyDetail] = []
    var arrayOfFilterCounty:[CountyDetail] = []
    var arrayOfGuideCountry:[BecomeGuideCountry] = []
    var arrayOfFilterGuideCountry:[BecomeGuideCountry] = []
    let heightOfTableViewCell:CGFloat = 62.0
    let sizeOfFont:CGFloat = 18.0
    var typpedString:String = ""
    var searchDelagate:SearchDelegate?
    var arrayOfCurrency:[Currency] = []
    var arrayOfFilterCurrency:[Currency] = []
    var araryOfEffort:[String] = ["\(Vocabulary.getWordFromKey(key:"Soft"))","\(Vocabulary.getWordFromKey(key:"Moderate"))","\(Vocabulary.getWordFromKey(key:"Hard"))","\(Vocabulary.getWordFromKey(key:"Extreme"))"]
    var arrayOfFilterEffort:[String] = ["\(Vocabulary.getWordFromKey(key:"Soft"))","\(Vocabulary.getWordFromKey(key:"Moderate"))","\(Vocabulary.getWordFromKey(key:"Hard"))","\(Vocabulary.getWordFromKey(key:"Extreme"))"]
    var arrayOfLanguage:[ExperienceLangauge] = []
    var arrayOfFilterLangauge:[ExperienceLangauge] = []
    var arrayOfSelectedLangauge:[ExperienceLangauge] = []
    var selectedLangauges:NSMutableSet = NSMutableSet()
    var arrayOfCollection:[Collections] = []
    var arrayOfFilterCollection:[Collections] = []
    var arrayOfSelectedCollection:[Collections] = []
    var selectedCollections:NSMutableSet = NSMutableSet()
    var arrayOfCoupon:[Coupon] = []
    var arrayOfFilterCoupon:[Coupon] = []
    var arrayOfOccurance:[String] = ["\(Vocabulary.getWordFromKey(key:"Once"))","\(Vocabulary.getWordFromKey(key:"Daily"))","\(Vocabulary.getWordFromKey(key:"Weekly"))","\(Vocabulary.getWordFromKey(key:"Weekdays"))","\(Vocabulary.getWordFromKey(key:"Monthly"))"]
    var arrayOfFilterOccurance:[String] = ["\(Vocabulary.getWordFromKey(key:"Once"))","\(Vocabulary.getWordFromKey(key:"Daily"))","\(Vocabulary.getWordFromKey(key:"Weekly"))","\(Vocabulary.getWordFromKey(key:"Weekdays"))","\(Vocabulary.getWordFromKey(key:"Monthly"))"]
    var arrayOfWeekDays:[String] = ["\(Vocabulary.getWordFromKey(key:"Monday"))","\(Vocabulary.getWordFromKey(key:"Tuesday"))","\(Vocabulary.getWordFromKey(key:"Wednesday"))","\(Vocabulary.getWordFromKey(key:"Thursday"))","\(Vocabulary.getWordFromKey(key:"Friday"))","\(Vocabulary.getWordFromKey(key:"Saturday"))","\(Vocabulary.getWordFromKey(key:"Sunday"))"]
    var arrayOfFilterWeekDays:[String] = ["\(Vocabulary.getWordFromKey(key:"Monday"))","\(Vocabulary.getWordFromKey(key:"Tuesday"))","\(Vocabulary.getWordFromKey(key:"Wednesday"))","\(Vocabulary.getWordFromKey(key:"Thursday"))","\(Vocabulary.getWordFromKey(key:"Friday"))","\(Vocabulary.getWordFromKey(key:"Saturday"))","\(Vocabulary.getWordFromKey(key:"Sunday"))"]
    var heightOfKeyboard:CGFloat{
        get{
            return 320.0*UIScreen.main.bounds.height/667.0
        }
    }
    var arrayOfLocation:[CountyDetail] = []
    var arrayOfFilterLocation:[CountyDetail]=[]
    var countryID:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageSearch.image = #imageLiteral(resourceName: "searchupdate").withRenderingMode(.alwaysTemplate)
        imageSearch.tintColor = UIColor.black
        imageSearch.alpha = 0.3
        // Do any additional setup after loading the view.
        self.testButton?.setTitle(Vocabulary.getWordFromKey(key: "noCountry.hint")+"?", for: .normal)
//
        self.buttonSelect.setTitle(Vocabulary.getWordFromKey(key: "ok.title"), for: .normal)
        self.buttonCancel.setTitle(Vocabulary.getWordFromKey(key: "Cancel"), for: .normal)
        //Configure SeachView
        self.configureSearchView()
      
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.lblSearchHeader.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblSearchHeader.adjustsFontForContentSizeCategory = true
        self.lblSearchHeader.adjustsFontSizeToFitWidth = true
        
        self.txtSeachCountry.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtSeachCountry.adjustsFontForContentSizeCategory = true
        
        self.buttonCancel.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonCancel.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonCancel.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.buttonSelect.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonSelect.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonSelect.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        NotificationCenter.default.removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
   
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3, animations: {
                self.topConstraint.constant = 0
                self.heightOfSearchView.constant = UIScreen.main.bounds.height - self.heightOfKeyboard
                print(keyboardSize)
                print(UIScreen.main.bounds.height)
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3, animations: {
                self.topConstraint.constant = 100
                self.heightOfSearchView.constant = 434.0
                print(keyboardSize)
                print(UIScreen.main.bounds.height)
                self.view.layoutIfNeeded()
            })
        }
    }
    func configureSearchView(){
        self.txtSeachCountry.delegate = self
        self.configureTableView()
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 14.0
        self.containerView.backgroundColor = UIColor.init(hexString:"F2F2F2")//UIColor.init(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 0.82)
        /*
        self.buttonCancel.setBackgroundColor(color:UIColor.init(hexString:"2963AF"), forState: .highlighted)
        self.buttonSelect.setBackgroundColor(color:UIColor.init(hexString:"2963AF"), forState: .highlighted)
        self.buttonCancel.applyGradient(colours: [UIColor.white.withAlphaComponent(0.1),UIColor.init(hexString:"2963AF").withAlphaComponent(0.2),
                                                  UIColor.init(hexString:"2963AF").withAlphaComponent(0.5), UIColor.init(hexString:"2963AF")])
        self.buttonSelect.applyGradient(colours: [UIColor.white.withAlphaComponent(0.1),UIColor.init(hexString:"2963AF").withAlphaComponent(0.2),
                                                  UIColor.init(hexString:"2963AF").withAlphaComponent(0.5),UIColor.init(hexString:"2963AF")])*/
    }
    func configureTableView(){
        self.tableViewSearch.tableHeaderView = UIView()
        self.tableViewSearch.rowHeight = UITableViewAutomaticDimension
        self.tableViewSearch.estimatedRowHeight = heightOfTableViewCell
        self.tableViewSearch.delegate = self
        self.tableViewSearch.dataSource = self
        self.tableViewSearch.tableFooterView = UIView()
        self.tableViewSearch.separatorStyle = .none
        let width = (UIScreen.main.bounds.height > 568.0) ? self.containerView.bounds.width/3 : self.containerView.bounds.width/3 - 20.0
        
        switch self.objSearchType {
            case .Location:
                self.lblSearchHeader.text = "\(Vocabulary.getWordFromKey(key: "Select")) \(Vocabulary.getWordFromKey(key: "Location") )"
                self.txtSeachCountry.placeholder = Vocabulary.getWordFromKey(key:"SearchHere")
                if self.arrayOfLocation.count > 0{
                    self.arrayOfFilterLocation = self.arrayOfLocation
                }
                self.buttonSelect.isHidden = true
                self.leadingStackConstraint.constant = width
                self.trailingStackConstraint.constant = width
            break
            case .City:
                self.lblSearchHeader.text = (self.isChooseCity) ? Vocabulary.getWordFromKey(key:"ChooseCity.hint") : Vocabulary.getWordFromKey(key:"SearchCity")
                self.txtSeachCountry.placeholder = Vocabulary.getWordFromKey(key:"SearchHere")
                if self.arrayOfCountry.count > 0{
                    self.arrayOfFilterCounty = self.arrayOfCountry
                }
                self.buttonSelect.isHidden = true
                self.leadingStackConstraint.constant = width
                self.trailingStackConstraint.constant = width
                break
            case .Country:
                self.lblSearchHeader.text =  Vocabulary.getWordFromKey(key: "title.searchCountry")
                self.txtSeachCountry.placeholder = Vocabulary.getWordFromKey(key:"SearchHere")
                if self.arrayOfGuideCountry.count > 0{
                    self.arrayOfFilterGuideCountry = self.arrayOfGuideCountry
                }
                self.buttonSelect.isHidden = true
                self.leadingStackConstraint.constant = width
                self.trailingStackConstraint.constant = width
                break
            
            case .Price:
                self.lblSearchHeader.text = Vocabulary.getWordFromKey(key:"SearchPrice")
                self.txtSeachCountry.placeholder = Vocabulary.getWordFromKey(key:"SearchHere")
                self.buttonSelect.isHidden = true
                self.leadingStackConstraint.constant = width
                self.trailingStackConstraint.constant = width
                break
            case .Currency:
                self.lblSearchHeader.text = Vocabulary.getWordFromKey(key:"SearchCurrency")
                self.txtSeachCountry.placeholder = Vocabulary.getWordFromKey(key:"SearchHere")
                if self.arrayOfCurrency.count > 0{
                    self.arrayOfFilterCurrency = self.arrayOfCurrency
                }
                self.buttonSelect.isHidden = true
                self.leadingStackConstraint.constant = width
                self.trailingStackConstraint.constant = width
                break
            case .Effort:
                 self.lblSearchHeader.text = Vocabulary.getWordFromKey(key:"SearchEffort")
                self.txtSeachCountry.placeholder = Vocabulary.getWordFromKey(key:"SearchHere")
                
                self.buttonSelect.isHidden = true
                 self.leadingStackConstraint.constant = width
                 self.trailingStackConstraint.constant = width
                break
            case .Langauge:
                self.lblSearchHeader.text = Vocabulary.getWordFromKey(key:"SearchLangauge")
                self.txtSeachCountry.placeholder = Vocabulary.getWordFromKey(key:"SearchHere")
                if self.arrayOfLanguage.count > 0{
                    self.arrayOfFilterLangauge = self.arrayOfLanguage
                }
                self.buttonSelect.isHidden = false
                self.leadingStackConstraint.constant = 35.0
                self.trailingStackConstraint.constant = 35.0
                break
            case .Collection:
                self.lblSearchHeader.text = Vocabulary.getWordFromKey(key:"SearchCollection")
                self.txtSeachCountry.placeholder = Vocabulary.getWordFromKey(key:"SearchHere")
                if self.arrayOfCollection.count > 0{
                    self.arrayOfFilterCollection = self.arrayOfCollection
                }
                self.buttonSelect.isHidden = false
                self.leadingStackConstraint.constant = 35.0
                self.trailingStackConstraint.constant = 35.0
                break
            case .Occurence:
                self.lblSearchHeader.text = Vocabulary.getWordFromKey(key:"HowOften")
                self.txtSeachCountry.placeholder = Vocabulary.getWordFromKey(key:"SearchHere")
                if self.arrayOfOccurance.count > 0{
                    self.arrayOfFilterOccurance = self.arrayOfOccurance
                }
                self.buttonSelect.isHidden = true
                self.leadingStackConstraint.constant = width
                self.trailingStackConstraint.constant = width
                break
            case .WeekDays:
                self.lblSearchHeader.text = Vocabulary.getWordFromKey(key:"SearchWeekDay")
                self.txtSeachCountry.placeholder = Vocabulary.getWordFromKey(key:"SearchHere")
                if self.arrayOfWeekDays.count > 0{
                    self.arrayOfFilterWeekDays = self.arrayOfWeekDays
                }
                self.buttonSelect.isHidden = true
                self.leadingStackConstraint.constant = width
                self.trailingStackConstraint.constant = width
                break
            case .Coupon:
                self.lblSearchHeader.text = Vocabulary.getWordFromKey(key:"searchCoupon.hint")
                self.txtSeachCountry.placeholder = Vocabulary.getWordFromKey(key:"SearchHere")
                if self.arrayOfCoupon.count > 0{
                    self.arrayOfFilterCoupon = self.arrayOfCoupon
                }
                self.buttonSelect.isHidden = true
                self.leadingStackConstraint.constant = width
                self.trailingStackConstraint.constant = width
                break
        }
        defer{
            self.viewSeprator.isHidden = self.buttonSelect.isHidden
            self.tableViewSearch.reloadData()
            if self.isGuideCountry,self.objSearchType == .Country{
                self.testButton?.isHidden = false
                self.nocountySelectorHeight?.constant = 40
            }else{
                self.testButton?.isHidden = true
                self.nocountySelectorHeight?.constant = 0
            }
        }
    }
    // MARK: - API Request Methods
    //Get Free Search CityDetail
    func getFreeSearchCityDetail(countryID:String){
        let freeSearchURL = "base/native/locations/\(countryID)/freesearch"
        guard CommonClass.shared.isConnectedToInternet else{
            DispatchQueue.main.async {
                ShowToast.show(toatMessage:"No Internet connection.")
            }
            return
        }
       
        let freeSearchParameters:[String:AnyObject] = ["SearchText":"\(self.typpedString)" as AnyObject]
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:freeSearchURL, parameter:freeSearchParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let arraySuccess = successDate["location"] as? NSArray{
                self.arrayOfCountry = []
                for objCountry in arraySuccess{
                    if let jsonCountry = objCountry as? [String:Any]{
                        let countryDetail = CountyDetail.init(objJSON: jsonCountry)
                        self.arrayOfCountry.append(countryDetail)
                    }
                }
                self.arrayOfFilterCounty = self.arrayOfCountry
                DispatchQueue.main.async {
                    self.view.endEditing(true)
                    self.tableViewSearch.reloadData()
                }
            }else{
                
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
    @IBAction func buttonNoCountrySelector(sender:UIButton){
        self.noCountryDelegate?.selectNoCountrySelector()
    }
    @IBAction func buttonCancelSelector(sender:UIButton){
        //
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func buttonSelectSelector(sender:UIButton){
        if self.objSearchType == .Langauge{
             var languages:[ExperienceLangauge] = []
            if self.selectedLangauges.count > 0{
                if let arrayOfLanID = self.selectedLangauges.allObjects as? [String]{
                    for languageID in arrayOfLanID{
                        let filtered = self.arrayOfLanguage.filter { $0.langaugeID == "\(languageID)"}
                        if filtered.count > 0{
                            languages.append(filtered.first!)
                        }
                    }
                }
            }else{
                //self.dismiss(animated: true, completion: nil)
            }
            if self.isGuideLanguage{
                //Unwind to guide languages
                self.performSegue(withIdentifier: "unwindToSettingFromGuideLanguage", sender: languages)
            }else if self.isGuideRequestLanguage{
                //Unwind to guide request
                self.performSegue(withIdentifier: "unwindToSettingFromGuideRequest", sender: languages)
            }else if self.isBecomeGuideLanguage{
                //Unwind to become guide
                self.performSegue(withIdentifier: "unwindToBecomeGuideFromLangauge", sender: languages)
            }else if self.isFilterLanguage{
                //Unwind to filter
                self.performSegue(withIdentifier: "unwindToFilterFromLangauge", sender: languages)
            }else{
                //Unwind With Languages
                self.performSegue(withIdentifier: "unwindToExperienceFromLanguage", sender: languages)
            }
        }else if self.objSearchType == .Collection{
            var collections:[Collections] = []
            if self.selectedCollections.count > 0{
                if let arrayOfCollectionID = self.selectedCollections.allObjects as? [String]{
                    for colletionID in arrayOfCollectionID{
                        let filtered = self.arrayOfCollection.filter { $0.id == "\(colletionID)"}
                        if filtered.count > 0{
                            collections.append(filtered.first!)
                        }
                    }
                }
               }
            if self.isFilterCollection{
                //Unwind With Collection
                self.performSegue(withIdentifier: "unwindToFilterFromCollection", sender: collections)
            }else{
                //Unwind With Collection
                self.performSegue(withIdentifier: "unwindToAddExperienceCollection", sender: collections)
            }
            /*else{
                self.dismiss(animated: true, completion: nil)
            }*/
        }
    }
    @IBAction func buttonTrasperantSelector(sender:UIButton){
        self.view.endEditing(true)
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "unwindToAddExperienceFromLocation",let objCountry = sender as? CountyDetail{
            if let discoverViewController: AddExperienceViewController = segue.destination as? AddExperienceViewController{
                discoverViewController.selectedCountryDetail = objCountry
            }
        }else if segue.identifier == "unwindSearchToDiscover",let objCountry = sender as? CountyDetail{
            if let discoverViewController: DiscoverViewController = segue.destination as? DiscoverViewController{
                discoverViewController.countryDetail = objCountry
            }
            //
        } else if segue.identifier == "unwindToGuideRequestFromLocation",let objCountry = sender as? CountyDetail{
            if let addNewExperience:GuideSignUpViewController = segue.destination as? GuideSignUpViewController{
                addNewExperience.selectedCity = objCountry
            }
        } else if segue.identifier == "unwindToGuideRequestFromCounty",let objCountry = sender as? BecomeGuideCountry{
            if let addNewExperience:GuideSignUpViewController = segue.destination as? GuideSignUpViewController{
                addNewExperience.selectedCountry = objCountry
            }
        }else if segue.identifier == "unWindToAddExperienceCurrency",let objCurrency = sender as? Currency{
            if let addNewExperience:AddExperienceViewController = segue.destination as? AddExperienceViewController{
                addNewExperience.selectedCurrency = objCurrency
            }
        }else if segue.identifier == "unWindToAddExperienceFromEffort",let selectedEffort = sender as? String{
            if let addNewExperience:AddExperienceViewController = segue.destination as? AddExperienceViewController{
                addNewExperience.selectedEffort = selectedEffort
            }
        }else if segue.identifier == "unwindToSettingFromGuideLanguage",let selectedLang = sender as? [ExperienceLangauge]{
            if let addNewExperience:SettingViewController = segue.destination as? SettingViewController{
                addNewExperience.selectedLangauges = selectedLang
            }
        }else if segue.identifier == "unwindToSettingFromGuideRequest",let selectedLang = sender as? [ExperienceLangauge]{
            if let guideRequest:GuideSignUpViewController = segue.destination as? GuideSignUpViewController{
                guideRequest.selectedLangauges = selectedLang
            }
        }else if segue.identifier == "unwindToExperienceFromLanguage",let selectedLang = sender as? [ExperienceLangauge]{
            if let addNewExperience:AddExperienceViewController = segue.destination as? AddExperienceViewController{
                addNewExperience.selectedLangauges = selectedLang
            }
        }else if segue.identifier == "unwindToFilterFromCollection",let selectedCollection = sender as? [Collections]{
            if let filerViewController:FilterViewController = segue.destination as? FilterViewController{
                filerViewController.selectedCollection = selectedCollection
            }
        }else if segue.identifier == "unwindToAddExperienceCollection",let selectedCollection = sender as? [Collections]{
            if let addNewExperience:AddExperienceViewController = segue.destination as? AddExperienceViewController{
                addNewExperience.selectedCollection = selectedCollection
            }
        }else if segue.identifier == "unWindToScheduleFromOccurence",let selectedOccurence = sender as? String{
            if let scheduleViewController:ScheduleViewController = segue.destination as? ScheduleViewController{
                scheduleViewController.selectedOccurence = selectedOccurence
            }
        }else if segue.identifier == "unWindToScheduleFromWeakDay",let selectedWeekDay = sender as? String{
            if let scheduleViewController:ScheduleViewController = segue.destination as? ScheduleViewController{
                scheduleViewController.selectedWeekDay = selectedWeekDay
            }
        }else if segue.identifier == "unwindToBecomeGuideFromCounty",let objCountry = sender as? BecomeGuideCountry{
            if let addNewExperience:BecomeGuideViewController = segue.destination as? BecomeGuideViewController{
                addNewExperience.selectedCountry = objCountry
            }
        }
        else if segue.identifier == "unwindToBecomeGuideFromLangauge",let selectedLang = sender as? [ExperienceLangauge]{
            if let addNewExperience:BecomeGuideViewController = segue.destination as? BecomeGuideViewController{
                addNewExperience.selectedLangauges = selectedLang
            }
        }else if segue.identifier == "unwindToFilterFromLangauge",let selectedLang = sender as? [ExperienceLangauge]{
            if let addNewExperience:FilterViewController = segue.destination as? FilterViewController{
                addNewExperience.selectedLangauges = selectedLang
            }
        }else if segue.identifier == "unwindToBecomeGuideFromLocation",let objCountry = sender as? CountyDetail{
            if let addNewExperience:BecomeGuideViewController = segue.destination as? BecomeGuideViewController{
                addNewExperience.selectedCity = objCountry
            }
        } else if segue.identifier == "unwindToInquiry",let objCountry = sender as? BecomeGuideCountry{
            if let addNewExperience:InquiryViewController = segue.destination as? InquiryViewController{
                addNewExperience.selectedCountry = objCountry
            }
        } else if segue.identifier == "unwindToSignUpFromCounty",let objCountry = sender as? BecomeGuideCountry{
            if let addNewExperience:SignUpViewController = segue.destination as? SignUpViewController{
                addNewExperience.selectedCountry = objCountry
            }
        } else if segue.identifier == "unwindToSignUpFromLocation",let objCountry = sender as? CountyDetail{
            if let addNewExperience:SignUpViewController = segue.destination as? SignUpViewController{
                addNewExperience.selectedCity = objCountry
            }
        } else if segue.identifier == "unwindToCouponCodeListFromSearch",let objCountry = sender as? Coupon{
            //unwindToCouponCodeListFromSearch
            if let addCouponCodeList:CouponCodeListViewController = segue.destination as? CouponCodeListViewController{
                addCouponCodeList.strCouponCode = "\(objCountry.couponID)"
            }
        }
    }
}
extension SearchViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            //"noCityResponce.hint"
        switch self.objSearchType {
            case .Location:
                return self.arrayOfFilterLocation.count
            case .City:
                if self.typpedString.count > 0,self.arrayOfFilterCounty.count == 0{
               tableView.showMessageLabel(msg:Vocabulary.getWordFromKey(key:"noCityResponce.hint") , backgroundColor: .clear)
                }else{
                    tableView.removeMessageLabel()

                }
                return self.arrayOfFilterCounty.count
            case .Country:
                return self.arrayOfFilterGuideCountry.count
            case .Price:
                return 0
            case .Currency:
                return self.arrayOfFilterCurrency.count
            case .Effort:
                return self.arrayOfFilterEffort.count
            case .Langauge:
                return self.arrayOfFilterLangauge.count
            case .Collection:
                return self.arrayOfFilterCollection.count
            case .Occurence:
                return self.arrayOfFilterOccurance.count
            case .WeekDays:
                return self.arrayOfFilterWeekDays.count
            case .Coupon:
                return self.arrayOfFilterCoupon.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchTableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") else {
                return SearchTableViewCell(style: .default, reuseIdentifier: "SearchTableViewCell")
            }
            return cell as! SearchTableViewCell
        }()
        cell.lblSearchResult?.textColor = .black
        cell.lblSearchResult?.adjustsFontForContentSizeCategory = true
        //cell.lblSearchResult?.adjustsFontSizeToFitWidth = true
        let objFont = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)

        cell.backgroundColor = .clear
        switch self.objSearchType {
            case .Location:
                let objectCountryDetail = self.arrayOfFilterLocation[indexPath.row]
                cell.lblSearchResult?.text = "\(objectCountryDetail.defaultCity)" + " ," + " \(objectCountryDetail.countyName)"
                cell.lblSearchResult?.textColor = .black
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                break
            case .City:
                guard self.arrayOfFilterCounty.count > indexPath.row else {
                    return cell
                }
                let objectCountryDetail = self.arrayOfFilterCounty[indexPath.row]
                cell.lblSearchResult?.text = "\(objectCountryDetail.defaultCity)"
                
              
                if objectCountryDetail.isExperience{
                    cell.lblSearchResult.font = UIFont.boldSystemFont(ofSize: objFont.pointSize)
                }else{
                    cell.lblSearchResult.font = objFont//UIFont.init(name: "Avenir Medium", size: CommonClass.shared.getScaledFontSize())
                }
                break
            case .Country:
                guard self.arrayOfFilterGuideCountry.count > indexPath.row else {
                    return cell
                }
                let objGuideCountry = self.arrayOfFilterGuideCountry[indexPath.row]
                cell.lblSearchResult?.text = "\(objGuideCountry.countyName)"
                cell.lblSearchResult.font = objFont//UIFont.init(name: "Avenir Medium", size: CommonClass.shared.getScaledFontSize())
                break
            case .Price:
                break
            case .Currency:
                guard self.arrayOfFilterCurrency.count > indexPath.row else {
                    return cell
                }
                let objectCurrencyDetail = self.arrayOfFilterCurrency[indexPath.row]
                cell.lblSearchResult?.text = "\(objectCurrencyDetail.currencyText)"
                cell.lblSearchResult.font = objFont//UIFont.init(name: "Avenir Medium", size: CommonClass.shared.getScaledFontSize())

                break
            case .Effort:
                guard self.arrayOfFilterEffort.count > indexPath.row else{
                    return cell
                }
                cell.lblSearchResult.text = "\(self.arrayOfFilterEffort[indexPath.row])"
                cell.lblSearchResult.font = objFont//UIFont.init(name: "Avenir Medium", size: CommonClass.shared.getScaledFontSize())

                break
            case .Langauge:
                guard self.arrayOfFilterLangauge.count > indexPath.row else{
                    return cell
                }
                let objectLangauge = self.arrayOfFilterLangauge[indexPath.row]
                cell.lblSearchResult?.text = "\(objectLangauge.langaugeName)"
                if self.selectedLangauges.contains(objectLangauge.langaugeID){
//                    cell.lblSearchResult?.textColor = UIColor.white
//                    cell.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                    cell.imgSelected.isHidden = false
                }else{
                    cell.imgSelected.isHidden = true
//                    cell.lblSearchResult?.textColor = .black
//                    cell.backgroundColor = .clear
                }
                cell.lblSearchResult.font = objFont//UIFont.init(name: "Avenir Medium", size: CommonClass.shared.getScaledFontSize())

                return cell
            
            case .Collection:
                guard self.arrayOfFilterCollection.count > indexPath.row else{
                    return cell
                }
                let objectCollection = self.arrayOfFilterCollection[indexPath.row]
                cell.lblSearchResult?.text = "\(objectCollection.title)"
                if self.selectedCollections.contains(objectCollection.id){
                    cell.imgSelected.isHidden = false
//                    cell.lblSearchResult?.textColor = UIColor.white
//                    cell.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                }else{
                    cell.imgSelected.isHidden = true
//                    cell.lblSearchResult?.textColor = .black
//                    cell.backgroundColor = .clear
                }
                cell.lblSearchResult.font = objFont//UIFont.init(name: "Avenir Medium", size: CommonClass.shared.getScaledFontSize())

                break
            case .Occurence:
                guard self.arrayOfFilterOccurance.count > indexPath.row else{
                    return cell
                }
                cell.lblSearchResult.text = "\(self.arrayOfFilterOccurance[indexPath.row])"
                cell.lblSearchResult.font = objFont//UIFont.init(name: "Avenir Medium", size: CommonClass.shared.getScaledFontSize())

                break
            case .WeekDays:
                guard self.arrayOfFilterWeekDays.count > indexPath.row else{
                    return cell
                }
                cell.lblSearchResult.text = "\(self.arrayOfFilterWeekDays[indexPath.row])"
                cell.lblSearchResult.font = objFont//UIFont.init(name: "Avenir Medium", size: CommonClass.shared.getScaledFontSize())

                break
            case .Coupon:
                guard self.arrayOfFilterCoupon.count > indexPath.row else {
                    return cell
                }
                let objectCouponDetail = self.arrayOfFilterCoupon[indexPath.row]
                var couponCurrency = ""
                if objectCouponDetail.currency.count > 0 {
                    couponCurrency = " (\(objectCouponDetail.currency))"
                }
                cell.lblSearchResult?.text = "\(objectCouponDetail.couponID)"+couponCurrency
                //cell.lblSearchResult.font = objFont//UIFont.init(name: "Avenir Medium", size: CommonClass.shared.getScaledFontSize())
                cell.lblSearchResult.font = UIFont.boldSystemFont(ofSize: objFont.pointSize)
                break
        }
//        cell.lblSearchResult.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
//        cell.lblSearchResult.adjustsFontForContentSizeCategory = true
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.objSearchType == .City{
            return 40.0
        }else{
            return heightOfTableViewCell
        }
    }
    func selectedLocation( _ cityId: String, _ cityName: String, _ countryName: String) {
        let currentUser: User? = User.getUserFromUserDefault()
        let userId: String = (currentUser?.userID)!
        let urlBookingDetail = "users/\(userId)/native/location/\(cityId)/userlocation"
        
        APIRequestClient.shared.sendRequest(requestType: .PUT, queryString:urlBookingDetail, parameter: [:], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let _ = success["data"] as? [String:Any] {
                // Location Change Suucess Alert
                currentUser!.userLocationID = cityId
                currentUser!.userCity = cityName
                currentUser!.userCountry = countryName
                currentUser!.userCurrentCity = cityName
                currentUser!.userCurrentCountry = countryName
                currentUser!.setUserDataToUserDefault()
                //Perform Segue
                self.performSegue(withIdentifier: "unwindToSettingFromSearchLocation", sender: nil)
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        switch self.objSearchType {
            case .Location:
                guard self.arrayOfFilterLocation.count > indexPath.row else {
                    return
                }
                let objLocationDetail = self.arrayOfFilterLocation[indexPath.row]
                self.performSegue(withIdentifier: "unwindToAddExperienceFromLocation", sender: objLocationDetail)
                break
            case .City:
                guard self.arrayOfFilterCounty.count > indexPath.row else {
                    return
                }
                let objCountryDetail = self.arrayOfFilterCounty[indexPath.row]
                if self.isChooseCity{
                    let cityId = objCountryDetail.locationID
                    self.selectedLocation(cityId, objCountryDetail.defaultCity, objCountryDetail.countyName)  // Location Change Request API
                }else if self.isGuideRequestLocation{
                    self.performSegue(withIdentifier:"unwindToGuideRequestFromLocation", sender: objCountryDetail)
                }else if self.isBecomeGuideLocation{
                    self.performSegue(withIdentifier:"unwindToBecomeGuideFromLocation", sender: objCountryDetail)
                }else if self.isSignUpLocation{
                    self.performSegue(withIdentifier:"unwindToSignUpFromLocation", sender: objCountryDetail)
                }
                else{
                    self.performSegue(withIdentifier:"unwindSearchToDiscover", sender: objCountryDetail)
                }
                
                break
            case .Country:
                guard self.arrayOfFilterGuideCountry.count > indexPath.row else {
                    return
                }
                let objGuideCountry = self.arrayOfFilterGuideCountry[indexPath.row]
                if self.isBecomeGuideCountry {
                    self.performSegue(withIdentifier:"unwindToBecomeGuideFromCounty", sender: objGuideCountry)
                } else if self.isInquiryCountry {
                    self.performSegue(withIdentifier:"unwindToInquiry", sender: objGuideCountry)
                } else if self.isSignUpCountry {
                    self.performSegue(withIdentifier:"unwindToSignUpFromCounty", sender: objGuideCountry)
                }
                else {
                self.performSegue(withIdentifier:"unwindToGuideRequestFromCounty", sender: objGuideCountry)
                }
            break
            case .Price:
                break
            case .Currency:
                guard self.arrayOfFilterCurrency.count > indexPath.row else {
                    return
                }
                let objCurrencyDetail = self.arrayOfFilterCurrency[indexPath.row]
                self.performSegue(withIdentifier:"unWindToAddExperienceCurrency", sender: objCurrencyDetail)

                break
            case .Effort:
                guard self.arrayOfFilterEffort.count > indexPath.row else{
                    return
                }
                let objSelectedEffort = self.araryOfEffort[indexPath.row]
                self.performSegue(withIdentifier:"unWindToAddExperienceFromEffort", sender: objSelectedEffort)

                break
            case .Langauge:
                guard self.arrayOfFilterLangauge.count > indexPath.row else {
                    return
                }
                let objectLangauge = self.arrayOfFilterLangauge[indexPath.row]
                if self.selectedLangauges.contains("\(objectLangauge.langaugeID)"){
                    self.selectedLangauges.remove("\(objectLangauge.langaugeID)")
                }else{
                    self.selectedLangauges.add("\(objectLangauge.langaugeID)")
                }
                DispatchQueue.main.async {
                    self.tableViewSearch.reloadData()
                }
                
                break
            case .Collection:
                guard self.arrayOfFilterCollection.count > indexPath.row else {
                    return
                }
                let objectCollection = self.arrayOfFilterCollection[indexPath.row]
                if self.selectedCollections.contains("\(objectCollection.id)"){
                    self.selectedCollections.remove("\(objectCollection.id)")
                }else{
                    self.selectedCollections.add("\(objectCollection.id)")
                }
                DispatchQueue.main.async {
                    self.tableViewSearch.reloadData()
                }
                break
            case .Occurence:
                guard self.arrayOfFilterOccurance.count > indexPath.row else{
                    return
                }
                let objSelectedOccurence = self.arrayOfFilterOccurance[indexPath.row]
                self.performSegue(withIdentifier:"unWindToScheduleFromOccurence", sender: objSelectedOccurence)
                break
            case .WeekDays:
                guard self.arrayOfFilterWeekDays.count > indexPath.row else{
                    return
                }
                let objSelectedWeakday = self.arrayOfFilterWeekDays[indexPath.row]
                self.performSegue(withIdentifier:"unWindToScheduleFromWeakDay", sender: objSelectedWeakday)
                break
            case .Coupon:
                guard self.arrayOfFilterCoupon.count > indexPath.row else{
                    return
                }
                let objSelectedCoupon = self.arrayOfFilterCoupon[indexPath.row]
                self.performSegue(withIdentifier:"unwindToCouponCodeListFromSearch", sender: objSelectedCoupon)
                break
            }
        
    }
}
extension SearchViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard !self.typpedString.isContainWhiteSpace() else{
            return false
        }
        switch self.objSearchType {
            case .Location:
                guard self.typpedString.count > 0 else {
                    self.arrayOfFilterLocation = self.arrayOfLocation
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                    return true
                }
                let filtered = self.arrayOfLocation.filter { $0.defaultCity.localizedCaseInsensitiveContains("\(typpedString)") }
                self.arrayOfFilterLocation = filtered
                break
            case .City:
                guard self.typpedString.count > 0 else {
                    if self.objSearchType == .City,self.isCityFreeSearch{
                        self.getFreeSearchCityDetail(countryID:self.countryID)
                    }else{
                        self.arrayOfFilterCounty = self.arrayOfCountry
                        DispatchQueue.main.async {
                            self.tableViewSearch.reloadData()
                        }
                    }
                    return true
                }
                if !self.isCityFreeSearch{
                    let filtered = self.arrayOfCountry.filter { $0.defaultCity.localizedCaseInsensitiveContains("\(typpedString)") }
                    self.arrayOfFilterCounty = filtered
                }
                break
            case .Country:
                guard self.typpedString.count > 0 else {
                    self.arrayOfFilterGuideCountry = self.arrayOfGuideCountry
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                    return true
                }
                let filtered = self.arrayOfGuideCountry.filter { $0.countyName.localizedCaseInsensitiveContains("\(typpedString)") }
                self.arrayOfFilterGuideCountry = filtered
                break
            case .Price:
                break
            case .Currency:
                guard self.typpedString.count > 0 else {
                    self.arrayOfFilterCurrency = self.arrayOfCurrency
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                    return true
                }
                let filtered = self.arrayOfCurrency.filter { $0.currencyText.localizedCaseInsensitiveContains("\(typpedString)") }
                self.arrayOfFilterCurrency = filtered
                break
            case .Effort:
                guard self.typpedString.count > 0 else{
                    self.arrayOfFilterEffort = self.araryOfEffort
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                    return true
                }
                let filtered = self.araryOfEffort.filter { $0.localizedCaseInsensitiveContains("\(typpedString)") }
                self.arrayOfFilterEffort = filtered
                break
            case .Langauge:
                guard self.typpedString.count > 0 else {
                    self.arrayOfFilterLangauge = self.arrayOfLanguage
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                    return true
                }
                let filtered = self.arrayOfLanguage.filter { $0.langaugeName.localizedCaseInsensitiveContains("\(typpedString)") }
                self.arrayOfFilterLangauge = filtered
                break
            case .Collection:
                guard self.typpedString.count > 0 else {
                    self.arrayOfFilterCollection = self.arrayOfCollection
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                    return true
                }
                let filtered = self.arrayOfCollection.filter { $0.title.localizedCaseInsensitiveContains("\(typpedString)") }
                self.arrayOfFilterCollection = filtered
                break
            case .Occurence:
                guard self.typpedString.count > 0 else{
                    self.arrayOfFilterOccurance = self.arrayOfOccurance
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                    return true
                }
                let filtered = self.arrayOfOccurance.filter { $0.localizedCaseInsensitiveContains("\(typpedString)") }
                self.arrayOfFilterOccurance = filtered
                break
            case .WeekDays:
                guard self.typpedString.count > 0 else{
                    self.arrayOfFilterWeekDays = self.arrayOfWeekDays
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                    return true
                }
                let filtered = self.arrayOfWeekDays.filter { $0.localizedCaseInsensitiveContains("\(typpedString)") }
                self.arrayOfFilterWeekDays = filtered
                break
            case .Coupon:
                guard self.typpedString.count > 0 else {
                    self.arrayOfFilterCoupon = self.arrayOfCoupon
                    DispatchQueue.main.async {
                        self.tableViewSearch.reloadData()
                    }
                    return true
                }
                let filtered = self.arrayOfCoupon.filter { $0.couponID.localizedCaseInsensitiveContains("\(typpedString)") }
                self.arrayOfFilterCoupon = filtered
                
                break
        }
        DispatchQueue.main.async {
            self.tableViewSearch.reloadData()
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch self.objSearchType {
            case .Location:
                self.arrayOfFilterLocation = self.arrayOfLocation
            break
            case .City:
                if self.isCityFreeSearch{
                    self.getFreeSearchCityDetail(countryID: self.countryID)
                }else{
                    self.arrayOfFilterCounty = self.arrayOfCountry
                }
            break
            case .Country:
                self.arrayOfFilterGuideCountry = self.arrayOfGuideCountry
            break
            case .Price:
            break
            case .Currency:
                self.arrayOfFilterCurrency = self.arrayOfCurrency
            break
            case .Effort:
                self.arrayOfFilterEffort = self.araryOfEffort
            break
            case .Langauge:
                self.arrayOfFilterLangauge = self.arrayOfLanguage
                break
            case .Collection:
                self.arrayOfFilterCollection = self.arrayOfCollection
                break
            case .Occurence:
                self.arrayOfFilterOccurance = self.arrayOfOccurance
            break
            case .WeekDays:
                self.arrayOfFilterWeekDays = self.arrayOfWeekDays
            break
            case .Coupon:
                self.arrayOfFilterCoupon = self.arrayOfCoupon
            break
        }
        defer{
            DispatchQueue.main.async {
                self.tableViewSearch.reloadData()
            }
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.objSearchType == .City,self.isCityFreeSearch{
            self.getFreeSearchCityDetail(countryID:"0")
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
}
extension UITextField {
    @IBInspectable var placeholderUpdateColor: UIColor {
        get {
            guard let currentAttributedPlaceholderColor = attributedPlaceholder?.attribute(NSAttributedStringKey.foregroundColor, at: 0, effectiveRange: nil) as? UIColor else { return UIColor.clear }
            return currentAttributedPlaceholderColor
        }
        set {
            guard let currentAttributedString = attributedPlaceholder else { return }
            let attributes = [NSAttributedStringKey.foregroundColor : newValue]
            
            attributedPlaceholder = NSAttributedString(string: currentAttributedString.string, attributes: attributes)
        }
    }
}
