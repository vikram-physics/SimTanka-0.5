//
//  WaterDiaryDetailView.swift
//  SimTanka-iOS
//
//  Created by Vikram  on 14/06/22.
//
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html


import SwiftUI
import Combine

struct WaterDiaryAddView: View {
    var myColorOne = Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 0.3207908163))
    var myColorTwo = Color(#colorLiteral(red: 0.2, green: 0.7, blue: 0.8, alpha: 0.5))
    var myColorThree = Color(#colorLiteral(red: 0.456269145, green: 0.4913182855, blue: 0.8021939397, alpha: 0.6583758503))
    
    @EnvironmentObject var myTankaUnits: TankaUnits
    @EnvironmentObject var waterDiaryModel:WaterDiaryModel
    
    @AppStorage("tankSizeM3") private var tankSizeM3 = 1000.0
    
    @State  var waterInTank:Double = 0.0
    @State private var potable = Potable.NonPotable
    
    @State var maintianceComments = ""
    @State var roofCleaned = false
    @State var firstFlushChecked = false
    @State var plumbingChecked = false
    @State var waterFilterChecked = false
    @State var tanksChecked = false
    
    var body: some View {
        
        List {
            Section(header: Text("Water at the end of the month"), content: {
                VStack {
                   /* HStack{
                        Text("Water in the tank at the end of the month.")
                            .foregroundColor(.white)
                       // Spacer()
                    }*/
                    HStack{
                        Text("Amount").font(.caption2)
                        Slider(value: $waterInTank, in: 0...tankSizeM3).padding(0)
                        Spacer()
                        Text(Helper.VolumeStringFrom(volumeM3: waterInTank, volumeUnit: myTankaUnits.volumeUnit))
                        Text(myTankaUnits.volumeUnit.text)
                    }
                }.listRowBackground(Color(#colorLiteral(red: 0.2, green: 0.7, blue: 0.8, alpha: 1)))
                
                VStack {
                   
                    Picker("Potable?", selection: $potable){
                        ForEach(Potable.allCases, id:\.self){
                            Text($0.text)
                            //Text("\($0.text)").font(.caption)
                        }

                    }
                }.pickerStyle(SegmentedPickerStyle())
                    .listRowBackground(Color(#colorLiteral(red: 0.5, green: 0.5, blue: 0.8, alpha: 1)))
                    
                
            })
            
            Section(header: Text("Maintainance"), content: {
                HStack{
                    Toggle(isOn: $roofCleaned) {
                        Text("Collecting surface cleaned").foregroundColor(.black)
                    }.toggleStyle(CheckboxToggleStyle())
                    
                }.listRowBackground(myColorThree)
               
                HStack {
                    Toggle(isOn:$firstFlushChecked) {
                        Text("First flush checked").foregroundColor(.black)
                    }.toggleStyle(CheckboxToggleStyle())
                }.listRowBackground(myColorTwo)
                
                HStack {
                    Toggle(isOn:$plumbingChecked) {
                        Text("Pipes and gutters checked").foregroundColor(.black)
                    }.toggleStyle(CheckboxToggleStyle())
                }.listRowBackground(myColorThree)
                
                HStack {
                    Toggle(isOn:$waterFilterChecked) {
                        Text("Water filter checked").foregroundColor(.black)
                    }.toggleStyle(CheckboxToggleStyle())
                }.listRowBackground(myColorTwo)
                
                HStack {
                    Toggle(isOn:$tanksChecked) {
                        Text("Tanks Checked").foregroundColor(.black)
                    }.toggleStyle(CheckboxToggleStyle())
                }.listRowBackground(myColorThree)
                
                
                
                
                
            })
            
        
           
               // .listRowBackground(myColorThree)
            
         
        }.navigationTitle(Text("Water Diary for \(Helper.PreviousMonth())"))
            .navigationBarTitleDisplayMode(.inline)
        VStack {
               HStack{Spacer()
                   Text("Water Diary").fontWeight(.light).textCase(.uppercase)
                   Spacer()
               }.listRowBackground(myColorOne)
               
            TextEditor(text: $maintianceComments)
                .scrollContentBackground(.hidden)
                .padding()
                .foregroundColor(.white)
                .background(Color.green.opacity(0.7))
                .frame(width: 350, height: 100)
                .cornerRadius(20)
                .onTapGesture {
                    self.hideKeyboard()
            }
            HStack {
                Spacer()
                Button(action: {
                    self.saveEnteryToCoreData()
                }, label: {
                    HStack{
                        Spacer()
                        Image(systemName: "square.and.arrow.down.on.square.fill")
                        Text("Save").font(.headline)
                        Spacer()
                    }.font(.caption)
                        .frame(width: 200, height:30)
                        .padding(5)
                        .background(myColorThree)
                        .foregroundColor(Color.black)
                        .clipShape(Capsule())
                    
            })
                Spacer()
            }
              .listRowBackground(myColorOne)

        }
        
        
        
       
       
        
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Button(action: {
                configuration.isOn.toggle()
            }, label: {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
            })
        }.frame(height: 10).font(.subheadline)
    }
}

extension WaterDiaryAddView {
    
    func saveEnteryToCoreData() {
        
        self.waterDiaryModel.SaveNewEntryToCD(waterInTankM3: waterInTank, potability: potable, entry: maintianceComments, month: Helper.PreviousMonthInt() , year: Helper.PreviousMonthsYear(), firstFlushCheck: firstFlushChecked, roofCheck: roofCleaned, plumbingCheck: plumbingChecked, tankCheck: tanksChecked, waterFilterCheck: waterFilterChecked)
        
    }
}


struct WaterDiaryDetailView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.shared
    
    static var previews: some View {
        WaterDiaryAddView()
            .environmentObject(TankaUnits())
            .environmentObject(WaterDiaryModel(managedObjectContext: persistenceController.container.viewContext))
        
    }
} 
