//
//  TermsViewController.swift
//  Live
//
//  Created by ITPATH on 5/2/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
let kBaseDomain = "http://app.live-privateguide.com" //http://prod.live.stockholmapplab.com //http://staging.live.stockholmapplab.com
class TermsViewController: UIViewController {
    
    var termsAndCondition:String = kBaseDomain+"/TandC/1.html"
    @IBOutlet var objectWebView:UIWebView!
    @IBOutlet var btnClose:UIButton!
    @IBOutlet var navTitle:UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navTitle.text = Vocabulary.getWordFromKey(key: "TermsandConditions")
        guard CommonClass.shared.isConnectedToInternet else {
            ShowToast.show(toatMessage: kNoInternetError)
            return
        }
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String,languageId.compareCaseInsensitive(str:"2") { // 1 for english and 2 for sweden
            termsAndCondition =  kBaseDomain+"/TandC/2.html"
            //"http://prod.live.stockholmapplab.com/TandC/2.html"//"http://staging.live.stockholmapplab.com/TandC/2.html"
        } else {
            termsAndCondition =  kBaseDomain+"/TandC/1.html"
            //"http://prod.live.stockholmapplab.com/TandC/1.html"//"http://staging.live.stockholmapplab.com/TandC/1.html"
        }
        self.configureWebView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarStyle = .default
        btnClose.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
        btnClose.imageView?.tintColor = UIColor.black
         DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    func addDynamicFont(){
        self.navTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.navTitle.adjustsFontForContentSizeCategory = true
        self.navTitle.adjustsFontSizeToFitWidth = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Methods
    func configureWebView(){
        self.objectWebView.delegate = self
        if let objUrl = URL.init(string:termsAndCondition){
            let objectRequest = URLRequest.init(url: objUrl)
            self.objectWebView.loadRequest(objectRequest)
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonCloseSelector(sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
extension TermsViewController:UIWebViewDelegate{
    func webViewDidStartLoad(_ webView: UIWebView) {
        DispatchQueue.main.async {
            ProgressHud.show()
        }
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        ShowToast.show(toatMessage: "\(error.localizedDescription)")
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        DispatchQueue.main.async {
            ProgressHud.hide()
        }
    }
}
