//
//  NCPoint.swift
//  Swift-NetCDF
//
//  Created by zhenghuiwin on 2019/4/4.
//

import Foundation

public struct NCPoint {
    let coordinate: Coordinate
    let x: Double
    let y: Double
    let value: Double
    
    public init(coordinate: Coordinate, value: Double) {
        self.coordinate = coordinate
        self.y = WebMercator.latitudeToY(latitude: coordinate.latitude)
        self.x = WebMercator.longitudeToX(longitude: coordinate.longitude)
        self.value = value
    }
}
