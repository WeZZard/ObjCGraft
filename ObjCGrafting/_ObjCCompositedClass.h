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

namespace objcgrafting {
    /// A set of tools to help with the composited class in grafting.
    ///
    struct _ObjCCompositedClass {
    public:
        enum class BackwardInstanceImplKind {
            Dealloc, ClassGetter, KVOClassGetter
        };
        
    public:
        static Class make(__unsafe_unretained Class semantic_class, const char * raw_class_name, _ObjCGraftRecordMap& graft_record_map);
    private:
        static void _addSystemProtocols(__unsafe_unretained Class cls);
        static void _addUserDefinedProtocols(__unsafe_unretained Class cls, _ObjCGraftRecordMap& graft_record_map);
        static void _addSystemMethods(__unsafe_unretained Class cls);
        static void _addUserDefinedMethods(__unsafe_unretained Class cls, _ObjCGraftCombinationList& graftCombinationList);
        
    public:
        static void setBackwardInstanceImpl(Class cls, IMP kind, BackwardInstanceImplKind instance_impl);
        static IMP getBackwardInstanceImpl(Class cls, BackwardInstanceImplKind kind);
    };
}

#endif /* _ObjCCompositedClass_h */
