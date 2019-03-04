//
//  ObjCGraftTestAuxiliaries.h
//  ObjCGraft
//
//  Created on 31/12/2018.
//

#import <Foundation/Foundation.h>

#pragma mark - Protocol 1
@protocol GraftedProtocol1<NSObject>
- (NSString *)foo1;
@end

@protocol SubGraftedProtocol1<GraftedProtocol1>
- (NSString *)bar1;
@end

@interface ObjectDoesNotImplementGraftedProtocol1: NSObject<SubGraftedProtocol1>
@end

@interface SubObjectImplementsGraftedProtocol1ForSuperclass: ObjectDoesNotImplementGraftedProtocol1
@end

@interface ObjectImplementsGraftedProtocol1: NSObject<SubGraftedProtocol1>
@end

@interface SubObjectImplementsGraftedProtocol1: ObjectImplementsGraftedProtocol1
@end

#pragma mark - Protocol 2
@protocol GraftedProtocol2<NSObject>
- (NSString *)foo2;
@end

@protocol SubGraftedProtocol2<GraftedProtocol2>
- (NSString *)bar2;
@end

@interface ObjectDoesNotImplementGraftedProtocol2: NSObject<SubGraftedProtocol2>
@end

@interface SubObjectImplementsGraftedProtocol2ForSuperclass: ObjectDoesNotImplementGraftedProtocol2
@end

@interface ObjectImplementsGraftedProtocol2: NSObject<SubGraftedProtocol2>
@end

@interface SubObjectImplementsGraftedProtocol2: ObjectImplementsGraftedProtocol2
@end

#pragma mark - Mixed Protocols
@interface ObjectDoesNotImplementGraftedProtocols: NSObject<SubGraftedProtocol1, SubGraftedProtocol2>
@end

@interface SubObjectImplementsGraftedProtocolsForSuperclass: ObjectDoesNotImplementGraftedProtocols
@end

@interface ObjectImplementsGraftedProtocols: NSObject<SubGraftedProtocol1, SubGraftedProtocol2>
@end

@interface SubObjectImplementsGraftedProtocols: ObjectImplementsGraftedProtocols
@end

#pragma mark - Dealloc
FOUNDATION_EXTERN BOOL IsDeallocAccessed;

@protocol Dealloc<NSObject>
- (void)dealloc;
@end

@interface ObjectImplementsDealloc: NSObject<Dealloc>
@end

#pragma mark - Get Class
FOUNDATION_EXTERN BOOL IsClassAccessed;

@protocol GetClass<NSObject>
- (Class)class;
@end

@interface ObjectImplementsGetClass: NSObject<GetClass>
@end

#pragma mark - RespondsToSelector
FOUNDATION_EXTERN BOOL IsRespondsToSelectorAccessed;

@protocol RespondsToSelector<NSObject>
- (BOOL)respondsToSelector:(SEL)aSelector;
@end

@interface ObjectImplementsRespondsToSelector: NSObject<RespondsToSelector>
@end

#pragma mark - ConformsToProtocol
FOUNDATION_EXTERN BOOL IsConformsToProtocolAccessed;

@protocol ConformsToProtocol<NSObject>
- (BOOL)conformsToProtocol:(Protocol *)aProtocol;
@end

@interface ObjectImplementsConformsToProtocol: NSObject<ConformsToProtocol>
@end
