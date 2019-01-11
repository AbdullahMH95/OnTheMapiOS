//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Abdullah Al-Mahry on 09/01/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let locations = Singleton.shared.locations
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addUIBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_addpin"), style: .plain, target: self, action: #selector(self.addNewLocation))
        self.navigationItem.rightBarButtonItem  = addUIBarButtonItem
        
        let logoutBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(self.logout))
        self.navigationItem.leftBarButtonItem  = logoutBarButtonItem
        
        // Do any additional setup after loading the view.
    }
    
    @objc func addNewLocation(){
        print("add click")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "AddNew") as! AddLocationViewController
        self.present(viewController, animated: true, completion: nil)
        
    }
    
    @objc func logout() {
        print("Logout click")
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Singleton.shared.locations!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let student = Singleton.shared.locations![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell")
        cell?.textLabel?.text = "\(student.firstName!) \(student.lastName!)"
        cell?.detailTextLabel?.text = student.mapString!
        cell?.imageView?.image = UIImage(named: "icon_pin")
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = Singleton.shared.locations![indexPath.row]
        guard let url = URL(string: student.mediaURL!) else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
}
