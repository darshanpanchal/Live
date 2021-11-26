//
//  FullScheduleViewController.swift
//  Live
//
//  Created by IPS on 30/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import Parchment

class FullScheduleViewController: UIViewController,UIGestureRecognizerDelegate {

    var pagingViewController = PagingViewController<PagingIndexItem>()
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var btnBack:UIButton!
    @IBOutlet var navTitle:UILabel!
    @IBOutlet var viewContainer:UIView!
    var isLoadHistory:Bool = false
    var isLoadUpcoming:Bool = false
    @IBOutlet var objUISegementController:UISegmentedControl!
    
    // Let's start by creating an array of citites that we
    // will use to generate some view controllers.
    fileprivate let cities = [
        Vocabulary.getWordFromKey(key:"Pending"),
        Vocabulary.getWordFromKey(key:"Calendar"),
        Vocabulary.getWordFromKey(key:"Upcoming"),
        Vocabulary.getWordFromKey(key:"History")
    ]
    fileprivate var pendingViewController:UIViewController{
        get{
            if let pendingVC = self.storyboard?.instantiateViewController(withIdentifier:"PendingViewController") as? PendingViewController{
                return pendingVC
            }else{
                return UIViewController()
            }
        }
    }
    fileprivate var calenderViewController:UIViewController{
        get{
            if let calenderVC = self.storyboard?.instantiateViewController(withIdentifier:"CalenderScheduleViewController") as? CalenderScheduleViewController{
                return calenderVC
            }else{
                return UIViewController()
            }
        }
    }
    fileprivate var upcomingViewController:UIViewController{
        get{
            if let upcomingVC = self.storyboard?.instantiateViewController(withIdentifier:"UpcomingScheduleViewController") as? UpcomingScheduleViewController{
                return upcomingVC
            }else{
                return UIViewController()
            }
        }
    }
    fileprivate var historyViewController:UIViewController{
        get{
            if let historyVC = self.storyboard?.instantiateViewController(withIdentifier:"HistoryScheduleViewController") as? HistoryScheduleViewController{
                return historyVC
            }else{
                return UIViewController()
            }
        }   
    }
    var arrayOfViewController:[UIViewController] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnBack.setImage(#imageLiteral(resourceName: "back_update").withRenderingMode(.alwaysTemplate), for: .normal)
        self.btnBack.imageView?.tintColor = UIColor.black
        navTitle.text = Vocabulary.getWordFromKey(key: "Schedule")
        self.arrayOfViewController = [pendingViewController,calenderViewController,upcomingViewController,historyViewController]
        //let pagingViewController = PagingViewController<PagingIndexItem>()
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        pagingViewController.collectionView.isHidden = true
        pagingViewController.options.contentInteraction = .none
        // Add the paging view controller as a child view controller and
        // contrain it to all edges.
        addChildViewController(pagingViewController)
        viewContainer.addSubview(pagingViewController.view)
        viewContainer.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParentViewController: self)
        pagingViewController.reloadData()
        
        if self.isLoadHistory{
            DispatchQueue.main.async {
                self.objUISegementController.selectedSegmentIndex = 3
                self.pagingViewController.select(index: 3, animated: false)
            }
        }else if self.isLoadUpcoming{
            DispatchQueue.main.async {
                self.objUISegementController.selectedSegmentIndex = 2
                self.pagingViewController.select(index: 2, animated: false)
            }
        }
        
        self.configureUISegementController()
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
    func configureUISegementController(){
        if UIScreen.main.bounds.height > 568.0{
            self.objUISegementController.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 14)!], for: .selected)
            self.objUISegementController.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 14)!], for: .normal)
        }else{
            self.objUISegementController.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 12)!], for: .selected)
            self.objUISegementController.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "Avenir-Roman", size: 12)!], for: .normal)
        }
       
        self.objUISegementController.setTitle(Vocabulary.getWordFromKey(key: "Pending"), forSegmentAt: 0)
        self.objUISegementController.setTitle(Vocabulary.getWordFromKey(key: "Calendar"), forSegmentAt: 1)
        self.objUISegementController.setTitle(Vocabulary.getWordFromKey(key: "Upcoming"), forSegmentAt: 2)
        self.objUISegementController.setTitle(Vocabulary.getWordFromKey(key: "History"), forSegmentAt: 3)
    }
    func addDynamicFont(){
        self.navTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.navTitle.adjustsFontForContentSizeCategory = true
        self.navTitle.adjustsFontSizeToFitWidth = true
        
        self.lblTitle.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.lblTitle.adjustsFontForContentSizeCategory = true
        self.lblTitle.adjustsFontSizeToFitWidth = true
    }
    //MARK:- Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: false)
    }
    @IBAction func buttonSegmentControllerSelector(sender:UISegmentedControl){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            APIRequestClient.shared.cancelAllAPIRequest(json: nil)
            self.pagingViewController.select(index: sender.selectedSegmentIndex , animated: true)
        }
        
        switch sender.selectedSegmentIndex {
        case 0: //Guide
           
            break
        case 1: //Traveler
            break
        case 2: //Traveler
            break
        case 3: //Traveler
            break
        default:
            break
        }
    }
}

extension FullScheduleViewController: PagingViewControllerDataSource {
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
        return PagingIndexItem(index: index, title: cities[index]) as! T
    }
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
        return self.arrayOfViewController[index]
    }
    
    func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
        return self.arrayOfViewController.count
    }
    
}

extension FullScheduleViewController: PagingViewControllerDelegate {
    
    // We want the size of our paging items to equal the width of the
    // city title. Parchment does not support self-sizing cells at
    // the moment, so we have to handle the calculation ourself. We
    // can access the title string by casting the paging item to a
    // PagingTitleItem, which is the PagingItem type used by
    // FixedPagingViewController.
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, widthForPagingItem pagingItem: T, isSelected: Bool) -> CGFloat? {
        guard let item = pagingItem as? PagingIndexItem else { return 0 }
        
        let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: pagingViewController.menuItemSize.height)
        let attributes = [NSAttributedStringKey.font: pagingViewController.font]
        
        let rect = item.title.boundingRect(with: size,
                                           options: .usesLineFragmentOrigin,
                                           attributes: attributes,
                                           context: nil)
        
        let width = ceil(rect.width) + insets.left + insets.right
        if isSelected {
            return width * 1.5
        } else {
            return width
        }
    }
    
}
extension UIView {
    
    func constrainCentered(_ subview: UIView) {
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let verticalContraint = NSLayoutConstraint(
            item: subview,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0)
        
        let horizontalContraint = NSLayoutConstraint(
            item: subview,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0)
        
        let heightContraint = NSLayoutConstraint(
            item: subview,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: subview.frame.height)
        
        let widthContraint = NSLayoutConstraint(
            item: subview,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: subview.frame.width)
        
        addConstraints([
            horizontalContraint,
            verticalContraint,
            heightContraint,
            widthContraint])
        
    }
    
    func constrainToEdges(_ subview: UIView) {
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let topContraint = NSLayoutConstraint(
            item: subview,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 0)
        
        let bottomConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0)
        
        let leadingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0)
        
        let trailingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0)
        
        addConstraints([
            topContraint,
            bottomConstraint,
            leadingContraint,
            trailingContraint])
    }
    
}
