import Foundation

public protocol Writer {
    static func writer() -> Writer?
    func toBuffer() -> Data
    func writeTag(_ tag: Int)
    func writeByte(_ v: UInt8)
    func writeVarInt(_ v: Int)
    func writeVarUInt(_ v: UInt)
    func writeVarUInt64(_ v: UInt64)
    func writeData(_ v: Data)
    func writeBool(_ v: Bool)
    func writeFloat32(_ v: Float32)
    func writeFloat64(_ v: Float64)
    func writeString(_ v: String)
    func pushTagMap(_ map: [Int:(String, Bool)])
    func popTagMap()
}
