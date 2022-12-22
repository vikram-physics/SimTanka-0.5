//
//  RainfallViewVC.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 22/11/22.
//
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html
// On first use: to save the location of the RWHS
// For downloading and displaying daily rainfall data
// for the location of the RWHS
// Rainfall data provided by Visual Corssing
//



import SwiftUI
import CoreLocation
import MapKit

struct RainfallViewVC: View {
    
    var myColor4 = Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
    var myColor5 = Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
    
    // for obtaining the location of the RWHS from GPS
    @StateObject var locationManager = LocationManager()
    
    // For storing the location of the RWHS
    @AppStorage("rwhsLat") private var rwhsLat = 0.0
    @AppStorage("rwhsLong") private var rwhsLong = 0.0
    @AppStorage("setLocation") private var setLocation = false
    
    // for location given by the user
    @State private var choosenLocation = Locations.CurrentLocation
    @State var latitudeStrg = String()
    @State var longitudeStrg = String()
    @State private var userGivenLatitude = 0.0
    @State private var userGivenLongitude = 0.0
    
    @State private var showSaveLocationButton = false
    @State private var alertSavingLocation = false
    @State private var alertNoInternet = false
    
    var body: some View {
        
        GeometryReader { geometry in
            
            List {
                // If location is not set then show obtain location view
                if !setLocation {
                    ObtainLocationView()
                } else {
                    // show on the map
                    SimTankaMapView(rwhsLatitude: userGivenLatitude, rwhsLongitude: userGivenLongitude).cornerRadius(1).frame(height: geometry.size.height * 0.3)
                    
                }
                if setLocation {
                    RainfallView().frame(height:geometry.size.height * 0.58)
                }
            }.frame( maxWidth: .infinity).listStyle(PlainListStyle())
                .navigationTitle(Text("Rainfall"))
        }
       
     /*   List {
            // If location is not set then show obtain location view
            if !setLocation {
                ObtainLocationView()
            } else {
                // show on the map
                SimTankaMapView(rwhsLatitude: userGivenLatitude, rwhsLongitude: userGivenLongitude).cornerRadius(1).frame(height:225)
                
            }
            if setLocation {
                RainfallView().frame(height:300)
            }
        }.frame( maxWidth: .infinity).listStyle(PlainListStyle())
            .navigationTitle(Text("Rainfall")) */
            
            
    }
}

extension RainfallViewVC {
    
}

struct RainfallViewVC_Previews: PreviewProvider {
    static var previews: some View {
        RainfallViewVC()
    }
}
