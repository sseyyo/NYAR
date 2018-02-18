//
//  ViewController.swift
//  Thesis02
//
//  Created by KimSe young on 2/18/18.
//  Copyright © 2018 SeyoungKim. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Mapbox


class ViewController: UIViewController, ARSCNViewDelegate, MGLMapViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "mapbox://styles/ssey10/cjdt994j332si2spipxz5iv5f")
        let mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 40.746328, longitude:  -73.989550), zoomLevel: 11    , animated: false)
        view.addSubview(mapView)
        
        let annotation = MGLPointAnnotation()
        let annotation2 = MGLPointAnnotation()
        let annotation3 = MGLPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 40.729419, longitude: -73.993746)
        annotation2.coordinate = CLLocationCoordinate2D(latitude: 40.728327, longitude: -73.995205)
        annotation3.coordinate = CLLocationCoordinate2D(latitude: 40.731270, longitude: -73.996963)
        annotation.title = "Tisch School of Arts"
        annotation2.title = "Think Coffee"
        annotation3.title = "Washington Square Park"
        annotation.subtitle = "Visit 4th Floor."
        annotation2.subtitle = "I love their latte."
        annotation3.subtitle = "Just sit and watch people living their lives."
        mapView.addAnnotation(annotation)
        mapView.addAnnotation(annotation2)
        mapView.addAnnotation(annotation3)
        
        mapView.delegate = self
        
        mapView.showsUserLocation = true
        

        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        let camera = MGLMapCamera(lookingAtCenter: annotation.coordinate, fromDistance: 4000, pitch: 0, heading: 0)
        mapView.setCamera(camera, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
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
