//
//  DashboardViewController.swift
//  Eventhogh
//
//  Created by Gareth Fong on 19/3/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import UIKit
class DashboardViewController: ETViewController {
    
    
    @IBOutlet weak var printerSettingBarButton: UIBarButtonItem!
    @IBOutlet weak var manualSignInButton: UIButton!
    @IBOutlet weak var quickSignInButton: UIButton!
    
    var accessToken     : String = ""
    var spreadsheetId   : String = ""
    var spreadsheetName : String = ""
    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = spreadsheetName
    }
    
    @IBAction func manualSignInPressed(_ sender: UIButton) {
        performSegueWithIdentifier(segueIdentifier: .showManualView, sender: self)
    }
    
    
    @IBAction func printerBtnPressed(_ sender: UIBarButtonItem) {
        performSegueWithIdentifier(segueIdentifier: .showPrintOptions, sender: self)
    }
    
    
}

extension DashboardViewController : ETSegueHandler {
    
    enum SegueIdentifier : String {
        case showManualView
        case showQRView
        case showPrintOptions
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifierForSegue(segue: segue) {
            case .showManualView:
                // prep the destination view controller
                let destinationVC             = segue.destination as! ManualSignInController
                destinationVC.accessToken     = self.accessToken
                destinationVC.spreadsheetId   = self.spreadsheetId
                
            case .showQRView :
                let destinationVC             = segue.destination as! ETQRViewController
                
                destinationVC.accessToken = self.accessToken
                destinationVC.spreadsheetId = self.spreadsheetId
            
            
            case .showPrintOptions :
                let destinationVC             = segue.destination as! ETPrintInteractionController
        }
    }
}
