//
//  ObjCGraft.m
//  ObjCGrafting
//
//  Created by WeZZard on 27/03/2017.
//
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "ObjCGraft.h"
#import "_ObjCGraftInternal.h"
#import "_ObjCGraftCenter.h"
#import "_ObjCGraftInfo.h"


#define _NSCPrecondition(condition, desc, ...) \
if (__builtin_expect(!(condition), 0)) { \
    [NSException raise: NSInternalInconsistencyException \
                format: (desc), ##__VA_ARGS__]; \
}

#pragma mark - Grafting Implementation


id object_graftImplementationOfProtocolFromClass(id object, Protocol * protocol, Class sourceClass) {
    Protocol * __unsafe_unretained unsafe_unretained_protocol = protocol;
    auto requests = objcgrafting::_ObjCGraftCenter::shared().makeGraftRequests(&unsafe_unretained_protocol, &sourceClass, 1);
    objcgrafting::_ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::_ObjCGraftCenter::shared().graftImplementationOfProtocolsFromClassesToObject(object, * requests);
    objcgrafting::_ObjCGraftCenter::shared().unlock();
    return retVal;
}


id object_graftImplementationsOfProtocolsFromClasses(id object, Protocol __unsafe_unretained * _Nonnull *  _Nonnull protocols, __unsafe_unretained Class _Nonnull * _Nonnull sourceClasses, unsigned int count) {
    auto requests = objcgrafting::_ObjCGraftCenter::shared().makeGraftRequests(protocols, sourceClasses, count);
    objcgrafting::_ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::_ObjCGraftCenter::shared().graftImplementationOfProtocolsFromClassesToObject(object, * requests);
    objcgrafting::_ObjCGraftCenter::shared().unlock();
    return retVal;
}


id object_graftImplementationsOfProtocolsFromClasses_nilTerminated(id object, Protocol * firstProtocol, Class firstSourceClass, ...) {
    _NSCPrecondition(objc_getMetaClass(class_getName(object_getClass(firstProtocol))) == objc_getMetaClass(class_getName(object_getClass(@protocol(NSObject)))), @"firstProtocol is not a protocol.");
    _NSCPrecondition(objc_getMetaClass(class_getName(object_getClass(firstSourceClass))) != objc_getMetaClass(class_getName(object_getClass(@protocol(NSObject)))), @"firstSourceClass is not a class.");
    
    Protocol * each_protocol;
    Class each_source_class;
    
    va_list arg_list;
    
    auto protocols = std::make_unique<std::vector<Protocol * __unsafe_unretained>>();
    protocols -> push_back(firstProtocol);
    auto source_classes = std::make_unique<std::vector<__unsafe_unretained Class>>();
    source_classes -> push_back(firstSourceClass);
    
    unsigned int count = 1;
    
    va_start(arg_list, firstSourceClass);
    while ((each_protocol = va_arg(arg_list, Protocol *)) && (each_source_class = va_arg(arg_list, Class))) {
        _NSCPrecondition(objc_getMetaClass(class_getName(object_getClass(each_protocol))) == objc_getMetaClass(class_getName(object_getClass(@protocol(NSObject)))), @"%@ is not a protocol.", each_protocol);
        _NSCPrecondition(objc_getMetaClass(class_getName(object_getClass(each_source_class))) != objc_getMetaClass(class_getName(object_getClass(@protocol(NSObject)))), @"%@ is not a class.", each_source_class);
        
        protocols -> push_back(each_protocol);
        source_classes -> push_back(each_source_class);
        
        count += 1;
    }
    va_end(arg_list);
    
    auto protocol_array = &(* protocols)[0];
    auto source_classes_array = &(* source_classes)[0];
    
    auto requests = objcgrafting::_ObjCGraftCenter::shared().makeGraftRequests(protocol_array, source_classes_array, count);
    
    objcgrafting::_ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::_ObjCGraftCenter::shared().graftImplementationOfProtocolsFromClassesToObject(object, * requests);
    objcgrafting::_ObjCGraftCenter::shared().unlock();
    return retVal;
}


id object_graftImplementationsOfProtocolsFromClass(id object, Protocol __unsafe_unretained * _Nonnull *  _Nonnull protocols, unsigned int count, __unsafe_unretained Class _Nonnull sourceClass) {
    auto requests = objcgrafting::_ObjCGraftCenter::shared().makeGraftRequests(protocols, count, sourceClass);
    objcgrafting::_ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::_ObjCGraftCenter::shared().graftImplementationOfProtocolsFromClassesToObject(object, * requests);
    objcgrafting::_ObjCGraftCenter::shared().unlock();
    return retVal;
}


id object_graftImplementationsOfProtocolsFromClass_nilTerminated(id object, __unsafe_unretained Class _Nonnull sourceClass, Protocol * firstProtocol, ...) {
    Protocol * each_protocol;
    
    va_list arg_list;
    
    auto protocols = std::make_unique<std::vector<Protocol * __unsafe_unretained>>();
    protocols -> push_back(firstProtocol);
    
    unsigned int count = 1;
    
    va_start(arg_list, firstProtocol);
    while ((each_protocol = va_arg(arg_list, Protocol *))) {
        protocols -> push_back(each_protocol);
        
        count += 1;
    }
    va_end(arg_list);
    
    auto protocol_array = &(* protocols)[0];
    
    auto requests = objcgrafting::_ObjCGraftCenter::shared().makeGraftRequests(protocol_array, count, sourceClass);
    
    objcgrafting::_ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::_ObjCGraftCenter::shared().graftImplementationOfProtocolsFromClassesToObject(object, * requests);
    objcgrafting::_ObjCGraftCenter::shared().unlock();
    return retVal;
}


#pragma mark - Removing Grafted Implementation


id object_removeGraftedImplementationOfProtocol(id object, Protocol * protocol) {
    Protocol * __unsafe_unretained unsafe_unretained_protocol = protocol;
    objcgrafting::_ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::_ObjCGraftCenter::shared().removeGraftedImplementationsOfProtocolsFromObject(object, &unsafe_unretained_protocol, 1);
    objcgrafting::_ObjCGraftCenter::shared().unlock();
    return retVal;
}


id object_removeGraftedImplementationsOfProtocols(id object, Protocol * __unsafe_unretained _Nonnull *  _Nonnull protocols, unsigned int count) {
    objcgrafting::_ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::_ObjCGraftCenter::shared().removeGraftedImplementationsOfProtocolsFromObject(object, protocols, count);
    objcgrafting::_ObjCGraftCenter::shared().unlock();
    return retVal;
}


id object_removeGraftedImplementationsOfProtocols_nilTerminated(id object, Protocol * firstProtocol, ...) {
    Protocol * each_protocol;
    
    va_list arg_list;
    
    auto protocols = std::make_unique<std::vector<Protocol * __unsafe_unretained>>();
    protocols -> push_back(firstProtocol);
    
    unsigned int count = 1;
    
    va_start(arg_list, firstProtocol);
    while ((each_protocol = va_arg(arg_list, Protocol *))) {
        protocols -> push_back(each_protocol);
        
        count += 1;
    }
    va_end(arg_list);
    
    auto protocol_array = &(* protocols)[0];
    
    objcgrafting::_ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::_ObjCGraftCenter::shared().removeGraftedImplementationsOfProtocolsFromObject(object, protocol_array, count);
    objcgrafting::_ObjCGraftCenter::shared().unlock();
    return retVal;
}


id object_removeAllGraftedImplementations(id object) {
    objcgrafting::_ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::_ObjCGraftCenter::shared().removeGraftedImplementationsFromObject(object);
    objcgrafting::_ObjCGraftCenter::shared().unlock();
    return retVal;
}


#pragma mark - Accessing Grafted Info


NSString * object_graftInfoDescription(id object) {
    NSString * description = nil;
    objcgrafting::_ObjCGraftCenter::shared().lock();
    if (objcgrafting::_ObjCGraftCenter::shared().objectHasGraftInfo(object)) {
        NSString * graftInfoDescription = objcgrafting::_ObjCGraftCenter::shared().objectGetGraftInfo(object).description();
        description = [NSString stringWithFormat:@"<%@: %p>\n%@", [object class], object, graftInfoDescription];
    } else {
        description = [NSString stringWithFormat:@"<%@: %p> No Graft Info.", [object class], object];
    }
    objcgrafting::_ObjCGraftCenter::shared().unlock();
    return description;
}

