//
//  WaterDiaryModel.swift
//  SimTanka-iOS
//
//  Created by Vikram  on 15/06/22.
//
// Class for storing and displaying entries of water diary
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html

import Foundation
import CoreData

class WaterDiaryModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    
    private let waterDiaryController: NSFetchedResultsController<WaterDiary>
    private let dbContext: NSManagedObjectContext
    
    @Published var waterDiaryArray: [WaterDiary] = []
    
    init(managedObjectContext: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<WaterDiary> = WaterDiary.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "year", ascending: false)]
        
        waterDiaryController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        self.dbContext = managedObjectContext
        super.init()
        
        waterDiaryController.delegate = self
        
        do {
            try waterDiaryController.performFetch()
            waterDiaryArray = waterDiaryController.fetchedObjects ?? []
           // print(waterDiaryArray[0])
        } catch {
            print("Could not fetch water diary entries")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        do {
            try waterDiaryController.performFetch()
            waterDiaryArray = waterDiaryController.fetchedObjects ?? []
        } catch {
            print("Could not fetch water diary entries")
        }
    }
    
}

extension WaterDiaryModel {
    
    func AddWaterDiaryEntry() -> Bool {
        
        // create date for the previous month
        let dateToCheck = Helper.AddOrSubtractMonth(month: -1)
       
        // month in integer for the date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: dateToCheck)
        let month = components.month
        
        // year in integer for the date
        let componentsYear = calendar.dateComponents([.year], from: dateToCheck)
        let year = componentsYear.year
        
        // check if we have record for the given month
        let monthPredicate = NSPredicate(format: "month=%i", month!)
        let yearPredicate = NSPredicate(format: "year=%i", year!)
       
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [monthPredicate, yearPredicate])
        
        let filterDailyRecord = self.waterDiaryArray.filter ({ record in
            
           // compoundPredicate.evaluate(with: record)
            compoundPredicate.evaluate(with: record)
            
        })
        
        if filterDailyRecord.count != 0 {
            return false
        } else {
            return true 
        }
        
        
    }
    
    func SaveNewEntryToCD(waterInTankM3: Double, potability: Potable, entry: String, month: Int, year: Int, firstFlushCheck:Bool, roofCheck: Bool, plumbingCheck: Bool, tankCheck: Bool, waterFilterCheck: Bool) {
        
        // create a new entity for today
        let newEntry = WaterDiary(context: dbContext)
        
        // set month
        newEntry.month = Int64(month)
        
        // set year
        newEntry.year = Int64(year)
        
        // set the amount of water in M3
        newEntry.amountM3 = waterInTankM3
        
        // set raw value of Potability enum
        newEntry.potable = Int16(potability.rawValue)
        
        // set diary entry
        newEntry.diaryEntry = entry
        
        // set roofcheck
        newEntry.roofCheck = roofCheck
        
        // set firstflushcheck
        newEntry.firstFlushCheck = firstFlushCheck
        
        // set pumbingCheck
        newEntry.plumbingCheck = plumbingCheck
        
        // set waterFilterCheck
        newEntry.waterFilterCheck = waterFilterCheck
        
        // set tankCheck
        newEntry.tankCheck = tankCheck
        
        // add newEntry to the waterDiaryArray
        waterDiaryArray.append(newEntry)
        
        // save to the data base
        do {
            try self.dbContext.save()
        } catch {
            print("Error saving  new water diary record")
        }
        
    }
}

enum Potable:Int, CaseIterable{
    
    case Potable = 0
    case NonPotable = 1
    case Unknown = 2
    
    init (type: Int) {
        switch type {
        case 0: self = .Potable
        case 1: self = .NonPotable
        case 2: self = .Unknown

        default: self = .NonPotable
        }
    }
    
    var text: String {
        switch self {
        case .Potable : return "Potable"
        case .NonPotable : return "Non Potable"
        case .Unknown : return "Not Tested"
       
        }
    }
}
