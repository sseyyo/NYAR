//
//  mapController.swift
//  Thesis02
//
//  Created by Kim Seyoung on 4/24/18.
//  Copyright © 2018 SeyoungKim. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit
import Mapbox
import CoreLocation
import MapKit
import ARCL

class mapController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    fileprivate let locationManager = CLLocationManager()
    
    var sceneLocationView = SceneLocationView()
    
    var updateUserLocationTimer: Timer?
    
    var ceterMapOnUserLocation: Bool = true
    
    var adjustNorthByTappingSidesOfScreen = false
    
    var myCoordinate:CLLocationCoordinate2D!
    
    var memo: UITextField!
    var label: UILabel!
    
    var compass: UIImageView!
    
    var myLocation:CLLocation!

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
        /*
        locationManager.delegate = locationDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        locationDelegate.locationCallback = { location in
            self.latestLocation = location
            print("latest is \(location)")
            let altitude = location.altitude
            print("alt is \(altitude)")
            self.myCoordinate = location.coordinate
        }
        */
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
//        sceneLocationView.delegate = self
        sceneLocationView.showsStatistics = false
        /*
        let compassImage = UIImage(named: "compass")
        compass = UIImageView(image: compassImage!)
        
        compass.frame = CGRect(x: self.view.frame.width / 2 - 58 , y: 530, width: 116, height: 116)
        view.addSubview(compass)
        
        locationDelegate.headingCallback = { newHeading in
            func computeNewAngle(with newAngle: CGFloat) -> CGFloat {
                let heading: CGFloat = {
                    let originalHeading = self.yourLocationBearing - newAngle.degreesToRadians
                    switch UIDevice.current.orientation {
                       case .faceDown: return -originalHeading
                       default: return originalHeading
                    }
                }()
                return CGFloat(self.orientationAdjustment().degreesToRadians + heading)
             }
        
             UIView.animate(withDuration: 0.5){
                  let angle = computeNewAngle(with: CGFloat(newHeading))
                  self.dirAng = abs(Int(angle))
                  print("angle is \(String(describing: self.dirAng))")
                  self.compass.transform = CGAffineTransform(rotationAngle: angle)
             }
        }*/
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneLocationView.addGestureRecognizer(tapGesture)
        
        let PaperCoordinate = CLLocationCoordinate2D(latitude: 40.7461795, longitude: -73.9893251)
        let PaperLocation = CLLocation(coordinate: PaperCoordinate, altitude: 40)
        let PaperImage = UIImage(named: "annotation_sm")!
        let PaperNode = LocationAnnotationNode(location: PaperLocation, image: PaperImage)
        PaperNode.scaleRelativeToDistance = true
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: PaperNode)
        
        let BryantCoordinate = CLLocationCoordinate2D(latitude: 40.7543011, longitude: -73.9838034)
        let BryantLocation = CLLocation(coordinate: BryantCoordinate, altitude: 40)
        let BryantNode = LocationAnnotationNode(location: BryantLocation, image: PaperImage)
        BryantNode.scaleRelativeToDistance = false
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: BryantNode)
    }
    
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
        
        let arHitTestResult = sceneLocationView.hitTest(location, types: .existingPlaneUsingExtent)
        if !arHitTestResult.isEmpty {
            let hit = arHitTestResult.first!
            print(hit)
        }
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        //        DDLogDebug("run")
//        sceneLocationView.run()
////        let configuration = ARWorldTrackingConfiguration()
////        sceneLocationView.session.run(configuration)
//    }
//
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        DDLogDebug("pause")
        // Pause the view's session
        sceneLocationView.pause()
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
//        sceneLocationView.frame = CGRect(x:0, y:0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        sceneLocationView.frame = view.bounds
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
    /*
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location manager")
        let location = locations[0]
        // let span:MKCoordinateSpan = MKCoordinateSpanMake(location.coordinate.latitude, location.coordinate.longitude)
        
        myCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        //        checking altitude
        let alttitude = location.altitude
        print("\(alttitude)")
        //            checkIfthereisAnyMemoryNearBy()
        
        if locations.count > 0 {
            let location = locations.last!
            let alttitude = location.altitude
            print("\(alttitude)")
            //            print("Accuracy: \(location.horizontalAccuracy)")
        }
    }
 */

}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
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
