//
//  InstantOpenController.swift
//  Live
//
//  Created by ips on 19/04/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import MobileCoreServices
protocol PreViewMediaDelegate {
    func setMainImageDelegatePreview(currentPage:Int)
    func deleteMediaDelegatePreview(currentPage:Int,isVideo:Bool)
}
class InstantOpenController: UIViewController, UIScrollViewDelegate {
    var urlString: String = ""
    var isVideo: Bool = false
    @IBOutlet weak var image: ImageViewForURL!
    @IBOutlet var playerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    var player = AVPlayer()
    var playerViewController = AVPlayerViewController()
    var previewMediaDelegate:PreViewMediaDelegate?
    @IBOutlet var butttonSelectAsCover:UIButton!
    @IBOutlet var buttonDeleteMedia:UIButton!
     @IBOutlet weak var imageNext: UIImageView!
     @IBOutlet weak var imagePrevous: UIImageView!
    @IBOutlet var buttonNext:UIButton!
    @IBOutlet var buttonPrevious:UIButton!
    
    var currentPage:Int = 0
    var isFromAddExperience:Bool = false
    let alertTitleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17.0)!]
    let alertMessageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
    }
    var imagesArr: [String] = []
    var videoArr: [String] = []
    var thumbnailArr:[NSString] = []
    var arrayOfPreview:[NSString] = []
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isFromAddExperience{
            if self.isVideo{
                self.butttonSelectAsCover.isHidden = true
            }else{
                self.butttonSelectAsCover.isHidden = false
            }
            self.buttonDeleteMedia.isHidden = false
            self.buttonNext.isHidden = true
            self.imageNext.isHidden = true
            self.buttonPrevious.isHidden = true
            self.imagePrevous.isHidden = true
        }else{
            self.buttonNext.isHidden = false
            self.imageNext.isHidden = false
            self.buttonPrevious.isHidden = false
            self.imagePrevous.isHidden = false
            
            self.butttonSelectAsCover.isHidden = true
            self.buttonDeleteMedia.isHidden = true
            
        }
        if !self.isFromAddExperience,!self.isVideo{
            self.addTapGesture()
        }
        if !isVideo {
            if urlString != "" {
                self.playerView.isHidden = true
                self.playerViewController.view.removeFromSuperview()
                self.stopVideo()
                self.scrollView.isHidden = false
                self.image.isHidden = false
                self.image.imageFromServerURL(urlString:urlString)
            }
            
        } else {
            self.playerView.isHidden = false
            self.scrollView.isHidden = true
            self.image.isHidden = true
            self.playerView.isHidden = false
            if let url = URL.init(string: urlString){
                self.playVideo(videoUrl: url)
                self.player.play()
            }
            self.playerViewController.showsPlaybackControls = true
            self.navigationController?.navigationBar.isHidden = true
            UIApplication.shared.statusBarStyle = .lightContent
            // Do any additional setup after loading the view.
        }
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
        
    }
    func reloadController(){
        if self.isFromAddExperience{
            if self.isVideo{
                self.butttonSelectAsCover.isHidden = true
            }else{
                self.butttonSelectAsCover.isHidden = false
            }
            self.buttonDeleteMedia.isHidden = false
        }else{
            self.butttonSelectAsCover.isHidden = true
            self.buttonDeleteMedia.isHidden = true
        }
        if !self.isFromAddExperience,!self.isVideo{
            self.addTapGesture()
        }
        
        self.playerViewController.view.removeFromSuperview()
        if !isVideo {
            if urlString != "" {
                self.playerView.isHidden = true
                self.stopVideo()
                self.scrollView.isHidden = false
                self.image.isHidden = false
                self.image.imageFromServerURL(urlString:urlString)
            }
            
        } else {
            self.playerView.isHidden = false
            self.scrollView.isHidden = true
            self.image.isHidden = true
            self.playerView.isHidden = false
            if let url = URL.init(string: urlString){
                self.playVideo(videoUrl: url)
                self.player.play()
            }
            self.playerViewController.showsPlaybackControls = true
            self.navigationController?.navigationBar.isHidden = true
            UIApplication.shared.statusBarStyle = .lightContent
            // Do any additional setup after loading the view.
        }
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addTapGesture(){
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(InstantOpenController.tapDetected))
        self.image.isUserInteractionEnabled = true
        self.image.addGestureRecognizer(singleTap)
    }
    //Action
    @objc func tapDetected() {
         self.dismiss(animated: false, completion: nil)
    }
    func addDynamicFont(){
        self.butttonSelectAsCover.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.butttonSelectAsCover.titleLabel?.adjustsFontForContentSizeCategory = true
        self.butttonSelectAsCover.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.butttonSelectAsCover.setTitle(Vocabulary.getWordFromKey(key: "selectAsCover.hint"), for: .normal)

    }
    func stopVideo(){
        self.playerView.isHidden = true
        self.player.pause()
    }
    
    func playVideo(videoUrl:URL){
        self.playerViewController.view.removeFromSuperview()
        let objAsset = AVURLAsset.init(url: videoUrl)
        let objPlayerItem = AVPlayerItem.init(asset: objAsset)
        self.player = AVPlayer.init(playerItem: objPlayerItem)
        self.playerViewController.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
        self.playerViewController.player = self.player
        self.playerViewController.view.frame = self.playerView.frame
        self.playerView.addSubview(self.playerViewController.view)
        self.player.isMuted = true
        self.player.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return image
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- Selector Methods
    @IBAction func buttonNextSelector(sender:UIButton){
        if !self.isFromAddExperience,self.imagesArr.count+self.videoArr.count > 1{
            
            if self.imagesArr.count+self.videoArr.count == self.currentPage+1{
                if var objURL = self.arrayOfPreview.first{
                    if self.imagesArr.contains(objURL as String){
                         //if self.imagesArr.count > 0{
                         //let url = self.imagesArr.first!
                         self.currentPage = 0
                         self.urlString = objURL as String//url
                         self.isVideo = false
                         self.reloadController()
                      }else{//}else if self.videoArr.count > 0{
                        if let videoIndex = self.thumbnailArr.index(where: {$0 == objURL}),self.videoArr.count > 0{
                            objURL = self.videoArr[videoIndex] as NSString
                        }
                           // let url = self.videoArr.first!
                            self.currentPage = 0
                            self.urlString = objURL as String//url
                            self.isVideo = true
                            self.reloadController()
                        }
                }
            }else{
                self.currentPage += 1
                if self.arrayOfPreview.count > self.currentPage{
                    var objURL = self.arrayOfPreview[self.currentPage]
                    if self.imagesArr.contains(objURL as String){
                        self.urlString = objURL as String//url
                        self.isVideo = false
                        self.reloadController()
                    }else{
                        if let videoIndex = self.thumbnailArr.index(where: {$0 == objURL}),self.videoArr.count > 0{
                            objURL = self.videoArr[videoIndex] as NSString
                        }
                        self.urlString = objURL as String//url
                        self.isVideo = true
                        self.reloadController()
                    }
                }
                /*
                if self.imagesArr.count+self.videoArr.count > self.currentPage{
                if self.currentPage > self.imagesArr.count{
                    let videoIndex = self.currentPage - self.imagesArr.count
                    if self.videoArr.count > videoIndex{
                        let url = self.videoArr[videoIndex]
                        self.urlString = url
                        self.isVideo = true
                        self.reloadController()
                    }
                }else{
                    if self.imagesArr.count == self.currentPage{
                        if self.videoArr.count > 0{
                            let url = self.videoArr.first!
                            self.urlString = url
                            self.isVideo = true
                            self.reloadController()
                        }else{
                            let url = self.imagesArr.first!
                            self.currentPage = 0
                            self.urlString = url
                            self.isVideo = false
                            self.reloadController()
                        }
                    }else{
                        let url = self.imagesArr[self.currentPage]
                        self.urlString = url
                        self.isVideo = false
                        self.reloadController()
                    }
                }
                }*/
            }
        }
        
    }
    @IBAction func buttonPreviousSelector(sender:UIButton){
        if !self.isFromAddExperience,self.imagesArr.count+self.videoArr.count > 1  {
            if self.currentPage == 0{
                if var objURL = self.arrayOfPreview.last{
                    if self.imagesArr.contains(objURL as String){
                        //if self.imagesArr.count > 0{
                        //let url = self.imagesArr.first!
                        self.currentPage = self.imagesArr.count+self.videoArr.count - 1//0
                        self.urlString = objURL as String//url
                        self.isVideo = false
                        self.reloadController()
                    }else{//}else if self.videoArr.count > 0{
                        if let videoIndex = self.thumbnailArr.index(where: {$0 == objURL}),self.videoArr.count > 0{
                            objURL = self.videoArr[videoIndex] as NSString
                        }
                        // let url = self.videoArr.first!
                        self.currentPage = self.imagesArr.count+self.videoArr.count - 1//0
                        self.urlString = objURL as String//url
                        self.isVideo = true
                        self.reloadController()
                    }
                }

                /*
                if self.videoArr.count > 0{
                    let url = self.videoArr.last!
                    self.currentPage = self.imagesArr.count+self.videoArr.count - 1
                    self.urlString = url
                    self.isVideo = true
                    self.reloadController()
                }else if self.imagesArr.count > 0{
                    let url = self.imagesArr.last!
                    self.currentPage = self.imagesArr.count+self.videoArr.count - 1
                    self.urlString = url
                    self.isVideo = false
                    self.reloadController()
                }*/
            }else{
                self.currentPage -= 1
                if self.arrayOfPreview.count > self.currentPage{
                    var objURL = self.arrayOfPreview[self.currentPage]
                    if self.imagesArr.contains(objURL as String){
                        self.urlString = objURL as String//url
                        self.isVideo = false
                        self.reloadController()
                    }else{
                        if let videoIndex = self.thumbnailArr.index(where: {$0 == objURL}),self.videoArr.count > 0{
                            objURL = self.videoArr[videoIndex] as NSString
                        }
                        self.urlString = objURL as String//url
                        self.isVideo = true
                        self.reloadController()
                    }
                }
                /*
                if self.imagesArr.count+self.videoArr.count > self.currentPage{
                    if self.currentPage > self.imagesArr.count{
                        let videoIndex = self.currentPage - self.imagesArr.count
                        if self.videoArr.count > videoIndex{
                            let url = self.videoArr[videoIndex]
                            self.urlString = url
                            self.isVideo = true
                            self.reloadController()
                        }
                    }else{
                        if self.imagesArr.count == self.currentPage{
                            if self.videoArr.count > 0{
                                let url = self.videoArr.first!
                                self.urlString = url
                                self.isVideo = true
                                self.reloadController()
                            }else{
                                let url = self.imagesArr.first!
                                self.currentPage = 0
                                self.urlString = url
                                self.isVideo = false
                                self.reloadController()
                            }
                        }else{
                            let url = self.imagesArr[self.currentPage]
                            self.urlString = url
                            self.isVideo = false
                            self.reloadController()
                            
                        }
                    }
                }*/
            }
        }
    }
    
    @IBAction func buttonDeleteSelector(sender:UIButton){
        if let _ = self.previewMediaDelegate{
            let deleteAlert = UIAlertController(title: Vocabulary.getWordFromKey(key:"Experience.title"), message: Vocabulary.getWordFromKey(key:"delete.msg"),preferredStyle: UIAlertControllerStyle.alert)
            deleteAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (action: UIAlertAction!) in
                if let _ = self.previewMediaDelegate{
                    self.previewMediaDelegate!.deleteMediaDelegatePreview(currentPage: self.currentPage, isVideo: self.isVideo)
                }
            }))
            deleteAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"no"), style: .cancel, handler: nil))
            self.view.endEditing(true)
            let titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key: "Experience.title"), attributes: self.alertTitleFont)
            let messageAttrString = NSMutableAttributedString(string:Vocabulary.getWordFromKey(key:"delete.msg"), attributes: self.alertMessageFont)
            
            deleteAlert.setValue(titleAttrString, forKey: "attributedTitle")
            deleteAlert.setValue(messageAttrString, forKey: "attributedMessage")
            deleteAlert.view.tintColor = UIColor(hexString: "#36527D")
            // UIApplication.shared.keyWindow?.rootViewController
            //UIApplication.shared.keyWindow?.rootViewController?
            //self.dismiss(animated: true, completion: nil)
            self.present(deleteAlert, animated: true, completion: nil)
        }
    }
    @IBAction func buttonMakeCoverSelector(sender:UIButton){
        if let _ = self.previewMediaDelegate{
            self.previewMediaDelegate!.setMainImageDelegatePreview(currentPage: self.currentPage)
        }
    }
}
