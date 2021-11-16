//
//  BrotherPrinter.swift
//  Eventhogh
//
//  Created by Gareth Fong on 4/5/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import Foundation
import BRPtouchPrinterKit

class BrotherPrinter : NSObject{
    
    typealias printResponse = (Int32)->Void
        
    let supportedPrinterModels : [String] = ["QL-820NWB","QL-810W","QL-1110NWB","QL-1115NWB"]
    var templateKey            : Int?
    var availabeDevices        : [BRPtouchDeviceInfo]?
    var printer                : BRPtouchPrinter
    var filePath               : String
    var settings          : BRPtouchPrintInfo?
    
    enum PrintError: Error {
        case printError(String)
    }
    
    init(ipAddress : String) throws {
        printer = BRPtouchPrinter(printerIPAddress: ipAddress)
        
        let infoPlist = try ETPList<InfoPList>()
        let folder    = infoPlist.data.Configuration.labelFolder
        let file      = infoPlist.data.Configuration.labelFile
        templateKey   = infoPlist.data.Configuration.templateKey
        
        let bundleURL = Bundle.main.bundleURL
        let folderURL = bundleURL.appendingPathComponent(folder)
        let fileURL   = folderURL.appendingPathComponent(file)
        filePath      = fileURL.relativePath
        
        super.init()
    }
    
    func printTemplate(templateKey : Int, inputs : [String:String]) ->Bool {
        var isPrinted = false
        
        printTemplate(inputs: inputs) { errorCode in
            if  errorCode != RET_FALSE {
                isPrinted = true
            }
        }
        
        return isPrinted
    }
    
    func printTemplate(inputs : [String:String], completion:printResponse) {
        
        // Connect, then print
        if printer.startCommunication() {
            
            // Specify the template key and the printer's encoding
            if printer.startPTTPrint(Int32(templateKey!), encoding: String.Encoding.utf8.rawValue) {
                
                // Replace text object with new text
                for (key,value) in inputs {
                    printer.replaceTextName(value, objectName: key)
                }
                
                let errorCode = printer.flushPTTPrint(withCopies:1)
                completion(errorCode)
            }
            
            printer.endCommunication()
        }
    }
    
    func transferTemplate(completion : printResponse){
        // Connect and transfer template
        if printer.startCommunication() {
            
            let errorCode = printer.sendTemplate(filePath, connectionType: .WLAN)
            
            completion(errorCode)
            
            printer.endCommunication()
        }
    }
    
    func defaultPrintSetting() -> BRPtouchPrintInfo{
        // Print Settings
        let settings          = BRPtouchPrintInfo()
        settings.strPaperName = "102mmx51mm"
        settings.nPrintMode   = PRINT_FIT_TO_PAGE
        settings.nAutoCutFlag = OPTION_AUTOCUT
        return settings
    }
    
    func printImage(image: UIImage, completion:printResponse) {
        guard let s = settings else {
            return
        }
        
        printer.setPrintInfo(s)
        // Connect, then print
        if printer.startCommunication() {
            let errorCode = printer.print(image.cgImage, copy: 1)
//            if errorCode != ERROR_NONE_ {
//                print("ERROR - \(errorCode)")
//            }
            printer.endCommunication()
            completion(errorCode)
        }
    }
    
    
}
