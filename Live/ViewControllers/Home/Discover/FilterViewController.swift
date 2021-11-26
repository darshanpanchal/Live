//
//  FilterViewController.swift
//  Live
//
//  Created by ITPATH on 4/16/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
protocol FilterDelegate {
    func buttonAppply()
}
class FilterViewController: UIViewController {

    fileprivate var kInstant:String = "IsInstant"
    fileprivate var kPrice:String = "MaxPrice"
    fileprivate var kWheelChair:String = "OnlyAccessible"
    fileprivate var kPetFriendly:String = "OnlyPetFriendly"
    fileprivate var kFreeForChildern:String = "OnlyFreeChildren"
    fileprivate var kFreeForElderly:String = "OnlyFreeElderly"
    fileprivate var kFreeSearchString = "FreeTextSearch"
    fileprivate var kLanguages:String = "Languages"
    fileprivate let kExperienceCollectionId = "CollectionIds"
    
    @IBOutlet weak var findBestExperienceLbl: UILabel!
    @IBOutlet weak var upToHowMuchLbl: UILabel!
    @IBOutlet weak var onlyInstantLbl: UILabel!
    @IBOutlet weak var wheelChairLbl: UILabel!
    @IBOutlet weak var freeChildrenyLbl: UILabel!
    @IBOutlet weak var petFriendlyLbl: UILabel!
    @IBOutlet weak var navTitleLbl: UILabel!
    @IBOutlet var buttonCancel:UIButton!
    @IBOutlet var buttonApply:RoundButton!
    @IBOutlet var objSlider:UISlider!
    @IBOutlet var objSwitchOnlyInstant:UISwitch!
    @IBOutlet var objSwitchWheelChair:UISwitch!
    @IBOutlet var objSwitchPetFriendly:UISwitch!
    @IBOutlet var objSwitchFreeforChildern:UISwitch!
    @IBOutlet var objSwitchFreeforelderly:UISwitch!
    @IBOutlet var buttonClear:UIButton!
    @IBOutlet var txtLanguage:TweeActiveTextField!
    @IBOutlet var txtSearch:UITextField!
    @IBOutlet var textOfSearch:UITextView!
    @IBOutlet var textOfLanguage:UITextView!
    @IBOutlet var txtExperienceCollection:UITextView!
    @IBOutlet var txtCollectionOfExperience:TweeActiveTextField!
    @IBOutlet var objScrollView:UIScrollView!
    @IBOutlet var lblMaximumHint:UILabel!
    @IBOutlet var lblPrice:UILabel!
    @IBOutlet var searchContainerView:UIView!
    var filterValue:[String:Any]?
    var instant:Bool = false
    var isOnlyInstant:Bool{
        get{
            return instant
        }
        set{
            self.instant = newValue
            //UpdateInstant
            if let _ = self.filterValue{
                self.filterValue![kInstant] = newValue
            }
        }
    }
    var delegate:FilterDelegate?
    var wheelChair:Bool = false
    var isWheelChair:Bool{
        get{
            return wheelChair
        }
        set{
            self.wheelChair = newValue
            //UpdateWheelChair
            if let _ = self.filterValue{
                self.filterValue![kWheelChair] = newValue
            }
            
        }
    }
    var petFriendly:Bool = false
    var isPetFriendly:Bool{
        get{
           return petFriendly
        }
        set{
            self.petFriendly = newValue
            //UpdatePetFriendly
            if let _ = self.filterValue{
                self.filterValue![kPetFriendly] = newValue
            }
        }
    }
    var freeforchildern:Bool = false
    var isFreeforChildern:Bool{
        get{
            return freeforchildern
        }
        set{
            self.freeforchildern = newValue
            //UpdateFreeforchildern
            if let _ = self.filterValue{
                self.filterValue![kFreeForChildern] = newValue
            }
        }
    }
    var freeforelderly:Bool = false
    var isFreeforElderly:Bool{
        get{
            return freeforelderly
        }
        set{
            self.freeforelderly = newValue
            //UpdateFreeforelderly
            if let _ = self.filterValue{
                self.filterValue![kFreeForElderly] = newValue
            }
        }
    }
    var arrayOfLanguage:[ExperienceLangauge] = []
    var selectedLangauges:[ExperienceLangauge] = []
    var selectedCollection:[Collections] = []
    var arrayOfExploreCollection:[Collections] = []
    var currentPrice:String = "0" //maximum price 1000 default
    var countryDetail:CountyDetail?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonCancel.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), for: .normal)
        self.buttonCancel.imageView?.tintColor = UIColor.black
        self.txtLanguage.tweePlaceholder = Vocabulary.getWordFromKey(key: "language")
        self.txtLanguage.textColor = UIColor.black//UIColor.black.withAlphaComponent(0.8)
        self.txtLanguage.placeholderColor = UIColor.black//UIColor.darkGray.withAlphaComponent(0.8)
        //self.txtLanguage.delegate = self
        
        //self.txtSearch.tweePlaceholder = Vocabulary.getWordFromKey(key: "SearchHint")
        self.txtSearch.placeholder = Vocabulary.getWordFromKey(key:"SearchHint")
        self.txtSearch.textColor = UIColor.black//UIColor.black.withAlphaComponent(0.8)
//        self.txtSearch.placeholderColor = UIColor.black//UIColor.darkGray.withAlphaComponent(0.8)
        //self.txtSearch.delegate = self
        self.txtSearch.delegate = self
        self.textOfSearch.delegate = self
        self.textOfLanguage.delegate = self
        self.txtExperienceCollection.delegate = self
        //self.txtCollectionOfExperience.delegate = self
        if let _ = self.countryDetail{
            self.getExploreCollection(locationID: self.countryDetail!.locationID)
        }
        self.getLanguages()
        self.navTitleLbl.text = Vocabulary.getWordFromKey(key: "filter")
        self.onlyInstantLbl.text = Vocabulary.getWordFromKey(key: "onlyInstant")
        self.wheelChairLbl.text = Vocabulary.getWordFromKey(key: "WheelchairAccessible")
        self.petFriendlyLbl.text = Vocabulary.getWordFromKey(key: "PetFriendly")
        self.freeChildrenyLbl.text = Vocabulary.getWordFromKey(key: "FreeChildren")
        self.buttonApply.setTitle("\(Vocabulary.getWordFromKey(key:"apply")) \(Vocabulary.getWordFromKey(key:"filter"))", for: .normal)
        self.buttonClear.setTitle(Vocabulary.getWordFromKey(key:"Clear"), for: .normal)
        self.findBestExperienceLbl.text = Vocabulary.getWordFromKey(key: "findBestExperience")
        self.findBestExperienceLbl.isHidden = true
        self.upToHowMuchLbl.text = Vocabulary.getWordFromKey(key: "UpToHowMuch?")
        self.lblMaximumHint.text = Vocabulary.getWordFromKey(key: "maxfilter.hint")
        // Do any additional setup after loading the view.
        //self.filterValue = [kInstant:false,kPrice:"1000",kWheelChair:false,kPetFriendly:false,kFreeForChildern:false,kFreeForElderly:false]
        //Configure FilterView
        //self.configureFilterView()
        self.buttonApply.setBackgroundColor(color: UIColor.lightGray.withAlphaComponent(0.5), forState: .highlighted)
        
        
        self.searchContainerView.layer.cornerRadius = 6.0
        self.searchContainerView.clipsToBounds = true
        self.searchContainerView.layer.borderWidth = 1.5
        self.searchContainerView.layer.borderColor = UIColor.black.cgColor
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            //self.addDynamicFont()
            self.txtCollectionOfExperience.tweePlaceholder = "\(Vocabulary.getWordFromKey(key: "Select")) \(Vocabulary.getWordFromKey(key: "collections") )"//
            self.txtCollectionOfExperience.maximumPlaceHolder = "\(Vocabulary.getWordFromKey(key: "Select")) \(Vocabulary.getWordFromKey(key: "collections") )"
            self.txtCollectionOfExperience.minimumPlaceHolder = Vocabulary.getWordFromKey(key: "collections").firstUppercased
        }
    }
    func addDynamicFont(){
        self.navTitleLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.navTitleLbl.adjustsFontForContentSizeCategory = true
        self.navTitleLbl.adjustsFontSizeToFitWidth = true
        
        self.buttonClear.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonClear.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonClear.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.buttonApply.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonApply.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonApply.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.onlyInstantLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.onlyInstantLbl.adjustsFontForContentSizeCategory = true
        self.onlyInstantLbl.adjustsFontSizeToFitWidth = true
        
        self.wheelChairLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.wheelChairLbl.adjustsFontForContentSizeCategory = true
        self.wheelChairLbl.adjustsFontSizeToFitWidth = true
        
        self.petFriendlyLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.petFriendlyLbl.adjustsFontForContentSizeCategory = true
        self.petFriendlyLbl.adjustsFontSizeToFitWidth = true
        
        self.freeChildrenyLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.freeChildrenyLbl.adjustsFontForContentSizeCategory = true
        self.freeChildrenyLbl.adjustsFontSizeToFitWidth = true
        
        self.findBestExperienceLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.findBestExperienceLbl.adjustsFontForContentSizeCategory = true
        self.findBestExperienceLbl.adjustsFontSizeToFitWidth = true
        
        self.upToHowMuchLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.upToHowMuchLbl.adjustsFontForContentSizeCategory = true
        self.upToHowMuchLbl.adjustsFontSizeToFitWidth = true
        
        self.lblPrice.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblPrice.adjustsFontForContentSizeCategory = true
        self.lblPrice.adjustsFontSizeToFitWidth = true
        
//        self.txtSearch.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1).pointSize
        self.txtSearch.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtSearch.adjustsFontForContentSizeCategory = true
        
//        self.txtLanguage.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1).pointSize
        self.txtLanguage.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtLanguage.adjustsFontForContentSizeCategory = true
        
        self.txtSearch.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtSearch.adjustsFontForContentSizeCategory = true
        
        self.textOfLanguage.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.textOfLanguage.adjustsFontForContentSizeCategory = true

//        self.txtCollectionOfExperience.originalPlaceholderFontSize = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1).pointSize
        self.txtExperienceCollection.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.txtCollectionOfExperience.adjustsFontForContentSizeCategory = true
        
        
        //self.txtCollectionOfExperience.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        //self.txtCollectionOfExperience.adjustsFontForContentSizeCategory = true
        //self.txtExperienceCollection.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
    func configureFilterView(){
        self.objSwitchOnlyInstant.tag = 1
        self.objSwitchWheelChair.tag = 2
        self.objSwitchPetFriendly.tag = 3
        self.objSwitchFreeforChildern.tag = 4
        self.objSwitchFreeforelderly.tag = 5
        if let _ = filterValue{
           self.updateFilter()
        }
    }
    func updateFilter(){
        if let instant = self.filterValue![kInstant] as? Bool{
            self.isOnlyInstant = instant
            self.objSwitchOnlyInstant.isOn = instant
        }
        if let wheelchair = self.filterValue![kWheelChair] as? Bool{
            self.isWheelChair = wheelchair
            self.objSwitchWheelChair.isOn = wheelchair
        }
        if let petfriendly = self.filterValue![kPetFriendly] as? Bool{
            self.isPetFriendly = petfriendly
            self.objSwitchPetFriendly.isOn = petfriendly
        }
        if let freeforchildren  = self.filterValue![kFreeForChildern] as? Bool{
            self.isFreeforChildern = freeforchildren
            self.objSwitchFreeforChildern.isOn = freeforchildren
        }
        if let freeforelder = self.filterValue![kFreeForElderly] as? Bool{
            self.isFreeforElderly = freeforelder
            self.objSwitchFreeforelderly.isOn = freeforelder
        }
        if let price = self.filterValue![kPrice] as? String{
            self.lblPrice.text = "\(price)"
            self.objSlider.setValue(Float(price)!, animated: true)
        }
        if let searchText = self.filterValue![kFreeSearchString] as? String{
            DispatchQueue.main.async {
                if searchText.count > 0{
                    //self.txtSearch.minimizePlaceholder()
                    self.textOfSearch.text = "\(searchText)"
                    self.txtSearch.text = "\(searchText)"
                }else{
                    guard self.textOfSearch.text.count > 0 else {
                        return
                    }
                    self.txtSearch.text = ""
                    self.textOfSearch.text = ""
                    //self.txtSearch.maximizePlaceholder()
                    self.txtSearch.resignFirstResponder()
                    self.textOfSearch.resignFirstResponder()
                }
            }
        }
        if let selectedLanguage:[String] = self.filterValue![kLanguages] as? [String]{
            if selectedLanguage.count > 0{
                self.selectedLangauges = []
                for languageID in selectedLanguage{
                    let filtered = self.arrayOfLanguage.filter { $0.langaugeID == "\(languageID)"}
                    if filtered.count > 0{
                        self.selectedLangauges.append(filtered.first!)
                    }
                }
                self.configureSelectedLanguage()
            }else{
                self.selectedLangauges = []
                DispatchQueue.main.async {
                    guard self.textOfLanguage.text.count > 0 else {
                        return
                    }
                    self.textOfLanguage.text = ""
                    self.txtLanguage.maximizePlaceholder()
                    //self.textOfLanguage.resignFirstResponder()
                    //self.txtLanguage.resignFirstResponder()
                }
            }
        }
        if let objselectedCollection:[String] = self.filterValue![kExperienceCollectionId] as? [String]{
            if objselectedCollection.count > 0{
                self.selectedCollection = []
                for collectionID in objselectedCollection{
                    let filtered = self.arrayOfExploreCollection.filter{ $0.id == "\(collectionID)"}
                    if filtered.count > 0{
                        self.selectedCollection.append(filtered.first!)
                    }
                }
                self.configureSelectedCollections()
            }else{
                self.selectedCollection = []
                self.filterValue![kExperienceCollectionId] = []
                //self.addExperienceParameters[kExperienceCollectionId]=[]
                if self.txtExperienceCollection.text.count > 0{
                    self.txtExperienceCollection.text = ""
                    self.txtCollectionOfExperience.maximizePlaceholder()
                }
            }
        }
//        DispatchQueue.main.async {
//            self.view.endEditing(true)
//        }
    }
    func updateSwitchValue(objSwitch:UISwitch){
        if objSwitch.tag == 1{ //Instant
            if objSwitch.isOn,!self.isOnlyInstant{
                self.isOnlyInstant = true
            }else{
                self.isOnlyInstant = false
            }
        }else if objSwitch.tag == 2{ //WheelChair
            if objSwitch.isOn,!self.isWheelChair{
                self.isWheelChair = true
            }else{
                self.isWheelChair = false
            }
        }else if objSwitch.tag == 3{ //PetFriendly
            if objSwitch.isOn,!self.isPetFriendly{
                self.isPetFriendly = true
            }else{
                self.isPetFriendly = false
            }
        }else if objSwitch.tag == 4{ //Freeforchildren
            if objSwitch.isOn,!self.isFreeforChildern{
                self.isFreeforChildern = true
            }else{
                self.isFreeforChildern = false
            }
        }else if objSwitch.tag == 5{ //Freeforelderly
            if objSwitch.isOn,!self.isFreeforElderly{
                self.isFreeforElderly = true
            }else{
                self.isFreeforElderly = false
            }
        }else{
            
        }
    }
    func configureSelectedLanguage(){
        if selectedLangauges.count > 0{
            var arrayLanID:[String] = []
            var arrayLanName:[String] = []
            for objLan in selectedLangauges{
                arrayLanID.append("\(objLan.langaugeID)")
                arrayLanName.append("\(objLan.langaugeName)")
            }
            defer{
                self.filterValue![kLanguages] = arrayLanID
                self.textOfLanguage.text = "\(arrayLanName.joined(separator: ", "))"
            }
            self.txtLanguage.minimizePlaceholder()
        }else{
            DispatchQueue.main.async {
                self.textOfLanguage.text = ""
                self.txtLanguage.maximizePlaceholder()
            }
        }
        defer{
            self.sizeFooterToFit()
        }
    }
    func configureSelectedCollections(){
        if selectedCollection.count > 0{
            var arrayCollectionID:[String] = []
            var arrayCollectionName:[String] = []
            for objCollection in selectedCollection{
                arrayCollectionID.append("\(objCollection.id)")
                arrayCollectionName.append("\(objCollection.title)")
            }
            defer{
                self.filterValue![kExperienceCollectionId] = arrayCollectionID
                //self.addExperienceParameters[kExperienceCollectionId] = arrayCollectionID
                self.txtExperienceCollection.text = "\(arrayCollectionName.joined(separator: ", "))"
                //self.validTextField(textField: txtCollectionOfExperience)
            }
            self.txtCollectionOfExperience.minimizePlaceholder()
        }else{
            self.filterValue![kExperienceCollectionId] = []
            //self.addExperienceParameters[kExperienceCollectionId]=[]
            if self.txtExperienceCollection.text.count > 0{
                self.txtExperienceCollection.text = ""
                self.txtCollectionOfExperience.maximizePlaceholder()
            }
        }
        defer{
            self.sizeFooterToFit()
        }
    }
    func sizeFooterToFit() {
        var contentRect = CGRect.zero
        
        for view in objScrollView.subviews {
            contentRect = contentRect.union(view.frame)
        }
       // objScrollView.contentSize = contentRect.size
    }
    // MARK: - API Request Methods
    func getLanguages(){ //Get Languages
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:kAllLanguage, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let arayOfLanguage = successData["Language"] as? [[String:Any]]{
                self.arrayOfLanguage = []
                for objLangauge in arayOfLanguage{
                    if let languageID = objLangauge["id"],let langaugeName = objLangauge["name"],let langaugeCode = objLangauge["code"]{
                        
                        let langauge = ExperienceLangauge.init(langaugeID: "\(languageID)", langaugeName:"\(langaugeName)", langaugeCode: "\(langaugeCode)")
                        self.arrayOfLanguage.append(langauge)
                        //Configure Selected Language
                    }
                }
                DispatchQueue.main.async {
                    self.configureFilterView()
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
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
        defer{
        }
    }
    func getExploreCollection(locationID:String){
        let requestURL = "experience/native/\(locationID)/collection"
        let expoParameter = ["FreeTextSearch": ""]
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:requestURL, parameter:expoParameter as [String : AnyObject], isHudeShow: false, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let array = successDate["collections"] as? [[String:Any]]{
                self.arrayOfExploreCollection = []
                for object in array{
                    let objectExperience = Collections.init(collectionDetail: object)
                    self.arrayOfExploreCollection.append(objectExperience)
                }
                if self.arrayOfExploreCollection.count > 0{
                    DispatchQueue.main.async {
                        //self.collectionViewContainer.isHidden = false
                        //self.bottomConstraintOfLocation.constant = 20
                    }
                    DispatchQueue.main.async {
                        // self.presentCollectionPicker()
                    }
                }else{
                    DispatchQueue.main.async {
                        //self.collectionViewContainer.isHidden = true
                        //self.bottomConstraintOfLocation.constant = -50
                        guard self.txtExperienceCollection.text.count > 0 else{
                            return
                        }
                        self.txtExperienceCollection.text = ""
                        self.txtCollectionOfExperience.maximizePlaceholder()
                    }
                }
                DispatchQueue.main.async {
                    self.sizeFooterToFit()
                }
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
    @IBAction func buttonSelectorApplyFilter(){
        self.delegate?.buttonAppply()
    }
    @IBAction func buttonCancelSelector(sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func buttonClearSelector(sender:UIButton){
        self.filterValue = [kInstant:false,kPrice:"0",kWheelChair:false,kPetFriendly:false,kFreeForChildern:false,kFreeForElderly:false,kLanguages:[],kFreeSearchString:"",kExperienceCollectionId:[]]
        self.updateFilter()
    }
    @IBAction func buttonSwitchSelector(sender:UISwitch){
        self.updateSwitchValue(objSwitch: sender)
    }
    @IBAction func sliderSelector(sender:UISlider){
        if let _ = self.filterValue{
            self.filterValue![kPrice] = "\(Int.init(sender.value))"
        }
        self.lblPrice.text = "\(Int.init(sender.value))"
    }
    
    @IBAction func unwindToFilterFromLangauge(segue:UIStoryboardSegue){
        DispatchQueue.main.async {
            self.configureSelectedLanguage()
        }
    }
    @IBAction func unwindToFilterFromCollection(segue:UIStoryboardSegue){
        
        DispatchQueue.main.async {
            self.configureSelectedCollections()
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    func presentLangaugePicker(){
        if let langaugePicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
            langaugePicker.modalPresentationStyle = .overFullScreen
            langaugePicker.objSearchType = .Langauge
            langaugePicker.arrayOfLanguage = self.arrayOfLanguage
            if self.selectedLangauges.count > 0{
                var arrayLanID:[String] = []
                for objLan in self.selectedLangauges{
                    arrayLanID.append("\(objLan.langaugeID)")
                }
                langaugePicker.selectedLangauges.addObjects(from: arrayLanID)
            }
            langaugePicker.isFilterLanguage = true
            self.view.endEditing(true)
            self.present(langaugePicker, animated: true, completion: nil)
        }
    }
    func presentCollectionPicker(){
        guard self.arrayOfExploreCollection.count > 0 else {
            DispatchQueue.main.async {
                ShowToast.show(toatMessage:"No Collections.")
            }
            return
        }
        if let collectionPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
            collectionPicker.modalPresentationStyle = .overFullScreen
            collectionPicker.objSearchType = .Collection
            collectionPicker.arrayOfCollection = self.arrayOfExploreCollection
            if selectedCollection.count > 0{
                var arrayCollectionID:[String] = []
                for objCollection in selectedCollection{
                    arrayCollectionID.append("\(objCollection.id)")
                }
                collectionPicker.selectedCollections.addObjects(from: arrayCollectionID)
            }
            collectionPicker.isFilterCollection = true 
            self.view.endEditing(true)
            self.present(collectionPicker, animated: true, completion: nil)
        }
        
    }
}
extension FilterViewController:UITextViewDelegate{
    func textViewDidEndEditing(_ textView: UITextView){
        DispatchQueue.main.async {
            if textView == self.textOfLanguage{
                if textView.text.count == 0{
                    self.textOfLanguage.resignFirstResponder()
                    //self.txtLanguage.maximizePlaceholder()
                    textView.resignFirstResponder()
                }else{
                    self.txtLanguage.minimizePlaceholder()
                }
            }else if textView == self.textOfSearch{
                if textView.text.count == 0{
                    self.textOfSearch.resignFirstResponder()
                    //self.txtSearch.maximizePlaceholder()
                    textView.resignFirstResponder()
                }else{
                    //self.txtSearch.minimizePlaceholder()
                }
            }else if textView == self.txtExperienceCollection{
                if textView.text.count == 0{
                    self.txtCollectionOfExperience.resignFirstResponder()
                    DispatchQueue.main.async {
                        //self.txtCollectionOfExperience.maximizePlaceholder()
                    }
                    textView.resignFirstResponder()
                }else{
                    self.txtCollectionOfExperience.minimizePlaceholder()
                }
            }
            defer {
                //self.tableGuideSingUp.scrollToBottom(animated: false)
                //self.sizeFooterToFit()
            }
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView){
        DispatchQueue.main.async {
            if textView == self.textOfLanguage{
                self.txtLanguage.resignFirstResponder()
                self.textOfLanguage.resignFirstResponder()
                // self.txtLanguage.minimizePlaceholder()
                //PresentLanguagePicker
                self.presentLangaugePicker()
            }else if textView == self.textOfSearch{
                self.txtSearch.resignFirstResponder()
                //self.txtCountry.resignFirstResponder()
                //self.txtSearch.minimizePlaceholder()
               // textView.becomeFirstResponder()
            }else if textView == self.txtExperienceCollection {
                self.txtCollectionOfExperience.resignFirstResponder()
                textView.resignFirstResponder()
                self.presentCollectionPicker()
                
            }
            defer{
                //self.view.endEditing(true)
            }
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let typpedString = ((textView.text)! as NSString).replacingCharacters(in: range, with: text)
        
        if text == "\n"{
            textView.resignFirstResponder()
            return true
        }
        if textView == self.textOfSearch{
            self.filterValue![kFreeSearchString] = "\(typpedString)"
        }
        return typpedString.count < 40
    }
}
extension FilterViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        if string == "\n"{
            textField.resignFirstResponder()
            return true
        }
        if textField == self.txtSearch{
            self.filterValue![kFreeSearchString] = "\(typpedString)"
        }
        return typpedString.count < 40
    }
}
