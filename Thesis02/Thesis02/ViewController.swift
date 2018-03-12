//
//  ViewController.swift
//  Thesis02
//
//  Created by Kim Seyoung on 2/18/18.
//  Copyright © 2018 SeyoungKim. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Mapbox
import CoreLocation
import MapKit

struct LocationData {
    var coordinates: CLLocationCoordinate2D
    var titleName: String
    var subTitleName: String
}


class ViewController: UIViewController, ARSCNViewDelegate,MGLMapViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "mapbox://styles/ssey10/cjdt994j332si2spipxz5iv5f")
        let mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 40.746328, longitude:  -73.989550), zoomLevel: 11    , animated: false)
        view.addSubview(mapView)
        
        let information = [
            // ITP
            LocationData(
                coordinates: CLLocationCoordinate2D(latitude: 40.729419, longitude: -73.993746),
                titleName: "Tisch School of Arts",
                subTitleName: "Visit 4th Floor."),
            
            // Think 
            LocationData(
                coordinates: CLLocationCoordinate2D(latitude: 40.728327, longitude: -73.995205),
                titleName: "Think Coffee",
                subTitleName: "I love their latte."),
            
            // WSP
            LocationData(
                coordinates: CLLocationCoordinate2D(latitude: 40.731270, longitude: -73.996963),
                titleName: "Washington Square Park",
                subTitleName: "Just sit and watch people")
        ]
        
        for item in information {
            let annotation = MGLPointAnnotation()
//            print(item.titleName)
//            print(item.coordinates)
            annotation.coordinate = item.coordinates
            annotation.title = item.titleName
            annotation.subtitle = item.subTitleName
            mapView.addAnnotation(annotation)
        }
        
   
        mapView.delegate = self
        
        mapView.showsUserLocation = true
        
        let ARCameraBtn = UIButton(frame: CGRect(x:135, y:620, width: 100, height: 30))
        ARCameraBtn.setTitle("camera", for: .normal)
        ARCameraBtn.setTitleColor(UIColor.white, for: .normal)
        ARCameraBtn.backgroundColor = UIColor.purple
        self.view.addSubview(ARCameraBtn)
        
        ARCameraBtn.addTarget(self, action: #selector(ARTap), for: .touchUpInside)
        
        let InventoryBtn = UIButton(frame: CGRect(x:135, y:520, width: 100, height: 30))
        InventoryBtn.setTitle("inventory", for: .normal)
        InventoryBtn.setTitleColor(UIColor.white, for: .normal)
        InventoryBtn.backgroundColor = UIColor.cyan
        self.view.addSubview(InventoryBtn)
        
        InventoryBtn.addTarget(self, action: #selector(inventoryTap), for: .touchUpInside)
    }
    
    @objc
    func ARTap(){
        print("ar camera")
        let ARstoryboard = UIStoryboard(name: "Main", bundle: nil)
        let ARViewScreen = ARstoryboard.instantiateViewController(withIdentifier: "ARViewController")
        self.present(ARViewScreen, animated: true, completion: nil)
    }
    
    @objc func inventoryTap(){
        print("inventory")
        let IVstoryboard = UIStoryboard(name: "Main", bundle: nil)
        let IVViewScreen = IVstoryboard.instantiateViewController(withIdentifier: "InventoryController")
        self.present(IVViewScreen, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        let camera = MGLMapCamera(lookingAtCenter: annotation.coordinate, fromDistance: 4000, pitch: 0, heading: 0)
        mapView.setCamera(camera, animated: true)
    }
}
