//
//  ObjCGraft.h
//  ObjCGrafting
//
//  Created by WeZZard on 27/03/2017.
//
//

#import <Foundation/Foundation.h>


/// Objective-C Grafting
/// ====================
/// Objective-C Grafting is a set of tool to graft implementation of a
/// protocol on a class to a specific object.
///
/// How it Works
/// ============
/// The key of Objective-C Grafting is a technology called is-a swizzle,
/// which achieved by function: `object_setClass`.
///
/// Possible Class Hierarchy for Input Object
/// =========================================
///
/// 1. First one is an object didn't adopt any is-a swizzle technologies.
/// ```
/// Root Class:                 NSObject
///                                ^
///                                |
///                               ...
///                                ^
///                                |
/// Topmost/Semantic Class:       Foo
/// ```
///
/// 2. Second one is an object adopted considered is-a swizzle technologies(
/// Currently KVO only).
/// ```
/// Root Class:                 NSObject
///                                ^
///                                |
///                               ...
///                                ^
///                                |
/// Semantic Class:               Foo
///                                ^
///                                |
/// Topmost Class:         NSKVONotifying_Foo
/// ```
///
/// 3. Third one is the output produced with first input.
/// ```
/// Root Class:                 NSObject
///                                ^
///                                |
///                               ...
///                                ^
///                                |
/// Semantic Class:               Foo
///                                ^
///                                |
/// Topmost/Composited Class:  _OjbCGrafted_Foo_GraftedProtocol->SourceClass
///
/// 4. Fourth one is the output produced with second input.
/// ```
/// Root Class:                 NSObject
///                                ^
///                                |
///                               ...
///                                ^
///                                |
/// Semantic Class:               Foo
///                                ^
///                                |
/// Composited Class:  _OjbCGrafted_Foo_GraftedProtocol->SourceClass
///                                ^
///                                |
/// Topmost Class:         NSKVONotifying_Foo
/// ```
///
/// Possible Class Hierarchy for Grafted Object
/// ===========================================
///
/// 1. Respect to the first case of input object.
/// ```
/// Root Class:                 NSObject
///                                ^
///                                |
///                               ...
///                                ^
///                                |
/// Semantic Class:               Foo
///                                ^
///                                |
/// Topmost/Composited Class:  _OjbCGrafted_Foo_GraftedProtocol->SourceClass
/// ```
///
/// 2. Respect to the second case of input object.
/// ```
/// Root Class:                 NSObject
///                                ^
///                                |
///                               ...
///                                ^
///                                |
/// Semantic Class:               Foo
///                                ^
///                                |
/// Composited Class:  _OjbCGrafted_Foo_GraftedProtocol->SourceClass
///                                ^
///                                |
/// Topmost Class:          NSKVONotifying_Foo
/// ```

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Grafting Implementation

/**
 Grafts the implementation of a protocol from a class to an object.

 @param object The object to graft the implementation to.
 
 @param protocol The protocol defines the implementation to be grafted
   with.
 
 @param sourceClass The class contains the implementation to be grafted
   from.
 
 @return The grafted object. The same to the input `object`.
 */
FOUNDATION_EXTERN id object_graftImplementationOfProtocolFromClass(id object, Protocol * protocol, Class sourceClass) NS_REFINED_FOR_SWIFT;


/**
 Grafts the implementation of the protocols from classes to an object.
 
 @note The number of protocols and the number of classes shall be equal.
 
 @param object The object to graft the implementation to.
 
 @param protocols An array of protocols which define the implementations
   to be grafted with.
 
 @param sourceClasses An array of classes which contain the
   implementations to be grafted from.
 
 @param count the count of the `protocols` and `sourceClasses`.
 
 @return The grafted object. The same to the input `object`.
 */
FOUNDATION_EXTERN id object_graftImplementationsOfProtocolsFromClasses(id object, Protocol __unsafe_unretained * _Nonnull *  _Nonnull protocols, __unsafe_unretained Class _Nonnull * _Nonnull sourceClasses, unsigned int count) NS_REFINED_FOR_SWIFT;


/**
 Grafts the implementation of the protocols from classes to an object.
 
 @note The protocols and classes are offered in a nil terminated
   protocol-class paired argument list.
 
 @param object The object to graft the implementation to.
 
 @param firstProtocol The first protocol defines the implementations to be
   grafted with.
 
 @param firstSourceClass The first class contains the implementations to
   be grafted from.
 
 @return The grafted object. The same to the input `object`.
 */
FOUNDATION_EXTERN id object_graftImplementationsOfProtocolsFromClasses_nilTerminated(id object, Protocol * firstProtocol, Class firstSourceClass, ...) NS_REQUIRES_NIL_TERMINATION NS_REFINED_FOR_SWIFT;

/**
 Grafts the implementation of the protocols from a class to an object.
 
 @note The number of protocols and the number of classes shall be equal.
 
 @param object The object to graft the implementation to.
 
 @param sourceClass The class contains the implementations to be grafted
   from.
 
 @param protocols The first protocol defines the implementations to be
   grafted with.
 
 @param count the count of the `protocols`.
 
 @return The grafted object. The same to the input `object`.
 */
FOUNDATION_EXTERN id object_graftImplementationsOfProtocolsFromClass(id object, Protocol __unsafe_unretained * _Nonnull *  _Nonnull protocols, unsigned int count, __unsafe_unretained Class _Nonnull sourceClass) NS_REFINED_FOR_SWIFT;


/**
 Grafts the implementation of the protocols from a class to an object.
 
 @note The protocols and classes are offered in a nil terminated
   protocol-class paired argument list.
 
 @param object The object to graft the implementation to.
 
 @param sourceClass The class contains the implementations to be grafted
   from.
 
 @param firstProtocol The first protocol defines the implementations to be
   removed with.
 
 @return The grafted object. The same to the input `object`.
 */
FOUNDATION_EXTERN id object_graftImplementationsOfProtocolsFromClass_nilTerminated(id object, __unsafe_unretained Class _Nonnull sourceClass, Protocol * firstProtocol, ...) NS_REQUIRES_NIL_TERMINATION NS_REFINED_FOR_SWIFT;

#pragma mark - Removing Grafted Implementation


/**
 Removes the grafted implementation of a protocol from an object.
 
 @param object The object whose grafted implementations to be removed
   from.
 
 @param protocol The protocol defines the implementation to be removed
   with.
 
 @return The object with its grafted implementation removed. The same to
   the input `object`.
 */
FOUNDATION_EXTERN id object_removeGraftedImplementationOfProtocol(id object, Protocol * protocol) NS_REFINED_FOR_SWIFT;


/**
 Removes the grafted implementations of the protocols from an object.
 
 @param object The object whose grafted implementations to be removed
   from.
 
 @param protocols The protocols which define the implementations to be
   removed with.
 
 @param count the count of the `protocols`.
 
 @return The object with its grafted implementations removed. The same to
   the input `object`.
 */
FOUNDATION_EXTERN id object_removeGraftedImplementationsOfProtocols(id object, Protocol __unsafe_unretained * _Nonnull *  _Nonnull protocols, unsigned int count) NS_REFINED_FOR_SWIFT;


/**
 Removes the grafted implementations of the protocols from an object.
 
 @note The protocols are offered in a nil terminated argument list.
 
 @param object The object whose grafted implementations to be removed
   from.
 
 @param firstProtocol The first protocol defines the implementations to be
   removed with.
 
 @return The object with its grafted implementations removed. The same to
   the input `object`.
 */
FOUNDATION_EXTERN id object_removeGraftedImplementationsOfProtocols_nilTerminated(id object, Protocol * firstProtocol, ...) NS_REQUIRES_NIL_TERMINATION NS_REFINED_FOR_SWIFT;


/**
 Removes all the grafted implementations from an object.
 
 
 @param object The object whose grafted implementations to be removed
   from.
 
 @return The object with its grafted implementations removed. The same to
   the input `object`.
 */
FOUNDATION_EXTERN id object_removeAllGraftedImplementations(id object) NS_REFINED_FOR_SWIFT;


#pragma mark - Accessing Grafted Info


/**
 Returns the description about the object's graft info.
 
 @param object The object to be inspected.
 
 @return The description about the object's graft info.
 */
FOUNDATION_EXPORT NSString * object_graftInfoDescription(id object) NS_REFINED_FOR_SWIFT;

NS_ASSUME_NONNULL_END
