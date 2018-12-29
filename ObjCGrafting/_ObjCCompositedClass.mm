//
//  _ObjCCompositedClass.mm
//  ObjCGrafting
//
//  Created on 30/12/2018.
//

#import "_ObjCCompositedClass.h"

#import "_ObjCGrafted.h"
#import "NSObject+ObjCGrafting.h"

namespace objcgrafting {
    void _ObjCCompositedClass::addSystemProtocols(__unsafe_unretained Class cls) {
        // Conforms to _ObjCGrafted.
        class_addProtocol(cls, @protocol(_ObjCGrafted));
    }
    
    void _ObjCCompositedClass::addUserDefinedProtocols(__unsafe_unretained Class cls, _ObjCGraftRecordMap& graft_record_map) {
        for (auto& pair: graft_record_map) {
            class_addProtocol(cls, pair.first);
        }
    }
    
    void _ObjCCompositedClass::addSystemMethods(__unsafe_unretained Class cls) {
        // Add [NSObject -class]
        class_addMethod(cls, @selector(class), (IMP)&_NSObjectClass, "@:");
        
        // Add [NSObject -dealloc]
        class_addMethod(cls, NSSelectorFromString(@"dealloc"), (IMP)&_NSObjectDealloc, "@:");
    }
    
    void _ObjCCompositedClass::addUserDefinedMethods(__unsafe_unretained Class cls, _ObjCGraftCombinationList& graft_combination_list) {
        
        Class metaClass = objc_getMetaClass(class_getName(cls));
        
        for (auto& graft: graft_combination_list) {
            if (graft.is_instance) {
                if (graft.name == @selector(class)) {
                    _ObjCCompositedClass::setBackwardInstanceImpl(cls, graft.impl, _ObjCCompositedClassBackwardInstanceImplKindClass);
                } else if (graft.name == NSSelectorFromString(@"dealloc")) {
                    _ObjCCompositedClass::setBackwardInstanceImpl(cls, graft.impl, _ObjCCompositedClassBackwardInstanceImplKindDealloc);
                } else {
                    class_addMethod(cls, graft.name, graft.impl, graft.types);
                }
            } else {
                class_addMethod(metaClass, graft.name, graft.impl, graft.types);
            }
        }
    }
    
    void _ObjCCompositedClass::setBackwardInstanceImpl(Class cls, IMP impl, _ObjCCompositedClassBackwardInstanceImplKind kind) {
        _ObjCCompositedClassSetBackwardInstanceImpl(cls, impl, kind);
    }
    
    IMP _ObjCCompositedClass::getBackwardInstanceImpl(Class cls, _ObjCCompositedClassBackwardInstanceImplKind kind) {
        return _ObjCCompositedClassGetBackwardInstanceImpl(cls, kind);
    }
    
}
