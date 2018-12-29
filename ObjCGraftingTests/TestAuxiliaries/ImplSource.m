//
//  ImplSource.m
//  ObjCGrafting
//
//  Created on 29/12/2018.
//

#import "ImplSource.h"

@implementation ImplSource
- (NSInteger)intValue
{
    [self accessFromSelector:_cmd withName:[ImplSource description]];
    return 0;
}

- (void)parentInstanceMethod
{
    [self accessFromSelector:_cmd withName:[ImplSource description]];
}

+ (void)parentClassMethod
{
    [self accessFromSelector:_cmd withName:[ImplSource description]];
}

- (void)childInstanceMethod
{
    [self accessFromSelector:_cmd withName:[ImplSource description]];
}

+ (void)childClassMethod
{
    [self accessFromSelector:_cmd withName:[ImplSource description]];
}
@end

