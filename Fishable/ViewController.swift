//
//  ViewController.swift
//  FishARKit
//
//  Main view controller for the capture feature points.
//
//  Created by CHESDA on 14/9/17.
//  Copyright © 2017 com.chesdametrey. All rights reserved.
//

import Foundation
import CSV
import ARKit
import SceneKit
import UIKit
import Vision

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate,UIPopoverPresentationControllerDelegate{
    
    
    // MARK: - ARKit Config Properties
    let session = ARSession()
    let standardConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        return configuration
    }()
    
    // MARK: - Other Properties
    
    var textManager: TextManager!
    var restartExperienceButtonIsEnabled = true
    var isNormalTrackingState = false
    
    // MARK: - UI Elements
    
    var spinner: UIActivityIndicatorView?
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var messagePanel: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var restartExperienceButton: UIButton!
    
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    // MARK: - Queues
    
    let serialQueue = DispatchQueue(label: "com.apple.arkitexample.serialSceneKitQueue")
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hapticFeedback()
        setupUIControls()
        setupScene()
        setupCamera()
        resetTracking()
        
        // initialise profess bar
        progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 5)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        tipsView.isHidden = true
    }
    
    func setupCamera(){
        
        guard let camera = sceneView.pointOfView?.camera else {
            fatalError("Expected a valid `pointOfView` from the scene.")
        }
        camera.wantsHDR = true
        camera.exposureOffset = -1
        camera.minimumExposure = -1
        camera.maximumExposure = 3
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
    }
    
    // MARK: - Setup
    
    func setupScene() {
        
        // set up scene view
        sceneView.setup()
        sceneView.delegate = self
        sceneView.session = session
        // sceneView.showsStatistics = true
        sceneView.session.delegate = self
        sceneView.scene.enableEnvironmentMapWithIntensity(25, queue: serialQueue)
    }
    
    
    var fishCaptured = UIImage()
    var pressCount = 0
    var numofPress = 7
    // Mark: - ARSession Delegate : processing every frames
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        // if captureButton presses = numofPress -> convert current frame to UIimage and transition
        // to fishViewController with the image
        if pressCount == numofPress {
            fishCaptured = pixelBufferToUIImage(frame.capturedImage)
            pressCount = 0
            
            let fvc = self.storyboard?.instantiateViewController(withIdentifier: "FishViewController") as! FishViewController
            fvc.modalTransitionStyle = .crossDissolve
            fvc.capturedImage = fishCaptured
            self.present(fvc, animated: true, completion: nil)
        }
    }
    
    // Mark: - pixelBuffer image convert to UIImage
    func pixelBufferToUIImage(_ buffer: CVPixelBuffer, options: [String: Any]? = nil) -> UIImage {
        let image = CIImage(cvPixelBuffer: buffer, options: options)
        return UIImage(ciImage: image)
    }
    
    // Properties and actions for showing tips view
    @IBOutlet weak var tipsView: UITextView!
    @IBAction func tipButton(_ sender: Any) {
        
        hapticFeedback()
        if tipsView.isHidden{
            tipsView.isHidden = false            
        }else{
            tipsView.isHidden = true
        }
    }
    
    // Mark: - setup message panel
    func setupUIControls() {
        textManager = TextManager(viewController: self)
        
        // Set appearance of message output panel
        messagePanel.layer.cornerRadius = 3.0
        messagePanel.clipsToBounds = true
        messagePanel.isHidden = true
        messageLabel.text = ""
    }
    
    // call to generate a short haptic feedback
    // MARK: - Haptic feedback
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    func hapticFeedback(){
        generator.impactOccurred()
    }
    
    // MARK: - Covert float to display format for distance metrix
    func convert(_ value: Float) -> String{
        let cm = value * 100.0
        
        let format = String(format: "%.2f cm", cm)
        return format
    }
    
    func resetTracking() {
        session.run(standardConfiguration, options: [.resetTracking, .removeExistingAnchors])
        
        textManager.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT",
                                    inSeconds: 7.5,
                                    messageType: .planeEstimation)
    }
    
    
    // MARK: - Error handling
    func displayErrorMessage(title: String, message: String, allowRestart: Bool = false) {
        // Blur the background.
        textManager.blurBackground()
        
        if allowRestart {
            // Present an alert informing about the error that has occurred.
            let restartAction = UIAlertAction(title: "Reset", style: .default) { _ in
                self.textManager.unblurBackground()
                self.restartExperience(self)
            }
            textManager.showAlert(title: title, message: message, actions: [restartAction])
        } else {
            textManager.showAlert(title: title, message: message, actions: [])
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
    // MARK: - Fishable
    var capFish = false
    var test = false
    
    @objc
    func handleFishPress (gestureReconizer: UILongPressGestureRecognizer){
        
        if (gestureReconizer.state == UIGestureRecognizerState.began){
            capFish = true
        }
        if (gestureReconizer.state == UIGestureRecognizerState.ended){
            
        }
    }
    
    let filename = FileHandler.init().getDocumentsDirectory().appendingPathComponent("test1.csv")
    
    var count = 0
    var numOfFeaturePoints = 350
    @IBOutlet weak var fishButton: UIButton!
    @IBAction func fishCapButton(_ sender: Any) {
        
        hapticFeedback()
        tipsView.isHidden = true
        
        capFish = true
        count += 1
        pressCount += 1
        
        // capture button press six times, notify user to align object in the view
        if (count == 6){
            infoLabel.text = "Align and center the object in the view"
            infoLabel.textColor = UIColor.red
            progressBar.progressTintColor = UIColor.red
        }
        
        // preapare all captured featurepoints to save and transition to fish view controller
        if (count == numofPress){
            
            capFish = true
            count = 0
            
            // array to store all the formated feature points
            var formatedFeaturepointsList = [[Float]]()
            // for every feature point in the array, we unproject SCNVector to the final camera frame to get 2D cooridinate
            // and save it with the SCNVector3 associate with it to CSV file
            for point in detectedFeaturePointsList{
                let makeV3 = SCNVector3Make(point[0], point[1], point[2])
                
                // unproject scnvector3 to CGpoint (2D)
                let TwoDPoint = sceneView.projectPoint(makeV3)
                
                // round up x and y of 2d coordinate
                let TwoDX = TwoDPoint.x.rounded()
                let TwoDY = TwoDPoint.y.rounded()
                
                // construct a list of float [2D x, 2D y, 3D x, 3D y, 3D z]
                let constructFloat = [TwoDX,TwoDY,point[3],point[4],point[5]]
                formatedFeaturepointsList.append(constructFloat)
            }
            
            FileHandler.init().writeNodeToCSV(fishArray: formatedFeaturepointsList,url: filename, append: false)
        }
        
        // computing and updating the progess bar
        if count <= numofPress {
            // compute ratio
            let ratio = Float(count) / Float(numofPress)
            // set progress            
            progressBar.setProgress(Float(ratio), animated: true)
            
        }
        
        // if after five presses there are still not enough feature points captured
        if count == 6{
            if  detectedFeaturePointsList.count < numOfFeaturePoints {
                // rewind back the progress
                count = 4
                pressCount = 4
                
                // show appropriate messge and update progress bar
                infoLabel.text = "Please try to capture more points"
                infoLabel.textColor = UIColor.orange
                progressBar.progressTintColor = UIColor.orange
                
                let ratio = Float(count) / Float(numofPress)
                // set progress
                progressBar.setProgress(Float(ratio), animated: true)
                
            }
        }
        
        //print("***Feature Point Count: ", detectedFeaturePointsList.count)
    }
    
    var detectedFeaturePointsList = [[Float]]()
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if (capFish){
            // getting raw feature points
            guard let features = self.session.currentFrame?.rawFeaturePoints else {return}
            //let points = features.__points
            
            //for every featurepoint detected at this time, project a 3D dot
            //and save those detected point in detectedFeaturePointsList
            for point in features.points {
                
                //if statement if we want to filter out the featurepoint that are too close.
                //Then we need to sepecify a general value of z which is complicate at this stage
                //if(e.z < -0.5 && e.z < 0.1){
                
                // just try to place sphere to every feature point detected
                let position = SCNVector3Make(point.x, point.y, point.z)
                
                //store each feature point in array as CGPoint and SCNVector
                let TwoDPoint = position
                
                //i rouded the 2s x and y
                let x = Float(point.x)
                let y = Float(point.y)
                let z = Float(point.z)
                
                let constructFloat = [TwoDPoint.x,TwoDPoint.y,TwoDPoint.z,x,y,z]
                
                // add contructFloat of featurepoints to an array
                detectedFeaturePointsList.append(constructFloat)
                
                // project 3d dot on to every feature points detected when the user press captureFish Button
                let firstSphere = SphereNode(position: position, color: UIColor.cyan)
                sceneView.scene.rootNode.addChildNode(firstSphere)
                //}
            }
            print("**LAST***",features.points.last!)
            print("**count***",features.points.count)
            print("***Feature Point Count: ", detectedFeaturePointsList.count)
            capFish = false
        }
        
        //******if fishable is ON, disable all features******
        
        
        // If light estimation is enabled, update the intensity of the model's lights and the environment map
        if let lightEstimate = session.currentFrame?.lightEstimate {
            sceneView.scene.enableEnvironmentMapWithIntensity(lightEstimate.ambientIntensity / 40, queue: serialQueue)
        } else {
            sceneView.scene.enableEnvironmentMapWithIntensity(40, queue: serialQueue)
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        textManager.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
        
        switch camera.trackingState {
        case .notAvailable:
            isNormalTrackingState = false
            fishButton.isEnabled = false
            fallthrough
        case .limited:
            textManager.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
            isNormalTrackingState = false
            fishButton.isEnabled = false
        //self.present(AlertView().showAlertView(title:"Limited",message: "Move the camera around"), animated: true, completion: nil)
        case .normal:
            hapticFeedback()
            isNormalTrackingState = true
            fishButton.isEnabled = true
            textManager.cancelScheduledMessage(forType: .trackingStateEscalation)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard let arError = error as? ARError else { return }
        
        let nsError = error as NSError
        var sessionErrorMsg = "\(nsError.localizedDescription) \(nsError.localizedFailureReason ?? "")"
        if let recoveryOptions = nsError.localizedRecoveryOptions {
            for option in recoveryOptions {
                sessionErrorMsg.append("\(option).")
            }
        }
        
        let isRecoverable = (arError.code == .worldTrackingFailed)
        if isRecoverable {
            sessionErrorMsg += "\nYou can try resetting the session or quit the application."
        } else {
            sessionErrorMsg += "\nThis is an unrecoverable error that requires to quit the application."
        }
        
        displayErrorMessage(title: "We're sorry!", message: sessionErrorMsg, allowRestart: isRecoverable)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        //textManager.blurBackground()
        //textManager.showAlert(title: "Session Interrupted", message: "The session will be reset after the interruption has ended.")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        textManager.unblurBackground()
        session.run(standardConfiguration, options: [.resetTracking, .removeExistingAnchors])
        restartExperience(self)
        textManager.showMessage("RESETTING SESSION")
    }
    
    
    
    // MARK: - ACTION
    enum SegueIdentifier: String {
        case showFish
    }
    
    
    // MARK:- Tag: restartExperience
    @IBAction func restartCapturing(_ sender: Any) {
        
        hapticFeedback()
        detectedFeaturePointsList.removeAll()
        progressBar.setProgress(0.0, animated: true)
        count = 0
        pressCount = 0
        
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        infoLabel.text = "Move and capture target object feature points"
        infoLabel.textColor = UIColor.white
        progressBar.progressTintColor = UIColor.cyan
        self.textManager.showMessage("Restarting")
    }
    
    @IBAction func restartExperience(_ sender: Any) {
        
        // guard restartExperienceButtonIsEnabled, else { return }
        
        DispatchQueue.main.async {
            self.restartExperienceButtonIsEnabled = false
            
            self.textManager.cancelAllScheduledMessages()
            self.textManager.dismissPresentedAlert()
            self.textManager.showMessage("STARTING A NEW SESSION")
            
            self.resetTracking()
            
            self.restartExperienceButton.setImage(#imageLiteral(resourceName: "restart"), for: [])
            
            
            // Disable Restart button for a while in order to give the session enough time to restart.
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                self.restartExperienceButtonIsEnabled = true
            })
        }
        
        
    }
    
    
    // MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // All popover segues should be popovers even on iPhone.
        if let popoverController = segue.destination.popoverPresentationController, let button = sender as? UIButton {
            popoverController.delegate = self
            popoverController.sourceRect = button.bounds
        }
        // setting segue identifier
        guard let identifier = segue.identifier, let segueIdentifer = SegueIdentifier(rawValue: identifier) else { return }
        
        // if fish segue
        if segueIdentifer == .showFish {
            let fishViewController = segue.destination as! FishViewController
            hapticFeedback()
            fishViewController.capturedImage = #imageLiteral(resourceName: "fishImg-1")
        }
        
    }
    
    // MARK: - ACTION
    
    // MARK: - Gesture Recognizers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // use to debug coordiniate
        /*
         let postion = sceneView.realWorldVector(screenPos: (touches.first?.location(in: sceneView))!)
         
         let tp = touches.first
         let position = tp?.location(in: sceneView)
         
         var rect = CGRect()
         rect.origin.x = (position?.x)!
         rect.origin.y = (position?.y)!
         rect.size.width = 100
         rect.size.height = 100
         print((position?.x)!)
         
         self.sceneView.layer.addSublayer(
         BoundingBox().show(frame: rect, label: "777", color: UIColor.red))
         
         let ix = postion?.x
         var minX = vector_float3()
         for i in fishNodeArray{
         
         if(i.x < ix!){
         minX = i
         print ("Enter***")
         }else{
         minX = vector_float3((postion?.x)!,(postion?.y)!,(postion?.z)!)
         }
         
         }
         print ("Min***",minX)
         
         */
        
        
    }
}

