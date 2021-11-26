//
//  ReviewViewController.swift
//  Live
//
//  Created by IPS on 07/06/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
@objc  protocol ReviewControlDelegate {
    @objc optional  func cancelExperienceReview(objExperience:Experience)
    @objc optional  func submitExperienceReview(objExperience:Experience,reviewData:[String:Any])
    @objc optional  func cancelGuideReview()
    @objc optional  func submittedGuideReview(objGuide:TopGuideData)
}
class ReviewViewController: UIViewController {

    
    
    private var kReview = "Review"
    private var kReviewComment = "Comment"
    private var kUserID = "UserId"
    private var kExperienceID = "ExperienceId"
    private var kGuideID = "GuideId"
    private var kUserName = "UserName"
    @IBOutlet weak var containerTopMultiplier: NSLayoutConstraint!
    
    @IBOutlet var buttonCancel:UIButton!
    @IBOutlet var buttonSubmit:UIButton!
    @IBOutlet var imageExperience:ImageViewForURL!
    @IBOutlet var lblExperienceName:UILabel!
    @IBOutlet var txtExperienceReview:UITextView!
    @IBOutlet var containerView:UIView!
    @IBOutlet var objFloatRatingView:FloatRatingView!
    var addReviewParameters:[String:Any] = [:]
    var objExperience:Experience?
    var objReviewDelegate:ReviewControlDelegate?
    var guideDetail:TopGuideData?
    var isGuideReview:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            //Configure RatingView
            self.configureRatingView()
            self.buttonCancel.setTitle(Vocabulary.getWordFromKey(key: "Cancel"), for: .normal)
            self.buttonSubmit.setTitle(Vocabulary.getWordFromKey(key: "sendReview.title"), for: .normal)
            self.txtExperienceReview.textContainer.lineFragmentPadding = 0
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.lblExperienceName.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblExperienceName.adjustsFontForContentSizeCategory = true
        self.lblExperienceName.adjustsFontSizeToFitWidth = true
        
        self.txtExperienceReview.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        
        self.buttonCancel.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonCancel.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonCancel.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.buttonSubmit.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonSubmit.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonSubmit.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Methods
    func configureRatingView(){
        self.objFloatRatingView.type = .halfRatings
        self.txtExperienceReview.text = Vocabulary.getWordFromKey(key: "review.hint")
        self.txtExperienceReview.textColor = UIColor.lightGray
        self.imageExperience.layer.cornerRadius = self.imageExperience.frame.width / 2.0
        self.imageExperience.clipsToBounds = true
        self.txtExperienceReview.delegate = self
        self.containerView.layer.cornerRadius = 14.0
        self.imageExperience.contentMode = .scaleAspectFill
        self.imageExperience.clipsToBounds = true
        self.containerView.clipsToBounds = true
        if let _ = self.objExperience{
            if self.objExperience!.mainImage.count > 0{
                self.imageExperience.imageFromServerURL(urlString:self.objExperience!.mainImage)
            }else{
                self.imageExperience.image = UIImage.init(named:"expriencePlaceholder")
            }
            self.lblExperienceName.text = "\(self.objExperience!.title)"
            self.objFloatRatingView.rating =  Double(self.objExperience!.averageReview)!
            if self.objExperience!.comment.count > 0{
                self.txtExperienceReview.text = "\(self.objExperience!.comment)"
                self.txtExperienceReview.textColor = UIColor.black
                self.addReviewParameters[kReviewComment] = "\(self.objExperience!.comment)"
            }else{
                self.txtExperienceReview.text = Vocabulary.getWordFromKey(key: "review.hint")
                self.txtExperienceReview.textColor = UIColor.lightGray
            }
            if let _ = self.objExperience!.userReview{
                //No Edit user review
                self.objFloatRatingView.editable = false
                self.txtExperienceReview.isEditable = false
                self.buttonSubmit.isHidden = true
//                self.leadingStackConstraint.constant = width
//                self.trailingStackConstraint.constant = width
                self.objFloatRatingView.rating =  Double("\(self.objExperience!.userReview!)")!
            }else{
                //Edit user review
                self.objFloatRatingView.editable = true
                self.txtExperienceReview.isEditable = true
                self.buttonSubmit.isHidden = false
//                self.leadingStackConstraint.constant = 35.0
//                self.trailingStackConstraint.constant = 35.0
            }
        }
        if let _ = self.guideDetail{
            if self.guideDetail!.image.count > 0{
                 self.imageExperience.imageFromServerURL(urlString:self.guideDetail!.image)
            }else{
                 self.imageExperience.image = UIImage.init(named:"ic_profile")!
            }
            self.lblExperienceName.text = "\(self.guideDetail!.guideName)"
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonCancelSelector(sender:UIButton){
        self.dismiss(animated: true, completion: nil)
        if self.isGuideReview{
            if let _ = self.objReviewDelegate{
                self.objReviewDelegate?.cancelGuideReview!()
            }
        }else {
            if let _ = self.objReviewDelegate,let _ = self.objExperience{
                self.objReviewDelegate?.cancelExperienceReview!(objExperience: self.objExperience!)
            }
        }
        
    }
    @IBAction func buttonSubmitSelector(sender:UIButton){
        self.updateRatingRequestAPI()
    }
    // MARK: - API request Methods
    func updateRatingRequestAPI(){
        if User.isUserLoggedIn,let user = User.getUserFromUserDefault(){
            self.addReviewParameters[kUserID] = "\(user.userID)"
            self.addReviewParameters[kUserName] = "\(user.userFirstName) \(user.userLastName)"
            if self.isGuideReview{
                if let _ = self.guideDetail{
                    self.addReviewParameters[kGuideID] = "\(self.guideDetail!.id)"
                }
            }else{
                if let _ = self.objExperience{
                    self.addReviewParameters[kExperienceID] = "\(self.objExperience!.id)"
                }
            }
            
            
            self.addReviewParameters[kReview] = "\(self.objFloatRatingView.rating)"
            print("\(self.addReviewParameters)")
            var requestURLUpdateReview = "experience/native/past"
            if self.isGuideReview{
                requestURLUpdateReview = "guides/guidereview"
            }else{
                requestURLUpdateReview = "experience/native/past"
            }
            
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString: requestURLUpdateReview, parameter: self.addReviewParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
                
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let strMSG = successData["Message"]{
                    DispatchQueue.main.async {
                        let backAlert = UIAlertController(title:Vocabulary.getWordFromKey(key:"Success"), message:"\(strMSG)",preferredStyle: UIAlertControllerStyle.alert)
                        backAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (action: UIAlertAction!) in
                          self.dismiss(animated: true, completion: nil)
                            if self.isGuideReview{
                                if let _ = self.guideDetail{
                                    self.objReviewDelegate?.submittedGuideReview!(objGuide:self.guideDetail!)
                                }
                                //self.objReviewDelegate?.submittedGuideReview(objGuide: <#T##TopGuideData#>, reviewData: <#T##[String : Any]#>)
                            }else{
                                if let _ = self.objReviewDelegate{
                                    if let _ = self.objExperience{
                                        self.dismiss(animated: true, completion: nil)
                                        self.objReviewDelegate?.submitExperienceReview!(objExperience: self.objExperience!,reviewData: self.addReviewParameters)
                                    }
                                }else{
                                    self.performSegue(withIdentifier:"unwindToMyLiveViewFromRatingView", sender: nil)
                                }
                            }
                        }))
                        self.present(backAlert, animated: true, completion: nil)
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
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
extension ReviewViewController:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Vocabulary.getWordFromKey(key: "review.hint")
            textView.textColor = UIColor.lightGray
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
  
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        if updatedText.isEmpty {
            textView.text = Vocabulary.getWordFromKey(key: "review.hint")
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            self.addReviewParameters[kReviewComment] = "\(updatedText)"

        }else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }else{
            self.addReviewParameters[kReviewComment] = "\(updatedText)"
            return true
        }
        return false
    }
//    func textViewDidChangeSelection(_ textView: UITextView) {
//        if self.view.window != nil {
//            if textView.textColor == UIColor.lightGray {
//                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
//            }
//        }
//    }
}
