//
//  DailyBudgetView.swift
//  SimTanka-iOS
//
//  Created by Vikram  on 25/05/22.
//
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html

import SwiftUI

struct DailyBudgetView: View {
    @AppStorage("setUpBudgetMsg") private var setUpBudgetMsg =  "Please set up your water budget, this will allow SimTanka to estimate future performances"
    
    @EnvironmentObject var myTankaUnits: TankaUnits
    @EnvironmentObject var demandModel:DemandModel
    
    // for showing detailed view
    @State private var selcetedMonth: Int = 0
    @State private var showSheet = false
   
    @State private var demandsDisplay:[DemandDisplay] = []
    
    let myBlue = Color(red: 0.1, green: 0.1, blue: 90)
    let myGray = Color(red: 30, green: 0, blue: 100)
    let skyBlue = Color(red: 0.4627, green: 0.8392, blue: 1.0)
    var myColor4 = Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
    var myColor5 = Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
    
    var body: some View {
        List {
            Section(header: Text("Tap to enter the daily water budget").font(.subheadline)){
                Spacer()
                
                ForEach(demandModel.demandDisplayArray.indices, id: \.self) { month in
                    
                    HStack{
                        Text(demandModel.demandDisplayArray[month].monthStr)
                        Spacer()
                        Text(demandModel.demandDisplayArray[month].demand)
                        Text(myTankaUnits.demandUnit.text)
                    }.containerShape(Rectangle()).padding().frame(height: 20)
                    .onTapGesture {
                        self.selcetedMonth = month
                        self.showSheet = true
                        print(selcetedMonth)
                    }
                        .foregroundColor(.black)
                       .listRowBackground((month % 2 == 0 ? myColor4 : myColor5))
                }
               Spacer()
            }
           
        }.onAppear{
            UITableView.appearance().separatorStyle = .none
            demandModel.FromCoreDataToUserDisplay(userDemandUnit: myTankaUnits.demandUnit)
        }
        .sheet(isPresented: $showSheet) {
            DemandRowView(monthIndex: self.$selcetedMonth)
                .presentationDetents([.fraction(0.4)])
        }
        .onDisappear {
            demandModel.SaveUserDemandToCoreData(userDemandUnit: myTankaUnits.demandUnit)
            self.setWaterBudgetMsg()
        }.environment(\.defaultMinListRowHeight, 10)
        .navigationTitle(Text("Daily Water Budget"))
       // .listStyle(PlainListStyle()).padding()
        
       
        
    }
}

extension DailyBudgetView {
   
    
    func fromCDtoDisplayArray() {
        for month in 1...12 {
            // find the user demand in M3 from Core Data
            let demandCD = demandModel.dailyDemandM3Array[month - 1]
            let demandM3 = demandCD.dailyDemandM3
            
            // user demand
            let userDemand = Helper.M3toDemandUnit(demandM3: demandM3, demandUnit: myTankaUnits.demandUnit)
            // month
            let deamandMonth = demandCD.month
            
            let newDemandToDisplay = DemandDisplay(userUnits: myTankaUnits.demandUnit, month: Int(deamandMonth), demand: String(userDemand))
            
            self.demandsDisplay.append(newDemandToDisplay)
           
        }
    }
    
    func setWaterBudgetMsg() {
        if demandModel.BudgetIsSet() {
            setUpBudgetMsg = "Water budget is set."
        }
    }
}

struct DailyBudgetView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.shared
    
    static var previews: some View {
        DailyBudgetView()
            .environmentObject(TankaUnits())
            .environmentObject(DemandModel(managedObjectContext: persistenceController.container.viewContext))
    }
}

struct Demand {
    var month: Int
    let demand: Double  // demand in user unit
    
}

struct DemandDisplay {
    
    var userUnits = DemandUnit(rawValue: 0)
    var month: Int
    var demand: String
    
    var monthStr:String {
        return Helper.intMonthToShortString(monthInt: self.month)
    }
    
    
}


