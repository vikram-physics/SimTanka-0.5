//
//  MonthlyPerformanceView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 16/02/22.
//
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html

import SwiftUI

struct MonthlyPerformanceView: View {
    
    @EnvironmentObject var myTankaUnits: TankaUnits
    @EnvironmentObject var simTanka: SimTanka
    @EnvironmentObject var demandModel:DemandModel
    
    var body: some View {
        GeometryReader { geometry in
            
            // show all the rows for which waterdemand is non-zero
            List {
                ForEach(demandModel.demandDisplayArray.indices, id: \.self ) { month in
                    
                    
                    
                    
                }
            } .frame(height: geometry.size.height * 0.9)
                .onAppear {
                   
                }
           
            
        }
    }
}

struct MonthlyPerformanceView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.shared
    
    static var previews: some View {
        MonthlyPerformanceView()
            .environmentObject(TankaUnits())
            .environmentObject(SimTanka(managedObjectContext: persistenceController.container.viewContext))
            .environmentObject(DemandModel(managedObjectContext: persistenceController.container.viewContext))
    }
}
