//
//  DemandRowView.swift
//  SimTanka-iOS
//
//  Created by Vikram  on 26/05/22.
//
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html

import SwiftUI

struct DemandRowView: View {
    @EnvironmentObject var myTankaUnits: TankaUnits
    @EnvironmentObject var demandModel:DemandModel
    @Binding var monthIndex: Int
    @State var dailyWater: String = ""
    @State var useSameDailyBudgetForAllMonths = false
    
    @FocusState private var dailyDemandIsFocused: Bool
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack{
                
                Color.gray
                VStack {
                    HStack{
                        Text(Helper.intMonthToShortString(monthInt: monthIndex + 1)).padding()
                        Spacer()
                        TextField("Daily Demand ", text: $dailyWater )
                        Text(myTankaUnits.demandUnit.text)
                    }.frame(width: geometry.size.width, height: 50, alignment: .leading)
                        .background(Color.clear)
                        .focused($dailyDemandIsFocused)
                        .keyboardType(.numberPad)
                        .frame(width: 100)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(.primary)
                    .onTapGesture {
                                  dailyDemandIsFocused = false
                    }
                    .onDisappear {
                        if useSameDailyBudgetForAllMonths {
                            sameDailyDemandForAllMonths()
                        } else {
                            demandModel.demandDisplayArray[monthIndex].demand = dailyWater
                        }
                       
                    }.onAppear {
                        demandString()
                    }
                    HStack{
                        Toggle(isOn:$useSameDailyBudgetForAllMonths) {
                            Text("Use for all the months").foregroundColor(.white).padding()
                        }.toggleStyle(CheckboxToggleStyle())
                    }.padding()
                }
            }
            
            
        }
        
        
    }
}

extension DemandRowView {
    
    func demandString() {
        
        if demandModel.demandDisplayArray[self.monthIndex].demand == "0" {
            dailyWater = ""
        } else {
            dailyWater = demandModel.demandDisplayArray[self.monthIndex].demand
        }
    }
    
    func sameDailyDemandForAllMonths() {
        
        for monthIndex in 0...11 {
            demandModel.demandDisplayArray[monthIndex].demand = dailyWater
        }
    }
}

struct DemandRowView_Previews: PreviewProvider {
    
    static var persistenceController = PersistenceController.shared
    
    static var previews: some View {
        
        ZStack{
            DemandRowView(monthIndex: .constant(3))
                .previewLayout(.fixed(width: 400, height: 200))
                .environmentObject(TankaUnits())
                .environmentObject(DemandModel(managedObjectContext: persistenceController.container.viewContext))
        }
       
    }
}
 
