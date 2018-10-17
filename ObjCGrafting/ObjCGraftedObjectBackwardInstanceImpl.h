//
//  ObjCGraftedObjectBackwardInstanceImpl.h
//  ObjCGrafting
//
//  Created by WeZZard on 02/04/2017.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ObjCGraftedObjectBackwardInstanceImplKind) {
    ObjCGraftedObjectBackwardInstanceImplKindDealloc,
    ObjCGraftedObjectBackwardInstanceImplKindClass,
    ObjCGraftedObjectBackwardInstanceImplKindKVOClass
};

#define OBJC_GRAFTED_CLASS_BACKWARD_IMPL_COUNT 3

FOUNDATION_EXTERN void ObjCGraftClassInitialize(__unsafe_unretained Class cls);

FOUNDATION_EXTERN void ObjCGraftClassSetBackwardInstanceImpl(__unsafe_unretained Class cls, IMP impl, ObjCGraftedObjectBackwardInstanceImplKind kind);

FOUNDATION_EXTERN IMP ObjCGraftClassGetBackwardInstanceImpl(__unsafe_unretained Class cls, ObjCGraftedObjectBackwardInstanceImplKind kind);
