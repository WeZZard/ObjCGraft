//
//  NSArray_RemovingGraftedImplementationsWithKeyValueObservedTests.m
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

static NSString * _kNSObjectDerivedDummyModelObservationContext = @"com.WeZZard.ObjCGraft.NSObject_RemovingGraftedImplementationsWithKeyValueObservedTests.NSObjectDerivedDummyModelObservationContext";

@interface NSArray_RemovingGraftedImplementationsWithKeyValueObservedTests : XCTestCase
@property (nonatomic, strong) NSArray * objects;
@property (nonatomic, strong) NSObjectDerivedDummyModel * object;
@property (nonatomic, assign) BOOL isNameAccessed;
@end

@implementation NSArray_RemovingGraftedImplementationsWithKeyValueObservedTests
- (void)setUp
{
    self.isNameAccessed = NO;
    self.object = [[NSObjectDerivedDummyModel alloc] initWithName: @""];
    self.objects = [NSArray arrayWithObject: self.object];
    
    [self.objects addObserver: self
           toObjectsAtIndexes: [NSIndexSet indexSetWithIndex: 0]
                   forKeyPath: @"name"
                      options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                      context: (void *)_kNSObjectDerivedDummyModelObservationContext];
    
}

- (void)tearDown
{
    [self.objects removeObserver: self
            fromObjectsAtIndexes: [NSIndexSet indexSetWithIndex: 0]
                      forKeyPath: @"name"
                         context: (void *)_kNSObjectDerivedDummyModelObservationContext];
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

#pragma mark - KVO Accessing
- (void)testObject_graftImplementationOfProtocolFromClass_KVOAccessing
{
    id grafted = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    object_removeGraftedImplementationOfProtocol(grafted, @protocol(GraftedProtocol1));
    
    XCTAssertFalse(self.isNameAccessed);
    
    [self.object setName: @"Test"];
    
    XCTAssertTrue(self.isNameAccessed);
}

#pragma mark - Returned Object's Is-A Pointer
- (void)testObject_removeGraftedImplementationOfProtocol_returnsObjectWithIsaPointerNotRestored_whenRemovingNonLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationsOfProtocolsFromClass_nilTerminated(self.object, [ObjectImplementsGraftedProtocols class], @protocol(GraftedProtocol1), @protocol(GraftedProtocol2), nil);
    
    XCTAssertNotEqual(object_getClass(grafted), [NSObject class]);
    
    id removed = object_removeGraftedImplementationOfProtocol(grafted, @protocol(GraftedProtocol1));
    
    XCTAssertNotEqual(object_getClass(removed), [NSObject class]);
}

- (void)testObject_removeGraftedImplementationOfProtocol_returnsObjectWithIsaPointerNotRestored_whenRemovingTheLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertNotEqual(object_getClass(grafted), [NSObject class]);
    
    id removed = object_removeGraftedImplementationOfProtocol(grafted, @protocol(GraftedProtocol1));
    
    XCTAssertNotEqual(object_getClass(removed), [NSObject class]);
}

#pragma mark - Returned Object's Conformity to the Grafted Protocol
- (void)testObject_removeGraftedImplementationOfProtocol_returnsObjectWhichDoesNotConformsToTheRemovedGraftedProtocol_whenRemovingNonLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationsOfProtocolsFromClass_nilTerminated(self.object, [ObjectImplementsGraftedProtocols class], @protocol(GraftedProtocol1), @protocol(GraftedProtocol2), nil);
    
    XCTAssertTrue([grafted conformsToProtocol: @protocol(GraftedProtocol1)]);
    
    id removed = object_removeGraftedImplementationOfProtocol(grafted, @protocol(GraftedProtocol1));
    
    XCTAssertFalse([removed conformsToProtocol: @protocol(GraftedProtocol1)]);
}

- (void)testObject_removeGraftedImplementationOfProtocol_returnsObjectWhichDoesNotConformsToTheRemovedGraftedProtocol_whenRemovingTheLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertTrue([grafted conformsToProtocol: @protocol(GraftedProtocol1)]);
    
    id removed = object_removeGraftedImplementationOfProtocol(grafted, @protocol(GraftedProtocol1));
    
    XCTAssertFalse([removed conformsToProtocol: @protocol(GraftedProtocol1)]);
}

#pragma mark - Returned Object's Grafted Implementations
- (void)testObject_removeGraftedImplementationOfProtocol_returnsObjectWhichDoesNotImplementsMethodsOfTheRemovedGraftedProtocol_whenRemovingNonLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationsOfProtocolsFromClass_nilTerminated(self.object, [ObjectImplementsGraftedProtocols class], @protocol(GraftedProtocol1), @protocol(GraftedProtocol2), nil);
    
    XCTAssertTrue([grafted respondsToSelector: @selector(foo1)]);
    XCTAssertTrue([grafted respondsToSelector: @selector(foo2)]);
    
    id removed = object_removeGraftedImplementationOfProtocol(grafted, @protocol(GraftedProtocol1));
    
    XCTAssertFalse([removed respondsToSelector: @selector(foo1)]);
    XCTAssertTrue([removed respondsToSelector: @selector(foo2)]);
}

- (void)testObject_removeGraftedImplementationOfProtocol_returnsObjectWhichDoesNotImplementsMethodsOfTheRemovedGraftedProtocol_whenRemovingTheLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertTrue([grafted respondsToSelector: @selector(foo1)]);
    
    id removed = object_removeGraftedImplementationOfProtocol(grafted, @protocol(GraftedProtocol1));
    
    XCTAssertFalse([removed respondsToSelector: @selector(foo1)]);
}
@end
