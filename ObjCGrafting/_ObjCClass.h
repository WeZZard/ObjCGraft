//
//  _ObjCClass.h
//  ObjCGrafting
//
//  Created on 29/12/2018.
//

#ifndef _ObjCClass_h
#define _ObjCClass_h

#import <objc/runtime.h>

namespace objcgrafting {
    class _ObjCClass {
    public:
        template <typename T>
        static T * replaceInstanceMethod(Class cls, SEL selector, T * impl) {
            auto method = class_getInstanceMethod(cls, selector);
            return (T *)class_replaceMethod(cls, selector, (IMP)impl, method_getTypeEncoding(method));
        }
    };
}

#endif /* _ObjCClass_h */
