//
//  ObjCGraftImplementation.swift
//  ObjCGrafting
//
//  Created by WeZZard on 22/10/2016.
//
//

import Foundation
import ObjectiveC

//MARK: - Graft
/// Grafts the implementation of a protocol on a class to another object.
public func ObjCGraftImplementation<P>(
    of protocol: P.Type,
    on class: AnyClass,
    to object: AnyObject
    ) -> P
{
    assert(`class` is P)
    let asAnyObject = `protocol` as AnyObject
    let asObjCProtocol = asAnyObject as! Protocol
    let object = __object_graftProtocol(object, asObjCProtocol, `class`)
    return unsafeBitCast(object as AnyObject, to: P.self)
}

public func ObjCGraftImplementations(
    to object: AnyObject,
    with protocolClassPairs: [(Protocol, AnyClass)]
    )
{
    let pairCount = protocolClassPairs.count
    
    let protocols = UnsafeMutablePointer<Protocol>
        .allocate(capacity: pairCount)
    let sourceClasses = UnsafeMutablePointer<AnyClass>
        .allocate(capacity: pairCount)
    
    for (index, (`protocol`, sourceClass)) in protocolClassPairs.enumerated() {
        protocols[index] = `protocol`
        sourceClasses[index] = sourceClass
    }
    
    let argProtocols = AutoreleasingUnsafeMutablePointer<Protocol>(protocols)
    let argSourceClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(
        sourceClasses
    )
    
    _ = __object_graftProtocols(
        object,
        argProtocols,
        argSourceClasses,
        UInt32(pairCount)
    )
    
    protocols.deallocate()
    sourceClasses.deallocate()
}

public func ObjCGraftImplementations(
    to object: AnyObject,
    with protocolClassPairs: (Protocol, AnyClass)...
    )
{
    ObjCGraftImplementations(to: object, with: protocolClassPairs)
}

// MARK: - Ungraft
public func ObjCUngraftImplementations(
    of protocol: Protocol, on object: AnyObject
    )
{
    _ = __object_ungraftProtocol(object, `protocol`)
}

public func ObjCUngraftImplementations(
    of protocols: Protocol..., on object: AnyObject
    )
{
    _ = ObjCUngraftImplementations(of: protocols, on: object)
}

public func ObjCUngraftImplementations(
    of protocols: [Protocol], on object: AnyObject
    )
{
    let protocolCount = protocols.count
    
    let protocolsPtr = UnsafeMutablePointer<Protocol>
        .allocate(capacity: protocolCount)
    
    for (index, `protocol`) in protocols.enumerated() {
        protocolsPtr[index] = `protocol`
    }
    
    let argProtocols = AutoreleasingUnsafeMutablePointer<Protocol>(protocolsPtr)
    
    _ = __object_ungraftProtocols(
        object,
        argProtocols,
        UInt32(protocolCount)
    )
    
    protocolsPtr.deallocate()
}

public func ObjCUngraftAllImplementationsOfProtocols(
    on object: AnyObject
    )
{
    _ = __object_ungraftAllProtocols(object)
}
