//
//  SearchViewController.swift
//  Eventhogh
//
//  Created by Gareth Fong on 30/3/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import UIKit

import SwipeCellKit

class ManualSignInController: ETTableViewController, UISearchResultsUpdating, SwipeTableViewCellDelegate {
    
    var accessToken     : String     = ""
    var spreadsheetId   : String     = ""
    var values          : [[String]] = [[String]]()
    var filteredValues  : [[String]] = [[String]]()
    
    let headerRow       : [String]   = ["name","datetime","other","check-In"]
    
    var search: UISearchController!
    
    override func viewDidLoad() {
        
        let googleSheets = GoogleSheets(spreadsheetId: spreadsheetId, accessToken: accessToken)
                
        googleSheets.getSpreadsheet(withRange: "A1:D10") { result in
            switch result {
                case .failure(let error):
                    //show alert to inform user error in getting files
                    self.promptError(code: error.localizedDescription)
                    return
                
                case .success(let results):
                    guard let sheet = results else {
                        self.promptError(code: "no column")
                        //show alert to inform user error in getting files
                        return
                    }
                    
                    //remove header row
//                    if let firstRow = sheet.values.first {
//                        if self.containsHeaderRow(row: firstRow) {
//                            sheet.values.removeFirst()
//                        }
//                    }
                    
                    self.values = sheet.values
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        search = UISearchController(searchResultsController: nil)
        definesPresentationContext = true
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.sizeToFit()
        search.hidesNavigationBarDuringPresentation = false
        search.searchBar.placeholder = "Type something here to search"
        tableView.tableHeaderView = search.searchBar
    }
    
    func containsHeaderRow(row : [String]) -> Bool{
        for item in row {
            if headerRow.contains(where: {$0.caseInsensitiveCompare(item) == .orderedSame}){
                return true
            }
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if search.isActive && search.searchBar.text != ""{
            return filteredValues.count
        }
        
        return values.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell      = tableView.dequeueReusableCell(withIdentifier: "AttendeeCell", for: indexPath) as! AttendeeCell
        cell.delegate = self
        
        var tag      :String = ""
        var name     :String = ""
        var dateTime :String = ""
        
        if search.isActive && search.searchBar.text != ""{
            name      = filteredValues[indexPath.row][0]
            dateTime  = filteredValues[indexPath.row][1]
            tag       = filteredValues[indexPath.row][2]
            
            if filteredValues[indexPath.row][3] == "Y" {
                cell.accessoryType = .checkmark
            }
        }
        else {
            name      = values[indexPath.row][0]
            dateTime  = values[indexPath.row][1]
            tag       = values[indexPath.row][2]
            
            if values[indexPath.row][3] == "Y" {
                cell.accessoryType = .checkmark
            }
        }
        
        cell.nameLabel.text     = name
        cell.dateTimeLabel.text = dateTime
        cell.tagLabel.text      = tag
        cell.otherLabel.text    = "other"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        var selectedValue = values[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! AttendeeCell

        let signInOutAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            
            switch action.title {
                case "Sign In" :
                    //insert the current date & time
                    let format = DateFormatter()
                    format.dateFormat = "dd-MMM-yyyy HH:mm:ss"
                    
                    let now = format.string(from: Date())
                    
                    selectedValue[1] = now
                    
                    //update the check-in to Y
                    selectedValue[3] = "Y"
                    self.values[indexPath.row][3]="Y"
                    cell.checkmark = true
                    cell.dateTimeLabel.text = now
                    
                case "Undo"    :
                    selectedValue[1] = ""
                    
                    //update the check-in to Y
                    selectedValue[3] = "N"
                    self.values[indexPath.row][3]="N"
                    cell.checkmark = false
                    cell.dateTimeLabel.text = ""
                    
                default :
                    self.promptError(code: "invalid action")
            }
            
            //add 1 to the selected row 
            let sheet = GoogleValues(range: "A\(indexPath.row+1):D\(indexPath.row+1)", values: [selectedValue])
            let googleSheets = GoogleSheets(spreadsheetId: self.spreadsheetId, accessToken: self.accessToken)
            googleSheets.updateSpreadsheet(sheets: sheet) { (result) in
                switch result {
                    case .failure(let error)    : print("failure \(error)")
                    case .success(let response) : print("success \(String(describing: response))")
                }
            }
        }
        
        if values[indexPath.row][3] == "Y" {
            signInOutAction.title = "Undo"
            signInOutAction.backgroundColor = .systemPink
            signInOutAction.image = UIImage(named: "arrow.uturn.left.circle")
        }
        else if values[indexPath.row][3] == "N" {
            signInOutAction.title = "Sign In"
            signInOutAction.backgroundColor = .systemGreen
            signInOutAction.image = UIImage(named: "checkmark")
        }
        
        signInOutAction.hidesWhenSelected = true
        
        return [signInOutAction]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
    
    func promptError(code : String){
        let alert = UIAlertController(title: "Error in loading your GoogleSheet?", message: "Make sure your sheet conforms to our specification \(code)", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
            //do nothing
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        filteredValues = values.filter { (value : [String]) -> Bool in
            return value[0].lowercased().contains(text.lowercased())
        }

        tableView.reloadData()
    }
    
    
    
}

class AttendeeCell: SwipeTableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var otherLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    var checkmark = false  {
        didSet {
            accessoryType = checkmark ? .checkmark : .none
        }
    }
}
