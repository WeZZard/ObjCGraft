//
//  _ObjCCompositedClassBackwardInstanceImpl.h
//  ObjCGrafting
//
//  Created by WeZZard on 02/04/2017.
//
//

#import <Foundation/Foundation.h>

#import "_ObjCCompositedClass.h"

#define _OBJC_COMPOSITED_CLASS_BACKWARD_IMPL_COUNT 3

FOUNDATION_EXTERN void _ObjCCompositedClassInitialize(__unsafe_unretained Class cls);

FOUNDATION_EXTERN void _ObjCCompositedClassSetBackwardInstanceImpl(__unsafe_unretained Class cls, IMP impl, objcgrafting::_ObjCCompositedClass::BackwardInstanceImplKind kind);

FOUNDATION_EXTERN IMP _ObjCCompositedClassGetBackwardInstanceImpl(__unsafe_unretained Class cls, objcgrafting::_ObjCCompositedClass::BackwardInstanceImplKind kind);
