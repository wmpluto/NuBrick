//
//  NuBrickMapViewController.swift
//  NuBrick
//  地图显示界面
//  Created by mwang on 17/01/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


// NuBrick Map View Controller
class NuBrickMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // For use in foreground
        map.delegate = self
        map.mapType = .standard
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.showsUserLocation = true;
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
                //let newRegion = MKCoordinateRegion(center:(locationManager.location?.coordinate)! , span: MKCoordinateSpanMake(0.02, 0.02))
                //map.setRegion(newRegion, animated: true)
            break
        default:
            self.locationManager.requestAlwaysAuthorization()
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //map.showsUserLocation = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Location Setting
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let newRegion = MKCoordinateRegion(center: locValue, span: MKCoordinateSpanMake(0.02, 0.02))
        map.setRegion(newRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
    }
}
