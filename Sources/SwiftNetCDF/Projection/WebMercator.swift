//
//  WebMercator.swift
//  Swift-NetCDF
//
//  Created by zhenghuiwin on 2019/4/13.
//

import Foundation

public class WebMercator {
    
    public static let DEGREES_PER_RADIANS = 180.0 / Double.pi
    public static let RADIANS_PER_DEGREES = Double.pi / 180.0
    public static let PI_OVER_2 = Double.pi / 2.0
    public static let RADIUS = 6378137.0
    public static let RADIUS_2 = RADIUS * 0.5
    public static let RAD_RAD = RADIANS_PER_DEGREES * RADIUS
    
    
    
    /// Convert geo lat to vertical distance in meters.
    ///
    /// - Parameter latitude: The latitude in decimal degrees.
    /// - Returns:            The vertical distance in meters.
    public static func latitudeToY(latitude: Double) -> Double {
        let rad = latitude * RADIANS_PER_DEGREES
        let sin_d = sin(rad)
        
        return RADIUS_2 * log((1.0 + sin_d) / (1.0 - sin_d))
    }
    
    
    /// Convert geo lon to horizontal distance in meters.
    ///
    /// - Parameter longitude: The longitude in decimal degrees.
    /// - Returns:             The horizontal distance in meters.
    public static func longitudeToX(longitude: Double) -> Double {
        return longitude * RAD_RAD
    }
    
    
    
    /// Convert horizontal distance in meters to longitude in decimal degress.
    ///
    /// - Parameter x: The horizontal distance in meters.
    /// - Returns:     The longitude in decimal degrees.
    public static func xToLongitude(x: Double) -> Double {
        return xToLongitude(x, linear: true)
    }
    
    
    
    /// Convert horizontal distance in meters to longitude in decimal degress.
    ///
    /// - Parameters:
    ///   - x:      The horizontal distance in meters.
    ///   - linear: If using continuous pan.
    /// - Returns:  The longitude in decimal degrees.
    public static func xToLongitude(_ x: Double, linear: Bool) -> Double {
        let rad = x / RADIUS
        let deg = rad * DEGREES_PER_RADIANS
        
        if linear {
            return deg;
        }
        
        let rotations = floor((deg + 180.0) / 360.0)
        
        return deg - (rotations * 360.0)
    }
    
    
    /// Convert vertical distance in meters to latitude in decimal degress.
    ///
    /// - Parameter y: The vertical distance in meters.
    /// - Returns:     The latitude in decimal degrees.
    public static func yToLatitude(_ y: Double) -> Double {
        let rad = PI_OVER_2 - ( 2.0 * atan( exp(-1.0 * y / RADIUS) ) )
        return rad * DEGREES_PER_RADIANS
    }
}
