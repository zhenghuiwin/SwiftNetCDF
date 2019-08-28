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
    
    public init( latitudeName: String,
                 longitudeName: String,
                 missingValueName: String,
                 scaleFactorName: String,
                 offsetName: String,
                 filePath: String) throws {
        
        let ret = nc_open(filePath, NC_NOWRITE, &ncId)
        try NCFile.checkFile(result: ret)
        
        latitudeVals  = try NCFile.coordinates(name: latitudeName,  ncId: ncId)
        longitudeVals = try NCFile.coordinates(name: longitudeName, ncId: ncId)
        
        self.latitudeName = latitudeName
        self.longitudeName = longitudeName
        
        self.missingValueName = missingValueName
        self.scaleFactorName = scaleFactorName
        self.offsetName = offsetName
    }
    
    deinit {
        nc_close(ncId)
    }
    
    
    // MARK: --- FOR TEST ---
    public func test (variable: String) throws {
        
        let d1: Double = 123.009
        let d2: Double = 123.001
        
    
        
        print("\(NCFileUtils.isEqual(double1: d1, double2: d2))")
        
        let varId   = try variableId(ncId: ncId, variable: variable)
        
//        var no_fill: Int32 = 1
//        var fill_valuep: Any = 0
//        let ret = nc_inq_var_fill(ncId, varId, &no_fill, &fill_valuep)
        var missingVal: Double = 0
        let ret = nc_get_att_double(ncId, varId, "missing_value", &missingVal)
        
        try NCFile.checkVariable(result: ret)
        
        print("All is good!")
//        print("no_fill: \(no_fill)")
        print("missingVal: \(missingVal)")
        
    }
    
    
    // MARK: --- Public Functions ---
    
    public func value(for variable: String, at point: Coordinate) throws -> Double {
        
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
                varId: varId
        )
        
        let val: Double = interpolationRect.interpolate(point: point)
        
        let scale  = try variableScaleFctor(varId: varId, scaleName: scaleFactorName)
        let offset = try variableOffset(varId: varId, offsetName: offsetName)
        
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
    
    private func variableMissingValue(varId: Int32, misName: String) throws -> Double {
        var misVal: Double = 0
        let ret = nc_get_att_double(ncId, varId, misName, &misVal)
        try NCFile.checkVariable(result: ret)
        
        return misVal
    }
    
    private func variableScaleFctor(varId: Int32, scaleName: String) throws -> Double {
        var scale: Double = 0
        let ret = nc_get_att_double(ncId, varId, scaleName, &scale)
        try NCFile.checkVariable(result: ret)
        
        return scale
    }
    
    private func variableOffset(varId: Int32, offsetName: String) throws -> Double {
        var offset: Double = 0
        let ret = nc_get_att_double(ncId, varId, offsetName, &offset)
        try NCFile.checkVariable(result: ret)
        
        return offset
    }
    
    
    private func interpolationArea(latsIndex: (Int, Int),
                                   lonIndex: (Int, Int),
                                   varId: Int32) throws -> GridCell {
        
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
        
        
        let misVal = try variableMissingValue(varId: varId, misName: missingValueName)
        
        guard 
            let val00: Double = (try values(
                varId: varId,
                start: [0, lat0.index, lon0.index],
                count: [1, 1, 1], size: 1)
            ).first,
            !NCFileUtils.isEqual(double1: val00, double2: misVal) 
        else {
            throw VariableError.invalidValue("Failed to get the val00!")
        }
        
        guard 
            let val01: Double = (try values(
                varId: varId,
                start: [0, lat0.index, lon1.index],    // [0, latsIndex.0, lonIndex.1],
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
                start: [0, lat1.index, lon0.index], //[0, latsIndex.1, lonIndex.0],
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
                start: [0, lat1.index, lon1.index], //[0, latsIndex.1, lonIndex.1],
                count: [1, 1, 1],
                size: 1)
            ).first,
            !NCFileUtils.isEqual(double1: val11, double2: misVal) 
        else {
            throw VariableError.invalidValue("Failed to get the val11!")
        }
        
        // TODO: FOR TEST, TO BE DELETED
        print("00 -> [ \(val00), \(coord00.latitude), \(coord00.longitude) ]")
        print("01 -> [ \(val01), \(coord01.latitude), \(coord01.longitude) ]")
        print("10 -> [ \(val10), \(coord10.latitude), \(coord10.longitude) ]")
        print("11 -> [ \(val11), \(coord11.latitude), \(coord11.longitude) ]")
        // TODO: END FOR TEST, TO BE DELETED
        
        let p00 = NCPoint(coordinate: coord00, value: val00)  
        let p01 = NCPoint(coordinate: coord01, value: val01)
        let p10 = NCPoint(coordinate: coord10, value: val10)
        let p11 = NCPoint(coordinate: coord11, value: val11)
        
        return GridCell(point00: p00, point10: p10, point01: p01, point11: p11)
    }
    
    
    // MARK: --- Static Functions ---
    
    private static func coordinates(name: String, ncId: Int32) throws -> [Double] {
        var varId: Int32 = -1
        
        var ret = nc_inq_varid(ncId, name, &varId)
        try checkVariable(result: ret)
        
        var len: size_t = 0
        ret = nc_inq_dimlen(ncId, varId, &len)
        try checkVariable(result: ret)
        
        guard len > 0 else {
            throw VariableError.invalidValue("The length of \(name) is less or equal to 0.")
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
        case NC_EBADDIM:
            throw VariableError.invalidDimensionID("Invalid dimension ID or name.")
        case NC_ENOTVAR:
            throw VariableError.variableNotFound("Variable not found.")
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
