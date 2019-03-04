//
//  NSArray_KeyValueObservingWithImplementationsGraftedTests.m
//  ObjCGraft
//
//  Created on 1/1/2019.
//

#import <XCTest/XCTest.h>
#import <dispatch/dispatch.h>
#import <objc/runtime.h>

#import <ObjCGraft/ObjCGraft.h>

#import "ObjCGraftTestAuxiliaries.h"
#import "NSObjectKeyValueObservingTestAuxiliaries.h"

static NSString * _kNSObjectDerivedDummyModelObservationContext = @"com.WeZZard.ObjCGraft.NSObject_KeyValueObservingWithImplementationsGraftedTests.NSObjectDerivedDummyModelObservationContext";

@interface NSArray_KeyValueObservingWithImplementationsGraftedTests : XCTestCase
@property (nonatomic, strong) NSArray * objects;
@property (nonatomic, strong) NSObjectDerivedDummyModel * object;
@property (nonatomic, assign) BOOL isNameAccessed;
@end

@implementation NSArray_KeyValueObservingWithImplementationsGraftedTests
- (void)setUp
{
    self.isNameAccessed = NO;
    self.object = [[NSObjectDerivedDummyModel alloc] initWithName: @""];
    self.objects = [NSArray arrayWithObject: self.object];
    
}

- (void)tearDown
{
    self.object = nil;
    self.objects = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context == (__bridge void *)_kNSObjectDerivedDummyModelObservationContext) {
        self.isNameAccessed = YES;
    } else {
        [super observeValueForKeyPath: keyPath ofObject: object change: change context: context];
    }
}

- (void)testNSObjectAddObserverForKeyPathOptionsContext_RemoveObserverForKeyPath
{
    [self.objects addObserver: self
           toObjectsAtIndexes: [NSIndexSet indexSetWithIndex: 0]
                   forKeyPath: @"name"
                      options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                      context: (void *)_kNSObjectDerivedDummyModelObservationContext];
    
    XCTAssertFalse(self.isNameAccessed);
    
    self.object.name = @"test";
    
    XCTAssertTrue(self.isNameAccessed);
    
    self.isNameAccessed = NO;
    
    [self.objects removeObserver: self
            fromObjectsAtIndexes: [NSIndexSet indexSetWithIndex: 0]
                      forKeyPath: @"name"];
    
    self.object.name = @"test";
    
    XCTAssertFalse(self.isNameAccessed);
    
}

- (void)testNSObjectAddObserverForKeyPathOptionsContext_RemoveObserverForKeyPathContext
{
    [self.objects addObserver: self
           toObjectsAtIndexes: [NSIndexSet indexSetWithIndex: 0]
                   forKeyPath: @"name"
                      options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                      context: (void *)_kNSObjectDerivedDummyModelObservationContext];
    
    XCTAssertFalse(self.isNameAccessed);
    
    self.object.name = @"test";
    
    XCTAssertTrue(self.isNameAccessed);
    
    self.isNameAccessed = NO;
    
    [self.objects removeObserver: self
            fromObjectsAtIndexes: [NSIndexSet indexSetWithIndex: 0]
                      forKeyPath: @"name"
                         context: (void *)_kNSObjectDerivedDummyModelObservationContext];
    
    self.object.name = @"test";
    
    XCTAssertFalse(self.isNameAccessed);
}

@end
