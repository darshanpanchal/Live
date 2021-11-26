//
//  MapViewController.swift
//  Live
//
//  Created by ips on 08/05/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import GoogleMaps

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var reloadMapBtn: UIButton!
    
    @IBOutlet weak var drivingTrailingConstant: NSLayoutConstraint!
    @IBOutlet weak var cylcleTrailingConstant: NSLayoutConstraint!
    @IBOutlet weak var walkBtnTrailingConstant: NSLayoutConstraint!
    @IBOutlet weak var cycleBtn: UIButton!
    @IBOutlet weak var walkingBtn: UIButton!
    @IBOutlet weak var transistBtn: UIButton!
    @IBOutlet weak var drivingBtn: UIButton!
    
    @IBOutlet weak var mapCardView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    //    @IBOutlet weak var chooseMode: UIButton!
    var currentLat: String = ""
    var currentLong: String = ""
    var destLat: String = ""
    var destLong: String = ""
    var selectedMode: String = "walking"
    var selectedDisplayStr: String = ""
    var bounds = GMSCoordinateBounds()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedDisplayStr = Vocabulary.getWordFromKey(key: "Walking")
        if self.view.frame.width < 375.0 {
            drivingTrailingConstant.constant = 20.0
            cylcleTrailingConstant.constant = 20.0
            walkBtnTrailingConstant.constant = 20.0
        } else {
            drivingTrailingConstant.constant = 40.0
            cylcleTrailingConstant.constant = 40.0
            walkBtnTrailingConstant.constant = 40.0
        }
        self.shadowView.layer.cornerRadius = 10.0

        self.mapCardView.clipsToBounds = true
        self.mapCardView.layer.cornerRadius = 10.0
        
        cycleBtn.layer.cornerRadius = cycleBtn.frame.width / 2.0
        cycleBtn.clipsToBounds = true
        walkingBtn.layer.cornerRadius = cycleBtn.frame.width / 2.0
        walkingBtn.clipsToBounds = true
        drivingBtn.layer.cornerRadius = cycleBtn.frame.width / 2.0
        drivingBtn.clipsToBounds = true
        transistBtn.layer.cornerRadius = cycleBtn.frame.width / 2.0
        transistBtn.clipsToBounds = true
        
        self.walkingBtn.isSelected = true
        self.cycleBtn.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        self.walkingBtn.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        self.transistBtn.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        self.drivingBtn.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        self.view.bringSubview(toFront: self.reloadMapBtn)
        self.view.sendSubview(toBack: self.mapView)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        var destCoordinate: CLLocationCoordinate2D?
        self.mapView.delegate = self
        self.mapView.clear()
        self.mapCardView.isHidden = true
        if destLong != "" && destLat != "" {
            self.mapCardView.isHidden = false
            let tempDestLat = Double(self.destLat)!
            let tempDestLong = Double(self.destLong)!
            destCoordinate = CLLocationCoordinate2DMake(tempDestLat, tempDestLong)
            self.mapView.camera = GMSCameraPosition.camera(withTarget: destCoordinate!, zoom: 17)
            let markerDest = GMSMarker(position: destCoordinate!)
            markerDest.position = destCoordinate!
            markerDest.map = self.mapView
            let markerImage = UIImage(named: "destinationMarkerIcn")!.withRenderingMode(.alwaysTemplate)
            let markerView = UIImageView(image: markerImage)
            markerView.tintColor = UIColor.black
            markerDest.iconView = markerView
        }
        if currentLong == "" || currentLat == "" {
            
        } else {
            let currentCoordinate = CLLocationCoordinate2DMake(Double(currentLat)!, Double(currentLong)!)
            let markerCurrent = GMSMarker(position: currentCoordinate)
            markerCurrent.position = currentCoordinate
            markerCurrent.map = self.mapView
            let markerImageCurrent = UIImage(named: "MarkerImg")!.withRenderingMode(.alwaysTemplate)
            let markerViewCurrent = UIImageView(image: markerImageCurrent)
            markerViewCurrent.tintColor = UIColor.black
            markerCurrent.iconView = markerViewCurrent
            self.mapView.camera = GMSCameraPosition.camera(withTarget: currentCoordinate, zoom: 17)
        }
        self.mapView.isMyLocationEnabled = true
        self.mapView.delegate = self
        self.mapView.settings.myLocationButton = false
        
        // Show route if distance is < 20 miles
        var distanceMile: Double = 0.0
        if destLong != "" && destLat != "" && currentLong != "" && currentLat != "" {
            let current = CLLocation(latitude: Double(currentLat)!, longitude: Double(currentLong)!)
            let dest = CLLocation(latitude: Double(destLat)!, longitude: Double(destLong)!)
            let distance = current.distance(from: dest)
            distanceMile = distance / 1609.344
            let str = "\(String(format: "%.2f", distanceMile))"
            self.distanceLabel.text = "\(self.selectedDisplayStr)" + ":" + " \(str)" + " miles"
            //            self.distanceLabel.text = str + "miles"
            let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(currentLat),\(currentLong)&destination=\(destLat),\(destLong)&sensor=false&mode=\(self.selectedMode)&alternatives=false&key=\(MAP_API_KEY)"
            
            Alamofire.request(url).responseJSON { response in
                if let JSON = response.result.value as? [String: Any] {
                    if let routes = JSON["routes"] as? NSArray {
                        for i in routes {
                            let route = i as? NSDictionary
                            if let temp = JSON["routes"] as? NSArray {
                                if let dataDic = temp.value(forKey: "legs") as? NSArray {
                                    if let duration = dataDic.value(forKey: "duration") as? NSArray {
                                        for i in 0..<duration.count {
                                            let timeDuration = duration[i] as! NSArray
                                            if let time = timeDuration.value(forKey: "text") as? NSArray {
                                                var str = "\(String(format: "%.2f", distanceMile))"
                                                str.append(" ")
                                                str.append("miles (")
                                                str.append("\(time[0])")
                                                str.append(")")
                                                self.distanceLabel.text = "\(self.selectedDisplayStr)" + ":" + " \(str)"
                                            }
                                        }
                                    }
                                }
                            }
                            if distanceMile < 20.0 {
                                let routeOverviewPolyline = route!["overview_polyline"] as? NSDictionary
                                let points = routeOverviewPolyline?["points"] as? String
                                let path = GMSPath.init(fromEncodedPath: points!)
                                let polyline = GMSPolyline.init(path: path)
                                let polyline1 = GMSPolyline.init(path: path)
                                polyline.strokeWidth = 8.0
                                polyline.strokeColor  = UIColor(red: 40.0/255.0, green: 133.0/255.0, blue: 207.0/255.0, alpha: 1.0)
                                polyline1.strokeWidth = 4.0
                                polyline1.strokeColor = UIColor(red: 0.0/255.0, green: 179.0/255.0, blue: 253.0/255.0, alpha: 1.0)
                                self.bounds = self.bounds.includingPath(path!)
                                polyline.map = self.mapView
                                polyline1.map = self.mapView
                                let update = GMSCameraUpdate.fit(self.bounds, withPadding: 50)
                                self.mapView.animate(with: update)
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    @objc func buttonClicked(sender: UIButton) {
        switch sender.tag {
        case 1:  //button1
        self.selectedMode = "walking"
        self.selectedDisplayStr = Vocabulary.getWordFromKey(key: "Walking")
        DispatchQueue.main.async {
        self.walkingBtn.setImage(#imageLiteral(resourceName: "selectedWalk").withRenderingMode(.alwaysTemplate), for: .normal)
        sender.isSelected = true
        self.drivingBtn.isSelected = false
        self.transistBtn.isSelected = false
        self.cycleBtn.isSelected = false

        self.cycleBtn.setImage(#imageLiteral(resourceName: "bicycleImg"), for: .normal)
        self.drivingBtn.setImage(#imageLiteral(resourceName: "DrivingImg"), for: .normal)
        self.transistBtn.setImage(#imageLiteral(resourceName: "TransistImg"), for: .normal)
        }
        break;
        case 2:  //button2
        self.selectedMode = "bicycling"
        self.selectedDisplayStr = Vocabulary.getWordFromKey(key: "Bicycling")
        DispatchQueue.main.async {
            self.cycleBtn.setImage(#imageLiteral(resourceName: "selectedCycle"), for: .normal)
            self.walkingBtn.setImage(#imageLiteral(resourceName: "walkingBtnImg"), for: .normal)
            self.drivingBtn.setImage(#imageLiteral(resourceName: "DrivingImg"), for: .normal)
            self.transistBtn.setImage(#imageLiteral(resourceName: "TransistImg"), for: .normal)
            self.drivingBtn.isSelected = false
            self.transistBtn.isSelected = false
            self.walkingBtn.isSelected = false
        }
        sender.isSelected = true
        break;
        case 3: //button3
        self.selectedMode = "driving"
        self.selectedDisplayStr = Vocabulary.getWordFromKey(key: "Driving")
        DispatchQueue.main.async {
        self.drivingBtn.setImage(#imageLiteral(resourceName: "selectedDriving"), for: .normal)
        self.cycleBtn.setImage(#imageLiteral(resourceName: "bicycleImg"), for: .normal)
        self.walkingBtn.setImage(#imageLiteral(resourceName: "walkingBtnImg"), for: .normal)
        self.transistBtn.setImage(#imageLiteral(resourceName: "TransistImg"), for: .normal)
        }
        self.cycleBtn.isSelected = false
        self.transistBtn.isSelected = false
        self.walkingBtn.isSelected = false
        sender.isSelected = true
        break;
        case 4:  //button4
        self.selectedMode = "transit"
        self.selectedDisplayStr = Vocabulary.getWordFromKey(key: "Transit")
        DispatchQueue.main.async {
        self.transistBtn.setImage(#imageLiteral(resourceName: "selectedTransit"), for: .normal)
        self.cycleBtn.setImage(#imageLiteral(resourceName: "bicycleImg"), for: .normal)
        self.walkingBtn.setImage(#imageLiteral(resourceName: "walkingBtnImg"), for: .normal)
        self.drivingBtn.setImage(#imageLiteral(resourceName: "DrivingImg"), for: .normal)
        }
        self.cycleBtn.isSelected = false
        self.drivingBtn.isSelected = false
        self.walkingBtn.isSelected = false
        sender.isSelected = true
        break;
        default:
        self.selectedMode = "walking"
        self.selectedDisplayStr = Vocabulary.getWordFromKey(key: "Walking")
        self.walkingBtn.setImage(#imageLiteral(resourceName: "selectedWalk"), for: .normal)
        sender.isSelected = true
        self.cycleBtn.setImage(#imageLiteral(resourceName: "bicycleImg"), for: .normal)
        self.drivingBtn.setImage(#imageLiteral(resourceName: "DrivingImg"), for: .normal)
        self.transistBtn.setImage(#imageLiteral(resourceName: "TransistImg"), for: .normal)
        self.cycleBtn.isSelected = false
        self.drivingBtn.isSelected = false
        self.transistBtn.isSelected = false
        break;
        }
        self.viewWillAppear(true)
    }
    
    // Custom Methods
    func openTravellingModeActionSheet() {
        //Present ModePicker
        let actionSheet = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"Mode"), message:Vocabulary.getWordFromKey(key:"chooseMode"), preferredStyle: .actionSheet)
        let cancel = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler: nil)
        actionSheet.addAction(cancel)
        let drivingMode = UIAlertAction.init(title:  Vocabulary.getWordFromKey(key:"Driving"), style: .default) { (_) in
            self.selectedMode = "driving"
            self.viewWillAppear(true)
        }
        actionSheet.addAction(drivingMode)
        let walkingMode = UIAlertAction.init(title:  Vocabulary.getWordFromKey(key:"Walking"), style: .default) { (_) in
            self.selectedMode = "walking"
            self.viewWillAppear(true)
        }
        actionSheet.addAction(walkingMode)
        let biycyclingMode = UIAlertAction.init(title:  Vocabulary.getWordFromKey(key:"Bicycling"), style: .default) { (_) in
            self.selectedMode = "bicycling"
            self.viewWillAppear(true)
        }
        actionSheet.addAction(biycyclingMode)
        let transitingMode = UIAlertAction.init(title:  Vocabulary.getWordFromKey(key:"Transit"), style: .default) { (_) in
            self.selectedMode = "transit"
            self.viewWillAppear(true)
        }
        actionSheet.addAction(transitingMode)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    // MARK:- Selector Methods
    @IBAction func cancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func reloadMapBtnPressed(_ sender: Any) {
        self.viewWillAppear(true)
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

