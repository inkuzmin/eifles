//
//  ViewController.swift
//  eifles
//
//  Created by Your Mom on 02/02/16.
//  Copyright © 2016 Your Mom. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    

    @IBOutlet weak var photoPreviewWrap: UIView!
    
    let captureSession = AVCaptureSession()
    
    let photoOutput = AVCaptureStillImageOutput()
    
    var captureDevice : AVCaptureDevice?
    
    @IBOutlet weak var splashView: UIImageView!
    
    @IBAction func takePhoto(sender: AnyObject) {
        
        splashView.hidden = false
        splashView.alpha = 1
        UIView.animateWithDuration(0.2, animations: {
            self.splashView.alpha = 0
            
            }, completion: { (Bool) -> () in
                self.splashView.alpha = 1
                self.splashView.hidden = true
            })
        
        
        if let videoConnection = photoOutput.connectionWithMediaType(AVMediaTypeVideo) {
            photoOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                
                if let image = UIImage(data: imageData) {
                    let flippedImage = UIImage(CGImage: image.CGImage!, scale: image.scale, orientation: UIImageOrientation.LeftMirrored)
                    
                    UIImageWriteToSavedPhotosAlbum(self.textToImage("уруру", inImage: image, atPoint: CGPoint.zero), nil, nil, nil)
                    UIImageWriteToSavedPhotosAlbum(self.textToImage("мимими", inImage: flippedImage, atPoint: CGPoint.zero), nil, nil, nil)
                }
            }
        }
        
        
        
    }
    
    func textToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage{
    
        let textColor: UIColor = UIColor.whiteColor()
        let textFont: UIFont = UIFont(name: "Helvetica Bold", size: 12)!
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.blackColor()
        shadow.shadowOffset = CGSize(width: 0,height: 1)
        
        UIGraphicsBeginImageContext(inImage.size)
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            NSShadowAttributeName: shadow
        ]
        
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        let rect: CGRect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)
        
        drawText.drawInRect(rect, withAttributes: textFontAttributes)
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return newImage
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == AVCaptureDevicePosition.Front) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        if captureDevice != nil {
            beginSession()
        }
        
    }
    
    func beginSession() {
        configureDevice()
        
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            
            
            captureSession.startRunning()
            photoOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            
            
            
            photoPreviewWrap.layer.addSublayer(previewLayer)
            previewLayer?.frame = self.view.layer.frame
            captureSession.startRunning()
        } catch {
            print(error)
        }
    }
    
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                if device.isFocusModeSupported(.ContinuousAutoFocus) {
                    device.focusMode = .ContinuousAutoFocus
                }
                else {
                    print("ContinuousAutoFocus is not supported")
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
            
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

