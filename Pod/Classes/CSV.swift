import Foundation

public class CSV {
    
    
    private let stream: Stream
    private let delimiter = ","
    private let doubleQuote = "\""
    
    public class func foreach(fileHandle: NSFileHandle, block: ([String], inout Bool) -> Void) {
        CSV(fileHandle: fileHandle).each(block)
    }
    
    public class func foreach(filePath: String, block: ([String], inout Bool) -> Void) throws {
        if let fileHandle = NSFileHandle(forReadingAtPath: filePath) {
            foreach(fileHandle, block: block)
        } else {
            throw CSVError.FileNotFound
        }
    }
    
    public class func parse(text: String, block: ([String], inout Bool) -> Void) {
        for line in text.componentsSeparatedByString("\n") {
            var stopped: Bool = false
            let row = CSV.parseLine(line, delimiter: ",", quote: "\"")
            block(row, &stopped)
            if (stopped) {
                break
            }
        }
    }
    
    public enum CSVOption {
        case QuoteChar(String)
        case Delimiter(String)
        case FirstLineAsHeader(Bool)
    }
    
    public init(fileHandle: NSFileHandle) {
        stream = Stream(fileHandle: fileHandle)
    }
     
    public func each(block: ([String], inout Bool) -> Void) {
        let generator = stream.generate()
        while (true) {
            var stopped: Bool = false
            if let row = CSV.parseRow(generator, delimiter: delimiter, quote: doubleQuote) {
                block(row, &stopped)
            }
            if (stream.eof) {
                break
            }
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

    static func parseRow(generator: Stream.Generator, delimiter:String, quote:String) -> [String]? {
        var row: String = ""
        var result: [String] = []
        var state: ParseState = .Empty
        
        while(true) {
            guard let line = generator.next() else {
                if row.characters.count > 0 {
                    result.append(row)
                } else if (result.count == 0) {
                    return nil
                }
                break
            }
            for c in line.unicodeScalars {
                let characterString = String(stringInterpolationSegment: c)
                
                switch (characterString) {
                case quote where state == .Empty:
                    state = .InQuote
                case quote where state == .InQuote:
                    state = .Parsing
                case quote where state == .Parsing:
                    row.append(c)
                case delimiter where state == .InQuote:
                    row.append(c)
                case delimiter:
                    result.append(row)
                    row = ""
                    state = .Empty
                default:
                    row.append(c)
                }
            }
            if (state != .InQuote) {
                if row.characters.count > 0 {
                    result.append(row)
                }
                break
            } else {
                row.appendContentsOf("\n")
            }
        }
        return result
    }
    
    static func parseLine(line: String, delimiter:String, quote:String) -> [String] {
        var row: String = ""
        var result: [String] = []
        var state: ParseState = .Empty
        
        for c in line.unicodeScalars {
            
            let characterString = String(stringInterpolationSegment: c)
            
            switch (characterString) {
            case quote where state == .Empty:
                state = .InQuote
            case quote where state == .InQuote:
                state = .Parsing
            case quote where state == .Parsing:
                row.append(c)
            case delimiter where state == .InQuote:
                row.append(c)
            case delimiter:
                result.append(row)
                row = ""
                state = .Empty
            default:
                row.append(c)
            }
        }
        if row.characters.count > 0 {
            result.append(row)
        }
        return result
    }
}
