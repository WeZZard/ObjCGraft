//
//  ClassUtilities.h
//  ObjCGrafting
//
//  Created on 29/12/2018.
//

#ifndef Cls_h
#define Cls_h

#import <objc/runtime.h>

namespace objcgrafting {
    class Cls {
    public:
        template <typename T>
        static T * replaceInstanceMethod(Class cls, SEL selector, T * impl) {
            auto method = class_getInstanceMethod(cls, selector);
            return (T *)class_replaceMethod(cls, selector, (IMP)impl, method_getTypeEncoding(method));
        }
    };
}

#endif /* Cls_hpp */
