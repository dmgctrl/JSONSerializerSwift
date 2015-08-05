import Foundation

public class JSONReader : Reader {
    typealias RepeatedObject = (key: Int, generator: NSArray.Generator)
    
    var generatorStack: [NSDictionary.Generator] = []
    var generator: NSDictionary.Generator
    var tagMapStack: [[String:(Int, Bool)]] = []
    var tagMap: [String:(Int, Bool)]! = nil
    var object: AnyObject! = nil
    var repeatedObjectStack: [RepeatedObject?] = []
    var repeatedObject: RepeatedObject? = nil
    
    init(dictionary: NSDictionary) {
        self.generator = dictionary.generate()
    }
    
    public class func from(data: NSData) -> Reader? {
        var error: NSError?
        if let dict = (NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? NSDictionary) {
            return JSONReader(dictionary: dict)
        } else {
            return nil
        }
    }
    
    public class func from(inputStream: NSInputStream) -> Reader? {
        var dict: NSDictionary = NSJSONSerialization.JSONObjectWithStream(inputStream, options: nil, error: nil)! as! NSDictionary
        return JSONReader(dictionary: dict)
    }
    
    public func readTag() -> Int {
        if let value: AnyObject = repeatedObject?.generator.next() {
            object = value
            return repeatedObject!.key
        }
        
        if let keyValuePair = generator.next() {
            if let info = tagMap[keyValuePair.key as! String] {
                if info.1 {
                    repeatedObject = (key: info.0, generator: (keyValuePair.value as! NSArray).generate())
                    object = repeatedObject?.generator.next()
                } else {
                    object = keyValuePair.value
                }
                if nil != object {
                    return info.0
                } else {
                    return 0
                }
            } else {
                return 0 // Error
            }
        } else {
            return 0
        }
    }
    
    public func readVarInt() -> Int {
        if let v = (object as? NSNumber)?.integerValue {
            return v
        }
        return 0
    }
    
    public func readVarUInt() -> UInt {
        if let v = (object as? NSNumber)?.unsignedIntegerValue {
            return UInt(v)
        }
        return 0
    }
    
    public func readVarUInt64() -> UInt64 {
        if let v = (object as? NSNumber)?.unsignedLongLongValue {
            return UInt64(v)
        }
        return 0
    }
    
    public func readBool() -> Bool {
        if let v = (object as? NSNumber)?.boolValue {
            return v
        }
        return false
    }
    
    public func readData() -> NSData {
        NSException(name:"Unsupported Operation", reason:"", userInfo: nil).raise()
        return NSData()
    }
    
    public func readUInt32() -> UInt32 {
        if let v = (object as? NSNumber)?.unsignedIntegerValue {
            return UInt32(v)
        }
        return 0
    }
    
    public func readUInt64() -> UInt64 {
        if let v = (object as? NSNumber)?.unsignedIntegerValue {
            return UInt64(v)
        }
        return 0
    }
    
    public func readFloat32() -> Float32 {
        if let v = (object as? NSNumber)?.floatValue {
            return Float32(v)
        }
        return 0
    }
    
    public func readFloat64() -> Float64 {
        if let v = (object as? NSNumber)?.doubleValue {
            return Float64(v)
        }
        return 0
    }
    
    public func readString() -> String {
        if let value = object as? String {
            return value
        }
        return ""
    }
    
    public func pushLimit(limit: Int) -> Int {
        return 0 // NO OP
    }
    
    public func popLimit(limit: Int) {
        // NO OP
    }
    
    public func pushTagMap(map: [String:(Int, Bool)]) {
        if nil != self.tagMap {
            tagMapStack.append(self.tagMap)
            generatorStack.append(generator)
            generator = (object as! NSDictionary).generate()
            repeatedObjectStack.append(repeatedObject)
            repeatedObject = nil
        }
        self.tagMap = map
    }
    
    public func popTagMap() {
        if tagMapStack.count > 0 {
            tagMap = tagMapStack.removeLast()
            generator = generatorStack.removeLast()
            repeatedObject = repeatedObjectStack.removeLast()
        }
    }
}