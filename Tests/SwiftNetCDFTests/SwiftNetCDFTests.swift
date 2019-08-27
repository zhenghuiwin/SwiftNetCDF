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
        do {
            let file = try NCFile(
                    latitudeName: "lat",
                   longitudeName: "lon",
                missingValueName: "missing_value",
                 scaleFactorName: "scale_factor",
                      offsetName: "add_offset",
                        filePath: ncPath
            )

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
            
            
            
            let ival00 = cell.interpolate(point:  coordi00)
            print("原始: \(tem00) -> \(ival00)")
            XCTAssertEqual(ival00, tem00, accuracy: 0.001)
            
            let ival01 = cell.interpolate(point:  coordi01)
            print("原始: \(tem01) -> \(ival01)")
            XCTAssertEqual(ival01, tem01, accuracy: 0.001)
            
            
            let ival10 = cell.interpolate(point:  coordi10)
            print("原始: \(tem10) -> \(ival10)")
            XCTAssertEqual(ival10, tem10, accuracy: 0.001)
            
            let ival11 = cell.interpolate(point:  coordi11)
            print("原始: \(tem11) -> \(ival11)")
            XCTAssertEqual(ival11, tem11, accuracy: 0.001)
            
            
            let accuracyValue = 0.001
            
            
            let temValue0 = try file.value(for: "TEM", at: coordi00)
            print("顶点: \(tem00) ---> tem0: \(temValue0)")
            XCTAssertEqual(temValue0, tem00, accuracy: accuracyValue)

            let temValue1 = try file.value(for: "TEM", at: coordi01)
            print("顶点: \(tem01) ---> tem1: \(temValue1)")
            XCTAssertEqual(temValue1, tem01, accuracy: accuracyValue)


            let temValue2 = try file.value(for: "TEM", at: coordi10)
            print("顶点: \(tem10) ---> tem2: \(temValue2)")
            XCTAssertEqual(temValue2, tem10, accuracy: accuracyValue)

            let temValue3 = try file.value(for: "TEM", at: coordi11)
            print("顶点: \(tem11) ---> tem3: \(temValue3)")
            XCTAssertEqual(temValue3, tem11, accuracy: accuracyValue)

            let temValue4 = try file.value(for: "TEM", at: Coordinate(latitude: 37.12026, longitude: 78.76000))
            print("tem4: \(temValue4)")
            XCTAssertGreaterThanOrEqual(temValue4, 23.0)
            XCTAssertLessThanOrEqual(temValue4,    23.6)
//
//            print("23.0 -> \(temValue0),23.2 -> \(temValue1), 23.6 -> \(temValue2), 23.4 -> \(temValue3)")

        } catch {
            print("Encount Error!")
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

    static var allTests = [
        ("testExample", testExample),
        ("test01", test01),
        ("test_NCFileUtils_neighborRange_0",test_NCFileUtils_neighborRange_0),
        ("test_NCFileUtils_neighborRange", test_NCFileUtils_neighborRange),
        ("test_NCFileUtils_neighborRange_1", test_NCFileUtils_neighborRange_1),
        ("test_NCFileUtils_neighborRange_2", test_NCFileUtils_neighborRange_2),
        ("test_NCFileUtils_neighborRange_3", test_NCFileUtils_neighborRange_3),
        ("test_NCFileUtils_neighborRange_4", test_NCFileUtils_neighborRange_4),
        ("test_NCFileUtils_neighborRange_5", test_NCFileUtils_neighborRange_5),
        ("test_NCFileUtils_neighborRange_6",  test_NCFileUtils_neighborRange_6),
        ("test_NCFileUtils_neighborRange_7", test_NCFileUtils_neighborRange_7),
        ("test_NCFileUtils_neighborRange_8", test_NCFileUtils_neighborRange_8),
        ("test_NCFileUtils_neighborRange_9", test_NCFileUtils_neighborRange_9),
        ("test_NCFileUtils_neighborRange_10", test_NCFileUtils_neighborRange_10),
        ("test_NCFileUtils_neighborRange_11", test_NCFileUtils_neighborRange_11),
        ("test_NCFileUtils_neighborRange_12", test_NCFileUtils_neighborRange_12),
        ("test_NCFileUtils_neighborRange_13", test_NCFileUtils_neighborRange_13),

    ]
}
