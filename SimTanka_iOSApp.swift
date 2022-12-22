//
//  SimTanka_iOSApp.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 12/12/21.
//

import SwiftUI

@main
struct SimTanka_iOSApp: App {
    
    
   
    
    @StateObject var myTankaUnits = TankaUnits() // user pref for units
    
    @StateObject private var downloadRain:DownloadRainfallFromVC
    
    @StateObject private var downloadRainModel:DownLoadRainfallNOAA // to be removed
    
    @StateObject var demandModel:DemandModel
    
    @StateObject var simTankaVC: SimTankaVC
    
    @StateObject private var simTanka:SimTanka // to be removed
    
    @StateObject private var performancdModel:PerformanceModel
    
    @StateObject private var waterDiaryModel:WaterDiaryModel
    
    init() {
        self.persistenceController = PersistenceController.shared
        
        let rain = DownloadRainfallFromVC(managedObjectContext: persistenceController.container.viewContext)
        self._downloadRain = StateObject(wrappedValue: rain)
        
        let rainModel = DownLoadRainfallNOAA(managedObjectContext: persistenceController.container.viewContext)
        
        self._downloadRainModel = StateObject(wrappedValue: rainModel)
        
        let simModel = SimTanka(managedObjectContext: persistenceController.container.viewContext)
        
        self._simTanka = StateObject(wrappedValue: simModel)
        
        let simModelVC = SimTankaVC(managedObjectContext: persistenceController.container.viewContext)
        self._simTankaVC = StateObject(wrappedValue: simModelVC)
        
        let demand = DemandModel(managedObjectContext: persistenceController.container.viewContext)
        self._demandModel = StateObject(wrappedValue: demand)
        
        let performance = PerformanceModel(managedObjectContext: persistenceController.container.viewContext)
        self._performancdModel = StateObject(wrappedValue: performance)
        
        let diaryModel = WaterDiaryModel(managedObjectContext: persistenceController.container.viewContext)
        self._waterDiaryModel = StateObject(wrappedValue: diaryModel)
    }
    let persistenceController: PersistenceController

    var body: some Scene {
        WindowGroup {
            //ContentView()
           // SettingUpView()
            StartUpView()
                .environmentObject(myTankaUnits)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(downloadRainModel)
                .environmentObject(simTanka)
                .environmentObject(demandModel)
                .environmentObject(performancdModel)
                .environmentObject(waterDiaryModel)
                .environmentObject(downloadRain)
                .environmentObject(simTankaVC)
        }
    }
}
