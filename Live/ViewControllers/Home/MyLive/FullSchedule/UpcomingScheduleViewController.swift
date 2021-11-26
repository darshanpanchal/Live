//
//  UpcomingScheduleViewController.swift
//  Live
//
//  Created by IPS on 30/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class UpcomingScheduleViewController: UIViewController {

    @IBOutlet var upcomingTableView:UITableView!
    var dateFormatter:DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    var endDate:Date{
        if let date = Calendar.current.date(byAdding: .year, value:10, to: Date()){
            return date
        }else{
            return Date()
        }
    }
    var arrayOfUpcomingExperience:[Schedule] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //GET UpcomingExperience
        self.getUpcomingExperiences()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - API request Meethods
    func getUpcomingExperiences(){
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            //{{baseUrl}}/api/experience/native/guide/29/schedule?start=2018-06-01&end=2028-06-01
            let requestURLUpcomingExperience = kExperiencePendingSchedule+"\(currentUser.userID)/schedule/upcoming?start=\(dateFormatter.string(from:Date()))&end=\(dateFormatter.string(from: endDate))"
            //GetUpcomingExperience
            APIRequestClient.shared.sendRequest(requestType: .GET, queryString: "\(requestURLUpcomingExperience)", parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let arrayOfUpcomingSchedule = successData["Result"] as? [[String:Any]]{
                    DispatchQueue.main.async {
                        self.arrayOfUpcomingExperience = []
                        for pendingSchedule in arrayOfUpcomingSchedule{
                            let objExperience = Schedule.init(scheduleDetail: pendingSchedule)
                            self.arrayOfUpcomingExperience.append(objExperience)
                        }
                        //Configure UpcomingExperience
                        self.configureUpcomingView()
                    }
                }else{
                    DispatchQueue.main.async {
                       // ShowToast.show(toatMessage:kCommonError)
                    }
                }
               
            
            }, fail: { (responseFail) in
                if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: "\(errorMessage)")
                    }
                }else{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:kCommonError)
                    }
                }
            })
        }
    }
    func cancelUpcomingScheduleAPIRequest(objSchedule:Schedule,index:Int){
        //http://staging.live.stockholmapplab.com/api/experience/bookingcancelguide
        let requestURLCacelBooking = "experience/native/bookingcancelguide"
        var cancelBookingParameters:[String:Any] = [:]
        cancelBookingParameters["BookingId"] = "\(objSchedule.id)"
        cancelBookingParameters["ExperienceTitle"] = "\(objSchedule.title)"
        cancelBookingParameters["GuideId"] = "\(User.getUserFromUserDefault()!.userID)"
        cancelBookingParameters["UserId"] = "\(objSchedule.userID)"
        cancelBookingParameters["ExperienceId"] = "\(objSchedule.experienceID)"
        //Cancel PendingExperience
        APIRequestClient.shared.sendRequest(requestType: .PUT, queryString: "\(requestURLCacelBooking)", parameter: cancelBookingParameters as [String : AnyObject], isHudeShow: true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let successMessage = successData["Message"]{
                let objAlert = UIAlertController.init(title: Vocabulary.getWordFromKey(key:"CancelTour"), message: "\(successMessage)", preferredStyle: .alert)
                objAlert.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (_ ) in
                    DispatchQueue.main.async {
                        self.arrayOfUpcomingExperience.remove(at: index)
                        self.upcomingTableView.reloadData()
                        
                    }
                }))
                let titleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17.0)!]
                let messageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
                let titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key: "CancelTour"), attributes: titleFont)
                let messageAttrString = NSMutableAttributedString(string: "\(successMessage)", attributes: messageFont)
                
                objAlert.setValue(titleAttrString, forKey: "attributedTitle")
                objAlert.setValue(messageAttrString, forKey: "attributedMessage")
                objAlert.view.tintColor = UIColor(hexString: "#36527D")
                self.present(objAlert, animated: true, completion: nil)
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
            
        }, fail: { (responseFail) in
            if let arrayFail = responseFail as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        })
    }
    // MARK: - Custom Meethods
    func configureUpcomingView(){
        let objScheduleNib = UINib.init(nibName: "PendingScheduleTableViewCell", bundle: nil)
        self.upcomingTableView.register(objScheduleNib, forCellReuseIdentifier: "PendingScheduleTableViewCell")
        
        //self.upcomingTableView.tableHeaderView = UIView()
        self.upcomingTableView.tableFooterView = UIView()
        self.upcomingTableView.delegate = self
        self.upcomingTableView.dataSource = self
        self.upcomingTableView.reloadData()
        self.upcomingTableView.separatorStyle = .none
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
extension UpcomingScheduleViewController:PendingScheduleDelegate{
    func upcomingScheduleCancelOnlySelector(tag: Int) {
        guard self.arrayOfUpcomingExperience.count > tag else {
            return
        }
        let objAlert = UIAlertController.init(title: Vocabulary.getWordFromKey(key:"CancelTour"), message: Vocabulary.getWordFromKey(key:"CancelTour.msg"), preferredStyle: .alert)
        
        objAlert.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"yes"), style: .default, handler: { (_ ) in
            let objSchedule = self.arrayOfUpcomingExperience[tag]
            self.cancelUpcomingScheduleAPIRequest(objSchedule: objSchedule,index: tag)
        }))
        objAlert.addAction(UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"no"), style: .cancel, handler: nil))
        let titleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17.0)!]
        let messageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
        let titleAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key: "CancelTour"), attributes: titleFont)
        let messageAttrString = NSMutableAttributedString(string: Vocabulary.getWordFromKey(key:"CancelTour.msg"), attributes: messageFont)
        
        objAlert.setValue(titleAttrString, forKey: "attributedTitle")
        objAlert.setValue(messageAttrString, forKey: "attributedMessage")
        objAlert.view.tintColor = UIColor(hexString: "#36527D")
        self.present(objAlert, animated: true, completion: nil)

    }
}
extension UpcomingScheduleViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let upcomingScheduleCell :PendingScheduleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PendingScheduleTableViewCell", for: indexPath) as! PendingScheduleTableViewCell
        guard self.arrayOfUpcomingExperience.count > indexPath.row else {
            return upcomingScheduleCell
        }
        upcomingScheduleCell.pendingScheduleDelegate = self
        let objSchedule = self.arrayOfUpcomingExperience[indexPath.row]
        let strMutableString = NSMutableAttributedString.init(string: "(\(objSchedule.status)) " + "\(objSchedule.bookingDate.changeDateFormat) - \(objSchedule.time.changeTimeformat)")
        let attributes:[NSAttributedStringKey : Any]
            = [NSAttributedStringKey.foregroundColor:self.getStatusColor(strStatus:"\(objSchedule.status)") as Any]
        
        strMutableString.addAttributes(attributes, range:NSRange(location:0,length:"\(objSchedule.status)".count+2))
        upcomingScheduleCell.lblStatus.text = "\(objSchedule.status)".firstUppercased
        upcomingScheduleCell.lblStatus.textColor = self.getStatusColor(strStatus:"\(objSchedule.status)")
        let statusWithColor:(String,UIColor) = self.getStatusForGuideWithColor(status: "\(objSchedule.status)")
        upcomingScheduleCell.lblStatus.text = objSchedule.isInstantBooking ? "  \(statusWithColor.0)" : "\(statusWithColor.0)"
        upcomingScheduleCell.lblStatus.textColor = statusWithColor.1
        //upcomingScheduleCell.lblScheduledate.attributedText = strMutableString
        upcomingScheduleCell.lblScheduledate.text = "\(objSchedule.time.changeTimeformat), \(objSchedule.bookingDate.changeDateFormat)"
        upcomingScheduleCell.lblScheduleTitle.text = "\(objSchedule.title)"
        upcomingScheduleCell.lblUserName.text = "\(objSchedule.userName)"
        upcomingScheduleCell.numberOfPerson.text = "\(objSchedule.slots)" + " \(Vocabulary.getWordFromKey(key: "people"))"
        upcomingScheduleCell.tag = indexPath.row
        upcomingScheduleCell.viewContainerSelectorContainer.isHidden = true
        upcomingScheduleCell.buttonCancelOnly.isHidden = false
        return upcomingScheduleCell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.arrayOfUpcomingExperience.count > 0 {
            tableView.removeMessageLabel()
        }else{
            tableView.showMessageLabel()
        }
        return self.arrayOfUpcomingExperience.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190.0
    }
    func getStatusColor(strStatus:String)->UIColor{
        if strStatus.compareCaseInsensitive(str: "\(Vocabulary.getWordFromKey(key: "confirmed"))"){
            return UIColor.init(hexString:"367D4A")
        }else if strStatus.compareCaseInsensitive(str:"\(Vocabulary.getWordFromKey(key: "pending"))"){
            return UIColor.init(hexString:"FF3B30")//FF3B30
        }else{
            return UIColor.init(hexString:"FF3B30")
        }
    }
    func getStatusForGuideWithColor(status:String)->(String,UIColor){
        if(status == "RequestedByTraveler"){
            return ("By Traveller",UIColor.init(hexString: "36527D"))
        }else if(status == "RequestedByGuide"){
            return ("Requested",UIColor.init(hexString:"FF3B30"))
        }else if(status == "Canceled"){
            return (status,UIColor.init(hexString:"FF3B30"))
        }else{
            return (status,UIColor.init(hexString:"367D4A")) //Accepted Confirmed
        }
    }
}
