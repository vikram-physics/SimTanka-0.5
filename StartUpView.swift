//
//  StartUpView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 28/06/22.
//
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html

import SwiftUI

struct StartUpView: View {
    
    var myColor4 = Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
    var myColor5 = Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
    
    // setlocation is true when the location is found
    @AppStorage("setLocation") private var setLocation = false
    
    @AppStorage("rainRecordsAvailable") private var rainRecordsAvailable = false // is true if past five years rainfall records were downloaded
    
    // setMetStation is true when a met station is found
    @AppStorage("setMetStation") private var setMetStation = false
    
    // when rwhs is set, water budget is set and
    
    //msg
    @AppStorage("setUpRWHSMsg") private var setUpRWHSMsg = "Please set up your RWHS"
    @AppStorage("setUpBudgetMsg") private var setUpBudgetMsg =  "Please set up your water budget, this will allow SimTanka to predict future performances"
    @AppStorage("msgLocationMetStation") private var  msgLocationMetStation = "Please set your location to obrain daily rainfall records"
    
    var body: some View {
        NavigationView {
            
            List {
                Section(header: Text("Information").font(.title2), content: {
                    
                    NavigationLink(destination: RainfallViewVC(), label: { // tmp change from SetUpLocationView()
                       DashboardView(titleText: "Rainfall", msgText: msgLocationMetStation).id(UUID())
                        
                    }).listRowBackground(Color(#colorLiteral(red: 0.2, green: 0.7, blue: 0.8, alpha: 1)))
                   
                    if rainRecordsAvailable {
                        NavigationLink(destination: DailyBudgetView(), label: {
                            DashboardView(titleText: "Water Budget", msgText: setUpBudgetMsg)
                        })
                        .listRowBackground(Color(#colorLiteral(red: 0.5, green: 0.5, blue: 0.8, alpha: 1)))
                    }
                    
                    NavigationLink(destination: RWHSView(), label: {
                        DashboardView(titleText: "RWHS", msgText: setUpRWHSMsg)
                        
                    }).listRowBackground(Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)))
                
                })
               
                
                
                Section(header: Text("Tools").font(.title3), content: {
                    
                    NavigationLink(destination: WaterDiaryListView(), label: {
                        DashboardView(titleText: "Water Diary", msgText: "Keep records of water harvested, potability and maintainace activites")
                    }).listRowBackground(myColor4)
                    
                    if rainRecordsAvailable {
                        NavigationLink(destination: PerformanceView(), label: {
                            DashboardView(titleText: "Performance", msgText: "Estimate how well will your RWHS perform next month")
                        })
                        .listRowBackground(myColor5)
                    }
                   
                })
               
                
               
            }.navigationBarTitle(Text("SimTanka"))
            .toolbar {
                Button(action: {  }, label: {
                    NavigationLink(destination: PrefernceView(), label: {
                        Label("Settings", systemImage: "gearshape")})
                   
                })
                }
            
        }.navigationViewStyle(StackNavigationViewStyle())
        
        
            
        
    }
}

struct StartUpView_Previews: PreviewProvider {
    static var previews: some View {
        StartUpView()
    }
}

struct DashboardView: View {
    
    var titleText = ""
    var msgText = ""
    var body: some View {
        VStack {
            HStack {
                Text(titleText)
                    .font(.title3)
                    .foregroundColor(.white)
                Spacer()
            }
            HStack {
                Text(.init(msgText)).font(.caption).foregroundColor(.black)
                Spacer()
            }
        }
    }
}
