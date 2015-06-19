import Foundation

public protocol Reader {
    static func from(data: NSData) -> Reader?
    static func from(inputStream: NSInputStream) -> Reader?
    func readTag() -> Int
    func readVarInt() -> Int
    func readVarUInt() -> UInt
    func readVarUInt64() -> UInt64
    func readBool() -> Bool
    func readData() -> NSData
    func readFloat32() -> Float32
    func readFloat64() -> Float64
    func readUInt32() -> UInt32
    func readUInt64() -> UInt64
    func readString() -> String
    func pushTagMap(map: [String:(Int, Bool)])
    func popTagMap()
}
