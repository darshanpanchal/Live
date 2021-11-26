//
//  BookDetailHeaderCell.swift
//  Live
//
//  Created by ips on 17/04/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

var isFromAddExperience: Bool = false
@objc protocol openImgaeFromSelectionofPageControl: class {
     func openNewImageView(imgUrl: String, isvideo: Bool,currentPage:Int,imageArray:[String],videoArray:[String])
     @objc optional func currentPageSetter(currentPage:Int)
}
protocol AddExperienceDelegate {
    func setMainImageDelegate(currentPage:Int)
    func deleteMediaDelegate(currentPage:Int,isVideo:Bool)
    func deleteOnlyMediaDelegate(currentPage:Int,isVideo:Bool)
    func hideKeyboardSelectorFromHeader()
}
class BookDetailHeaderCell: UITableViewCell, UIScrollViewDelegate {
    weak var openImageDelegate: openImgaeFromSelectionofPageControl?
    var addExperienceDelegate:AddExperienceDelegate?
    
    @IBOutlet weak var scrViewTopConstant: NSLayoutConstraint!
    @IBOutlet var view: UIView!
    @IBOutlet var videoImg: UIImageView!
    @IBOutlet weak var scrMain: UIScrollView!
    @IBOutlet var pageControl: CustomPageControl!
    @IBOutlet var hintView:UIView!
    @IBOutlet var btnDelete:UIButton!
    @IBOutlet var btnDeleteOnly:UIButton!
    @IBOutlet var btnMainImage:UIButton!
    @IBOutlet var lblHintLable:UILabel!

    var imagesArr: [String] = []
    var videoArr: [String] = []
    var thumbnailArr: [String] = []
    var isForAddExperience:Bool = false
    var mainImage:Int?
    var loadedIndex:NSMutableSet = NSMutableSet()
    var arrayOfPreview:[NSString] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            if isFromAddExperience {
                self.scrViewTopConstant.constant = 0
            } else {
                self.scrViewTopConstant.constant = -45
            }
        }
        self.btnMainImage.setTitle(Vocabulary.getWordFromKey(key: "mainImage"), for: .normal)
        self.btnDelete.setTitle(Vocabulary.getWordFromKey(key: "delete"), for: .normal)
        self.btnDeleteOnly.setTitle(Vocabulary.getWordFromKey(key: "delete"), for: .normal)
        self.lblHintLable.text = Vocabulary.getWordFromKey(key: "lblHintCamera")
        self.scrMain.delegate = self
        self.scrMain.isPagingEnabled = true
        self.layoutIfNeeded()
        // Initialization code
        self.addShadowOnPlay()
        self.addBorderOnButton(sender:btnDelete )
        self.addBorderOnButton(sender:btnDeleteOnly)
        self.addBorderOnButton(sender: btnMainImage)
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        //self.lblHintLable.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Medium", textStyle: .title1)
        self.lblHintLable.adjustsFontForContentSizeCategory = true
        self.lblHintLable.adjustsFontSizeToFitWidth = true
    }
    func addShadowOnPlay(){
        videoImg.layer.shadowColor = UIColor.black.cgColor
        videoImg.layer.shadowOffset = CGSize.init(width: 0, height:5.0)
        videoImg.layer.shadowOpacity = 1.0
        videoImg.layer.shadowRadius = 5.0
        videoImg.layer.masksToBounds = false
    }
    func addBorderOnButton(sender:UIButton){
        sender.layer.borderColor = UIColor.white.cgColor
        sender.layer.borderWidth = 1.0
        sender.clipsToBounds = true
    }
    func loadScrollView(mediaDic: [String:[String]]) {
        self.imagesArr = []
        self.videoArr = []
        self.imagesArr = mediaDic["Image"]!
        self.videoArr = mediaDic["Video"]!
        self.thumbnailArr = mediaDic["Thumbnail"]!
        
        var arr = self.imagesArr.count + self.videoArr.count
        print(self.arrayOfPreview)
        
        let pageCount : CGFloat = CGFloat(arr)
        scrMain.backgroundColor = UIColor.clear
        scrMain.delegate = self
        scrMain.isPagingEnabled = true
        scrMain.contentSize = CGSize(width: scrMain.frame.size.width * pageCount, height: scrMain.frame.size.height)
        scrMain.showsHorizontalScrollIndicator = false

        pageControl.numberOfPages = Int(pageCount)
        pageControl.addTarget(self, action: #selector(self.pageChanged), for: .valueChanged)
        if pageCount > 1 {
            self.addSubview(pageControl)
        }
//        if pageCount == 0, self.imagesArr.count == 0, thumbnailArr.count == 0 {
//            let image1: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
//            image1.image = #imageLiteral(resourceName: "expriencePlaceholder")
//            image1.contentMode = UIViewContentMode.scaleToFill
//            self.scrMain.addSubview(image1)
//        }
        for i in 0..<Int(pageCount) {
                let image: ImageViewForURL = ImageViewForURL(frame: CGRect(x: self.scrMain.frame.size.width * CGFloat(i), y: 0, width: self.scrMain.frame.size.width, height: self.scrMain.frame.size.height))
            DispatchQueue.main.async {
                if isFromAddExperience {
                    self.pageControl.frame = CGRect(x: self.scrMain.frame.size.width / 2 - 90, y: self.scrMain.frame.size.height - 37, width: 180, height: 37)
                    self.videoImg.frame = CGRect(x: image.frame.size.width - (25+10), y: image.frame.size.height - (25+10), width: 25, height: 25)
                } else {
                    self.pageControl.frame = CGRect(x: self.scrMain.frame.size.width / 2 - 90, y: self.scrMain.frame.size.height - 82, width: 180, height: 37)
                    self.videoImg.frame = CGRect(x: image.frame.size.width - (25+10), y: image.frame.size.height - (25+10+45), width: 25, height: 25)
                }
            }
            var objURL:NSString = ""
            if self.arrayOfPreview.count > i{
                objURL = self.arrayOfPreview[i]
            }
            if self.imagesArr.contains(objURL as String){
            //if i < self.imagesArr.count {
                DispatchQueue.main.async {
//                    self.videoImg.isHidden = true
                    image.imageFromServerURL(urlString: objURL as String)
                    //image.imageFromServerURL(urlString: self.imagesArr[i])
                    if isFromAddExperience {
                        print("From Add Experience")
                    } else {
                        image.addShadow(to: [.top], radius: 140.0)
                    }
                }
                self.scrMain.addSubview(image)
            } else {
                    DispatchQueue.main.async {
                        image.layoutIfNeeded()
                        
                        if let videoIndex = self.thumbnailArr.index(where: {$0 == objURL as String}),self.videoArr.count > 0{
                            objURL = self.videoArr[videoIndex] as NSString
                        }
                        if let strURL = "\(objURL)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),let videoURL = URL.init(string: strURL){
                         self.playVideo(videoUrl:videoURL,frame:image.frame)
                         }
                        /*if let strURL = "\(self.videoArr[i - self.imagesArr.count])".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),let videoURL = URL.init(string: strURL){
                            self.playVideo(videoUrl:videoURL,frame:image.frame)
                        }*/
                    }
                    let tapped1 = UITapGestureRecognizer(target: self, action: #selector(myFunction))
                    videoImg.isUserInteractionEnabled = true
                    tapped1.accessibilityValue = "\(i)"
                    tapped1.numberOfTapsRequired = 1
                    videoImg.addGestureRecognizer(tapped1)
                    self.addSubview(videoImg)
                }
                image.contentMode = UIViewContentMode.scaleAspectFill
            image.clipsToBounds = true
                image.isUserInteractionEnabled = true
                let tapped = UITapGestureRecognizer(target: self, action: #selector(myFunction))
                tapped.accessibilityValue = "\(i)"
                tapped.numberOfTapsRequired = 1
                image.addGestureRecognizer(tapped)
        }
    }
    func playVideo(videoUrl:URL,frame:CGRect){
        var playerView:UIView = UIView.init(frame: frame)
        var player = AVPlayer()
        var playerViewController = AVPlayerViewController()
        
       playerView.isHidden = false
        let objAsset = AVURLAsset.init(url: videoUrl)
        let objPlayerItem = AVPlayerItem.init(asset: objAsset)
        player = AVPlayer.init(playerItem: objPlayerItem)
        playerViewController.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
        playerViewController.player = player
        playerViewController.view.frame = frame//playerView.frame
        playerViewController.showsPlaybackControls = false
        //self.playerView.addSubview(self.playerViewController.view)
        playerViewController.accessibilityValue = "\(videoUrl)"
        print("Video Player View Frame \(playerView.frame)")
        print("Video View Frame \(playerViewController.view.frame)")
//        self.playerViewController.view.tag = 456
//        if let objPlayerView = self.scrMain.viewWithTag(456){
//            objPlayerView.removeFromSuperview()
//        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.scrMain.addSubview(playerViewController.view)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil)
        { notification in
            let t1 = CMTimeMake(5, 100);
            player.seek(to: t1)
            player.play()
            playerViewController.player?.seek(to: t1)
            playerViewController.player?.play()
        }
        
        
        //self.playerView.backgroundColor = .green
        //self.scrMain.addSubview(self.playerView)
        //self.playerViewController.view.backgroundColor = .red
        playerViewController.player?.play()
        player.play()
        player.isMuted = true
        playerViewController.player?.isMuted = true
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        //self.scrMain.setContentOffset(self.scrMain.contentOffset, animated: false)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        var lastIndex:Bool = false
        var firstIndex:Bool = false
        if self.imagesArr.count+self.videoArr.count > 0{
            if Int(ceil(x/w)) == self.imagesArr.count+self.videoArr.count - 1{ //last index
                if Int(ceil(x/w)) == pageControl.currentPage{
                    //pageControl.currentPage = 0
                    lastIndex = true
                }
            }else if Int(ceil(x/w)) == 0{
                if Int(ceil(x/w)) ==  pageControl.currentPage{
                    firstIndex = true
                }
            }
        }
        if lastIndex{
            pageControl.currentPage = 0
            self.pageChanged()
        }else if firstIndex{
            pageControl.currentPage = self.imagesArr.count+self.videoArr.count
            self.pageChanged()
        }else{
            pageControl.currentPage = Int(ceil(x/w))
        }
        self.openImageDelegate?.currentPageSetter?(currentPage: Int(ceil(x/w)))
        var objURL:NSString = ""
        if self.arrayOfPreview.count > pageControl.currentPage{
            objURL = self.arrayOfPreview[pageControl.currentPage]
        }
        if !self.imagesArr.contains(objURL as String){ //Video
        //if pageControl.currentPage + 1 > imagesArr.count {
            self.videoImg.isHidden = false
            //self.player.play()
        } else {
            self.videoImg.isHidden = true
            //self.player.pause()
        }
        defer{
            self.configureAddExperience()
        }
    }
    
    //Added Gesture to top images of page control
    @objc func myFunction(gesture: UITapGestureRecognizer) {
        let selectedImg: Int = Int(gesture.accessibilityValue!)!
        var objURL:NSString = ""
        if self.arrayOfPreview.count > selectedImg{
            objURL = self.arrayOfPreview[selectedImg]
        }
        if self.imagesArr.contains(objURL as String){
        //var objURL = self.arrayOfPreview[selectedImg]
        //if selectedImg < imagesArr.count {
            self.openImageDelegate?.openNewImageView(imgUrl:objURL as String, isvideo: false,currentPage:selectedImg,imageArray:self.imagesArr,videoArray:self.videoArr)
            //self.openImageDelegate?.openNewImageView(imgUrl: imagesArr[selectedImg], isvideo: false,currentPage:selectedImg,imageArray:self.imagesArr,videoArray:self.videoArr)
        } else {
            if let videoIndex = self.thumbnailArr.index(where: {$0 == objURL as String}),self.videoArr.count > 0{
                objURL = self.videoArr[videoIndex] as NSString
            }
            self.openImageDelegate?.openNewImageView(imgUrl: objURL as String, isvideo: true,currentPage:selectedImg,imageArray:self.imagesArr,videoArray:self.videoArr)
            //self.openImageDelegate?.openNewImageView(imgUrl: videoArr[pageControl.currentPage - imagesArr.count], isvideo: true,currentPage:selectedImg,imageArray:self.imagesArr,videoArray:self.videoArr)
        }
    }
    
    @objc func pageChanged() {
        let pageNumber = pageControl.currentPage
        var frame = scrMain.frame
        frame.origin.x = frame.size.width * CGFloat(pageNumber)
        frame.origin.y = 0
        scrMain.scrollRectToVisible(frame, animated: false)
        var objURL:NSString = ""
        if self.arrayOfPreview.count > pageControl.currentPage{
            objURL = self.arrayOfPreview[pageControl.currentPage]
        }
        if !self.imagesArr.contains(objURL as String){
        //if pageControl.currentPage + 1 > imagesArr.count {
            self.videoImg.isHidden = false
            //self.player.play()
        } else {
            self.videoImg.isHidden = true
           // self.player.pause()
        }
        defer{
            self.configureAddExperience()
        }
    }
    func hideAll(){
        self.btnDelete.isHidden = true
        self.btnDeleteOnly.isHidden = true
        self.btnMainImage.isHidden = true
        self.scrMain.isHidden = true
    }
    func configureAddExperience(){
        if self.isForAddExperience{
            var objURL:NSString = ""
            if self.arrayOfPreview.count > pageControl.currentPage{
                objURL = self.arrayOfPreview[pageControl.currentPage]
            }
            if !self.imagesArr.contains(objURL as String){ //Video
            //if pageControl.currentPage + 1 > imagesArr.count { //Video
                self.btnDelete.isHidden = true
                self.btnMainImage.isHidden = true
                self.btnDeleteOnly.isHidden = false
            }else{ //Image
                if let mainIndex = self.mainImage,mainIndex == self.pageControl.currentPage{
                        self.btnDelete.isHidden = true
                        self.btnMainImage.isHidden = true
                        self.btnDeleteOnly.isHidden = false
                    }else{
                        self.btnDelete.isHidden = false
                        self.btnMainImage.isHidden = false
                        self.btnDeleteOnly.isHidden = true
                    }
                }
        }else{
            self.btnDelete.isHidden = true
            self.btnMainImage.isHidden = true
            self.btnDeleteOnly.isHidden = true
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    @IBAction func buttonDelete(sender:UIButton){
        self.addExperienceDelegate?.deleteMediaDelegate(currentPage: self.pageControl.currentPage, isVideo:pageControl.currentPage + 1 > imagesArr.count)
    }
    @IBAction func buttonDeleteOnly(sender:UIButton){
        self.addExperienceDelegate?.deleteMediaDelegate(currentPage: self.pageControl.currentPage, isVideo:pageControl.currentPage + 1 > imagesArr.count)

    }
    @IBAction func buttonMainImage(sender:UIButton){
        print("\(self.pageControl.currentPage)")
        self.mainImage = self.pageControl.currentPage
        self.addExperienceDelegate?.setMainImageDelegate(currentPage: self.pageControl.currentPage)
    }
    @IBAction func buttonFullScreenSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
             self.addExperienceDelegate?.hideKeyboardSelectorFromHeader()
        }
    }
}
class CustomPageControl: UIPageControl {
    
    @IBInspectable var currentPageImage: UIImage?
    
    @IBInspectable var otherPagesImage: UIImage?
    
    override var numberOfPages: Int {
        didSet {
            updateDots()
        }
    }
    
    override var currentPage: Int {
        didSet {
            updateDots()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pageIndicatorTintColor = .clear
        currentPageIndicatorTintColor = .clear
        clipsToBounds = false
    }
    
    private func updateDots() {
        
        for (index, subview) in subviews.enumerated() {
            let imageView: UIImageView
            if let existingImageview = getImageView(forSubview: subview) {
                imageView = existingImageview
            } else {
                imageView = UIImageView(image: otherPagesImage)
                
                imageView.center = subview.center
                subview.addSubview(imageView)
                subview.clipsToBounds = false
            }
            imageView.image = currentPage == index ? currentPageImage : otherPagesImage
        }
    }
    
    private func getImageView(forSubview view: UIView) -> UIImageView? {
        if let imageView = view as? UIImageView {
            return imageView
        } else {
            let view = view.subviews.first { (view) -> Bool in
                return view is UIImageView
                } as? UIImageView
            
            return view
        }
    }
    
}
