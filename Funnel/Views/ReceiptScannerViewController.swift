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
    
    // Camera variables
    let stillImageOutput = AVCapturePhotoOutput()
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var flashOn = false
    
    // Volume variables
    var initialVolume: Float = 0.0
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cameraCover: UIView!
    
    // MARK: Camera setup
    //Toggle flash
    @IBAction func flash(_ sender: Any) {
        toggleTorch(on: !flashOn)
        flashOn = !flashOn
    }
    
    // Camera button click
    @IBAction func takePhoto(_ sender: Any) {
        // Check if photo in progress
        if !activityIndicator.isAnimating {
            
            // Blur camera and start activity indicator
            activityIndicator.startAnimating()
            
            //Create blur view and add to view
            if !UIAccessibility.isReduceTransparencyEnabled {
                activityIndicator.backgroundColor = .clear
                let blurEffect = UIBlurEffect(style: .dark)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                //always fill the view
                blurEffectView.frame = self.view.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                activityIndicator.addSubview(blurEffectView)
                
                let spinner = UIActivityIndicatorView(style: .whiteLarge)
                spinner.startAnimating()
                spinner.frame = self.previewView.bounds
                spinner.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                activityIndicator.addSubview(spinner)
                activityIndicator.bringSubviewToFront(spinner)
            }
            
            // Set capture settings
            let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            stillImageOutput.capturePhoto(with: settings, delegate: self)
        }
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide camera as it's loading
        self.view.bringSubviewToFront(cameraCover)
        cameraCover.isHidden = false
        
        AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
        do { try AVAudioSession.sharedInstance().setActive(true) }
        catch { debugPrint("\(error)") }
        
        // Hide volume
        let volumeView = MPVolumeView(frame: CGRect.zero)
        volumeView.frame.origin = CGPoint(x: previewView.frame.origin.x, y:previewView.frame.origin.y + previewView.frame.height / 2)
        self.view.addSubview(volumeView)
        self.view.sendSubviewToBack(volumeView)
        
        // Manipulate slider when it is near max to not be max
        let slider = (view.subviews.filter{$0 is MPVolumeView})[0].subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            if slider!.value == 1.00 {
                self.initialVolume = 0.98
                slider!.value = 0.98
            } else if slider!.value == 0.00 {
                self.initialVolume = 0.02
                slider!.value = 0.02
            } else {
                self.initialVolume = slider!.value
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraCover.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraCover.isHidden = false
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
        do { try AVAudioSession.sharedInstance().setActive(false) }
        catch { debugPrint("\(error)") }
        
        // Reset orientation
        AppUtility.lockOrientation(.all)
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
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                    self.cameraCover.isHidden = true
                }
            }
        }
    }
    
    // MARK: Capture image and process (Tesseract logic in Logic/OCR.swift, receipt parsing Logic/ReceiptParser.swift)
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let image = UIImage(data: imageData)
        
        // Fetch OCR
        let output = OCR().output(image: image!)
        
        // Parse Receipt, create instance of receiptParser
        let receiptParser = ReceiptParser()
        let result = receiptParser.parse(string: output)
        
        if receiptParser.isReceipt {
            // Stop the activity indicator because processing is done
            activityIndicator.stopAnimating()
            
            // Process output
        } else {
            // Not a receipt
            let alert = UIAlertController(title: "No receipt found", message: "Make sure to align the receipt properly with the camera.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {action in self.activityIndicator.stopAnimating()}))
            self.present(alert, animated: true)
        }
        
        
        
    }
    
    // MARK: Flash handler
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    // MARK: Volume button handlers
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let slider = (view.subviews.filter{$0 is MPVolumeView})[0].subviews.first(where: { $0 is UISlider }) as? UISlider
    
        // Take photo on volume change
        takePhoto("Volume Button" as Any)
        if initialVolume == 1.00 || slider?.value == 1.00 {
            slider?.value = 0.98
            initialVolume = 0.98
        } else if initialVolume == 0.00 || slider?.value == 0.00 {
            slider?.value = 0.02
            initialVolume = 0.02
        } else {
            slider?.value = initialVolume
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
