import Foundation

open class JSONWriter : Writer {
    var tagMapStack: [[Int:(String, Bool)]] = []
    var tagMap: [Int:(String, Bool)]! = nil
    var objectStack: [NSMutableDictionary] = []
    var object: NSMutableDictionary! = nil
    var tag: Int! = nil
    var isRepeatedStack: [Bool] = []
    
    open class func writer() -> Writer? {
        return JSONWriter()
    }
    
    open func toBuffer() -> Data {
        return try! JSONSerialization.data(withJSONObject: object, options: [])
    }
    
    open func writeTag(_ tag: Int) {
        self.tag = tag
    }
    
    open func writeByte(_ v: UInt8) {
        self.writeValue(Int(v))
    }
    
    open func writeVarInt(_ v: Int) {
        if 0 == tag & 0x02 {
            self.writeValue(v)
        }
    }
    
    open func writeVarUInt(_ v: UInt) {
        self.writeValue(v)
    }
    
    open func writeVarUInt64(_ v: UInt64) {
        self.writeValue(Int(v))
    }
    
    open func writeBool(_ v: Bool) {
        self.writeValue(v)
    }
    
    open func writeData(_ v: Data) {
        NSException(name: NSExceptionName(rawValue: "Unsupported Operation"), reason: "", userInfo: nil).raise()
    }
    
    open func writeFloat32(_ v: Float32) {
        self.writeValue(v)
    }
    
    open func writeFloat64(_ v: Float64) {
        self.writeValue(v)
    }
    
    open func writeString(_ v: String) {
        self.writeValue(v)
    }
    
    fileprivate func writeValue(_ v: Any) {
        self.writeValue(v, object: object)
    }
    
    fileprivate func writeValue(_ v: Any, object: NSMutableDictionary) {
        if let info = tagMap[tag] {
            if info.1 {
                if let array = object[info.0] as? NSMutableArray {
                    array.add(v)
                } else {
                    object[info.0] = NSMutableArray(objects: v)
                }
            } else {
                object[info.0] = v
            }
        } else {
            // error
        }
    }
    
    open func pushTagMap(_ map: [Int:(String, Bool)]) {
        let parentObject = object
        object = [:]
        if tag != nil {
            self.writeValue(object, object: parentObject!)
        }
        
        if tagMap != nil {
            tagMapStack.append(tagMap)
            objectStack.append(parentObject!)
        }
        tagMap = map
    }
    
    open func popTagMap() {
        if tagMapStack.count > 0 {
            tagMap = tagMapStack.removeLast()
            object = objectStack.removeLast()
        }
    }
}
