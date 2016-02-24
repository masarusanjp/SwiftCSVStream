//
//  Stream.swift
//  Pods
//
//  Created by Masaru Ichikawa on 2016/02/24.
//
//

import Foundation

class Stream : SequenceType {
    class Generator : GeneratorType {
        let stream: Stream
        init(stream: Stream) {
            self.stream = stream
        }
        
        func next() -> String? {
            return try! stream.nextLine()
        }
    }
    
    let fileHandle: NSFileHandle
    private let chunkSize: Int = 1024
    private let buffer: NSMutableData? = NSMutableData(capacity: 1024)
    private let lineDelimiterData: NSData? = String("\n").dataUsingEncoding(NSUTF8StringEncoding)
    private(set) var eof: Bool = false
    
    init(fileHandle: NSFileHandle) {
        self.fileHandle = fileHandle
    }
    
    deinit {
        fileHandle.closeFile()
    }
    
    func generate() -> Generator {
        return Generator(stream: self)
    }
    
    func nextLine() throws -> String? {
        if (eof) {
            return nil
        }
        guard let buffer = buffer else {
            throw CSVError.IOFail
        }
        guard let lineDelimiterData = lineDelimiterData else {
            throw CSVError.IOFail
        }
        
        var range = buffer.rangeOfData(lineDelimiterData,options: NSDataSearchOptions(rawValue: 0), range: NSRange(location: 0, length: buffer.length))
        
        while range.location == NSNotFound {
            let data = fileHandle.readDataOfLength(chunkSize)
            
            if data.length == 0 {
                eof = true
                if buffer.length > 0 {
                    let line = String(data: buffer, encoding: NSUTF8StringEncoding)
                    buffer.length = 0
                    return line
                } else {
                   return nil
                }
            }
            buffer.appendData(data)
            range = buffer.rangeOfData(lineDelimiterData,options: NSDataSearchOptions(rawValue: 0), range: NSRange(location: 0, length: buffer.length))
        }
        
        let lineRange = NSRange(location: 0, length: range.location)
        let line = String(data: buffer.subdataWithRange(lineRange), encoding: NSUTF8StringEncoding)
        
        buffer.replaceBytesInRange(NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
        return line
    }
}