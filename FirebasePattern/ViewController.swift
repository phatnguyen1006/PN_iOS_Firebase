//
//  ViewController.swift
//  FirebasePattern
//
//  Created by Phat Nguyen on 03/09/2021.
//

import UIKit
import Toast_Swift
import FirebaseAuth

class ViewController: UIViewController {
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        autoLogin() // Check AutoLogin first when the app open
    }
    
    // Setup AutoLogin when the App open
    func autoLogin() {
        let currentUserId = Auth.auth().currentUser?.uid
        if currentUserId != nil {
            // Auto Login -> Navigator screen
            print("Auto Login")
            
            // Do something
        }
    }
    
    // --- Forgot Password ---
    // Forgot Password by send a link to Email
    @IBAction func tapOnForgot(_ sender: Any) {
        view.endEditing(true)   // hide the keyboard
        // Send the Reset link to the Email
        if tfEmail.text == "" {
            // Validation
            self.view.makeToast("Please enter your email")
        }
        else {
            Auth.auth().sendPasswordReset(withEmail: tfEmail.text!) { error in
                if error != nil {
                    // Firebase Failed
                    self.view.makeToast(error?.localizedDescription)
                }
                else {
                    // Successfully
                    self.view.makeToast("Please check your email to change password")
                }
            }
        }
    }
    // ---- ----
    
    // Navigator screen -> Register Screen
    @IBAction func tapOnRegister(_ sender: Any) {
        // Navigator push to Register Screen
        let registerVC = RegisterVC(nibName: "RegisterVC", bundle: nil)
        navigationController?.pushViewController(registerVC, animated: true)
    }
    // --- ---
    
    // --- LOGIN ---
    @IBAction func tapOnLogin(_ sender: Any) {
        view.endEditing(true)   // hide the keyboard
        
        if tfEmail.text == "" || tfPassword.text == "" {
            // Validation
            self.view.makeToast("Please enter all required fields")
        }
        else {
            // [Keyword?] [weak self] : to prevent crash the app when we call SignIn firebase
            Auth.auth().signIn(withEmail: tfEmail.text!, password: tfPassword.text!) { [weak self]
                (authData, error) in
                if error != nil {
                    // SignIn failed
                    self?.view.makeToast(error!.localizedDescription)
                }
                else {
                    // Reload Firebase
                    authData?.user.reload(completion: { error in
                        if error != nil {
                            self?.view.makeToast(error!.localizedDescription)
                        }
                        if (authData?.user.isEmailVerified)! {
                            // Successfully -> Do something
                            self?.view.makeToast("Login successfully")
                        }
                        else {
                            self?.view.makeToast("Your email have not verified yet")
                        }
                    })
                }
            }
        }
    }
    // --- ---
    
    // --- SignOut in Firebase ---
    @IBAction func tapOnLogOut(_ sender: Any) {
        // [Important] !!! SignOut on Firebase need to keyword "try" before
        try? Auth.auth().signOut()
        
        // Do something
    }
    // --- ---
    
    // LOGIN By Other Platform
    // Navigator Screen -> OtherPlatfrom Screen
    @IBAction func tapOnOtherPlatform(_ sender: Any) {
        // CHANGE SCREEN
        let otherPlatformVC = OtherPlatformVC(nibName: "OtherPlatformVC", bundle: nil)
        navigationController?.pushViewController(otherPlatformVC, animated: true)
    }
    // ---- ----
}
