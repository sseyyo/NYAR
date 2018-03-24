//
//  ARViewController.swift
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

class ARScreenController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!

    fileprivate let locationManager = CLLocationManager()
    fileprivate var places = [Place]()
    fileprivate var arViewController: ARViewController!
    
    var sceneLocationView = SceneLocationView()
    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?
    
    var updateUserLocationTimer: Timer?
    
    var ceterMapOnUserLocation: Bool = true
    
    var displayDebugging = false
    var adjustNorthByTappingSidesOfScreen = false
    var startedLoadingPOIs = false

    var myLocation:CLLocationCoordinate2D!
    
    let imgCoord = CLLocationCoordinate2D(latitude: 40.729843846782558, longitude: -73.99686592901034)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //basic configuration for location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        //
        
        sceneLocationView.showAxesNode = true
        
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        /*let scene = SCNScene(named: "art.scnassets/ARtestScene.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene */
        
        let mapBtn = UIButton(frame: CGRect(x:135, y:620, width: 100, height: 30))
        mapBtn.setTitle("map", for: .normal)
        mapBtn.setTitleColor(UIColor.black, for: .normal)
        mapBtn.backgroundColor = UIColor.cyan
        self.view.addSubview(mapBtn)
        mapBtn.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        
        let InventoryBtn = UIButton(frame: CGRect(x:135, y:580, width: 100, height: 30))
        InventoryBtn.setTitle("inventory", for: .normal)
        InventoryBtn.setTitleColor(UIColor.white, for: .normal)
        InventoryBtn.backgroundColor = UIColor.cyan
        self.view.addSubview(InventoryBtn)
        InventoryBtn.addTarget(self, action: #selector(inventoryTap), for: .touchUpInside)
       
       /* let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchLocation(_:)))
        sceneView.addGestureRecognizer(tapGesture) */
        
        let tapGestureBtn = UIButton(frame: CGRect(x:135, y:540, width: 100, height: 30))
        tapGestureBtn.setTitle("my location", for: .normal)
        tapGestureBtn.setTitleColor(UIColor.white, for: .normal)
        tapGestureBtn.backgroundColor = UIColor.cyan
        self.view.addSubview(tapGestureBtn)
        tapGestureBtn.addTarget(self, action: #selector(touchLocation), for: .touchUpInside)
        
        arViewController = ARViewController()
        arViewController.dataSource = self
        arViewController.maxDistance = 500
        arViewController.maxVisibleAnnotations = 30
        arViewController.maxVerticalLevel = 5
        arViewController.headingSmoothingFactor = 0.05
        
        //    arViewController.maxDistance = 100
        arViewController.trackingManager.userDistanceFilter = 25
        arViewController.trackingManager.reloadDistanceFilter = 75
        arViewController.setAnnotations(places)
        arViewController.uiOptions.debugEnabled = false
        arViewController.uiOptions.closeButtonEnabled = true
        
        self.present(arViewController, animated: true, completion: nil)
    
    }
    
    func showInfoView(forPlace place: Place) {
        let alert = UIAlertController(title: place.placeName , message: place.infoText, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        arViewController.present(alert, animated: true, completion: nil)
    }
    
    func checkIfthereisAnyMemoryNearBy(){
        let imgCoorLoc =  CLLocation(coordinate: imgCoord, altitude: 38)
        let myLoc =  CLLocation(coordinate: myLocation, altitude: 38)
        
        let distance : CLLocationDistance = imgCoorLoc.distance(from: myLoc)
        print("distance is \(distance)")
    }

    @objc
    func touchLocation(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        
        print("touched! + \(myLocation)")
        
        //library
        //let imgCoord = CLLocationCoordinate2D(latitude: 40.729843846782558, longitude: -73.99686592901034)
        let imglocation = CLLocation(coordinate: myLocation, altitude: 38)
        let image = UIImage(named: "memoryPin.png")! //change into 3d objects later
        let annotationNode = LocationAnnotationNode(location: imglocation, image: image)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        
        let memo =  UITextField(frame: CGRect(x: 20, y: 100, width: 300, height: 40))
        memo.placeholder = "Enter text here"
        memo.font = UIFont.systemFont(ofSize: 15)
        memo.borderStyle = UITextBorderStyle.roundedRect
        memo.autocorrectionType = UITextAutocorrectionType.no
        memo.keyboardType = UIKeyboardType.default
        memo.returnKeyType = UIReturnKeyType.done
        memo.clearButtonMode = UITextFieldViewMode.whileEditing;
        memo.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        self.view.addSubview(memo)
    }
    
    @objc
    func handleTap(){
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
}

extension ARScreenController: CLLocationManagerDelegate {
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        let span:MKCoordinateSpan = MKCoordinateSpanMake(location.coordinate.latitude, location.coordinate.longitude)
        
        var myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        //        var alt = location.altitude
        //        print("\(alt)")
//        checkIfthereisAnyMemoryNearBy()
        //1
        if locations.count > 0 {
            let location = locations.last!
            print("Accuracy: \(location.horizontalAccuracy)")
            
            //2
            if location.horizontalAccuracy < 100 {
                //3
                manager.stopUpdatingLocation()
                let span = MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                
                if !startedLoadingPOIs {
                    startedLoadingPOIs = true
                    //2
                    let loader = PlacesLoader()
                    loader.loadPOIS(location: location, radius: 1000) { placesDict, error in
                        //3
                        if let dict = placesDict {
                            print(dict)
                            guard let placesArray = dict.object(forKey: "results") as? [NSDictionary]  else { return }
                            //2
                            for placeDict in placesArray {
                                //3
                                let latitude = placeDict.value(forKeyPath: "geometry.location.lat") as! CLLocationDegrees
                                let longitude = placeDict.value(forKeyPath: "geometry.location.lng") as! CLLocationDegrees
                                let reference = placeDict.object(forKey: "reference") as! String
                                let name = placeDict.object(forKey: "name") as! String
                                let address = placeDict.object(forKey: "vicinity") as! String
                                
                                let location = CLLocation(latitude: latitude, longitude: longitude)
                                //4
                                let place = Place(location: location, reference: reference, name: name, address: address)
                                self.places.append(place)
                                //5
                                let annotation = PlaceAnnotation(location: place.location!.coordinate, title: place.placeName)
                                //6
                                
                            }
                        }
                    }
                }
            }
        }
    }
}

/*func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations[0]
    let span:MKCoordinateSpan = MKCoordinateSpanMake(location.coordinate.latitude, location.coordinate.longitude)
    
    myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
    let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
    //        var alt = location.altitude
    //        print("\(alt)")
    checkIfthereisAnyMemoryNearBy()
    /*let imglocation = CLLocation(coordinate: myLocation, altitude: 36)
     let image = UIImage(named: "memoryPin.png")! //change into 3d objects later
     let annotationNode = LocationAnnotationNode(location: imglocation, image: image)
     sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)*/
}*/

extension ARScreenController: ARDataSource {
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = AnnotationView()
        annotationView.annotation = viewForAnnotation
        annotationView.delegate = self
        annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        
        return annotationView
    }
}

extension ARScreenController: AnnotationViewDelegate {
    func didTouch(annotationView: AnnotationView) {
        if let annotation = annotationView.annotation as? Place {
            let placesLoader = PlacesLoader()
            placesLoader.loadDetailInformation(forPlace: annotation) { resultDict, error in
                
                if let infoDict = resultDict?.object(forKey: "result") as? NSDictionary {
                    annotation.phoneNumber = infoDict.object(forKey: "formatted_phone_number") as? String
                    annotation.website = infoDict.object(forKey: "website") as? String
                    
                    self.showInfoView(forPlace: annotation)
                }
            }
            
        }
    }
}
