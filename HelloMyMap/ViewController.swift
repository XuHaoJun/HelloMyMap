//
//  ViewController.swift
//  HelloMyMap
//
//  Created by fguai on 2017/6/23.
//  Copyright © 2017年 xuhaojun. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mainMapView: MKMapView!
    let locationManager = CLLocationManager()
    var firstLocationReceived = false
    let defaultTrackingSpan = MKCoordinateSpanMake(0.01, 0.01)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Ask user's permission of location
        locationManager.requestWhenInUseAuthorization()
        // Prepare locationManager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        // Prepare mainMapView
        mainMapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        switch index{
        case 0:
            mainMapView.mapType = MKMapType.standard
        case 1:
            mainMapView.mapType = MKMapType.satellite
        case 2:
            mainMapView.mapType = MKMapType.hybrid
        case 3:
            mainMapView.mapType = MKMapType.satelliteFlyover
            let coordinate = CLLocationCoordinate2DMake(35.710063, 139.8107)
            let camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: 700, pitch: 65.0, heading: 0.0)
            mainMapView.camera = camera
        default:
            mainMapView.mapType = MKMapType.standard
        }
    }
    
    @IBAction func userTrackingModeChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        switch index {
        case 0:
            mainMapView.userTrackingMode = .none
        case 1:
            mainMapView.userTrackingMode = .follow
        case 2:
            mainMapView.userTrackingMode = .followWithHeading
        default:
            mainMapView.userTrackingMode = .none
        }
    }
    
    func StoreAnnotationMake(coordinate: CLLocationCoordinate2D) -> MKPointAnnotation {
        var storeCoodinate = coordinate
        storeCoodinate.latitude += 0.0001
        storeCoodinate.longitude += 0.0001
        let annotation = MKPointAnnotation()
        annotation.coordinate = storeCoodinate
        annotation.title = "肯德基"
        annotation.subtitle = "真好吃"
        return annotation
    }

    // CLLocationManagerDelegate Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last;
        if let currentCoordinate = currentLocation?.coordinate {
            NSLog("Lat: \(currentCoordinate.latitude), Lon: \(currentCoordinate.longitude)")
            if firstLocationReceived == false {
                firstLocationReceived = true
                let region = MKCoordinateRegionMake(currentCoordinate, defaultTrackingSpan)
                mainMapView.setRegion(region, animated: false)
                let storeAnnotation = StoreAnnotationMake(coordinate: currentCoordinate)
                mainMapView.addAnnotation(storeAnnotation)
            }
        } else {
            NSLog("Empty coordinate")
        }
    }
    
    func buttonTapped(sender: Any) {
        let alert = UIAlertController(title: "標題", message: "按鈕被按下了.", preferredStyle: .actionSheet)
        let ok = UIAlertAction(title: "確認", style: .default) { (action) in
            // ...
        }
        let cancel = UIAlertAction(title: "取消", style: .destructive) { (action) in
            // ...
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MKMapViewDelegate Delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseID = "store"
        // var result: MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        var result = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if result == nil {
            // result = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            result = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        } else {
            result?.annotation = annotation
        }
        result?.canShowCallout = true
        //result?.animatesDrop = true
        //result?.pinTintColor = UIColor.green
        let image = #imageLiteral(resourceName: "PointRed")
        result?.image = image
        result?.leftCalloutAccessoryView = UIImageView(image: image)
        let button = UIButton(type: .detailDisclosure)
        button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        result?.rightCalloutAccessoryView = button
        return result
    }
}

