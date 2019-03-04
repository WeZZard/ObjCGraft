//
//  NSObjectKeyValueObservingTestAuxiliaries.m
//  ObjCGraft
//
//  Created on 1/1/2019.
//

#import "NSObjectKeyValueObservingTestAuxiliaries.h"

@implementation NSObjectDerivedDummyModel
- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}
@end
