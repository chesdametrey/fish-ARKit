//
//  FishViewController.swift
//  FishARKit
//
//  Created by CHESDA on 25/9/17.
//  Copyright © 2017 com.chesdametrey. All rights reserved.
//

import Foundation
import ARKit
import SceneKit
import UIKit
import CSV



class FishViewController: UIViewController, UIGestureRecognizerDelegate{
    
    // MARK: - average dept variable
    var averageZ = 0.0
    
    // MARK: - array to keey voting number
    var votes:[Double] = []
    
    // MARK: - Sliders properties
    var sliderOne: Float = 0.0
    var sliderTwo: Float = 0.0
    @IBOutlet weak var leftSlider: UIView!
    @IBOutlet weak var rightSlider: UIView!
    @IBOutlet weak var debugButton: UIButton!
    
    @IBOutlet weak var fishView: UIImageView!
    @IBOutlet weak var testLabel: UILabel!
    
    // MARK: - measurement properties
    @IBOutlet weak var distanceLabel1: UILabel!
    @IBOutlet weak var distanceLabel2: UILabel!
    
    // MARK: - array properties for fish vectors
    var fishNodeArray = [SCNVector3]()
    var fishNodeArrayT1 = [SCNVector3]()
    var mainFeaturepointList = [[Float]]()
    
    // MARK: - others
    var file = FileHandler.init()
    var capturedImage: UIImage!
    let imgName = FileHandler.init().getDocumentsDirectory().appendingPathComponent("testImg.jpg")
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize fishView
        fishView.image = capturedImage
        
        // set sliders to unser interacable
        leftSlider.isUserInteractionEnabled = true
        rightSlider.isUserInteractionEnabled = true
                
        // MARK: - initialise slider to guestures
        let pan = UIPanGestureRecognizer (target: self, action: #selector(handlePan))
        let pan2 = UIPanGestureRecognizer (target: self, action: #selector(handlePan2))
        
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        
        pan2.minimumNumberOfTouches = 1
        pan2.maximumNumberOfTouches = 1
        
        
        leftSlider.addGestureRecognizer(pan)
        rightSlider.addGestureRecognizer(pan2)
        
        
        // MARK: - read all the saved featurepoints from csv into array
        let filePath = getDocumentsDirectory().appendingPathComponent("test1.csv")
        if(FileManager.default.fileExists(atPath: filePath.path)){
            print("** Path Avialable **")
            mainFeaturepointList = file.readToSCNVector(url: filePath)
        }else{
            print("** Path Unavialable **")
        }
        
        // filter out edge and boundary set
        fliterXYCoordinate()
        
        // sorted array
        mainFeaturepointList = mainFeaturepointList.sorted{ ($0[0]) < ($1[0]) }
        
        // compute average depth z
        averageZ = average(nums: getDeptZ(test: mainFeaturepointList))
        print("Average Z: ",averageZ)
        
        // remove duplicated X
        removeDuplicate()
        removeDuplicate()

    }
    
    // MARK: - remove duplicate coordinate X
    func removeDuplicate(){
        
        for (inde,_) in mainFeaturepointList.enumerated().reversed(){
            
            if inde != 0 {
                if mainFeaturepointList[inde-1][0].isEqual(to: mainFeaturepointList[inde][0]){
                    print("duplicated**", mainFeaturepointList.count)
                    mainFeaturepointList.remove(at: inde-1)
                    print("duplicated** removed", mainFeaturepointList.count)
                    
                }
            }
            
        }
        
    }
    
    // MARK: - handle pan moving of slider 1
    @objc
    func handlePan (reconizer: UIPanGestureRecognizer){
        
        hapticFeedback()
        //X cooridinate at right edge in the slider view
        let edgeX = leftSlider.frame.maxX.rounded()
        
        let tran = reconizer.translation(in: self.view)
        if let myView = reconizer.view {
            myView.center = CGPoint (x: myView.center.x + tran.x, y: myView.center.y)
            
        }
        reconizer.setTranslation(CGPoint(x:0,y:0), in: self.view)

        sliderOne = Float (edgeX)
        distanceLabel1.text = String(describing: sliderOne)
        
        //matchCoordinate(firstX: Float(view1.frame.minX), secondX: sliderTwo)
        matchCoordinate(firstX: sliderOne, secondX: sliderTwo)
    }
    
    // MARK: - handle pan moving of slider 1
    @objc
    func handlePan2 (reconizer: UIPanGestureRecognizer){
        
        hapticFeedback()
        //X cooridinate at left edge in the slider view
        let edgeX = rightSlider.frame.minX.rounded()
        
        if (Float(edgeX) > sliderOne ){
            let tran = reconizer.translation(in: self.view)
            if let myView = reconizer.view {
                myView.center = CGPoint (x: myView.center.x + tran.x, y: myView.center.y)
                
            }
            
            reconizer.setTranslation(CGPoint(x:0,y:0), in: self.view)
            
            sliderTwo = Float(edgeX)
            distanceLabel2.text = String(describing: sliderTwo)
            
            matchCoordinate(firstX: sliderOne, secondX: sliderTwo)
            
        }
        if (Float(edgeX) <= sliderOne + 4){
            let tran = reconizer.translation(in: self.view)
            if let myView = reconizer.view {
                myView.center = CGPoint (x: myView.center.x+5 + tran.x, y: myView.center.y)
                
            }
        }
    }
    
    // Mark: - filter out x coordinates that are out of range
    func fliterXYCoordinate (){
        
        //let minX:Float = 90.0
        //let maxX:Float  = 660.0
        //let minY:Float  = 40.0
        //let maxY:Float  = 390.0
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        /*
         let minX = Float(screenWidth / 8)
         let maxX = Float(screenWidth / 1.12)
         
         let minY = Float(screenHeight / 10.35)
         let maxY = Float(screenHeight / 1.1)
         */
        
        let minX = Float(screenWidth / 8)
        let maxX = Float(screenWidth / 1.12)
        
        let minY = Float(screenHeight / 2.5)
        let maxY = Float(screenHeight / 1.6)
        
        
        addBoundaryLine(x: CGFloat(minX), y: screenHeight/2, flag: true)
        addBoundaryLine(x: CGFloat(maxX), y: screenHeight/2, flag: true)
        addBoundaryLine(x: screenWidth/2, y: CGFloat(minY), flag: false)
        addBoundaryLine(x: screenWidth/2, y: CGFloat(maxY), flag: false)
        
        
        // enumerated through the array to find the x coordinate
        // that is out of range and remove it
        for (i,coord) in mainFeaturepointList.enumerated().reversed(){
            
            if (coord[0] < minX || coord[0] > maxX || coord[1] < minY || coord[1] > maxY) {
                mainFeaturepointList.remove(at: i)
            }
            
            
            
        }
    }
    
    // MARK: - Finding the closest match -> we need to recondtruct coordinate if we cannot find the matching one
    var closestP1 :[Float] =  []
    var closestP2 :[Float] =  []
    func matchCoordinate (firstX:Float, secondX: Float){
        for i in mainFeaturepointList{
            // print("i:",i)
            
            if (i[0].isEqual(to: firstX)){
                closestP1.removeAll()
                closestP1 = i
            }
            
            if (i[0].isEqual(to: secondX)){
                closestP2.removeAll()
                closestP2 = i
            }
            
        }
        
        // need to  change this,  need to ...
        if (!closestP1.isEmpty && !closestP2.isEmpty){
            // let vector1 = SCNVector3Make(closestP1[2], closestP1[3], closestP1[4])
            //let vector2 = SCNVector3Make(closestP2[2], closestP2[3], closestP2[4])
            
            // reconstruct SCNVector3 with the average Z
            let vector1 = SCNVector3Make(closestP1[2], closestP1[3], Float(averageZ))
            let vector2 = SCNVector3Make(closestP2[2], closestP2[3], Float(averageZ))
            
            let distance = vector1.distance(from: vector2)
            
            //****just to debug the ...
            if showDebug {
                debugCoordinate(v1: closestP1[0], v2: closestP1[1], color: UIColor.red)
                debugCoordinate(v1: closestP2[0], v2: closestP2[1], color: UIColor.yellow)
            }
            testLabel.text = format(distance)
        }else{
            print("*Empty Coordinate :( *")
        }
        
    }
    
    var showDebug = false
    @IBAction func debugButtonAction(_ sender: Any) {
        if showDebug {
            hapticFeedbackHeavy()
            debugButton.backgroundColor = UIColor.lightGray
            showDebug = false
            
        }else{
            hapticFeedbackHeavy()
            debugButton.backgroundColor = UIColor.red
            showDebug = true
            
        }
    }
    

    // MARK: - string to float function
    func toFloat (string: String) -> Float{
        
        let myFloat = (string as NSString).floatValue
        return myFloat
        
    }
    
    // MARK: - return a list of all each feature point depth z
    func getDeptZ(test: [[Float]]) -> [Double]{
        
        var a:[Double] = []
        for i in test {
            let t = Double(i[4])
            a.append(t)
        }
        return a
    }
    
    // MARK: - return an average depth value of all feature points
    func average(nums: [Double]) -> Double {
        
        var total = 0.0
        //use the parameter-array instead of the global variable votes
        for vote in nums{
            total += Double(vote)
        }
        
        let votesTotal = Double(nums.count)
        let average = total/votesTotal
        return average
    }
    
    // function to return a document directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(paths.count)
        
        return paths[0]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // for debug perpurposes
        /*
        let position = touches.first?.location(in: self.fishView)
        print("x: ", Float((position?.x)!).rounded())
        print("y: ", Float((position?.y)!).rounded())
        print(" ")
        */
    }
    
     // function to convert any type to string
    func covert(_ value: Float) {
        let cm = value * 100.0
        let inch = cm*0.3937007874
        print (String(format: "%.2f cm | %.2f\"", cm, inch))
    }
    
    // function to fomat float to string
    func format(_ value: Float) -> String{
        let cm = value * 100.0
        let inch = cm*0.3937007874
        return  String(format: "%.2f cm | %.2f\"", cm, inch)
    }
    
    // function to visual feature point that match with the sliders
    func debugCoordinate (v1: Float, v2: Float, color:UIColor){
        /*
         let line = UIView(frame: CGRect(x: Int(v1), y: Int(v2), width: 2, height: 20))
         line.backgroundColor = UIColor.red
         self.view.addSubview(line)
         */
        
        let dotPath = UIBezierPath(ovalIn: CGRect(x:Int(v1), y:Int(v2), width:2, height:2))
        
        let layer = CAShapeLayer()
        layer.path = dotPath.cgPath
        layer.strokeColor = color.cgColor
        
        view.layer.addSublayer(layer)
        
    }
    
    // add boundary to visualise where the boundary has been set
    func addBoundaryLine(x:CGFloat, y:CGFloat, flag: Bool){
        
        // Add a green line with thickness 1, width 200 at location (50, 100)
        if (flag){
            let line = UIView(frame: CGRect(x: Int(x), y: Int(y), width: 2, height: 20))
            line.backgroundColor = UIColor.lightGray
            self.view.addSubview(line)
            
        }else{
            let line = UIView(frame: CGRect(x: Int(x), y: Int(y), width: 20, height: 2))
            line.backgroundColor = UIColor.lightGray
            self.view.addSubview(line)
        }
        
    }
    
    // function to add dots for debug purpose
    func addTestDot(){
        let dotPath = UIBezierPath(ovalIn: CGRect(x:90, y:360, width:8, height:8))
        
        let layer = CAShapeLayer()
        layer.path = dotPath.cgPath
        layer.strokeColor = UIColor.blue.cgColor
        
        view.layer.addSublayer(layer)
        
        
        let dotPath2 = UIBezierPath(ovalIn: CGRect(x:650, y:360, width:8, height:8))
        
        let layer2 = CAShapeLayer()
        layer2.path = dotPath2.cgPath
        layer2.strokeColor = UIColor.blue.cgColor
        
        view.layer.addSublayer(layer2)
    }
    
    // call to generate a short haptic feedback
    // MARK: - Haptic feedback
    let generator = UIImpactFeedbackGenerator(style: .light)
    let highGenerator = UIImpactFeedbackGenerator(style: .heavy)
    func hapticFeedback(){
        generator.impactOccurred()
    }
    func hapticFeedbackHeavy(){
        highGenerator.impactOccurred()
    }
    
}


