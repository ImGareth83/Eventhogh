//
//  DriveViewController.swift
//  Eventhogh
//
//  Created by Gareth Fong on 13/3/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import UIKit
class DriveViewController : ETTableViewController{
    
    var accessToken     : String = ""
    var spreadsheetId   : String = ""
    var spreadsheetName : String = ""
    
    var files           : [GoogleFile] = []
    
    override func viewDidLoad() {
        
//        if self.accessToken == "" {
//            self.dismiss(animated: true, completion: {});
//            self.navigationController?.popViewController(animated: true);
//            print("DriveViewController viewDidLoad AccessToken")
//            return
//        }
        
        if GoogleSignIn.accessToken == "" {
            self.accessToken = GoogleSignIn.accessToken
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.hidesBackButton = true
        self.title = "Select a Google Sheet"
                
        let drive = GoogleDrive(accessToken: GoogleSignIn.accessToken)
        
        drive.getFiles { result in
            
            switch result {
            case .failure(let error):
                print("DriveViewController viewDidLoad error \(error)")
                //show alert to inform user error in getting files
                return
                
            case .success(let files):
                guard let files = files else {
                    print("DriveViewController viewDidLoad error at returnedFiles")
                    //show alert to inform user error in getting files
                    return
                }
                
                self.files = files
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            //show alert to indicate how many files
            
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = files[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFile = files[indexPath.row]
        
        spreadsheetId   = selectedFile.id
        spreadsheetName = selectedFile.name
        
        performSegueWithIdentifier(segueIdentifier: .showSpreadSheet, sender: self)
    }
    
    @IBAction func signOutBarBtnPressed(_ sender: UIBarButtonItem) {
        performSegueWithIdentifier(segueIdentifier: .showSignIn, sender: self)

    }
}

extension DriveViewController : ETSegueHandler {
    
    enum SegueIdentifier : String {
        case showSpreadSheet
        case showManualSignIn
        case showSignIn
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifierForSegue(segue: segue) {
        case .showSpreadSheet:
            // prep the destination view controller
            let destinationVC             = segue.destination as! DashboardViewController
            
            destinationVC.accessToken     = GoogleSignIn.accessToken
            destinationVC.spreadsheetId   = spreadsheetId
            destinationVC.spreadsheetName = spreadsheetName
            
        case .showManualSignIn :
            let destinationVC = segue.destination as! ManualSignInController
            
        case .showSignIn     :
            let destinationVC  = segue.destination as! SignInViewController
            GoogleSignIn.signOut()
        }
    }
}


