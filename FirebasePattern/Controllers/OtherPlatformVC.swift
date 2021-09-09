//
//  OtherPlatformVC.swift
//  FirebasePattern
//
//  Created by Phat Nguyen on 04/09/2021.
//

import UIKit
import Toast_Swift
import FirebaseAuth
import FBSDKLoginKit
import FirebaseStorage
import FirebaseDatabase

class OtherPlatformVC: UIViewController {
    @IBOutlet weak var btnFacebook: FBLoginButton!
    @IBOutlet weak var imgAvatar: UIImageView!
    // picker Image
    let imgPicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // [Facebook] !!! Setup
        setUpLoginFacebook()
        // --- ---
        
        // Setup Upload Avatar
        setUpImgAvatar()
        // --- ---
        
        // Fetch Avatar When Init Screen
        // fetchDataFromDatabase()
        // --- ---
    }
    
    // SetUp Facebook Button.
    func setUpLoginFacebook() {
        btnFacebook.delegate = self
    }
    // --- ---
    
    // Setup Upload Avatar
    func setUpImgAvatar() {
        // Init Gesture
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(chooseAvatar))
        // Allow user interact to UIImageView
        imgAvatar.isUserInteractionEnabled = true
        // Add tapGes
        imgAvatar.addGestureRecognizer(tapGes)
    }
    
    @objc func chooseAvatar() {
        let alert = UIAlertController(title: "Choose your Avatar", message: "Choose action", preferredStyle: .actionSheet)
        
        let takePhoto = UIAlertAction(title: "Take a Photo", style: .default) { (takePhoto) in
            // TAKE A PHOTO
            self.imgPicker.sourceType = .camera
            // Show out
            self.present(self.imgPicker, animated: true, completion: nil)
        }
        
        let fromLib = UIAlertAction(title: "Choose from Library", style: .default) {
            fromLib in
            // Choose from Library
            self.imgPicker.sourceType = .photoLibrary
            // Show Image after take from Library
            self.imgPicker.delegate = self
            // Show out
            self.present(self.imgPicker, animated: true, completion: nil)
        }
        
        // Cancel chooseAvatar
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // style
        cancel.setValue(UIColor.red, forKey: "TitleTextColor")
        
        // Add 3 action into the Options Sheet
        alert.addAction(takePhoto)
        alert.addAction(fromLib)
        alert.addAction(cancel)
        // Show out the Screen
        present(alert, animated: true, completion: nil)
    }
    // --- ---
    
    // [Database] !!! Fetch data from Database
    func fetchDataFromDatabase() {
        let databaseRef = Database.database(url: "https://swift-ios-pattern-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
        databaseRef.child("picture").observe(.value) { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let picture = PictureModel(dict: dict)
                if let urlPicture = URL(string: picture.avatar) {
                    // Handle URL Here
                }
            }
        }
    }
    // ---- ----
    
    @IBAction func onTapLoginGoogle(_ sender: Any) {
    }
    
    // Upload Image to Firebase Storage
    @IBAction func onTapUploadAvatar(_ sender: Any) {
        // [Loader] !!! Show Loader here.
        if let imgUpload = self.imgAvatar.image {
            let imgName = "SwiftPattern"
            if let imgData = imgUpload.jpegData(compressionQuality: 0.5) {
                // Connect to Storage
                let storageRef = Storage.storage().reference()
                
                let uploadStorage = storageRef.child("Avatar").child(imgName)
                
                uploadStorage.putData(imgData, metadata: nil) { (meta, error) in
                    if error != nil {
                        self.view.makeToast(error?.localizedDescription)
                        
                        // [Loader] !!! Hide Loader here.
                    }
                    else {
                        self.view.makeToast("Successfully.")
                        
                        // Receive URL of Image.
                        uploadStorage.downloadURL { url, error in
                            if error != nil {
                                // If upload failed.
                                self.view.makeToast(error?.localizedDescription)
                                
                                // [Loader] !!! Hide Loader here.
                            }
                            else {
                                // Connect to Database
                                // [Important] !!! If have error: "Difference regoin database" -> Give the url in to Database.database() to try reconnect.
                                let databaseRef = Database.database(url: "https://swift-ios-pattern-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
                                // Handle URL
                                guard let urlAvatar = url else {return}
                                let value : [String: Any] = ["avatar": "\(urlAvatar)"]
                                
                                // Save to Database
                                databaseRef.child("picture").setValue(value) { (error, data) in
                                    if error != nil {
                                        // Have error
                                        self.view.makeToast(error?.localizedDescription)
                                        
                                        // [Loader] !!! Hide Loader here.
                                    }
                                    else {
                                        // Success
                                        self.view.makeToast("Saved to Database")
                                        
                                        // [Loader] !!! Hide Loader here.
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// [Facebook] !!! Extenstion to Delegate Facebook Button.
// Connect to Firebase
extension UIViewController: LoginButtonDelegate {
    public func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error != nil {
            // Failed
            self.view.makeToast(error?.localizedDescription)
        } else {
            // LogIn Facebook Successfully
            let fbLoginManager: LoginManager = LoginManager()
            fbLoginManager.logIn(permissions: ["public_profile", "email"], from: self) {
                (facebookData, error) in
                if error != nil {
                    // Catch err
                    self.view.makeToast(error?.localizedDescription)
                } else {
                    // Connect to Firebase -> receive Token
                    if let data = facebookData {
                        // grantedPermission: Check [email, public_profile, name, ...] is allowed to public.
                        // If not! -> !contains("fields")
                        if data.grantedPermissions.contains("email") {
                            // GraphQL: Receive the data Object.
                            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start {
                                (connection, result, error) in
                                if error != nil  {
                                    // Failed: connection || result = {}
                                    self.view.makeToast(error?.localizedDescription)
                                }
                                else {
                                    if let dict = result as? NSDictionary {
                                        // NSDictionary:
                                        
                                        // Ex: Take the email in facebookData
                                        guard let email = dict.object(forKey: "email") as? String else {return}
                                        // print("email \(email)")
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: FBLoginButton) {}
    
}
// --- ---

// Extension for Choose Photo from Photo Library
extension OtherPlatformVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // After finish -> Image will be returned inside info.
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imgAvatar.image = image
        }
        // Dismiss the Avatar image.
        dismiss(animated: true, completion: nil)
    }
}
