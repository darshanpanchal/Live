//
//  GuideDetailViewController.swift
//  Live
//
//  Created by ITPATH on 4/30/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import ReadMoreTextView

class GuideDetailViewController: UIViewController ,readMoreEvent,ReviewCellUpdater,UIGestureRecognizerDelegate{

    @IBOutlet var btnBack:UIButton!
    @IBOutlet var btnShare:UIButton!
    @IBOutlet var btnFavourite:UIButton!
    @IBOutlet var guideDetailTxtView:ReadMoreTextView!
    @IBOutlet var tableGuide:UITableView!
    @IBOutlet var lblGuideDetail:UILabel!
    @IBOutlet var lblGuideCityName:UILabel!
    @IBOutlet var lblGuideLanguage:UILabel!
    @IBOutlet var imgGuide:ImageViewForURL!
    @IBOutlet var lblGuideName:UILabel!
    @IBOutlet var heightOfGuideOrganization:NSLayoutConstraint!
    @IBOutlet var lblOrganization:UILabel!
    @IBOutlet var lblOrganizationName:UILabel!
    @IBOutlet var imgOrganization:ImageViewForURL!
    @IBOutlet var ratingView:FloatRatingView!
    @IBOutlet var ratingViewSelector:UIButton!
    var guideDetail:ReadMoreTextView = ReadMoreTextView()
    var guideId: String = ""
    var arrayOfOfferedExperiences:[Experience] = []
    var arrayOfReview: [Review] = []
    var reviewLblHeight: CGFloat = 0.0
    var reviewSeeMoreSet = Set<Int>()
    var arrayOfRowsSection:NSArray = []
    var arrayOfExperienceTitle:[String] = [Vocabulary.getWordFromKey(key:"offeredExperiences")]
    var arrayOfExperienceDiscription:[String] = [Vocabulary.getWordFromKey(key:"offeredExperiences.msg")]
    var topGuideDetailData:TopGuideData?
    var tableviewExperienceRowHeight:CGFloat{
        get{
            return UIScreen.main.bounds.width*0.5+60+100+30//UIScreen.main.bounds.height * 360.0/812.0
        }
    }
    var tableViewReviewHeight:CGFloat = 320.0
    var objGuideDetail:Guide?
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.arrayOfRowsSection = [self.arrayOfOfferedExperiences,self.arrayOfReview]
        self.ratingViewSelector.isEnabled = User.isUserLoggedIn
        //Configure Guide TableView
//        guideDetailTxtView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnLabel(_:))))
       
        self.btnShare.isHidden = true
        self.btnFavourite.isHidden = true
        self.configureGuideTableView()

        if let  _ = self.objGuideDetail{
            self.getGuideDetails(guideID:self.objGuideDetail!.id)
        }else if self.guideId.count > 0{
            self.getGuideDetails(guideID:self.guideId)
        }else if let  _ = self.topGuideDetailData{
            self.getGuideDetails(guideID:self.topGuideDetailData!.id)
        }
       
    }
    func swipeToPop() {
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func configureGuideOrganization(){
        DispatchQueue.main.async {
            self.imgOrganization.layer.cornerRadius = 5.0
            self.imgOrganization.clipsToBounds = true
            if let _ = self.topGuideDetailData{
                if self.topGuideDetailData!.organisationLogo.count > 0 ,self.topGuideDetailData!.organisationName.count > 0{
                    self.imgOrganization.imageFromServerURL(urlString: self.topGuideDetailData!.organisationLogo)
                    self.lblOrganizationName.text = "\(self.topGuideDetailData!.organisationName)"
                    self.heightOfGuideOrganization.constant = 135.0
                }else{
                    self.heightOfGuideOrganization.constant = 0.0
                }
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.tableViewHeaderFit()
        }
      
    }
    func tableViewHeaderFit(){
        if let headerView = tableGuide.tableHeaderView {
            
            let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            
            //Comparison necessary to avoid infinite loop
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableGuide.tableHeaderView = headerView
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableGuide.estimatedSectionHeaderHeight = UITableViewAutomaticDimension
        DispatchQueue.main.async {
            self.addDynamicFont()
            self.swipeToPop()
        }
    }
    func addDynamicFont(){
   
        self.guideDetailTxtView.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        
//        self.lblGuideCityName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
//        self.lblGuideCityName.adjustsFontForContentSizeCategory = true
//        self.lblGuideCityName.adjustsFontSizeToFitWidth = true
        
        self.lblGuideDetail.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblGuideDetail.adjustsFontForContentSizeCategory = true
        self.lblGuideDetail.adjustsFontSizeToFitWidth = true
        
        self.lblGuideLanguage.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.lblGuideLanguage.adjustsFontForContentSizeCategory = true
        self.lblGuideLanguage.adjustsFontSizeToFitWidth = true
        
        self.lblGuideName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblGuideName.adjustsFontForContentSizeCategory = true
        self.lblGuideName.adjustsFontSizeToFitWidth = true
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
    func configureGuideTableView(){
        self.tableGuide.rowHeight = UITableViewAutomaticDimension
        self.tableGuide.estimatedRowHeight = 150.0
        //Register Experience TableViewCell
        let objExperienceNib = UINib.init(nibName: "ExperienceTableViewCell", bundle: nil)
        self.tableGuide.register(objExperienceNib, forCellReuseIdentifier: "ExperienceTableViewCell")
        self.tableGuide.delegate = self
        self.tableGuide.dataSource = self
    }
    
    func configureGuideView(){
        self.view.addSubview(self.guideDetail)
        imgGuide.contentMode = .scaleAspectFill
//        self.imgGuide.layer.borderColor = UIColor.black.cgColor
//        self.imgGuide.layer.borderWidth = 1.0
        self.imgGuide.layer.cornerRadius =  self.imgGuide.frame.width / 2.0
        self.imgGuide.clipsToBounds = true
        if let _  = self.topGuideDetailData{
            self.lblGuideName.text = "\(self.topGuideDetailData!.guideName)"
            self.ratingView.rating = Double(self.topGuideDetailData!.averageReview)!
            if User.isUserLoggedIn{
                self.ratingViewSelector.isEnabled = !self.topGuideDetailData!.isRated
            }else{
                self.ratingViewSelector.isEnabled = false
            }
            
           if self.topGuideDetailData!.comment.count > 200 {
            
            self.guideDetailTxtView.textContainer.maximumNumberOfLines = 5
            let readmoreFont = UIFont(name: "Avenir-Roman", size: 14.0)
            self.guideDetailTxtView.isUserInteractionEnabled = true
            let readmoreFontColor = UIColor(red: 56.0/255.0, green: 114.0/255.0, blue: 170.0/255.0, alpha: 1.0)
            let readMoreAttriString = NSAttributedString(string:"... read more", attributes:
                [NSAttributedStringKey.foregroundColor: readmoreFontColor,
                 NSAttributedStringKey.font: readmoreFont!])
            DispatchQueue.main.async {
                self.guideDetailTxtView.shouldTrim = true
                self.guideDetailTxtView.maximumNumberOfLines = 4
                self.guideDetailTxtView.attributedReadMoreText = readMoreAttriString
            }
             self.guideDetailTxtView.text = "\(self.topGuideDetailData!.comment)".trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
 
           } else {
                self.guideDetailTxtView.textContainer.maximumNumberOfLines = 0
                self.guideDetailTxtView.text = "\(self.topGuideDetailData!.comment)".trimmingCharacters(in: .whitespacesAndNewlines)
            }
            self.lblGuideCityName.text = "\(self.topGuideDetailData!.location)"
            self.lblGuideLanguage.text = "\(self.topGuideDetailData!.language)"
            self.imgGuide.imageFromServerURL(urlString: "\(self.topGuideDetailData!.image)",placeHolder:UIImage.init(named:"ic_profile")!)
            
            self.tableGuide.reloadData()
            self.configureGuideOrganization()
            
        }
    }
    // MARK: - API Request
    //Get Guide Details
    func getGuideDetails(guideID:String){
        var userID:String = "0"
        var deviceID:String = ""
        
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            userID =  currentUser.userID
        }
        if let udid = UIDevice.current.identifierForVendor{
            deviceID = "\(udid.uuidString)"
            
        }
        
        let urlGuide = "guides/\(guideID)/native?userId=\(userID)&&deviceId=\(deviceID)"
        guard CommonClass.shared.isConnectedToInternet else{
            return
        }
    
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:urlGuide, parameter: nil , isHudeShow: true, success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let guideDetail = successDate["Guide"] as? [String:Any]{
                DispatchQueue.main.async {
                self.topGuideDetailData = TopGuideData(topGuideDetail: guideDetail)
                    DispatchQueue.main.async {
                        self.arrayOfOfferedExperiences = (self.topGuideDetailData?.topExperience)!
                        self.arrayOfReview = (self.topGuideDetailData?.reviews)!
                        self.tableGuide.reloadData()
                        self.configureGuideView()
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
    
    // MARK: - Selector Methods
    @IBAction func buttonRatingViewSelector(sender:UIButton){
        self.presentGuideReviewController()
    }
    @IBAction func buttonBackSelector(sender:UIButton){
        //PopToBackView Controller
        self.popToBackViewController()
    }
    @IBAction func buttonShareSelector(sender:UIButton){
        let text: String = "Hello details"
        let temp = "Live with us! \n Experience: \(text), \n http://www.liveinternational.net "
        
        // set up activity view controller
        let textToShare = [ temp ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        self.present(activityViewController, animated: true, completion: nil)
    }
    @IBAction func buttonFavSelector(sender:UIButton){
        
        let currentUser: User? = User.getUserFromUserDefault()
        let userId: String = (currentUser?.userID)!
        let experienceId: String = "1"
        if btnFavourite.isSelected == true {
            btnFavourite.setBackgroundImage(#imageLiteral(resourceName: "FavouriteBtn"), for: .normal)
            btnFavourite.isSelected = false
            self.favouriteFunctionality(userID: userId, isFavourite: "true", experienceId: experienceId)   // Favourite
        }else {
            btnFavourite.setBackgroundImage(#imageLiteral(resourceName: "fillFavourite"), for: .normal)
            btnFavourite.isSelected = true
            self.favouriteFunctionality(userID: userId, isFavourite: "false", experienceId: experienceId)  // Not Favourite
        }
    }
    @IBAction func buttonReadMoreSelector(sender:UIButton){
        
        if let _ = self.topGuideDetailData,self.topGuideDetailData!.comment.count > 200{
            DispatchQueue.main.async {
                let readmoreFont = UIFont(name: "Avenir-Roman", size: 17.0)
                self.guideDetailTxtView.isUserInteractionEnabled = true
                let readmoreFontColor = UIColor.black//UIColor(red: 56.0/255.0, green: 114.0/255.0, blue: 170.0/255.0, alpha: 1.0)
                let readMoreAttriString = NSAttributedString(string:"\(self.topGuideDetailData!.comment)", attributes:
                    [NSAttributedStringKey.foregroundColor: readmoreFontColor,
                     NSAttributedStringKey.font: readmoreFont!])
                self.guideDetailTxtView.attributedText = readMoreAttriString
                self.guideDetailTxtView.textContainer.maximumNumberOfLines = 0
                self.tableViewHeaderFit()
            }
        }
    }
   
    //  Favourite API Calling
    func favouriteFunctionality(userID:String, isFavourite: String, experienceId: String) {
        let urlBookingDetail = "experience/native/wishlist"
        let requestParameters =
            ["UserId":userID,
             "ExperienceId":experienceId,
             "IsDelete":isFavourite
                ] as[String : AnyObject]
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:urlBookingDetail, parameter: requestParameters, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let _ = success["data"] as? [String:Any] {
                if let dataDic = success["data"] as? [String:Any] {
                    let currentUser: User? = User.getUserFromUserDefault()
                    let userId: String = (currentUser?.userID)!
                    self.getGuideDetails(guideID:userId)
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
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    func popToBackViewController(){
        self.navigationController?.popViewController(animated: true)
    }
    //PresentReview
    func presentGuideReviewController(){
        guard let _ = self.topGuideDetailData else {
            return
        }
        
        DispatchQueue.main.async {
            self.view.endEditing(true)
            if let reviewViewController = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController{
                reviewViewController.modalPresentationStyle = .overFullScreen
                reviewViewController.guideDetail = self.topGuideDetailData!
                reviewViewController.isGuideReview = true
                reviewViewController.objReviewDelegate = self
                self.present(reviewViewController, animated: false, completion: nil)
            }
        }
        
    }
}
extension GuideDetailViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfRowsSection.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let experienceCell:ExperienceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ExperienceTableViewCell", for: indexPath) as! ExperienceTableViewCell
            self.tableGuide.separatorStyle = .none
            guard self.arrayOfRowsSection.count > indexPath.row,self.arrayOfExperienceTitle.count > indexPath.row,self.arrayOfExperienceDiscription.count > indexPath.row else {
                return experienceCell
            }
            experienceCell.lblExperienceTitle.text = "\(self.arrayOfExperienceTitle[indexPath.row])"
            experienceCell.lblExperienceDiscription.text = "\(self.arrayOfExperienceDiscription[indexPath.row])"
            experienceCell.collectionExperience.tag = indexPath.row + 100
            experienceCell.collectionExperience.delegate = self
            experienceCell.collectionExperience.dataSource = self
            experienceCell.selectionStyle = .none
            DispatchQueue.main.async {
                experienceCell.collectionExperience.reloadData()
            }
            return experienceCell
        }else { //Review TableViewCell
            let reviewCell = tableView.dequeueReusableCell(withIdentifier: "ReviewsTableViewCell") as! ReviewsTableViewCell
            reviewCell.selectionStyle = .none
            reviewCell.reviewCollectionView.tag = 1
            reviewCell.reviewCollectionView.delegate = self
            reviewCell.reviewCollectionView.dataSource = self
            reviewCell.reviewCountLabel.text = "\(Vocabulary.getWordFromKey(key: "review"))" + " (" + "\(self.arrayOfReview.count)" + ")"
            DispatchQueue.main.async {
                reviewCell.reviewCollectionView.reloadData()
            }
            return reviewCell
        }
       
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            if self.arrayOfOfferedExperiences.count > 0{
                return self.tableviewExperienceRowHeight
            }else{
                return 150.0
            }
        }else{
            if self.arrayOfReview.count > 0{
                return self.tableViewReviewHeight
            }else{
                return 150.0
            }
        }
    }
}
extension GuideDetailViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,TopExperienceDelegate{
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 100{ //Offered Experiences
            if self.arrayOfOfferedExperiences.count > 0 {
                collectionView.removeMessageLabel()
            }else{
                collectionView.showMessageLabel()
            }
            return self.arrayOfOfferedExperiences.count
        }else{
            if self.arrayOfReview.count > 0 {
                collectionView.removeMessageLabel()
            }else{
                collectionView.showMessageLabel()
            }
            return self.arrayOfReview.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 100{ //Instant
              let experienceCell:ExperienceCollectionViewCell =  collectionView.dequeueReusableCell(withReuseIdentifier: "ExperienceCollectionViewCell", for: indexPath) as! ExperienceCollectionViewCell
              var objectTopExperience:Experience?
              experienceCell.payContainerView.isHidden = true
              experienceCell.payBtn.isHidden = true

                if self.arrayOfOfferedExperiences.count > indexPath.item{
                    objectTopExperience = self.arrayOfOfferedExperiences[indexPath.item]
                }
          
             if let _ = objectTopExperience{
                experienceCell.lblExperienceDisc.text = "\(objectTopExperience!.title)"
                experienceCell.lblExperienceCurrency.text = "\(objectTopExperience!.currency) \(self.isPricePerPerson(objExperience: objectTopExperience!) ? objectTopExperience!.priceperson : objectTopExperience!.groupPrice)"
                if objectTopExperience!.mainImage.count > 0{
                    experienceCell.loadImage(url: objectTopExperience!.smallmainImage)
                    //experienceCell.imgExperience.imageFromServerURL(urlString: objectTopExperience!.mainImage)
                }else{
                    experienceCell.imgExperience.image = #imageLiteral(resourceName: "expriencePlaceholder").withRenderingMode(.alwaysOriginal)
                }
                
                experienceCell.ratingView.rating = Double(objectTopExperience!.ratingReview)!
                experienceCell.ratingView.editable = false
                experienceCell.circularView.isHidden = true
                experienceCell.lblMinimumPrice.text = self.getMinimumPriceHint(objExperience: objectTopExperience!)
                if Bool.init(objectTopExperience!.isWished){
                    experienceCell.btnAddToLike.setBackgroundImage(#imageLiteral(resourceName: "fillFavourite"), for: .normal)
                } else {
                    let favouriteBtnImg = #imageLiteral(resourceName: "FavouriteBtn").withRenderingMode(.alwaysTemplate)
                    experienceCell.btnAddToLike.setBackgroundImage(favouriteBtnImg, for: .normal)
                }
                experienceCell.btnAddToLike.tintColor = UIColor.white
                experienceCell.btnAddToLike.isHidden = !User.isUserLoggedIn
                experienceCell.viewContainerForShareAndLike.isHidden = false
                experienceCell.btnShare.accessibilityValue = "\(collectionView.tag)"
                experienceCell.btnAddToLike.accessibilityValue = "\(collectionView.tag)"
                experienceCell.btnShare.tag = indexPath.item
                experienceCell.btnAddToLike.tag = indexPath.item
                experienceCell.delegate = self
             }
            return experienceCell
        }else{
            let reviewsCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReviewCollectionViewCell", for: indexPath) as! ReviewCollectionViewCell
            let imgUrl = self.arrayOfReview[indexPath.item].userImage
            reviewsCollectionCell.reviewProfileImg.imageFromServerURL(urlString: imgUrl,placeHolder:UIImage.init(named:"updatedProfilePlaceholder")!)
            reviewsCollectionCell.readMore = self
            reviewsCollectionCell.reviewProfileImg.circularImg(imgWidth: reviewsCollectionCell.reviewProfileImg.frame.size.height)
            reviewsCollectionCell.reviewView.rating = Double(arrayOfReview[indexPath.item].value)!
            reviewsCollectionCell.delegate = self
            reviewsCollectionCell.reviewTextLbl.tag = indexPath.item
            reviewsCollectionCell.seeMoreBtn.tag = indexPath.item
            reviewsCollectionCell.reviewTextLbl.text =  self.arrayOfReview[indexPath.item].comment
            reviewsCollectionCell.userNameReviewCell.text = self.arrayOfReview[indexPath.item].userName
            let dateStr = self.arrayOfReview[indexPath.item].createdDate
            reviewsCollectionCell.dateReviewCell.text = dateStr.changeDateWithTimeFormat//self.changeDateFormat(dateStr: dateStr)
            let text = self.arrayOfReview[indexPath.item].comment //+  self.reviewsObj[indexPath.item].comment
            let temp1: CGFloat = text.heightWithConstrainedWidth(width: reviewsCollectionCell.frame.size.width, font: UIFont(name: "Avenir-Roman", size: 14.0)!)
            
            self.reviewLblHeight = reviewsCollectionCell.reviewTextLbl.frame.size.height
            if self.reviewSeeMoreSet.contains(indexPath.item) {//|| temp1 < reviewsCollectionCell.reviewTextLbl.frame.size.height {
//                DispatchQueue.main.async {
                    reviewsCollectionCell.reviewDetailTxtView.textContainer.maximumNumberOfLines = 0
                    reviewsCollectionCell.reviewDetailTxtView.text = "\(self.arrayOfReview[indexPath.item].comment)".trimmingCharacters(in: .whitespacesAndNewlines)
                    /*
                    reviewsCollectionCell.reviewTextLbl.numberOfLines = 0
                    //                    reviewsCollectionCell.seeMoreBtn.isHidden = true
                    reviewsCollectionCell.layoutIfNeeded()*/
//                }
            } else {
//                DispatchQueue.main.async {
                    reviewsCollectionCell.reviewDetailTxtView.textContainer.maximumNumberOfLines = 5
                    let readmoreFont = UIFont(name: "Avenir-Roman", size: 14.0)
                    reviewsCollectionCell.reviewDetailTxtView.isUserInteractionEnabled = true
                    let readmoreFontColor = UIColor(red: 56.0/255.0, green: 114.0/255.0, blue: 170.0/255.0, alpha: 1.0)
                    let readMoreAttriString = NSAttributedString(string:"... read more", attributes:
                        [NSAttributedStringKey.foregroundColor: readmoreFontColor,
                         NSAttributedStringKey.font: readmoreFont!])
                    DispatchQueue.main.async {
                        reviewsCollectionCell.reviewDetailTxtView.shouldTrim = true
                        reviewsCollectionCell.reviewDetailTxtView.maximumNumberOfLines = 4
                        reviewsCollectionCell.reviewDetailTxtView.attributedReadMoreText = readMoreAttriString
                    }
                    reviewsCollectionCell.reviewDetailTxtView.text = "\(self.arrayOfReview[indexPath.item].comment)".trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    /*
                    reviewsCollectionCell.reviewTextLbl.numberOfLines = 4
                    //                    reviewsCollectionCell.seeMoreBtn.isHidden = false
                    let readmoreFont = UIFont(name: "Avenir-Roman", size: 14.0)
                    reviewsCollectionCell.reviewTextLbl.isUserInteractionEnabled = true
                    let readmoreFontColor = UIColor(red: 56.0/255.0, green: 114.0/255.0, blue: 170.0/255.0, alpha: 1.0)
                    DispatchQueue.main.async {
                        reviewsCollectionCell.reviewTextLbl.addTrailing(with: "... ", moreText: "read more", moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor)
                    }*/
//                }
            }
            //            reviewsCollectionCell.seeMoreBtn.addTarget(self, action:#selector(buttonClicked), for: .touchUpInside)
            
            return reviewsCollectionCell
        }
    }
    func buttonClicked(sender: UILabel?) {
        let tag: Int = (sender?.tag)!
        self.reviewSeeMoreSet.insert(tag)
        self.reloadReviewCell(tag: tag)
    }
    func reloadReviewCell(tag: Int) {
        let cell = self.tableGuide.dequeueReusableCell(withIdentifier: "ReviewsTableViewCell") as! ReviewsTableViewCell
        let text = self.arrayOfReview[tag].comment
        var temp1: CGFloat = text.heightWithConstrainedWidth(width: cell.frame.size.width, font: UIFont(name: "Avenir Book", size: 14.0)!)
//        self.reviewLblHeight = temp1
//        self.tableViewReviewHeight = 500//temp1 + 200.0
        temp1 += 50.0
        if reviewLblHeight > temp1 {
            //self.tableViewReviewHeight += temp1 + 100.0
        } else {
            let additionalHeight: CGFloat = temp1
            self.tableViewReviewHeight += additionalHeight + 100.0
        }
        let indexPath = IndexPath(item: 1, section: 0)
        self.tableGuide.reloadRows(at: [indexPath], with: .none)
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
        if collectionView.tag == 100{ //Instant
            return  CGSize.init(width: collectionView.bounds.size.width - 115.0, height: 300)
        }else{
            return CGSize.init(width: 200, height: self.tableViewReviewHeight - 50.0)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsetsMake(0, 20.0, 0, 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 10.0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var objectTopExperience:Experience?
        if collectionView.tag == 100{ //Instant
            if self.arrayOfOfferedExperiences.count > indexPath.item{
                objectTopExperience = self.arrayOfOfferedExperiences[indexPath.item]
                let storyboard = UIStoryboard(name: "BooknowDetailSB", bundle: nil)
                if let bookDetailcontroller = storyboard.instantiateViewController(withIdentifier: "BookDetailViewController") as? BookDetailViewController {
                    bookDetailcontroller.bookDetailArr = objectTopExperience
                    self.navigationController?.pushViewController(bookDetailcontroller, animated: true)
                }
            }
        }
    }
    
    @objc func buttonSelectFavClicked(sender: UIButton?) {
        let tag: Int = (sender?.tag)!
        let objExperience = self.arrayOfOfferedExperiences[tag]
        let currentUser: User? = User.getUserFromUserDefault()
        let userId: String = (currentUser?.userID)!
        
        if objExperience.isTopExperienceIsWish == true {
            self.favouriteFunctionality(userID: userId, isFavourite: "true", experienceId: objExperience.id)  // Not Favourite
        }
        if objExperience.isTopExperienceIsWish == false {
            self.favouriteFunctionality(userID: userId, isFavourite: "false", experienceId: objExperience.id)   // Favourite
        }
       
    }
}
extension GuideDetailViewController:ReviewControlDelegate{
    func submittedGuideReview(objGuide: TopGuideData) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.getGuideDetails(guideID: "\(objGuide.id)")
        }
    }
    func cancelGuideReview() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
extension GuideDetailViewController:ExperienceDelegate{
    func didSelectLikeExperienceSelector(sender: UIButton) {
        guard self.arrayOfOfferedExperiences.count > sender.tag else{
            return
        }
        let objExperience = self.arrayOfOfferedExperiences[sender.tag]
        self.likeUnlikeExperienceWith(objExperience: objExperience)
    }
    func likeUnlikeExperienceWith(objExperience:Experience){
        var userID:String = "0"
        if User.isUserLoggedIn{
            userID = User.getUserFromUserDefault()!.userID
        }
        self.favouriteFunctionality(userID: userID, objExperience: objExperience)
        
    }
    func favouriteFunctionality(userID:String,objExperience:Experience) {
        if User.isUserLoggedIn{
            if let currentUser = User.getUserFromUserDefault(){
                if self.topGuideDetailData!.id == currentUser.userID{
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
                //pushToken = "\(kUserDefault.value(forKey:kPushNotificationToken)!)" as AnyObject
            }
            requestParameters["deviceId"] = pushToken
        }
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:urlBookingDetail, parameter: requestParameters, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let _ = success["data"] as? [String:Any] {
                
                if let dataDic = success["data"] as? [String:Any] {
                    if let  _ = self.objGuideDetail{
                        self.getGuideDetails(guideID:self.objGuideDetail!.id)
                    }else if self.guideId.count > 0{
                        self.getGuideDetails(guideID:self.guideId)
                    }else if let  _ = self.topGuideDetailData{
                        self.getGuideDetails(guideID:self.topGuideDetailData!.id)
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
    func didSelectShareExperienceSelector(sender: UIButton) {
        guard self.arrayOfOfferedExperiences.count > sender.tag else{
            return
        }
        let objExperience = self.arrayOfOfferedExperiences[sender.tag]
        self.shareExpereinceWith(objExperience: objExperience)
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
