//
//  _ObjCCompositedClassBackwardInstanceImpl.h
//  ObjCGrafting
//
//  Created by WeZZard on 02/04/2017.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, _ObjCCompositedClassBackwardInstanceImplKind) {
    _ObjCCompositedClassBackwardInstanceImplKindDealloc,
    _ObjCCompositedClassBackwardInstanceImplKindClass,
    _ObjCCompositedClassBackwardInstanceImplKindKVOClass
};

#define _OBJC_COMPOSITED_CLASS_BACKWARD_IMPL_COUNT 3

FOUNDATION_EXTERN void _ObjCCompositedClassInitialize(__unsafe_unretained Class cls);

FOUNDATION_EXTERN void _ObjCCompositedClassSetBackwardInstanceImpl(__unsafe_unretained Class cls, IMP impl, _ObjCCompositedClassBackwardInstanceImplKind kind);

FOUNDATION_EXTERN IMP _ObjCCompositedClassGetBackwardInstanceImpl(__unsafe_unretained Class cls, _ObjCCompositedClassBackwardInstanceImplKind kind);
