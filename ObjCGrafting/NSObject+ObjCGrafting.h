//
//  NSObject+ObjCGrafting.h
//  ObjCGrafting
//
//  Created on 29/12/2018.
//

#ifndef NSObject_ObjCGrafting_h
#define NSObject_ObjCGrafting_h

#import <Foundation/Foundation.h>

typedef Class NSObjectClass (NSObject *, SEL);

typedef void NSObjectDealloc (NSObject * __unsafe_unretained, SEL);

FOUNDATION_EXTERN NSObjectClass _NSObjectClass;
FOUNDATION_EXTERN NSObjectDealloc _NSObjectDealloc;
FOUNDATION_EXTERN NSObjectDealloc _NSObjectSuperDealloc;

#endif /* NSObject_ObjCGrafting_h */
