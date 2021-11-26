//
//  LocationRequestViewController.swift
//  Live
//
//  Created by ips on 14/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import MobileCoreServices

var isFromRequestLocation: Bool = false
class LocationRequestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
  
    @IBOutlet weak var locationImage: ImageViewForURL!
    var selectedCountry: String = ""
    var imagePicker:UIImagePickerController = UIImagePickerController()
    @IBOutlet weak var saveBtn: RoundButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var locationRequestTblView: UITableView!
    @IBOutlet weak var lblNavTitle: UILabel!
    var isVideoFile:Bool = false
    var imgUrl: String = ""
    var locationData = [String: String]()
    var state: String = ""
    var city: String = ""
    let dataArr = [Vocabulary.getWordFromKey(key:"SelectCoutry"), Vocabulary.getWordFromKey(key:"State"), Vocabulary.getWordFromKey(key:"City")]
    var headerViewHeight = UIScreen.main.bounds.size.height > 568.0 ? 270.0 : 188.0
    var topController: UIViewController? {
        if var temp = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = temp.presentedViewController {
                temp = presentedViewController
            }
            return temp
        }
        return nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        lblNavTitle.text = Vocabulary.getWordFromKey(key: "LocationRequest")
        self.saveBtn.setTitle(Vocabulary.getWordFromKey(key: "save.title"), for: .normal)
        //Register TableViewCell
        self.saveBtn.layer.cornerRadius = 15.0
        self.saveBtn.addBorderWith(width: 1.0, color: .black)
        self.imagePicker.delegate = self
        let objNib = UINib.init(nibName: "LogInTableViewCell", bundle: nil)
        self.locationRequestTblView.register(objNib, forCellReuseIdentifier: "LogInTableViewCell")
        self.locationRequestTblView.tableHeaderView = headerView
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapImage))
        tap.delegate = self
        self.imagePicker.allowsEditing = true
        self.locationImage.isUserInteractionEnabled = true
        self.locationImage.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if let value = locationData["name"] {
            self.selectedCountry = value
        }
        self.swipeToPop()
    }
    func swipeToPop() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    /*
    func testUploadVideo(){
     if let urlpath = Bundle.main.path(forResource: "sample", ofType: "mp4"),let videoURL:NSURL = NSURL.fileURL(withPath: urlpath) as NSURL{
        guard let data = NSData(contentsOf: videoURL as URL) else {
            return
     }
     ProgressHud.show()
     
     print("File size before compression: \(Double(data.length / 1048576)) mb")
     
     let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + "\(videoURL.lastPathComponent)")
     
        self.compressVideo(inputURL: videoURL as URL, outputURL: compressedURL) { (exportSession) in
     guard let session = exportSession else {
        return
     }
     if session.status == .completed{
        guard let compressedData = NSData(contentsOf: compressedURL) else {
            return
     }
        self.uploadVideoRequest(videoData: compressedData as Data, videoName:"\(videoURL.lastPathComponent ?? "")")
     }else{
        ShowToast.show(toatMessage:kCommonError)
                }
            }
        }
     }*/
    // Gesture Handler
   @objc func handleTapImage() {
        //Present ImagePicker
        let actionSheet = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"LocationImage"), message:Vocabulary.getWordFromKey(key:"LocationImage.msg"), preferredStyle: .actionSheet)
        let cancel = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler: nil)
        actionSheet.addAction(cancel)
        let photoLiberary = UIAlertAction.init(title:  Vocabulary.getWordFromKey(key:"Photos"), style: .default) { (_) in
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.isEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        actionSheet.addAction(photoLiberary)
        let videoSelector = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Videos"), style: .default) { (_) in
            DispatchQueue.main.async {
                self.imagePicker = UIImagePickerController()
                self.imagePicker.delegate = self
                //self.objImagePickerController.allowsEditing = false
                self.imagePicker.sourceType = .photoLibrary
                self.imagePicker.mediaTypes = [kUTTypeMovie as String]
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
    actionSheet.addAction(videoSelector)
        let camera = UIAlertAction.init(title:  Vocabulary.getWordFromKey(key:"Camera"), style: .default) { (_) in
            if CommonClass.isSimulator{
                DispatchQueue.main.async {
                    let noCamera = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"Cameranotsupported"), message: "", preferredStyle: .alert)
                    noCamera.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .cancel, handler: nil))
                    self.present(noCamera, animated: true, completion: nil)
                }
            }else{
                self.imagePicker = UIImagePickerController()
                self.imagePicker.delegate = self
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .camera
                self.imagePicker.mediaTypes = [kUTTypeImage as String,kUTTypeMovie as String]
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        actionSheet.addAction(camera)
    if locationImage.image != nil {
        let removeImage = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Remove"), style: .default) { (_) in
            self.locationImage.image = nil
            self.imgUrl = ""
        }
        actionSheet.addAction(removeImage)
    }
        self.present(actionSheet, animated: true, completion: nil)
    }
 
    // MARK:-  UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationRequestTableViewCell") as! LocationRequestTableViewCell
        guard indexPath.row < dataArr.count else {
            return cell
        }
        cell.locationRequestFields.tag = indexPath.row
        cell.locationRequestFields.delegate = self
        if indexPath.row == 0 {
            if self.selectedCountry == "" {
            cell.locationRequestFields.tweePlaceholder = dataArr[indexPath.row]
            } else {
                cell.locationRequestFields.tweePlaceholder = dataArr[indexPath.row]
                cell.locationRequestFields.text = self.selectedCountry
            }
            cell.locationRequestFields.isUserInteractionEnabled = false
            cell.selectCountry.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
        } else {
            cell.locationRequestFields.isHidden = false
            cell.locationRequestFields.tweePlaceholder = dataArr[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 55.0
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            isFromRequestLocation = true
            self.presentSearchCountry()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

    func updateActiveLine(textfield:TweeActiveTextField,color:UIColor){
        textfield.activeLineColor = color
        textfield.lineColor = color
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        if textField.tag == 0 {
            textField.text = selectedCountry
        }
        else if textField.tag == 1 {
            if textField.text == "" {
                self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .black)
                textField.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"enterState"))
            } else {
                self.state = textField.text!
            }
        }
        else if textField.tag == 2 {
            if textField.text == "" {
                self.updateActiveLine(textfield:(textField as! TweeActiveTextField), color: .black)
                textField.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"enterCity"))
            } else {
                self.city = textField.text!
            }
        }
    }
    
    // Select Country Pressed
    @objc func buttonClicked() {
        isFromRequestLocation = true
        self.presentSearchCountry()
    }
    
    //MARK:- UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! CFString
        
        switch mediaType {
        case kUTTypeImage:
            if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage,let imageData = editedImage.jpeg(.lowest){
                print("\(Date().ticks)")
                self.uploadImageRequest(imageData: imageData, imageName:"image")
            }
            break
        case kUTTypeMovie:
            if let videoURL = info[UIImagePickerControllerMediaURL] as? URL{
                
                guard let data = NSData(contentsOf: videoURL as URL) else {
                    DispatchQueue.main.async {
                        ProgressHud.hide()
                    }
                    return
                }
                DispatchQueue.main.async {
                    ProgressHud.show()
                }
                print("File size before compression: \(Double(data.length / 1048576)) mb")
                let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
                self.compressVideo(inputURL: videoURL as URL, outputURL: compressedURL) { (exportSession) in
                    guard let session = exportSession else {
                        DispatchQueue.main.async {
                            ProgressHud.hide()
                        }
                        return
                    }
                    if session.status == .completed{
                        guard let compressedData = NSData(contentsOf: compressedURL) else {
                            DispatchQueue.main.async {
                                ProgressHud.hide()
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            ProgressHud.show()
                        }
                        self.uploadVideoRequest(videoData: compressedData as Data, videoName:"\(videoURL.lastPathComponent)")
                    }else{
                        DispatchQueue.main.async {
                            ProgressHud.hide()
                            ShowToast.show(toatMessage:kCommonError)
                        }
                    }
                }
                
            }
            break
        case kUTTypeLivePhoto:
            
            break
        default:
            break
        }
        
        picker.dismiss(animated: true, completion: nil)
      
        
    }
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Selector Method
    @IBAction func saveBtnPressed(_ sender: Any) {
        if selectedCountry == "", self.city == "", self.state == "", self.imgUrl == "" {
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"enterData"))
        }
        else if self.imgUrl == "" {
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"selectImage"))
        }
        else if self.selectedCountry == "" {
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"selectCountry"))
        }
        else if self.state == "" {
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"enterState"))
        }
        else if self.city == "" {
            ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key:"enterCity"))
        }
        else {
            self.sendLocationRequest()
        }
    }
    @IBAction func cameraBtnPressed(_ sender: Any) {
       self.handleTapImage()
    }
    @IBAction func uploadImagePressed(_ sender: Any) {
        self.imagePicker.sourceType = .photoLibrary
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- API Calling
    func uploadImageRequest(imageData:Data,imageName:String){
        let parameters = [
            "file_name": "\(imageName)"
        ]
        let requestURL = "amazons3/native/location/imagevideo/upload/\(imageName)"
        APIRequestClient.shared.uploadImage(requestType: .POST, queryString: requestURL, parameter: parameters as [String : AnyObject], imageData: imageData, isHudeShow: true, success: { (sucessResponse) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if let success = sucessResponse as? [String:Any],let successData = success["data"] as? [String:Any],let uploadedImageURL = successData["videoImageUrl"] as? String{
                self.isVideoFile = false
                self.imgUrl = uploadedImageURL
                self.locationImage.imageFromServerURL(urlString: self.imgUrl)
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: kCommonError)
                }
            }
        }) { (failResponse) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if let failData = failResponse as? [String:Any],let failMessage = failData["Message"]{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(failMessage)")
                }
            }
        }
    }
    //Upload Video
    func uploadVideoRequest(videoData:Data,videoName:String){
        let parameters = [ "file_name":"video"]
        let requestUploadVideoURL = "amazons3/native/location/imagevideo/upload/video"

        APIRequestClient.shared.uploadVideo(requestType: .POST, queryString: requestUploadVideoURL, parameter: parameters as [String : AnyObject], videoData: videoData, isHudeShow: true, success: { (sucessResponse) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if let success = sucessResponse as? [String:Any],let successData = success["data"] as? [String:Any],let urls = successData["videoImageUrl"] as? [String:Any],let videoURL = urls["VideoUrl"],let thumnailURL = urls["ThumbImgUrl"]{
                self.imgUrl = "\(videoURL)"
                self.isVideoFile = true
                self.locationImage.imageFromServerURL(urlString:"\(thumnailURL)")
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }) { (failResponse) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if let arrayFail = failResponse as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
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
    func sendLocationRequest() {  // API for Location Request
        let currentUser: User? = User.getUserFromUserDefault()
        let userId: String = (currentUser?.userID)!
        let urlLocationRequest = "guides/\(userId)/native/locationrequest"
        let countryId = locationData["id"]
        let requestParameters =
            ["Country":"\(countryId!)",
             "State":self.state,
             "City":self.city,
             "ImagePath":self.imgUrl,
             "IsVideo":"\(self.isVideoFile)"
                ] as[String : AnyObject]
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: urlLocationRequest, parameter: requestParameters, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let _ = success["data"] as? [String:Any] {
                if let dataDic = success["data"] as? [String:Any] {
                    DispatchQueue.main.async {
                        guard let top = self.topController else { return }
                        let locationRequestAlert = UIAlertController(title: Vocabulary.getWordFromKey(key:"RequestLocation"), message: "\(dataDic["Message"]!)",preferredStyle: UIAlertControllerStyle.alert)
                        locationRequestAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (action: UIAlertAction!) in
                                self.navigationController?.popViewController(animated: true)
                        }))
                        top.present(locationRequestAlert, animated: false, completion: nil)
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
    
    @IBAction func unwindToLocationRequest(segue: UIStoryboardSegue) {
        viewWillAppear(true)
        DispatchQueue.main.async {
            let cell = self.locationRequestTblView.dequeueReusableCell(withIdentifier: "LocationRequestTableViewCell") as! LocationRequestTableViewCell
            if cell.locationRequestFields.tag == 0 {
                cell.locationRequestFields.text = self.selectedCountry
                let indexPath = IndexPath(item: 0, section: 0)
                self.locationRequestTblView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }

    // MARK: - Navigation
    func presentSearchCountry() { // Present SearchCountry
        if let searchCountryViewController = self.storyboard?.instantiateViewController(withIdentifier:"CountrySearchViewController") as? CountrySearchViewController {
            searchCountryViewController.modalPresentationStyle = .overFullScreen
            present(searchCountryViewController, animated: false, completion: nil)
        }
    }

}
