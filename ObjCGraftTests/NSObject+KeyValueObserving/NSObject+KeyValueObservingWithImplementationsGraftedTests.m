//
//  NSObject_KeyValueObservingWithImplementationsGraftedTests.m
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

@interface NSObject_KeyValueObservingWithImplementationsGraftedTests : XCTestCase
@property (nonatomic, strong) NSObjectDerivedDummyModel * object;
@property (nonatomic, assign) BOOL isNameAccessed;
@end

@implementation NSObject_KeyValueObservingWithImplementationsGraftedTests
- (void)setUp
{
    self.isNameAccessed = NO;
    self.object = [[NSObjectDerivedDummyModel alloc] initWithName: @""];
    object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
}

- (void)tearDown
{
    self.object = nil;
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
    [self.object addObserver: self
                  forKeyPath: @"name"
                     options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context: (void *)_kNSObjectDerivedDummyModelObservationContext];
    
    XCTAssertFalse(self.isNameAccessed);
    
    self.object.name = @"test";
    
    XCTAssertTrue(self.isNameAccessed);
    
    self.isNameAccessed = NO;
    
    [self.object removeObserver: self forKeyPath: @"name"];
    
    self.object.name = @"test";
    
    XCTAssertFalse(self.isNameAccessed);
    
}

- (void)testNSObjectAddObserverForKeyPathOptionsContext_RemoveObserverForKeyPathContext
{
    [self.object addObserver: self
                  forKeyPath: @"name"
                     options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context: (void *)_kNSObjectDerivedDummyModelObservationContext];
    
    XCTAssertFalse(self.isNameAccessed);
    
    self.object.name = @"test";
    
    XCTAssertTrue(self.isNameAccessed);
    
    self.isNameAccessed = NO;
    
    [self.object removeObserver: self forKeyPath: @"name" context: (void *)_kNSObjectDerivedDummyModelObservationContext];
    
    self.object.name = @"test";
    
    XCTAssertFalse(self.isNameAccessed);
}

@end
