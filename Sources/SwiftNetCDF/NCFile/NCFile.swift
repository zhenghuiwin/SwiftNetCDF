//
//  NCFile.swift
//  Swift-NetCDF
//
//  Created by zhenghuiwin on 2019/3/28.
//

import Foundation
import Cnetcdf

public class NCFile {
    
    private static let missingType: Double =  999999
    
    private var ncId: Int32 = -1
    
    private let latitudeName: String
    private let longitudeName: String
    
    private let latitudeVals:  [Double]
    private let longitudeVals: [Double]
    
    private let missingValueName: String
    private let scaleFactorName: String
    private let offsetName: String
    
    public init(    latitudeName: String,
                    latitudeSize: Int = 0,
                   longitudeName: String,
                   longitudeSize: Int = 0,
                missingValueName: String,
                scaleFactorName : String,
                      offsetName: String,
                        filePath: String) throws {
        
        let ret = nc_open(filePath, NC_NOWRITE, &ncId)
        try NCFile.checkFile(result: ret)
        
        
        latitudeVals  = try NCFile.coordinates(name: latitudeName,  varSize: latitudeSize,  ncId: ncId)
        longitudeVals = try NCFile.coordinates(name: longitudeName, varSize: longitudeSize, ncId: ncId)

        
        self.latitudeName  = latitudeName
        self.longitudeName = longitudeName
        
        self.missingValueName = missingValueName
        self.scaleFactorName  = scaleFactorName
        self.offsetName       = offsetName
    }
    
    deinit {
        nc_close(ncId)
    }
    
    
    // MARK: --- Public Functions ---
    
    /// Get the value of variable at a position at specified time
    /// - Parameter variable: The name of variable.
    /// - Parameter point: The position used to get the value of variable.
    /// - Parameter time: The time dimension which starts at 0.
    public func value(for variable: String, at point: Coordinate, atTime time: Int = 0) throws -> Double {
        
        // Check the coordinate is in the area of the NCFile data set
        guard ( latitudeVals.first!.isLessThanOrEqualTo(point.latitude) &&
                point.latitude.isLessThanOrEqualTo(latitudeVals.last!) ||
                latitudeVals.last!.isLessThanOrEqualTo(point.latitude) &&
                point.latitude.isLessThanOrEqualTo(latitudeVals.first!)
              ),
              ( longitudeVals.first!.isLessThanOrEqualTo(point.longitude) &&
                point.longitude.isLessThanOrEqualTo(longitudeVals.last!) ||
                longitudeVals.last!.isLessThanOrEqualTo(point.longitude) &&
                point.longitude.isLessThanOrEqualTo(longitudeVals.first!)
              ) else {
              throw VariableError.invalidValue("The input values of coordinate is invalid.")
        }
        
        
        guard let latRange = try NCFileUtils.neighborRange(
            at: point.latitude,
            in: latitudeVals) 
        else {
            throw VariableError.invalidValue("Failed to get the range for point in latitude")
        }
        
        guard let lonRange = try NCFileUtils.neighborRange(
            at: point.longitude,
            in: longitudeVals) 
        else {
            throw VariableError.invalidValue("Failed to get the range for point in longitude.")
        }
        
        let varId  = try variableId(ncId: ncId, variable: variable)
        
        let interpolationRect: GridCell = try interpolationArea(
            latsIndex: latRange,
             lonIndex: lonRange,
                varId: varId,
                 time: time
        )
        
        let val: Double = interpolationRect.interpolate(point: point)
        
        let scale  = variableScaleFctor(varId: varId, scaleName: scaleFactorName)
        let offset = variableOffset(varId: varId, offsetName: offsetName)
        
        return val * scale + offset
    }
    
    
    
    public func values(varId: Int32, start: [Int], count: [Int], size: Int) throws -> [Double] {
        
        let varType = try variableType(ncId: ncId, varId: varId)
        
        var output: [Double] = []
        
        if varType == NC_SHORT {
            let vals: UnsafeMutablePointer<CShort> = UnsafeMutablePointer.allocate(capacity: size)
            let ret = nc_get_vara_short(ncId, varId, start, count, vals)
            try NCFile.checkVariable(result: ret)
            
            for i in 0 ..< size {
                output.append(Double(vals[i]))
            }
        } else if varType == NC_FLOAT {
            let vals: UnsafeMutablePointer<Float> = UnsafeMutablePointer.allocate(capacity: size)
            let ret = nc_get_vara_float(ncId, varId, start, count, vals)
            try NCFile.checkVariable(result: ret)
            
            for i in 0 ..< size {
                output.append(Double(vals[i]))
            }
        } else if varType == NC_DOUBLE {
            let vals: UnsafeMutablePointer<Double> = UnsafeMutablePointer.allocate(capacity: size)
            let ret = nc_get_vara_double(ncId, varId, start, count, vals)
            try NCFile.checkVariable(result: ret)
            
            for i in 0 ..< size {
                output.append(Double(vals[i]))
            }
        } else {
            throw NCFileError.noCorrespondingType("No corresponding type for variable: \(varId): \(varType)")
        }
        
        return output
    }
    
    // MARK: --- Private Functions ---
    
    private func variableId(ncId: Int32, variable: String) throws -> Int32 {
        var varId: Int32 = 0
        let ret = nc_inq_varid(ncId, variable, &varId)
        try NCFile.checkVariable(result: ret)
        
        return varId
    }
    
    private func variableType(ncId: Int32, varId: Int32) throws -> Int32 {
        var type: Int32 = 0
        let ret = nc_inq_vartype(ncId, varId, &type)
        try NCFile.checkVariable(result: ret)
        
        return type
    }
    
    private func variableMissingValue(varId: Int32, misName: String) -> Double {
        var misVal: Double = 9999
        let ret = nc_get_att_double(ncId, varId, misName, &misVal)
        do {
            try NCFile.checkVariable(result: ret)
        } catch let e {
            print("Failed to find missing value of this file: \(e)")
        }
        
        return misVal
    }
    
    private func variableScaleFctor(varId: Int32, scaleName: String) -> Double {
        var scale: Double = 0
        let ret = nc_get_att_double(ncId, varId, scaleName, &scale)
        do {
            try NCFile.checkVariable(result: ret)
            return scale
        } catch let e {
            print("Failed to find \(scaleName): \(e)")
            return 1.0
        }
    }
    
    private func variableOffset(varId: Int32, offsetName: String) -> Double {
        var offset: Double = 0
        let ret = nc_get_att_double(ncId, varId, offsetName, &offset)
        
        do {
            try NCFile.checkVariable(result: ret)
            return offset
        } catch let e {
            print("Failed to find \(offsetName): \(e)")
            return 0
        }
    }
    
    
    private func interpolationArea(latsIndex: (Int, Int),
                                   lonIndex: (Int, Int),
                                   varId: Int32,
                                   time: Int = 0) throws -> GridCell {
        
        let latLeft  = latitudeVals[latsIndex.0]
        let latRight = latitudeVals[latsIndex.1]

//        let lat0 = min(latLeft, latRight)
//        let lat1 = max(latLeft, latRight)
        var lat0: (lat: Double, index: Int) = (0,0)
        var lat1: (lat: Double, index: Int) = (0,0)
        if latLeft <= latRight {
            lat0 = (lat: latLeft,  index: latsIndex.0)
            lat1 = (lat: latRight, index: latsIndex.1)
        } else {
            lat0 = (lat: latRight, index: latsIndex.1)
            lat1 = (lat: latLeft,  index: latsIndex.0)
        }
        
//        let lon0 = min(lonLeft, lonRight)
//        let lon1 = max(lonLeft, lonRight)
        let lonLeft  = longitudeVals[lonIndex.0]
        let lonRight = longitudeVals[lonIndex.1]
        
        var lon0: (lon: Double, index: Int) = (0, 0)
        var lon1: (lon: Double, index: Int) = (0, 0)
        if lonLeft <= lonRight {
            lon0 = (lon: lonLeft,  index: lonIndex.0)
            lon1 = (lon: lonRight, index: lonIndex.1)
        } else {
            lon0 = (lon: lonRight, index: lonIndex.1)
            lon1 = (lon: lonLeft,  index: lonIndex.0)
        }
        
        
        
        let coord00 = Coordinate(latitude: lat0.lat, longitude: lon0.lon)
        let coord01 = Coordinate(latitude: lat0.lat, longitude: lon1.lon)
        let coord10 = Coordinate(latitude: lat1.lat, longitude: lon0.lon)
        let coord11 = Coordinate(latitude: lat1.lat, longitude: lon1.lon)
        
        
        let misVal = variableMissingValue(varId: varId, misName: missingValueName)
        
        guard 
            let val00: Double = (try values(
                varId: varId,
                start: [time, lat0.index, lon0.index],
                count: [1, 1, 1], size: 1)
            ).first,
            !NCFileUtils.isEqual(double1: val00, double2: misVal) 
        else {
            throw VariableError.invalidValue("Failed to get the val00!")
        }
        
        guard 
            let val01: Double = (try values(
                varId: varId,
                start: [time, lat0.index, lon1.index],    // [0, latsIndex.0, lonIndex.1],
                count: [1, 1, 1],
                size: 1)
            ).first,
            !NCFileUtils.isEqual(double1: val01, double2: misVal) 
        else {
            throw VariableError.invalidValue("Failed to get the val01!")
        }
        
        guard 
            let val10: Double = (try values(
                varId: varId,
                start: [time, lat1.index, lon0.index], //[0, latsIndex.1, lonIndex.0],
                count: [1, 1, 1],
                size: 1)
            ).first,
            !NCFileUtils.isEqual(double1: val10, double2: misVal) 
        else {
            throw VariableError.invalidValue("Failed to get the val10!")
        }
        
        guard 
            let val11: Double = (try values(
                varId: varId,
                start: [time, lat1.index, lon1.index], //[0, latsIndex.1, lonIndex.1],
                count: [1, 1, 1],
                size: 1)
            ).first,
            !NCFileUtils.isEqual(double1: val11, double2: misVal) 
        else {
            throw VariableError.invalidValue("Failed to get the val11!")
        }
        
        // TODO: FOR TEST, TO BE DELETED
        print("00 -> [ \(val00) at [ \(coord00.latitude), \(coord00.longitude) ] ]")
        print("01 -> [ \(val01) at [ \(coord01.latitude), \(coord01.longitude) ] ]")
        print("10 -> [ \(val10) at [ \(coord10.latitude), \(coord10.longitude) ] ]")
        print("11 -> [ \(val11) at [ \(coord11.latitude), \(coord11.longitude) ] ]")
        // TODO: END FOR TEST, TO BE DELETED
        
        let p00 = NCPoint(coordinate: coord00, value: val00)  
        let p01 = NCPoint(coordinate: coord01, value: val01)
        let p10 = NCPoint(coordinate: coord10, value: val10)
        let p11 = NCPoint(coordinate: coord11, value: val11)
        
        return GridCell(point00: p00, point10: p10, point01: p01, point11: p11)
    }
    
    
    // MARK: --- Static Functions ---
    
    private static func coordinates(name: String, varSize: Int, ncId: Int32) throws -> [Double] {
        var varId: Int32 = -1
        
        var ret = nc_inq_varid(ncId, name, &varId)
        try checkVariable(result: ret)
        
        var len: size_t = 0
        ret = nc_inq_dimlen(ncId, varId, &len)
        do {
            try checkVariable(result: ret)
        } catch let e {
            print("Failed to get size of [\(name)]: \(e). Will using the varSize: [\(varSize)].")
            len = varSize
        }
        
        len = max(len, varSize)
        
        guard len > 0 else {
            throw VariableError.invalidValue("The length of [\(name)] is less or equal to 0.")
        }

        var values: [Double] = Array(repeating: NCFile.missingType, count: len)
        
        ret = nc_get_var_double(ncId, varId, &values)
        try checkVariable(result: ret)
        
        return values
    }
    
    private static func checkVariable(result: Int32) throws {
        switch result {
        case NC_NOERR:
            return
        case NC_EBADID:
            throw VariableError.badNcid("Bad ncid.")
        case NC_ENOTVAR:
            throw VariableError.invalidVariableID("Invalid variable ID.")
        case NC_EBADNAME:
            throw VariableError.badName("Bad name. See object_name.")
        case NC_EINVAL:
            throw VariableError.invalidParameters("Invalid parameters.")
        case NC_ENOTATT:
            throw VariableError.invalidAttribute("Can not find attribute.")
        case NC_ECHAR:
            throw VariableError.faildConvertToChar("Can not convert to or from NC_CHAR.")
        case NC_ENOMEM:
            throw VariableError.outOfMemory("Out of memory.")
        case NC_EBADDIM:
            throw VariableError.invalidDimensionID("Invalid dimension ID or name.")
        case NC_ERANGE:
            throw VariableError.outOfrange("One or more of the values are out of range.")
        case NC_EINDEFINE:
            throw VariableError.operationNotAllowed("Operation not allowed in define mode.")
        default:
            print("CheckVariable: No case be matched .")
            return
        }
    }
    
    private static func checkFile(result: Int32) throws {
        switch result {
        case NC_NOERR:
            return
        case NC_EPERM:
           throw NCFileError.noPermissionError(" Attempting to create a netCDF file in a directory where you do not have permission to open files")
        case NC_ENFILE:
            throw NCFileError.tooManyFilesOpenError("Too many files open")
        case NC_ENOMEM:
            throw NCFileError.outOfMemoryError("Out of memory.")
        case NC_EHDFERR:
            throw NCFileError.HDF5Error("HDF5 error.")
        case NC_EDIMMETA:
            throw NCFileError.dimmetaError("Error in netCDF-4 dimension metadata.")
        default:
            print("CheckFile: No Error case be matched .")
            return
        }
    }
    
    
}
