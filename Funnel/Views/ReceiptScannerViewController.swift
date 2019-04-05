//
//  ReceiptScannerViewController.swift
//  Funnel
//
//  Created by Shao-Qian Mah on 4/4/19.
//  Copyright © 2019 Funnel. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ReceiptScannerViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    let stillImageOutput = AVCapturePhotoOutput()
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Camera setup
    // Camera button click
    
    @IBAction func takePhoto(_ sender: Any) {
        // Blur camera and start activity indicator
        activityIndicator.startAnimating()
        if !UIAccessibility.isReduceTransparencyEnabled {
            activityIndicator.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.previewView.frame
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            activityIndicator.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        }
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // Setup camera

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Rotate and lock
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        
        // Setup volume buttons
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // This is to make it so that the camera view doesn't have the animation
        previewView.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Stop camera from running
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
        
        // Reset orientation
        AppUtility.lockOrientation(.all)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
                self.view.bringSubviewToFront(self.activityIndicator)
            }
        }
    }
    
    // MARK: Tesseract OCR
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let image = UIImage(data: imageData)
        
        // Tesseract setup and OCR
        OCR().output(image: UIImage(imageLiteralResourceName: "test_receipt"))
        
        // Start running the capture session again
        activityIndicator.stopAnimating()
        self.captureSession.startRunning()
    }
    
    // MARK: Volume button handlers
    func listenVolumeButton() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch {
            print("some error")
        }
        audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
            print("got in here")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
