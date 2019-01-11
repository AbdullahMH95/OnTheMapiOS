//
//  ViewController.swift
//  OnTheMap
//
//  Created by Abdullah Al-Mahry on 14/12/2018.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        email.delegate = self
        password.delegate = self
        password.isSecureTextEntry = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    @IBAction func login(_ sender: Any) {
        if (email.text?.isEmpty)! || (password.text?.isEmpty)!
        {
            print("No data enterd")
            let alertController = UIAlertController(title: "Alert", message: "No data entered", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(ok)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        else if isValidEmail(testStr: email.text!) && (password.text?.count)! > 5 {
            ParseAPI.login(email: email.text!, password: password.text!) { (error, done, userKey) in
                if done {
                    ParseAPI.GETtingPublicUserData(userKey: userKey!, onComplete: { (error, done) in
                        //
                        if done {
                            ParseAPI.GETtingStudentLocations(userKay: userKey! ,onComplete: { (error, done, data) in
                                if done {
                                    Singleton.shared.locations = data!
                                    DispatchQueue.main.async {
                                        self.password.text = ""
                                        self.email.text = ""
                                        self.performSegue(withIdentifier: "AfterLogin", sender: nil)
                                    }
                                }
                            })
                        } else {
                            DispatchQueue.main.async {
                                let alertController = UIAlertController(title: "Alert", message: error!, preferredStyle: .alert)
                                let ok = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in
                                    alertController.dismiss(animated: true, completion: nil)
                                }
                                alertController.addAction(ok)
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    })
                    
                }
                else {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Alert", message: error!, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in
                            alertController.dismiss(animated: true, completion: nil)
                        }
                        alertController.addAction(ok)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Alert", message: "Not vaild data", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in
                    alertController.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if email.isEditing || password.isEditing {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
}

