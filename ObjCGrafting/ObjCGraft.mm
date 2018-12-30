//
//  ObjCGraft.m
//  ObjCGrafting
//
//  Created by WeZZard on 27/03/2017.
//
//

#import "ObjCGraft.h"
#import "ObjCGraftCommon.h"
#import "_ObjCGraftCenter.h"
#import "_ObjCGraftInfo.h"

#pragma mark - Implementations of C Bindings
id object_graftImplementationOfProtocol(id object, Protocol * protocol, Class sourceClass) {
    Protocol * __unsafe_unretained unsafe_unretained_protocol = protocol;
    auto requests = objcgrafting::_ObjCGraftCenter::shared().makeGraftRequests(&unsafe_unretained_protocol, &sourceClass, 1);
    objcgrafting::_ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::_ObjCGraftCenter::shared().graftImplementationOfProtocolsFromClassesToObject(object, * requests);
    objcgrafting::_ObjCGraftCenter::shared().unlock();
    return retVal;
}

id object_graftImplementationsOfProtocols(id object, Protocol * _Nonnull *  _Nonnull protocols, __unsafe_unretained Class _Nonnull * _Nonnull sourceClasses, unsigned int count) {
    Protocol * __unsafe_unretained unsafe_unretained_first_protocol = * protocols;
    Protocol * __unsafe_unretained * unsafe_unretained_protocols = &unsafe_unretained_first_protocol;
    auto requests = objcgrafting::_ObjCGraftCenter::shared().makeGraftRequests(unsafe_unretained_protocols, sourceClasses, count);
    objcgrafting::_ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::_ObjCGraftCenter::shared().graftImplementationOfProtocolsFromClassesToObject(object, * requests);
    objcgrafting::_ObjCGraftCenter::shared().unlock();
    return retVal;
}

id object_graftImplementationsOfProtocols_nilTerminated(id object, Protocol * firstProtocol, Class firstSourceClass, ...) {
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

id object_removeGraftedImplementationOfProtocol(id object, Protocol * protocol) {
    Protocol * __unsafe_unretained unsafe_unretained_protocol = protocol;
    objcgrafting::_ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::_ObjCGraftCenter::shared().removeGraftedImplementationsOfProtocolsFromObject(object, &unsafe_unretained_protocol, 1);
    objcgrafting::_ObjCGraftCenter::shared().unlock();
    return retVal;
}

id object_removeGraftedImplementationsOfProtocols(id object, Protocol * _Nonnull *  _Nonnull protocols, unsigned int count) {
    Protocol * __unsafe_unretained unsafe_unretained_first_protocol = * protocols;
    Protocol * __unsafe_unretained * unsafe_unretained_protocols = &unsafe_unretained_first_protocol;
    objcgrafting::_ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::_ObjCGraftCenter::shared().removeGraftedImplementationsOfProtocolsFromObject(object, unsafe_unretained_protocols, count);
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
