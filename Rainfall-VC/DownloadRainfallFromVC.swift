//
//  DownloadRainfallFromVC.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 12/11/22.
//
// Main class for downloading monthly rainfall
// using Visual Crossing API
// and Saving to CoreData
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html


import Foundation
import SwiftUI
import CoreData

class DownloadRainfallFromVC:  NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    
    @AppStorage("baseYear") private var baseYear = 0 // the year user started using SimTanka
    @AppStorage("rainRecordsAvailable") private var rainRecordsAvailable = false // is true if past five years rainfall records were downloaded
    
    @Published var downloading = false
    @Published var downloadMsg = String()
    
    // core data
    private let dailyRainController: NSFetchedResultsController<DailyRainVC>
    private let dbContext: NSManagedObjectContext
    
    // daily rainfall records stored in CoreData
    var dailyRainArrayCD : [DailyRainVC] = []
    
    // for charts
    @Published var arrayOfDailyRain: [DisplayDailyRain] = [] // for displaying in chart view
    @Published var arrayOfMonthRain: [DisplayMonthRain] = [] // for displaying in chart view
    @Published var arrayOfAnnualRain: [DisplayAnnualRain] = [] // for displayig in chart view
    
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
        
        // populate annual rainfall array from daily rainfall array
        if dailyRainArrayCD.count != 0 {
            
        }
    }
    
    func CreateURLrequestFor(month:Int, year:Int, latitude: Double, longitude: Double) -> URLRequest {
        
        // create start date
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month, day: 1)
        let startDate = calendar.date(from: dateComponents)!
        
        // convert start date into string
        let startDateFormatter = DateFormatter()
        startDateFormatter.dateFormat = "yyyy'-'MM'-'dd"
        let startString = startDateFormatter.string(from: startDate)
        
        // find the number of days
        let interval = calendar.dateInterval(of: .month, for: startDate)!
        let days = calendar.dateComponents([.day], from: interval.start, to: interval.end)
        
        // create end date
        let endDateComponents = DateComponents(year: year, month: month, day: days.day)
        let endDate = calendar.date(from: endDateComponents)!
        
        // convert end date into string
        let endString = startDateFormatter.string(from: endDate)
        
        
        // creating VC timeline weather api
        var urlString = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/"
        
        // convert latitude and location to string
        let locationString = String(latitude) + "," + String(longitude)
        
        // add  location to urlString
        urlString = urlString + locationString + "/"
        
        // add date1 - start date
        urlString = urlString + startString + "/"
        
        // add date2 - end date
        urlString = urlString + endString
        
        // create an instance of url component
        var urlComponents = URLComponents(string: urlString)!
        
       
        
        
        // create query
        
        // item for units returns rainfall in mm
        let queryItemUnit = URLQueryItem(name: "unitGroup", value: "metric")
        // maxDistance of the met. station for obtaining rainfall
        let queryItemMaxDistance = URLQueryItem(name: "maxDistance", value: "50000")
        // vc key for open source
        let queryItemKey = URLQueryItem(name: "key", value: "") // provided by Visual Crossing
        // daily historical observations
        let queryItemInclude = URLQueryItem(name: "include", value: "remote,obs,days")
        // get rainfall for the day
        let queryItemElements = URLQueryItem(name: "elements", value: "datetime,precip")
        
        let queryItems = [queryItemUnit, queryItemMaxDistance, queryItemElements, queryItemInclude, queryItemKey]

        urlComponents.queryItems = queryItems
        
        let testURL = urlComponents.url!
        //print(testURL)
        // url created
       // let url = urlComponents.url!
        //test
       // print(url)
       // let url = URL(string: "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/Bikaner/2022-07-01/2022-07-31?unitGroup=metric&elements=datetime%2Cprecip&include=days&key=4P4NBUCNQQKSRNENEM6CJNB88&contentType=json")
       // let url = URL(string: "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/28.0%2C%2073.3/2022-07-01/2022-07-31?unitGroup=metric&elements=datetime%2Cprecip&include=days&key=4P4NBUCNQQKSRNENEM6CJNB88&contentType=json")
        // return url request
        
       // let url = URL(string: "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/12.4552%2C%2075.7027/2021-12-01/2021-12-31?unitGroup=metric&maxDistance=50000&elements=datetime%2Cprecip%2Cstations%2Csource&include=remote%2Cobs%2Cdays&key=4P4NBUCNQQKSRNENEM6CJNB88&contentType=json")
        
       // print(url!)
       
        return URLRequest(url: testURL)
        
    }
    
    func URLrequestForDailyRain(day:Int, month:Int, year:Int, latitude: Double, longitude: Double) -> URLRequest {
        
        // create date for which we want rainfall
         let rainDate = Helper.DateFromDayMonthYear(day: day, month: month, year: year)
        
        // convert date into string
       
        let startDateFormatter = DateFormatter()
        startDateFormatter.dateFormat = "yyyy'-'MM'-'dd"
        let rainDateString = startDateFormatter.string(from: rainDate)
        
        // creating VC timeline weather api
        var urlString = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/"
        
        // convert latitude and location to string
        let locationString = String(latitude) + "," + String(longitude)
        
        // add  location to urlString
        urlString = urlString + locationString + "/"
        
        // add date
        urlString = urlString + rainDateString
        
        // create an instance of url component
        var urlComponents = URLComponents(string: urlString)!
        
        // create query
        
        // item for units returns rainfall in mm
        let queryItemUnit = URLQueryItem(name: "unitGroup", value: "metric") // rainfall in mm
        // vc key for open source
        let queryItemKey = URLQueryItem(name: "key", value: "4P4NBUCNQQKSRNENEM6CJNB88")
        // daily historical observations
        let queryItemInclude = URLQueryItem(name: "include", value: "obs,days")
        // get rainfall for the day
        let queryItemElements = URLQueryItem(name: "elements", value: "datetime,precip")
        
        let queryItems = [queryItemUnit, queryItemKey, queryItemInclude, queryItemElements]

        urlComponents.queryItems = queryItems
        
        // url created
        let url = urlComponents.url!
        
        print(url)
       // let testURL = URL(string: "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/Bikaner/2022-07-01/2022-07-31?unitGroup=metric&elements=datetime%2Cprecip&include=days%2Cobs&key=4P4NBUCNQQKSRNENEM6CJNB88&contentType=json")
        // return url request
       // return URLRequest(url: url)
        
        // testing
        return URLRequest(url: url)
        
    }
    
    func FetchMonthlyRainInMM(month: Int, year: Int, latitude: Double, longitude: Double) async throws -> DisplayMonthRain {
        
        let request = CreateURLrequestFor(month: month, year: year, latitude: latitude, longitude: longitude)
        let (data, response) = try await URLSession.shared.data(for: request)
       
        // test
        // print(String(data: data, encoding: .utf8)!)
        
        guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                      DispatchQueue.main.async {
                          print("no data")
                          self.downloading = false
                      }
                throw DownloadError.invalidServerResponse
            }
        
        let deCoder = JSONDecoder()
        
        let decodedRainfall = try deCoder.decode(VCrainData.self, from: data)
        
        // save decoded data
        SaveRainfallData(result: decodedRainfall)
        
        DispatchQueue.main.async {
            // append the dailyraindata
            for dayCount in decodedRainfall.days {
                self.arrayOfDailyRain.append(DisplayDailyRain(day: dayCount.day, month: dayCount.month, year: dayCount.year, rainMM: dayCount.precip ?? 0.0)) // null rainfal in downloaded data is treated as zero rainfall
                // save to coredata
            }
            
        }
        
        // for testing
       /* for dayR in decodedRainfall.days {
            print("Rainfall on \(dayR.day) - \(dayR.month) - \(dayR.year) = ", dayR.precip ?? 0.0) // treating null rainfall as zero
        } */
        
        let totalRainInMonth = decodedRainfall.days.reduce(0) {$0 + ($1.precip ?? 0.0) }
        return DisplayMonthRain(month: month, year: year, monthRainMM:totalRainInMonth)
    }
    
    func FetchDailyRainInMM(day: Int, month: Int, year: Int, latitude: Double, longitude: Double) async throws -> DisplayDailyRain {
        
        let request = URLrequestForDailyRain(day: day, month: month, year: year, latitude: latitude, longitude: longitude)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // for testing
        print(String(data: data, encoding: .utf8)!)
        guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                      DispatchQueue.main.async {
                          print("no data")
                          self.downloading = false
                      }
                throw DownloadError.invalidServerResponse
            }
       
        let deCoder = JSONDecoder()
        
        let decodedRainfall = try deCoder.decode(VCrainData.self, from: data)
        
        
       /*  for dayR in decodedRainfall.days {
            print("Rainfall on \(day) - \(month) - \(year) = ", dayR.precip)
        } */
       // dummy return change it!!!!
        return DisplayDailyRain(day: 1, month: 1, year: 2022, rainMM: decodedRainfall.days[0].precip ?? 0.0)
    }
    
    func FetchAndSavePastFiveYearsDailyRainfall(latitude: Double, longitude: Double) async throws {
        
        
        // to be called only at the start of using SimTanka
        for year in baseYear - 5...baseYear - 1 {
            
            DispatchQueue.main.async {
               self.arrayOfMonthRain = []
            }
            
            for month in 1...12 {

                DispatchQueue.main.async {
                    self.downloadMsg = "Downloading rainfall for \(Helper.intMonthToShortString(monthInt: month))-\(year)"
                }
                
                let result = try await FetchMonthlyRainInMM(month: month, year: year, latitude: latitude, longitude: longitude)
                
                // save result to core data
                
                DispatchQueue.main.async {
                    
                    self.arrayOfMonthRain.append(result)
                   // print(result)
                }
            }
            
            DispatchQueue.main.async {
                let annualRain = self.arrayOfMonthRain.reduce(0){ $0 + $1.monthRainMM}
                self.arrayOfAnnualRain.append(DisplayAnnualRain(year: year, annualRainMM: annualRain))
            }
        }
        
        DispatchQueue.main.async {
            self.downloadMsg = "Finished downloading rainfall"
            self.rainRecordsAvailable = true
        }
    }
    
    func SaveRainfallData(result: VCrainData) {
        
        DispatchQueue.main.async {
            for day in result.days {
                
                // create a new record
                let newRecord = DailyRainVC(context: self.dbContext)
                
                // write in new record
                newRecord.day = day.day
                newRecord.month = day.month
                newRecord.year = day.year
                newRecord.dailyRainMM = day.precip ?? 0.0
                
                // try and save
                do {
                    try self.dbContext.save()
                } catch {
                    print("VC daily rainfall could not be saved")
                }
                
            }
        }
        
        
    }
    
    func LastFiveYearsAnnualRain() {
        // for displaying annual rainfall once it has been
        // down loaded
        
        // initialize
        DispatchQueue.main.async {
            self.downloadMsg = "Annual rainfall"
            self.arrayOfAnnualRain = []
        }
        
        
        // find current year
        let currentYear = Helper.CurrentYear()
        
        for year in currentYear - 5 ... currentYear - 1 {
            
            // find all dailyrain records with the given year
            let yearPredicate = NSPredicate(format: "year=%i", year)
            
            // apply the filter
            let dayForYearArray = self.dailyRainArrayCD.filter( {
                day in
                yearPredicate.evaluate(with: day)
            })
            
            // add up the rainfall
            let annualRainInMM = dayForYearArray.reduce(0){ $0 + $1.dailyRainMM}
            let newDisplayRecord = DisplayAnnualRain(year: year, annualRainMM: annualRainInMM)
            
            DispatchQueue.main.async {
                self.arrayOfAnnualRain.append(newDisplayRecord)
            }
        }
        
        
    }
    
    
    
    enum DownloadError: Error {
        
        case invalidServerResponse
        case noResult
        
    }
    
}

extension DownloadRainfallFromVC {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        guard let fetchedRainfall = controller.fetchedObjects as? [DailyRainVC] else {
            return
        }
        dailyRainArrayCD = fetchedRainfall
    }
}


// model for storing decoded JSON data from Visual Crossing
struct VCdailyRain: Decodable {
    let datetime : String
    let precip : Double?
    
    // computed properties to extract year, month and day from datetime
    // datetime e.g:2021-12-01
    
    var year: Int32 {
        let yearString = datetime.dropLast(6)
        return Int32(yearString)!
    }
    
    var month: Int32 {
        let start = datetime.index(datetime.startIndex, offsetBy: 5)
        let end = datetime.index(datetime.endIndex, offsetBy: -3)
        let range = start..<end
        let subString = datetime[range]
        return Int32(subString)!
    }
    
    var day: Int32 {
        let dayString = datetime.dropFirst(8)
        return Int32(dayString)!
    }
}

struct VCrainData: Decodable {
    let days : [VCdailyRain]
}

struct DisplayDailyRain: Identifiable {
    let id = UUID()
    let day : Int32
    let month : Int32
    let year : Int32
    let rainMM : Double
}

struct DisplayMonthRain: Identifiable {
    let id = UUID()
    let month : Int
    let year : Int
    let monthRainMM : Double
    
}

struct DisplayAnnualRain: Identifiable {
    let id = UUID()
    let year : Int
    let annualRainMM : Double
}

