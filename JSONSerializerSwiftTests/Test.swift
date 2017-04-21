import JSONSerializerSwift

public func ==(a: DemoMessage, b: DemoMessage) -> Bool {
    return (
        a.sizeInBytes == b.sizeInBytes
            && a.demoDouble == b.demoDouble
            && a.demoInt32 == b.demoInt32
            && a.demoInt64 == b.demoInt64
            && a.demoBool == b.demoBool
            && a.demoString == b.demoString
            && a.demoNestedMessage == b.demoNestedMessage
            && a.demoRepeated == b.demoRepeated
            && a.demoRepeatedNestedMessage == b.demoRepeatedNestedMessage
    )
}

public func ==(a: DemoMessage.DemoNestedMessage, b: DemoMessage.DemoNestedMessage) -> Bool {
    return (
        a.sizeInBytes == b.sizeInBytes
            && a.nestedString == b.nestedString
            && a.nestedInt32 == b.nestedInt32
    )
}

open class DemoMessage: Equatable {
    open let sizeInBytes: Int
    open let demoDouble: Float64?
    open let demoInt32: Int?
    open let demoInt64: Int?
    open let demoBool: Bool?
    open let demoString: String?
    open let demoNestedMessage: DemoNestedMessage?
    open let demoRepeated: [String]
    open let demoRepeatedNestedMessage: [DemoNestedMessage]!
    
    init(sizeInBytes: Int,
         demoDouble: Float64?,
         demoInt32: Int?,
         demoInt64: Int?,
         demoBool: Bool?,
         demoString: String?,
         demoNestedMessage: DemoNestedMessage?,
         demoRepeated: [String],
         demoRepeatedNestedMessage: [DemoNestedMessage]!) {
        self.sizeInBytes = sizeInBytes
        self.demoDouble = demoDouble
        self.demoInt32 = demoInt32
        self.demoInt64 = demoInt64
        self.demoBool = demoBool
        self.demoString = demoString
        self.demoNestedMessage = demoNestedMessage
        self.demoRepeated = demoRepeated
        self.demoRepeatedNestedMessage = demoRepeatedNestedMessage
    }
    
    open func toWriter(_ w: Writer) {
        let tagMap: [Int:(String, Bool)] = [
            9 : ("demoDouble", false),
            16 : ("demoInt32", false),
            24 : ("demoInt64", false),
            32 : ("demoBool", false),
            42 : ("demoString", false),
            50 : ("demoNestedMessage", false),
            58 : ("demoRepeated", true),
            66 : ("demoRepeatedNestedMessage", true)
        ]
        
        w.pushTagMap(tagMap)
        
        if let v = self.demoDouble {
            w.writeTag(9)
            w.writeFloat64(v)
        }
        
        if let v = self.demoInt32 {
            w.writeTag(16)
            w.writeVarInt(v)
        }
        
        if let v = self.demoInt64 {
            w.writeTag(24)
            w.writeVarInt(v)
        }
        
        if let v = self.demoBool {
            w.writeTag(32)
            w.writeBool(v)
        }
        
        if let v = self.demoString {
            w.writeTag(42)
            w.writeString(v)
        }
        
        if let v = self.demoNestedMessage {
            w.writeTag(50)
            w.writeVarInt(v.sizeInBytes)
            v.toWriter(w)
        }
        
        for v in self.demoRepeated {
            w.writeTag(58)
            w.writeString(v)
        }
        
        for v in self.demoRepeatedNestedMessage {
            w.writeTag(66)
            w.writeVarInt(v.sizeInBytes)
            v.toWriter(w)
        }
        
        w.popTagMap()
    }
    
    open class func fromReader(_ r: Reader) -> DemoMessage {
        let tagMap: [String:(Int, Bool)] = [
            "demoDouble" : (9, false),
            "demoInt32" : (16, false),
            "demoInt64" : (24, false),
            "demoBool" : (32, false),
            "demoString" : (42, false),
            "demoNestedMessage" : (50, false),
            "demoRepeated" : (58, true),
            "demoRepeatedNestedMessage" : (66, true)
        ]
        
        r.pushTagMap(tagMap)
        
        var demoDouble: Float64? = nil
        var demoInt32: Int? = nil
        var demoInt64: Int? = nil
        var demoBool: Bool? = nil
        var demoString: String? = nil
        var demoNestedMessage: DemoNestedMessage? = nil
        var demoRepeated: [String] = []
        var demoRepeatedNestedMessage: [DemoNestedMessage]! = []
        
        loop: while true {
            switch r.readTag() {
            case 9:
                demoDouble = r.readFloat64()
            case 16:
                demoInt32 = r.readVarInt()
            case 24:
                demoInt64 = r.readVarInt()
            case 32:
                demoBool = r.readBool()
            case 42:
                demoString = r.readString()
            case 50:
                let limit = r.pushLimit(r.readVarInt())
                demoNestedMessage = DemoMessage.DemoNestedMessage.fromReader(r)
                r.popLimit(limit)
            case 58:
                demoRepeated.append(r.readString())
            case 66:
                let limit = r.pushLimit(r.readVarInt())
                demoRepeatedNestedMessage.append(DemoMessage.DemoNestedMessage.fromReader(r))
                r.popLimit(limit)
            default:
                break loop
            }
        }
        
        r.popTagMap()
        
        let sizeInBytes = DemoMessage.sizeOf(demoDouble, demoInt32: demoInt32, demoInt64: demoInt64, demoBool: demoBool, demoString: demoString, demoNestedMessage: demoNestedMessage, demoRepeated: demoRepeated, demoRepeatedNestedMessage: demoRepeatedNestedMessage)
        return DemoMessage(sizeInBytes: sizeInBytes, demoDouble: demoDouble, demoInt32: demoInt32, demoInt64: demoInt64, demoBool: demoBool, demoString: demoString, demoNestedMessage: demoNestedMessage, demoRepeated: demoRepeated, demoRepeatedNestedMessage: demoRepeatedNestedMessage)
    }
    
    class func sizeOf(_ demoDouble: Float64?,
                      demoInt32: Int?,
                      demoInt64: Int?,
                      demoBool: Bool?,
                      demoString: String?,
                      demoNestedMessage: DemoNestedMessage?,
                      demoRepeated: [String],
                      demoRepeatedNestedMessage: [DemoNestedMessage]!) -> Int {
        var n = 0
        
        if let _ = demoDouble {
            n += 1 + 8
        }
        if let v = demoInt32 {
            n += 1 + sizeOfVarInt(Int(v))
        }
        if let v = demoInt64 {
            n += 1 + sizeOfVarInt(Int(v))
        }
        if let _ = demoBool {
            n += 1 + 1
        }
        if let v = demoString {
            n += 1 + sizeOfString(v)
        }
        if let v = demoNestedMessage {
            n += 1 + sizeOfVarInt(v.sizeInBytes) + v.sizeInBytes
        }
        for v in demoRepeated {
            n += 1 + sizeOfString(v)
        }
        for v in demoRepeatedNestedMessage {
            n += 1 + sizeOfVarInt(v.sizeInBytes) + v.sizeInBytes
        }
        
        return n
    }
    
    open class func builder() -> DemoMessageBuilder {
        return DemoMessageBuilder()
    }
    
    open class DemoNestedMessage: Equatable {
        open let sizeInBytes: Int
        open let nestedString: String?
        open let nestedInt32: Int?
        
        init(sizeInBytes: Int, nestedString: String?, nestedInt32: Int?) {
            self.sizeInBytes = sizeInBytes
            self.nestedString = nestedString
            self.nestedInt32 = nestedInt32
        }
        
        open func toWriter(_ w: Writer) {
            let tagMap: [Int:(String, Bool)] = [
                10 : ("nestedString", false),
                16 : ("nestedInt32", false)
            ]
            
            w.pushTagMap(tagMap)
            
            if let v = self.nestedString {
                w.writeTag(10)
                w.writeString(v)
            }
            
            if let v = self.nestedInt32 {
                w.writeTag(16)
                w.writeVarInt(v)
            }
            
            w.popTagMap()
        }
        
        open class func fromReader(_ r: Reader) -> DemoNestedMessage {
            let tagMap: [String:(Int, Bool)] = [
                "nestedString" : (10, false),
                "nestedInt32" : (16, false)
            ]
            
            r.pushTagMap(tagMap)
            
            var nestedString: String? = nil
            var nestedInt32: Int? = nil
            
            loop: while true {
                switch r.readTag() {
                case 10:
                    nestedString = r.readString()
                case 16:
                    nestedInt32 = r.readVarInt()
                default:
                    break loop
                }
            }
            
            r.popTagMap()
            
            let sizeInBytes = DemoNestedMessage.sizeOf(nestedString, nestedInt32: nestedInt32)
            return DemoNestedMessage(sizeInBytes: sizeInBytes, nestedString: nestedString, nestedInt32: nestedInt32)
        }
        
        class func sizeOf(_ nestedString: String?, nestedInt32: Int?) -> Int {
            var n = 0
            
            if let v = nestedString {
                n += 1 + sizeOfString(v)
            }
            if let v = nestedInt32 {
                n += 1 + sizeOfVarInt(Int(v))
            }
            
            return n
        }
        
        open class func builder() -> DemoNestedMessageBuilder {
            return DemoNestedMessageBuilder()
        }
    }
    
    open class DemoNestedMessageBuilder {
        var nestedString: String? = nil
        var nestedInt32: Int? = nil
        
        open func clear() -> Self {
            self.nestedString = nil
            self.nestedInt32 = nil
            return self
        }
        
        open func setNestedString(_ v: String?) -> Self {
            self.nestedString = v
            return self
        }
        
        open func clearNestedString() -> Self {
            self.nestedString = nil
            return self
        }
        
        open func setNestedInt32(_ v: Int?) -> Self {
            self.nestedInt32 = v
            return self
        }
        
        open func clearNestedInt32() -> Self {
            self.nestedInt32 = nil
            return self
        }
        
        open func build() -> DemoNestedMessage {
            let sizeInBytes = DemoNestedMessage.sizeOf(nestedString, nestedInt32: nestedInt32)
            return DemoNestedMessage(sizeInBytes: sizeInBytes, nestedString: nestedString, nestedInt32: nestedInt32)
        }
    }
}

open class DemoMessageBuilder {
    var demoDouble: Float64? = nil
    var demoInt32: Int? = nil
    var demoInt64: Int? = nil
    var demoBool: Bool? = nil
    var demoString: String? = nil
    var demoNestedMessage: DemoMessage.DemoNestedMessage? = nil
    var demoRepeated: [String] = []
    var demoRepeatedNestedMessage: [DemoMessage.DemoNestedMessage]! = []
    
    open func clear() -> Self {
        self.demoDouble = nil
        self.demoInt32 = nil
        self.demoInt64 = nil
        self.demoBool = nil
        self.demoString = nil
        self.demoNestedMessage = nil
        self.demoRepeated = []
        self.demoRepeatedNestedMessage = []
        return self
    }
    
    open func setDemoDouble(_ v: Float64?) -> Self {
        self.demoDouble = v
        return self
    }
    
    open func clearDemoDouble() -> Self {
        self.demoDouble = nil
        return self
    }
    
    open func setDemoInt32(_ v: Int?) -> Self {
        self.demoInt32 = v
        return self
    }
    
    open func clearDemoInt32() -> Self {
        self.demoInt32 = nil
        return self
    }
    
    open func setDemoInt64(_ v: Int?) -> Self {
        self.demoInt64 = v
        return self
    }
    
    open func clearDemoInt64() -> Self {
        self.demoInt64 = nil
        return self
    }
    
    open func setDemoBool(_ v: Bool?) -> Self {
        self.demoBool = v
        return self
    }
    
    open func clearDemoBool() -> Self {
        self.demoBool = nil
        return self
    }
    
    open func setDemoString(_ v: String?) -> Self {
        self.demoString = v
        return self
    }
    
    open func clearDemoString() -> Self {
        self.demoString = nil
        return self
    }
    
    open func setDemoNestedMessage(_ v: DemoMessage.DemoNestedMessage?) -> Self {
        self.demoNestedMessage = v
        return self
    }
    
    open func clearDemoNestedMessage() -> Self {
        self.demoNestedMessage = nil
        return self
    }
    
    open func setDemoRepeated(_ v: [String]) -> Self {
        self.demoRepeated = v
        return self
    }
    
    open func clearDemoRepeated() -> Self {
        self.demoRepeated = []
        return self
    }
    
    open func setDemoRepeatedNestedMessage(_ v: [DemoMessage.DemoNestedMessage]!) -> Self {
        self.demoRepeatedNestedMessage = v
        return self
    }
    
    open func clearDemoRepeatedNestedMessage() -> Self {
        self.demoRepeatedNestedMessage = []
        return self
    }
    
    open func build() -> DemoMessage {
        let sizeInBytes = DemoMessage.sizeOf(demoDouble, demoInt32: demoInt32, demoInt64: demoInt64, demoBool: demoBool, demoString: demoString, demoNestedMessage: demoNestedMessage, demoRepeated: demoRepeated, demoRepeatedNestedMessage: demoRepeatedNestedMessage)
        return DemoMessage(sizeInBytes: sizeInBytes, demoDouble: demoDouble, demoInt32: demoInt32, demoInt64: demoInt64, demoBool: demoBool, demoString: demoString, demoNestedMessage: demoNestedMessage, demoRepeated: demoRepeated, demoRepeatedNestedMessage: demoRepeatedNestedMessage)
    }
}

private func sizeOfVarInt(_ v: Int) -> Int {
    var n = 0
    var x = v
    repeat {
        x = x >> 7
        n += 1
    } while (x > 0)
    return n
}

private func sizeOfString(_ s: String) -> Int {
    let b = s.utf8.count
    return sizeOfVarInt(b) + b
}

