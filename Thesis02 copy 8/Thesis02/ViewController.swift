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

class ViewController: UIViewController, ARSCNViewDelegate, MGLMapViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "mapbox://styles/ssey10/cjfprngco4bj62sqc4l6q3wq7")
        let mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 40.746328, longitude:  -73.989550), zoomLevel: 11, animated: false)
        view.addSubview(mapView)
        mapView.delegate = self

        let information = [
            // ITP
            LocationData(
                coordinates: CLLocationCoordinate2D(latitude: 40.729419, longitude: -73.993746),
                titleName: "Tisch School of Arts",
                subTitleName: "Visit 4th Floor."),
            
            // bryant park
            LocationData(
                coordinates: CLLocationCoordinate2D(latitude: 40.753645, longitude: -73.983812),
                titleName: "Bryant Park",
                subTitleName: "I love their latte."),
            
            // home
            LocationData(
                coordinates: CLLocationCoordinate2D(latitude: 40.753033, longitude: -73.995717),
                titleName: "home",
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
        let pisa = MGLPointAnnotation()
        pisa.coordinate = CLLocationCoordinate2D(latitude: 40.7458514, longitude: -73.9817633)
        pisa.title = "Leaning Tower of Pisa"
        mapView.addAnnotation(pisa)
   
        
        mapView.showsUserLocation = true
        print("you're in \(String(describing: mapView.userLocation?.coordinate))")
        
        let ARCameraBtn = UIButton(frame: CGRect(x: self.view.frame.width/2 - 60 , y: 650, width: 120, height: 120))
        ARCameraBtn.setImage(UIImage(named: "ar"), for: UIControlState.normal)
        self.view.addSubview(ARCameraBtn)
        
        ARCameraBtn.addTarget(self, action: #selector(ARTap), for: .touchUpInside)
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        // Try to reuse the existing ‘pisa’ annotation image, if it exists.
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "pisa")
        
        if annotationImage == nil {
            print("image is nil")
            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project.
            var image = UIImage(named: "annotation_map")!
            
            image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
            
            // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "pisa")
        }
        
        return annotationImage
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    
    @objc
    func ARTap(){
        print("ar camera")
        let ARstoryboard = UIStoryboard(name: "Find with AR", bundle: nil)
        let ARViewScreen = ARstoryboard.instantiateViewController(withIdentifier: "mapController") as UIViewController
        present(ARViewScreen, animated: true, completion: nil)
    }
    
/*    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        let camera = MGLMapCamera(lookingAtCenter: annotation.coordinate, fromDistance: 4000, pitch: 0, heading: 0)
        mapView.setCamera(camera, animated: true)
    }*/
}
