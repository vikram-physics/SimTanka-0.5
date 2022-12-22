//
//  ObtainLocationView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 22/11/22.
//
//
// View for obtaining location of the RWHS
//
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html

import SwiftUI
import CoreLocation
import CoreLocationUI
import Network

struct ObtainLocationView: View {
    
    var myColor4 = Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
    var myColor5 = Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
    
    // For storing the location of the RWHS
    @AppStorage("rwhsLat") private var rwhsLat = 0.0
    @AppStorage("rwhsLong") private var rwhsLong = 0.0
    @AppStorage("setLocation") private var setLocation = false
    @AppStorage("nameOfLocation") private var nameOfLocation = String()
    @AppStorage("cityOfRWHS") private var cityOfRWHS = String()
    
    // for obtaining the location from users location
    @StateObject var locationManager = LocationManager()
    
    @State private var choosenLocation = Locations.CurrentLocation
    @State var latitudeStrg = String()
    @State var longitudeStrg = String()
    @State private var userGivenLatitude = 0.0
    @State private var userGivenLongitude = 0.0
    
    @State private var showSaveLocationButton = false
    @State private var alertSavingLocation = false
    
    
    var body: some View {
        
        VStack{
            HStack {
                Text("Provide the location of your RWHS").font(.title3)
                Spacer()
            }.foregroundColor(.black)
           
            Picker("Location", selection: $choosenLocation) {
                
                ForEach(Locations.allCases, id:\.self) {
                    Text($0.text)
                }
            }.pickerStyle(SegmentedPickerStyle())
                .background(myColor5)
            
            if choosenLocation.rawValue == 0 {
                HStack {
                    
                    LocationButton (.currentLocation) {
                        locationManager.locationManager.startUpdatingLocation()
                    }.labelStyle(.titleAndIcon).font(.callout)
                        .cornerRadius(50).padding(1)
                        .foregroundColor(.white)
                        .symbolVariant(.fill)
                    .tint(.blue)
                    Spacer()
                    Button(action: {
                        showSaveLocationButton = true
                        saveCurrentLocation()}, label: {
                        Text("Show on the map")
                                .font(.callout)
                            .foregroundColor(.white)
                            .padding(5)
                            .background(myColor4)
                            .clipShape(RoundedRectangle(cornerRadius: 1))
                    })
                }
            }
            
            if choosenLocation.rawValue == 1 {
                VStack(alignment: .leading, spacing: 0){
                    Text("Enter the location of the RWHS").foregroundColor(.black)
                    HStack{
                        Text("Latitude:")
                        TextField("latitude", text: $latitudeStrg).keyboardType(.numbersAndPunctuation)
                           
                    }
                    HStack{
                        Text("Longitude:")
                        TextField("Longitude", text: $longitudeStrg).keyboardType(.numbersAndPunctuation)
                            
                    }
                    Spacer()
                    // validate and save location of the RWHS
                    if validUserGivenLocation(latString: latitudeStrg, longString: longitudeStrg) {
                        HStack(alignment:.center){
                            Spacer()
                            Button(action: {
                                showSaveLocationButton = true
                                saveUserGivenLocation()
                            }, label:{
                                Text("Show on the map")
                                    .font(.callout)
                                    .foregroundColor(.white)
                                    .padding(1)
                                    .background(myColor4)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } ).buttonStyle(BorderlessButtonStyle())
                            Spacer()
                        }
                        
                    }
                   
                }.padding().font(.callout).background(myColor5)
                    .cornerRadius(5)
                    .onTapGesture {
                        self.hideKeyboard()
                      }
            }
        }.padding().background(myColor5)
        
        SimTankaMapView(rwhsLatitude: userGivenLatitude, rwhsLongitude: userGivenLongitude).cornerRadius(1).frame(height:200)
        
        // Allow user to save the location
        HStack{
            if !setLocation && showSaveLocationButton {
                Button(action: {
                    
                    alertSavingLocation = true
                    
                   
                },
                label: {
                    Text("Save Location")
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(myColor4)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }).alert("SimTanka will use rainfall data for this location. You will not be able to change it later!", isPresented: $alertSavingLocation) {
                    Button("Save") { saveRWHSLocation()
                        Task {
                            await findNameOftheLocation()
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                   
                }
            }
           
        }
        
    }
}

extension ObtainLocationView {
    
    func saveCurrentLocation() {
        // reset the values
        rwhsLat = 0.0
        rwhsLong = 0.0
        
        if let location = locationManager.location {
            userGivenLatitude = location.latitude
            userGivenLongitude = location.longitude
        }
    }
    
    func validUserGivenLocation(latString: String, longString: String) -> Bool {
        
        
        if Double(latString) == nil {
            
            return false
        }
        
        if Double(longString) == nil {
            return false
        }
        
        return true
    }
    
    func saveUserGivenLocation() {
        // validated before using
        userGivenLatitude = Double(latitudeStrg)!
        userGivenLongitude = Double(longitudeStrg)!
        print(userGivenLatitude, userGivenLongitude)
    }
    
    func saveRWHSLocation() {
        rwhsLat = userGivenLatitude
        rwhsLong = userGivenLongitude
        setLocation = true
    }
    
    func findNameOftheLocation() async {
        
        let geocoder = CLGeocoder()
        var city = String()
        var name = String()
        
        let cllLocationOfRWHS = CLLocation(latitude: rwhsLat, longitude: rwhsLong)
        
        if let rwhsPlacemark = try? await geocoder.reverseGeocodeLocation(cllLocationOfRWHS) {
            // find city
            city = rwhsPlacemark.first?.locality ?? ""
            // find name
            name = rwhsPlacemark.first?.name ?? ""
        } else {
            
        }
        /*
        if let city = try? await geocoder.reverseGeocodeLocation(cllLocationOfRWHS)
                    .first
                    .flatMap({ placemark in
                        placemark.locality
                    })
                {
                    self.nameOfLocation = city
                    print(city)
                }
                else {
                    self.nameOfLocation = ""
                    print("no city")
                }
        */
        self.nameOfLocation = "\(name) \(city)"
        self.cityOfRWHS = city
    }
    
}

struct ObtainLocationView_Previews: PreviewProvider {
    static var previews: some View {
        ObtainLocationView()
    }
}
