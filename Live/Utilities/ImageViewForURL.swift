//
//  Extensions.swift
//  campus.
//
//  Created by ips on 08/02/17.
//  Copyright © 2017 Dilip manek. All rights reserved.
//

import UIKit
import SDWebImage

var cashedImages = [String:UIImage]()

class ImageViewForURL:UIImageView{
    
     var imageUrl = ""
    public func imageFromServerURL(urlString: String,placeHolder:UIImage = UIImage(named: "expriencePlaceholder")!) {
        
        if urlString.removeWhiteSpaces().count == 0{
            return
        }
       // DispatchQueue.main.async {
            /*
            self.sd_setImage(
                with: URL(string: "\(urlString)"),
                placeholderImage: placeHolder,
                options: SDWebImageOptions(rawValue: 0),
                completed: {  image, error, cacheType, imageURL in
                    // your rest code
                    self.image = image
                    
             }
            )
           */
            //DispatchQueue.main.async {
                self.sd_setImage(with: URL(string: "\(urlString)"), placeholderImage:placeHolder)
           // }
       // }
        /*
        self.stopLoadingView()
        //self.image = #imageLiteral(resourceName: "profile_placeholder").withRenderingMode(.alwaysTemplate)
        self.tintColor = UIColor.clear
        self.imageUrl = urlString
        
        if let cashedImage = cashedImages[urlString]{
            self.image = cashedImage
            return
        }
        let urlStringWithHttp = urlString
//        if !urlString.hasPrefix("http://"){
//            urlStringWithHttp = "http://"+urlString
//        }
        
        guard let url = URL(string:urlStringWithHttp ) else {
            return
        }
        
        self.startLoadingView()
        URLSession.shared.dataTask(with:url , completionHandler: { (imageData, response, error) -> Void in
            if error != nil {

                return
            }
           
            DispatchQueue.main.async(execute: { () -> Void in
                if let imgData = imageData,let fetchedImage =  UIImage(data: imgData){
                    if self.imageUrl == urlString{
                        self.stopLoadingView()
                        self.image = fetchedImage
                    }
                    cashedImages[urlString] = fetchedImage
                }
                else
                {
                        self.stopLoadingView()
                        //self.image = #imageLiteral(resourceName: "profile_placeholder").withRenderingMode(.alwaysTemplate)
                    
                }
            })
            
        }).resume() */
    }
    public func imageLoadingFromServerURL(urlString: String,placeHolder:UIImage = UIImage(named: "expriencePlaceholder")!) {
        
         self.stopLoadingView()
         self.image = placeHolder// #imageLiteral(resourceName: "profile_placeholder").withRenderingMode(.alwaysTemplate)
         self.tintColor = UIColor.clear
         self.imageUrl = urlString
         
         if let cashedImage = cashedImages[urlString]{
            self.image = cashedImage
            return
         }
         var urlStringWithHttp = urlString
//         if !urlString.hasPrefix("http://"){
//             urlStringWithHttp = "http://"+urlString
//         }
        
         guard let url = URL(string:urlStringWithHttp ) else {
         return
         }
         
         self.startLoadingView()
         URLSession.shared.dataTask(with:url , completionHandler: { (imageData, response, error) -> Void in
            if error != nil {
         
                return
         }
         
         DispatchQueue.main.async(execute: { () -> Void in
         if let imgData = imageData,let fetchedImage =  UIImage(data: imgData){
         if self.imageUrl == urlString{
            self.stopLoadingView()
            self.image = fetchedImage
         }
            cashedImages[urlString] = fetchedImage
         }
         else
         {
         self.stopLoadingView()
         //self.image = #imageLiteral(resourceName: "profile_placeholder").withRenderingMode(.alwaysTemplate)
         
         }
         })
         
         }).resume()
    }
    let loadingIndicator:UIActivityIndicatorView={
        let loading = UIActivityIndicatorView()
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.activityIndicatorViewStyle = .gray
        loading.backgroundColor = UIColor.init(white: 0.5, alpha: 0)
        loading.layer.cornerRadius = 8
        loading.layer.masksToBounds = true
        return loading
    }()
    
    
    public func startLoadingView(){
       
        if !self.subviews.contains(loadingIndicator){
            self.addSubview(loadingIndicator)
            loadingIndicator.startAnimating()
            
            loadingIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
            loadingIndicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
            loadingIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            loadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
    }
    public func stopLoadingView(){
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.removeFromSuperview()
        }
    }
    
    public func setBorder(status:Int){
        self.layer.borderWidth = 10
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 17
        
        switch status {
        case 0:
             self.layer.borderColor = UIColor.white.cgColor
        case 1:
              self.layer.borderColor = UIColor.green.cgColor
        default:
            self.layer.borderColor = UIColor.orange.cgColor
        }
    }
}
