//
//  AllGuideViewController.swift
//  Live
//
//  Created by IPS on 22/11/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class AllGuideViewController: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet var collectionViewGuide:UICollectionView!
    @IBOutlet var btnBack:UIButton!
    @IBOutlet var lblTitle:UILabel!
    
    var currentGuidePageIndex:Int = 0
    var currentGuidePageSize:Int = 10
    var isAllGuideLoadMore:Bool = false
    var arrayOfGuide:[TopGuideData] = []
    var locationID:String = "0"
    override func viewDidLoad() {
        super.viewDidLoad()
        let objGuideNib = UINib.init(nibName: "GuideCollectionViewCell", bundle: nil)
        self.collectionViewGuide.register(objGuideNib, forCellWithReuseIdentifier:"GuideCollectionViewCell")
        self.collectionViewGuide.delegate = self
        self.collectionViewGuide.dataSource = self
        //Get Guides
        self.getGuidesRequetsAPI()
        self.swipeToPop()
    }
    func swipeToPop() {
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - API Requests
    func getGuidesRequetsAPI(){
        let urlAllGuide = "guides/\(locationID)?pageSize=\(currentGuidePageSize)&pageIndex=\(currentGuidePageIndex)"
        
        guard CommonClass.shared.isConnectedToInternet else{
            return
        }
        
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:urlAllGuide, parameter: nil , isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let  array = successDate["Guides"] as? [[String:Any]]{
                if self.currentGuidePageIndex == 0{
                    self.arrayOfGuide = []
                }
                self.isAllGuideLoadMore = (array.count == self.currentGuidePageSize)
                for object in array{
                    let objectExperience = TopGuideData.init(topGuideDetail: object)
                    self.arrayOfGuide.append(objectExperience)
                }
                DispatchQueue.main.async {
                    UIView.performWithoutAnimation {
                        self.collectionViewGuide.reloadData()
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
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    //PushToGuideDetail
    func pushToGuideDetailController(objGuide:TopGuideData){
        if let guideViewController = self.storyboard?.instantiateViewController(withIdentifier: "GuideDetailViewController") as? GuideDetailViewController{
            guideViewController.topGuideDetailData = objGuide
            self.navigationController?.pushViewController(guideViewController, animated: true)
        }
    }
}
extension AllGuideViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.arrayOfGuide.count > 0 {
            collectionView.removeMessageLabel()
        }else{
            collectionView.showMessageLabel()
        }
        return self.arrayOfGuide.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let guideCell:GuideCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuideCollectionViewCell", for: indexPath) as! GuideCollectionViewCell
        if  self.arrayOfGuide.count > indexPath.item{
            let objectGuide = self.arrayOfGuide[indexPath.item]
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
                    guideCell.txtGuideDiscription.shouldTrim = true
                    guideCell.txtGuideDiscription.maximumNumberOfLines = 4
                    guideCell.txtGuideDiscription.attributedReadMoreText = readMoreAttriString
                }
            } else {
                guideCell.txtGuideDiscription.textContainer.maximumNumberOfLines = 0
            }
            if indexPath.item == (self.arrayOfGuide.count - 1) , self.isAllGuideLoadMore{ //last index
                //if (self.arrayOfBestRatedExperience.count < collectionView.visibleCells.count) {
                DispatchQueue.global(qos: .background).async {
                    self.currentGuidePageIndex += 1
                    self.getGuidesRequetsAPI()
                }
                //}
            }
        }
        return guideCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize.init(width: collectionView.bounds.size.width*0.5-27, height:  200.0+36.0)//collectionView.bounds.size.width*0.5+50+30)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.init(top: 20, left: 20, bottom: 0, right: 20)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 15.0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.arrayOfGuide.count > indexPath.item{
           self.pushToGuideDetailController(objGuide:self.arrayOfGuide[indexPath.item])
        }
    }
}
extension AllGuideViewController:GuideDescriptionReadMore{
    func readMorePressedFromGuideDescription(index: Int) {
        if self.arrayOfGuide.count > index{
            self.pushToGuideDetailController(objGuide:self.arrayOfGuide[index])
        }
    }
}
