//
//  BookingDetailAddressTableViewCell.swift
//  Live
//
//  Created by ips on 16/04/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire

protocol reloadMap {
    func reloadMapView()
    func navigationClicked()
}

class BookingDetailAddressTableViewCell: UITableViewCell {
    @IBOutlet weak var mapDetaiView: UIView!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var distanceView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var meetingLocationDetailLbl: UILabel!
    @IBOutlet weak var meetingPointLbl: UILabel!
    @IBOutlet weak var buttonNavigation: UIButton!
    @IBOutlet weak var buttonMap: UIButton!
    var cordinateBounds = GMSCoordinateBounds()
    var reloadMapDelegate: reloadMap?
    override func awakeFromNib() {
        super.awakeFromNib()
        mapDetaiView.layer.cornerRadius = 5.0
        mapDetaiView.layer.shadowColor = UIColor(hexString: "40000000").cgColor
        mapDetaiView.layer.shadowOpacity = 1
        mapDetaiView.layer.shadowOffset = CGSize.zero
        mapDetaiView.layer.shadowRadius = 2.0
        self.durationLbl.text = Vocabulary.getWordFromKey(key: "CalculatingDistance")
        self.meetingPointLbl.text = Vocabulary.getWordFromKey(key: "meetingPoint")
//        distanceView.layer.shadowColor = UIColor.black.cgColor
//        distanceView.layer.shadowOpacity = 0.3
//        distanceView.layer.shadowOffset = CGSize.zero
//        distanceView.layer.shadowRadius = 5
        // Add Custom button for meeting Location
        print(UIScreen.main.bounds.size.height)
//        let yOrigin: CGFloat = UIScreen.main.bounds.size.height > 568.0 ? self.distanceView.frame.ori + 30.0 : self.distanceView.frame.size.height - 100
//        let buttonMap = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width - 50, y: self.distanceView.frame.origin.y , width: 40, height: 40))
        buttonMap.addTarget(self, action: #selector((self.myLocationClicked)), for: .touchUpInside)
       // buttonMap.backgroundColor = UIColor.white
       // buttonMap.layer.cornerRadius = buttonMap.frame.size.width / 2.0
        buttonMap.clipsToBounds = true
//        buttonMap.layer.borderWidth = 1.0
//        buttonMap.layer.borderColor = UIColor.black.cgColor
//        buttonMap.setImage(#imageLiteral(resourceName: "locationIcon"), for: .normal)
//        let buttonNavigation = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width - 50, y: self.distanceView.frame.origin.y, width: 40, height: 40))
        buttonNavigation.addTarget(self, action: #selector((self.navigationBtnClicked)), for: .touchUpInside)
       // buttonNavigation.backgroundColor = UIColor.white
        //buttonNavigation.layer.cornerRadius = buttonMap.frame.size.width / 2.0
        buttonNavigation.clipsToBounds = true
//        buttonNavigation.layer.borderWidth = 1.0
//        buttonNavigation.layer.borderColor = UIColor.black.cgColor
//        buttonNavigation.setImage(#imageLiteral(resourceName: "navButton"), for: .normal)
//        self.addSubview(buttonNavigation)
//        self.addSubview(buttonMap)
        // Initialization code
        DispatchQueue.main.async {
            self.addDynamicFont()
        }
    }
    
    func addDynamicFont(){
        self.meetingPointLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Heavy", textStyle: .title1)
        self.meetingPointLbl.adjustsFontForContentSizeCategory = true
        self.meetingPointLbl.adjustsFontSizeToFitWidth = true
        
        self.durationLbl.font = CommonClass.shared.getScaledFont(forFont: "Avenir-Roman", textStyle: .title1)
        self.durationLbl.adjustsFontForContentSizeCategory = true
        self.durationLbl.adjustsFontSizeToFitWidth = true
    }
    @objc func myLocationClicked() {
        self.reloadMapDelegate?.reloadMapView()
    }
    
    @objc func navigationBtnClicked() {
        self.reloadMapDelegate?.navigationClicked()
    }
    
    // Draw PolyLine on Map
    func drawPolyline(destLat: String, destLong: String, currentLat: String, currentLong: String) {
       
        var distanceMile: Double = 0.0
        if destLong != "" && currentLong != "" && destLat != "" && destLong != "" {
            let current = CLLocation(latitude: Double(currentLat)!, longitude: Double(currentLong)!)
            let dest = CLLocation(latitude: Double(destLat)!, longitude: Double(destLong)!)
            let distance = current.distance(from: dest)
            distanceMile = distance / 1609.344
                let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(currentLat),\(currentLong)&destination=\(destLat),\(destLong)&sensor=false&mode=walking&alternatives=false&key=\(MAP_API_KEY)"
                
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
                                                    str.append("miles (")
                                                    str.append("\(time[0])")
                                                    str.append(")")
                                                    self.durationLbl.text = "\(Vocabulary.getWordFromKey(key: "Walking")) - " + "\(str)"
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                            if distanceMile < 20.0 {
                                let routeOverviewPolyline = route!["overview_polyline"] as? NSDictionary
                                let points = routeOverviewPolyline?["points"] as? String
                                DispatchQueue.main.async {
                                    let path = GMSPath.init(fromEncodedPath: points!)
                                    let polyline = GMSPolyline.init(path: path)
                                    polyline.geodesic = true
                                    polyline.strokeWidth = 8.0
                                    polyline.strokeColor  = UIColor(red: 40.0/255.0, green: 133.0/255.0, blue: 207.0/255.0, alpha: 1.0)
                                    let polyline1 = GMSPolyline.init(path: path)
                                    polyline1.strokeWidth = 4.0
                                    polyline1.strokeColor = UIColor(red: 0.0/255.0, green: 179.0/255.0, blue: 253.0/255.0, alpha: 1.0)
                                    polyline.map = self.mapView
                                    polyline1.map = self.mapView
                                    self.cordinateBounds = self.cordinateBounds.includingPath(path!)
                                    let update = GMSCameraUpdate.fit(self.cordinateBounds, withPadding: 50)
                                    self.mapView.animate(with: update)
                                }
                            }
                        }
                    }
                }
                self.sendSubview(toBack: self.mapView)
                self.bringSubview(toFront: self.durationLbl)
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
