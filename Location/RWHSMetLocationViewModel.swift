//
//  RWHSMetLocationViewModel.swift
//  SimTanka-iOS
//
//  Created by Vikram Vyas on 02/11/22.
//
// Released under
// GNU General Public License v3.0 or later
// https://www.gnu.org/licenses/gpl-3.0-standalone.html

import Foundation

enum Locations:Int, CaseIterable, Hashable {
    case CurrentLocation = 0
    case UserProvided = 1
    
    init(locationType: Int) {
        switch locationType {
        case 0: self = .CurrentLocation
        case 1: self = .UserProvided
        default: self = .CurrentLocation
        }
    }
    
    var text: String {
        switch self {
        case .CurrentLocation : return "Use current location"
        case .UserProvided : return "Enter the location"
        }
    }
}
