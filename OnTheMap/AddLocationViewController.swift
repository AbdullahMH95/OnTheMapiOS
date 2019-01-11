//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Abdullah Al-Mahry on 11/01/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var location: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        location.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func findByMap(_ sender: Any) {
        if (location.text?.isEmpty)! {
            let alertController = UIAlertController(title: "Error", message: "No data entered", preferredStyle: .alert)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        else {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = location.text!
            //request.region = mapView.region
            
            let search = MKLocalSearch(request: request)
            
            search.start(completionHandler: {(response, error) in
                
                if error != nil {
                    let alertController = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)                } else if response!.mapItems.count == 0 {
                    let alertController = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)                } else {
                    print("Matches found")
                    let confirmViewControl = self.storyboard?.instantiateViewController(withIdentifier: "confirmViewControl") as! ConfirmViewController
                    confirmViewControl.name = self.location.text!
                    confirmViewControl.lat = response!.mapItems.first!.placemark.coordinate.latitude
                    confirmViewControl.long = response!.mapItems.first!.placemark.coordinate.longitude
                    self.present(confirmViewControl, animated: true, completion: nil)
                    
                }
            })
        }
    }
    
}
