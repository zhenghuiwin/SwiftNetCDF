import XCTest
@testable import SwiftNetCDF

final class SwiftNetCDFTests: XCTestCase {

    private let ncPath = "../MSP1_PMSC_ELEH_ME_L88_CHN_201808211600_00000-00000.nc"
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftNetCDF().text, "Hello, World!")
    }

    func test01() {
        XCTAssertTrue(FileManager.default.fileExists(atPath: ncPath))
    }
    
    func test02() {
        // tem[lat, lon]
        let tem00 = 23.0 // 37.11026  78.75744
        let coordi00 = Coordinate(latitude:  37.11026, longitude: 78.75744)
        let ncpoint00 = NCPoint(coordinate: coordi00, value: 23.0)
        
        let tem01 = 23.2 // 37.11026  78.76744
        let coordi01 = Coordinate(latitude:  37.11026, longitude: 78.76744)
        let ncpoint01 = NCPoint(coordinate: coordi01, value: 23.2)
        
        let tem10 = 23.6 // 37.12026  78.75744
        let coordi10 = Coordinate(latitude:  37.12026, longitude: 78.75744)
        let ncpoint10 = NCPoint(coordinate: coordi10, value: 23.6)
        
        let tem11 = 23.4 // 37.12026  78.76744
        let coordi11 = Coordinate(latitude:  37.12026, longitude: 78.76744)
        let ncpoint11 = NCPoint(coordinate: coordi11, value: 23.4)
        
        
        
        let cell = GridCell(point00: ncpoint00, point10: ncpoint10, point01: ncpoint01, point11: ncpoint11)
        
        let coordi200 = Coordinate(latitude: 37.11900, longitude: 78.76500)
        let ival200 = cell.interpolate(point: coordi200)
//        print("ival200: \(ival200)")
        
        XCTAssertGreaterThanOrEqual(ival200, 23.0)
        XCTAssertLessThanOrEqual(ival200,    23.6)
        
        let coordi201 = Coordinate(latitude: 37.12000, longitude: 78.76000)
        let ival201 = cell.interpolate(point: coordi201)
//        print("ival201: \(ival201)")
        
        XCTAssertGreaterThanOrEqual(ival201, 23.0)
        XCTAssertLessThanOrEqual(ival201,    23.6)
        
        
        let coordi202 = Coordinate(latitude: 37.11026, longitude: 78.76500)
        let ival202 = cell.interpolate(point: coordi202)
//        print("ival202: \(ival202)")
        
        XCTAssertGreaterThanOrEqual(ival202, 23.0)
        XCTAssertLessThanOrEqual(ival202,    23.6)
        
        
        let coordi203 = Coordinate(latitude: 37.12000, longitude: 78.76744)
        let ival203 = cell.interpolate(point: coordi203)
//        print("ival203: \(ival203)")
        
        XCTAssertGreaterThanOrEqual(ival203, 23.0)
        XCTAssertLessThanOrEqual(ival203,    23.6)
        
        
        
        
        let ival00 = cell.interpolate(point:  coordi00)
//        print("原始: \(tem00) -> \(ival00)")
        XCTAssertEqual(ival00, tem00, accuracy: 0.001)
        
        let ival01 = cell.interpolate(point:  coordi01)
//        print("原始: \(tem01) -> \(ival01)")
        XCTAssertEqual(ival01, tem01, accuracy: 0.001)
        
        
        let ival10 = cell.interpolate(point:  coordi10)
//        print("原始: \(tem10) -> \(ival10)")
        XCTAssertEqual(ival10, tem10, accuracy: 0.001)
        
        let ival11 = cell.interpolate(point:  coordi11)
//        print("原始: \(tem11) -> \(ival11)")
        XCTAssertEqual(ival11, tem11, accuracy: 0.001)
    }

    func test03() {
        do {
            let file = try NCFile(
                    latitudeName: "lat",
                   longitudeName: "lon",
                missingValueName: "missing_value",
                 scaleFactorName: "scale_factor",
                      offsetName: "add_offset",
                        filePath: ncPath
            )
            
            let tem00 = 23.0 // 37.11026  78.75744
            let coordi00 = Coordinate(latitude:  37.11026, longitude: 78.75744)
            
            let tem01 = 23.2 // 37.11026  78.76744
            let coordi01 = Coordinate(latitude:  37.11026, longitude: 78.76744)
            
            let tem10 = 23.6 // 37.12026  78.75744
            let coordi10 = Coordinate(latitude:  37.12026, longitude: 78.75744)
            
            let tem11 = 23.4 // 37.12026  78.76744
            let coordi11 = Coordinate(latitude:  37.12026, longitude: 78.76744)

           
            let accuracyValue = 0.001
            
            let temValue0 = try file.value(for: "TEM", at: coordi00)
            XCTAssertEqual(temValue0, tem00, accuracy: accuracyValue)
            print("test03: Target: \(tem00)  Value: \(temValue0)")
            
            let temValue1 = try file.value(for: "TEM", at: coordi01)
            XCTAssertEqual(temValue1, tem01, accuracy: accuracyValue)
            print("test03: Target: \(tem01)  Value: \(temValue1)")
            
            let temValue2 = try file.value(for: "TEM", at: coordi10)
            XCTAssertEqual(temValue2, tem10, accuracy: accuracyValue)
            print("test03: Target: \(tem10)  Value: \(temValue2)")
            
            let temValue3 = try file.value(for: "TEM", at: coordi11)
            XCTAssertEqual(temValue3, tem11, accuracy: accuracyValue)
            print("test03: Target: \(tem11)  Value: \(temValue3)")

//
//            print("23.0 -> \(temValue0),23.2 -> \(temValue1), 23.6 -> \(temValue2), 23.4 -> \(temValue3)")

        } catch {
            print("Encount Error!")
        }
    }
    
    func test0401() {
        //lat 28.6  lon 97.6
        print("--- test0401 ----")
//        let path = "/Users/zhenghuiwin/tools/test.nc"
//        let path = "/Users/zhenghuiwin/Dropbox/workspace/swift_on_server/NetCDF_Swift/SwiftNetCDF/data_v.nc"
        let path = "./data_v.nc"
        if FileManager.default.fileExists(atPath: path) {
            print("\(path) existed.")
        } else {
            print("\(path) is not existed.")
            return
        }
        
        do {
            let file = try NCFile(
                 latitudeName: "latitude",
                longitudeName: "longitude",
             missingValueName: "missing_value",
              scaleFactorName: "scale_factor",
                   offsetName: "add_offset",
                filePath: path
            )
            print("Opened file.")
            
            // lat=30.65089&lon=104.07572
            print("--- Will get value.")
//            let varName = "Total_precipitation_surface_1_Hour_Accumulation"
            let varName = "APCP_surface"
            // lon 97.6
            let value = try file.value(for: varName, at: Coordinate(latitude: 28.6, longitude: 97.78))
            print("value: \(value)")
        } catch let e {
            print(e)
        }
        print("--- test0401 ----")
    }
    
    func test04() {
        do {
            let file = try NCFile(
                latitudeName: "lat",
                longitudeName: "lon",
                missingValueName: "missing_value",
                scaleFactorName: "scale_factor",
                offsetName: "add_offset",
                filePath: ncPath
            )
            
            let coord200 = Coordinate(latitude: 30.684154, longitude: 103.981221)
            let tem200 = try file.value(for: "TEM", at: coord200)
            print("tem200 -> \(tem200)")
            XCTAssertGreaterThanOrEqual(tem200,  32.30)
            XCTAssertLessThanOrEqual(tem200,     32.40)
            
            // 30.690114974975586
            let coord00 = Coordinate(latitude: 30.68011474609375, longitude: 103.97282409667969)
            let ncpoint00 = NCPoint(coordinate: coord00, value: 323.0)
            
            let coord01 = Coordinate(latitude: 30.68011474609375, longitude: 103.98282623291016)
            let ncpoint01 = NCPoint(coordinate: coord01, value: 324.0)
            
            let coord10 = Coordinate(latitude: 30.690114974975586,  longitude: 103.97282409667969)
            let ncpoint10 = NCPoint(coordinate: coord10, value:  324.0)
            
            let coord11 = Coordinate(latitude: 30.690114974975586,  longitude: 103.98282623291016)
            let ncpoint11 = NCPoint(coordinate: coord11, value:  324.0)
            
            XCTAssertGreaterThanOrEqual(coord200.latitude, coord00.latitude)
            XCTAssertLessThanOrEqual(coord200.longitude,   coord11.longitude)
            
            let cell = GridCell(point00: ncpoint00, point10: ncpoint10, point01: ncpoint01, point11: ncpoint11)
            let gridIval200 = cell.interpolate(point: coord200)
            print("gridIval200 -> \(gridIval200)")
            
            XCTAssertGreaterThanOrEqual(gridIval200,  323.0)
            XCTAssertLessThanOrEqual(gridIval200,   324.0)
            
            
            
            let gridIval300 = cell.interpolate(point: coord00)
            print("324.0 -> gridIval300: \(gridIval300)")
            
            // -------------------------------------------------
            print("通过 NCFile 计算 coord00(\(coord00.latitude),\(coord00.longitude))")
            let tem300 = try file.value(for: "TEM", at: coord00)
            print("\(ncpoint00.value) -> tem300: \(tem300 * 10)")
            // -------------------------------------------------
            
            let gridIval400 = cell.interpolate(point: coord01)
            print("324.0 -> gridIval400: \(gridIval400)")
            
            let gridIval500 = cell.interpolate(point: coord10)
             print("323.0 -> gridIval500: \(gridIval500)")
            
            let gridIval600 = cell.interpolate(point: coord11)
            print("324.0 -> gridIval600: \(gridIval600)")
            
            
            
        } catch {
            print("Error")
        }
    }


     func test_NCFileUtils_neighborRange_0() throws {
        let array = [1.0, 1.5, 2.0, 3.2]
        let point = 0.6
        let result = try NCFileUtils.neighborRange(at: point, in: array)
        
        XCTAssertNil(result)
        
//        XCTAssertEqual(result!.left, 0)
//        XCTAssertEqual(result!.right, 1)
    }
    
    func test_NCFileUtils_neighborRange() throws {
        let array = [1.0, 1.5, 2.0, 3.2]
        let point = 1.0
        let result = try NCFileUtils.neighborRange(at: point, in: array)
        
        XCTAssertNotNil(result)
        
        XCTAssertEqual(result!.left, 0)
        XCTAssertEqual(result!.right, 1)
    }
    
    func test_NCFileUtils_neighborRange_1() throws {
        let array = [1.0, 1.5, 2.0, 3.2]
        let point = 1.2
        let result = try NCFileUtils.neighborRange(at: point, in: array)
        
        XCTAssertNotNil(result)
        
        XCTAssertEqual(result!.left, 0)
        XCTAssertEqual(result!.right, 1)
    }
    
    func test_NCFileUtils_neighborRange_2() throws {
        let array = [1.0, 1.5, 2.0, 3.2]
        let point = 1.8
        let ret = try NCFileUtils.neighborRange(at: point, in: array)
        
        XCTAssertNotNil(ret)
        
        XCTAssertEqual(ret!.left, 1)
        XCTAssertEqual(ret!.right, 2)
    }
    
    
    func test_NCFileUtils_neighborRange_3() throws {
        let array = [1.0, 1.5, 2.0, 3.2]
        let point = 2.0
        let ret = try NCFileUtils.neighborRange(at: point, in: array)
        
        XCTAssertNotNil(ret)
        
        XCTAssertEqual(ret!.left, 2)
        XCTAssertEqual(ret!.right, 3)
    }
    
    func test_NCFileUtils_neighborRange_4() throws {
        let array = [1.0, 1.5, 2.0, 3.2]
        let point = 3.0
        let ret = try NCFileUtils.neighborRange(at: point, in: array)
        
        XCTAssertNotNil(ret)
        
        XCTAssertEqual(ret!.left, 2)
        XCTAssertEqual(ret!.right, 3)
    }
    
    func test_NCFileUtils_neighborRange_5() throws {
        let array = [1.0, 1.5, 2.0, 3.2]
        let point = 3.2
        let ret = try NCFileUtils.neighborRange(at: point, in: array)
    
        XCTAssertNotNil(ret)
        
        XCTAssertEqual(ret!.left, 2)
        XCTAssertEqual(ret!.right, 3)
    }
    
    
    func test_NCFileUtils_neighborRange_6() throws {
        let array = [3.2, 2.0, 1.8,1.5,1.0]
        let point = 3.2
        let ret = try NCFileUtils.neighborRange(at: point, in: array)
        
        XCTAssertNotNil(ret)
        
        XCTAssertEqual(ret!.left, 0)
        XCTAssertEqual(ret!.right, 1)
    }
    
    
    func test_NCFileUtils_neighborRange_7() throws {
        let array = [3.2, 2.0, 1.8,1.5,1.0]
        let point = 3.0
        let ret = try NCFileUtils.neighborRange(at: point, in: array)
        
        XCTAssertNotNil(ret)
        
        XCTAssertEqual(ret!.left, 0)
        XCTAssertEqual(ret!.right, 1)
    }
    
    func test_NCFileUtils_neighborRange_8() throws {
        let array = [3.2, 2.0, 1.8,1.5,1.0]
        let point = 1.9
        let ret = try NCFileUtils.neighborRange(at: point, in: array)
        
        XCTAssertNotNil(ret)
        
        XCTAssertEqual(ret!.left, 1)
        XCTAssertEqual(ret!.right, 2)
    }
    
    func test_NCFileUtils_neighborRange_9() throws {
        let array = [3.2, 2.0, 1.8,1.5,1.0]
        let point = 1.8
        let ret = try NCFileUtils.neighborRange(at: point, in: array)
        
        XCTAssertNotNil(ret)
        
        XCTAssertEqual(ret!.left, 2)
        XCTAssertEqual(ret!.right, 3)
    }
    
    func test_NCFileUtils_neighborRange_10() throws {
        let array = [3.2, 2.0, 1.8,1.5,1.0]
        let point = 1.6
        let ret = try NCFileUtils.neighborRange(at: point, in: array)
        
        XCTAssertNotNil(ret)
        
        XCTAssertEqual(ret!.left, 2)
        XCTAssertEqual(ret!.right, 3)
    }
    
    func test_NCFileUtils_neighborRange_11() throws {
        let array = [3.2, 2.0, 1.8,1.5,1.0]
        let point = 1.5
        let ret = try NCFileUtils.neighborRange(at: point, in: array)
        
        XCTAssertNotNil(ret)
        
        XCTAssertEqual(ret!.left, 3)
        XCTAssertEqual(ret!.right, 4)
    }
    
    
    func test_NCFileUtils_neighborRange_12() throws {
        let array = [3.2, 2.0, 1.8,1.5,1.0]
        let point = 1.2
        let ret = try NCFileUtils.neighborRange(at: point, in: array)
        
        XCTAssertNotNil(ret)
        
        XCTAssertEqual(ret!.left, 3)
        XCTAssertEqual(ret!.right, 4)
    }
    
    func test_NCFileUtils_neighborRange_13() throws {
        let array = [3.2, 2.0, 1.8,1.5,1.0]
        let point = 1.0
        let ret = try NCFileUtils.neighborRange(at: point, in: array)
        
        XCTAssertNotNil(ret)
        
        XCTAssertEqual(ret!.left, 3)
        XCTAssertEqual(ret!.right, 4)
    }

    // 20 tests
    static var allTests = [
        ("test0401", test0401)
//        ("testExample", testExample),
//        ("test01", test01),
//        ("test02", test02),
//        ("test03", test03),
//        ("test04",test04),
//        ("test0401", test0401),
//        ("test_NCFileUtils_neighborRange_0",test_NCFileUtils_neighborRange_0),
//        ("test_NCFileUtils_neighborRange", test_NCFileUtils_neighborRange),
//        ("test_NCFileUtils_neighborRange_1", test_NCFileUtils_neighborRange_1),
//        ("test_NCFileUtils_neighborRange_2", test_NCFileUtils_neighborRange_2),
//        ("test_NCFileUtils_neighborRange_3", test_NCFileUtils_neighborRange_3),
//        ("test_NCFileUtils_neighborRange_4", test_NCFileUtils_neighborRange_4),
//        ("test_NCFileUtils_neighborRange_5", test_NCFileUtils_neighborRange_5),
//        ("test_NCFileUtils_neighborRange_6",  test_NCFileUtils_neighborRange_6),
//        ("test_NCFileUtils_neighborRange_7", test_NCFileUtils_neighborRange_7),
//        ("test_NCFileUtils_neighborRange_8", test_NCFileUtils_neighborRange_8),
//        ("test_NCFileUtils_neighborRange_9", test_NCFileUtils_neighborRange_9),
//        ("test_NCFileUtils_neighborRange_10", test_NCFileUtils_neighborRange_10),
//        ("test_NCFileUtils_neighborRange_11", test_NCFileUtils_neighborRange_11),
//        ("test_NCFileUtils_neighborRange_12", test_NCFileUtils_neighborRange_12),
//        ("test_NCFileUtils_neighborRange_13", test_NCFileUtils_neighborRange_13),

    ]
}
