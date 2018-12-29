//
//  _ObjCGraftInfo.h
//  ObjCGrafting
//
//  Created on 29/12/2018.
//

#ifndef _ObjCGraftInfo_h
#define _ObjCGraftInfo_h

#import <objc/runtime.h>

#include <memory>
#include <unordered_map>

#import "ObjCGraftCommon.h"

namespace objcgrafting {
    struct _ObjCGraftInfo {
        /// Since other is-a swizzle dependent technologies like KVO may
        /// override `NSObject`'s `class` method to masquerade as nothing
        /// happened on it, we don't use `object_getClass` to get the true
        /// original class but `[NSObject -class]` the masqueraded.
        __unsafe_unretained Class semantic_class;
        
        /// The composited class with grafted implementations.
        __unsafe_unretained Class composited_class;
        
        /// The priority of grafted protocols.
        std::unique_ptr<_ObjCProtocolList> grafted_protocol_list;
        
        /// The relationship of protocols and source-classes.
        std::unique_ptr<_ObjCGraftRecordMap> graft_record_map;
        
        _ObjCGraftInfo(__unsafe_unretained Class semantic_class, __unsafe_unretained Class composited_class, _ObjCProtocolList& grafted_protocol_list, _ObjCGraftRecordMap& graft_record_map);
        
        /// Returns `true` when the `_ObjCGraftInfo` itself was mutated due to this registration.
        bool push(Protocol * __unsafe_unretained *  protocols, __unsafe_unretained Class * source_classes, unsigned int count);
        
        /// Returns `true` when the `_ObjCGraftInfo` itself was mutated due to this unregistration.
        bool pop(Protocol * __unsafe_unretained * protocols, unsigned int count);
    };
    
    typedef std::unordered_map<id __unsafe_unretained , std::unique_ptr<_ObjCGraftInfo>, _ObjCIdHasher> _ObjCGraftInfoMap;
}


#endif /* _ObjCGraftInfo_h */