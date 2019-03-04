//
//  _ObjCCompositedClassBackwardInstanceImpl.m
//  ObjCGraft
//
//  Created by WeZZard on 02/04/2017.
//
//

#import <objc/runtime.h>

#import "_ObjCCompositedClassBackwardInstanceImpl.h"

static inline NSInteger _ObjCCompositedClassBackwardInstanceImplKindGetIndex(objcgraft::_ObjCCompositedClass::BackwardInstanceImplKind kind);

NSInteger _ObjCCompositedClassBackwardInstanceImplKindGetIndex(objcgraft::_ObjCCompositedClass::BackwardInstanceImplKind kind) {
    switch (kind) {
        case objcgraft::_ObjCCompositedClass::BackwardInstanceImplKind::Dealloc:
            return 0;
            break;
        case objcgraft::_ObjCCompositedClass::BackwardInstanceImplKind::ClassGetter:
            return 1;
            break;
        case objcgraft::_ObjCCompositedClass::BackwardInstanceImplKind::KVOClassGetter:
            return 2;
            break;
        case objcgraft::_ObjCCompositedClass::BackwardInstanceImplKind::RespondsToSelector:
            return 3;
            break;
        case objcgraft::_ObjCCompositedClass::BackwardInstanceImplKind::ConformsToProtocol:
            return 4;
            break;
        default:
            [NSException raise:NSInvalidArgumentException format:@"Invalid backward instance impl kind."];
            break;
    }
}

void _ObjCCompositedClassInitialize(__unsafe_unretained Class cls) {
    void * * ivars = (void **)object_getIndexedIvars(cls);
    for (int offset = 0; offset < _OBJC_COMPOSITED_CLASS_BACKWARD_IMPL_COUNT; offset ++) {
        ivars[offset] = NULL;
    }
}

void _ObjCCompositedClassSetBackwardInstanceImpl(__unsafe_unretained Class cls, IMP impl, objcgraft::_ObjCCompositedClass::BackwardInstanceImplKind kind) {
    IMP * impls = (IMP *)object_getIndexedIvars(cls);
    impls[_ObjCCompositedClassBackwardInstanceImplKindGetIndex(kind)] = impl;
}

IMP _ObjCCompositedClassGetBackwardInstanceImpl(__unsafe_unretained Class cls, objcgraft::_ObjCCompositedClass::BackwardInstanceImplKind kind) {
    IMP * impls = (IMP *)object_getIndexedIvars(cls);
    return impls[_ObjCCompositedClassBackwardInstanceImplKindGetIndex(kind)];
}
