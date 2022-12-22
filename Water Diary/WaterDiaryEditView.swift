//
//  WaterDiaryEditView.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 18/06/22.
//
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html

import SwiftUI

struct WaterDiaryEditView: View {
    
    var myColorOne = Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 0.3207908163))
    var myColorTwo = Color(#colorLiteral(red: 0.2, green: 0.7, blue: 0.8, alpha: 0.5))
    var myColorThree = Color(#colorLiteral(red: 0.456269145, green: 0.4913182855, blue: 0.8021939397, alpha: 0.6583758503))
    
    @EnvironmentObject var myTankaUnits: TankaUnits
    @Environment(\.managedObjectContext) var dbContext
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("tankSizeM3") private var tankSizeM3 = 1000.0
    
    let diary:WaterDiary?
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
            
        }.navigationTitle(Text("Water Diary for \(Helper.intMonthToShortString(monthInt: Int(diary!.month)))" + "-\(diary!.year)"))
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        VStack {
               HStack{Spacer()
                   Text("Water Diary").fontWeight(.light).textCase(.uppercase)
                   Spacer()
               }//.listRowBackground(myColorOne)
               
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
                    self.savedEditedChanges()
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    HStack{
                        Spacer()
                        Image(systemName: "square.and.arrow.down.on.square.fill")
                        Text("Save Changes").font(.headline)
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
          

        }
         .onAppear {
                self.waterInTank = diary!.amountM3
                self.potable = Potable(rawValue: Int(diary!.potable))!
                self.maintianceComments = diary!.diaryEntry!
                self.roofCleaned = diary!.roofCheck
                self.firstFlushChecked = diary!.firstFlushCheck
                self.plumbingChecked = diary!.plumbingCheck
                self.waterFilterChecked = diary!.waterFilterCheck
                self.tanksChecked = diary!.tankCheck
           
        }
       // .background(Color.teal)
        
    }
}

extension WaterDiaryEditView {
    
    func savedEditedChanges() {
        
        // save amount of water
        diary?.amountM3 = self.waterInTank
        // save potability
        diary?.potable = Int16(self.potable.rawValue)
        // save diary entry
        diary?.diaryEntry = self.maintianceComments
        // save roofCleaned
        diary?.roofCheck = self.roofCleaned
        // save firstFlushChecked
        diary?.firstFlushCheck = self.firstFlushChecked
        // save plumbingChecked
        diary?.plumbingCheck = self.plumbingChecked
        // save waterfilterChecked
        diary?.waterFilterCheck = self.waterFilterChecked
        // save tankChecked
        diary?.tankCheck = self.tanksChecked
        
        
        
        // save to the data base
        do {
            try self.dbContext.save()
        } catch {
            print("Error saving  edited water diary record")
        }
    }
}

struct WaterDiaryEditView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.shared
    static var diary = WaterDiary(context: persistenceController.container.viewContext)
    static var previews: some View {
        WaterDiaryEditView(diary: diary)
            .environmentObject(TankaUnits())
    }
}
