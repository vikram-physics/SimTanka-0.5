//
//  WaterDiaryRowView.swift
//  SimTanka-iOS
//
//  Created by Vikram  on 15/06/22.
//
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html

import SwiftUI

struct WaterDiaryRowView: View {
    let myColorOne = Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
    let myColorTwo = Color(#colorLiteral(red: 0.2, green: 0.7, blue: 0.8, alpha: 0.5))
    let myColorThree = Color(#colorLiteral(red: 0.456269145, green: 0.4913182855, blue: 0.8021939397, alpha: 0.6583758503))
    
    @EnvironmentObject var myTankaUnits: TankaUnits
    
    let diary:WaterDiary?
   

    var body: some View {
        VStack(spacing:0) {
            HStack {
                Spacer()
                Text("\(Helper.intMonthToShortString(monthInt: Int(diary!.month))) \(String(diary!.year))").font(.caption2).fontWeight(.heavy)
                Spacer()
            } .padding(0).background(myColorTwo).foregroundColor(.black)
            HStack{
                Spacer()
                Text("Water in the tank: \(Helper.VolumeStringFrom(volumeM3: diary!.amountM3, volumeUnit: myTankaUnits.volumeUnit)) \(myTankaUnits.volumeUnit.text)")
                //Text(myTankaUnits.volumeUnit.text)
                //Spacer()
                Text("Water is")
                Text(Potable(rawValue: Int(diary!.potable))!.text)
                    .foregroundColor(Potable(rawValue: Int(diary!.potable))!.text == "Potable" ? .black : .red)
                Spacer()
            }.padding(2).background(myColorTwo).font(.caption2)
                //.font(.system(size: 14))
          /*  HStack{
                Text("Potability of water ")
                Spacer()
                Text(Potable(rawValue: Int(diary!.potable))!.text)
                    .foregroundColor(Potable(rawValue: Int(diary!.potable))!.text == "Potable" ? .white : .black)
                
            }.padding(4).background(myColorThree).font(.caption2) */
           
            // add checkmarks
            HStack{
                Spacer()
                VStack{
                    Text("Roof")
                    Image(systemName: diary!.roofCheck ? "checkmark.circle.fill" : "circle")
                }
               // Spacer()
                VStack{
                    Text("First Flush")
                    Image(systemName: diary!.firstFlushCheck ? "checkmark.circle.fill" : "circle")
                }
               // Spacer()
                VStack{
                    Text("Plumbing")
                    Image(systemName: diary!.plumbingCheck ? "checkmark.circle.fill" : "circle")
                }
               // Spacer()
                VStack{
                    Text("Water Filter")
                    Image(systemName: diary!.waterFilterCheck ? "checkmark.circle.fill" : "circle")
                }
               // Spacer()
                VStack {
                    Text("Tank")
                    Image(systemName: diary!.tankCheck ? "checkmark.circle.fill" : "circle")
                }
                Spacer()
            }.background(myColorThree).font(.caption2)
           
        }.frame(height: 150).cornerRadius(25)
            .onAppear{
                
            }
    }
}

struct WaterDiaryRowView_Previews: PreviewProvider {
    static var persistenceController = PersistenceController.shared
    static var diary = WaterDiary(context: persistenceController.container.viewContext)
    static var previews: some View {
        WaterDiaryRowView(diary: diary)
            .environmentObject(TankaUnits())
            .frame(height: 100)
    }
}
