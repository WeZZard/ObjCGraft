//
//  _ObjCCompositedClass.h
//  ObjCGrafting
//
//  Created on 30/12/2018.
//

#ifndef _ObjCCompositedClass_h
#define _ObjCCompositedClass_h

#import <objc/runtime.h>

#import "ObjCGraftCommon.h"
#import "_ObjCGraftCombination.h"
#import "_ObjCCompositedClassBackwardInstanceImpl.h"

namespace objcgrafting {
    struct _ObjCCompositedClass {
    public:
        static void addSystemProtocols(__unsafe_unretained Class cls);
        static void addUserDefinedProtocols(__unsafe_unretained Class cls, _ObjCGraftRecordMap& graft_record_map);
        static void addSystemMethods(__unsafe_unretained Class cls);
        static void addUserDefinedMethods(__unsafe_unretained Class cls, _ObjCGraftCombinationList& graftCombinationList);
        
        static void setBackwardInstanceImpl(Class cls, IMP kind, _ObjCCompositedClassBackwardInstanceImplKind instance_impl);
        static IMP getBackwardInstanceImpl(Class cls, _ObjCCompositedClassBackwardInstanceImplKind kind);
    };
}

#endif /* _ObjCCompositedClass_h */
