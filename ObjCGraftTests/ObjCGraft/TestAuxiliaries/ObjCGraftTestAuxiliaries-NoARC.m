//
//  ObjCGraftTestAuxiliaries-NoARC.m
//  ObjCGraft
//
//  Created on 1/1/2019.
//

#import "ObjCGraftTestAuxiliaries.h"

#pragma mark - Dealloc
BOOL IsDeallocAccessed = NO;

@implementation ObjectImplementsDealloc
- (void)dealloc
{
    IsDeallocAccessed = YES;
    [super dealloc];
}
@end
