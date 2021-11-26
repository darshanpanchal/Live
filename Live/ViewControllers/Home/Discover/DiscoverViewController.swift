//
//  DiscoverViewController.swift
//  Live
//
//  Created by ITPATH on 4/11/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import FacebookCore
import AVKit
import AVFoundation
import MaterialShowcase
import ReadMoreTextView
import SDWebImage

class DiscoverViewController: UIViewController, GuideDescriptionReadMore,UIGestureRecognizerDelegate {

    fileprivate var kInstant:String = "IsInstant"
    fileprivate var kPrice:String = "MaxPrice"
    fileprivate var kWheelChair:String = "OnlyAccessible"
    fileprivate var kPetFriendly:String = "OnlyPetFriendly"
    fileprivate var kFreeForChildern:String = "OnlyFreeChildren"
    fileprivate var kFreeForElderly:String = "OnlyFreeElderly"
    fileprivate var kFreeTextSeach:String = "FreeTextSearch"
    fileprivate var kLanguagees:String = "Languages"
    fileprivate let kExperienceCollectionId = "CollectionIds"

    @IBOutlet weak var currentCityTextFieldWidth: NSLayoutConstraint!
    @IBOutlet weak var noInternetConnectionView: UIView!
    @IBOutlet var tableviewDiscover:UITableView!
    @IBOutlet var tableViewHeaderImage:ImageViewForURL!
    @IBOutlet var tableviewHeader:UIView!
    @IBOutlet var textCurrentCity:CustomTextField!
    @IBOutlet var lblCountryName:UILabel!
    @IBOutlet var lblNavTitle:UILabel!
    @IBOutlet var btnFilter:UIButton!
    @IBOutlet var cityPickerView:UIPickerView!
    @IBOutlet var objToolBar:UIToolbar!
    @IBOutlet var btnShowMore:RoundButton!
    @IBOutlet var noINternetLbl1:UILabel!
    @IBOutlet var noINternetLbl2:UILabel!
    @IBOutlet weak var retryBtn: RoundButton!
    @IBOutlet var playerView:UIView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet var txtFreeSeach:UITextField!
    @IBOutlet var btnFreeSearch:UIButton!
    @IBOutlet var collectionAllExperience:UICollectionView!
    @IBOutlet var lblAllExperience:UILabel!
    
    private var tag :Int = 100
    var isNoDataOnFreeSearch:Bool = false
    var isSearchInitiative:Bool = false
    var defaultListingTag:Int{
        get{
            return tag
        }
        set{
           tag = newValue
           //ConfigureDefaultTag
            self.configureInstantHidden()
        }
    }
    var selectedCityTag:Int = 0
    var tableviewHeightOfHeader:CGFloat{
        get{
            return 272.0
        }
    }
    var tableviewExperienceRowHeight:CGFloat{
        get{
            return 380//UIScreen.main.bounds.height * 380.0/812.0
        }
    }
    var tableViewExploreCollectionRowHeight:CGFloat{
        get{
            return 220;//UIScreen.main.bounds.width*0.5+10+40+10//UIScreen.main.bounds.height * 300.0/812.0
        }
    }
    var tableViewTopRatedGuideHeight:CGFloat{
        get{
            return 280.0 + 36.0 //350.0
           //return UIScreen.main.bounds.height * 200.0/812.0
        }
    }
    var tableViewAllExperienceHeight:CGFloat{
        get{
            return 380
        }
    }
    var tableFooterViewHeight:CGFloat = 50.0
    var countryDetail:CountyDetail?
    var arrayOfCountryDetail:[CountyDetail] = [] //Detail of cities
    var arrayOfInstantExperience:[Experience] = []
    var arrayOfBestRatedExperience:[Experience] = []
    var arrayOfExploreCollection:[Collections] = []
    var arrayOfTopRatedGuide:[Guide] = []
    var arrayOfAllExperience:[Experience] = []
    var arrayOfRowsSection:NSArray = []
    var arrayOfExperienceTitle:[String] = []
    var arrayOfExperienceDiscription:[String] = []
    
    var currentPageIndex:Int = 0 //pagination for all experience
    var currentPageSize:Int = 10//pagination for all experience
    var instantPageIndex:Int = 0
    var isInstantLoadMore:Bool = false
    var bestRatedPageIndex:Int = 0
    var isBesRatedLoadMore:Bool = false
    var isLocationHasExperience:Bool = false
    var isDefaultSearch:Bool = true
    var isSugggestedSearchResultShown:Bool = false
    private var player = AVPlayer()
    private var playerViewController = AVPlayerViewController()
    fileprivate var loadMore = true
    var isShowMore:Bool{
        get{
            return self.loadMore
        }
        set{
            self.loadMore = newValue
            //ConfigureLoadMore
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                 self.configureLoadMore()
            }
        }
    }
    var filterParameters:[String:Any]?
    var playerObserver:NSObjectProtocol?
    
    // MARK: - ViewContoller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.pushToWhereToNextViewController()
        self.retryBtn.layer.cornerRadius = self.retryBtn.frame.height / 2.0
        self.retryBtn.clipsToBounds = true
        // Do any additional setup after loading the view.
        self.filterParameters = [kInstant:false,kPrice:"0",kWheelChair:false,kPetFriendly:false,kFreeForChildern:false,kFreeForElderly:false,kFreeTextSeach:"",kLanguagees:[],kExperienceCollectionId:[]]
        self.isShowMore = false
        self.arrayOfRowsSection = [self.arrayOfBestRatedExperience,self.arrayOfInstantExperience,self.arrayOfExploreCollection,self.arrayOfTopRatedGuide,self.arrayOfAllExperience]
        //Configure View
        self.configureDefaultCity()
        //ConfigureTableView
        self.configureTableView()
        //ConfigereCityPicker
        self.configureCityPicker()
        
        //Configure FreeSearch
        self.configureFreeSearch()
        
    }
    func swipeToPop() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    func showDisplayShowCase(){
        if let value = kUserDefault.value(forKey: kShowCaseForLocationButton) as? Bool, value {
        } else {
            DispatchQueue.main.async {
                self.displayShowCase()
                
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.locationButton.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureInstantHidden()
        self.changeTextAsLanguage()
        self.navigationController?.navigationBar.isHidden = true
        DispatchQueue.main.async {
            //self.tableviewDiscover.reloadData()
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.lblNavTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblNavTitle.adjustsFontForContentSizeCategory = true
        self.lblNavTitle.adjustsFontSizeToFitWidth = true
        
        self.lblAllExperience.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblAllExperience.adjustsFontForContentSizeCategory = true
        self.lblAllExperience.adjustsFontSizeToFitWidth = true
        
        self.txtFreeSeach.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.txtFreeSeach.adjustsFontForContentSizeCategory = true
        
        self.btnFilter.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
        self.btnFilter.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnFilter.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.btnShowMore.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
        self.btnShowMore.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnShowMore.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.noINternetLbl1.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.noINternetLbl1.adjustsFontForContentSizeCategory = true
        self.noINternetLbl1.adjustsFontSizeToFitWidth = true
        
        self.noINternetLbl2.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.noINternetLbl2.adjustsFontForContentSizeCategory = true
        self.noINternetLbl2.adjustsFontSizeToFitWidth = true
        
        self.retryBtn.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.retryBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        self.retryBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let _ = self.playerObserver{
            self.view.endEditing(true)
            NotificationCenter.default.removeObserver(self.playerObserver!)
        }
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        let alertController = UIAlertController.init(title:"Memory", message:"didReceiveMemoryWarning", preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title:"Ok", style: .cancel, handler:nil))
        
        //self.present(alertController, animated: true, completion: nil)
        cashedImages.removeAll()
        let imageCache = SDImageCache.shared()
        imageCache.clearMemory()
        imageCache.clearDisk {
            
        }
    }
    // MARK: - Custom Methods
    
    func displayShowCase() {
        
        let showcase = MaterialShowcase()
        showcase.setTargetView(view: self.locationButton)
        showcase.backgroundViewType = .full
        showcase.primaryText = Vocabulary.getWordFromKey(key:"showcaseLocation")
        showcase.primaryTextFont = UIFont.init(name:"Avenir-Heavy", size: 30.0)//CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        showcase.secondaryText = Vocabulary.getWordFromKey(key:"gotIt.hint")//
        showcase.secondaryTextFont = UIFont.init(name:"Avenir-Heavy", size: 20.0)
        showcase.delegate = self
        showcase.shouldSetTintColor = true // It should be set to false when button uses image.
        showcase.backgroundPromptColor = UIColor.init(red: 54.0/255.0, green: 83.0/255.0, blue: 123.0/255.0, alpha: 1.0)//UIColor.black
        showcase.backgroundPromptColorAlpha = 0.85
        showcase.isTapRecognizerForTargetView = false
        showcase.show(completion: {
        })
    }
    
    func configureInstantHidden(){
        if self.defaultListingTag == 100{
             self.arrayOfExperienceTitle = ["\(Vocabulary.getWordFromKey(key: "Bestrated"))","\(Vocabulary.getWordFromKey(key: "instant"))","\(Vocabulary.getWordFromKey(key: "Explorecollections"))","\(Vocabulary.getWordFromKey(key: "Topratedguides"))","\(Vocabulary.getWordFromKey(key: "AllExperiences"))"]
             self.arrayOfExperienceDiscription = ["\(Vocabulary.getWordFromKey(key: "bestRateDesc"))","\(Vocabulary.getWordFromKey(key: "instantDesc"))","\(Vocabulary.getWordFromKey(key: "exploreDesc"))","\(Vocabulary.getWordFromKey(key: "Topratedguides"))",""]
              self.arrayOfRowsSection = [self.arrayOfBestRatedExperience,self.arrayOfInstantExperience,self.arrayOfExploreCollection,self.arrayOfTopRatedGuide,self.arrayOfAllExperience]
        }else if self.defaultListingTag == 101{
            self.arrayOfExperienceTitle = ["\(Vocabulary.getWordFromKey(key: "Bestrated"))","\(Vocabulary.getWordFromKey(key: "Explorecollections"))","\(Vocabulary.getWordFromKey(key: "Topratedguides"))","\(Vocabulary.getWordFromKey(key: "AllExperiences"))"]
            self.arrayOfExperienceDiscription = ["\(Vocabulary.getWordFromKey(key: "bestRateDesc"))","\(Vocabulary.getWordFromKey(key: "exploreDesc"))","\(Vocabulary.getWordFromKey(key: "Topratedguides"))",""]
              self.arrayOfRowsSection = [self.arrayOfBestRatedExperience,self.arrayOfExploreCollection,self.arrayOfTopRatedGuide,self.arrayOfAllExperience]
        }
    }
    func configureDefaultCity(){
        if let _ = self.countryDetail{
       
            self.getLocationRequestWithCountyID(countryID:self.countryDetail!.countryID, locationID:self.countryDetail!.locationID)
        }else{
            //Check for User LogIn and get city detail
            if(User.isUserLoggedIn),let currentUser = User.getUserFromUserDefault(){
                
                self.getLocationRequestWithCountyID(countryID: currentUser.userCountryID, locationID: currentUser.userLocationID)
            }
        }
    }
    
    func changeTextAsLanguage() {
        self.txtFreeSeach.placeholder = Vocabulary.getWordFromKey(key: "SearchHint")
        self.txtFreeSeach.placeholderTextColor = UIColor.white
        self.lblNavTitle.text = Vocabulary.getWordFromKey(key: "discover")
       
        self.btnShowMore.setTitle(Vocabulary.getWordFromKey(key: "showMore"), for: .normal)
        self.noINternetLbl1.text = Vocabulary.getWordFromKey(key: "NoInternetPage.text1")
        self.noINternetLbl2.text = Vocabulary.getWordFromKey(key: "NoInternetPage.text2")
        self.retryBtn.setTitle(Vocabulary.getWordFromKey(key: "Retry"), for: .normal)
    }
    
    func configureTableView(){
        //self.tableviewDiscover.rowHeight = UITableViewAutomaticDimension
        //self.tableviewDiscover.estimatedRowHeight = 150.0
        self.tableviewDiscover.delegate = self
        self.tableviewDiscover.dataSource = self
        //Register Experience TableViewCell
        let objExperienceNib = UINib.init(nibName: "ExperienceTableViewCell", bundle: nil)
        self.tableviewDiscover.register(objExperienceNib, forCellReuseIdentifier: "ExperienceTableViewCell")
        //Register All Experience TableViewCell
        let objAllExperienceNib = UINib.init(nibName: "AllExperienceTableViewCell", bundle: nil)
        self.tableviewDiscover.register(objAllExperienceNib, forCellReuseIdentifier: "AllExperienceTableViewCell")
        
        self.tableviewDiscover.separatorStyle = .none
        DispatchQueue.main.async {
            //self.tableviewDiscover.reloadData()
        }
        if let _ = self.tableviewDiscover.tableHeaderView{
            self.tableviewDiscover.tableHeaderView?.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.tableviewDiscover.bounds.width, height: self.tableviewHeightOfHeader))
        }
        /*if let _ = self.tableviewDiscover.tableFooterView{
            UIView.setAnimationsEnabled(false)
            self.tableviewDiscover.beginUpdates()
            self.tableviewDiscover.tableFooterView?.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.tableviewDiscover.bounds.width, height: self.tableFooterViewHeight))
            self.tableviewDiscover.layoutIfNeeded()
            self.tableviewDiscover.reloadData()
            self.tableviewDiscover.endUpdates()
            UIView.setAnimationsEnabled(true)
        }*/
        let objExperienceCollectionNib = UINib.init(nibName: "ExperienceCollectionViewCell", bundle: nil)
        self.collectionAllExperience.register(objExperienceCollectionNib, forCellWithReuseIdentifier: "ExperienceCollectionViewCell")
        self.collectionAllExperience.tag = 104
        self.collectionAllExperience.delegate = self
        self.collectionAllExperience.dataSource = self
        self.collectionAllExperience.isScrollEnabled = false
    }
    func configureCityPicker(){
        self.cityPickerView.delegate = self
        self.cityPickerView.dataSource = self
        //self.textCurrentCity.inputView = self.cityPickerView
    }
    func setCityDetailWith(countryDetail:CountyDetail){
        self.showDisplayShowCase()
        var parameters:[String:Any] = [:]
        parameters["item_name"] = "Discover"
        parameters["country"] = "\(countryDetail.countyName)"
        parameters["defaultCity"] = "\(countryDetail.defaultCity)"
        if User.isUserLoggedIn,let user = User.getUserFromUserDefault(){
            parameters["username"] = "\(user.userFirstName) \(user.userLastName)"
            parameters["userID"] = "\(user.userID)"
            user.userCountryID = "\(countryDetail.countryID)"
            user.userLocationID = "\(countryDetail.locationID)"
            user.setUserDataToUserDefault()
        }
        CommonClass.shared.addFirebaseAnalytics(parameters: parameters)
        self.addFaceBookAnayltics(countryDetail: countryDetail)
        
        self.countryDetail = countryDetail
        DispatchQueue.main.async {
            self.textCurrentCity.text = "\(countryDetail.defaultCity)"
            let width = self.getWidth(text: "\(countryDetail.defaultCity)")
            self.currentCityTextFieldWidth.constant = width
            self.textCurrentCity.frame.size.width = width
            self.view.layoutIfNeeded()
            self.lblCountryName.text = "\(countryDetail.countyName)"
            if countryDetail.isVideo{
                self.playerView.isHidden = false
                if let url = URL.init(string: "\(countryDetail.imageURL)"){
                   self.playVideo(videoUrl: url)
                  self.playerObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { _ in
                        self.player.seek(to: kCMTimeZero)
                        self.player.play()
                    }
                }
            }else{
                self.playerView.isHidden = true
                self.stopVideo()
                self.tableViewHeaderImage.imageFromServerURL(urlString: countryDetail.imageURL,placeHolder: #imageLiteral(resourceName: "expriencePlaceholder").withRenderingMode(.alwaysOriginal))
            }
        }
        instantPageIndex = 0
        self.isInstantLoadMore = false
        self.arrayOfInstantExperience = []
        bestRatedPageIndex = 0
        self.arrayOfBestRatedExperience = []
        self.isBesRatedLoadMore = false
        self.arrayOfAllExperience = []
        self.currentPageIndex = 0
        self.arrayOfExploreCollection = []
        self.arrayOfTopRatedGuide = []
        //Configure Experiences On Selected City
        self.getInstantExperienceOnCity(locationID:"\(countryDetail.locationID)")
       
    }
    
    func getWidth(text: String) -> CGFloat {
        let txtField = UITextField(frame: .zero)
        txtField.font = UIFont(name: "Avenir-Heavy", size: 44.0)
        txtField.text = text
        txtField.sizeToFit()
        return txtField.frame.size.width
    }
    
    func playVideo(videoUrl:URL){
        self.playerView.isHidden = false
        let objAsset = AVURLAsset.init(url: videoUrl)
        let objPlayerItem = AVPlayerItem.init(asset: objAsset)
        self.player = AVPlayer.init(playerItem: objPlayerItem)
        self.playerViewController.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
        self.playerViewController.player = self.player
        self.playerViewController.view.frame = self.playerView.frame
        self.playerViewController.showsPlaybackControls = false
        self.playerView.addSubview(self.playerViewController.view)
        self.player.play()
        self.player.isMuted = true
        self.playerViewController.player?.isMuted = true
        self.playerViewController.player?.volume = 0.0
        self.player.volume = 0.0
    }
    func stopVideo(){
        self.playerView.isHidden = true
        if let _ = self.playerObserver{
            NotificationCenter.default.removeObserver(self.playerObserver!)
        }
        self.player.pause()
    }
    func addFaceBookAnayltics(countryDetail:CountyDetail){
        var parameters:AppEvent.ParametersDictionary = [:]
        parameters["item_name"] = "Discover"
        parameters["country"] = "\(countryDetail.countyName)"
        parameters["defaultCity"] = "\(countryDetail.defaultCity)"
        if User.isUserLoggedIn,let user = User.getUserFromUserDefault(){
            parameters["username"] = "\(user.userFirstName) \(user.userLastName)"
            parameters["userID"] = "\(user.userID)"
        }
        CommonClass.shared.addFaceBookAnalytics(eventName: "Discover", parameters: parameters)
    }
    func getAllExperienceTableViewHeight()->CGFloat{
        let collectionWidth:CGFloat = UIScreen.main.bounds.width*0.5+80
        
        if self.arrayOfAllExperience.count < 3{
            return collectionWidth + 50.0 + 20.0
        }else if self.arrayOfAllExperience.count % 2 == 0{
            return (CGFloat(self.arrayOfAllExperience.count/2) * collectionWidth) + 50.0 + (CGFloat(self.arrayOfAllExperience.count/2) * 10.0)
        }else{
            return (CGFloat((self.arrayOfAllExperience.count+1)/2) * collectionWidth) + 50.0 + (CGFloat(self.arrayOfAllExperience.count+1/2) * 10.0)// + 80.0 //+ 20
        }
    }
    //Get Collection
    func configureExploreCollection(){
        self.getExploreCollection()
    }
    //Configure Load More on pagination
    func configureLoadMore(){
     
        var objTableViewFooterHeight:CGFloat = 0.0
//        if self.currentPageIndex == 0 || self.currentPageIndex == 1{
//            tableViewFooterHeight = self.getAllExperienceTableViewHeight()+20.0
//        }else{
//            tableViewFooterHeight = self.getAllExperienceTableViewHeight()+20.0//self.collectionAllExperience.contentSize.height+120.0
//        }
        if self.currentPageIndex == 0{
            objTableViewFooterHeight = self.collectionAllExperience.contentSize.height + 120.0
        }else if self.currentPageIndex == 1 {
            self.tableFooterViewHeight = self.collectionAllExperience.contentSize.height
            objTableViewFooterHeight = self.tableFooterViewHeight + 120.0
        }else if self.isShowMore{
            objTableViewFooterHeight = (self.tableFooterViewHeight * CGFloat(self.currentPageIndex)) + 120.0
        }else{
            objTableViewFooterHeight = self.collectionAllExperience.contentSize.height + 120.0
        }
        
        print("=====\(self.currentPageIndex) \(objTableViewFooterHeight) =====")
        self.btnShowMore.isHidden = !self.isShowMore
        if let _ = self.tableviewDiscover.tableFooterView{
                UIView.setAnimationsEnabled(false)
                //self.tableviewDiscover.beginUpdates()
                self.tableviewDiscover.tableFooterView?.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.tableviewDiscover.bounds.width, height: objTableViewFooterHeight))
                self.tableviewDiscover.layoutIfNeeded()
                self.collectionAllExperience.reloadData()
                self.tableviewDiscover.reloadData()
                //self.tableviewDiscover.endUpdates()
                UIView.setAnimationsEnabled(true)
//                self.sizeFooterToFit()
//            self.tableviewDiscover.tableFooterView?.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.tableviewDiscover.bounds.width, height: (self.isShowMore) ? self.tableFooterViewHeight:0))
        }
    }
    func sizeFooterToFit() {
        if let footerView =  self.tableviewDiscover.tableFooterView {
            footerView.setNeedsLayout()
            footerView.layoutIfNeeded()
            
            let height = footerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var frame = footerView.frame
            frame.size.height = height
            footerView.frame = frame
            self.tableviewDiscover.tableFooterView = footerView
        }
    }
    //Configure Free Search
    func configureFreeSearch(){
        if let _ = self.filterParameters{
            self.filterParameters![kFreeTextSeach] = "" //Initial Search
        }
        self.txtFreeSeach.delegate = self
    }
    func freeSearchAPIRequest(){
        if let _ = self.filterParameters{
            let searchedString = "\(self.filterParameters![kFreeTextSeach] ?? "")"
            self.filterParameters = [kInstant:false,kPrice:"10000",kWheelChair:false,kPetFriendly:false,kFreeForChildern:false,kFreeForElderly:false,kFreeTextSeach:searchedString,kLanguagees:[]]
        }
        self.isNoDataOnFreeSearch = true
        self.isSearchInitiative = true
        self.isDefaultSearch = false
        DispatchQueue.main.async {
            ProgressHud.show()
            self.tableviewDiscover.reloadData()
        }
        instantPageIndex = 0
        isInstantLoadMore = true
        bestRatedPageIndex = 0
        isBesRatedLoadMore = true
        self.currentPageIndex = 0
        self.isShowMore = false
        self.arrayOfAllExperience = []
        self.getInstantExperienceOnCity(locationID:"\(countryDetail?.locationID ?? "1")")
    }
    //MARK: - API Methods
    //Get Cities
    func getLocationRequestWithCountyID(countryID:String,locationID:String){
        if(User.isUserLoggedIn),let currentUser = User.getUserFromUserDefault(){
            currentUser.userCountryID = "\(countryID)"
            currentUser.userLocationID = "\(locationID)"
            currentUser.setUserDataToUserDefault()
        }
        let requestURL = "\(kCityLocations)\(countryID)"
        guard CommonClass.shared.isConnectedToInternet else{
            self.noInternetConnectionView.isHidden = false
            self.tableviewDiscover.isHidden = true
            return
        }
        self.noInternetConnectionView.isHidden = true
        self.tableviewDiscover.isHidden = false
        
        let freeSearchURL = "base/native/locations/\(countryID)/freesearch"
        guard CommonClass.shared.isConnectedToInternet else{
            DispatchQueue.main.async {
                ShowToast.show(toatMessage:"No Internet connection.")
            }
            return
        }
        
        let freeSearchParameters:[String:AnyObject] = ["SearchText":"" as AnyObject]
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:freeSearchURL, parameter:freeSearchParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let arraySuccess = successDate["location"] as? NSArray{
                for objCountry in arraySuccess{
                    if let jsonCountry = objCountry as? [String:Any]{
                        let countryDetail = CountyDetail.init(objJSON: jsonCountry)
                        self.arrayOfCountryDetail.append(countryDetail)
                    }
                }
                if self.arrayOfCountryDetail.count > 0{
                    let filteredArray = self.arrayOfCountryDetail.filter() { $0.locationID == "\(locationID)" }
                    if let _ = filteredArray.first{
                        self.setCityDetailWith(countryDetail: filteredArray.first!)
                }else{
                        DispatchQueue.main.async {
                            //WhereToNext
                            self.isLocationHasExperience = true
                            ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key:"selectlocation.hint"))
                            self.performSegue(withIdentifier: "unwindToViewController", sender: nil)
                            //self.navigationController?.popViewController(animated: true)
                        }
                }
                }else{
                    DispatchQueue.main.async {
                        //WhereToNext
                        self.isLocationHasExperience = true
                        ShowToast.show(toatMessage:Vocabulary.getWordFromKey(key:"selectlocation.hint"))
                        self.performSegue(withIdentifier: "unwindToViewController", sender: nil)
                        //self.navigationController?.popViewController(animated: true)
                    }
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
        /*
        APIRequestClient.shared.getCitiesOnCountyID(requestType: .GET, queryString: requestURL, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let arraySuccess = successDate["location"] as? NSArray{
                for objCountry in arraySuccess{
                    if let jsonCountry = objCountry as? [String:Any]{
                        let countryDetail = CountyDetail.init(objJSON: jsonCountry)
                        self.arrayOfCountryDetail.append(countryDetail)
                    }
                }
                if self.arrayOfCountryDetail.count > 0{
                    let filteredArray = self.arrayOfCountryDetail.filter() { $0.locationID == "\(locationID)" }
                    if let _ = filteredArray.first{
                        self.setCityDetailWith(countryDetail: filteredArray.first!)
                    }else{
                        //WhereToNext
                        ShowToast.show(toatMessage:"Please select another location.")
                        self.navigationController?.popViewController(animated: true)
                        
                    }
                }else{
                    //WhereToNext
                    ShowToast.show(toatMessage:"")
                    self.navigationController?.popViewController(animated: true)
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
        }*/
    }
    //Get InstantExperience based on locationID
    func getInstantExperienceOnCity(locationID:String){
        var userID:String = "0"
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            userID = currentUser.userID
        }
        let urlInstantExperience = "\(kInstantExperience)\(locationID)/instantexperiences?pagesize=\(self.currentPageSize)&pageindex=\(self.instantPageIndex)&userId=\(userID)"
        
        guard CommonClass.shared.isConnectedToInternet else{
            self.noInternetConnectionView.isHidden = false
            self.tableviewDiscover.isHidden = true
            return
        }
        DispatchQueue.main.async {
            self.noInternetConnectionView.isHidden = true
            self.tableviewDiscover.isHidden = false
        }
        if self.isSearchInitiative{
            
        }else{
            
        }
        let searchedString = "\(self.filterParameters![kFreeTextSeach] ?? "")"
        var parameters:[String:AnyObject] = self.isSearchInitiative ? [kFreeTextSeach:"\(searchedString)"] as [String:AnyObject] : self.filterParameters! as [String : AnyObject]
            if let udid = UIDevice.current.identifierForVendor{
                var pushToken = "\(udid.uuidString)" as AnyObject
                if let _ = kUserDefault.value(forKey:kPushNotificationToken){
                    //pushToken = "\(kUserDefault.value(forKey:kPushNotificationToken)!)" as AnyObject
                }
                parameters["deviceId"] = pushToken
            }
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:urlInstantExperience, parameter:self.isDefaultSearch ? [:]:parameters, isHudeShow: self.instantPageIndex == 0 ? true : false, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let array = successDate["InstantExperience"] as? [[String:Any]]{
                if let responseMSG = successDate["ResultMessage"] as? String,responseMSG.count > 0,!self.isDefaultSearch,!self.isSugggestedSearchResultShown{
                    DispatchQueue.main.async {
                        self.isSugggestedSearchResultShown = true
                        ShowToast.show(toatMessage: "\(responseMSG)")
                    }
                }
                if self.instantPageIndex == 0{
                    self.arrayOfInstantExperience = []
                }
                self.isInstantLoadMore = (array.count == self.currentPageSize)
                for object in array{
                    let objectExperience = Experience.init(experienceDetail: object)
                    self.arrayOfInstantExperience.append(objectExperience)
                }
                
                DispatchQueue.main.async {
                     self.defaultListingTag = 100
                     /*
                    self.defaultListingTag = 100
                    if self.arrayOfInstantExperience.count > 0{
                        self.defaultListingTag = 100
                    }else{
                        self.defaultListingTag = 101
                    }*/
                    
                    if self.instantPageIndex == 0{
                        //self.tableviewDiscover.reloadData()
                        self.getBestRatedExperienceOnCity(locationID:"\(locationID)")
                    }else{
                        self.tableviewDiscover.reloadData()
                    }
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
                    self.tableviewDiscover.reloadData()
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
    }
    //Get Best Rated experience based on locationID
    func getBestRatedExperienceOnCity(locationID:String){
        var userID:String = "0"
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            userID = currentUser.userID
        }
        let urlInstantExperience = "\(kBestRatedExperience)\(locationID)/bestreview?pagesize=\(self.currentPageSize)&pageindex=\(self.bestRatedPageIndex)&userId=\(userID)"
        guard CommonClass.shared.isConnectedToInternet else{
            self.tableviewDiscover.isHidden = true
            self.noInternetConnectionView.isHidden = false
            return
        }
        DispatchQueue.main.async {
            self.noInternetConnectionView.isHidden = true
            self.tableviewDiscover.isHidden = false
        }
        let searchedString = "\(self.filterParameters![kFreeTextSeach] ?? "")"
        var parameters:[String:AnyObject] = self.isSearchInitiative ? [kFreeTextSeach:"\(searchedString)"] as [String:AnyObject] : self.filterParameters! as [String : AnyObject]
            if let udid = UIDevice.current.identifierForVendor{
                var pushToken = "\(udid.uuidString)" as AnyObject
                if let _ = kUserDefault.value(forKey:kPushNotificationToken){
                    //pushToken = "\(kUserDefault.value(forKey:kPushNotificationToken)!)" as AnyObject
                }
                parameters["deviceId"] = pushToken
            }
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:urlInstantExperience, parameter:self.isDefaultSearch ? [:] : parameters, isHudeShow: self.bestRatedPageIndex == 0 ? self.isSearchInitiative : false, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let array = successDate["BestReviewExperience"] as? [[String:Any]]{
                if let responseMSG = successDate["ResultMessage"] as? String,responseMSG.count > 0,!self.isDefaultSearch,!self.isSugggestedSearchResultShown{
                    DispatchQueue.main.async {
                        self.isSugggestedSearchResultShown = true
                        ShowToast.show(toatMessage: "\(responseMSG)")
                    }
                }
                if self.bestRatedPageIndex == 0{
                    self.arrayOfBestRatedExperience = []
                }
                self.isBesRatedLoadMore = (array.count == self.currentPageSize)
                for object in array{
                    let objectExperience = Experience.init(experienceDetail: object)
                    self.arrayOfBestRatedExperience.append(objectExperience)
                }
                DispatchQueue.main.async {
                    if let cell = self.tableviewDiscover.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? ExperienceTableViewCell{
                        if self.tableviewDiscover.visibleCells.contains(cell){
                            cell.collectionExperience.reloadData()
                            //self.tableviewDiscover.reloadRows(at: [IndexPath.init(row: 0, section: 0)],  with: .automatic)
                        }
                    }
                    if self.bestRatedPageIndex == 0{
                        self.getExploreCollection()
                        self.collectionAllExperience.reloadData()
                        self.getTopRatedExperience(locationID: "\(locationID)")
                    }
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
                    self.tableviewDiscover.reloadData()
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
    }
    //Get Explore collection
    func getExploreCollection(){
        //kExploreCollection
        guard CommonClass.shared.isConnectedToInternet else{
            self.noInternetConnectionView.isHidden = false
            self.tableviewDiscover.isHidden = true
            return
        }
        DispatchQueue.main.async {
            self.noInternetConnectionView.isHidden = true
            self.tableviewDiscover.isHidden = false
        }
        if let _ = self.countryDetail{
            let requestURL = "experience/native/\(self.countryDetail!.locationID)/collection"
            let expoParameter:[String:AnyObject] = ["FreeTextSearch": "\(self.filterParameters![kFreeTextSeach] ?? "")" as AnyObject]
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString:requestURL, parameter:self.isDefaultSearch ? [:]:expoParameter , isHudeShow: false, success: { (responseSuccess) in
                
                if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let array = successDate["collections"] as? [[String:Any]]{
                    if let responseMSG = successDate["ResultMessage"] as? String,responseMSG.count > 0,!self.isDefaultSearch,!self.isSugggestedSearchResultShown{
                        DispatchQueue.main.async {
                            self.isSugggestedSearchResultShown = true
                            ShowToast.show(toatMessage: "\(responseMSG)")
                        }
                    }
                    self.arrayOfExploreCollection = []
                    for object in array{
                        let objectExperience = Collections.init(collectionDetail: object)
                        self.arrayOfExploreCollection.append(objectExperience)
                    }
                    
                    DispatchQueue.main.async {
                        //self.tableviewDiscover.reloadData()
                        self.arrayOfAllExperience = []
                        self.tableviewDiscover.reloadData()
                        self.getAllExperienceOnLocation(locationID: "\(self.countryDetail!.locationID)")
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
        }
    }
    //Get Top rated guides
    func getTopRatedExperience(locationID:String){
        let urlInstantExperience = "\(kTopRatedGuides)\(locationID)/toprated"
        guard CommonClass.shared.isConnectedToInternet else{
            self.tableviewDiscover.isHidden = true
            self.noInternetConnectionView.isHidden = false
            return
        }
        DispatchQueue.main.async {
            self.noInternetConnectionView.isHidden = true
            self.tableviewDiscover.isHidden = false
        }
        
        let topRatedParameters:[String:AnyObject] = ["FreeTextSearch": "\(self.filterParameters![kFreeTextSeach] ?? "")" as AnyObject,"Languages":self.filterParameters![kLanguagees] as AnyObject]
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:urlInstantExperience, parameter:self.isDefaultSearch ? [:]:topRatedParameters as [String : AnyObject], isHudeShow: false, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let array = successDate["TopRatedGuide"] as? [[String:Any]]{
                if let responseMSG = successDate["ResultMessage"] as? String,responseMSG.count > 0,!self.isDefaultSearch,!self.isSugggestedSearchResultShown{
                    DispatchQueue.main.async {
                        self.isSugggestedSearchResultShown = true
                        ShowToast.show(toatMessage: "\(responseMSG)")
                    }
                }
                self.arrayOfTopRatedGuide = []
                for object in array{
                    let objectExperience = Guide.init(guideDetail: object)
                    self.arrayOfTopRatedGuide.append(objectExperience)
                }
                DispatchQueue.main.async {
                   // self.tableviewDiscover.reloadData()
                    //ConfigureExploreCollection
                    //self.configureExploreCollection()
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
    //Get All Experience based on location id
    func getAllExperienceOnLocation(locationID:String){
        var userID:String = "0"
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            userID = currentUser.userID
        }
        if let _ = self.filterParameters,let isInstant = self.filterParameters!["IsInstant"]{
            if !Bool.init("\(isInstant)"){
                //self.filterParameters!.removeValue(forKey:"IsInstant")
            }
        }
        //self.currentPageSize = 50
        let urlAllExperience = "\(kAllExperience)\(locationID)/allexperiences?pagesize=\(self.currentPageSize)&pageindex=\(self.currentPageIndex)&userId=\(userID)"
        guard CommonClass.shared.isConnectedToInternet else{
            self.noInternetConnectionView.isHidden = false
            self.tableviewDiscover.isHidden = true
            return
        }
        DispatchQueue.main.async {
           
            self.noInternetConnectionView.isHidden = true
            self.tableviewDiscover.isHidden = false
        }
        let searchedString = "\(self.filterParameters![kFreeTextSeach] ?? "")"
        //self.isSearchInitiative ? [kFreeTextSeach:"\(searchedString)"] as [String:AnyObject] : self.filterParameters! as [String : AnyObject]
        var parameters:[String:AnyObject] = self.isSearchInitiative ? [kFreeTextSeach:"\(searchedString)"] as [String:AnyObject] : self.filterParameters! as [String : AnyObject]
            if let udid = UIDevice.current.identifierForVendor{
                var pushToken = "\(udid.uuidString)" as AnyObject
                if let _ = kUserDefault.value(forKey:kPushNotificationToken){
                    //pushToken = "\(kUserDefault.value(forKey:kPushNotificationToken)!)" as AnyObject
                }
                parameters["deviceId"] = pushToken
            }
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:urlAllExperience, parameter: self.isDefaultSearch ? [:]:parameters, isHudeShow: (self.currentPageIndex == 0) ? false : true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let array = successDate["experiences"] as? [[String:Any]]{
                if let responseMSG = successDate["ResultMessage"] as? String,responseMSG.count > 0,!self.isDefaultSearch,!self.isSugggestedSearchResultShown{
                    DispatchQueue.main.async {
                        self.isSugggestedSearchResultShown = true
                        ShowToast.show(toatMessage: "\(responseMSG)")
                    }
                }
                var arrayOfTemp:[Experience] = []
                for object in array{
                    let objectExperience = Experience.init(experienceDetail: object)
                    arrayOfTemp.append(objectExperience)
                }
                self.arrayOfAllExperience.append(contentsOf: arrayOfTemp)
                DispatchQueue.main.async {
                    self.lblAllExperience.text =  self.arrayOfAllExperience.count > 0 ? "\(Vocabulary.getWordFromKey(key: "AllExperiences"))" : ""
                    UIView.performWithoutAnimation {
                        self.collectionAllExperience.reloadData()
                        self.collectionAllExperience.layoutIfNeeded()
                    }
                }
                if arrayOfTemp.count == self.currentPageSize{
                    self.currentPageIndex += 1
                    self.isShowMore = true
                }else{
                    self.isShowMore = false
                }
                DispatchQueue.main.async {
//                    if self.currentPageIndex == 0{
//                        self.tableviewDiscover.reloadData()
//                    }
                    ShowHud.show()
//                    if self.currentPageIndex != 0 || self.currentPageIndex != 1{
//                        self.tableviewDiscover.layoutIfNeeded()
//                        self.tableviewDiscover.setContentOffset(CGPoint(x: 0, y: self.tableviewDiscover.contentSize.height - self.tableviewDiscover.frame.height), animated: false)
//                    }
                    if let searchText = self.filterParameters![self.kFreeTextSeach],"\(searchText)".count > 0,
                        self.arrayOfInstantExperience.count == 0,self.arrayOfBestRatedExperience.count == 0,self.arrayOfExploreCollection.count == 0
                        ,self.arrayOfTopRatedGuide.count == 0,self.arrayOfAllExperience.count == 0{
                       self.isNoDataOnFreeSearch = true
                    }else{
                       self.isNoDataOnFreeSearch = false
                    }
                    //self.isSearchInitiative = false
                    
                    if self.currentPageIndex == 0{//self.currentPageIndex == 1 || self.currentPageIndex == 0{
                        ShowHud.hide()
                    }else{
                        ShowHud.hide()
                           /*
                            DispatchQueue.main.asyncAfter(deadline: .now() ) {

                                let rowCount = (self.isNoDataOnFreeSearch) ? 0 : self.arrayOfRowsSection.count
                                if rowCount > 0 {
                                    if let cell:AllExperienceTableViewCell = self.tableviewDiscover.cellForRow(at: IndexPath.init(row:rowCount-1, section: 0)) as? AllExperienceTableViewCell{
                                        //cell.collectionExperience.reloadWithoutAnimation()
                                        cell.collectionExperience.delegate = nil
                                        cell.collectionExperience.dataSource = nil
                                        
                                        cell.selectionStyle = .none
                                        cell.collectionExperience.collectionViewLayout.invalidateLayout()
                                        cell.collectionExperience.delegate = self
                                        cell.collectionExperience.dataSource = self
                                        cell.collectionExperience.reloadWithoutAnimation()
                                    }
                                    self.tableviewDiscover.beginUpdates()
                                    self.tableviewDiscover.reloadRows(at: [IndexPath.init(row: rowCount-1, section: 0)],  with: .none)
                                    self.tableviewDiscover.endUpdates()
                                }
                        }*/
                    }
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
    }
    func favouriteFunctionality(userID:String,objExperience:Experience,tag:Int) {
        if User.isUserLoggedIn{
            if let currentUser = User.getUserFromUserDefault(){
                if objExperience.userID == currentUser.userID{
                        let alertController = UIAlertController.init(title:"\(Vocabulary.getWordFromKey(key:"Information"))", message:Vocabulary.getWordFromKey(key:"unableToAddWishList.hint"), preferredStyle: .alert)
                        alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .cancel, handler: nil))
                        alertController.view.tintColor = UIColor(hexString: "#36527D")
                        self.present(alertController, animated: true, completion: nil)
                        return
                }
            }
        }
        
        
        let urlBookingDetail = "experience/native/wishlist"
        var requestParameters =
            ["UserId":userID as AnyObject,
             "ExperienceId":"\(objExperience.id)" as AnyObject,
             "IsDelete": "\(objExperience.isWished.toBool() ?? true)"
                ] as[String : AnyObject]
        
        if let udid = UIDevice.current.identifierForVendor{
            var pushToken = "\(udid.uuidString)" as AnyObject
            if let _ = kUserDefault.value(forKey:kPushNotificationToken){
                pushToken = "\(kUserDefault.value(forKey:kPushNotificationToken)!)" as AnyObject
            }
            requestParameters["deviceId"] = pushToken
        }
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:urlBookingDetail, parameter: requestParameters, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let _ = success["data"] as? [String:Any] {
                
                if let dataDic = success["data"] as? [String:Any] {
                    
                    
                    DispatchQueue.main.async {
                        let isWish:Bool = objExperience.isWished.toBool() ?? true
                        if isWish{
                            objExperience.isWished = "0"
                        }else{
                            objExperience.isWished = "1"
                        }
                        
                        if tag == 101 {       //Instant
                            UIView.performWithoutAnimation {
                                //let loc = self.tableviewDiscover.contentOffset
                                
                                //self.tableviewDiscover.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .none)
                                //self.tableviewDiscover.contentOffset = loc
                            }
                            
                            let bestRated = self.arrayOfBestRatedExperience.filter({ $0.id == objExperience.id})
                            if bestRated.count > 0{
                                let objBestRated = bestRated.first!
                                let isWishBest:Bool = objBestRated.isWished.toBool() ?? true
                                if isWishBest{
                                    objBestRated.isWished = "0"
                                }else{
                                    objBestRated.isWished = "1"
                                }
                                UIView.performWithoutAnimation {
                                    if  let objCell = self.tableviewDiscover.cellForRow(at: IndexPath.init(row: 1, section: 0)) as? ExperienceTableViewCell{
                                        objCell.collectionExperience.reloadData()
                                    }else{
                                        self.tableviewDiscover.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .none)
                                    }
                                    
                                    //let loc = self.tableviewDiscover.contentOffset
                                    //self.tableviewDiscover.reloadSections(IndexSet(integersIn: 0...0), with: .none)
                                    //self.tableviewDiscover.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .none)
                                    //self.tableviewDiscover.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .none)
                                    //self.tableviewDiscover.contentOffset = loc
                                }
                            }
                            UIView.performWithoutAnimation {
                                if  let objCell = self.tableviewDiscover.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? ExperienceTableViewCell{
                                    objCell.collectionExperience.reloadData()
                                }else{
                                    self.tableviewDiscover.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .none)
                                }
                            }
                            
                            let allExpereince = self.arrayOfAllExperience.filter({ $0.id == objExperience.id})
                            if allExpereince.count > 0{
                                let objAllExper = allExpereince.first!
                                let isWishAllExper:Bool = objAllExper.isWished.toBool() ?? true
                                if isWishAllExper{
                                    objAllExper.isWished = "0"
                                }else{
                                    objAllExper.isWished = "1"
                                }
                                self.collectionAllExperience.reloadData()
                            }
                        }else if tag == 100{  //Best rated
                            UIView.performWithoutAnimation {
                                //let loc = self.tableviewDiscover.contentOffset
                                //self.tableviewDiscover.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .none)
                                //self.tableviewDiscover.contentOffset = loc
                            }
                            let instant = self.arrayOfInstantExperience.filter({ $0.id == objExperience.id})
                            if instant.count > 0{
                                let objinsta = instant.first!
                                let isWishInst:Bool = objinsta.isWished.toBool() ?? true
                                if isWishInst{
                                    objinsta.isWished = "0"
                                }else{
                                    objinsta.isWished = "1"
                                }
                                UIView.performWithoutAnimation {
                                    if  let objCell = self.tableviewDiscover.cellForRow(at: IndexPath.init(row: 1, section: 0)) as? ExperienceTableViewCell{
                                        objCell.collectionExperience.reloadData()
                                    }else{
                                        self.tableviewDiscover.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .none)
                                    }
//                                    let loc = self.tableviewDiscover.contentOffset
//                                    self.tableviewDiscover.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .none)
//                                    self.tableviewDiscover.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .none)
//                                    self.tableviewDiscover.contentOffset = loc
                                }
                            }
                            UIView.performWithoutAnimation {
                                if  let objCell = self.tableviewDiscover.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? ExperienceTableViewCell{
                                    objCell.collectionExperience.reloadData()
                                }else{
                                    self.tableviewDiscover.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .none)
                                }
                            }
                            let allExpereince = self.arrayOfAllExperience.filter({ $0.id == objExperience.id})
                            if allExpereince.count > 0{
                                let objAllExper = allExpereince.first!
                                let isWishAllExper:Bool = objAllExper.isWished.toBool() ?? true
                                if isWishAllExper{
                                    objAllExper.isWished = "0"
                                }else{
                                    objAllExper.isWished = "1"
                                }
                                self.collectionAllExperience.reloadData()
                            }
                            
                        }else if tag == 104{  //All experience
                            let bestRated = self.arrayOfBestRatedExperience.filter({ $0.id == objExperience.id})
                            if bestRated.count > 0{
                                let objBestRated = bestRated.first!
                                let isWishBest:Bool = objBestRated.isWished.toBool() ?? true
                                if isWishBest{
                                    objBestRated.isWished = "0"
                                }else{
                                    objBestRated.isWished = "1"
                                }
                                UIView.performWithoutAnimation {
//                                    if  let objCell = self.tableviewDiscover.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? ExperienceTableViewCell{
//                                        objCell.collectionExperience.reloadData()
//                                    }else{
//                                        self.tableviewDiscover.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .none)
//                                    }
//                                    let loc = self.tableviewDiscover.contentOffset
//                                    self.tableviewDiscover.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .none)
//                                    self.tableviewDiscover.contentOffset = loc

                                }
                            }
                            let instant = self.arrayOfInstantExperience.filter({ $0.id == objExperience.id})
                            if instant.count > 0{
                                let objinsta = instant.first!
                                let isWishInst:Bool = objinsta.isWished.toBool() ?? true
                                if isWishInst{
                                    objinsta.isWished = "0"
                                }else{
                                    objinsta.isWished = "1"
                                }
                                UIView.performWithoutAnimation {
//                                    if  let objCell = self.tableviewDiscover.cellForRow(at: IndexPath.init(row: 1, section: 0)) as? ExperienceTableViewCell{
//                                        objCell.collectionExperience.reloadData()
//                                    }else{
//                                        self.tableviewDiscover.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .none)
//                                    }
//                                    let loc = self.tableviewDiscover.contentOffset
//                                    self.tableviewDiscover.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .none)
//                                    self.tableviewDiscover.contentOffset = loc

                                }
                            }
                            self.collectionAllExperience.reloadData()
                            self.tableviewDiscover.reloadData()
                        }
                    }
                    
//                    self.instantPageIndex = 0
//                    self.isInstantLoadMore = false
//                    self.arrayOfInstantExperience = []
//                    self.bestRatedPageIndex = 0
//                    self.isBesRatedLoadMore = false
//                    self.arrayOfBestRatedExperience = []
//                    self.currentPageIndex = 0
//                    //self.isShowMore = false
//                    self.arrayOfAllExperience = []
                    
                   // self.getInstantExperienceOnCity(locationID:"\(self.countryDetail?.locationID ?? "1")")
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                        //self.tableviewDiscover.delegate = self
                        //self.tableviewDiscover.dataSource = self
                        //self.tableviewDiscover.reloadData()
                    })
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
    @IBAction func buttonCitySearchSelector(selector:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
            if let currencyPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
            {
                currencyPicker.modalPresentationStyle = .overFullScreen
                currencyPicker.arrayOfCountry = self.arrayOfCountryDetail
                currencyPicker.objSearchType = .City
                currencyPicker.isCityFreeSearch = true
                currencyPicker.countryID = "\(self.countryDetail!.countryID)"
                self.present(currencyPicker, animated: false, completion: nil)
            }
        }

    }
    @IBAction func buttonLocationSelector(sender:UIButton){
        if let _ = self.countryDetail{
            self.pushToAllExperienceMap(locationID:"\(self.countryDetail!.locationID)")
        }
//        if let mapAllExperience = self.storyboard?.instantiateViewController(withIdentifier:"DirectReplyViewController") as? DirectReplyViewController {
//            self.navigationController?.pushViewController(mapAllExperience, animated: false)
//        }
    }
    @IBAction func buttonCountrySelectionAction(selector:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func retryBtnPressed(_ sender: Any) {
        guard CommonClass.shared.isConnectedToInternet else{
            self.noInternetConnectionView.isHidden = false
            self.tableviewDiscover.isHidden = true
            return
        }
        self.tableviewDiscover.isHidden = false
        DispatchQueue.main.async {
            self.viewDidLoad()
        }
    }

    @IBAction func buttonCitySelector(selector:UIBarButtonItem){
        guard self.arrayOfCountryDetail.count >= selectedCityTag else{
            return
        }
        self.textCurrentCity.resignFirstResponder()
        self.setCityDetailWith(countryDetail: self.arrayOfCountryDetail[selectedCityTag])
    }
    @IBAction func buttonCityCancelSelector(selector:UIBarButtonItem){
        self.textCurrentCity.resignFirstResponder()
    }
    @IBAction func buttonFilterSelector(sender:UIButton){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            return
        }
        self.presentfilterViewController()
    }
    @IBAction func buttonShowMoreSelector(sender:UIButton){
        if let _ = self.countryDetail{
            self.getAllExperienceOnLocation(locationID: "\(self.countryDetail!.locationID)")
            DispatchQueue.main.async {
                //self.tableviewDiscover.scrollToBottom(animated: true)
            }
        }
    }
    @IBAction func hideKeyboardSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    @IBAction func buttonFreeSearchSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        self.freeSearchAPIRequest()
    }
    @IBAction func unwindFromFilterViewController(segue: UIStoryboardSegue) {
        if let filterViewController = segue.source as? FilterViewController{
            
            self.filterParameters = filterViewController.filterValue
            if let searchText = self.filterParameters![kFreeTextSeach],"\(searchText)".count > 0{
                DispatchQueue.main.async {
                    self.txtFreeSeach.text = "\(searchText)"
                }
            }else{
                DispatchQueue.main.async {
                    self.txtFreeSeach.text = ""
                }
            }
            DispatchQueue.main.async {
                self.view.endEditing(true)
                let defaultParameter:[String:Any] = ["OnlyFreeChildren": false, "OnlyFreeElderly": false, "Languages": [], "IsInstant": false, "MaxPrice": "0", "OnlyAccessible": false, "FreeTextSearch": "", "OnlyPetFriendly": false,"CollectionIds":[]]
                if NSDictionary.init(dictionary: self.filterParameters!).isEqual(to: defaultParameter){
                    self.isDefaultSearch = true
                }else{
                    self.isDefaultSearch = false
                }
                self.instantPageIndex = 0
                self.isInstantLoadMore = false
                self.arrayOfInstantExperience = []
                self.bestRatedPageIndex = 0
                self.isBesRatedLoadMore = false
                self.arrayOfBestRatedExperience = []
                self.currentPageIndex = 0
                //self.isShowMore = false
                self.arrayOfAllExperience = []
                //
                self.getInstantExperienceOnCity(locationID:"\(self.countryDetail?.locationID ?? "1")")
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                    self.tableviewDiscover.delegate = self
                    self.tableviewDiscover.dataSource = self
                    self.tableviewDiscover.reloadData()
                })
               
                
            }
            
//            self.getBestRatedExperienceOnCity(locationID:"\(countryDetail?.locationID ?? "1")")
//            self.getAllExperienceOnLocation(locationID: "\(countryDetail?.locationID ?? "1")")
        }else if let exploreCollectionView = segue.source as? ExploreViewController{
            print(exploreCollectionView)
        }
        defer{
            
        }
    }
    @IBAction func unwindToDiscoverViewController(segue:UIStoryboardSegue){
        
    }
    @IBAction func unwindSearchToDiscoverController(segue:UIStoryboardSegue){
        if let _ = self.countryDetail{
            self.arrayOfCountryDetail = []
            self.getLocationRequestWithCountyID(countryID: "\(self.countryDetail!.countryID)", locationID:"\(self.countryDetail!.locationID)")
            //self.setCityDetailWith(countryDetail: self.countryDetail!)
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func readMorePressedFromGuideDescription(index: Int) {
        let objGuide = self.arrayOfTopRatedGuide[index]
        self.pushToGuideDetailController(objGuide: objGuide)
    }
    
    func presentfilterViewController(){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        if let filterViewController = self.storyboard?.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController{
            filterViewController.filterValue = self.filterParameters
            filterViewController.delegate = self
            if let _ = self.countryDetail{
               filterViewController.countryDetail = self.countryDetail!
            }
             //self.navigationController?.pushViewController(filterViewController, animated: false)
            self.navigationController?.present(filterViewController, animated: true, completion: nil)
        }
    }
//    func presentFreeSearchViewController(){
//        if let freeSearchViewController = self.storyboard?.instantiateViewController(withIdentifier: "FreeSearchViewController") as? FreeSearchViewController{
//            self.navigationController?.present(freeSearchViewController, animated: true, completion: nil)
//        }
//    }
    func presentExploreCollection(objCollection:Collections){
        guard CommonClass.shared.isConnectedToInternet else {
            return
        }
        if let exploreCollection:ExploreViewController = self.storyboard?.instantiateViewController(withIdentifier: "ExploreViewController") as? ExploreViewController{
            exploreCollection.collections = objCollection
//            self.present(UINavigationController.init(rootViewController: exploreCollection), animated: true, completion: nil)
            self.navigationController?.pushViewController(exploreCollection, animated: true)
        }
    }
    func pushToAllExperienceMap(locationID:String){
        if let mapAllExperience = self.storyboard?.instantiateViewController(withIdentifier:"MapAllExperienceViewController") as? MapAllExperienceViewController{
            mapAllExperience.locationID = locationID
            if let _ = self.countryDetail{
                mapAllExperience.objCountyDetail = self.countryDetail
            }
            self.navigationController?.pushViewController(mapAllExperience, animated: true)
        }
    }
    func pushToGuideDetailController(objGuide:Guide){
        guard CommonClass.shared.isConnectedToInternet else {
            return
        }
//        guard User.isUserLoggedIn else {
//            let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"notLogin.title"), message: Vocabulary.getWordFromKey(key:"notLogin.msg"), preferredStyle: .alert)
//            alertController.addAction(UIAlertAction.init(title:"Ok", style: .default, handler: { (_) in
//                self.navigationController?.popToRootViewController(animated: true)
//            }))
//            self.present(alertController, animated: true, completion: nil)
//            return
//        }
        if let guideViewController = self.storyboard?.instantiateViewController(withIdentifier: "GuideDetailViewController") as? GuideDetailViewController{
            guideViewController.objGuideDetail = objGuide
            self.navigationController?.pushViewController(guideViewController, animated: true)
        }
    }
    
    func pushToBookDetailController(objExperience:Experience){
        guard CommonClass.shared.isConnectedToInternet else {
            return
        }
//        guard User.isUserLoggedIn else {
//            let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"notLogin.title"), message: Vocabulary.getWordFromKey(key:"notLogin.msg"), preferredStyle: .alert)
//            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (_) in
//                self.navigationController?.popToRootViewController(animated: true)
//            }))
//            self.present(alertController, animated: true, completion: nil)
//            return
//        }
        let storyboard = UIStoryboard(name: "BooknowDetailSB", bundle: nil)
        if let bookDetailcontroller = storyboard.instantiateViewController(withIdentifier: "BookDetailViewController") as? BookDetailViewController {
            bookDetailcontroller.bookDetailArr = objExperience
            self.navigationController?.pushViewController(bookDetailcontroller, animated: true)
        }
    }
    func pushToWhereToNextViewController(){
        if let whereToNextViewController:WhereToNextViewController = self.storyboard?.instantiateViewController(withIdentifier: "WhereToNextViewController") as? WhereToNextViewController{
            self.navigationController?.pushViewController(whereToNextViewController, animated: true)
        }
    }
    func pushToAllGuideViewController(){
        if let allGuideViewController:AllGuideViewController = self.storyboard?.instantiateViewController(withIdentifier: "AllGuideViewController") as? AllGuideViewController{
            if let _ = self.countryDetail{
                allGuideViewController.locationID = self.countryDetail!.locationID
            }
            self.navigationController?.pushViewController(allGuideViewController, animated: true)
        }
    }
}
extension DiscoverViewController:FilterDelegate{
    func buttonAppply() {
        DispatchQueue.main.async {
            self.tableviewDiscover.reloadData()
            self.tableviewDiscover.layoutIfNeeded()
        }
    }
}
extension DiscoverViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRow:Int = 0
        if self.arrayOfBestRatedExperience.count > 0{
            numberOfRow += 1
        }
        if self.arrayOfInstantExperience.count > 0{
            numberOfRow += 1
        }
        if self.arrayOfExploreCollection.count > 0{
            numberOfRow += 1
        }
        if self.arrayOfTopRatedGuide.count > 0{
            numberOfRow += 1
        }
        if self.arrayOfAllExperience.count > 0{
            numberOfRow += 1
        }
        let rowCount = (self.isNoDataOnFreeSearch) ? 0 : self.arrayOfRowsSection.count-1
        DispatchQueue.main.async {

        if rowCount > 0 ,numberOfRow > 0{
            tableView.removeMessageLabel()
        }else{
            if !self.isDefaultSearch{
                
tableView.showMessageLabel(msg:Vocabulary.getWordFromKey(key:"NoSearchResult") , backgroundColor: .clear)
            }else {
                tableView.removeMessageLabel()
            }
            }}
        
        return rowCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
/*
        guard self.arrayOfRowsSection.count != indexPath.row+1 else {
            let allExperienceCell:AllExperienceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AllExperienceTableViewCell", for: indexPath) as! AllExperienceTableViewCell
            allExperienceCell.lblExperienceTitle.text = "\(self.arrayOfExperienceTitle[indexPath.row])"
            allExperienceCell.collectionExperience.tag = indexPath.row + defaultListingTag//0 for instant 1 for best rated 2 for explore collection 3 top rated 4 all experience
//            if indexPath.row == 0{
//                allExperienceCell.collectionExperience.tag = 101
//            }else if indexPath.row == 1{
//                allExperienceCell.collectionExperience.tag = 100
//            }
            allExperienceCell.collectionExperience.delegate = nil
            allExperienceCell.collectionExperience.dataSource = nil
            
            allExperienceCell.selectionStyle = .none
            DispatchQueue.main.async {
//                allExperienceCell.setNeedsUpdateConstraints()
//                allExperienceCell.updateConstraintsIfNeeded()
                allExperienceCell.collectionExperience.collectionViewLayout.invalidateLayout()
                //allExperienceCell.collectionExperience.layoutIfNeeded()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    
                    allExperienceCell.collectionExperience.delegate = self
                    allExperienceCell.collectionExperience.dataSource = self
                    allExperienceCell.collectionExperience.reloadWithoutAnimation()
                   

                }
               // allExperienceCell.collectionExperience.layoutSubviews()
            }
            return allExperienceCell
        }*/
        let experienceCell:ExperienceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ExperienceTableViewCell", for: indexPath) as! ExperienceTableViewCell
        
        guard self.arrayOfRowsSection.count > indexPath.row,self.arrayOfExperienceTitle.count > indexPath.row,self.arrayOfExperienceDiscription.count > indexPath.row else {
            return experienceCell
        }
        experienceCell.lblExperienceTitle.text = "\(self.arrayOfExperienceTitle[indexPath.row])"
        experienceCell.delegateTableViewCell = self
        /*
        if indexPath.row == 0{
            let strAttributedStrign = NSAttributedString.init(string: "\(self.arrayOfExperienceDiscription[indexPath.row])", attributes:  [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
            if self.arrayOfInstantExperience.count > 0{
                experienceCell.lblExperienceDiscription.attributedText = strAttributedStrign
            }else{
                experienceCell.lblExperienceDiscription.text = "\(self.arrayOfExperienceDiscription[indexPath.row])"
            }
        }else{
            experienceCell.lblExperienceDiscription.text = "\(self.arrayOfExperienceDiscription[indexPath.row])"
        }*/
        experienceCell.lblExperienceDiscription.text = "\(self.arrayOfExperienceDiscription[indexPath.row])"
        experienceCell.collectionExperience.tag = indexPath.row + defaultListingTag//0 for instant 1 for best rated 2 for explore collection 3 top rated 4 all experience
//        if indexPath.row == 0{
//            experienceCell.collectionExperience.tag = 101
//        }else if indexPath.row == 1{
//            experienceCell.collectionExperience.tag = 100
//        }
        experienceCell.collectionExperience.delegate = nil
        experienceCell.collectionExperience.dataSource = nil
        
        experienceCell.selectionStyle = .none
        DispatchQueue.main.async {
            experienceCell.collectionExperience.collectionViewLayout.invalidateLayout()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                experienceCell.collectionExperience.delegate = self
                experienceCell.collectionExperience.dataSource = self
                experienceCell.collectionExperience.reloadData()
            }
             //experienceCell.collectionExperience.layoutSubviews()
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            if experienceCell.collectionExperience.tag == 103{
                    let attributedString = NSMutableAttributedString(string:"See all guides", attributes: [NSAttributedStringKey.underlineStyle : true,NSAttributedStringKey.foregroundColor:UIColor.init(hexString: "36527D")])
                    experienceCell.buttonSeeAllGuide.setAttributedTitle(attributedString, for: .normal)
                    experienceCell.buttonSeeAllGuide.isHidden = false
            }else{
                experienceCell.buttonSeeAllGuide.setTitle("", for: .normal)
                experienceCell.buttonSeeAllGuide.isHidden = true
            }
            })
        
        return experienceCell
        
    }

//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0
//    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return 0.0
        return self.getExperienceTableViewHeight(indexPath: indexPath)
    }
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        var tableViewFooterHeight:CGFloat = 0.0
//        if self.currentPageIndex == 0 || self.currentPageIndex == 1{
//            tableViewFooterHeight = self.getAllExperienceTableViewHeight()
//        }else{
//            tableViewFooterHeight = self.collectionAllExperience.contentSize.height+120.0
//        }
//        return tableViewFooterHeight
//    }
    func getExperienceTableViewHeight(indexPath:IndexPath)->CGFloat{
        if defaultListingTag  == 100 {
            if indexPath.row == 0,self.arrayOfBestRatedExperience.count > 0{ //Instant
                return self.tableviewExperienceRowHeight
            }else if indexPath.row == 1,self.arrayOfInstantExperience.count > 0{ //Best Rated
                return self.tableviewExperienceRowHeight
            }else if indexPath.row == 2,self.arrayOfExploreCollection.count > 0{ //Explore Collection
                return self.tableViewExploreCollectionRowHeight
            }else if indexPath.row == 3,self.arrayOfTopRatedGuide.count > 0{ //Top rated guides
                return self.tableViewTopRatedGuideHeight
            }else if indexPath.row == 4 ,self.arrayOfAllExperience.count > 0{ //All experience
                return self.getAllExperienceTableViewHeight()//UITableViewAutomaticDimension
                    //(self.arrayOfAllExperience.count == 1) ? self.tableviewExperienceRowHeight:self.getAllExperienceTableViewHeight()  //self.tableviewExperienceRowHeight//
            }else{
                return 0.0
            }
        }else {
            if indexPath.row == 0,self.arrayOfBestRatedExperience.count > 0{ //Best Rated
                return self.tableviewExperienceRowHeight
            }else if indexPath.row == 1,self.arrayOfExploreCollection.count > 0{ //Explore Collection
                return self.tableViewExploreCollectionRowHeight
            }else if indexPath.row == 2,self.arrayOfTopRatedGuide.count > 0{ //Top rated guides
                return self.tableViewTopRatedGuideHeight
            }else if indexPath.row == 3,self.arrayOfAllExperience.count > 0{ //All experience
                return self.getAllExperienceTableViewHeight()//UITableViewAutomaticDimension
                    //(self.arrayOfAllExperience.count == 1) ? self.tableviewExperienceRowHeight:self.getAllExperienceTableViewHeight()  //self.tableviewExperienceRowHeight
            }else{
                return 0.0
            }
        }
    }
}
extension DiscoverViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 101{ //Instant
            if self.arrayOfInstantExperience.count > 0 {
                collectionView.removeMessageLabel()
            }else{
                //collectionView.showMessageLabel(msg: Vocabulary.getWordFromKey(key: "nothingToSee"), backgroundColor: UIColor.clear)
            }
            return self.arrayOfInstantExperience.count
        }else if collectionView.tag == 100{ //Best Rated
            if self.arrayOfBestRatedExperience.count > 0 {
                collectionView.removeMessageLabel()
            }else{
                //collectionView.showMessageLabel()
            }
            return self.arrayOfBestRatedExperience.count
        }else if collectionView.tag == 102{ //Explore collections
            if self.arrayOfExploreCollection.count > 0 {
                collectionView.removeMessageLabel()
            }else{
                //collectionView.showMessageLabel()
            }
            return self.arrayOfExploreCollection.count
        }else if collectionView.tag == 103{ //Top rated guides
            if self.arrayOfTopRatedGuide.count > 0 {
                collectionView.removeMessageLabel()
            }else{
                //collectionView.showMessageLabel()
            }
            return self.arrayOfTopRatedGuide.count
        }else if collectionView.tag == 104{ //All experience
            if self.arrayOfAllExperience.count > 0 {
                collectionView.removeMessageLabel()
            }else{
                //collectionView.showMessageLabel()
            }
            return self.arrayOfAllExperience.count
        }else{
            collectionView.removeMessageLabel()
            return 0
        }
    }
    
    func showCaseDidDismiss(showcase: MaterialShowcase) {
        //do what you want
    }
    
    func showCaseWillDismiss(showcase: MaterialShowcase) {
        //do what you want
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 100 || collectionView.tag == 101 || collectionView.tag == 104{
            let experienceCell:ExperienceCollectionViewCell =  collectionView.dequeueReusableCell(withReuseIdentifier: "ExperienceCollectionViewCell", for: indexPath) as! ExperienceCollectionViewCell//Instant //BestRated //All experience
            experienceCell.circularView.isHidden = true
            experienceCell.payContainerView.isHidden = true
            experienceCell.payBtn.isHidden = true
            var objectExperience:Experience?
            if collectionView.tag == 101{ //Instant
                if self.arrayOfInstantExperience.count > indexPath.item{
                    objectExperience = self.arrayOfInstantExperience[indexPath.item]
                    if indexPath.item == (self.arrayOfInstantExperience.count - 1) , self.isInstantLoadMore{ //last index
                        //if (self.arrayOfInstantExperience.count > collectionView.visibleCells.count) {
                            DispatchQueue.global(qos: .background).async {
                                self.instantPageIndex += 1
                                self.getInstantExperienceOnCity(locationID:"\(self.countryDetail?.locationID ?? "1")")
                            }
                        //}
                    }
                }
            }else if collectionView.tag == 100{ //BestRated
                if self.arrayOfBestRatedExperience.count > indexPath.item{
                    objectExperience = self.arrayOfBestRatedExperience[indexPath.item]
                    if indexPath.item == (self.arrayOfBestRatedExperience.count - 1) , self.isBesRatedLoadMore{ //last index
                        //if (self.arrayOfBestRatedExperience.count < collectionView.visibleCells.count) {
                            DispatchQueue.global(qos: .background).async {
                                self.bestRatedPageIndex += 1
                                self.getBestRatedExperienceOnCity(locationID:"\(self.countryDetail?.locationID ?? "1")")
                            }
                        //}
                    }
                }
            }else if collectionView.tag == 104 { //All Experience
                if self.arrayOfAllExperience.count > indexPath.item{
                    objectExperience = self.arrayOfAllExperience[indexPath.item]
                }
            }
            if let _ = objectExperience{
                experienceCell.lblExperienceDisc.text = "\(objectExperience!.title)"

                experienceCell.lblExperienceCurrency.text = "\(objectExperience!.currency) \(self.isPricePerPerson(objExperience: objectExperience!) ? objectExperience!.priceperson : objectExperience!.groupPrice)"
                 experienceCell.loadImage(url: objectExperience!.smallmainImage)
                experienceCell.ratingView.rating = (objectExperience!.averageReview.count > 0) ? Double(objectExperience!.averageReview)! : 0.0
                experienceCell.lblMinimumPrice.text = self.getMinimumPriceHint(objExperience: objectExperience!)
                if Bool.init(objectExperience!.isWished){
                       experienceCell.btnAddToLike.setBackgroundImage(#imageLiteral(resourceName: "fillFavourite"), for: .normal)
                } else {
                   let favouriteBtnImg = #imageLiteral(resourceName: "FavouriteBtn").withRenderingMode(.alwaysTemplate)
                   experienceCell.btnAddToLike.setBackgroundImage(favouriteBtnImg, for: .normal)
                }
                experienceCell.btnAddToLike.tintColor = UIColor.white
            }
            experienceCell.btnAddToLike.isHidden = !User.isUserLoggedIn
            experienceCell.viewContainerForShareAndLike.isHidden = false
            experienceCell.btnShare.accessibilityValue = "\(collectionView.tag)"
            experienceCell.btnAddToLike.accessibilityValue = "\(collectionView.tag)"
            experienceCell.btnShare.tag = indexPath.item
            experienceCell.btnAddToLike.tag = indexPath.item
            experienceCell.delegate = self
            return experienceCell
        }else if collectionView.tag == 102{ //Explore Collection
            let exploreCell:ExploreCollectionViewCell =  collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreCollectionViewCell", for: indexPath) as! ExploreCollectionViewCell//Explore
            exploreCell.contentView.layer.cornerRadius = 4.0
            exploreCell.contentView.layer.masksToBounds = true

            if self.arrayOfExploreCollection.count > indexPath.item{
                let objectCollection = self.arrayOfExploreCollection[indexPath.item]
                if let url = URL.init(string: "\(objectCollection.imgaeURL)") {
                    exploreCell.collectionImgView.imageFromServerURL(urlString: objectCollection.imgaeURL)
                  
                    if objectCollection.isVideo { // Play Video
                        DispatchQueue.main.async {
                            exploreCell.playVideo(url: url)
                        }
                    }else{
                        DispatchQueue.main.async {
                            exploreCell.playerView.isHidden = true
                            exploreCell.playerLayer?.removeFromSuperlayer()
                            exploreCell.collectionImgView.imageFromServerURL(urlString: objectCollection.imgaeURL)
                        }
                    }
                } else { // Image
                    exploreCell.playerLayer?.removeFromSuperlayer()
                    exploreCell.playerView.isHidden = true
                    exploreCell.collectionImgView.image = #imageLiteral(resourceName: "expriencePlaceholder")
                }
                exploreCell.lblCollectionName.text = "\(objectCollection.title)"
               
                return exploreCell
            }
        } else if collectionView.tag == 103{ //Top rated guides
            let guideCell:GuideCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuideCollectionViewCell", for: indexPath) as! GuideCollectionViewCell
            if  self.arrayOfTopRatedGuide.count > indexPath.item{
                let objectGuide = self.arrayOfTopRatedGuide[indexPath.item]
                if objectGuide.image.count > 0 {
                   // DispatchQueue.main.async {
                        guideCell.guideImage.imageFromServerURL(urlString:"\(objectGuide.image)",placeHolder:UIImage.init(named:"ic_profile")!)
                   // }
                }else{
                    guideCell.guideImage.image = UIImage.init(named:"ic_profile")
                }
                guideCell.delegate = self
                guideCell.guideIndexNumber = indexPath.item
                guideCell.guideImage.contentMode = .scaleAspectFill
                guideCell.lblGuideName.text = "\(objectGuide.firstName) \(objectGuide.lastName)"
                guideCell.guideImage.contentMode = .scaleAspectFill
                guideCell.guideImage.clipsToBounds = true
                guideCell.lblGuideName.text = "\(objectGuide.firstName) \(objectGuide.lastName)"
                guideCell.txtGuideDiscription.tag = indexPath.item
                guideCell.guideRating.rating = (objectGuide.averageReview.count > 0) ? Double(objectGuide.averageReview)! : 0.0
                
                let attributedString = NSMutableAttributedString(string: "\(objectGuide.comment)", attributes: [NSAttributedStringKey.font: UIFont.init(name: "Avenir-Roman", size: 14.0) as Any])
                guideCell.txtGuideDiscription.text = "\(objectGuide.comment)"
                if attributedString.string.count > 150 {
                    //self.guideDetailTxtView.text = self.topGuideDetailData!.comment
                   guideCell.txtGuideDiscription.textContainer.maximumNumberOfLines = 5
                    let readmoreFont = UIFont(name: "Avenir-Roman", size: 12.0)
                    guideCell.txtGuideDiscription.isUserInteractionEnabled = false
                    let readmoreFontColor = UIColor(red: 56.0/255.0, green: 114.0/255.0, blue: 170.0/255.0, alpha: 1.0)
                    let readMoreAttriString = NSAttributedString(string:"... read more", attributes:
                        [NSAttributedStringKey.foregroundColor: readmoreFontColor,
                         NSAttributedStringKey.font: readmoreFont!])
                    DispatchQueue.main.async {
                        //                self.guideDetail.shouldTrim = true
                        //                self.guideDetail.maximumNumberOfLines = 4
                        //                self.guideDetail.attributedReadMoreText = readMoreAttriString
                        
                        guideCell.txtGuideDiscription.shouldTrim = true
                        guideCell.txtGuideDiscription.maximumNumberOfLines = 4
                        guideCell.txtGuideDiscription.attributedReadMoreText = readMoreAttriString
                    }
                  
                    DispatchQueue.main.async {
                        //                  self.guideDetailTxtView.addTrailing(with: "... ", moreText: "read more", moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor, characterLimit: 188, isFromGuideDescription: false)
                    }
                } else {
                     guideCell.txtGuideDiscription.textContainer.maximumNumberOfLines = 0
                }
//                let myParagraphStyle = NSMutableParagraphStyle()
//                myParagraphStyle.alignment = .center // center the text
//                myParagraphStyle.paragraphSpacing = 38 //Change space between paragraphs
//                attributedString.addAttributes([.paragraphStyle: myParagraphStyle], range: NSRange(location: 0, length: attributedString.length))

                //guideCell.setReadMore(guideComment: attributedString, comment: "\(objectGuide.comment)")
            }
            
            return guideCell
        }
        return UICollectionViewCell()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            print(" you reached end of the table")
            
        }
//        if self.tableviewDiscover.contentOffset.y >= (self.tableviewDiscover.contentSize.height - self.tableviewDiscover.frame.size.height) {
//            if self.isShowMore{ //last index
//                //if collectionView.indexPathsForVisibleItems.contains(indexPath){
//                //}
//                //if (self.arrayOfAllExperience.count > collectionView.visibleCells.count) {
//                DispatchQueue.global(qos: .background).async {
//                    //self.currentPageIndex += 1
//                    self.isShowMore = false
//                    self.getAllExperienceOnLocation(locationID:"\(self.countryDetail?.locationID ?? "1")")
//                }
//            //you reached end of the table
//            }}
    }
    func getMinimumPriceHint(objExperience:Experience)->String{
        if self.isPricePerPerson(objExperience: objExperience){
            return "(\(Vocabulary.getWordFromKey(key: "priceperperson")))"
        }else{
            return  "(\(Vocabulary.getWordFromKey(key: "pricepergroup")))"
        }
    }
    func isPricePerPerson(objExperience:Experience)->Bool{
        guard objExperience.priceperson.count > 0 else {
            return false//"(\(Vocabulary.getWordFromKey(key: "pricepergroup")))" //group
        }
        guard objExperience.groupPrice.count > 0 else {
            return true//"(\(Vocabulary.getWordFromKey(key: "priceperperson")))" //person
        }
        if Int(objExperience.groupPrice) ?? 0 > Int(objExperience.priceperson) ?? 0{
            return false//true//"(\(Vocabulary.getWordFromKey(key: "priceperperson")))" //person
        }else{
            return true//false//"(\(Vocabulary.getWordFromKey(key: "pricepergroup")))"
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        if self.isCollectionViewShown(collectionView: collectionView){
            if collectionView.tag == 103{ // Guide
                return CGSize.init(width: 240.0, height: collectionView.bounds.height)
            }else if collectionView.tag == 104{ // All Experience
//                if self.arrayOfAllExperience.count == 1 {
//                    return CGSize.init(width: 261.0, height: 300)
//                }else{
//
//                }
                let height = collectionView.bounds.size.width*0.5+80
                return CGSize.init(width: collectionView.bounds.size.width*0.5-27, height: height)
            }else if collectionView.tag == 102{ //Explore Collection
                return CGSize.init(width: 150, height: collectionView.bounds.height)
            }else{
                return CGSize.init(width: 261.0, height: collectionView.bounds.height)
            }
        }else{
             return CGSize.zero//CGSize.init(width: 261.0, height: 300)
        }
    }
    func getCenterCellForOneRecord()->CGFloat{
        return (UIScreen.main.bounds.width - 261.0)/2.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        if self.isCollectionViewShown(collectionView: collectionView){
            if collectionView.tag == 101 {       //Instant
                if self.arrayOfInstantExperience.count == 1{
                     return UIEdgeInsetsMake(0, self.getCenterCellForOneRecord(), 0, 0)
                }else{
                    return UIEdgeInsetsMake(0, 20.0, 0, 20)
                }
            }else if collectionView.tag == 100{  //Best rated
                if self.arrayOfBestRatedExperience.count == 1 {
                     return UIEdgeInsetsMake(0, self.getCenterCellForOneRecord(), 0, 0)
                }else{
                    return UIEdgeInsetsMake(0, 20.0, 0, 20)
                }
            }else if collectionView.tag == 104{  //All experience
//                if self.arrayOfAllExperience.count == 1 {
//                     return UIEdgeInsetsMake(0, 0, 0, 0)
//                }else{
//
//                    //return UIEdgeInsetsMake(0, 20.0, 0, 0)
//                }
                return UIEdgeInsets.init(top: 20, left: 20, bottom: 0, right: 20)
            }
            return UIEdgeInsetsMake(0, 20.0, 0, 10)
        }else{
            return UIEdgeInsets.zero
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        if self.isCollectionViewShown(collectionView: collectionView){
            return 15.0
        }else{
            return 0.0
        }
    }
    func isCollectionViewShown(collectionView: UICollectionView)->Bool {
        if collectionView.tag == 101 {       //Instant
            guard self.arrayOfInstantExperience.count > 0 else{
                return false
            }
            return true
        }else if collectionView.tag == 100{  //Best rated
            guard self.arrayOfBestRatedExperience.count > 0 else{
                return false
            }
            return true
        }else if collectionView.tag == 102{  //Explore collection
            guard self.arrayOfExploreCollection.count > 0 else{
                return false
            }
            return true
        }else if collectionView.tag == 103{  //Top rated guide
            guard self.arrayOfTopRatedGuide.count > 0 else{
                return false
            }
            return true
        }else if collectionView.tag == 104{  //All experience
            guard self.arrayOfAllExperience.count > 0 else{
                return false
            }
            return true
        }else{
            return false
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 101 {       //Instant
            guard self.arrayOfInstantExperience.count > indexPath.item else{
                return
            }
            let objExperience = self.arrayOfInstantExperience[indexPath.item]
            self.pushToBookDetailController(objExperience: objExperience)
        }else if collectionView.tag == 100{  //Best rated
            guard self.arrayOfBestRatedExperience.count > indexPath.item else{
                return
            }
            let objExperience = self.arrayOfBestRatedExperience[indexPath.item]
            self.pushToBookDetailController(objExperience: objExperience)
        }else if collectionView.tag == 102{  //Explore collection
            if self.arrayOfExploreCollection.count > indexPath.item{
                let objCollection:Collections = self.arrayOfExploreCollection[indexPath.item]
                //Present Explore Collection
                self.presentExploreCollection(objCollection: objCollection)
            }
        }else if collectionView.tag == 103{  //Top rated guide
            if self.arrayOfTopRatedGuide.count > indexPath.item{
                let objGuide = self.arrayOfTopRatedGuide[indexPath.item]
                //PushToGuide Detail
                self.pushToGuideDetailController(objGuide: objGuide)
            }
        }else if collectionView.tag == 104{  //All experience
            guard self.arrayOfAllExperience.count > indexPath.item else{
                return
            }
            let objExperience = self.arrayOfAllExperience[indexPath.item]
            self.pushToBookDetailController(objExperience: objExperience)
        }
    }

}
extension DiscoverViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.arrayOfCountryDetail[row].defaultCity
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 150.0
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.arrayOfCountryDetail.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedCityTag = row
        self.cityPickerView.selectRow(row, inComponent: component, animated: true)
    }
}
extension DiscoverViewController:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.filterParameters![kFreeTextSeach] = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.filterParameters![kFreeTextSeach] = ""
        textField.resignFirstResponder()
        self.freeSearchAPIRequest()
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.freeSearchAPIRequest()
        textField.resignFirstResponder()
        return true
    }
}
extension UICollectionView {
    func reloadWithoutAnimation(){
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.reloadData()
        CATransaction.commit()
    }
}
extension UITableView {
    
    func scrollToBottom(){
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections - 1) - 1,
                section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func scrollToTop() {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}
extension DiscoverViewController: MaterialShowcaseDelegate {
    func showCaseWillDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
        kUserDefault.set(true, forKey: kShowCaseForLocationButton)
    }
    func showCaseDidDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
    }
}
extension DiscoverViewController:ExperienceTableViewCellDelegate{
    func seeAllGuideSelector() {
        self.pushToAllGuideViewController()
    }
}
extension DiscoverViewController:ExperienceDelegate{
    func didSelectLikeExperienceSelector(sender: UIButton) {
        if let _ = sender.accessibilityValue{
            if let collectionTag = Int(sender.accessibilityValue!){
                
                if collectionTag == 101 {       //Instant
                    guard self.arrayOfInstantExperience.count > sender.tag else{
                        return
                    }
                    let objExperience = self.arrayOfInstantExperience[sender.tag]
                    self.likeUnlikeExperienceWith(objExperience: objExperience,tag:collectionTag)
                }else if collectionTag == 100{  //Best rated
                    guard self.arrayOfBestRatedExperience.count > sender.tag else{
                        return
                    }
                    let objExperience = self.arrayOfBestRatedExperience[sender.tag]
                    self.likeUnlikeExperienceWith(objExperience: objExperience,tag:collectionTag)
                }else if collectionTag == 104{  //All experience
                    guard self.arrayOfAllExperience.count > sender.tag else{
                        return
                    }
                    let objExperience = self.arrayOfAllExperience[sender.tag]
                    self.likeUnlikeExperienceWith(objExperience: objExperience,tag:collectionTag)
                }
                
            }
        }
    }
    func likeUnlikeExperienceWith(objExperience:Experience,tag:Int){
        var userID:String = "0"
        if User.isUserLoggedIn{
            userID = User.getUserFromUserDefault()!.userID
        }
        self.favouriteFunctionality(userID: userID, objExperience: objExperience,tag:tag)
        
    }
    func didSelectShareExperienceSelector(sender: UIButton) {
        if let _ = sender.accessibilityValue{
            if let collectionTag = Int(sender.accessibilityValue!){
                if collectionTag == 101 {       //Instant
                    guard self.arrayOfInstantExperience.count > sender.tag else{
                        return
                    }
                    let objExperience = self.arrayOfInstantExperience[sender.tag]
                    self.shareExpereinceWith(objExperience: objExperience)
                }else if collectionTag == 100{  //Best rated
                    guard self.arrayOfBestRatedExperience.count > sender.tag else{
                        return
                    }
                    let objExperience = self.arrayOfBestRatedExperience[sender.tag]
                    self.shareExpereinceWith(objExperience: objExperience)
                }else if collectionTag == 104{  //All experience
                    guard self.arrayOfAllExperience.count > sender.tag else{
                        return
                    }
                    let objExperience = self.arrayOfAllExperience[sender.tag]
                    self.shareExpereinceWith(objExperience: objExperience)
                }
            }
        }
    }
    func shareExpereinceWith(objExperience:Experience){
        let text: String = objExperience.title
        let imageView: ImageViewForURL = ImageViewForURL(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.imageFromServerURL(urlString: objExperience.mainImage as String)
        
        var sharingURL:String = ""
        sharingURL = objExperience.experienceURL
        
        let myWebsite = NSURL(string:"https://itunes.apple.com/us/app/live-private-guided-tours/id1317979792?ls=1&mt=8")//NSURL(string:"https://itunes.apple.com/us/app/live/id1317979792?ls=1&mt=8")
        var shareAll = [text , imageView.image!] as [Any]
        if sharingURL.count > 0{
            let fbURL = NSURL(string:"\(sharingURL)")
            shareAll.append(fbURL as Any)
        }
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        self.present(activityViewController, animated: true, completion: nil)
    }
}
extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}
