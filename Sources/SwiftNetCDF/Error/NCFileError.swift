//
//  NCFileError.swift
//  Swift-NetCDF
//
//  Created by zhenghuiwin on 2019/3/28.
//

import Foundation

public enum NCFileError: Error {
    case noPermissionError(String)
    case tooManyFilesOpenError(String)
    case outOfMemoryError(String)
    case HDF5Error(String)
    case dimmetaError(String)
    case noCorrespondingType(String)
}
