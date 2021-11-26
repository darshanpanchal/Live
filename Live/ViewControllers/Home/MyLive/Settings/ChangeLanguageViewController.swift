//
//  ChangeLanguageViewController.swift
//  Live
//
//  Created by ips on 05/06/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class ChangeLanguageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate {
    @IBOutlet weak var navTitle: UILabel!
    @IBOutlet weak var btnSave: RoundButton!
    @IBOutlet weak var languageTableView: UITableView!
    @IBOutlet var buttonBack:UIButton!
    
    var languagesSource:[LocalizableLanguage]?{
        didSet{
            languageTableView.reloadData()
        }
    }
    var selectedCell = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navTitle.text = Vocabulary.getWordFromKey(key: "language")
        self.btnSave.setTitle(Vocabulary.getWordFromKey(key: "Done"), for: .normal)
        if (UserDefaults.standard.value(forKey: "selectedLanguageCode") != nil) {
            selectedCell = 0
        }
        self.setUpViews()
        self.languageTableView.tableFooterView = UIView()
        self.languageTableView.separatorStyle = .none
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.addDynamicFont()
            self.swipeToPop()
        }
    }
    func swipeToPop() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func addDynamicFont(){
        self.buttonBack.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.buttonBack.imageView?.tintColor = UIColor.black
        
        self.navTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.navTitle.adjustsFontForContentSizeCategory = true
        self.navTitle.adjustsFontSizeToFitWidth = true
        
        self.btnSave.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.btnSave.titleLabel?.adjustsFontForContentSizeCategory = true
        self.btnSave.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    // MARK:- Custom Methods
    func setUpViews(){
        if String.getSelectedLanguage() == "1"{
            selectedCell = 0
        }else if String.getSelectedLanguage() == "2"{
            selectedCell = 1
        }else if String.getSelectedLanguage() == "3" {
            selectedCell = 2
        } else if String.getSelectedLanguage() == "4" {
            selectedCell = 3
        } else if String.getSelectedLanguage() == "5" {
            selectedCell = 4
        } else if String.getSelectedLanguage() == "6" {
            selectedCell = 5
        }
        
        let eng = LocalizableLanguage()
        eng.title = "English"
        
        let sweden = LocalizableLanguage()
        sweden.title = "Svenska"
        
        let greek = LocalizableLanguage()
        greek.title = "Ελληνικά"
        
        let portuguese = LocalizableLanguage()
        portuguese.title = "Português"
        
        let spanish = LocalizableLanguage()
        spanish.title = "Español"
        
        let norwegian = LocalizableLanguage()
        norwegian.title = "Norwain"
        //Apply english localisation for now #368
        self.languagesSource = [eng]//[eng,sweden,greek,norwegian,portuguese,spanish]
        
    }
    
    // MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.languagesSource?.count{
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageTableViewCell") as! LanguageTableViewCell
        if selectedCell == indexPath.row{
            cell.imgRight.isHidden = false
            cell.lblLanguageName.textColor = UIColor.init(hexString: "#36527D")
        }
        else {
            cell.imgRight.isHidden = true
            cell.lblLanguageName.textColor = UIColor.black
        }
        cell.language = self.languagesSource![indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedCell = indexPath.row
        self.languageTableView.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72.0
    }
    //MARK:- Update App Language
    func updateLanguage() {
        let currentUser: User? = User.getUserFromUserDefault()
        let userId: String = (currentUser?.userID)!
        let languageId = String(self.selectedCell + 1)

        let urlUpdateDescription = "users/\(userId)/native/applicationlanguage/\(languageId)"
        APIRequestClient.shared.sendRequest(requestType: .PUT, queryString:urlUpdateDescription, parameter: nil, isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let data = success["data"] as? [String:Any] {
               UserDefaults.standard.set(String(self.selectedCell + 1), forKey: "selectedLanguageCode")

                let instantAlert = UIAlertController(title: Vocabulary.getWordFromKey(key: "Success"), message: data["Message"] as? String ,preferredStyle: UIAlertControllerStyle.alert)
                instantAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .cancel, handler: { (action: UIAlertAction!) in
                    self.pushToRoot()
                }))
                let titleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17.0)!]
                let messageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
                let titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key: "Success"), attributes: titleFont)
                let messageAttrString = NSMutableAttributedString(string: (data["Message"] as? String)!, attributes: messageFont)
                
                instantAlert.setValue(titleAttrString, forKey: "attributedTitle")
                instantAlert.setValue(messageAttrString, forKey: "attributedMessage")
                instantAlert.view.tintColor = UIColor(hexString: "#36527D")
                self.present(instantAlert, animated: true, completion: nil)
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
    
    // MARK:- Selector methods
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        let instantAlert = UIAlertController(title: Vocabulary.getWordFromKey(key: "ChangeLanguage"), message: Vocabulary.getWordFromKey(key:"languageChangeMsg"),preferredStyle: UIAlertControllerStyle.alert)
        instantAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (action: UIAlertAction!) in
            if User.isUserLoggedIn {
                self.updateLanguage()
            } else {
                UserDefaults.standard.set(String(self.selectedCell + 1), forKey: "selectedLanguageCode")
                self.pushToRoot()
            }
        }))
        instantAlert.addAction(UIAlertAction(title: Vocabulary.getWordFromKey(key:"no"), style: .cancel, handler: nil))
        let titleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17.0)!]
        let messageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
        let titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key: "ChangeLanguage"), attributes: titleFont)
        let messageAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key:"languageChangeMsg"), attributes: messageFont)
        
        instantAlert.setValue(titleAttrString, forKey: "attributedTitle")
        instantAlert.setValue(messageAttrString, forKey: "attributedMessage")
        instantAlert.view.tintColor = UIColor(hexString: "#36527D")
        present(instantAlert, animated: true, completion: nil)
    }
    
    func pushToRoot() {
        let filterd = self.navigationController?.viewControllers.filter { $0 is HomeViewController}
        if let arrayFilter = filterd,arrayFilter.count > 0,let homeVC =  arrayFilter.first! as? HomeViewController{
           homeVC.selectedIndex = 0
            self.navigationController?.popToViewController(homeVC, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
