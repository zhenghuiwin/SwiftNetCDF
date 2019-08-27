//
//  Coordinate.swift
//  Swift-NetCDF
//
//  Created by zhenghuiwin on 2019/3/30.
//

import Foundation

public struct Coordinate {
    let latitude: Double
    let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
