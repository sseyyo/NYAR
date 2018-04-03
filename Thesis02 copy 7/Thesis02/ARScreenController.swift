//
//  ARScreenController.swift
//  Thesis02
//
//  Created by Seyoung Kim on 2/26/18.
//  Copyright © 2018 Seyoung Kim. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit
import Mapbox
import CoreLocation
import MapKit
import ARCL

struct ARNotesData {
    var coordinates: CLLocationCoordinate2D
    var location: CLLocation
    var image: UIImage
}

struct CycleArray<T> {
    private var array: [T]
    private var cycleIndex: Int
    
    var currentElement: T? {
        get { return array.count > 0 ? array[cycleIndex] : nil }
    }
    
    init(_ array: [T]) {
        self.array = array
        self.cycleIndex = 0
    }
    
    mutating func cycle() -> T?  {
        cycleIndex = cycleIndex + 1 == array.count ? 0 : cycleIndex + 1
        return currentElement
    }
}
class ARScreenController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!

    fileprivate let locationManager = CLLocationManager()
    
    var sceneLocationView = SceneLocationView()
    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?
    
    var updateUserLocationTimer: Timer?
    
    var ceterMapOnUserLocation: Bool = true
    
    var displayDebugging = false
    var adjustNorthByTappingSidesOfScreen = false

    var myCoordinate:CLLocationCoordinate2D!
    
    let imgCoord = CLLocationCoordinate2D(latitude: 40.729843846782558, longitude: -73.99686592901034)
    
    var memo: UITextField!
    var label: UILabel!
    
    var myLocation:CLLocation!
    
    var currentModelAsset: SCNNode!
//    var modelAssets = CycleArray(ModelAssets)
    var mainScene: SCNScene!
    let alt:CLLocationDistance = 50
    override func viewDidLoad() {
        super.viewDidLoad()
 
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        sceneLocationView.showAxesNode = false
        
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.showsStatistics = false
        
        // Create a new scene
        /*let scene = SCNScene(named: "art.scnassets/ARtestScene.scn")!
        
         // Set the scene to the view
         sceneView.scene = scene */
        
        let mapBtn = UIButton(frame: CGRect(x:240, y:580, width: 98, height: 64))
        mapBtn.setImage(UIImage(named: "mapBtn"), for: UIControlState.normal)
        self.view.addSubview(mapBtn)
        mapBtn.addTarget(self, action: #selector(ARTap), for: .touchUpInside)
       
        let hereBtn = UIButton(frame: CGRect(x:30, y:580, width: 98, height: 64))
        hereBtn.setImage(UIImage(named: "hereBtn"), for: UIControlState.normal)
        self.view.addSubview(hereBtn)
        hereBtn.addTarget(self, action: #selector(touchLocation), for: .touchUpInside)
        
//       ********* AR NOTES START HERE
        //library
        let fourthCoordinate = CLLocationCoordinate2D(latitude: 40.729650, longitude: -73.997370)
        let fourthLocation = CLLocation(coordinate: fourthCoordinate, altitude: alt)
        let fourthImage = UIImage(named: "door")!
        let fourthAnnotationNode = LocationAnnotationNode(location: fourthLocation, image: fourthImage)
        fourthAnnotationNode.scaleRelativeToDistance = true
        fourthAnnotationNode.annotationNode.name = "door"
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: fourthAnnotationNode)
        
        //wsp
        let firstCoordinate = CLLocationCoordinate2D(latitude: 40.729838, longitude: -73.996230)
        let firstLocation = CLLocation(coordinate: firstCoordinate, altitude: alt)
        let firstImage = UIImage(named: "WSP")!
        let firstAnnotationNode = LocationAnnotationNode(location: firstLocation, image: firstImage)
        firstAnnotationNode.scaleRelativeToDistance = true
        firstAnnotationNode.annotationNode.name = "wsp"
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: firstAnnotationNode)
        
        //itp
        let thirdCoordinate = CLLocationCoordinate2D(latitude: 40.729415, longitude: -73.993699)
        let thirdLocation = CLLocation(coordinate: thirdCoordinate, altitude: alt)
        let thirdImage = UIImage(named: "righthere")!
        let thirdAnnotationNode = LocationAnnotationNode(location: thirdLocation, image: thirdImage)
        thirdAnnotationNode.scaleRelativeToDistance = true
        thirdAnnotationNode.annotationNode.name = "righthere"
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: thirdAnnotationNode)
        
        let secondTextGeometry = SCNText(string: "I found this place on the way home from school It was really nice", extrusionDepth: 0.0)
       
        secondTextGeometry.font = UIFont(name: "Avenir-HeavyOblique", size: 15)
        secondTextGeometry.flatness = 0.0
        secondTextGeometry.firstMaterial?.isDoubleSided = true
        
        
        guard let pov = sceneView.pointOfView else {
            print("Unable to get pov")
            return
        }
        
        // Create node from geometry
        let secondTextNode = SCNNode(geometry: secondTextGeometry)
        secondTextNode.simdPosition = pov.simdPosition + pov.simdWorldFront * 0.5
        secondTextNode.simdRotation = pov.simdRotation
        
        // Scale down the text
        secondTextNode.scale = SCNVector3Make(0.5, 0.5, 0.5)
        
        let (minVec, maxVec) = secondTextNode.boundingBox
        secondTextNode.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2 + minVec.x, (maxVec.y - minVec.y) / 2 + minVec.y, 0)
        sceneView.scene.rootNode.addChildNode(secondTextNode)
        
        let secondCoordinate = CLLocationCoordinate2D(latitude: 40.746671, longitude: -73.992516)
        let secondLocation = CLLocation(coordinate: secondCoordinate, altitude: alt)
        let object = LocationNode(location: secondLocation)
        object.addChildNode(secondTextNode)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: object)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneLocationView.addGestureRecognizer(tapGesture)
        
    }
    
    func createTextNode(_ text: String) {
        // Create text geometry
        let textGeometry = SCNText(string: text, extrusionDepth: 0.0)
        
        // 1 text unit is 1 scene unit, so scale text down later according to the size here
//        textGeometry.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.black)
        textGeometry.font = UIFont(name: "Avenir-HeavyOblique", size: 10)
        
        textGeometry.flatness = 0.0

        // Double sided material
        textGeometry.firstMaterial?.isDoubleSided = true
        
        // Get point of view
        guard let pov = sceneView.pointOfView else {
            print("Unable to get pov")
            return
        }
        
        // Create node from geometry
        let textNode = SCNNode(geometry: textGeometry)
        
        //        imgNode.material("memoryPin")
        // Position the text just in front of the camera
        textNode.simdPosition = pov.simdPosition + pov.simdWorldFront * 0.5
        textNode.simdRotation = pov.simdRotation
        
        // Scale down the text
        textNode.scale = SCNVector3Make(0.01, 0.01, 0.01)
        
        // Change pivot point of text so that it is centered
        // See: https://stackoverflow.com/questions/45168896/scenekit-scntext-centering-incorrectly
        let (minVec, maxVec) = textNode.boundingBox
        textNode.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2 + minVec.x, (maxVec.y - minVec.y) / 2 + minVec.y, 0)
        sceneView.scene.rootNode.addChildNode(textNode)
        
        let textlocation = CLLocation(coordinate: myCoordinate, altitude: alt)
        let object = LocationNode(location: textlocation)
        
//        let bgGeometry = SCNPlane(width: textGeometry.containerFrame.width, height: textGeometry.containerFrame.height)
        
//        createBGtext()
        
//        print("text width is \(textGeometry.containerFrame.width)")
//        let bgGeometry = SCNPlane(width: 10, height: 20)
//
//        bgGeometry.firstMaterial?.diffuse.contents  = UIColor(red: 30, green: 150, blue: 30, alpha: 1)
//
//        let bgNode = SCNNode(geometry: bgGeometry)
//        textNode.addChildNode(bgNode)
        object.addChildNode(textNode)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: object)
        
        print(textGeometry.containerFrame.height)
    }
    

    
//    func checkIfthereisAnyMemoryNearBy(){
//        let imgCoorLoc =  CLLocation(coordinate: imgCoord, altitude: alt)
//        let myLoc =  CLLocation(coordinate: myCoordinate, altitude: alt)
//
//        let distance : CLLocationDistance = imgCoorLoc.distance(from: myLoc)
//        print("distance is \(distance)")
//    }
    
    @objc
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        // Get tapped location in scene.
        let location = recognizer.location(in: sceneLocationView)
        
        ///////////////////////////////////////////////////////////////////////
        // Handle object tap.
        let sceneHitTestResult = sceneLocationView.hitTest(location, options: nil)
//        print(sceneHitTestResult)
//        print(location)
        if !sceneHitTestResult.isEmpty {
            let hit = sceneHitTestResult.first
            
            print(">>>>> Tapping: \(String(describing: hit?.node.name))")
        }

        

            let arHitTestResult = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
            if !arHitTestResult.isEmpty {
                let hit = arHitTestResult.first!

                print("hit")
//                let modelAsset = currentModelAsset.clone() as SCNNode
//
//                modelAsset.position = SCNVector3Make(hit.worldTransform.columns.3.x,
//                                                     hit.worldTransform.columns.3.y,
//                                                     hit.worldTransform.columns.3.z)
//
//                modelAsset.name = modelAssets.currentElement!.name
//
//                sceneView.scene.rootNode.addChildNode(modelAsset)
//
//                modelsInScene.append(modelAsset)
            }
        
    }

    @objc
    func touchLocation(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        
        print("touched! + \(myCoordinate)")
        
        //library
        let imglocation = CLLocation(coordinate: myCoordinate, altitude: alt)
        let image = UIImage(named: "memoryPin.png")! //change into 3d objects later
        let annotationNode = LocationAnnotationNode(location: imglocation, image: image)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        
        memo = UITextField(frame: CGRect(x: 30, y: 100, width: 330, height: 40))
        memo.delegate = self
        memo.placeholder = "Enter text here"
        memo.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.black)
        memo.autocorrectionType = UITextAutocorrectionType.no
        memo.keyboardType = UIKeyboardType.default
        memo.returnKeyType = UIReturnKeyType.done
        memo.clearButtonMode = UITextFieldViewMode.whileEditing;
        self.view.addSubview(memo)
    }
    
    @objc
    func ARTap(){
        print("ar camera")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let MapViewScreen = storyboard.instantiateViewController(withIdentifier: "MapView")
        self.present(MapViewScreen, animated: true, completion: nil)
    }
    
    @objc func inventoryTap(){
        print("inventory")
        let IVstoryboard = UIStoryboard(name: "Main", bundle: nil)
        let IVViewScreen = IVstoryboard.instantiateViewController(withIdentifier: "InventoryController")
        self.present(IVViewScreen, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        DDLogDebug("run")
        sceneLocationView.run()
//        // Create a session configuration
//        let configuration = ARWorldTrackingConfiguration()
//
//        // Run the view's session
//        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        DDLogDebug("pause")
        // Pause the view's session
        sceneLocationView.pause()
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = CGRect(x:0, y:0, width: self.view.frame.size.width, height: self.view.frame.size.height)
//        sceneLocationView.frame = view.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        // let span:MKCoordinateSpan = MKCoordinateSpanMake(location.coordinate.latitude, location.coordinate.longitude)
        
        myCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
//        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
       
//        checking altitude
//         let alttitude = location.altitude
//            print("\(alt)")
//            checkIfthereisAnyMemoryNearBy()

        if locations.count > 0 {
            let location = locations.last!
//            print("Accuracy: \(location.horizontalAccuracy)")
        }
    }
}

extension ARScreenController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // called when 'return' key pressed. return NO to ignore.
        print("TextField should return method called")
        memo.resignFirstResponder()
        
        view.endEditing(true)
        
        if let text = textField.text {
            createTextNode(text)
        }
        
        // Clear out the text
        textField.text = ""
        
        return false
    }
}

extension SCNAnimationPlayer {
    class func loadAnimation(fromSceneNamed sceneName: String) -> SCNAnimationPlayer {
        let scene = SCNScene( named: sceneName )!
        // find top level animation
        var animationPlayer: SCNAnimationPlayer! = nil
        scene.rootNode.enumerateChildNodes { (child, stop) in
            if !child.animationKeys.isEmpty {
                animationPlayer = child.animationPlayer(forKey: child.animationKeys[0])
                stop.pointee = true
            }
        }
        return animationPlayer
    }
}

