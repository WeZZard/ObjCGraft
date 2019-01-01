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

/// Grafts the implementation of a protocol from a class to an object.
///
/// - Parameter protocol: The protocol defines the implementation to be
///   grafted with.
///
/// - Parameter class: The class contains the implementation to be grafted
///   from.
///
/// - Parameter object: The object to graft the implementation to.
///
/// - Returns: The grafted object. The same to the input `object`.
///
public func ObjCGraftImplementation<P>(
    of protocol: P.Type,
    from class: AnyClass,
    to object: AnyObject
    ) -> P
{
    assert(`class` is P)
    let asAnyObject = `protocol` as AnyObject
    let asObjCProtocol = asAnyObject as! Protocol
    let object = __object_graftImplementationOfProtocolFromClass(object, asObjCProtocol, `class`)
    return unsafeBitCast(object as AnyObject, to: P.self)
}


/// Grafts the implementation of protocols from classes to an object.
///
/// - Parameter object: The object to graft the implementation to.
///
/// - Parameter protocolClassPairs: An array of protocol-class pair which
///   the protocol defines the implementations to be grafted with and the
///   class defines the implementations to be grafted from.
///
/// - Returns: The grafted object. The same to the input `object`.
///
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
    
    _ = __object_graftImplementationsOfProtocolsFromClasses(
        object,
        argProtocols,
        argSourceClasses,
        UInt32(pairCount)
    )
    
    protocols.deallocate()
    sourceClasses.deallocate()
}


/// Grafts the implementation of protocols from classes to an object.
///
/// - Parameter object: The object to graft the implementation to.
///
/// - Parameter protocolClassPairs: An protocol-class pair which the
///   protocol defines the implementations to be grafted with and the
///   class defines the implementations to be grafted from.
///
/// - Returns: The grafted object. The same to the input `object`.
///
public func ObjCGraftImplementations(
    to object: AnyObject,
    with protocolClassPair: (Protocol, AnyClass)...
    )
{
    ObjCGraftImplementations(to: object, with: protocolClassPair)
}


/// Grafts the implementation of protocols from classes to an object.
///
/// - Parameter object: The object to graft the implementation to.
///
/// - Parameter protocols: The protocols define the implementations to be
///   grafted with.
///
/// - Parameter sourceClass: The class holds the implementations to be
///   grafted from.
///
/// - Returns: The grafted object. The same to the input `object`.
///
public func ObjCGraftImplementations(
    to object: AnyObject,
    with protocols: [Protocol],
    from sourceClass: AnyClass
    )
{
    let pairCount = protocols.count
    
    let protocolsPtr = UnsafeMutablePointer<Protocol>
        .allocate(capacity: pairCount)
    
    for (index, `protocol`) in protocols.enumerated() {
        protocolsPtr[index] = `protocol`
    }
    
    let argProtocols = AutoreleasingUnsafeMutablePointer<Protocol>(protocolsPtr)
    
    _ = __object_graftImplementationsOfProtocolsFromClass(
        object,
        argProtocols,
        UInt32(pairCount),
        sourceClass
    )
    
    protocolsPtr.deallocate()
}


/// Grafts the implementation of protocols from classes to an object.
///
/// - Parameter object: The object to graft the implementation to.
///
/// - Parameter sourceClass: The class holds the implementations to be
///   grafted from.
///
/// - Parameter protocol: A protocol defines the implementations to be
///   grafted with.
///
/// - Returns: The grafted object. The same to the input `object`.
///
public func ObjCGraftImplementations(
    to object: AnyObject,
    from sourceClass: AnyClass,
    with protocol: Protocol...
    )
{
    ObjCGraftImplementations(
        to: object,
        with: `protocol`,
        from: sourceClass
    )
}


// MARK: - Remove

/// Removes the grafted implementation of the protocol from an object.
///
/// - Parameter protocol: The protocol defines the implementation to be
///   removed with.
///
/// - Parameter object: The object whose grafted implementations to be
///   removed from.
///
/// - Returns: The object with its grafted implementations removed. The
///   same to the input `object`.
///
public func ObjCRemoveGraftedImplementations(
    of protocol: Protocol,
    from object: AnyObject
    )
{
    _ = __object_removeGraftedImplementationOfProtocol(object, `protocol`)
}


/// Removes the grafted implementation of protocols from an object.
///
/// - Parameter object: The object whose grafted implementations to be
///   removed from.
///
/// - Parameter protocol: The protocol defines the implementation to be
///   removed with.
///
/// - Returns: The object with its grafted implementations removed. The
///   same to the input `object`.
///
public func ObjCRemoveGraftedImplementations(
    from object: AnyObject,
    of protocol: Protocol...
    )
{
    _ = ObjCRemoveGraftedImplementations(from: object, of: `protocol`)
}


/// Removes the grafted implementation of protocols from an object.
///
/// - Parameter object: The object whose grafted implementations to be
///   removed from.
///
/// - Parameter protocol: The protocols which define the implementations
///   to be removed with.
///
/// - Returns: The object with its grafted implementations removed. The
///   same to the input `object`.
///
public func ObjCRemoveGraftedImplementations(
    from object: AnyObject,
    of protocols: [Protocol]
    )
{
    let protocolCount = protocols.count
    
    let protocolsPtr = UnsafeMutablePointer<Protocol>
        .allocate(capacity: protocolCount)
    
    for (index, `protocol`) in protocols.enumerated() {
        protocolsPtr[index] = `protocol`
    }
    
    let argProtocols = AutoreleasingUnsafeMutablePointer<Protocol>(protocolsPtr)
    
    _ = __object_removeGraftedImplementationsOfProtocols(
        object,
        argProtocols,
        UInt32(protocolCount)
    )
    
    protocolsPtr.deallocate()
}


/// Removes all the grafted implementations from an object.
///
/// - Parameter object: The object whose grafted implementations to be
///   removed from.
///
/// - Returns: The object with its grafted implementations removed. The
///   same to the input `object`.
///
public func ObjCRemoveAllGraftedImplementations(from object: AnyObject) {
    _ = __object_removeAllGraftedImplementations(object)
}
