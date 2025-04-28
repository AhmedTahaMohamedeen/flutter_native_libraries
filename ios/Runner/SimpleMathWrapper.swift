import Foundation

@_silgen_name("add")
func add(_ a: Int32, _ b: Int32) -> Int32

@_cdecl("dummy_reference_to_add")
public func dummy_reference_to_add() -> Int32 {
    return add(1, 1)
}
