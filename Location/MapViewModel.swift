//
//  MapViewModel.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 27/12/21.
//
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html

import Foundation
import SwiftUI
import MapKit

class MapViewModel: ObservableObject {
    
    // For the location of the RWHS
    @AppStorage("rwhsLat") private var rwhsLat = 0.0
    @AppStorage("rwhsLong") private var rwhsLong = 0.0
    
    // For the location of the met. station
    @AppStorage("metLat") private var metLat = 0.0
    @AppStorage("metLong") private var metLong = 0.0
    
    // setMetStation is true when a met station is found
    @AppStorage("setMetStation") private var setMetStation = false
    
    func rwhsLocation() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.rwhsLat, longitude: self.rwhsLong)
    }
    
    func metLocation() -> CLLocationCoordinate2D {
        
        return CLLocationCoordinate2D(latitude: self.metLat, longitude: self.metLong)
        
    }
    
}
