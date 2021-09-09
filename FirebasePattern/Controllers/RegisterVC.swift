//
//  RegisterVC.swift
//  FirebasePattern
//
//  Created by Phat Nguyen on 03/09/2021.
//

import UIKit
import Toast_Swift
import FirebaseAuth

class RegisterVC: UIViewController {
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // background
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
    }
    
    // Register Firebase
    // Create User and send Verifications to Email
    @IBAction func tapOnRegister(_ sender: Any) {
        view.endEditing(true)   // hide the keyboard
        
        if tfEmail.text == "" || tfPassword.text == "" {
            self.view.makeToast("Please enter all required fields")
        }
        else {
            // Create user
            Auth.auth().createUser(withEmail: tfEmail.text!, password: tfPassword.text!) { authData, error in
                if error != nil {
                    self.view.makeToast(error?.localizedDescription)
                }
                //                 Sign up not Verification
                //                else {
                //                    self.view.makeToast("Register Successfully")
                //                }
                
                // Send VERIFICATION to EMAIL
                authData?.user.sendEmailVerification(completion: { error in
                    if error != nil {
                        self.view.makeToast(error!.localizedDescription)
                    }
                    else {
                        // Successfully
                        self.view.makeToast("Sent Verification to your email")
                    }
                })
            }
        }
    }
    // ---- ----
}
