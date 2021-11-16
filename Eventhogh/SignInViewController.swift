//
//  ViewController.swift
//  Eventhogh
//
//  Created by Gareth Fong on 12/3/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import UIKit
class SignInViewController: ETViewController{
        
    @IBOutlet weak var googleSignInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GoogleSignIn.setPresentingViewController(self)

        // Register notification to update screen after user successfully signed in
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDidSignInGoogle(_:)),
                                               name: .signInGoogleCompleted,
                                               object: nil)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signInGDrive" {
            let destinationVC = segue.destination as! DriveViewController
            destinationVC.accessToken = GoogleSignIn.accessToken
        }
    }
    
    // TODO: Implement hasYourRequiredScopes
    func hasYourRequiredScopes(scopes : [Any]) -> Bool {
        return true
    }
    
    @IBAction func unwindToSignInView(segue:UIStoryboardSegue) {
        
    }
    
    // MARK:- Notification
    @objc private func userDidSignInGoogle(_ notification: Notification) {
        // Update screen after user successfully signed in
        if let _ = GoogleSignIn.currentUser(){
            performSegue(withIdentifier: "signInGDrive", sender: self)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

