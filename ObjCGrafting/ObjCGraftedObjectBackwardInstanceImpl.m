//
//  ObjCGraftedObjectBackwardInstanceImpl.m
//  ObjCGrafting
//
//  Created by WeZZard on 02/04/2017.
//
//

@import ObjectiveC;

#include "ObjCGraftedObjectBackwardInstanceImpl.h"

static inline NSInteger ObjCGraftedObjectBackwardInstanceImplKindGetIndex(ObjCGraftedObjectBackwardInstanceImplKind kind);

NSInteger ObjCGraftedObjectBackwardInstanceImplKindGetIndex(ObjCGraftedObjectBackwardInstanceImplKind kind) {
    switch (kind) {
        case ObjCGraftedObjectBackwardInstanceImplKindDealloc:
            return 0;
            break;
        case ObjCGraftedObjectBackwardInstanceImplKindClass:
            return 1;
            break;
        case ObjCGraftedObjectBackwardInstanceImplKindKVOClass:
            return 2;
        default:
            [NSException raise:NSInvalidArgumentException format:@"Invalid backward instance impl kind: %@", @(kind)];
            break;
    }
}

void ObjCGraftClassInitialize(__unsafe_unretained Class cls) {
    void * * ivars = (void **)object_getIndexedIvars(cls);
    for (int offset = 0; offset < OBJC_GRAFTED_CLASS_BACKWARD_IMPL_COUNT; offset ++) {
        ivars[offset] = NULL;
    }
}

void ObjCGraftClassSetBackwardInstanceImpl(__unsafe_unretained Class cls, IMP impl, ObjCGraftedObjectBackwardInstanceImplKind kind) {
    IMP * impls = (IMP *)object_getIndexedIvars(cls);
    impls[ObjCGraftedObjectBackwardInstanceImplKindGetIndex(kind)] = impl;
}

IMP ObjCGraftClassGetBackwardInstanceImpl(__unsafe_unretained Class cls, ObjCGraftedObjectBackwardInstanceImplKind kind) {
    IMP * impls = (IMP *)object_getIndexedIvars(cls);
    return impls[ObjCGraftedObjectBackwardInstanceImplKindGetIndex(kind)];
}
