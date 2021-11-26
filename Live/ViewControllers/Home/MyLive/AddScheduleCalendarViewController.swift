//
//  AddScheduleCalendarViewController.swift
//  Live
//
//  Created by IPS on 14/09/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class AddScheduleCalendarViewController: UIViewController {

    @IBOutlet var buttonSave:UIButton!
    @IBOutlet var lblNavigation:UILabel!
    @IBOutlet var buttonBack:UIButton!
    @IBOutlet var objCalender:FSCalendar!
    @IBOutlet var btnNext:UIButton!
    @IBOutlet var btnPrevious:UIButton!
    @IBOutlet var heightOfCalendar:NSLayoutConstraint!
    @IBOutlet var topConstraintNext:NSLayoutConstraint!
    @IBOutlet var topConstraintPrevious:NSLayoutConstraint!
    var unit: FSCalendarUnit! //at top of the controller
    var scheduleType:ScheduleType?
    let alertTitleFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Heavy", size: 17.0)!]
    let alertMessageFont = [NSAttributedStringKey.font: UIFont(name: "Avenir-Roman", size: 13.0)!]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.buttonBack.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), for: .normal)
        self.buttonBack.imageView?.tintColor = UIColor.black
        self.buttonBack.imageView?.contentMode = .scaleAspectFit
        self.configureAddScheduleView()
        self.configureFSCalender()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.topConstraintNext.constant = IsiPhone5 ? 14.0 : 24.0
            self.topConstraintPrevious.constant = IsiPhone5 ? 14.0 : 24.0
            self.addDynamicFont()
            self.addLocalisation()
        }
    }
    // MARK: - Custom Methods
    func configureFSCalender(){
        self.objCalender.dataSource = self
        self.objCalender.delegate = self
        self.objCalender.placeholderType = .none
        self.btnPrevious.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.btnPrevious.imageView?.tintColor = UIColor.init(hexString:"36527D")
        
        self.btnNext.setImage(#imageLiteral(resourceName: "next_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.btnNext.imageView?.tintColor = UIColor.init(hexString:"36527D")
        
        self.objCalender.appearance.titleFont = UIFont.init(name:"Avenir-Roman", size: 14.0)
        self.objCalender.appearance.headerTitleFont = UIFont.init(name: "Avenir-Heavy", size: 17.0)
        self.objCalender.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 14.0)
        self.objCalender.headerHeight = IsiPhone5 ? 50 : 70
        self.objCalender.weekdayHeight = IsiPhone5 ? 40 : 50
        self.heightOfCalendar.constant = UIScreen.main.bounds.height == 568.0 ? 300.0:360.0
        var allowMulipleSelection:Bool = false
        if let type:ScheduleType = self.scheduleType{
            if type == .Free{
                allowMulipleSelection = true
            }else if type == .Once{
                allowMulipleSelection = false
            }else if type == .Monthly{
                allowMulipleSelection = true
            }else{
                allowMulipleSelection = false
            }
        }
        self.objCalender.allowsMultipleSelection = allowMulipleSelection
        self.objCalender.reloadInputViews()
    }
    func addDynamicFont(){
        self.lblNavigation.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblNavigation.adjustsFontForContentSizeCategory = true
        self.lblNavigation.adjustsFontSizeToFitWidth = true
        
        self.buttonSave.titleLabel?.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.buttonSave.titleLabel?.adjustsFontForContentSizeCategory = true
        self.buttonSave.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    func addLocalisation(){
        self.lblNavigation.text = Vocabulary.getWordFromKey(key: "PickDay").capitalizingFirstLetter()
        self.buttonSave.setTitle("\(Vocabulary.getWordFromKey(key: "save.title"))", for: .normal)
    }
    func configureAddScheduleView(){
        
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelect(sender:UIButton){
        print("Selected Date \(self.objCalender.selectedDates)")
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func buttonSaveSelector(sender:UIButton){
        if self.objCalender.selectedDates.count > 0{
            let saveAlert = UIAlertController(title: Vocabulary.getWordFromKey(key:"AddTime.hint"), message: Vocabulary.getWordFromKey(key:"AddTimeMSG.hint"),preferredStyle: UIAlertControllerStyle.alert)
            //Vocabulary.getWordFromKey(key:"For all days")
            saveAlert.addAction(UIAlertAction(title:Vocabulary.getWordFromKey(key:"ForAllDays.hint"), style: .default, handler: { (action: UIAlertAction!) in
                self.performSegue(withIdentifier: "unwindFromCalendarToNewSchedule", sender: false)
            }))
            //Vocabulary.getWordFromKey(key:"No times")
            saveAlert.addAction(UIAlertAction(title:Vocabulary.getWordFromKey(key:"NoTime.hint"), style: .default, handler: { (action: UIAlertAction!) in
                self.performSegue(withIdentifier: "unwindFromCalendarToNewSchedule", sender: true)
            }))
            let titleAttrString = NSMutableAttributedString(string:Vocabulary.getWordFromKey(key:"AddTime.hint"), attributes: self.alertTitleFont)
            let messageAttrString = NSMutableAttributedString(string:Vocabulary.getWordFromKey(key:"AddTimeMSG.hint"), attributes: self.alertMessageFont)
            
            saveAlert.setValue(titleAttrString, forKey: "attributedTitle")
            saveAlert.setValue(messageAttrString, forKey: "attributedMessage")
            saveAlert.view.tintColor = UIColor(hexString: "#36527D")
            self.present(saveAlert, animated: true, completion: nil)
        }
    }
    @IBAction func buttonNextSelector(sender:UIButton){
        self.unit = (objCalender.scope == FSCalendarScope.month) ? FSCalendarUnit.month : FSCalendarUnit.weekOfYear
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: objCalender.currentPage)
        self.btnPrevious.isHidden = false
        //self.getCalenderExperiences(startDate: self.getFirstDate(objDate: nextMonth!), endDate: self.getLastDate(objDate: nextMonth!),isForCurrentMonth:false)
        self.objCalender.setCurrentPage(nextMonth!, animated: true)
    }
    @IBAction func buttonPreviousSelector(sender:UIButton){
        self.unit = (objCalender.scope == FSCalendarScope.month) ? FSCalendarUnit.month : FSCalendarUnit.weekOfYear
        let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: objCalender.currentPage)
        let currentYear = Calendar.current.date(byAdding: .year, value: 0, to: objCalender.currentPage)
        if currentYear?.year == Date().year{
            if previousMonth!.month == Date().month{
                self.btnPrevious.isHidden = true
            }
            guard previousMonth!.month >= Date().month else {
                return
            }
        }
       
        //self.getCalenderExperiences(startDate: self.getFirstDate(objDate: previousMonth!), endDate: self.getLastDate(objDate: previousMonth!),isForCurrentMonth:previousMonth!.month == Date().month)
        self.objCalender.setCurrentPage(previousMonth!, animated: true)
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "unwindFromCalendarToNewSchedule"{
            if let scheduleViewController: ScheduleViewController = segue.destination as? ScheduleViewController{
                if let _ = self.scheduleType{
                    scheduleViewController.scheduleType = self.scheduleType!
                    if self.scheduleType == .Free{
                        if let isNotime = sender as? Bool{
                            scheduleViewController.isFreeScheduleNoTime = isNotime
                             scheduleViewController.selectedDates = self.objCalender.selectedDates
                        }
                    }else if self.scheduleType == .Once{
                        if let isNotime = sender as? Bool{
                            scheduleViewController.isOnceScheduleNoTime = isNotime
                             scheduleViewController.selectedDates = self.objCalender.selectedDates
                        }
                    }else if self.scheduleType == .Monthly{
                        if let isNotime = sender as? Bool{
                            scheduleViewController.isMonthlyScheduleNoTime = isNotime
                            scheduleViewController.selectedDates = self.filterDatesforMonthlySelection()
                        }
                    }else{
                        
                    }
                }
               
            }
        }
    }
    func filterDatesforMonthlySelection()->[Date]{
        guard self.objCalender.selectedDates.count > 0 else{
            return []
        }
        var selectedDay:NSMutableSet = NSMutableSet()
        var filterDates:[Date] = []
        for date in self.objCalender.selectedDates{
            let day = Calendar.current.component(.day, from: date)
            if !selectedDay.contains(day){
                filterDates.append(date)
                selectedDay.add(day)
            }
        }
        return filterDates
    }
}

extension AddScheduleCalendarViewController:FSCalendarDelegate,FSCalendarDataSource{
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        //self.configureCurrentDate()
        
    }
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
}
