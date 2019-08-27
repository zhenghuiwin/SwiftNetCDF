//
//  NCFileUtil.swift
//  Swift-NetCDF
//
//  Created by zhenghuiwin on 2019/4/6.
//

import Foundation

public class NCFileUtils {
    
    
    /// Find the minimum neighbor range for specified point in array.
    /// The array must be sorted in ascending or descending.
    ///
    /// - Parameters:
    ///   - point: It is in the minimum neighbor range.
    ///   - array: The array be sorted in ascending or descending.
    /// - Returns: (left: Int, right: Int): the minimum neighbor range for specified point in array,
    ///            or return nil if the point does not belong the range of the array.
    /// - Throws: VariableError.invalidValue, LogicError.logicError
    public static func neighborRange(at point: Double, in array: [Double]) throws -> (left: Int, right: Int)? {
        
        guard array.count > 0  else {
            throw VariableError.invalidValue("The count of parameter array is less than 0.")
        }
        
        var ascendingArray = array
        // The values of array are latitude or longitude in the NC File,
        // and they are stored either in ascending or descending.
        // Here we should make sure they are all stored in ascending.
        var isReversed = false
        if ascendingArray.last!.isLess(than: ascendingArray.first!) {
            isReversed = true
            ascendingArray.reverse()
        }
        
        var lidx: Int = 0
        var ridx: Int = ascendingArray.count - 1
        while lidx < ridx {
            let midx: Int = Int( ceil(Float(ridx + lidx) / 2.0) )
            if point.isLess(than: ascendingArray[midx]) {
                if ascendingArray[midx - 1].isLessThanOrEqualTo(point) {
                    // midx - 1  <= position of point < midx
                    lidx = midx - 1
                    ridx = lidx
                    break
                }
                ridx = midx - 1
            } else {
                // midx <= position of point <= position of last element
                lidx = midx
            }
        }
        
        guard lidx == ridx else {
            throw LogicError.logicError("left index is not equal right index.")
        }
        
        if ascendingArray[lidx].isLessThanOrEqualTo(point) {
            
            var result = (left: lidx, right: lidx + 1)
            
            let end = ascendingArray.count - 1
            if lidx == end {
                result = (left: lidx - 1, right: lidx)
            }
            
            if isReversed {
                // If we reversed the array, we should calculate the index in the original array
                if result.left != 0 && ascendingArray[result.left].isEqual(to: point) {
                    result.right = result.left
                    result.left = result.left - 1
                }
                
                return (left: end - result.right, right: end - result.left)
            }
            
            return result
        }
        
        return nil
    }
    
    public static func isEqual(double1: Double, double2: Double) -> Bool {
        return abs(double1).distance(to: abs(double2)) <= 0.01
    }
}
