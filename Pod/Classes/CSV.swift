import Foundation

public class CSV {
    
    public enum CSVError : ErrorType {
        case IOFail
    }
    private class Stream : SequenceType {
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
        private var eof: Bool = false
        
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
    
    private let stream: Stream
    private let delimiter = ","
    private let doubleQuote = "\""
    
    public class func foreach(fileHandle: NSFileHandle, firstLineAsHeader: Bool, block: ([String], inout Bool) -> Void) {
        CSV(fileHandle: fileHandle).each(block)
    }
    
    public init(fileHandle: NSFileHandle) {
        stream = Stream(fileHandle: fileHandle)
    }
     
    public func each(block: ([String], inout Bool) -> Void) {
        for line in stream {
            var stopped: Bool = false
            let row = parseLine(line)
            block(row, &stopped)
            if (stopped) {
                break
            }
        }
    }
    
    enum ParseState {
        case Empty
        case InQuote
        case Parsing
    }
    
    func parseLine(line: String) -> [String] {
        var row: String = ""
        var result: [String] = []
        var state: ParseState = .Empty
        
        for c in line.unicodeScalars {
            
            let context = (String(stringInterpolationSegment: c), state)
            
            switch (context) {
            case (doubleQuote, .Empty):
                state = .InQuote
            case (doubleQuote, .InQuote):
                state = .Parsing
            case (doubleQuote, .Parsing):
                row.append(c)
            case (delimiter, .InQuote):
                row.append(c)
            case (delimiter, _):
                result.append(row)
                row = ""
                state = .Empty
            case (_, _):
                row.append(c)
            }
        }
        if row.characters.count > 0 {
            result.append(row)
        }
        return result
    }
}
