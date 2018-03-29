//
//  PlaceAnnotation.swift
//  Thesis02
//
//  Created by KimSe young on 3/23/18.
//  Copyright © 2018 SeyoungKim. All rights reserved.
//

import Foundation
import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    
    init(location: CLLocationCoordinate2D, title: String) {
        self.coordinate = location
        self.title = title
        
        super.init()
    }
}

