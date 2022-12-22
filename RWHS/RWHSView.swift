//
//  RWHSView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 07/02/22.
//
// View for entering runoff, catch area and tank size
// Also display optimum tank size and performance
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html


import SwiftUI

struct RWHSView: View {
    
    var myColor4 = Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
    var myColor5 = Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
    
    @EnvironmentObject var myTankaUnits: TankaUnits
    @EnvironmentObject var simTankaVC: SimTankaVC
    @EnvironmentObject var demandModel:DemandModel
    
    // RWHS from app storage
    @AppStorage("runOff") var runOff = 0.0
    
    @AppStorage("catchAreaM2") private var catchAreaM2 = 0.0
    @AppStorage("tankSizeM3") private var tankSizeM3 = 0.0
    @AppStorage("setUpRWHSMsg") private var setUpRWHSMsg = ""
    @AppStorage("catchAreaSet") private var catchAreaSet = false
    @AppStorage("tankSizeSet") private var tankSizeSet = false
    @AppStorage("rwhsSet") private var rwhsSet = false
    @AppStorage("rainRecordsAvailable") private var rainRecordsAvailable = false // is true if past five years rainfall records were downloaded
    @AppStorage("canSim") private var canSim = false
    
    @State private var userRunOff = RunOff.Roof
    @State private var areaString = "5000"
    @State private var tankString = " "
    
    @State private var showResult = false
    @State private var isSimulating = false
    // results
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0.0){
                SimTankaMapView().frame(height: geometry.size.height * 0.4).padding(.horizontal)
                List {
                   // Spacer()
                    HStack {
                        VStack{
                            Text("Catchment Surface:")
                            Text(userRunOff.text).foregroundColor(.black)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(Color.white)
                        }
                        
                        Spacer()
                        Text("Efficiency " + String(userRunOff.rawValue * 100)+"%")
                            .foregroundColor(Color.white)
                    }.font(.subheadline)
                        .foregroundColor(.white)
                       .listRowBackground(myColor4)
                        
                    Picker("Runoff", selection: $userRunOff){
                        ForEach(RunOff.allCases, id:\.self){
                            Text($0.text)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    .listRowBackground(myColor5)
                    .font(.subheadline)
                    // catchment area
                    HStack{
                        Text("Catchement Area")
                            .foregroundColor(.white)
                        Spacer()
                        TextField("Area", text: $areaString)
                            .keyboardType(.numberPad)
                            .frame(width: 100 )
                            .multilineTextAlignment(.trailing)
                            .background(Color.gray)
                        Text(myTankaUnits.areaUnit.text)
                    }.listRowBackground(myColor4)
                        .onTapGesture {
                                  self.hideKeyboard()
                                }
                        .font(.subheadline)
                    
                    // tank size
                    VStack{
                        HStack{
                            Text("Storage Size")
                            Spacer()
                            TextField("Volume", text: $tankString)
                                .multilineTextAlignment(.trailing)
                                .background(Color.gray)
                                .keyboardType(.numberPad).frame(width: 100)
                            Text(myTankaUnits.volumeUnit.text)
                        }.onTapGesture {
                            self.hideKeyboard()
                          }
                        .font(.subheadline)
                    }.listRowBackground(myColor5)
                    
                    // estimate performance
                  
                    if rainRecordsAvailable && simSetup() {
                        VStack{
                            HStack {
                                Button (action: {
                                    self.setUpMessage()
                                    Task{
                                        //self.isSimulating = true
                                        self.saveVolume()
                                        self.saveRunOff()
                                        self.saveCatchArea()
                                        self.showResult = true
                                       // let finished = await self.estimatePerformance()
                                       // self.isSimulating = !finished
                                       // self.showResult = finished
                                        // self.forResearch()
                                    }
                                     }, label: {
                                         HStack{
                                             Spacer()
                                             Text(!isSimulating ? "Estimate and Optmize": "Please wait, working hard on it ...")
                                                 .font(.caption)
                                                 .frame(height:30)
                                                 .padding(5)
                                                 .background(myColor5)
                                                 .foregroundColor(Color.black)
                                                 .clipShape(Capsule())
                                             Spacer()
                                         }
                                         
                                })
                            }
                        }.listRowBackground(myColor4)
                    }
                        
                       
                  
                }.onAppear {
                    if runOff != 0 {
                        userRunOff = RunOff(rawValue: runOff ) ?? RunOff.Roof
                    }
                    
                    readCatchArea()
                    readVolume()
                }
                    .onDisappear {
                        runOff = userRunOff.rawValue
                        saveCatchArea()
                        saveVolume()
                        self.setUpMessage()
                        if rainRecordsAvailable && simSetup() {
                            self.canSim = true
                        } else {
                            self.canSim = false
                        }
                    }
                    .sheet(isPresented: $showResult) {
                        RwhsPerformanceView(myTanka:  SimInput(runOff: userRunOff.rawValue, catchAreaM2: catchAreaM2, tankSizeM3: tankSizeM3, dailyDemands: demandModel.DailyDemandM3()))
                            .presentationDetents([.fraction(0.75)])
                        
                }
                    .navigationTitle(Text("Harvesting System"))
                    .listStyle(PlainListStyle())
                    .padding()
                
               
            }.frame(height: geometry.size.height )
           
           
            
            
        }
        
    }
}


extension RWHSView {
    
    func saveRunOff() {
        runOff = userRunOff.rawValue
    }
    
    func saveCatchArea() {
        catchAreaM2 = Helper.CatchAreaInM2From(areaString: self.areaString, areaUnit: self.myTankaUnits.areaUnit)
    }
    
    func readCatchArea () {
        areaString = Helper.AreaStringFrom(catchAreaM2: self.catchAreaM2, areaUnit: myTankaUnits.areaUnit)
    }
    
    func saveVolume() {
        tankSizeM3 = Helper.VolumeInM3From(volumeString: self.tankString, volumeUnit: myTankaUnits.volumeUnit)
    }
    
    func catchAreaEntered() -> Bool {
        
        if areaString != "" && areaString != "0" {
            return true
        } else {
            return false
        }
    }
    
    func tankSizeEntered() -> Bool {
        
        if tankString != "" && tankString != "0"{
            return true
        } else {
            return false
        }
    }
    
    
    
    func simSetup() -> Bool {
        
        // check if we have catch area
        guard areaString != "" && areaString != "0" else {
            //self.catchAreaMissing = true
            return false
        }
         // guard if we have tank size
        guard tankString != "" && tankString != "0" else {
            return false
        }
        // guard if we have waterbudget
        guard demandModel.BudgetIsSet() else {
            //self.waterBudgetMissing = true
            return false
        }
        
        return true
    }
    
    func estimateSetup() -> Bool {
        
        if simSetup() && tankString != "" {
            return true
        } else {
            return false
        }
    }
    
    func readVolume() {
        tankString = Helper.VolumeStringFrom(volumeM3: self.tankSizeM3, volumeUnit: myTankaUnits.volumeUnit)
    }
    
    
    func estimatePerformance() async -> Bool {
        // save changes
        self.saveVolume()
        self.saveCatchArea()
        
        let myTanka = SimInput(runOff: userRunOff.rawValue, catchAreaM2: catchAreaM2, tankSizeM3: tankSizeM3, dailyDemands: demandModel.DailyDemandM3())
        
        // await self.simTanka.EstimatePerformanceUsingDailyRainfall(myTanka: myTanka)
        await self.simTankaVC.PerformanceForTankSizes(myTanka: myTanka)
        
        return true

    }
    
    func forResearch() {
        self.saveVolume()
        self.saveCatchArea()
        
       // let myTanka = SimInput(runOff: userRunOff.rawValue, catchAreaM2: catchAreaM2, tankSizeM3: tankSizeM3, dailyDemands: demandModel.DailyDemandM3())
        
       // self.simTanka.DisplayPeformanceUsingDailyRainfall(myTanka: myTanka)
        
    }
    
    func setUpMessage() {
        
        catchAreaSet = self.catchAreaEntered()
        tankSizeSet = self.tankSizeEntered()
        
        // if catch area is not set and tank size is not set
        if !catchAreaSet && !tankSizeSet {
            setUpRWHSMsg = "Please enter the catchment area and the tank size."
        }
        // if tank size is not set
        if catchAreaSet && !tankSizeSet {
            setUpRWHSMsg = "Please enter the tank size."
        }
        
        // if catch area is not set
        if !catchAreaSet && tankSizeSet {
            setUpRWHSMsg = "Please enter the catchment area."
        }
        
        // if both are set
        if catchAreaSet && tankSizeSet {
            setUpRWHSMsg = "RWHS is set."
        }
        

    }
}

struct RWHSView_Previews: PreviewProvider {
    
    static var persistenceController = PersistenceController.shared
    static var previews: some View {
        RWHSView()
            .environmentObject(TankaUnits())
            .environmentObject(SimTankaVC(managedObjectContext: persistenceController.container.viewContext))
            .environmentObject(DownLoadRainfallNOAA(managedObjectContext: persistenceController.container.viewContext))
            .environmentObject(DemandModel(managedObjectContext: persistenceController.container.viewContext))
    }
}

struct SimInput {
    var runOff: Double
    var catchAreaM2: Double
    var tankSizeM3: Double
    var dailyDemands: [Double]
}
