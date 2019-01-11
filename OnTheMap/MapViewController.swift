//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Abdullah Al-Mahry on 07/01/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var locationManager = CLLocationManager.init()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.delegate = self
        
        print("Now we are in map!")
        print(Singleton.shared.userKey)
        print(Singleton.shared.sessionID!)
        // Do any additional setup after loading the view.
        showLocations(locations: Singleton.shared.locations!)
        let addUIBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_addpin"), style: .plain, target: self, action: #selector(self.clickBarButton))
        self.navigationItem.rightBarButtonItem  = addUIBarButtonItem
        
        let logoutBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(self.logout))
        self.navigationItem.leftBarButtonItem  = logoutBarButtonItem
        
    }
    
    @objc func clickBarButton(){
        print("button click")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "AddNew") as! AddLocationViewController
        self.present(viewController, animated: true, completion: nil)
    }
    
    @objc func logout() {
        ParseAPI.logout { (error, done) in
            if done {
                DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                }
            }
            else {
                DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Error", message: error!, preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    @IBAction func zoomToCurrentLocation(_ sender: UIBarButtonItem) {
        let span = MKCoordinateSpan.init(latitudeDelta: 0.0075, longitudeDelta: 0.0075)
        let region = MKCoordinateRegion.init(center: (locationManager.location?.coordinate)!, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case MapType.StandardMap.rawValue:
            mapView.mapType = .standard
        case MapType.SatelliteMap.rawValue:
            mapView.mapType = .satellite
        case MapType.HybridMap.rawValue:
            mapView.mapType = .hybrid
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        mapView .setCenter(userLocation.coordinate, animated: true)
    }
    
    private func showLocations(locations: [Location]) {
        
        if locations.isEmpty {
            return
        }
        
        var annotations = [MKPointAnnotation]()
        for location in locations {
            let annotation = MKPointAnnotation()
            if let last = location.lastName, let first = location.firstName {
                annotation.title = "\(first) \(last)"
            }
            else {
                annotation.title = "Unknown"
            }
            
            if let subtitle = location.mediaURL {
                annotation.subtitle = subtitle
            }
            else {
                annotation.subtitle = "Unknown"
            }
            
            if let lat = location.latitude, let long = location.longitude {
                annotation.coordinate = CLLocationCoordinate2DMake(lat, long)
            }
            else {
                continue
            }
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
        
        
    }
    
    
}

enum MapType: NSInteger {
    case StandardMap = 0
    case SatelliteMap = 1
    case HybridMap = 2
}
