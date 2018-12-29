//
//  _ObjCCompositedClassBackwardInstanceImpl.m
//  ObjCGrafting
//
//  Created by WeZZard on 02/04/2017.
//
//

@import ObjectiveC;

#include "_ObjCCompositedClassBackwardInstanceImpl.h"

static inline NSInteger _ObjCCompositedClassBackwardInstanceImplKindGetIndex(_ObjCCompositedClassBackwardInstanceImplKind kind);

NSInteger _ObjCCompositedClassBackwardInstanceImplKindGetIndex(_ObjCCompositedClassBackwardInstanceImplKind kind) {
    switch (kind) {
        case _ObjCCompositedClassBackwardInstanceImplKindDealloc:
            return 0;
            break;
        case _ObjCCompositedClassBackwardInstanceImplKindClass:
            return 1;
            break;
        case _ObjCCompositedClassBackwardInstanceImplKindKVOClass:
            return 2;
        default:
            [NSException raise:NSInvalidArgumentException format:@"Invalid backward instance impl kind: %@", @(kind)];
            break;
    }
}

void _ObjCCompositedClassInitialize(__unsafe_unretained Class cls) {
    void * * ivars = (void **)object_getIndexedIvars(cls);
    for (int offset = 0; offset < _OBJC_COMPOSITED_CLASS_BACKWARD_IMPL_COUNT; offset ++) {
        ivars[offset] = NULL;
    }
}

void _ObjCCompositedClassSetBackwardInstanceImpl(__unsafe_unretained Class cls, IMP impl, _ObjCCompositedClassBackwardInstanceImplKind kind) {
    IMP * impls = (IMP *)object_getIndexedIvars(cls);
    impls[_ObjCCompositedClassBackwardInstanceImplKindGetIndex(kind)] = impl;
}

IMP _ObjCCompositedClassGetBackwardInstanceImpl(__unsafe_unretained Class cls, _ObjCCompositedClassBackwardInstanceImplKind kind) {
    IMP * impls = (IMP *)object_getIndexedIvars(cls);
    return impls[_ObjCCompositedClassBackwardInstanceImplKindGetIndex(kind)];
}
