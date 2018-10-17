//
//  ObjCGraft.h
//  ObjCGrafting
//
//  Created by WeZZard on 27/03/2017.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN id object_graftProtocol(id object, Protocol * protocol, Class sourceClass) NS_REFINED_FOR_SWIFT;

FOUNDATION_EXTERN id object_graftProtocols(id object, Protocol * _Nonnull *  _Nonnull protocols, __unsafe_unretained Class _Nonnull * _Nonnull sourceClasses, unsigned int count) NS_REFINED_FOR_SWIFT;

FOUNDATION_EXTERN id object_graftProtocolsWithNilTermination(id object, Protocol * firstProtocol, Class firstSourceClass, ...) NS_REQUIRES_NIL_TERMINATION NS_REFINED_FOR_SWIFT;

FOUNDATION_EXTERN id object_ungraftProtocol(id object, Protocol * protocol) NS_REFINED_FOR_SWIFT;

FOUNDATION_EXTERN id object_ungraftProtocols(id object, Protocol * _Nonnull *  _Nonnull protocols, unsigned int count) NS_REFINED_FOR_SWIFT;

FOUNDATION_EXTERN id object_ungraftProtocolsWithNilTermination(id object, Protocol * firstProtocol, ...) NS_REQUIRES_NIL_TERMINATION NS_REFINED_FOR_SWIFT;

FOUNDATION_EXTERN id object_ungraftAllProtocols(id object) NS_REFINED_FOR_SWIFT;

NS_ASSUME_NONNULL_END
