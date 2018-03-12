//
//  InventoryController.swift
//  Thesis02
//
//  Created by KimSe young on 3/12/18.
//  Copyright © 2018 SeyoungKim. All rights reserved.
//

import Foundation
import Foundation
import UIKit
import SceneKit
import ARKit
import Mapbox
import CoreLocation
import MapKit
import ARCL


class InventoryController: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        let ARCameraBtn = UIButton(frame: CGRect(x:135, y:620, width: 100, height: 30))
        ARCameraBtn.setTitle("camera", for: .normal)
        ARCameraBtn.setTitleColor(UIColor.white, for: .normal)
        ARCameraBtn.backgroundColor = UIColor.purple
        self.view.addSubview(ARCameraBtn)
        
        ARCameraBtn.addTarget(self, action: #selector(ARTap), for: .touchUpInside)
        
        let MapBtn = UIButton(frame: CGRect(x:135, y:520, width: 100, height: 30))
        MapBtn.setTitle("map", for: .normal)
        MapBtn.setTitleColor(UIColor.white, for: .normal)
        MapBtn.backgroundColor = UIColor.cyan
        self.view.addSubview(MapBtn)
        
        MapBtn.addTarget(self, action: #selector(mapTap), for: .touchUpInside)
    }
    @objc func ARTap(){
        print("ar camera")
        let ARstoryboard = UIStoryboard(name: "Main", bundle: nil)
        let ARViewScreen = ARstoryboard.instantiateViewController(withIdentifier: "ARViewController")
        self.present(ARViewScreen, animated: true, completion: nil)
    }

    @objc func mapTap(){
        print("map")
        let Mapstoryboard = UIStoryboard(name: "Main", bundle: nil)
        let MapViewScreen = Mapstoryboard.instantiateViewController(withIdentifier: "MapView")
        self.present(MapViewScreen, animated: true, completion: nil)
    }
}
