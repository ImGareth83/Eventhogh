//
//  PrintOptionsController.swift
//  Eventhogh
//
//  Created by Gareth Fong on 7/5/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import Foundation
import UIKit

class ETPrintInteractionController: ETViewController {
    
    var selectedIPAddress : String? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var device :String?
        
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate   = self
        tableView.dataSource = self
        
    }
    
    @IBAction func testPrintBtnPressed(_ sender: UIButton) {
        
        do {
            
            var content = try HTMLHelper.renderLabel(with: "tan meimei", ticket: "ticket", other: "oth", misc: "misc", qrCode: "123")
            print(content)
            HTMLHelper.PDF(HTMLContent: content)
            
            
            
            
            

        } catch  {
            print("Error \(error)")
        }
        
    }
}

class ETPrintCopyCell : UITableViewCell {

    @IBOutlet weak var noOfCopyLbl: UILabel!
    
    @IBOutlet weak var copyStepper: UIStepper!
    
    var noOfCopies = 1
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        noOfCopyLbl.text = (Int(sender.value)) != 1 ? "\(Int(sender.value)) Copies" : "1 Copy"
        noOfCopies       = Int(sender.value)
    }
}

class ETPrintCell: UITableViewCell {
    
    @IBOutlet weak var printerLbl: UILabel!
    
}

extension ETPrintInteractionController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell = UITableViewCell()
        
        if indexPath.row == 0 {
            cell      = tableView.dequeueReusableCell(withIdentifier: "printCell", for: indexPath) as! ETPrintCell
            
            cell.textLabel?.text = selectedIPAddress != nil ?  "\(device!)@\(selectedIPAddress!)" : "Printer"
            
        }else {
            let copyCell      = tableView.dequeueReusableCell(withIdentifier: "CopyCell", for: indexPath) as! ETPrintCopyCell
            copyCell.noOfCopyLbl.text = "1 Copy"
            cell = copyCell
    
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "showPrinters", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "showPrinters", sender: self)
        }
    }
    
    @IBAction func unwindToPrintInteractionView(segue:UIStoryboardSegue) {
           
    }

    
    
}
