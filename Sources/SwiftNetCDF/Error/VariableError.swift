//
//  VariableError.swift
//  Swift-NetCDF
//
//  Created by zhenghuiwin on 2019/3/29.
//

import Foundation

public enum VariableError: Error {
    case badNcid(String)
    case badName(String)
    case invalidVariableID(String)
    case invalidDimensionID(String)
    case invalidParameters(String)
    case invalidAttribute(String)
    case faildConvertToChar(String)
    case outOfMemory(String)
    case variableNotFound(String)
    case outOfrange(String)
    case operationNotAllowed(String)
    case invalidValue(String)
}

enum LogicError: Error {
    case logicError(String)
}
