//
//  NuBrickMapViewController.swift
//  NuBrick
//
//  Created by mwang on 17/01/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class NuBrickMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // For use in foreground

        //self.locationManager.requestWhenInUseAuthorization()
        
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
 
        /*
        let spanX = 0.007
        let spanY = 0.007
        
        let newRegion = MKCoordinateRegion(center:(locationManager.location?.coordinate)! , span: MKCoordinateSpanMake(spanX, spanY))
        map.setRegion(newRegion, animated: true)
        if let coor = map.userLocation.location?.coordinate{
            map.setCenter(coor, animated: true)
        }
 */
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let newRegion = MKCoordinateRegion(center: locValue, span: MKCoordinateSpanMake(0.02, 0.02))
        map.setRegion(newRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
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
