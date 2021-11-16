//
//  HTMLHelper.swift
//  Eventhogh
//
//  Created by Gareth Fong on 18/5/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import UIKit
class HTMLHelper : NSObject{
    
    static let labelHtml = Bundle.main.path(forResource: "label", ofType: "html")
    static var pdfFilename = ""
    
    
    override init() {
        super.init()
    }
    
    static func renderLabel(with name :String, ticket : String, other: String, misc:String, qrCode:String) throws -> String {

        // Load the invoice HTML template code into a String variable.
        var html = try String(contentsOfFile: labelHtml!)
        
        //#NAME#, #TICKET#, #OTHER#, #MISC#, #QR#
        
        html = html.replacingOccurrences(of: "#NAME#", with: name)
        html = html.replacingOccurrences(of: "#TICKET#", with: ticket)
        html = html.replacingOccurrences(of: "#OTHER#", with: other)
        html = html.replacingOccurrences(of: "#MISC#", with: misc)
        html = html.replacingOccurrences(of: "#QR#", with: QRCode(data:qrCode))
        
        return html
    }
    
    static func renderQRCode(data : String) throws -> String {
        var html = try String(contentsOfFile: labelHtml!)
        html = html.replacingOccurrences(of: "#QR#", with: QRCode(data:data))
        return html
    }
    
    static func PDF(formatter : UIViewPrintFormatter, HTMLContent: String) -> NSData!{
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(formatter, startingAtPageAt: 0)
        
        // assign paperRect and printableRect 283.46, 175.75
        let page = size()
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")
        
        let pdfData = generatePDFContext(render: render, page: page)
        
        //        pdfFilename = "\(AppDelegate.getAppDelegate().getDocDir())/Label\(uniqueFilename()).pdf"
        //        pdfData?.write(toFile: pdfFilename, atomically: true)
        //        print(pdfFilename)
        
        return pdfData
    }
    
    static private func generatePDFContext(render: UIPrintPageRenderer, page : CGRect) -> NSData! {
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, page, nil)
        
        render.prepare(forDrawingPages: NSMakeRange(0, render.numberOfPages))
        
        UIGraphicsBeginPDFPage()
        
        render.drawPage(at: 0, in: UIGraphicsGetPDFContextBounds())
        
        UIGraphicsEndPDFContext()
        
        return data
    }
    
    static func QRCode(data : String) -> String {
        let encoded = data.data(using: String.Encoding.ascii)
        
        var base64Str = ""
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(encoded, forKey: "inputMessage")
            
            let scale = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: scale) {
                let image = UIImage(ciImage: output)
                base64Str = image.pngData()?.base64EncodedString() ?? ""
            }
        }
        return String(describing: base64Str)
    }
    
    static func uniqueFilename(filename: String = "") -> String {
        let uniqueString = ProcessInfo.processInfo.globallyUniqueString
        return filename + "-" + uniqueString
    }
    
    static private func size() -> CGRect {
        // label size - 283.46, 175.75
        let pageSize = CGSize(width: 283.46, height: 175.75)
        
        // create margins
        let pageMargins = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
        
        // calculate the printable rect from the above two
        let printableRect = CGRect(x: pageMargins.left, y: pageMargins.top, width: pageSize.width - pageMargins.left - pageMargins.right, height: pageSize.height - pageMargins.top - pageMargins.bottom)
        
        //  paper rectangle
        let paperRect = CGRect(x: 0, y: 0, width: pageSize.width, height: pageSize.height)
        
        return paperRect
    }
    
    
    
}
