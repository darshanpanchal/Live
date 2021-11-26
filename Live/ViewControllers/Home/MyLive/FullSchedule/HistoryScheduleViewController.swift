//
//  HistoryScheduleViewController.swift
//  Live
//
//  Created by IPS on 30/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class HistoryScheduleViewController: UIViewController {

    @IBOutlet var historyTableView:UITableView!
    
    var dateFormatter:DateFormatter{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    var startDate:Date{
        if let date = Calendar.current.date(byAdding: .year, value:-10, to: Date()){
            return date
        }else{
            return Date()
        }
    }
    var arrayOfHistory:[Schedule] = []
    override func viewDidLoad() {
        super.viewDidLoad()

      
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //GET Experience Histotry
        self.getHistoryAPIRequest()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Custom Methods
    func configureHistoryView(){
        let objScheduleNib = UINib.init(nibName: "PendingScheduleTableViewCell", bundle: nil)
        self.historyTableView.register(objScheduleNib, forCellReuseIdentifier: "PendingScheduleTableViewCell")
        
        //self.historyTableView.tableHeaderView = UIView()
        self.historyTableView.tableFooterView = UIView()
        self.historyTableView.delegate = self
        self.historyTableView.dataSource = self
        self.historyTableView.separatorStyle = .none
        self.historyTableView.reloadData()
    }
    // MARK: - API RequestMethods
    func getHistoryAPIRequest(){
        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
            //{{baseUrl}}/api/experience/native/guide/29/schedule?start=2018-06-01&end=2028-06-01
            let requestURLUpcomingExperience = kExperiencePendingSchedule+"\(currentUser.userID)/schedule/history?start=\(dateFormatter.string(from:startDate))&end=\(dateFormatter.string(from: Date()))"
            //GetUpcomingExperience
            APIRequestClient.shared.sendRequest(requestType: .GET, queryString: "\(requestURLUpcomingExperience)", parameter: nil, isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any],let arrayOfUpcomingSchedule = successData["Result"] as? [[String:Any]]{
                    DispatchQueue.main.async {
                        self.arrayOfHistory = []
                        for pendingSchedule in arrayOfUpcomingSchedule{
                            let objExperience = Schedule.init(scheduleDetail: pendingSchedule)
                            self.arrayOfHistory.append(objExperience)
                        }
                        //Configure History
                        self.configureHistoryView()
                    }
                }else{
                    DispatchQueue.main.async {
                        //ShowToast.show(toatMessage:kCommonError)
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
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
extension HistoryScheduleViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let historyScheduleCell :PendingScheduleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PendingScheduleTableViewCell", for: indexPath) as! PendingScheduleTableViewCell
        guard self.arrayOfHistory.count > indexPath.row else {
     
           return historyScheduleCell
        }
        let objSchedule = self.arrayOfHistory[indexPath.row]
        let strMutableString = NSMutableAttributedString.init(string: "\(objSchedule.status.compareCaseInsensitive(str:"\(Vocabulary.getWordFromKey(key: "confirmed"))".firstUppercased) ? "completed".firstUppercased:"\(objSchedule.status)".firstUppercased) " + "\(objSchedule.bookingDate.changeDateFormat) - \(objSchedule.time.changeTimeformat)")
        let attributes:[NSAttributedStringKey : Any]
            = [NSAttributedStringKey.foregroundColor:self.getStatusColor(strStatus:"\(objSchedule.status)") as Any,
             NSAttributedStringKey.font:UIFont.init(name:"Avenir-Heavy", size: 14.0)!]
        strMutableString.addAttributes(attributes, range:NSRange(location:0,length:"\(objSchedule.status)".count))
        historyScheduleCell.lblStatus.text = "\(objSchedule.status.compareCaseInsensitive(str:"\(Vocabulary.getWordFromKey(key: "confirmed"))".firstUppercased) ? Vocabulary.getWordFromKey(key: "confirmed").firstUppercased:"\(objSchedule.status)".firstUppercased) "
        //historyScheduleCell.lblLeadingConstraont.constant = 104.0
        historyScheduleCell.lblStatus.textColor = self.getStatusColor(strStatus:"\(objSchedule.status)")
        let statusWithColor:(String,UIColor) = self.getStatusForGuideWithColor(status: "\(objSchedule.status)")
        historyScheduleCell.lblStatus.text = objSchedule.isInstantBooking ? "  \(statusWithColor.0)" : "\(statusWithColor.0)"
        historyScheduleCell.lblStatus.textColor = statusWithColor.1
        historyScheduleCell.lblScheduledate.text = "\(objSchedule.time.changeTimeformat), \(objSchedule.bookingDate.changeDateFormat)"
        historyScheduleCell.lblScheduleTitle.text = "\(objSchedule.title)"
        historyScheduleCell.lblUserName.text = "\(objSchedule.userName)"
        historyScheduleCell.numberOfPerson.text = "\(objSchedule.slots)" + " \(Vocabulary.getWordFromKey(key: "people"))"
        historyScheduleCell.tag = indexPath.row
        historyScheduleCell.viewContainerSelectorContainer.isHidden = true
        historyScheduleCell.buttonCancelOnly.isHidden = true
        historyScheduleCell.backgroundColor = UIColor.clear
        DispatchQueue.main.async {
            historyScheduleCell.shadowView.isHidden = false
            historyScheduleCell.containerView.clipsToBounds = true
            historyScheduleCell.containerView.layer.cornerRadius = 10.0
        }
        return historyScheduleCell
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  
        if self.arrayOfHistory.count > 0 {
            tableView.removeMessageLabel()
        }else{
            tableView.showMessageLabel()
        }
        return self.arrayOfHistory.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190.0
    }
}
