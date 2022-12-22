//
//  SimTankaVC.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 05/12/22.
//
// Main mocel for simulations using rainfall data
// obtained via Visual Crossing API
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html

import Foundation
import SwiftUI
import CoreData

class SimTankaVC: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    
    @AppStorage("baseYear") private var baseYear = 0
    
    // rainfall data from Coredata
    private let dailyRainController: NSFetchedResultsController<DailyRainVC>
    private let dbContext: NSManagedObjectContext
    
    // daily rainfall records stored in CoreData
    var dailyRainArrayCD : [DailyRainVC] = []
    
    // for displaying results in RWHS view
    @Published var displayResults:[EstimateResult] = []
    
    // for performance of the RWHS
    @Published var performanceMsg = String()
    @Published var performanceSim = false
    @Published var performanceProgress = Double()
    var counter = 0
    
    init(managedObjectContext: NSManagedObjectContext) {
        let fetchDailyRainfall:NSFetchRequest<DailyRainVC> = DailyRainVC.fetchRequest()
        fetchDailyRainfall.sortDescriptors = [NSSortDescriptor(key: "year", ascending: true)]
        
        dailyRainController = NSFetchedResultsController(fetchRequest: fetchDailyRainfall, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        self.dbContext = managedObjectContext
        
        super.init()
        
        dailyRainController.delegate = self
        
        // fetch the stored data
        
        do {
            try dailyRainController.performFetch()
            dailyRainArrayCD = dailyRainController.fetchedObjects ?? []
           
        } catch {
            print("Could not fetch daily rainfall records")
        }
        
        
    }
    
    func PerformanceForTankSizes(myTanka: SimInput) async {
        
        let userTankSizeM3 = myTanka.tankSizeM3
        let deltaTank = userTankSizeM3 * 0.25
        var trialTanka = myTanka
        // trying out two different sizes of tank
        let numberOfNewTankSize = 1 // will simulate three sizes starting with the users size
        
        DispatchQueue.main.async {
            self.counter = 0
            self.performanceProgress = 10.0 // initial
            self.displayResults = []
            self.performanceMsg = "Please wait, working hard!"
            self.performanceSim = true
        }
        
       
        
        for tankStep in -1...numberOfNewTankSize {
            
            let tankSizeM3 = userTankSizeM3 + Double(tankStep) * deltaTank
            trialTanka.tankSizeM3 = tankSizeM3
            
            let success = ProbabilityOfSuccess(myTanka: trialTanka)
           
           let estimateSucc = EstimateResult(tanksizeM3: tankSizeM3, annualSuccess: Int(success * 100))
            DispatchQueue.main.async {
                self.counter += 1
                self.performanceProgress = (Double(self.counter) / Double((numberOfNewTankSize + 2))) * 100
                self.displayResults.append(estimateSucc)
            }
        }
        
        DispatchQueue.main.async {
            self.performanceSim = false
        }
        
    }
    
    func ProbabilityOfSuccess(myTanka: SimInput) -> Double {
        
        let runOff = myTanka.runOff
        let catchAreaM2  = myTanka.catchAreaM2
        let userTankSizeM3 = myTanka.tankSizeM3
        let dailyDemandArrayM3 = myTanka.dailyDemands
        
        var waterInTankToday = 0.0
        var waterInTankYesterday = 0.0
        
        var daysUsed = 0 // number of days tanka is used
        var succDays = 0 // number of successful days
        
        
        let yearsToSim = Helper.PastFiveYearsFromBaseYear(baseYear: baseYear)
        
        for year in yearsToSim {
            
            for month in 1...12 {
                
                for day in 1...Helper.DaysIn(month: month, year: year) {
                    
                    // water harvested on the day
                    waterInTankToday = DailyWaterHarvestedM3(day: day, month: month, year: year, runOff: runOff, catchAreaM2: catchAreaM2) + waterInTankYesterday
                   
                    // water harvested cannot be larger than the tank size
                    waterInTankToday = min(waterInTankToday, userTankSizeM3)
                    
                    let dailyDemand = dailyDemandArrayM3[month - 1]
                    
                    if dailyDemand != 0.0 {
                        daysUsed = daysUsed + 1
                        waterInTankToday = waterInTankToday - dailyDemand
                        if waterInTankToday >= 0 {
                            succDays = succDays + 1
                        } else {
                            waterInTankToday = 0 // tank is empty
                        }
                    }
                    
                    // prepare for tomorrow
                    waterInTankYesterday = waterInTankToday
                    
                    
                }
                
            } // month loop
            
        }
        
        // probability of success
        
        let probSucc = Double(succDays) / Double(daysUsed)
        
        return probSucc
    }
    
    func DailyWaterHarvestedM3(day:Int, month:Int, year:Int, runOff: Double, catchAreaM2: Double) -> Double {
        // month 1 = Jan
        // month 12 = Dec
        
        var waterHarvested = 0.0
        
        // get the desired daily record from core data
        let dayPredicate = NSPredicate(format: "day=%i", day)
        let monthPredicate = NSPredicate(format: "month=%i", month)
        let yearPredicate = NSPredicate(format: "year=%i", year)
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [dayPredicate, monthPredicate, yearPredicate])
        
        let filterDailyRecord = self.dailyRainArrayCD.filter ({ record in
            
            compoundPredicate.evaluate(with: record)
            
        })
        
        // check if there is any record
        if filterDailyRecord.count != 0 {
           
            waterHarvested = filterDailyRecord[0].dailyRainMM * 0.001 * catchAreaM2 * runOff
        } else {
            
            waterHarvested = 0 // assume no rainfall for the day for which record is not there
        }
        
       // print( day, month, year, waterHarvested)
        return waterHarvested
    }
}

extension SimTankaVC {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        guard let fetchedRainfall = controller.fetchedObjects as? [DailyRainVC] else {
            return
        }
        dailyRainArrayCD = fetchedRainfall
    }
}

struct EstimateResult: Hashable {
    var tanksizeM3: Double
    var annualSuccess: Int
}
