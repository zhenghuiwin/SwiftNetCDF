//
//  InterpolationRect.swift
//  Swift-NetCDF
//
//  Created by zhenghuiwin on 2019/4/8.
//

import Foundation

public struct GridCell {
    // lat0, lon0
    let point00: NCPoint
    // lat1, lon0
    let point10: NCPoint
    // lat0, lon1
    let point01: NCPoint
    // lat1, lon1
    let point11: NCPoint
    
    var width: Double {
        return abs(point01.x - point00.x)
    }
    
    var height: Double {
        return abs(point10.y - point00.y)
    }
    
    public init(point00: NCPoint, point10: NCPoint, point01: NCPoint, point11: NCPoint) {
        self.point00 = point00
        self.point10 = point10
        self.point01 = point01
        self.point11 = point11
        
        print("00: \(point00.value), 10: \(point10.value), 01: \(point01.value), 11: \(point11.value)")
    }
    
    func interpolate(point: Coordinate) -> Double {
        let latY = WebMercator.latitudeToY(latitude: point.latitude)
        let lonX = WebMercator.longitudeToX(longitude: point.longitude)
        
        let rationForLatY: Double = (latY - point00.y) / self.height
        let rationForLonX: Double = (lonX - point00.x) / self.width
        
        // fyx = f00 * ( 1 - x ) * ( 1 - y ) + f10 * y * ( 1 - x ) + f01 * ( 1 - y ) * x + f11 * x*y
        let interpolateValue: Double = 
              point00.value * ( 1 - rationForLatY ) * ( 1 - rationForLonX )
            + point10.value * rationForLatY * ( 1 - rationForLonX )
            + point01.value * ( 1 - rationForLatY ) * rationForLonX
            + point11.value * rationForLatY * rationForLonX
        
        // TODO: TO BE DELETE
//        print("00: \(point00.value) -> (\(point00.y),\(point00.x)), \n 01: \(point01.value) -> (\(point01.y),\(point01.x)), \n 10: \(point10.value) -> (\(point10.y),\(point10.x)), \n 11: \(point11.value) -> (\(point11.y),\(point11.x))")
        // TODO: END
        
        return interpolateValue
    }
    
    
}
