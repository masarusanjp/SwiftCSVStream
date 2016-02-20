import UIKit
import XCTest
import SwiftCSVStream

class Tests: XCTestCase {
    
    let bundle = NSBundle(forClass: Tests.self)
        
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testParseNoQuotedFile() {
        guard let path = bundle.pathForResource("test01.csv", ofType: nil)else  {
            XCTFail("failed to get path")
            return
        }
        guard let fileHandle = NSFileHandle(forReadingAtPath: path) else {
            XCTFail("failed to create fileHandle")
            return
        }
        var numberOfLines = 0
        let expected = [
            ["a", "b", "c"],
            ["d", "e", "f"],
            ["123", "456", "899"],
        ]
        CSV.foreach(fileHandle, firstLineAsHeader: false) { (rows, stopped) in
            XCTAssertEqual(expected[numberOfLines], rows)
            numberOfLines++
        }
        XCTAssertEqual(3, numberOfLines)
    }
    
    func testParseQuotedFile() {
        guard let path = bundle.pathForResource("test02.csv", ofType: nil)else  {
            XCTFail("failed to get path")
            return
        }
        guard let fileHandle = NSFileHandle(forReadingAtPath: path) else {
            XCTFail("failed to create fileHandle")
            return
        }
        var numberOfLines = 0
        let expected = [
            ["a,b", "b", "c"],
        ]
        CSV.foreach(fileHandle, firstLineAsHeader: false) { (rows, stopped) in
            XCTAssertEqual(expected[numberOfLines], rows)
            numberOfLines++
        }
    }
}
