//
//  NSObject+ObjCGraft.h
//  ObjCGraft
//
//  Created on 29/12/2018.
//

#ifndef NSObject_ObjCGraft_h
#define NSObject_ObjCGraft_h

#import <Foundation/Foundation.h>

typedef Class NSObjectGetClass (NSObject *, SEL);

typedef void NSObjectDealloc (NSObject * __unsafe_unretained, SEL);

typedef BOOL NSObjectRespondsToSelector (NSObject * __unsafe_unretained, SEL, SEL);

typedef BOOL NSObjectConformsToProtocol (NSObject * __unsafe_unretained, SEL, Protocol *);

FOUNDATION_EXTERN NSObjectGetClass _NSObjectGetClass;
FOUNDATION_EXTERN NSObjectDealloc _NSObjectDealloc;
FOUNDATION_EXTERN NSObjectRespondsToSelector _NSObjectRespondsToSelector;
FOUNDATION_EXTERN NSObjectConformsToProtocol _NSObjectConformsToProtocol;

#endif /* NSObject_ObjCGraft_h */
