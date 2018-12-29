//
//  NSObject+ObjCGrafting.mm
//  ObjCGrafting
//
//  Created on 29/12/2018.
//

#import <objc/message.h>

#import "NSObject+ObjCGrafting.h"
#import "_ObjCGraftCenter.h"
#import "_ObjCGraftInfo.h"

void _NSObjectDealloc(NSObject * __unsafe_unretained self, SEL _cmd) {
    if (objcgrafting::_ObjCGraftCenter::shared().objectHasGraftInfo(self)) {
        NSObjectDealloc * customImpl = (NSObjectDealloc *)objcgrafting::_ObjCGraftCenter::shared().objectGetBackwardInstanceImpl(self, _ObjCCompositedClassBackwardInstanceImplKindDealloc);
        
        if (customImpl != nullptr) {
            (* customImpl)(self, _cmd);
        } else {
            _NSObjectSuperDealloc(self, _cmd);
        }
        
        objcgrafting::_ObjCGraftCenter::shared().lock();
        objcgrafting::_ObjCGraftCenter::shared().objectWillDealloc(self);
        objcgrafting::_ObjCGraftCenter::shared().unlock();
    } else {
        _NSObjectSuperDealloc(self, _cmd);
    }
}

void _NSObjectSuperDealloc(NSObject * __unsafe_unretained self, SEL _cmd) {
    struct objc_super superclass = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    
    typedef void SuperMsg (struct objc_super *, SEL);
    SuperMsg * superImpl = (SuperMsg *)objc_msgSendSuper;
    (* superImpl)(&superclass, _cmd);
}

Class _NSObjectClass(NSObject * self, SEL _cmd) {
    objcgrafting::_ObjCGraftCenter::shared().lock();
    
    auto& graft_info = objcgrafting::_ObjCGraftCenter::shared().objectGetGraftInfo(self);
    
    Class semantic_calss = graft_info.semantic_class;
    
    NSObjectClass * customImpl = (NSObjectClass *)objcgrafting::_ObjCGraftCenter::shared().objectGetBackwardInstanceImpl(self, _ObjCCompositedClassBackwardInstanceImplKindClass);
    
    if (customImpl) {
#if DEBUG
        Class retVal = (* customImpl)(self, _cmd);
        NSLog(@"The return value(\"%@\") of your implementation defined for selector \"-class\" grafted on class \"%@\" was omitted.", NSStringFromClass(retVal), NSStringFromClass(semantic_calss));
#else
        (* customImpl)(self, _cmd);
#endif
    }
    
    assert(semantic_calss != nil);
    
    objcgrafting::_ObjCGraftCenter::shared().unlock();
    
    return semantic_calss;
}
