//
//  VariableError.swift
//  Swift-NetCDF
//
//  Created by zhenghuiwin on 2019/3/29.
//

import Foundation

public enum VariableError: Error {
    case badNcid(String)
    case invalidVariableID(String)
    case invalidDimensionID(String)
    case variableNotFound(String)
    case outOfrange(String)
    case operationNotAllowed(String)
    case invalidValue(String)
}

enum LogicError: Error {
    case logicError(String)
}
