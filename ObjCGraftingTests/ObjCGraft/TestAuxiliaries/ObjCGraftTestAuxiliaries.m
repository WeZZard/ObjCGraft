//
//  ObjCGraftTestAuxiliaries.m
//  ObjCGrafting
//
//  Created on 31/12/2018.
//

#import "ObjCGraftTestAuxiliaries.h"

#pragma mark - Protocol 1

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
@implementation ObjectDoesNotImplementGraftedProtocol1
@end
#pragma clang diagnostic pop

@implementation SubObjectImplementsGraftedProtocol1ForSuperclass
- (NSString *)foo1
{
    return @"Foo1";
}

- (NSString *)bar1
{
    return @"Bar1";
}
@end

@implementation ObjectImplementsGraftedProtocol1
- (NSString *)foo1
{
    return @"Foo1";
}

- (NSString *)bar1
{
    return @"Bar1";
}
@end

@implementation SubObjectImplementsGraftedProtocol1
@end

#pragma mark - Protocol 2

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
@implementation ObjectDoesNotImplementGraftedProtocol2
@end
#pragma clang diagnostic pop

@implementation SubObjectImplementsGraftedProtocol2ForSuperclass
- (NSString *)foo2
{
    return @"Foo2";
}

- (NSString *)bar2
{
    return @"Bar2";
}
@end

@implementation ObjectImplementsGraftedProtocol2
- (NSString *)foo2
{
    return @"Foo2";
}

- (NSString *)bar2
{
    return @"Bar2";
}
@end

@implementation SubObjectImplementsGraftedProtocol2
@end

#pragma mark - Mixed Protocols

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
@implementation ObjectDoesNotImplementGraftedProtocols
@end
#pragma clang diagnostic pop

@implementation SubObjectImplementsGraftedProtocolsForSuperclass
- (NSString *)foo1
{
    return @"Foo1";
}

- (NSString *)bar1
{
    return @"Bar1";
}

- (NSString *)foo2
{
    return @"Foo2";
}

- (NSString *)bar2
{
    return @"Bar2";
}
@end

@implementation ObjectImplementsGraftedProtocols
- (NSString *)foo1
{
    return @"Foo1";
}

- (NSString *)bar1
{
    return @"Bar1";
}

- (NSString *)foo2
{
    return @"Foo2";
}

- (NSString *)bar2
{
    return @"Bar2";
}
@end

@implementation SubObjectImplementsGraftedProtocols
@end

#pragma mark - Get Class
BOOL IsClassAccessed = NO;

@implementation ObjectImplementsGetClass
- (Class)class
{
    IsClassAccessed = YES;
    return [super class];
}
@end

#pragma mark - RespondsToSelector
BOOL IsRespondsToSelectorAccessed = NO;

@implementation ObjectImplementsRespondsToSelector
- (BOOL)respondsToSelector:(SEL)aSelector
{
    IsRespondsToSelectorAccessed = YES;
    return [super respondsToSelector: aSelector];
}
@end

#pragma mark - ConformsToSelector
BOOL IsConformsToProtocolAccessed = NO;

@implementation ObjectImplementsConformsToProtocol
- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    IsConformsToProtocolAccessed = YES;
    return [super conformsToProtocol: aProtocol];
}
@end
