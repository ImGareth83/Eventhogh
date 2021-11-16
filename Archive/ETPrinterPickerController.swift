//
//  PrinterViewController.swift
//  Eventhogh
//
//  Created by Gareth Fong on 30/3/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import UIKit
import BRPtouchPrinterKit

protocol ETPrinterCellDelegate  {
    func didSelectPrinter(ipAddress : String, device: String)
}

class ETPrinterCell: UITableViewCell {
    var ipAddress : String?
    var device : String?
    var delegate : ETPrinterCellDelegate?

    @IBOutlet weak var printerLabel: UILabel!
    
    @IBOutlet weak var selectPrinterBtn: UIButton!
    
    @IBAction func selectPrinterPressed(_ sender: UIButton) {
        guard let ip = ipAddress else { return }
        guard let device = device else { return }
        
        delegate?.didSelectPrinter(ipAddress: ip, device: device)
    }
}

class ETPrinterPickerController: ETTableViewController {
    
    var selectedPrinterIP : String?
    var device : String?
    
    @IBAction func refreshBtnPressed(_ sender: UIBarButtonItem) {
        availabeDevices = [BRPtouchDeviceInfo]()
        tableView.reloadData()
        searchWiFiPrinter()
    }
    
    private let supportedPrinterModels : [String] = ["QL-820NWB","QL-810W","QL-1110NWB","QL-1115NWB"]
    var availabeDevices : [BRPtouchDeviceInfo] = [BRPtouchDeviceInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchWiFiPrinter()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrinterCell", for: indexPath) as! ETPrinterCell
        cell.delegate = self
        
        let printer = availabeDevices[indexPath.row]
        cell.ipAddress = printer.strIPAddress
        cell.device = printer.strNodeName
        cell.printerLabel.text = printer.strNodeName+"@"+printer.strIPAddress
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        availabeDevices.count
    }
    
    func promptNoPrinter(){
        let alert = UIAlertController(title: "Printer", message: "No Printer found. Make sure printers are connected with same WIFI", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
            
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
}
extension ETPrinterPickerController : ETPrinterCellDelegate {
    func didSelectPrinter(ipAddress: String, device: String) {
        
        self.selectedPrinterIP = ipAddress
        self.device  = device
        
        performSegue(withIdentifier: "unwindToPrintOptions", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let ip = selectedPrinterIP else { return }
        
        if segue.identifier == "unwindToPrintOptions" {
            if let destination = segue.destination as? ETPrintInteractionController {
                destination.selectedIPAddress = ip
                destination.device = device
            }
        }
    }
}

//BrotherPrinter cannot extend BRPtouchNetworkDeletgate because didFinishSearch throws NSInvalidArguement
extension ETPrinterPickerController : BRPtouchNetworkDelegate{

    func searchWiFiPrinter() {
        let manager = BRPtouchNetworkManager()
        manager.delegate = self
        manager.setPrinterNames(supportedPrinterModels)

        //Time to perform the search in seconds
        manager.startSearch(3)
    }

    //delegate method called after manager.startSearch
    func didFinishSearch(_ sender: Any!) {

        guard let manager = sender as? BRPtouchNetworkManager else {
            return
        }

        guard let devices = manager.getPrinterNetInfo() else {
            return
        }
        
        if devices.isEmpty {
            promptNoPrinter()
        }

//        for deviceInfo in devices {
//            if let deviceInfo = deviceInfo as? BRPtouchDeviceInfo {
//                print("Node: \(deviceInfo.strNodeName) Model: \(deviceInfo.strModelName), IP Address: \(deviceInfo.strIPAddress) ")
//            }
//        }
        
        DispatchQueue.main.async {
            // the super class with available printer device(s)
            self.availabeDevices = devices as! [BRPtouchDeviceInfo]
            self.tableView.reloadData()
        }
    }

}
