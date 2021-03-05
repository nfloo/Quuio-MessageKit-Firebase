/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController,GIDSignInDelegate {
  
  @IBOutlet var actionButton: UIButton!
  @IBOutlet var fieldBackingView: UIView!
  @IBOutlet var displayNameField: UITextField!
  @IBOutlet var actionButtonBackingView: UIView!
  @IBOutlet var bottomConstraint: NSLayoutConstraint!
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fieldBackingView.smoothRoundCorners(to: 8)
    actionButtonBackingView.smoothRoundCorners(to: actionButtonBackingView.bounds.height / 2)
    
    displayNameField.tintColor = .primary
    displayNameField.addTarget(
      self,
      action: #selector(textFieldDidReturn),
      for: .primaryActionTriggered
    )
    
    registerForKeyboardNotifications()
    
    // Do any additional setup after loading the view.
    GIDSignIn.sharedInstance()?.presentingViewController = self
    GIDSignIn.sharedInstance().delegate = self
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    displayNameField.becomeFirstResponder()
  }
  
  // MARK: - Actions
  
  @IBAction func actionButtonPressed() {
    signIn()
  }
  
  @objc private func textFieldDidReturn() {
    signIn()
  }
  
  // MARK: - Helpers
  
  private func registerForKeyboardNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow(_:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide(_:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
  }
  
  private func signIn() {
    guard let name = displayNameField.text, !name.isEmpty else {
      showMissingNameAlert()
      return
    }
    
    displayNameField.resignFirstResponder()
    
    GIDSignIn.sharedInstance().signIn()
    
   
  }
  
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
  //Sign in functionality will be handled here
      
      if let error = error {
      print(error.localizedDescription)
      return
      }
      guard let auth = user.authentication else { return }
      let credentials = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
      Auth.auth().signIn(with: credentials) { (authResult, error) in
      if let error = error {
      print(error.localizedDescription)
      } else {
      print("Login Successful.")
      //This is where you should add the functionality of successful login
      //i.e. dismissing this view or push the home view controller etc
          
//          self.btnSignIn.isHidden = true
//          self.lblName.isHidden = false
//          self.ivProfile.isHidden = false
//          self.btnLogout.isHidden = false
          
          let user: GIDGoogleUser = GIDSignIn.sharedInstance()!.currentUser
          let fullName = user.profile.name
          let email = user.profile.email
          
          print("FUll Name : \(fullName!)")
          print("EMail : \(email!)")
        AppSettings.displayName = fullName!
        
        NotificationCenter.default.post(name: Notification.Name.AuthStateDidChange, object: nil)
        
//          self.lblName.text = "\(fullName)"
//          if user.profile.hasImage {
//          let userDP = user.profile.imageURL(withDimension: 200)
//          self.ivProfile.sd_setImage(with: userDP, placeholderImage: UIImage(named: "default-profile"))
//          } else {
//          self.ivProfile.image = UIImage(named: "default-profile")
//          }
          
          
      }
      
  }
      
      
  }
  
  
  private func showMissingNameAlert() {
    let ac = UIAlertController(title: "Display Name Required", message: "Please enter a display name.", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
      DispatchQueue.main.async {
        self.displayNameField.becomeFirstResponder()
      }
    }))
    present(ac, animated: true, completion: nil)
  }
  
  // MARK: - Notifications
  
  @objc private func keyboardWillShow(_ notification: Notification) {
    guard let userInfo = notification.userInfo else {
      return
    }
    guard let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
      return
    }
    guard let keyboardAnimationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
      return
    }
    guard let keyboardAnimationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else {
      return
    }
    
    let options = UIView.AnimationOptions(rawValue: keyboardAnimationCurve << 16)
    bottomConstraint.constant = keyboardHeight + 20
    
    UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: options, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
  @objc private func keyboardWillHide(_ notification: Notification) {
    guard let userInfo = notification.userInfo else {
      return
    }
    guard let keyboardAnimationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
      return
    }
    guard let keyboardAnimationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else {
      return
    }
    
    let options = UIView.AnimationOptions(rawValue: keyboardAnimationCurve << 16)
    bottomConstraint.constant = 20
    
    UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: options, animations: {
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
  
}
