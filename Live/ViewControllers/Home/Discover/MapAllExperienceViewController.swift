//
//  MapAllExperienceViewController.swift
//  Live
//
//  Created by IPS on 24/07/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
class MapAllExperienceViewController: UIViewController,GMSMapViewDelegate {
    
    @IBOutlet weak var objMapView: GMSMapView!
    var arrayOfAllExperience:[Experience] = []
    var locationID:String = ""
    var markers:[GMSMarker] = []
    var objCountyDetail:CountyDetail?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if locationID.count > 0{
            self.getAllExperienceOnLocation(locationID: self.locationID)
            self.objMapView.delegate = self
            self.objMapView.isMyLocationEnabled = true
            self.objMapView.settings.myLocationButton = true
            self.objMapView.clear()
            if let countydetail = self.objCountyDetail,let latitude = Double(countydetail.latitude),let logitude = Double(countydetail.longitude){
                let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: logitude, zoom:12)
                self.objMapView.camera = camera
                self.objMapView.animate(to: camera)
                //self.objMapView.animate(toLocation: CLLocationCoordinate2D(latitude: latitude, longitude: logitude))
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    // MARK: - Custom Methods
    func addAllExperienceOnMapView(){
        
    }
    // MARK: - API Request Methods
    func getAllExperienceOnLocation(locationID:String){
        
        let urlAllExperience = "\(kAllExperience)\(locationID)/allexperiences?pagesize=-1&pageindex=0"

        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:urlAllExperience, parameter: nil, isHudeShow:true, success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successDate = success["data"] as? [String:Any],let array = successDate["experiences"] as? [[String:Any]]{
                self.arrayOfAllExperience = []
                self.markers = []
                for object in array{
                    let objectExperience = Experience.init(experienceDetail: object)
                    self.arrayOfAllExperience.append(objectExperience)
                    DispatchQueue.main.async {
                        if let latitude = Double(objectExperience.latitude),let logitude = Double(objectExperience.longitude){
                            let destCoordinate = CLLocationCoordinate2DMake(latitude, logitude)
                            let markerDest = GMSMarker(position: destCoordinate)
                            markerDest.title = "\(objectExperience.title)"
                            markerDest.userData = objectExperience
                            //markerDest.snippet = "Test snippet"
                            if objectExperience.instant{
                                let markerImage = UIImage(named: "destinationMarkerIcn")!.withRenderingMode(.alwaysTemplate)
                                let markerView = UIImageView(image: markerImage)
                                markerView.tintColor = UIColor.init(hexString:"36537b")
                                markerDest.iconView = markerView
                            }else{
                                markerDest.iconView = UIImageView.init(image: UIImage.init(named: "destinationMarkerIcn"))
                            }
                            markerDest.map = self.objMapView
                            self.markers.append(markerDest)
//                                let markerImage = UIImage(named: "destinationMarkerIcn")!.withRenderingMode(.alwaysTemplate)
//                                let markerView = UIImageView(image: markerImage)
//                                markerView.tintColor = UIColor.init(hexString:"36537b")
//                                markerDest.iconView = markerView
//                            }else{
//                                markerDest.iconView = UIImageView.init(image: UIImage.init(named: "destinationMarkerIcn"))
//                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.addAllExperienceOnMapView()
                }
            }else{
                DispatchQueue.main.async {
                    //ShowToast.show(toatMessage:kCommonError)
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
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if let index = markers.index(of: marker) {
            if self.arrayOfAllExperience.count > index{
                let objExperience = self.arrayOfAllExperience[index]
                self.pushToBookDetailController(objExperience: objExperience)
            }
        }
    }
    func pushToBookDetailController(objExperience:Experience){
        guard CommonClass.shared.isConnectedToInternet else {
            return
        }
        guard User.isUserLoggedIn else {
            let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"notLogin.title"), message: Vocabulary.getWordFromKey(key:"notLogin.msg"), preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key:"ok.title"), style: .default, handler: { (_) in
                self.navigationController?.popToRootViewController(animated: true)
            }))
            let continueSelelector = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"continueBrowsing"), style: .cancel, handler: nil)
            
            alertController.addAction(continueSelelector)
            alertController.view.tintColor = UIColor(hexString: "#36527D")

            self.present(alertController, animated: true, completion: nil)
            return
        }
        let storyboard = UIStoryboard(name: "BooknowDetailSB", bundle: nil)
        if let bookDetailcontroller = storyboard.instantiateViewController(withIdentifier: "BookDetailViewController") as? BookDetailViewController {
            bookDetailcontroller.bookDetailArr = objExperience
            self.navigationController?.pushViewController(bookDetailcontroller, animated: true)
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

