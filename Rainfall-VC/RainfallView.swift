//
//  RainfallView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 09/11/22.
//
// To download and display rainfall data
//
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html


import SwiftUI
import Charts

struct RainfallView: View {
    
    
    @EnvironmentObject var myTankaUnits: TankaUnits
    @EnvironmentObject var downloadRain: DownloadRainfallFromVC
    
    
    // user storage data
    // base year is the year from which user starts using SimTanka
    @AppStorage("setBaseYear") private var setBaseYear = false
    @AppStorage("baseYear") private var baseYear = 0
    @AppStorage("msgLocationMetStation") private var  msgLocationMetStation = ""
    
    // For storing the location of the RWHS
    @AppStorage("rwhsLat") private var rwhsLat = 0.0
    @AppStorage("rwhsLong") private var rwhsLong = 0.0
    @AppStorage("nameOfLocation") private var nameOfLocation = String()
    @AppStorage("cityOfRWHS") private var cityOfRWHS = String()

    var body: some View {
        
        GeometryReader { geometry in
            
            VStack{
                HStack{
                  
                    Text(downloadRain.downloadMsg  + " \(cityOfRWHS) in \(myTankaUnits.rainfallUnit.text)").font(.headline)
                  
                    
                }.frame(height: geometry.size.height * 0.1)
                
                Chart(downloadRain.arrayOfAnnualRain) {
                    BarMark(
                        x: .value("year", String($0.year)),
                        y: .value("rain", Helper.RainInUserUnitFromMM(rainMM: $0.annualRainMM, userRainUnits: myTankaUnits.rainfallUnit) )
                    )
                }.frame(height: geometry.size.height * 0.7)

                HStack{
                    Link(destination: URL(string: "https://www.visualcrossing.com/")!) {
                        VStack {
                            Image("PoweredByVC").resizable().scaledToFit()
                            
                        }
                    }.frame(height: geometry.size.height * 0.15)
                }
                
            }.onAppear {
                checkForBaseYear()
            }
            .task {
               await downloadRainfall()
            }
        }
        
       
       
    }
}

extension RainfallView {
    
    func checkForBaseYear() {
    
        if !setBaseYear {
            // find current year
            let year = Helper.CurrentYear()
            self.baseYear = year
            self.setBaseYear = true
        }
       
    }
    
    func downloadRainfall() async {
        self.msgLocationMetStation = "[Powered by Visual Crossing Weather](https://www.visualcrossing.com/)"
        // check if we have rainfall records
        let count = downloadRain.dailyRainArrayCD.count
        print(" your have \(count) days of record")
        
        if count == 0 {
            await fetchPastFiveYearRainfall()
        } else {
            // update annual rainfall view array for chart
            downloadRain.LastFiveYearsAnnualRain()
            
        }
    }
    
    func fetchPastFiveYearRainfall() async {
        do {
            try  await downloadRain.FetchAndSavePastFiveYearsDailyRainfall(latitude: rwhsLat, longitude: rwhsLong)
        } catch {
            print("Could not download met stations")
        }
    }
    
    
}
struct RainfallView_Previews: PreviewProvider {
    
    static var persistenceController = PersistenceController.shared
    
    static var previews: some View {
        RainfallView()
            .environmentObject(DownloadRainfallFromVC(managedObjectContext: persistenceController.container.viewContext))
            .environmentObject(TankaUnits())
    }
}
