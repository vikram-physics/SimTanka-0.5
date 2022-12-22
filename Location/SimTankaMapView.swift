//
//  SimTankaMapView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 27/12/21.
//
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html

import SwiftUI
import MapKit

struct SimTankaMapView: UIViewRepresentable {
    
    @StateObject private var mapViewModel = MapViewModel()
    @AppStorage("setLocation") private var setLocation = false
    @AppStorage("setMetStation") private var setMetStation = false
    @AppStorage("nameOfLocation") private var nameOfLocation = String()
    var rwhsLatitude = Double()
    var rwhsLongitude = Double()
    
    func makeUIView(context: Context) -> MKMapView {
                MKMapView(frame: .zero)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.mapType = .satellite
        uiView.isZoomEnabled = false
        uiView.isScrollEnabled = false
    
        // show Tanka
        let annotation = MKPointAnnotation()
        if setLocation {
            annotation.coordinate = mapViewModel.rwhsLocation()
        } else {
            annotation.coordinate = CLLocationCoordinate2D(latitude: rwhsLatitude, longitude: rwhsLongitude)
        }
        
        annotation.title = "RHWS"
        annotation.subtitle = "\(nameOfLocation)"
        uiView.addAnnotation(annotation)
        
        // show met station if it exists
        if setMetStation {
            let annotationMet = MKPointAnnotation()
            annotationMet.coordinate = mapViewModel.metLocation()
            annotationMet.title = "Met. Station"
            uiView.addAnnotation(annotationMet)
            uiView.showAnnotations([annotation, annotationMet], animated: true)
        } else {
            uiView.showAnnotations([annotation], animated: true)
        }
                
    }
}

struct SimTankaMapView_Previews: PreviewProvider {
    static var previews: some View {
        SimTankaMapView()
    }
}
