//
//  NSArray_GraftingImplementationsWithKeyValueObservedTests.m
//  ObjCGrafting
//
//  Created on 1/1/2019.
//

#import <XCTest/XCTest.h>
#import <dispatch/dispatch.h>
#import <objc/runtime.h>

#import <ObjCGrafting/ObjCGrafting.h>

#import "ObjCGraftTestAuxiliaries.h"
#import "NSObjectKeyValueObservingTestAuxiliaries.h"

static NSString * _kNSObjectDerivedDummyModelObservationContext = @"com.WeZZard.ObjCGrafting.NSArray_GraftingImplementationsWithKeyValueObservedTests.NSObjectDerivedDummyModelObservationContext";

@interface NSArray_GraftingImplementationsWithKeyValueObservedTests : XCTestCase
@property (nonatomic, strong) NSArray * objects;
@property (nonatomic, strong) NSObjectDerivedDummyModel * object;
@property (nonatomic, assign) BOOL isNameAccessed;
@end

@implementation NSArray_GraftingImplementationsWithKeyValueObservedTests
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
    object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertFalse(self.isNameAccessed);
    
    [self.object setName: @"Test"];
    
    XCTAssertTrue(self.isNameAccessed);
}

#pragma mark - Returned Object's Class Property
- (void)testObject_graftImplementationOfProtocolFromClass_returnsObject_whoseClassPropertyReturnsOriginalClass_whenTheClassConformsToTheProtocol
{
    id retVal = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertEqual([retVal class], [NSObjectDerivedDummyModel class]);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObject_whoseClassPropertyReturnsOriginalClass_whenTheClassDoesNotConformToProtocol
{
    id retVal = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [NSArray class]);
    
    XCTAssertEqual([retVal class], [NSObjectDerivedDummyModel class]);
}

#pragma mark - Returned Object's Is-A Pointer
- (void)testObject_graftImplementationOfProtocolFromClass_returnsObject_whoseIsaPointerIsNotAClassWithPrefixOf_ObjCGrafted__whenTheClassConformsToTheProtocol
{
    id retVal = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    Class retValClass = object_getClass(retVal);
    NSString * retValClassName = NSStringFromClass(retValClass);
    
    XCTAssertFalse([retValClassName hasPrefix: @"_ObjCGrafted_"]);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObject_whoseIsaPointerIsNotOriginalClass_whenTheClassConformsToTheProtocol
{
    id retVal = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    Class retValClass = object_getClass(retVal);
    
    XCTAssertNotEqual(retValClass, [NSObjectDerivedDummyModel class]);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObject_whoseIsaPointerIsNotSourceClass_whenTheClassConformsToTheProtocol
{
    id retVal = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    Class retValClass = object_getClass(retVal);
    
    XCTAssertNotEqual(retValClass, [ObjectImplementsGraftedProtocol1 class]);
}

#pragma mark - Returned Object's Conformity with The Grafted Protocol
- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichConformsToGraftedProtocol_whenTheClassConformsToTheProtocol
{
    XCTAssertFalse([self.object conformsToProtocol: @protocol(GraftedProtocol1)]);
    
    id retVal = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertTrue([retVal conformsToProtocol: @protocol(GraftedProtocol1)]);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichDoesNotConformToGraftedProtocol_whenTheClassDoesNotConformToTheProtocol
{
    XCTAssertFalse([self.object conformsToProtocol: @protocol(GraftedProtocol1)]);
    
    id retVal = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [NSArray class]);
    
    XCTAssertFalse([retVal conformsToProtocol: @protocol(GraftedProtocol1)]);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichConformsToGraftedProtocol_whenTheClassDoeNotConformToTheProtocolButItsSuperclassDoes
{
    XCTAssertFalse([self.object conformsToProtocol: @protocol(GraftedProtocol1)]);
    
    id retVal = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [SubObjectImplementsGraftedProtocol1ForSuperclass class]);
    
    XCTAssertTrue([retVal conformsToProtocol: @protocol(GraftedProtocol1)]);
}

#pragma mark - Returned Object's Implementation
- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichImplementsMethods_whenMethodsAreDefinedByTheProtocolAndImplementedByTheClass_withProtocolWithoutHierarchy
{
    XCTAssertFalse([self.object respondsToSelector:@selector(foo1)]);
    
    XCTAssertFalse([self.object isProxy]);
    
    id retVal = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertTrue([retVal respondsToSelector:@selector(foo1)]);
    XCTAssertEqual([retVal foo1], @"Foo1");
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichDoesNotImplementMethods_whenMethodsAreDefinedByTheProtocolAnButNotImplementedByTheClass_withProtocolWithoutHierarchy
{
    XCTAssertFalse([self.object respondsToSelector:@selector(foo1)]);
    
    id retVal = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [ObjectDoesNotImplementGraftedProtocol1 class]);
    
    XCTAssertFalse([retVal respondsToSelector:@selector(foo1)]);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichDoesNotImplementMethods_whenMethodsAreDefinedByTheProtocolAnButImplementedByTheSuperclass_withProtocolWithoutHierarchy
{
    XCTAssertFalse([self.object respondsToSelector:@selector(foo1)]);
    
    id retVal = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [SubObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertFalse([retVal respondsToSelector:@selector(foo1)]);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichImplementsMethods_whenMethodsAreDefinedByTheProtocolAndImplementedByTheClass_withProtocolWithHierarchy
{
    XCTAssertFalse([self.object respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([self.object respondsToSelector:@selector(bar1)]);
    
    id retVal = object_graftImplementationOfProtocolFromClass(self.object, @protocol(SubGraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertTrue([retVal respondsToSelector:@selector(foo1)]);
    XCTAssertTrue([retVal respondsToSelector:@selector(bar1)]);
    
    XCTAssertEqual([retVal foo1], @"Foo1");
    XCTAssertEqual([retVal bar1], @"Bar1");
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichDoesNotImplementMethods_whenMethodsAreDefinedByTheProtocolAnButNotImplementedByTheClass_withProtocolWithHierarchy
{
    id retVal = object_graftImplementationOfProtocolFromClass(self.object, @protocol(SubGraftedProtocol1), [ObjectDoesNotImplementGraftedProtocol1 class]);
    
    XCTAssertFalse([retVal respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([retVal respondsToSelector:@selector(bar1)]);
    
    XCTAssertThrows([retVal foo1]);
    XCTAssertThrows([retVal bar1]);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichDoesNotImplementMethods_whenMethodsAreDefinedByTheProtocolAnButImplementedByTheSuperclass_withProtocolWithHierarchy
{
    XCTAssertFalse([self.object respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([self.object respondsToSelector:@selector(bar1)]);
    
    id retVal = object_graftImplementationOfProtocolFromClass(self.object, @protocol(SubGraftedProtocol1), [SubObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertFalse([retVal respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([retVal respondsToSelector:@selector(bar1)]);
    
    XCTAssertThrows([retVal foo1]);
    XCTAssertThrows([retVal bar1]);
}
@end
