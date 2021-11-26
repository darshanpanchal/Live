//
//  BookDetailViewController.swift
//  Live
//
//  Created by ips on 16/04/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import FacebookCore
import ReadMoreTextView

let bookNowBtnColor = UIColor(red: 139/255, green: 155/255, blue: 206/255, alpha: 0.8)
let kExperience = "experience"

class BookDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomCellUpdater, openImgaeFromSelectionofPageControl, CLLocationManagerDelegate, GMSMapViewDelegate, ReviewCellUpdater, reloadMap, readMoreEvent ,UIGestureRecognizerDelegate{
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var bookNowBtnLeadingConstant: NSLayoutConstraint!
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet var lblBooking:UILabel!
    @IBOutlet var btnBack:UIButton!
    @IBOutlet weak var bookNowBtn: UIButton!
    @IBOutlet weak var favouriteBtn: UIButton!
    @IBOutlet weak var navTopConstant: NSLayoutConstraint!
    @IBOutlet weak var navHeightConstant: NSLayoutConstraint!
    @IBOutlet var navView:UIView!
    var bookDetailArr:Experience?
    var videoObj: [Video] = []
    var occurrences: [Occurrences] = []
    var occurTime: [String] = []
    var guideDic: GuideForBooking?
    var locationDic: Location?
    var languageObj: [Language] = []
    var reviewsObj: [Review] = []
    var languageArr: [String] = []
    var imgArr: [NSString] = []
    var experienceId: String = ""
    var videoArr: [NSString] = []
    var imageForShare: UIImage?
    //    @IBOutlet weak var bookNowBtnLeadingConstant: NSLayoutConstraint!
    //    @IBOutlet weak var bookNowBtnTrailingConstant: NSLayoutConstraint!
    var readMoreButtonClicked: Bool = false
    var headerCellHeight = UIScreen.main.bounds.size.height > 568.0 ? 350.0 : 300.0
    var instantOccurence:Occurrences?
    var imageObj: [Images] = []
    var accessbilityArr: [String] = []
    var instant:Bool = false
    var mediaDic = [String:[String]]()
    var mainVideoUrl: [NSString] = []
    var reviewSeeMoreSet = Set<Int>()
    var instantBookingSlot:Slot?
    var placeDiscription: String?
    var currentLat: String = ""
    var currentLong: String = ""
    var isShowMore:Bool = false
    @IBOutlet weak var instantBookingBtn: UIButton!
    var isSeeMoreProfile:Bool = false
    var isWish:Bool = false
    var reviewLblHeight: CGFloat = 0.0
    let locationManager = CLLocationManager()
    var isInstantBooking:Bool{
        get{
            return instant
        }
        set{
            instant = newValue
            self.configureInstanBooking()
        }
    }
    var tableViewReviewHeight:CGFloat = 320.0
     var arrayOfPreview:[NSString] = []
    override func viewDidLoad() {
        isFromAddExperience = false
        super.viewDidLoad()
       
        self.lblBooking.isHidden = true
        self.bookNowBtn.setTitle(Vocabulary.getWordFromKey(key: "preview.hint"), for: .normal)
        //        self.instantBookingBtn.setTitle(Vocabulary.getWordFromKey(key: "Instant"), for: .normal)
        //        self.instantBookingBtn.layer.borderColor = UIColor.red.cgColor
        //        self.instantBookingBtn.layer.borderWidth = 1.2
        self.detailTableView.rowHeight = UITableViewAutomaticDimension
        self.detailTableView.estimatedRowHeight = 300.0
        self.bookNowBtn.setBackgroundColor(color: UIColor.black.withAlphaComponent(0.5), forState: .highlighted)
      let currentUser = User.getUserFromUserDefault()
        if self.view.bounds.height > 811 {
            self.navTopConstant.constant = 0.0
            self.navHeightConstant.constant = 88.0
//            self.topConstantOfNavView.constant = -44.0
        } else {
            self.navTopConstant.constant = 0.0
            self.navHeightConstant.constant = 64.0
//            self.topConstantOfNavView.constant = -20.0
        }
        if User.isUserLoggedIn {
            self.getBookingDetails(userID: (currentUser?.userID)!)
            //self.favouriteBtn.isHidden = false
        } else {
            self.getBookingDetails(userID: "0")
            //self.favouriteBtn.isHidden = true
        }
        // Location Set Up
        
        //        // Register Cells
//                self.registerCustomCells()
        
        // Get Booking Details
        
        // Do any additional setup after loading the view.
      
    }
    func swipeToPop() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.view.bounds.height > 811 { // iPhone X
            if self.detailTableView.contentOffset.y == -44.0 {
                DispatchQueue.main.async {
                    UIApplication.shared.statusBarStyle = .lightContent
                    self.navView.backgroundColor = UIColor.clear
                    self.lblBooking.isHidden = true
                    self.lblBooking.textColor = UIColor.black
                    let backBtnImg = #imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate)
                    self.btnBack.setImage(backBtnImg, for: .normal)
                    self.btnBack.tintColor = UIColor.white
                    let favouriteBtnImg = #imageLiteral(resourceName: "updatedFavouriteImg").withRenderingMode(.alwaysTemplate)
                    self.favouriteBtn.setImage(favouriteBtnImg, for: .normal)
                    self.favouriteBtn.tintColor = UIColor.white
                    let shareImg = #imageLiteral(resourceName: "updatedShareBtnImg").withRenderingMode(.alwaysTemplate)
                    self.shareButton.setImage(shareImg, for: .normal)
                    self.shareButton.tintColor = UIColor.white
                }
            } else {
                DispatchQueue.main.async {
                    self.customiseNavigationView()
                }
            }
        } else {
            if self.detailTableView.contentOffset.y == -20.0 {
                DispatchQueue.main.async {
                    UIApplication.shared.statusBarStyle = .lightContent
                    self.navView.backgroundColor = UIColor.clear
                    self.lblBooking.isHidden = true
//                    self.lblBooking.textColor = UIColor.white
                    let backBtnImg = #imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate)
                    self.btnBack.setImage(backBtnImg, for: .normal)
                    self.btnBack.tintColor = UIColor.white
                }
            } else {
                DispatchQueue.main.async {
                    self.customiseNavigationView()
                }
            }
        }
    }
    
    func customiseNavigationView() {
        UIApplication.shared.statusBarStyle = .default
        self.navView.backgroundColor = UIColor.white
        self.lblBooking.isHidden = false
        self.lblBooking.textColor = UIColor.black
        let backBtnImg = #imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate)
        self.btnBack.setImage(backBtnImg, for: .normal)
        self.btnBack.tintColor = UIColor.black
        let favouriteImg = #imageLiteral(resourceName: "updatedFavouriteImg").withRenderingMode(.alwaysTemplate)
        self.favouriteBtn.setImage(favouriteImg, for: .normal)
        self.favouriteBtn.tintColor = UIColor.black
        let shareImg = #imageLiteral(resourceName: "updatedShareBtnImg").withRenderingMode(.alwaysTemplate)
        self.shareButton.setImage(shareImg, for: .normal)
        self.shareButton.tintColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.setStatusBarStyle()
            self.addDynamicFont()
            self.swipeToPop()
        }
    }
    func setStatusBarStyle(){
        if self.view.bounds.height > 811 { // iPhone X
            if self.detailTableView.contentOffset.y == -44.0 {
                DispatchQueue.main.async {
                    UIApplication.shared.statusBarStyle = .lightContent
                    self.navView.backgroundColor = UIColor.clear
                    self.lblBooking.isHidden = true
                    self.lblBooking.textColor = UIColor.black
                    let backBtnImg = #imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate)
                    self.btnBack.setImage(backBtnImg, for: .normal)
                    self.btnBack.tintColor = UIColor.white
                    let favouriteBtnImg = #imageLiteral(resourceName: "updatedFavouriteImg").withRenderingMode(.alwaysTemplate)
                    self.favouriteBtn.setImage(favouriteBtnImg, for: .normal)
                    self.favouriteBtn.tintColor = UIColor.white
                    let shareImg = #imageLiteral(resourceName: "updatedShareBtnImg").withRenderingMode(.alwaysTemplate)
                    self.shareButton.setImage(shareImg, for: .normal)
                    self.shareButton.tintColor = UIColor.white
                }
            } else {
                DispatchQueue.main.async {
                    self.customiseNavigationView()
                }
            }
        } else {
            if self.detailTableView.contentOffset.y == -20.0 {
                DispatchQueue.main.async {
                    UIApplication.shared.statusBarStyle = .lightContent
                    self.navView.backgroundColor = UIColor.clear
                    self.lblBooking.isHidden = true
                    //                    self.lblBooking.textColor = UIColor.white
                    let backBtnImg = #imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate)
                    self.btnBack.setImage(backBtnImg, for: .normal)
                    self.btnBack.tintColor = UIColor.white
                }
            } else {
                DispatchQueue.main.async {
                    self.customiseNavigationView()
                }
            }
        }
    }
    func addDynamicFont(){
        self.bookNowBtn.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.bookNowBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        self.bookNowBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //        self.instantBookingBtn.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        //        self.instantBookingBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        //        self.instantBookingBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    func registerCustomCells() {
        self.detailTableView.delegate = self
        self.detailTableView.dataSource = self
        self.detailTableView.allowsSelection = false
        
        let nib = UINib.init(nibName: "BookingDetailRateandTimeTableViewCell", bundle: nil)
        self.detailTableView.register(nib, forCellReuseIdentifier: "BookingDetailRateandTimeTableViewCell")
        let nibProfile = UINib.init(nibName: "BookingDetailProfileTableViewCell", bundle: nil)
        self.detailTableView.register(nibProfile, forCellReuseIdentifier: "BookingDetailProfileTableViewCell")
        let nibAddress = UINib.init(nibName: "BookingDetailAddressTableViewCell", bundle: nil)
        self.detailTableView.register(nibAddress, forCellReuseIdentifier: "BookingDetailAddressTableViewCell")
        let nibHeaderCell = UINib.init(nibName: "BookDetailHeaderCell", bundle: nil)
        self.detailTableView.register(nibHeaderCell, forCellReuseIdentifier: "BookDetailHeaderCell")
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        DispatchQueue.main.async {
            self.detailTableView.isScrollEnabled = true
            self.detailTableView.reloadData()
        }
        ProgressHud.hide()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopUpdatingLocation()
    }
    // Reload Table Row
    func updateGuideProfileRow() {
        DispatchQueue.main.async {
            self.isSeeMoreProfile = true
            let indexPath = IndexPath(item: 4, section: 0)
            self.detailTableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func reloadReviewCell(tag: Int) {
        let cell = self.detailTableView.dequeueReusableCell(withIdentifier: "ReviewsTableViewCell") as! ReviewsTableViewCell
        let text = self.reviewsObj[tag].comment
        let temp1: CGFloat = text.heightWithConstrainedWidth(width: cell.frame.size.width, font: UIFont(name: "Avenir Book", size: 14.0)!)
        if reviewLblHeight > temp1 {
        } else {
            let additionalHeight: CGFloat = temp1
            self.tableViewReviewHeight += additionalHeight + 100.0
        }
        let indexPath = IndexPath(item: 6, section: 0)
        self.detailTableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func updateTimeAndRateRow() {
        DispatchQueue.main.async {
            self.isShowMore = true
            let indexPath = IndexPath(item: 1, section: 0)
            self.detailTableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func reloadMapView() {
        let indexPath = IndexPath(item: 5, section: 0)
        if let cell: UITableViewCell = self.detailTableView.cellForRow(at: indexPath){
            if self.detailTableView.visibleCells.contains(cell){
                self.detailTableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    // Navigtion to Full Map Controller
    func navigationClicked() {
        if let mapViewController = kBookingStoryBoard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController {
            mapViewController.currentLat = self.currentLat
            mapViewController.currentLong = self.currentLong
            if bookDetailArr?.latitude == "" && bookDetailArr?.longitude == "" { // Manage empty string of Lat - Long
            } else {
                if let lat = bookDetailArr?.latitude,let long = bookDetailArr?.longitude {
                    mapViewController.destLat = lat
                    mapViewController.destLong = long
                }
            }
            self.present(mapViewController, animated: true, completion: nil)
        }
    }
    
    func configureInstanBooking(){
        if self.isInstantBooking{
            self.instantOccurence = Occurrences.init(occurrenceDetail: ["Recurrence": Vocabulary.getWordFromKey(key: "InstantBooking") ,"Time":"\(self.getInstantBookingTime())"])
            if self.occurrences.count > 0{
                let tempOccurence = self.occurrences
                self.occurrences = []
                self.occurrences.append(self.instantOccurence!)
                self.occurrences.append(contentsOf: tempOccurence)
            }else{
                self.occurrences = [self.instantOccurence!]
            }
        }
        DispatchQueue.main.async {
            self.detailTableView.reloadData()
        }
        
    }
    
    // Open image in WebView
    func openNewImageView(imgUrl: String, isvideo: Bool, currentPage: Int, imageArray: [String], videoArray: [String]) {
        let instantViewController = UIStoryboard(name: "BooknowDetailSB", bundle: nil).instantiateViewController(withIdentifier: "InstantOpenController") as! InstantOpenController
        instantViewController.urlString = imgUrl
        instantViewController.isVideo = isvideo
        instantViewController.imagesArr = imageArray
        instantViewController.videoArr = videoArray
        instantViewController.currentPage = currentPage
        instantViewController.arrayOfPreview = self.arrayOfPreview
        instantViewController.thumbnailArr = self.videoArr 
        //        instantViewController.buttonDeleteMedia.isHidden = true
        //        instantViewController.butttonSelectAsCover.isHidden = true
        self.present(instantViewController, animated: false, completion: nil)
    }
    
    // Get Images for page control view
    func getImages() -> [String: [String]]{
        self.imgArr = []
        self.videoArr = []
        self.mainVideoUrl = []
        for (index,image) in imageObj.enumerated(){
            if image.orderIndex.count > 0,let objIndex = Int(image.orderIndex){
                image.largeimageURL.accessibilityValue  = "\(objIndex)"
            }else{
                image.largeimageURL.accessibilityValue = "\(index)"
            }
            imgArr.append(image.largeimageURL)
        }
        for(index,video) in videoObj.enumerated(){
            
            if video.orderIndex.count > 0,let objIndex = Int(video.orderIndex){
                video.videoUrl.accessibilityValue = "\(objIndex)"
                video.thumbnailUrl.accessibilityValue = "\(objIndex)"
            }else{
                let newindex = index + self.imgArr.count
                video.videoUrl.accessibilityValue = "\(newindex)"
                video.thumbnailUrl.accessibilityValue = "\(newindex)"
            }
            self.mainVideoUrl.append(video.videoUrl)
            self.videoArr.append(video.thumbnailUrl)
        }
        var tempDic = [String: [String]]()
        tempDic["Image"] = imgArr as [String]
        tempDic["Thumbnail"] = videoArr as [String]
        tempDic["Video"] = mainVideoUrl as [String]
        
        self.arrayOfPreview = self.imgArr + self.videoArr
        let ans = arrayOfPreview.sorted {
            (first, second) in
            first.accessibilityValue!.compare(second.accessibilityValue!, options: .numeric) == ComparisonResult.orderedAscending
        }
        self.arrayOfPreview = ans
        return tempDic
    }
    
    // MARK:- UITableViewDataSource
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//         let cell = tableView.dequeueReusableCell(withIdentifier: "BookDetailHeaderCell") as! BookDetailHeaderCell
//         cell.contentView.clipsToBounds = false
//        let cell1 = tableView.dequeueReusableCell(withIdentifier: "BookingDetailRateandTimeTableViewCell") as! BookingDetailRateandTimeTableViewCell
//        cell1.contentView.clipsToBounds = false
//    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
////        let cellNib = UINib(nibName: "BookDetailHeaderCell", bundle: nil)
////        self.tableView.registerNib(cellNib, forCellReuseIdentifier: self.tableCellId)
//
//                var mainHeaderView = UIView()
//                var headerView1 = tableView.dequeueReusableHeaderFooterView(withIdentifier: "BookDetailHeaderCell") as! BookDetailHeaderCell
//                let headerView2 = tableView.dequeueReusableCell(withIdentifier: "BookingDetailRateandTimeTableViewCell") as! BookingDetailRateandTimeTableViewCell
//                mainHeaderView.addSubview(headerView1)
//
//        return headerView
//    }
//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 { // Page Control Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookDetailHeaderCell") as! BookDetailHeaderCell
            cell.selectionStyle = .none
            cell.isForAddExperience = false
            cell.openImageDelegate = self
            self.mediaDic = getImages()
            cell.arrayOfPreview = self.arrayOfPreview
            if self.imgArr.count >= 0 {
                DispatchQueue.main.async {
                    // page control concept
                    cell.loadScrollView(mediaDic: self.mediaDic)
                }
            }
            return cell
        }
        else if indexPath.row == 1 { // Rate and Time Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookingDetailRateandTimeTableViewCell") as! BookingDetailRateandTimeTableViewCell
            cell.selectionStyle = .none
            cell.delegate = self
            if let value = bookDetailArr?.averageReview {
                cell.ratingView.rating = Double(value)!
            }
            self.guideDic = bookDetailArr?.guide
            if let imgUrl = self.guideDic?.image {
                if imgUrl == "" {
                    cell.profileImgGuide.image = UIImage.init(named:"updatedProfilePlaceholder")!
                } else {
                    cell.profileImgGuide.imageFromServerURL(urlString: imgUrl, placeHolder: UIImage.init(named:"updatedProfilePlaceholder")!)
                }
            } else {
                cell.profileImgGuide.image = UIImage.init(named:"updatedProfilePlaceholder")!
            }
            if let guideName = self.guideDic?.guideName {
                if let guideCity = self.guideDic?.city {
                    cell.nameGuideLbl.text = "\(guideName)" + ", " + "\(guideCity)"
                }
            }
            if let tempCurrency = bookDetailArr?.currency {
                if let tempPrice = bookDetailArr?.topExperiencePrice {
                    let strMinimumPrice = self.getMinimumPriceHint(objExperience: self.bookDetailArr!)
                    let strFull = tempCurrency + " \(tempPrice)"+" \(strMinimumPrice)"
                    let strMutableString = NSMutableAttributedString.init(string:strFull)
                    let attributes:[NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor:UIColor.black.withAlphaComponent(1.0),NSAttributedStringKey.font:UIFont.init(name:"Avenir-Heavy", size: 17.0)]
                    strMutableString.addAttributes(attributes, range:NSRange(location:strFull.count - strMinimumPrice.count,length:strMinimumPrice.count))
                    cell.currencyLbl.attributedText = strMutableString
                    //cell.currencyLbl.text = tempCurrency + " \(tempPrice)"+strMinimumPrice
                }
            }
            if let title = bookDetailArr?.title {
                cell.placeTitleLbl.text = title
            }
            if let effort = bookDetailArr?.effort {
                cell.effortLbl.text = effort
            }
            if self.accessbilityArr.count > 0{
                cell.lblLanguages.text = self.accessbilityArr.first!
            }
            if let groupMin = bookDetailArr?.groupSizeMin {
                if let groupMax = bookDetailArr?.groupSizeMax {
                    cell.peopleCapacityLbl.text = groupMin + "~" + groupMax + " ppl"
                    cell.maxPeopleLbl.text = Vocabulary.getWordFromKey(key: "MaximumPeople:") + " \(groupMax)"
                }
                cell.minPeopleLbl.text = Vocabulary.getWordFromKey(key: "MinimumPeople:") + " \(groupMin)"
            }
            if let duration = bookDetailArr?.duration {
                cell.timeDuration.text = duration
            }
            if let description = placeDiscription { // hide see more button if content is less.
                if self.isShowMore{ //if description.count < 200 {//
                    cell.placeDetailLbl.numberOfLines = 0
                    cell.placeDetailTxtView.textContainer.maximumNumberOfLines = 0
                    cell.seeMoreBtn.isHidden = true
                }else{
                    cell.placeDetailLbl.numberOfLines = 4
                    cell.placeDetailTxtView.textContainer.maximumNumberOfLines = 6
                    let readmoreFont = UIFont(name: "Avenir-Roman", size: 14.0)
                    cell.placeDetailTxtView.isUserInteractionEnabled = true
                    let readmoreFontColor = UIColor(red: 56.0/255.0, green: 114.0/255.0, blue: 170.0/255.0, alpha: 1.0)
                    DispatchQueue.main.async {
                        cell.placeDetailTxtView.addTrailing(with: "... ", moreText: "read more", moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor, characterLimit: 200, isFromGuideDescription: false)
                    }
//                    cell.seeMoreBtn.isHidden = false
                }
                cell.placeDetailTxtView.text = description
                DispatchQueue.main.async {
                    cell.layoutIfNeeded()
                }
//                cell.placeDetailTxtView.text = description
            }
            cell.layer.zPosition = CGFloat(indexPath.row)
            
            return cell
        }
        else if indexPath.row == 2 { // Time Slot Cell
            let slotCell = tableView.dequeueReusableCell(withIdentifier: "BookingSlotsTableViewCell") as! BookingSlotsTableViewCell
            slotCell.selectionStyle = .none
            slotCell.bookingSlotsCollectionView.tag = 2
            slotCell.bookingSlotsCollectionView.delegate = self
            slotCell.bookingSlotsCollectionView.dataSource = self
            DispatchQueue.main.async {
                slotCell.bookingSlotsCollectionView.reloadData()
            }
            return slotCell
        }
        else if  indexPath.row == 3 { // Accessibility Cell
            let accessibilityCell = tableView.dequeueReusableCell(withIdentifier: "AccessibilityTableViewCell") as!  AccessibilityTableViewCell
            accessibilityCell.selectionStyle = .none
            accessibilityCell.accessibilityCollectionView.tag = 3
            accessibilityCell.accessibilityCollectionView.dataSource = self
            accessibilityCell.accessibilityCollectionView.delegate = self
            DispatchQueue.main.async {
                accessibilityCell.accessibilityCollectionView.reloadData()
            }
            accessibilityCell.layer.zPosition = CGFloat(indexPath.row)
            return accessibilityCell
        }
        else if indexPath.row == 4 { // Guide Profile Cell
            let profileCell = tableView.dequeueReusableCell(withIdentifier: "BookingDetailProfileTableViewCell") as! BookingDetailProfileTableViewCell
            profileCell.delegate = self
            self.guideDic = bookDetailArr?.guide
            if let value = self.guideDic?.averageReview {
                profileCell.ratingView.rating = Double(value)!
            }
            if let imgUrl = self.guideDic?.image {
                profileCell.profilePicImage.imageFromServerURL(urlString: imgUrl,placeHolder:UIImage.init(named:"updatedProfilePlaceholder")!)
            }else{
                profileCell.profilePicImage.image = UIImage.init(named:"updatedProfilePlaceholder")!
            }
            profileCell.guideNameLbl.text = self.guideDic?.guideName
            if let value = self.guideDic?.guideDescription { // hide see more button if content is less.
                if !self.isSeeMoreProfile {
                    //self.guideDetailTxtView.text = self.topGuideDetailData!.comment
                    profileCell.guideDetailTxtView.textContainer.maximumNumberOfLines = 6
                    let readmoreFont = UIFont(name: "Avenir-Roman", size: 14.0)
                    profileCell.guideDetailTxtView.isUserInteractionEnabled = true
                    let readmoreFontColor = UIColor(red: 56.0/255.0, green: 114.0/255.0, blue: 170.0/255.0, alpha: 1.0)
                    let readMoreAttriString = NSAttributedString(string:"... read more", attributes:
                        [NSAttributedStringKey.foregroundColor: readmoreFontColor,
                         NSAttributedStringKey.font: readmoreFont!])
                    DispatchQueue.main.async {
                        //                self.guideDetail.shouldTrim = true
                        //                self.guideDetail.maximumNumberOfLines = 4
                        //                self.guideDetail.attributedReadMoreText = readMoreAttriString
                        
                        profileCell.guideDetailTxtView.shouldTrim = true
                        profileCell.guideDetailTxtView.maximumNumberOfLines = 6
                        profileCell.guideDetailTxtView.attributedReadMoreText = readMoreAttriString
                    }
                    profileCell.guideDetailTxtView.text = value//"\(self.topGuideDetailData!.comment)".trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    DispatchQueue.main.async {
                        //                  self.guideDetailTxtView.addTrailing(with: "... ", moreText: "read more", moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor, characterLimit: 188, isFromGuideDescription: false)
                    }
                } else {
                    profileCell.guideDetailTxtView.textContainer.maximumNumberOfLines = 0
                    profileCell.guideDetailTxtView.text = value//"\(self.topGuideDetailData!.comment)".trimmingCharacters(in: .whitespacesAndNewlines)
                }
                /*
                if self.isSeeMoreProfile{
                    profileCell.guideDetailLbl.numberOfLines = 0
                    profileCell.guideDetailTxtView.textContainer.maximumNumberOfLines = 0
                    profileCell.seeMoreBtn.isHidden = true
                }else{
                    profileCell.guideDetailLbl.numberOfLines = 4
                    profileCell.guideDetailTxtView.textContainer.maximumNumberOfLines = 6
                    let readmoreFont = UIFont(name: "Avenir-Roman", size: 14.0)
                    profileCell.guideDetailTxtView.isUserInteractionEnabled = true
                    let readmoreFontColor = UIColor(red: 56.0/255.0, green: 114.0/255.0, blue: 170.0/255.0, alpha: 1.0)
                    DispatchQueue.main.async {
                        profileCell.guideDetailTxtView.addTrailing(with: "... ", moreText: "read more", moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor, characterLimit: 200, isFromGuideDescription: false)
                    }

//                    profileCell.seeMoreBtn.isHidden = false
                }
                */
                DispatchQueue.main.async {
                    profileCell.layoutIfNeeded()
                }
                profileCell.guideDetailTxtView.text = value
              
            }
            
            return profileCell
        }
        else if indexPath.row == 5 { // Meeting Cell
            let addressCell = tableView.dequeueReusableCell(withIdentifier: "BookingDetailAddressTableViewCell") as! BookingDetailAddressTableViewCell
            addressCell.selectionStyle = .none
            guard self.bookDetailArr != nil else {
                return addressCell
            }
            addressCell.reloadMapDelegate = self
            var destLat: Double = 0.0
            var destLong: Double = 0.0
            
            if bookDetailArr?.latitude == "" && bookDetailArr?.longitude == "" { // Manage empty string of Lat - Long
                addressCell.distanceView.isHidden = true
                if currentLat != "" || currentLong != "" {
                    let currentCoordinate = CLLocationCoordinate2DMake(Double(currentLat)!, Double(currentLong)!)
                    let markerCurrent = GMSMarker(position: currentCoordinate)
                    markerCurrent.position = currentCoordinate
                    markerCurrent.map = addressCell.mapView
                    let markerImageCurrent = UIImage(named: "MarkerImg")!.withRenderingMode(.alwaysTemplate)
                    let markerViewCurrent = UIImageView(image: markerImageCurrent)
                    markerCurrent.iconView = markerViewCurrent
                    markerViewCurrent.tintColor = UIColor.black
                    addressCell.mapView.camera = GMSCameraPosition.camera(withTarget: currentCoordinate, zoom: 16)
                }
            } else {
                addressCell.distanceView.isHidden = false
                if let lat = bookDetailArr?.latitude,let long = bookDetailArr?.longitude {
                    destLat = Double(lat)!
                    destLong = Double(long)!
                    let destCoordinate = CLLocationCoordinate2DMake(destLat, destLong)
                    if currentLat == "" || currentLong == "" {
                        
                    } else {
                        let currentCoordinate = CLLocationCoordinate2DMake(Double(currentLat)!, Double(currentLong)!)
                        let markerCurrent = GMSMarker(position: currentCoordinate)
                        markerCurrent.position = currentCoordinate
                        markerCurrent.map = addressCell.mapView
                        let markerImageCurrent = UIImage(named: "MarkerImg")!.withRenderingMode(.alwaysTemplate)
                        let markerViewCurrent = UIImageView(image: markerImageCurrent)
                        markerCurrent.iconView = markerViewCurrent
                        markerViewCurrent.tintColor = UIColor.black
                    }
                    addressCell.mapView.camera = GMSCameraPosition.camera(withTarget: destCoordinate, zoom: 16)
                    let markerdest = GMSMarker(position: destCoordinate)
                    markerdest.position = destCoordinate
                    markerdest.map = addressCell.mapView
                    let markerImage = UIImage(named: "destinationMarkerIcn")!.withRenderingMode(.alwaysTemplate)
                    let markerView = UIImageView(image: markerImage)
                    markerView.tintColor = UIColor.black
                    markerdest.iconView = markerView
                    addressCell.mapView.isMyLocationEnabled = true
                    addressCell.mapView.delegate = self
                    addressCell.mapView.settings.myLocationButton = false
                    // Adding current button for get location
                    DispatchQueue.main.async {
                        addressCell.drawPolyline(destLat: lat, destLong: long, currentLat: self.currentLat, currentLong: self.currentLong)
                        addressCell.bringSubview(toFront: addressCell.distanceView)
                        addressCell.sendSubview(toBack: addressCell.mapView)
                    }
                   
                }
                
            }
            self.locationDic = self.bookDetailArr?.location
            if let city = self.locationDic?.city, let state = self.locationDic?.state, let country = self.locationDic?.country {
                var arr = [String]()
                if city != "" {
                    arr.append(city)
                }
                if state != "" {
                    arr.append(state)
                }
                if country != "" {
                    arr.append(country)
                }
                var meetingAddress: String = ""
                if let address = self.bookDetailArr?.address {
                    meetingAddress = "\(address)" + "\n"
                }
                meetingAddress = meetingAddress + arr.joined(separator: ",")
                addressCell.meetingLocationDetailLbl.text = meetingAddress
            }
            DispatchQueue.main.async {
                addressCell.layoutIfNeeded()
            }
            addressCell.layer.zPosition = CGFloat(indexPath.row)
            return addressCell
        }
        else if indexPath.row == 6 { // Reviews Cell
            let reviewCell = tableView.dequeueReusableCell(withIdentifier: "ReviewsTableViewCell") as! ReviewsTableViewCell
            reviewCell.selectionStyle = .none
            reviewCell.reviewCollectionView.tag = 1
            reviewCell.reviewCollectionView.delegate = self
            reviewCell.reviewCollectionView.dataSource = self
            reviewCell.reviewCountLabel.text = "\(Vocabulary.getWordFromKey(key: "review"))" + " (" + "\(self.reviewsObj.count)" + ")"
            DispatchQueue.main.async {
                reviewCell.reviewCollectionView.reloadData()
            }
            return reviewCell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 4 {
            if let _ = self.bookDetailArr,let  objGuide:GuideForBooking = self.bookDetailArr!.guide{
                self.pushToGuideDetailController(guideID: objGuide.guideId)
            }
            defer {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    func pushToGuideDetailController(guideID:String){
//        guard User.isUserLoggedIn else {
//            let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"notLogin.title"), message: Vocabulary.getWordFromKey(key:"notLogin.msg"), preferredStyle: .alert)
//
//            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (_) in
//                self.navigationController?.popToRootViewController(animated: true)
//            }))
//            self.present(alertController, animated: true, completion: nil)
//            return
//        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let guideViewController = storyboard.instantiateViewController(withIdentifier: "GuideDetailViewController") as? GuideDetailViewController {
            guideViewController.guideId = guideID
            guideViewController.objGuideDetail = nil
            self.navigationController?.pushViewController(guideViewController, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return CGFloat(headerCellHeight)
        }
        else if indexPath.row == 6 { // Reviews Cell
            if self.reviewsObj.count == 0 {
                return 0 // hide review cell
            } else {
                return tableViewReviewHeight
            }
        }
        else if indexPath.row == 2 {
            if instant, self.occurrences.count > 0 {
                return UITableViewAutomaticDimension
            } else {
                return 0  // hide slot view
            }
        }
        else if indexPath.row == 3 {
            if self.accessbilityArr.count > 0 {
                return CGFloat((self.accessbilityArr.count * 30) + 40)  // Number of items of accessibility * cell height +  top space
            } else {
                return 0  //hide accessible row
            }
        }
        else if indexPath.row == 5 {
            return UITableViewAutomaticDimension
        }
        else {
            return UITableViewAutomaticDimension
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.currentLat = "\(locValue.latitude)"
        self.currentLong = "\(locValue.longitude)"
        self.locationManager.stopUpdatingLocation()
        if self.bookDetailArr?.id != nil || self.bookDetailArr?.id == "" {
            self.reloadMapView()
        }
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
        if let groupPrice = Int(objExperience.groupPrice),groupPrice == 0{
            return true
        }
        guard objExperience.groupPrice.count > 0 else {
            return true//"(\(Vocabulary.getWordFromKey(key: "priceperperson")))" //person
        }
        if let personPrice = Int(objExperience.priceperson),personPrice == 0{
            return false
        }
        if Int(objExperience.groupPrice) ?? 0 > Int(objExperience.priceperson) ?? 0{
            return false//true//"(\(Vocabulary.getWordFromKey(key: "priceperperson")))" //person
        }else{
            return true //false//"(\(Vocabulary.getWordFromKey(key: "pricepergroup")))"
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.detailTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 108, right: 0)
    }
    
    // MARK:- Selector Methods
    @IBAction func instantBookingBtnPressed(_ sender: Any) {
        guard CommonClass.shared.isConnectedToInternet else {
            return
        }
        guard User.isUserLoggedIn else {
            let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"notLogin.title"), message: Vocabulary.getWordFromKey(key:"notLogin.msg"), preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (_) in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            let continueSelelector = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"continueBrowsing"), style: .cancel, handler: nil)
            
            alertController.addAction(continueSelelector)
            alertController.view.tintColor = UIColor(hexString: "#36527D")
            self.present(alertController, animated: true, completion: nil)
            return
        }
        if isInstantBooking == true {
            let instantAlert = UIAlertController(title: Vocabulary.getWordFromKey(key: "InstantBooking"), message: Vocabulary.getWordFromKey(key:"InstantBookingAelrt"),preferredStyle: UIAlertControllerStyle.alert)
            instantAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (action: UIAlertAction!) in
                if let maxValue = self.bookDetailArr?.groupSizeMax {
                    let instantTime: String = self.getInstantBookingTime()
                    self.instantBookingSlot = Slot.init(slotDetail:["Slots":maxValue,"Time":instantTime])
                }
                self.pushToBookingViewController()
            }))
            //instantAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"no"), style: .cancel, handler: nil))
            instantAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler: nil))
            let titleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17.0)!]
            let messageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
            let titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key: "InstantBooking"), attributes: titleFont)
            let messageAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key:"InstantBookingAelrt"), attributes: messageFont)
            
            instantAlert.setValue(titleAttrString, forKey: "attributedTitle")
            instantAlert.setValue(messageAttrString, forKey: "attributedMessage")
            instantAlert.view.tintColor = UIColor.init(hexString: "#36527D")
            present(instantAlert, animated: true, completion: nil)
        }
        
    }
    @IBAction func shareBtnPressed(_ sender: Any) {
        let text: String = (self.bookDetailArr?.title)!
        if self.imageForShare == nil {
            self.imageForShare = #imageLiteral(resourceName: "expriencePlaceholder")
        }
        var sharingURL:String = ""
        if let objExperience:Experience  = self.bookDetailArr,objExperience.experienceURL.count > 0{
            sharingURL = objExperience.experienceURL
        }
        let myWebsite = NSURL(string:"https://itunes.apple.com/us/app/live-private-guided-tours/id1317979792?ls=1&mt=8")//NSURL(string:"https://itunes.apple.com/us/app/live/id1317979792?ls=1&mt=8")
        var shareAll = [text , imageForShare!] as [Any]
        if sharingURL.count > 0{
            let fbURL = NSURL(string:"\(sharingURL)")
            shareAll.append(fbURL as Any)
        }
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        self.present(activityViewController, animated: true, completion: nil)
    }
    @IBAction func favouriteBtn(_ sender: Any) {
        /*
        guard User.isUserLoggedIn else {
            let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"notLogin.title"), message: Vocabulary.getWordFromKey(key:"notLogin.msg"), preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (_) in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            let continueSelelector = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"continueBrowsing"), style: .cancel, handler: nil)
            
            alertController.addAction(continueSelelector)
            alertController.view.tintColor = UIColor(hexString: "#36527D")

            self.present(alertController, animated: true, completion: nil)
            return
        }*/
        var objUserID:String = "0"
        if User.isUserLoggedIn{
            let currentUser: User? = User.getUserFromUserDefault()
            objUserID = (currentUser?.userID)!
        }else{
            objUserID = "0"
        }
        /*
        let currentUser: User? = User.getUserFromUserDefault()
        let userId: String = (currentUser?.userID)!*/
        
        let experienceId: String = (bookDetailArr?.id)!
        if self.isWish == true {
            self.isWish = false
            self.favouriteFunctionality(userID: objUserID, isFavourite: "true", experienceId: experienceId)  // Not Favourite
        } else {
            self.isWish = true
            self.favouriteFunctionality(userID: objUserID, isFavourite: "false", experienceId: experienceId)   // Favourite
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonBookingSelector(sender:UIButton){
        guard CommonClass.shared.isConnectedToInternet else {
            return
        }
        guard User.isUserLoggedIn else {
            let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"notLogin.title"), message: Vocabulary.getWordFromKey(key:"notLogin.msg"), preferredStyle: .alert)
           let continueSelelector = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"continueBrowsing"), style: .cancel, handler: nil)
            
            alertController.addAction(continueSelelector)
 alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (_) in
                self.navigationController?.popToRootViewController(animated: true)
                }))
            
               // alertController.addAction(continueSelelector)
            alertController.view.tintColor = UIColor.init(hexString: "36527D")
            self.present(alertController, animated: true, completion: nil)
            return
        }
        self.instantBookingSlot = nil
        self.pushToBookingViewController()
    }
    
    //MARK:- API Calling (Get Experience Detail from User id)
    func getBookingDetails(userID:String) {
        ProgressHud.show()
        let experienceId: String = (bookDetailArr?.id)!
    
        let urlBookingDetail = "\(kExperience)/\(experienceId)/native/users/\(userID)"
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:urlBookingDetail, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let experienceDic = successDate["experience"] as? [String:Any]{
                DispatchQueue.main.async {
                    self.instantBookingBtn.isEnabled = true
                    self.bookNowBtn.isEnabled = true
                }
                self.bookDetailArr = Experience.init(experienceDetail: experienceDic)
                print(successDate)
                print(experienceDic)
                self.occurrences = self.bookDetailArr!.occurrences
                self.isInstantBooking = self.bookDetailArr!.instant
                self.videoObj = (self.bookDetailArr?.videos)!
                self.languageObj = self.bookDetailArr!.languages
                self.reviewsObj = (self.bookDetailArr?.reviews)!
                self.imageObj = (self.bookDetailArr?.images)!
                for image in self.imageObj {
                    if image.mainImage {
                        DispatchQueue.main.async {
                            let imageView: ImageViewForURL? = ImageViewForURL(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                            imageView?.imageFromServerURL(urlString: image.imageURL as String)
                            self.imageForShare = imageView?.image
                            if let currency = self.bookDetailArr?.currency {
                                let price = self.bookDetailArr?.topExperiencePrice
                                self.bookNowBtn.setTitle(Vocabulary.getWordFromKey(key: "preview.hint") + " (" + "\(currency)" + " " + "\(price!)" + ")", for: .normal)
                            }
                        }
                    }
                }
                self.placeDiscription = self.bookDetailArr?.discription
//                self.placeDiscription?.components(separatedBy: .whitespacesAndNewlines).join
                var parameters:[String:Any] = [:]
                parameters["item_name"] = "Tour Detail"
                parameters["Tour Name"] = "\(self.bookDetailArr!.title)"
                if User.isUserLoggedIn,let user = User.getUserFromUserDefault(){
                    parameters["username"] = "\(user.userFirstName) \(user.userLastName)"
                    parameters["userID"] = "\(user.userID)"
                }
                CommonClass.shared.addFirebaseAnalytics(parameters: parameters)
                self.addFaceBookAnayltics()
                DispatchQueue.main.async {
                    if self.isInstantBooking {
                        self.instantBookingBtn.isHidden = false
                        //                        self.bookNowBtnLeadingConstant.constant = 200
                        //                        self.bookNowBtnTrailingConstant.constant = 25
                        self.bookNowBtnLeadingConstant.constant = 87.0
                    } else {
                        self.instantBookingBtn.isHidden = true
                        //                        self.bookNowBtnLeadingConstant.constant = ((self.view.frame.size.width - 150) / 2)  // Make BookNow btn in Center if instant booking is false
                        //                        self.bookNowBtnTrailingConstant.constant = ((self.view.frame.size.width - 150) / 2)
                        self.bookNowBtnLeadingConstant.constant = 20.0
                    }
//                    let contentHeight: CGFloat = (self.placeDiscription?.heightWithConstrainedWidth(width: self.view.frame.size.width - 20, font: UIFont(name: "Avenir Book", size: 14.0)!))!
//                    let defaultHeightRateCell: Double = 67.0
                    let stringCount = self.placeDiscription?.characters.count
                    if  stringCount! > 200 { // Default label height is 67.0
                        self.isShowMore = false
                    } else {
                        self.isShowMore = true
                    }
                    self.guideDic = self.bookDetailArr?.guide
                    let guideDescriptionCount = self.guideDic?.guideDescription.characters.count
//                    let contentHeightGuide: CGFloat = (guideDescription?.heightWithConstrainedWidth(width: self.view.frame.size.width - 20, font: UIFont(name: "Avenir Book", size: 14.0)!))!
//                    let defaultHeightGuideDetail: Double = 50.0
                    if guideDescriptionCount! > 200 { // Default label height is 58.0
                        self.isSeeMoreProfile = false
                    } else {
                        self.isSeeMoreProfile = true
                    }
                }
                self.getAccessibility()  // get accessibility types
                self.getLanguageName()
                DispatchQueue.main.async {
                    self.registerCustomCells()
                    if self.bookDetailArr?.isWished == "1" {
                        self.favouriteBtn.setBackgroundImage(#imageLiteral(resourceName: "fillFavourite"), for: .normal)
                        self.isWish = true
                    } else {
                        self.favouriteBtn.setBackgroundImage(#imageLiteral(resourceName: "updatedFavouriteImg"), for: .normal)
                        self.isWish = false
                    }
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }) { (responseFail) in
            DispatchQueue.main.async {
                self.instantBookingBtn.isEnabled = false
                self.bookNowBtn.isEnabled = false
            }
            if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
    }
    func addFaceBookAnayltics(){
        var parameters:AppEvent.ParametersDictionary = [:]
        parameters["item_name"] = "Tour Detail"
        parameters["Tour Name"] = "\(self.bookDetailArr!.title)"
        if User.isUserLoggedIn,let user = User.getUserFromUserDefault(){
            parameters["username"] = "\(user.userFirstName) \(user.userLastName)"
            parameters["userID"] = "\(user.userID)"
        }
        CommonClass.shared.addFaceBookAnalytics(eventName:"Tour Detail", parameters: parameters)
    }
    //  Favourite API Calling
    func favouriteFunctionality(userID:String, isFavourite: String, experienceId: String) {
        if User.isUserLoggedIn{
            if let currentUser = User.getUserFromUserDefault(){
                if self.bookDetailArr!.userID == currentUser.userID{
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
            ["UserId":userID,
             "ExperienceId":experienceId,
             "IsDelete":isFavourite
                ] as[String : AnyObject]
        
        if let udid = UIDevice.current.identifierForVendor{
            requestParameters["deviceId"] = "\(udid.uuidString)" as AnyObject
        }
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:urlBookingDetail, parameter: requestParameters, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let _ = success["data"] as? [String:Any] {
                if let dataDic = success["data"] as? [String:Any] {
                    let resultStr = dataDic["Result"] as? Int
                    if resultStr == 1 {
                        DispatchQueue.main.async {
                            self.favouriteBtn.setBackgroundImage(#imageLiteral(resourceName: "fillFavourite"), for: .normal)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.favouriteBtn.setBackgroundImage(#imageLiteral(resourceName: "updatedFavouriteImg"), for: .normal)
                        }
                    }
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
    
    // Accessibility Array
    func getAccessibility() {
        self.accessbilityArr.removeAll()
        if (bookDetailArr?.accessible) == true {
            self.accessbilityArr.append(Vocabulary.getWordFromKey(key:"Accessible"))
        }
        if (bookDetailArr?.freechildren) == true {
            self.accessbilityArr.append(Vocabulary.getWordFromKey(key:"FreeChildren"))
        }
        if (bookDetailArr?.petFriendly) == true {
            self.accessbilityArr.append(Vocabulary.getWordFromKey(key:"PetFriendly"))
        }
        if (bookDetailArr?.freeElderly)  == true {
            self.accessbilityArr.append(Vocabulary.getWordFromKey(key:"FreeElderly"))
        }
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    func pushToBookingViewController(){
        if let _ = self.bookDetailArr,User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(),self.bookDetailArr!.userID == currentUser.userID{
            let alertController = UIAlertController.init(title: Vocabulary.getWordFromKey(key:"Error.title"), message: Vocabulary.getWordFromKey(key:"notBookTourMsg"), preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.tourBtn"), style: .cancel, handler:nil))
            alertController.view.tintColor = UIColor(hexString: "36527D")
            self.present(alertController, animated: true, completion: nil)
            return
        }
        if let bookingViewController = kBookingStoryBoard.instantiateViewController(withIdentifier: "BookingViewController") as? BookingViewController{
            if let _ = self.bookDetailArr{
                bookingViewController.objExperience = self.bookDetailArr!
            }
            if let _ = self.instantBookingSlot{
                bookingViewController.instanceTimeSlot = self.instantBookingSlot!
            }
            self.navigationController?.pushViewController(bookingViewController, animated: true)
        }
    }
    func pushToBookingViewControllerWithOccurence(objOccurence:Occurrences){
        if let _ = self.bookDetailArr,User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(),self.bookDetailArr!.userID == currentUser.userID{
            let alertController = UIAlertController.init(title: Vocabulary.getWordFromKey(key:"Error.title"), message: Vocabulary.getWordFromKey(key:"notBookTourMsg"), preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.tourBtn"), style: .cancel, handler:nil))
            alertController.view.tintColor = UIColor(hexString: "36527D")
            self.present(alertController, animated: true, completion: nil)
            return
        }
        if let bookingViewController = kBookingStoryBoard.instantiateViewController(withIdentifier: "BookingViewController") as? BookingViewController{
            if let _ = self.bookDetailArr{
                bookingViewController.objExperience = self.bookDetailArr!
            }
            bookingViewController.objOccurence = objOccurence
            self.navigationController?.pushViewController(bookingViewController, animated: true)
        }
    }
    // Get Current time + 30 mins
    func minutesToHoursMinutes () -> (hours : Int , leftMinutes : Int) {
        let date = Date()
        let calendar = Calendar.current
        let hourInMin = calendar.component(.hour, from: date) * 60
        let minutes = calendar.component(.minute, from: date)
        let tempMin = hourInMin + minutes + 60
        return (tempMin / 60, (tempMin % 60))
    }
    
    func getInstantBookingTime() -> String {
        let timeStr = "\(minutesToHoursMinutes().hours):\(minutesToHoursMinutes().leftMinutes)"
        return "\(timeStr)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension BookDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return reviewsObj.count
        }
        else if collectionView.tag == 2 {
            return self.occurrences.count
        }
        else if collectionView.tag == 3 {
            if self.languageArr.count == 0 {
                
                return accessbilityArr.count
            } else {
                return accessbilityArr.count
            }
        }
        else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 1 {// Review Collection
            let reviewsCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReviewCollectionViewCell", for: indexPath) as! ReviewCollectionViewCell
            if let imgUrl = self.reviewsObj[indexPath.item].userImage as? String {
                reviewsCollectionCell.reviewProfileImg.imageFromServerURL(urlString: imgUrl,placeHolder:UIImage.init(named:"updatedProfilePlaceholder")!)
            }
            reviewsCollectionCell.readMore = self
            reviewsCollectionCell.reviewProfileImg.circularImg(imgWidth: reviewsCollectionCell.reviewProfileImg.frame.size.height)
            reviewsCollectionCell.reviewView.rating = Double(reviewsObj[indexPath.item].value)!
            reviewsCollectionCell.delegate = self
            reviewsCollectionCell.reviewTextLbl.tag = indexPath.item
            reviewsCollectionCell.seeMoreBtn.tag = indexPath.item
            reviewsCollectionCell.reviewTextLbl.text =  self.reviewsObj[indexPath.item].comment
            reviewsCollectionCell.userNameReviewCell.text = self.reviewsObj[indexPath.item].userName
            let dateStr = self.reviewsObj[indexPath.item].createdDate
            reviewsCollectionCell.dateReviewCell.text = dateStr.changeDateWithTimeFormat
            //self.changeDateFormat(dateStr: dateStr)
            let text = self.reviewsObj[indexPath.item].comment //+  self.reviewsObj[indexPath.item].comment
            let temp1: CGFloat = text.heightWithConstrainedWidth(width: reviewsCollectionCell.frame.size.width, font: UIFont(name: "Avenir-Roman", size: 14.0)!)
            
            self.reviewLblHeight = reviewsCollectionCell.reviewTextLbl.frame.size.height
            if self.reviewSeeMoreSet.contains(indexPath.item) || temp1 < reviewsCollectionCell.reviewTextLbl.frame.size.height {
                DispatchQueue.main.async {
                    reviewsCollectionCell.reviewTextLbl.numberOfLines = 0
//                    reviewsCollectionCell.seeMoreBtn.isHidden = true
                    reviewsCollectionCell.layoutIfNeeded()
                }
            } else {
                DispatchQueue.main.async {
                    reviewsCollectionCell.reviewTextLbl.numberOfLines = 3
//                    reviewsCollectionCell.seeMoreBtn.isHidden = false
                    let readmoreFont = UIFont(name: "Avenir-Roman", size: 14.0)
                    reviewsCollectionCell.reviewTextLbl.isUserInteractionEnabled = true
                    let readmoreFontColor = UIColor(red: 56.0/255.0, green: 114.0/255.0, blue: 170.0/255.0, alpha: 1.0)
                    DispatchQueue.main.async {
                        reviewsCollectionCell.reviewTextLbl.addTrailing(with: "... ", moreText: "read more", moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor)
                    }
                }
            }
//            reviewsCollectionCell.seeMoreBtn.addTarget(self, action:#selector(buttonClicked), for: .touchUpInside)
            
            return reviewsCollectionCell
            
        } else if collectionView.tag == 2 {//Booking slot Collection
            let slotCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookingSlotsCollectionCell", for: indexPath) as! BookingSlotsCollectionCell
            if self.isInstantBooking,indexPath.row == 0 { //instant
                slotCell.layer.borderColor = UIColor(red: 56.0/255.0, green: 114.0/255.0, blue: 170.0/255.0, alpha: 1.0).cgColor
            } else {
                slotCell.layer.borderColor = UIColor.black.cgColor
            }
            guard self.occurrences.count > indexPath.row else {
                return slotCell
            }
            slotCell.slotTitleLbl.text = "\(self.occurrences[indexPath.item].recurrence)"
            if self.occurrences[indexPath.item].time.count > 0,self.occurrences[indexPath.item].time != "None"{
                slotCell.slotTimeLbl.text = self.occurrences[indexPath.item].time.converTo12hoursFormate()
            }else{
                slotCell.slotTimeLbl.text = Vocabulary.getWordFromKey(key:"Custom")
            }
            return slotCell
            
        } else if collectionView.tag == 3 { // Accessibility Collection
            let accessCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AccessibilityCollectionCell", for: indexPath) as! AccessibilityCollectionCell
            guard self.accessbilityArr.count > indexPath.item else {
                return accessCell
            }
            if indexPath.item == 0 { // for language row
                accessCell.accessImg.image = #imageLiteral(resourceName: "earth")
                accessCell.dotImgLbl.isHidden = true
                accessCell.accessImg.isHidden = false
                if  accessbilityArr.count > 0 {
                    accessCell.accessNameLbl.text = self.accessbilityArr[indexPath.item]
                }
                accessCell.accessNameLbl.isHidden = true
                accessCell.accessImg.isHidden = true
            } else { // accessbility rows
                accessCell.dotImgLbl.isHidden = false
                accessCell.accessImg.isHidden = true
                accessCell.accessNameLbl.isHidden = false
                if  accessbilityArr.count > 0 {
                    accessCell.accessNameLbl.text = self.accessbilityArr[indexPath.item]
                }
            }
            return accessCell
        } else {
            return UICollectionViewCell()
        }
    }
    
    // See more Pressed of ReviewCell
    func buttonClicked(sender: UILabel?) {
        let tag: Int = (sender?.tag)!
        self.reviewSeeMoreSet.insert(tag)
        self.reloadReviewCell(tag: tag)
    }
    
    func getLanguageName() {
        for i in languageObj {
            self.languageArr.append(i.languageName)
        }
        if self.languageArr.count > 0 {
            let languageStr = self.languageArr.joined(separator: ", ")
            
            self.accessbilityArr.insert(languageStr, at: 0)
            let indexPath = IndexPath(item: 3, section: 0)
//            DispatchQueue.main.async {
//                self.detailTableView.reloadRows(at: [indexPath], with: .none)
//            }
            
        }
    }
    
    // Date Formatter for Review cell
    func changeDateFormat(dateStr: String) -> String {
        var dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let  dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        
        if let date = dateFormatter.date(from: dateStr){
            return dateFormatter1.string(from: date)
        }else{
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = dateFormatter.date(from: dateStr){
                return dateFormatter1.string(from: date)
            }
            return dateStr
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        if collectionView.tag == 1 { // Review Cell
            return CGSize.init(width: 261.0, height: collectionView.bounds.size.height)
        } else if collectionView.tag == 2 {
            return CGSize(width: 150.0, height: 50.0)
        } else {
            return CGSize(width: collectionView.frame.size.width - 20, height: 30)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        if collectionView.tag == 1 {
            return 0
        }
        else if collectionView.tag == 2 {
            return 20.0
        } else {
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 2 && indexPath.item == 0 { // Booking Slot Collection
            if isInstantBooking == true {
                let instantAlert = UIAlertController(title: Vocabulary.getWordFromKey(key:"InstantBooking"), message: Vocabulary.getWordFromKey(key:"InstantBookingAelrt"),preferredStyle: UIAlertControllerStyle.alert)
                instantAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (action: UIAlertAction!) in
                    if let maxValue = self.bookDetailArr?.groupSizeMax {
                        let instantTime: String = self.getInstantBookingTime()
                        self.instantBookingSlot = Slot.init(slotDetail:["Slots":maxValue,"Time":instantTime])
                    }
                    self.pushToBookingViewController()
                }))
                //instantAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"no"), style: .cancel, handler: nil))
                instantAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler: nil))
                let titleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17.0)!]
                let messageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
                let titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key: "InstantBooking"), attributes: titleFont)
                let messageAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key:"InstantBookingAelrt"), attributes: messageFont)
                
                instantAlert.setValue(titleAttrString, forKey: "attributedTitle")
                instantAlert.setValue(messageAttrString, forKey: "attributedMessage")
                instantAlert.view.tintColor = UIColor.init(hexString: "#36527D")
                present(instantAlert, animated: true, completion: nil)
            }
        }else if collectionView.tag == 2{
            guard User.isUserLoggedIn else{
                return
            }
            // return
            if self.occurrences.count > indexPath.item{
                let objOccurence = self.occurrences[indexPath.item]
                self.pushToBookingViewControllerWithOccurence(objOccurence: objOccurence)
            }
        }
    }
}
extension UILabel {
    
    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        let readMoreText: String = trailingText + moreText
        let lengthForVisibleString: Int = self.vissibleTextLength
        let mutableString: String = self.text!
        let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.count)! - lengthForVisibleString)), with: "")
        let readMoreLength: Int = (readMoreText.count)
        let trimmedForReadMore: String = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: ((trimmedString?.count ?? 0) - readMoreLength), length: readMoreLength), with: "") + trailingText
        let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedStringKey.font: self.font])
        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedStringKey.font: moreTextFont, NSAttributedStringKey.foregroundColor: moreTextColor])
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
    }
    
    var vissibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let attributes: [AnyHashable: Any] = [NSAttributedStringKey.font: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedStringKey : Any])
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
        
        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                }
            } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedStringKey : Any], context: nil).size.height <= labelHeight
            return prev
        }
        return self.text!.count
    }
}
extension UITextView {
    
    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor, characterLimit: Int, isFromGuideDescription: Bool) {
        let readMoreText: String = trailingText + moreText
        
        let lengthForVisibleString: Int = characterLimit + 12   // character limit 200 + 12 (... read more)
        print(((self.text?.count)! - lengthForVisibleString))
        let mutableString: String = self.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//        let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.count)! - lengthForVisibleString)), with: "")
        
        let trimmedString = mutableString.prefix(characterLimit)
        
        let readMoreLength: Int = (readMoreText.count)
        let trimmedForReadMore: String = (trimmedString as NSString).replacingCharacters(in: NSRange(location: ((trimmedString.count ?? 0) - readMoreLength), length: readMoreLength), with: "") + trailingText
        let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedStringKey.font: self.font])
        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedStringKey.font: moreTextFont, NSAttributedStringKey.foregroundColor: moreTextColor])
        answerAttributed.append(readMoreAttributed)
        if isFromGuideDescription {
            let myParagraphStyle = NSMutableParagraphStyle()
            myParagraphStyle.alignment = .center // center the text
            myParagraphStyle.paragraphSpacing = 38 //Change space between paragraphs
            answerAttributed.addAttributes([.paragraphStyle: myParagraphStyle], range: NSRange(location: 0, length: answerAttributed.length))
            self.attributedText = answerAttributed
            
        } else {
            self.attributedText = answerAttributed
        }
    }
    
    var vissibleTextLength: Int {
        let font: UIFont = self.font!
        let mode: NSLineBreakMode = self.textContainer.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width - 40.0
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let attributes: [AnyHashable: Any] = [NSAttributedStringKey.font: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedStringKey : Any])
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
        
        let characterLimit = 200
        let testStr = self.text!
        

        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                }
            } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedStringKey : Any], context: nil).size.height <= labelHeight
            return 200
        }
        return 200
    }
}
extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        guard let attrString = label.attributedText else {
            return false
        }
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        let textStorage = NSTextStorage(attributedString: attrString)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
    func didTapAttributedTextInTextView(label: UITextView, inRange targetRange: NSRange) -> Bool {
        guard let attrString = label.attributedText else {
            return false
        }
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        let textStorage = NSTextStorage(attributedString: attrString)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = label.textContainer.lineBreakMode
        textContainer.maximumNumberOfLines = label.textContainer.maximumNumberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}

