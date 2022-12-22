//
//  WaterDiaryListView.swift
//  SimTanka-iOS
//
//  Created by Vikram  on 15/06/22.
//
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html

import SwiftUI

struct WaterDiaryListView: View {
    
    @EnvironmentObject var myTankaUnits: TankaUnits
    @EnvironmentObject var waterDiaryModel:WaterDiaryModel
   
    var body: some View {
        
       
            VStack {
               
                List(waterDiaryModel.waterDiaryArray) { diary in
                   NavigationLink(destination: WaterDiaryEditView(diary: diary), label: {
                       
                       HStack {
                           WaterDiaryRowView(diary: diary)
                               .id(UUID())
                       }.frame(width:350).padding()
                   }).listRowBackground(Color.gray)
                    
                    
                }
               
                
                // create a button for adding new entry
                Spacer()
                if waterDiaryModel.AddWaterDiaryEntry() {
                    Button(action: {
                     }) {
                         NavigationLink(destination: WaterDiaryAddView()) {
                             HStack {
                                 //Spacer()
                                 Image(systemName: "note.text.badge.plus")
                                 //Spacer()
                                 Text("Add new diary entry")
                             }
                         }
                     }
                     .frame(width: 300, height: 40)
                     .padding(5)
                     .background(Color.purple)
                     .foregroundColor(.white)
                     .border(Color.purple, width: 5)
                }
               
                Spacer()
                
            }.navigationTitle(Text("Water Diary"))
            .navigationBarTitleDisplayMode(.inline)
        
    }
       
    }


extension WaterDiaryListView {
    func deleteDiaryEntry() {
        
    }
}

struct WaterDiaryListView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.shared
    static var previews: some View {
        WaterDiaryListView()
            .environmentObject(TankaUnits())
            .environmentObject(WaterDiaryModel(managedObjectContext: persistenceController.container.viewContext))
    }
}
