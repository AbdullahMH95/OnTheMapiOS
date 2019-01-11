//
//  ConfirmViewController.swift
//  OnTheMap
//
//  Created by Abdullah Al-Mahry on 11/01/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit

class ConfirmViewController: UIViewController, UITextFieldDelegate {
    
    var lat: Double = 0.0
    var long: Double = 0.0
    var name: String = ""
    @IBOutlet weak var mediaURL: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mediaURL.delegate = self
        // Do any additional setup after loading the view.
        let location = MKPointAnnotation()
        location.title = name
        location.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        mapView.addAnnotation(location)
        mapView.setCenter(location.coordinate, animated: true)
    }
    
    @IBAction func confirm(_ sender: Any) {
        if mediaURL.text!.isEmpty {
            let alertController = UIAlertController(title: "Error", message: "No data entered", preferredStyle: .alert)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        else {
            ParseAPI.POSTingStudentLocation(mapString: name, mediaURL: mediaURL.text!, lat: lat, long: long) { (error, done) in
                if done {
                    DispatchQueue.main.async {
                        Singleton.shared.locations!.append(Location(mediaURL: self.mediaURL.text!, firstName: Singleton.shared.firstName, lastName: Singleton.shared.lastName, latitude: self.lat, mapString: self.name, longitude: self.long))
                        self.performSegue(withIdentifier: "Home", sender: nil)
                    }
                }
                else {
                    let alertController = UIAlertController(title: "Error", message: error!, preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)                }
            }
        }
    }
    
}
