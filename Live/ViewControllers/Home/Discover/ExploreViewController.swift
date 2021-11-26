//
//  ExploreViewController.swift
//  Live
//
//  Created by ITPATH on 4/30/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class ExploreViewController: UIViewController ,UIGestureRecognizerDelegate{
    
    @IBOutlet var objCollectionView:UICollectionView!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var btnClear:UIButton!
    var collections:Collections?
    var arrayOfExperience:[Experience] = []
    var objExperienceDetail:Experience?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let _ = self.collections{
            self.lblTitle.text = "\(self.collections!.title)"
        }
        self.getExpoCollectionDetails(experienceID:(collections?.id)!)
        //self.getExpoCollectionDetails(userID:"1")
        //self.configureCollectionView()
       
    }
    func swipeToPop() {
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        DispatchQueue.main.async {
            self.addDynamicFont()
             self.swipeToPop()
        }
    }
    func addDynamicFont(){
        self.lblTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblTitle.adjustsFontForContentSizeCategory = true
        self.lblTitle.adjustsFontSizeToFitWidth = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
    func configureCollectionView(){
        let objExperienceNib = UINib.init(nibName: "ExperienceCollectionViewCell", bundle: nil)
        self.objCollectionView.register(objExperienceNib, forCellWithReuseIdentifier: "ExperienceCollectionViewCell")
        self.objCollectionView.delegate = self
        self.objCollectionView.dataSource = self
        self.objCollectionView.reloadData()
    }
    
    //Get Guide Details
    func getExpoCollectionDetails(experienceID:String){
        var userID:String = "0"
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            userID = currentUser.userID
        }
        var deviceID:String = ""
        if let udid = UIDevice.current.identifierForVendor{
           deviceID = "\(udid.uuidString)" 
        }
        let urlExpoCollection = "experience/native/expocollection/\(experienceID)?userId=\(userID)&deviceId=\(deviceID)"
        guard CommonClass.shared.isConnectedToInternet else{
            return
        }
   
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:urlExpoCollection, parameter: nil , isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let expoCollection = successDate["ExpoCollection"] as? [String:Any]{
                DispatchQueue.main.async {
                    self.arrayOfExperience.removeAll()
                    self.collections = Collections.init(collectionDetail: expoCollection)
                    self.arrayOfExperience = self.collections!.expoExperiences
//                        for dateObject in arrayExpoCollectionDetails{
//                            let objExpoCollection = Experience.init(experienceDetail:dateObject)
//                            self.arrayOfExperience.append(objExpoCollection)
//                        }
                    DispatchQueue.main.async {
                        self.configureCollectionView()
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
    @IBAction func buttonClearSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: false)
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    func pushToExperienceDetail(objExperience:Experience){
        if let bookingDetailView  = kBookingStoryBoard.instantiateViewController(withIdentifier: "BookDetailViewController") as? BookDetailViewController{
            self.navigationController?.pushViewController(bookingDetailView, animated: true)
        }
    }
}
extension ExploreViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.arrayOfExperience.count > 0 {
            collectionView.removeMessageLabel()
        }else{
            collectionView.showMessageLabel()
        }
        return self.arrayOfExperience.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let experienceCell:ExperienceCollectionViewCell =  collectionView.dequeueReusableCell(withReuseIdentifier: "ExperienceCollectionViewCell", for: indexPath) as! ExperienceCollectionViewCell
        experienceCell.payContainerView.isHidden = true
        experienceCell.payBtn.isHidden = true
        if self.arrayOfExperience.count > indexPath.item{
            let objectExperience:Experience = self.arrayOfExperience[indexPath.item]
            experienceCell.lblExperienceDisc.text = "\(objectExperience.title)"
            experienceCell.lblExperienceCurrency.text = "\(objectExperience.currency) \(self.isPricePerPerson(objExperience: objectExperience) ? objectExperience.priceperson : objectExperience.groupPrice)"
             experienceCell.loadImage(url: objectExperience.smallmainImage)
            //experienceCell.imgExperience.imageFromServerURL(urlString:objectExperience.mainImage)
            experienceCell.ratingView.rating = Double(objectExperience.averageReview)!
            experienceCell.ratingView.editable = false
            experienceCell.circularView.isHidden = true
            experienceCell.lblMinimumPrice.text =  self.getMinimumPriceHint(objExperience: objectExperience)
            if Bool.init(objectExperience.isWished){
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
        return CGSize.init(width: collectionView.bounds.size.width*0.5-27, height: collectionView.bounds.size.width*0.5+50+30)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.init(top: 20, left: 20, bottom: 0, right: 20)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 15.0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var objectExperience:Experience?
            if self.arrayOfExperience.count > indexPath.item{
//                guard User.isUserLoggedIn else {
//                    let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"notLogin.title"), message: Vocabulary.getWordFromKey(key:"notLogin.msg"), preferredStyle: .alert)
//                    alertController.addAction(UIAlertAction.init(title:"Ok", style: .default, handler: { (_) in
//                        self.dismiss(animated: true, completion: {
//                            self.navigationController?.popToRootViewController(animated: true)
//                        })
//                    }))
//                    self.present(alertController, animated: true, completion: nil)
//                    return
//                }
                objectExperience = self.arrayOfExperience[indexPath.item]
                let storyboard = UIStoryboard(name: "BooknowDetailSB", bundle: nil)
                if let bookDetailcontroller = storyboard.instantiateViewController(withIdentifier: "BookDetailViewController") as? BookDetailViewController {
                    bookDetailcontroller.bookDetailArr = objectExperience
                    self.navigationController?.pushViewController(bookDetailcontroller, animated: true)
                }
        }
    }
}
extension ExploreViewController:ExperienceDelegate{
    func didSelectLikeExperienceSelector(sender: UIButton) {
        guard self.arrayOfExperience.count > sender.tag else{
            return
        }
        let objExperience = self.arrayOfExperience[sender.tag]
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
                //pushToken = "\(kUserDefault.value(forKey:kPushNotificationToken)!)" as AnyObject
            }
            requestParameters["deviceId"] = pushToken
        }
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:urlBookingDetail, parameter: requestParameters, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let _ = success["data"] as? [String:Any] {
                
                if let dataDic = success["data"] as? [String:Any] {
                     self.getExpoCollectionDetails(experienceID:(self.collections?.id)!)
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
        guard self.arrayOfExperience.count > sender.tag else{
            return
        }
        let objExperience = self.arrayOfExperience[sender.tag]
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
