//
//  RwhsPerformanceView.swift
//  SimTanka-iOS
//
//  Created by Vikram  on 25/06/22.
//
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html

import SwiftUI

struct RwhsPerformanceView: View {
    @EnvironmentObject var myTankaUnits: TankaUnits
    @EnvironmentObject var simTankaVC: SimTankaVC
    @EnvironmentObject var demandModel:DemandModel
    @AppStorage("tankSizeM3") private var tankSizeM3 = 0.0
    
    var myColor4 = Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
    var myColor5 = Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
    
    var myTanka:SimInput
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Rectangle()
                    .fill(myColor4)
                    .frame(height: geometry.size.height * 1.0)
                List {
                    if simTankaVC.performanceSim {
                        HStack{
                            ProgressView(simTankaVC.performanceMsg, value: simTankaVC.performanceProgress, total: 100)
                                .padding()
                            ProgressView()
                        }
                       
                       
                    }
                    VStack {
                        HStack {
                            Spacer()
                            Text((simTankaVC.performanceSim ? " Estimating Reliability" : "Estimated Reliabilty") ).font(.title2)
                            Spacer()
                        }
                        Text("Annual demand of \(Helper.VolumeStringFrom(volumeM3: demandModel.AnnualWaterDemandM3(), volumeUnit: myTankaUnits.volumeUnit)) \(myTankaUnits.volumeUnit.text)")
                       // Text(myTankaUnits.volumeUnit.text)
                        Spacer()
                    }
                        .listRowBackground(myColor4)
                        .foregroundColor(.white)
                    
                    HStack{
                        Spacer()
                        Text("Tank \(myTankaUnits.volumeUnit.text)")
                        Spacer()
                        Text("Reliability")
                        Spacer()
                    }.listRowBackground(myColor5).font(.title3)
                   
                    ForEach(simTankaVC.displayResults, id: \.self ) { result in
                        
                        HStack{
                            Spacer()
                            Text("\(Helper.VolumeStringFrom(volumeM3: result.tanksizeM3, volumeUnit: myTankaUnits.volumeUnit))")
                            Spacer()
                            Text("\(Helper.LikelyHoodProbFrom(reliability: result.annualSuccess))")
                            Spacer()
                        }.listRowBackground(( tankSizeM3 == result.tanksizeM3 ? myColor5 : myColor4))
                            .foregroundColor(Color.white)
                            .frame(height: 30)
                    }
                   // Spacer()
                   
                }.environment(\.defaultMinListRowHeight, 30)
                 .frame(height: geometry.size.height * 0.6)
                 .listStyle(PlainListStyle())
                 .task {
                     await self.estimatePerformance(myTanka: myTanka)
                 }
            }
            
            
        }
        
    }
}

extension RwhsPerformanceView {
   func estimatePerformance(myTanka:SimInput) async {
       
       await self.simTankaVC.PerformanceForTankSizes(myTanka: myTanka)
        
    }
}

struct RwhsPerformanceView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.shared
    
    static var previews: some View {
        RwhsPerformanceView(myTanka: SimInput(runOff: 0.8, catchAreaM2: 100, tankSizeM3: 5000, dailyDemands: [0,0,0,0,0,0,100,0,0,0,0,0]))
            .environmentObject(TankaUnits())
            .environmentObject(SimTankaVC(managedObjectContext: persistenceController.container.viewContext))
            .environmentObject(DemandModel(managedObjectContext: persistenceController.container.viewContext))
    }
}
