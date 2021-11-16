//
//  QRViewController.swift
//  Eventhogh
//
//  Created by Gareth Fong on 30/3/20.
//  Copyright © 2020 Gareth Fong. All rights reserved.
//

import UIKit
import AVFoundation

class ETQRViewController: ETViewController {
    
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var scanView: UIView!
    
    var qrCodeFrameView: UIView?
    
    var captureSession : AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var lastQRCode = ""
    var useFrontCamera = true
    
    var spreadsheetId = ""
    var accessToken  = ""
    
    var googleSheets : GoogleSheets?
    
    @IBAction func cameraPressed(_ sender: UIButton) {
        //remove current input
        captureSession?.removeInput((captureSession?.inputs.first)!)
        
        //use front camera if current device is rear camera
        let captureDevice = useFrontCamera ? cameraWithPosition(position: .front) : cameraWithPosition(position: .back)
        
        let input = try? AVCaptureDeviceInput(device: captureDevice!)
        
        captureSession?.addInput(input!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleSheets = GoogleSheets(spreadsheetId: spreadsheetId, accessToken: accessToken)
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
            
        case .authorized:
            // The user has previously granted access to the camera.
            let captureSession = setupCaptureSession()
            
            // Display the video captured by the device's camera on screen by initialising the video preview layer
            // Add it as a sublayer to the viewPreview view's layer
            if let videoPreview = previewVideo(session: captureSession) {
                videoPreviewLayer = videoPreview
                scanView.layer.addSublayer(videoPreview)
                captureSession.startRunning()
            }
            
            
        case .notDetermined:
            // The user has not yet been asked for camera access.
            requestCameraPermission()
            
        case .denied, .restricted:
            // The user has previously denied access, or can't grant access due to restrictions.
            alertCameraAccess()
            
        @unknown default:
            failed()
        }
        
        setupQRCodeFrame()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession?.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    // Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
    private func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
    //MARK: - Methods related to camera usage and access
    private func setupCaptureSession() -> AVCaptureSession{
        // Start a capture Session
        let captureSession = AVCaptureSession()
        
        // Get the default video device (default is rear, wide angle camera)
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        // Get an instance of the AVCaptureDeviceInput using the Capture Device
        let input = try? AVCaptureDeviceInput(device: captureDevice!)
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output
        let metadataOutput = AVCaptureMetadataOutput()
        
        //Adding both input and output to the session before setting the metadata object types.
        captureSession.addInput(input!)
        captureSession.addOutput(metadataOutput)
        
        // Set delegate and use the default dispatch queue to execute the call back
        // When new metadata objects are captured, they are forwarded to the delegate object for further processing.
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        // Indicates the Metadata is QR
        metadataOutput.metadataObjectTypes = [.qr]
        
        // Display the video captured by the device's camera on screen by initialising the video preview layer
        // Add it as a sublayer to the viewPreview view's layer
//        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        videoPreviewLayer?.frame = view.layer.bounds
//
//        scanView.layer.addSublayer(videoPreviewLayer!)
        
        //start video capture
//        captureSession.startRunning()
        
        return captureSession
    }
    
    func previewVideo(session : AVCaptureSession)-> AVCaptureVideoPreviewLayer?{
        let videoLayer = AVCaptureVideoPreviewLayer(session: session)
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoLayer.frame = view.layer.bounds
        
        return videoLayer
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                //self.alertCameraAccess()
                self.captureSession = self.setupCaptureSession()
            }
            else{
                self.failed()
                return
            }
        }
    }
    
    private func setupQRCodeFrame() {
        // Initialize QR Code Frame to highlight the QR code in Blue
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.systemBlue.cgColor
            qrCodeFrameView.layer.borderWidth = 4
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }
    
    //MARK: - Alerts
    private func alertCameraAccess() {
        
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        
        let alert = UIAlertController(
            title: "Need Camera Access",
            message: "Camera access is required to make full use of this app.",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func failed(){
        let alert = UIAlertController(title: "Scanning not supported", message: "Device does not supported scanning QR code", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
        captureSession = nil
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
      layer.videoOrientation = orientation
      videoPreviewLayer?.frame = view.bounds
    }
    
    func promptError(code : String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error in loading your GoogleSheet?", message: "Make sure your sheet conforms to our specification \(code)", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
                //do nothing
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ETQRViewController : AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Check if the metadataObjects array is contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = .zero
            displayLabel.text = "No QR Code is detected"
            return
        }
        
        //self.captureSession?.stopRunning()
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // If the found metadata is equal to the QR code metadata, then update the status label's text and set the bounds
        if metadataObj.type == .qr {
            
            let qrCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
                        
//            qrCodeFrameView?.frame = qrCodeObject!.bounds
            
            if let outputString = metadataObj.stringValue {
                
                guard let sheets = googleSheets else {
                    return
                }
                                
                //select%20A%2C%20B%2C%20C%2C%20D%2C%20E%20where%20E%3D''
                //"select%20A%2C%20B%2C%20C%2C%20D%20where%20D%20matches%20'\(outputString)'"
                //"select%20A%2C%20B%2C%20C%2C%20D%2C%20E"
            
                let sql = "select%20A%2C%20B%2C%20C%2C%20D%2C%20E%20where%20E%3D'\(outputString)'"
                
                sheets.getSpreadsheet(by: sql) { result in
                    
                    switch result {
                        
                        case .success(let results) :
                            guard let sheet = results else {return}

//                            let name     = sheet.values[0][0]
//                            let dateTime = sheet.values[0][1]
//                            let tag      = sheet.values[0][2]
//                            let qrCode   = sheet.values[0][3]
//                            
//                            print("success \(name) \(dateTime) \(tag) \(qrCode)")
                            
                        case .failure(let error):
                        print("error :\(error)")
                        return
                    }
                }
                
                
                if outputString != self.lastQRCode {
                    DispatchQueue.main.async {
                        self.displayLabel.text = outputString
                        self.lastQRCode = outputString
                    }
                    
                    // Stop capture session
                    self.videoPreviewLayer?.isHidden = true
                    self.qrCodeFrameView?.isHidden = true
                    self.captureSession?.stopRunning()
                    
                }
                else {
                    self.displayLabel.text = outputString+" has been scanned"
                    
                }
            }
        }
    }
    
}
