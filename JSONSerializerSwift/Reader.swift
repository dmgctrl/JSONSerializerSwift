import Foundation

public protocol Reader {
    static func from(_ data: Data) -> Reader?
    static func from(_ inputStream: InputStream) -> Reader?
    func readTag() -> Int
    func readVarInt() -> Int
    func readVarUInt() -> UInt
    func readVarUInt64() -> UInt64
    func readBool() -> Bool
    func readData() -> Data
    func readFloat32() -> Float32
    func readFloat64() -> Float64
    func readUInt32() -> UInt32
    func readUInt64() -> UInt64
    func readString() -> String
    func pushLimit(_ limit: Int) -> Int
    func popLimit(_ limit: Int)
    func pushTagMap(_ map: [String:(Int, Bool)])
    func popTagMap()
}
