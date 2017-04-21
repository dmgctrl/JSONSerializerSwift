import Foundation

open class JSONReader : Reader {
    typealias RepeatedObject = (key: Int, generator: NSArray.Iterator)
    
    var generatorStack: [NSDictionary.Iterator] = []
    var generator: NSDictionary.Iterator
    var tagMapStack: [[String:(Int, Bool)]] = []
    var tagMap: [String:(Int, Bool)]! = nil
    var object: Any! = nil
    var repeatedObjectStack: [RepeatedObject?] = []
    var repeatedObject: RepeatedObject? = nil
    
    init(dictionary: NSDictionary) {
        self.generator = dictionary.makeIterator()
    }
    
    open class func from(_ data: Data) -> Reader? {
        var readData : Any?
        do {
            readData = try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            print(error)
        }
        
        if let dict = readData as? NSDictionary {
            return JSONReader(dictionary: dict)
        } else {
            return nil
        }
    }
    
    open class func from(_ inputStream: InputStream) -> Reader? {
        let dict: NSDictionary = (try! JSONSerialization.jsonObject(with: inputStream, options: [])) as! NSDictionary
        return JSONReader(dictionary: dict)
    }
    
    open func readTag() -> Int {
        if let value: Any = repeatedObject?.generator.next() {
            object = value
            return repeatedObject!.key
        }
        
        if let
            keyValuePair = generator.next(),
            let info = tagMap[keyValuePair.key as! String] {
                if info.1 {
                    repeatedObject = (key: info.0, generator: (keyValuePair.value as! NSArray).makeIterator())
                    object = repeatedObject?.generator.next()
                } else {
                    object = keyValuePair.value
                }
                
                if nil == object || object is NSNull {
                    return readTag()
                } else {
                    return info.0
                }
        } else {
            return 0
        }
    }
    
    open func readVarInt() -> Int {
        if let v = (object as? NSNumber)?.intValue {
            return v
        }
        return 0
    }
    
    open func readVarUInt() -> UInt {
        if let v = (object as? NSNumber)?.uintValue {
            return UInt(v)
        }
        return 0
    }
    
    open func readVarUInt64() -> UInt64 {
        if let v = (object as? NSNumber)?.uint64Value {
            return UInt64(v)
        }
        return 0
    }
    
    open func readBool() -> Bool {
        if let v = (object as? NSNumber)?.boolValue {
            return v
        }
        return false
    }
    
    open func readData() -> Data {
        NSException(name: NSExceptionName(rawValue: "Unsupported Operation"), reason: "", userInfo: nil).raise()
        return Data()
    }
    
    open func readUInt32() -> UInt32 {
        if let v = (object as? NSNumber)?.uintValue {
            return UInt32(v)
        }
        return 0
    }
    
    open func readUInt64() -> UInt64 {
        if let v = (object as? NSNumber)?.uintValue {
            return UInt64(v)
        }
        return 0
    }
    
    open func readFloat32() -> Float32 {
        if let v = (object as? NSNumber)?.floatValue {
            return Float32(v)
        }
        return 0
    }
    
    open func readFloat64() -> Float64 {
        if let v = (object as? NSNumber)?.doubleValue {
            return Float64(v)
        }
        return 0
    }
    
    open func readString() -> String {
        if let value = object as? String {
            return value
        }
        return ""
    }
    
    open func pushLimit(_ limit: Int) -> Int {
        return 0 // NO OP
    }
    
    open func popLimit(_ limit: Int) {
        // NO OP
    }
    
    open func pushTagMap(_ map: [String:(Int, Bool)]) {
        if nil != self.tagMap {
            tagMapStack.append(self.tagMap)
            generatorStack.append(generator)
            generator = (object as! NSDictionary).makeIterator()
            repeatedObjectStack.append(repeatedObject)
            repeatedObject = nil
        }
        self.tagMap = map
    }
    
    open func popTagMap() {
        if tagMapStack.count > 0 {
            tagMap = tagMapStack.removeLast()
            generator = generatorStack.removeLast()
            repeatedObject = repeatedObjectStack.removeLast()
        }
    }
}
