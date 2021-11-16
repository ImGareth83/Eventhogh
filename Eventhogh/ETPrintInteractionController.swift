//
//  PrintOptionsController.swift
//  Eventhogh
//
//  Created by Gareth Fong on 7/5/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class ETPrintInteractionController: ETViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var copiesLbl: UILabel!
    @IBOutlet weak var printerLbl: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    var noOfCopies = 1
    var previewHTML : String?
    
    @IBAction func valueChanged(_ sender: UIStepper) {
        copiesLbl.text = "\(Int(stepper.value)) Copies"
        noOfCopies = Int(stepper.value)
    }
    
    var selectedIPAddress : String = ""
    let path = Bundle.main.path(forResource: "previewLabel", ofType: "html")
    
    var savedPrinter : UIPrinter? {
        didSet{
            var text : String = ""
            if let selectedIPAddress = savedPrinter?.url.host {
                if let makeAndModel = savedPrinter?.makeAndModel {
                    text = makeAndModel+"@"+selectedIPAddress
                }
                else {
                    text = selectedIPAddress
                }
            }
            printerLbl.text = text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        do {
            //Preview the label
            previewHTML = try String(contentsOfFile: path!)
            previewHTML = try HTMLHelper.renderQRCode(data: "HELLO")
            
            webView.loadHTMLString(previewHTML!, baseURL: nil)
            webView.scrollView.isScrollEnabled = false
            
        } catch {
            promptError()
        }
        
        self.labelTap()
    }
    
    @IBAction func unwindToPrintInteractionView(segue:UIStoryboardSegue) {
    }
    
    func labelTap() {
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
        self.printerLbl.isUserInteractionEnabled = true
        self.printerLbl.addGestureRecognizer(labelTap)
    }
    
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        printerDialog()
    }
    
    @IBAction func testPrintBtnPressed(_ sender: UIButton) {
        let printController = UIPrintInteractionController.shared
        
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfo.OutputType.general
        printInfo.orientation = .landscape
        printInfo.duplex = .none
        
        printInfo.jobName = "Eventhogh Test Print"
        
        printController.printInfo = printInfo
        
        guard let html = previewHTML else { return }
        
        let formatter = webView.viewPrintFormatter()
        let pdf = HTMLHelper.PDF(formatter: formatter, HTMLContent: html)
        
        if noOfCopies > 1 {
            var pdfArray = [Any?]()
            
            for _ in 1...noOfCopies {
                let duplicate = pdf?.copy()
                pdfArray.append(duplicate)
            }
            
            printController.printingItems = pdfArray as [Any]
        }
        else{
            printController.printingItem = pdf
        }
        
        guard let printer = savedPrinter else {
            self.promptError()
            return
        }
        
        printController.print(to: printer) { (controller, completed, error) in
            if error != nil {
                self.promptError()
            }
        }
    }
    
    func promptError(){
        let alert = UIAlertController(title: "Error in Printing?", message: "Try to reconnect to printer", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Error in Printing", style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
            GoogleSignIn.signIn()
        }))
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK:- UIPrinterPickerControllerDelegate
extension ETPrintInteractionController: UIPrinterPickerControllerDelegate {
    func printerPickerControllerParentViewController(_ printerPickerController: UIPrinterPickerController) -> UIViewController? {
        return self
    }
    
    func printerDialog(){
        let picker = UIPrinterPickerController(initiallySelectedPrinter: nil)
        picker.delegate = self
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            picker.present(from: CGRect(x: 400, y: 200, width: 0, height: 0), in: view, animated: true){( printerPickerController, userDidSelect, error)  in
                if userDidSelect {
                    self.savedPrinter = printerPickerController.selectedPrinter
                }
            }
        }else {
            picker.present(animated: true) { (printerPickerController, userDidSelect, error) in
             if userDidSelect {
                self.savedPrinter = printerPickerController.selectedPrinter
              }
            }
        }
    }
}
