
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
import AVFoundation

class ARScreenController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!

    fileprivate let locationManager = CLLocationManager()
    
    var sceneLocationView = SceneLocationView()
    
    var updateUserLocationTimer: Timer?
    
    var ceterMapOnUserLocation: Bool = true
    
    var adjustNorthByTappingSidesOfScreen = false

    var myCoordinate:CLLocationCoordinate2D!
    
    let imgCoord = CLLocationCoordinate2D(latitude: 40.729843846782558, longitude: -73.99686592901034)
    
    var memo: UITextField!
    var label: UILabel!
    
    var myLocation:CLLocation!
    
    var mainScene: SCNScene!
    let alt:CLLocationDistance = 50
    
    var player: AVAudioPlayer?
    
    var audioPlayer: AVAudioPlayer?
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var recordButton: UIButton!
    
    var recordBtnTwo: UIButton!
    var stopBtn: UIButton!
    var playBtn: UIButton!
    
    var compass: UIImageView!
    var cameraBtn: UIButton!
    var textBtn: UIButton!
    
    var cancelBtn: UIButton!
    var doneBtn: UIButton!
    
    var fadeBtn: UIButton!
    
    var modelsInScene = [SCNNode]()
    
    var soundBool = false
    var textBool = false
    
    var soundBtn: UIButton!
    var slider: UIButton!
    var pop: UIButton!
    let locationDelegate = LocationDelegate()
    var latestLocation: CLLocation? = nil
    var yourLocationBearing: CGFloat { return latestLocation?.bearingToLocationRadian(self.yourLocation) ?? 0}
    var yourLocation: CLLocation {
        get {return UserDefaults.standard.currentLocation}
        set {UserDefaults.standard.currentLocation = newValue}
    }
    
    private func orientationAdjustment() -> CGFloat {
        let isFaceDown: Bool = {
            switch UIDevice.current.orientation{
            case .faceDown: return true
            default: return false
            }
        }()
        
        let adjAngle: CGFloat = {
            switch UIApplication.shared.statusBarOrientation{
            case .landscapeLeft: return 90
            case .landscapeRight: return -90
            case .portrait, .unknown: return 0
            case .portraitUpsideDown: return isFaceDown ? 180 : -180
            }
        }()
        return adjAngle
    }
    
    
    var defaults: UserDefaults!
    var dirAng: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
//        audioRecorder.delegate = self
        
//        locationManager.delegate = self
        locationManager.delegate = locationDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        
        //
//        locationManager.delegate = locationDelegate
        locationDelegate.locationCallback = { location in
            self.latestLocation = location
            print("latest is \(location)")
            
            self.myCoordinate = location.coordinate
        }
        
        
        
        sceneLocationView.showAxesNode = false
        
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        // Set the view's delegate
        sceneLocationView.delegate = self
        sceneLocationView.showsStatistics = false
        
        textBtn = UIButton(frame: CGRect(x:self.view.frame.width / 2 - 157, y: 650, width: 75, height: 75))
        textBtn.setImage(UIImage(named: "memo"), for: UIControlState.normal)
        self.view.addSubview(textBtn)
        textBtn.addTarget(self, action: #selector(createText), for: .touchUpInside)
        
        soundBtn = UIButton(frame: CGRect(x:self.view.frame.width / 2 + 80, y: 650, width: 75, height: 75))
        soundBtn.setImage(UIImage(named: "mic"), for: UIControlState.normal)
        self.view.addSubview(soundBtn)
        soundBtn.addTarget(self, action: #selector(soundTap), for: .touchUpInside)
       
        cameraBtn = UIButton(frame: CGRect(x:self.view.frame.width / 2 - 37, y: 650, width: 75, height: 75))
        cameraBtn.setImage(UIImage(named: "camera"), for: UIControlState.normal)
        self.view.addSubview(cameraBtn)
        cameraBtn.addTarget(self, action: #selector(touchLocation), for: .touchUpInside)
        
        
        cancelBtn = UIButton(frame: CGRect(x: 0, y:40, width: 90, height: 90))
        cancelBtn.setImage(UIImage(named: "cancel"), for: UIControlState.normal)
        self.view.addSubview(cancelBtn)
        cancelBtn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelBtn.isHidden = true
        
        doneBtn = UIButton(frame: CGRect(x: self.view.frame.width - 145 , y:40, width: 139, height: 90))
        doneBtn.setImage(UIImage(named: "done"), for: UIControlState.normal)
        self.view.addSubview(doneBtn)
        doneBtn.addTarget(self, action: #selector(showSlider), for: .touchUpInside)
        doneBtn.isHidden = true
        
        recordBtnTwo = UIButton(frame: CGRect(x: self.view.frame.width / 2 - 146, y: 650, width: 64, height: 64))
        recordBtnTwo.setTitle("recordBtnTwo", for: .normal)
        recordBtnTwo.setImage(UIImage(named: "record"), for: UIControlState.normal)
        self.view.addSubview(recordBtnTwo)
        recordBtnTwo.addTarget(self, action: #selector(recordAudio), for: .touchUpInside)
        recordBtnTwo.isHidden = true
        
        stopBtn = UIButton(frame: CGRect(x: self.view.frame.width / 2 - 32, y:650, width: 64, height: 64))
        stopBtn.setTitle("stop", for: .normal)
        stopBtn.setImage(UIImage(named: "stop"), for: UIControlState.normal)
        self.view.addSubview(stopBtn)
        stopBtn.addTarget(self, action: #selector(stopAudio), for: .touchUpInside)
        stopBtn.isHidden = true
        
        playBtn = UIButton(frame: CGRect(x: self.view.frame.width / 2 + 82, y: 650 , width: 64, height: 64))
        playBtn.setTitle("play", for: .normal)
        playBtn.setImage(UIImage(named: "play"), for: UIControlState.normal)
        stopBtn.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        self.view.addSubview(playBtn)
        playBtn.isHidden = true

        
//        let compassImage = UIImage(named: "compass")
//        compass = UIImageView(image: compassImage!)
//
//        compass.frame = CGRect(x: self.view.frame.width / 2 - 58 , y: 530, width: 116, height: 116)
//        view.addSubview(compass)
//
//        locationDelegate.headingCallback = { newHeading in
//            func computeNewAngle(with newAngle: CGFloat) -> CGFloat {
//                let heading: CGFloat = {
//                    let originalHeading = self.yourLocationBearing - newAngle.degreesToRadians
//                    switch UIDevice.current.orientation {
//                    case .faceDown: return -originalHeading
//                    default: return originalHeading
//                    }
//                }()
//                return CGFloat(self.orientationAdjustment().degreesToRadians + heading)
//            }
//
//            UIView.animate(withDuration: 0.5){
//                let angle = computeNewAngle(with: CGFloat(newHeading))
//                self.dirAng = abs(Int(angle))
//                print("angle is \(String(describing: self.dirAng))")
//                self.compass.transform = CGAffineTransform(rotationAngle: angle)
//            }
//        }
        
//       ********* AR NOTES START HERE
        //library
        /*let fourthCoordinate = CLLocationCoordinate2D(latitude: 40.729650, longitude: -73.997370)
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
        */
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneLocationView.addGestureRecognizer(tapGesture)
        
        let fileMgr = FileManager.default
        
        let dirPaths = fileMgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        
        let soundFileURL = dirPaths[0].appendingPathComponent("sound.caf")
        
        let recordSettings =
            [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
             AVEncoderBitRateKey: 16,
             AVNumberOfChannelsKey: 2,
             AVSampleRateKey: 44100.0] as [String : Any]
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(
                AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        do {
            try audioRecorder = AVAudioRecorder(url: soundFileURL,
                                                settings: recordSettings as [String : AnyObject])
            audioRecorder?.prepareToRecord()
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
       /* recordBtnTwo = UIButton(frame: CGRect(x:240, y:200, width: 98, height: 64))
        recordBtnTwo.setTitle("recordBtnTwo", for: .normal)
        self.view.addSubview(recordBtnTwo)
        recordBtnTwo.addTarget(self, action: #selector(recordAudio), for: .touchUpInside)
        
        stopBtn = UIButton(frame: CGRect(x:140, y:200, width: 98, height: 64))
        stopBtn.setTitle("stop", for: .normal)
        self.view.addSubview(stopBtn)
        stopBtn.addTarget(self, action: #selector(stopAudio), for: .touchUpInside)
        
        playBtn = UIButton(frame: CGRect(x:40, y:200, width: 98, height: 64))
        playBtn.setTitle("play", for: .normal)
        self.view.addSubview(playBtn)
        playBtn.addTarget(self, action: #selector(playAudio), for: .touchUpInside) */
    }
    
    @objc
    func soundTap (){
        
        soundBool = true
        cameraBtn.isHidden = true
        textBtn.isHidden = true
        soundBtn.isHidden = true
        
        recordBtnTwo.isHidden = false
        stopBtn.isHidden = true
        playBtn.isHidden = true
        
        
//        cancelBtn = UIButton(frame: CGRect(x: 0, y:40, width: 90, height: 90))
//        cancelBtn.setImage(UIImage(named: "cancel"), for: UIControlState.normal)
//        self.view.addSubview(cancelBtn)
//        cancelBtn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelBtn.isHidden = false
        
    }
    
    
    @objc
    func recordAudio(_ sender: AnyObject) {
        if audioRecorder?.isRecording == false {
//            stopBtn.isEnabled = true
            audioRecorder?.record()
            print("record start")
            
            stopBtn.isHidden = false
            recordBtnTwo.isEnabled = false

        }
        soundBool = true
    }
    
    @objc
    func stopAudio(_ sender: AnyObject) {
        
//        playBtn.isEnabled = true
//        recordBtnTwo.isEnabled = true
        
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
        } else {
            audioPlayer?.stop()
        }
        print("record stop")
        
        playBtn.isHidden = false
        playBtn.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        stopBtn.isEnabled = false
        recordBtnTwo.isEnabled = true
        
        doneBtn = UIButton(frame: CGRect(x: self.view.frame.width - 145 , y:40, width: 139, height: 90))
        doneBtn.setImage(UIImage(named: "done"), for: UIControlState.normal)
        self.view.addSubview(doneBtn)
        doneBtn.addTarget(self, action: #selector(showSlider), for: .touchUpInside)
        
    }
    
    @objc
    func showSlider(){
        
        if textBool {
            memo.isHidden = true
            textBool = false
        }
        
        if soundBool {
            stopBtn.isHidden = true
            playBtn.isHidden = true
            recordBtnTwo.isHidden = true
            soundBool = false
        }
        slider = UIButton(frame: CGRect(x: self.view.frame.width/2 - 171 , y: 640, width: 343, height: 56))
        slider.setImage(UIImage(named: "sliderWdays"), for: UIControlState.normal)
        self.view.addSubview(slider)
        slider.addTarget(self, action: #selector(showPop), for: .touchUpInside)

        cameraBtn.isHidden = true
        textBtn.isHidden = true
        soundBtn.isHidden = true

        cancelBtn.isHidden = true
        doneBtn.isHidden = true
    }
    
    @objc
    func showPop(){
        pop = UIButton(frame: CGRect(x: self.view.frame.width/2 - 169 , y:240, width: 338, height: 220))
        pop.setImage(UIImage(named: "popUp"), for: UIControlState.normal)
        self.view.addSubview(pop)
        pop.addTarget(self, action: #selector(fadeOutCall), for: .touchUpInside)
    }
    
    @objc
    func fadeOutCall(){
        fadeOut()
        pop.isHidden = true
        slider.isHidden = true
        
    }
    
    @objc
    func playAudio(_ sender: AnyObject) {
        if audioRecorder?.isRecording == false {
            stopBtn.isEnabled = true
            recordBtnTwo.isEnabled = true
            print("play")
            do {
                try audioPlayer = AVAudioPlayer(contentsOf:
                    (audioRecorder?.url)!)
                audioPlayer!.delegate = self
                audioPlayer!.prepareToPlay()
                audioPlayer!.play()
                print("play\(String(describing: audioRecorder?.url))")

            } catch let error as NSError {
                print("audioPlayer error: \(error.localizedDescription)")
            }
        }
    }
    
    func playAudioo() {
        if audioRecorder?.isRecording == false {
            
            print("play")
            do {
                try audioPlayer = AVAudioPlayer(contentsOf:
                    (audioRecorder?.url)!)
                audioPlayer!.delegate = self
                audioPlayer!.prepareToPlay()
                audioPlayer!.play()
                print("play\(String(describing: audioRecorder?.url))")
                
            } catch let error as NSError {
                print("audioPlayer error: \(error.localizedDescription)")
            }
        }
        
        recordBtnTwo.isEnabled = true
        stopBtn.isEnabled = true
    }

    func createTextNode(_ text: String) {
        // Create text geometry
        let textGeometry = SCNText(string: text, extrusionDepth: 0.0)
        
        // 1 text unit is 1 scene unit, so scale text down later according to the size here
//        textGeometry.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.black)
        textGeometry.font = UIFont(name: "BodoniFLF-Bold", size: 10)
        
        textGeometry.flatness = 0.0

        // Double sided material
        textGeometry.firstMaterial?.isDoubleSided = true
        textGeometry.firstMaterial?.diffuse.contents = UIColor(hexColor: "cdcdff")
        // Get point of view
        guard let pov = sceneLocationView.pointOfView else {
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
        sceneLocationView.scene.rootNode.addChildNode(textNode)
        
        modelsInScene.append(textNode)
        
        cancelBtn = UIButton(frame: CGRect(x: 0, y:40, width: 90, height: 90))
        cancelBtn.setImage(UIImage(named: "cancel"), for: UIControlState.normal)
        self.view.addSubview(cancelBtn)
        cancelBtn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        
        doneBtn = UIButton(frame: CGRect(x: self.view.frame.width - 145 , y:40, width: 139, height: 90))
        doneBtn.setImage(UIImage(named: "done"), for: UIControlState.normal)
        self.view.addSubview(doneBtn)
        doneBtn.addTarget(self, action: #selector(showSlider), for: .touchUpInside)
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
            playAudioo()
            fadeOut()
            
        }

            let arHitTestResult = sceneLocationView.hitTest(location, types: .existingPlaneUsingExtent)
            if !arHitTestResult.isEmpty {
                let hit = arHitTestResult.first!

                print(hit)
            }
        
    }
    func playSound() {
        guard let url = Bundle.main.url(forResource: "testSnap", withExtension: "m4a") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    @objc
    func touchLocation(_ gestureRecognize: UIGestureRecognizer) {
        guard let currentFrame = sceneLocationView.session.currentFrame else {
            return
        }
        
//        compass.isHidden = true
//        textBtn.isHidden = true
//        cameraBtn.isHidden = true
//        soundBtn.isHidden = true
        
        guard let pov = sceneLocationView.pointOfView else {
            return
        }
        

        // Create image plane from sceneView snapshot and camera position.
        let imagePlane = SCNPlane(width: sceneLocationView.bounds.width / 6000,
                                  height: sceneLocationView.bounds.height / 6000)
        
        imagePlane.firstMaterial?.diffuse.contents = sceneLocationView.snapshot()
        imagePlane.firstMaterial?.lightingModel = .constant
        
//        let bgPlane = SCNPlane(width: sceneLocationView.bounds.width / 6000 + 10,height: sceneLocationView.bounds.height / 6000 + 10)
        
//        bgPlane.firstMaterial?.lightingModel = .constant
//        var BGtranslation = matrix_identity_float4x4
//        BGtranslation.columns.3.z = -0.2
//
//        let bgNode = SCNNode(geometry: bgPlane)
        
//        bgNode.simdTransform = matrix_multiply(currentFrame.camera.transform, BGtranslation)
//        var bgTranslation = matrix_identity_float4x4
//        bgTranslation.columns.3.z = -0.01
//        bgNode.simdTransform = matrix_multiply(currentFrame.camera.transform, bgTranslation)
        
        
        let planeNode = SCNNode(geometry: imagePlane)
//        planeNode.addChildNode(bgNode)

        planeNode.simdPosition = pov.simdPosition + pov.simdWorldFront * 0.1
        planeNode.simdRotation = pov.simdRotation
        
        sceneLocationView.scene.rootNode.addChildNode(planeNode);
        
        modelsInScene.append(planeNode)
        
        /*let snaplocation = CLLocation(coordinate: myCoordinate, altitude: alt)
        let object = LocationNode(location: snaplocation)
        
        object.addChildNode(planeNode)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: object)*/
        
//        var translation = matrix_identity_float4x4
//        translation.columns.3.z = -0.1
//        planeNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
        //help!!
//        planeNode.rotation = SCNVector4Make(1, 1, 0, Float(M_PI/2));
        
//        fadeBtn = UIButton(frame: CGRect(x: self.view.frame.width / 2 + 82, y: 570, width: 64, height: 64))
//        fadeBtn.setTitle("fade", for: .normal)
////        fadeBtn.setImage(UIImage(named: "record"), for: UIControlState.normal)
//        self.view.addSubview(fadeBtn)
//        fadeBtn.addTarget(self, action: #selector(fadeOut), for: .touchUpInside)
        
        
        print("touched! + \(myCoordinate)")
        
        let imglocation = CLLocation(coordinate: myCoordinate, altitude: alt)
        let image = UIImage(named: "memoryPin.png")! //change into 3d objects later
        let annotationNode = LocationAnnotationNode(location: imglocation, image: image)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        
        cancelBtn = UIButton(frame: CGRect(x: 0, y:40, width: 90, height: 90))
        cancelBtn.setImage(UIImage(named: "cancel"), for: UIControlState.normal)
        self.view.addSubview(cancelBtn)
        cancelBtn.addTarget(self, action: #selector(cancel), for: .touchUpInside)

        
        doneBtn = UIButton(frame: CGRect(x: self.view.frame.width - 145 , y:40, width: 139, height: 90))
        doneBtn.setImage(UIImage(named: "done"), for: UIControlState.normal)
        self.view.addSubview(doneBtn)
        doneBtn.addTarget(self, action: #selector(showSlider), for: .touchUpInside)
    }
    
    @objc
    func createText(){
        
        cancelBtn.isHidden = false
        
        if textBool {
            print("text bool is false")
        } else {
            memo = UITextField(frame: CGRect(x: 30, y: 250, width: 330, height: 40))
            memo.delegate = self
            memo.placeholder = "Enter text here"
            memo.font = UIFont(name: "BodoniFLF-Bold", size: 30)
        
        //        memo.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.black)
            memo.autocorrectionType = UITextAutocorrectionType.no
            memo.keyboardType = UIKeyboardType.default
            memo.returnKeyType = UIReturnKeyType.done
            memo.clearButtonMode = UITextFieldViewMode.whileEditing;
            self.view.addSubview(memo)
            textBool = true
        }
    }
    
    @objc
    func fadeOut() {
        
        for model in modelsInScene {
            let fadeOut = SCNAction.fadeOut(duration: 1)
            model.runAction(fadeOut)
        }
        
//        if let lastModel = modelsInScene.popLast() {
//            let fadeOut = SCNAction.fadeOut(duration: 1)
//            lastModel.runAction(fadeOut)
//            lastModel.removeFromParentNode()
//            print(modelsInScene[0])
//           modelsInScene[0].runAction(fadeOut)
//            modelsInScene[1].runAction(fadeOut)
        
        cameraBtn.isHidden = false
        soundBtn.isHidden = false
        textBtn.isHidden = false
    }

    
    @objc
    func ARTap(){
        print("ar camera")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let MapViewScreen = storyboard.instantiateViewController(withIdentifier: "MapView")
        self.present(MapViewScreen, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        DDLogDebug("run")
        sceneLocationView.run()
//        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
//
//        // Run the view's session
        sceneLocationView.session.run(configuration)
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
       
//        checking altitude
         let alttitude = location.altitude
            print("\(alttitude)")
//            checkIfthereisAnyMemoryNearBy()

        if locations.count > 0 {
            let location = locations.last!
//            print("Accuracy: \(location.horizontalAccuracy)")
        }
    }
    
    @objc func cancel(){
        
        recordBtnTwo.isHidden = true
        stopBtn.isHidden = true
        playBtn.isHidden = true
        
        if textBool {
            memo.isHidden = true
            textBool = false
        }
        
        for model in modelsInScene {
            model.removeFromParentNode()
        }
       
        cancelBtn.isHidden = true
        doneBtn.isHidden = true
        
        cameraBtn.isHidden = false
        soundBtn.isHidden = false
        textBtn.isHidden = false

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

extension UIColor {
    convenience init(hexColor: String) {
        let scannHex = Scanner(string: hexColor)
        var rgbValue: UInt64 = 0
        scannHex.scanLocation = 0
        scannHex.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}


//extension SCNAnimationPlayer {
//    class func loadAnimation(fromSceneNamed sceneName: String) -> SCNAnimationPlayer {
//        let scene = SCNScene( named: sceneName )!
//        // find top level animation
//        var animationPlayer: SCNAnimationPlayer! = nil
//        scene.rootNode.enumerateChildNodes { (child, stop) in
//            if !child.animationKeys.isEmpty {
//                animationPlayer = child.animationPlayer(forKey: child.animationKeys[0])
//                stop.pointee = true
//            }
//        }
//        return animationPlayer
//    }
//}

