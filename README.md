# SwiftCSVStream

[![CI Status](http://img.shields.io/travis/masaichi/SwiftCSVStream.svg?style=flat)](https://travis-ci.org/masaichi/SwiftCSVStream)
[![Version](https://img.shields.io/cocoapods/v/SwiftCSVStream.svg?style=flat)](http://cocoapods.org/pods/SwiftCSVStream)
[![License](https://img.shields.io/cocoapods/l/SwiftCSVStream.svg?style=flat)](http://cocoapods.org/pods/SwiftCSVStream)
[![Platform](https://img.shields.io/cocoapods/p/SwiftCSVStream.svg?style=flat)](http://cocoapods.org/pods/SwiftCSVStream)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SwiftCSVStream is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SwiftCSVStream"
```

## Usage


### Read from file

```Swift

do {
    try CSV.foreach(filePath) { (rows, stopped) in
    }
} catch {

}

```


### Read from NSFileHandle 

```Swift

// STDIN
CSV.foreach(NSFileHandle.fileHandleWithStandardInput) { (rows, stopped) in
    if (rows.count == 0) {
        stopped = true
    }
}

```

## Author

masaichi, masarusanplusplus@gmail.com

## License

SwiftCSVStream is available under the MIT license. See the LICENSE file for more info.
