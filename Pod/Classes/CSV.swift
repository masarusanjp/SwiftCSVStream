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
            
            var range = buffer.rangeOfData(lineDelimiterData,options: NSDataSearchOptions.Backwards, range: NSRange(location: 0, length: buffer.length))
            
            while range.location == NSNotFound {
                let data = fileHandle.readDataOfLength(chunkSize)
                
                if data.length == 0 {
                    eof = true
                    if buffer.length > 0 {
                        let line = String(data: buffer, encoding: NSUTF8StringEncoding)
                        buffer.length = 0
                        return line
                    }
                }
                buffer.appendData(data)
                range = buffer.rangeOfData(lineDelimiterData,options: NSDataSearchOptions.Backwards, range: NSRange(location: 0, length: buffer.length))
            }
            
            let lineRange = NSRange(location: 0, length: range.location)
            let line = String(data: buffer.subdataWithRange(lineRange), encoding: NSUTF8StringEncoding)
            buffer.replaceBytesInRange(NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
            return line
        }
    }
    
    
    public class func foreach(fileHandle: NSFileHandle, firstLineAsHeader: Bool, block: ([String], inout Bool) -> Void) {
        let stream = Stream(fileHandle: fileHandle)
        for line in stream {
            var stopped: Bool = false
            // TODO: Handle commas inner double quotes. ex) a, b, "c, c", d
            let row = line.componentsSeparatedByString(",")
            block(row, &stopped)
            if (stopped) {
                break
            }
        }
    }
    
}
