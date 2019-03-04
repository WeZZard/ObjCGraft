//
//  Object_graftImplementationOfProtocolFromClassTests.m
//  ObjCGraft
//
//  Created on 29/12/2018.
//

#import <XCTest/XCTest.h>
#import <dispatch/dispatch.h>
#import <objc/runtime.h>

#import <ObjCGraft/ObjCGraft.h>

#import "ObjCGraftTestAuxiliaries.h"

@interface Object_graftImplementationOfProtocolFromClassTests : XCTestCase

@end

@implementation Object_graftImplementationOfProtocolFromClassTests
- (void)setUp
{
    [super setUp];
    IsDeallocAccessed = NO;
    IsClassAccessed = NO;
    IsRespondsToSelectorAccessed = NO;
    IsConformsToProtocolAccessed = NO;
}

#pragma mark - Returned Object
- (void)testObject_graftImplementationOfProtocolFromClass_returnsTheInputObject
{
    NSObject * object = [[NSObject alloc] init];
    
    id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    XCTAssert(retVal == object);
}

#pragma mark - Returned Object's Class Property
- (void)testObject_graftImplementationOfProtocolFromClass_returnsObject_whoseClassPropertyReturnsOriginalClass_whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertEqual([retVal class], [NSObject class]);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObject_whoseClassPropertyReturnsOriginalClass_whenTheClassDoesNotConformToProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(GraftedProtocol1), [NSArray class]);
    
    XCTAssertEqual([retVal class], [NSObject class]);
}

#pragma mark - Returned Object's Is-A Pointer
- (void)testObject_graftImplementationOfProtocolFromClass_returnsObject_whoseIsaPointerIsAClassWithPrefixOf_ObjCGrafted__whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    Class retValClass = object_getClass(retVal);
    NSString * retValClassName = NSStringFromClass(retValClass);
    
    XCTAssertTrue([retValClassName hasPrefix: @"_ObjCGrafted_"]);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObject_whoseIsaPointerIsNotOriginalClass_whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    Class retValClass = object_getClass(retVal);
    
    XCTAssertNotEqual(retValClass, [NSObject class]);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObject_whoseIsaPointerIsNotSourceClass_whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    Class retValClass = object_getClass(retVal);
    
    XCTAssertNotEqual(retValClass, [ObjectImplementsGraftedProtocol1 class]);
}

#pragma mark - Returned Object's Conformity with The Grafted Protocol
- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichConformsToGraftedProtocol_whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol1)]);
    
    id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertTrue([retVal conformsToProtocol: @protocol(GraftedProtocol1)]);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichDoesNotConformToGraftedProtocol_whenTheClassDoesNotConformToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol1)]);
    
    id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(GraftedProtocol1), [NSArray class]);
    
    XCTAssertFalse([retVal conformsToProtocol: @protocol(GraftedProtocol1)]);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichConformsToGraftedProtocol_whenTheClassDoeNotConformToTheProtocolButItsSuperclassDoes
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol1)]);
    
    id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(GraftedProtocol1), [SubObjectImplementsGraftedProtocol1ForSuperclass class]);
    
    XCTAssertTrue([retVal conformsToProtocol: @protocol(GraftedProtocol1)]);
}

#pragma mark - Returned Object's Implementation
- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichImplementsMethods_whenMethodsAreDefinedByTheProtocolAndImplementedByTheClass_withProtocolWithoutHierarchy
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object respondsToSelector:@selector(foo1)]);
    
    XCTAssertFalse([object isProxy]);
    
    id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertTrue([retVal respondsToSelector:@selector(foo1)]);
    XCTAssertEqual([retVal foo1], @"Foo1");
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichDoesNotImplementMethods_whenMethodsAreDefinedByTheProtocolAnButNotImplementedByTheClass_withProtocolWithoutHierarchy
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object respondsToSelector:@selector(foo1)]);
    
    id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(GraftedProtocol1), [ObjectDoesNotImplementGraftedProtocol1 class]);
    
    XCTAssertFalse([retVal respondsToSelector:@selector(foo1)]);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichDoesNotImplementMethods_whenMethodsAreDefinedByTheProtocolAnButImplementedByTheSuperclass_withProtocolWithoutHierarchy
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object respondsToSelector:@selector(foo1)]);
    
    id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(GraftedProtocol1), [SubObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertFalse([retVal respondsToSelector:@selector(foo1)]);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichImplementsMethods_whenMethodsAreDefinedByTheProtocolAndImplementedByTheClass_withProtocolWithHierarchy
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([object respondsToSelector:@selector(bar1)]);
    
    id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(SubGraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertTrue([retVal respondsToSelector:@selector(foo1)]);
    XCTAssertTrue([retVal respondsToSelector:@selector(bar1)]);
    
    XCTAssertEqual([retVal foo1], @"Foo1");
    XCTAssertEqual([retVal bar1], @"Bar1");
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichDoesNotImplementMethods_whenMethodsAreDefinedByTheProtocolAnButNotImplementedByTheClass_withProtocolWithHierarchy
{
    NSObject * object = [[NSObject alloc] init];
    
    id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(SubGraftedProtocol1), [ObjectDoesNotImplementGraftedProtocol1 class]);
    
    XCTAssertFalse([retVal respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([retVal respondsToSelector:@selector(bar1)]);
    
    XCTAssertThrows([retVal foo1]);
    XCTAssertThrows([retVal bar1]);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichDoesNotImplementMethods_whenMethodsAreDefinedByTheProtocolAnButImplementedByTheSuperclass_withProtocolWithHierarchy
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([object respondsToSelector:@selector(bar1)]);
    
    id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(SubGraftedProtocol1), [SubObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertFalse([retVal respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([retVal respondsToSelector:@selector(bar1)]);
    
    XCTAssertThrows([retVal foo1]);
    XCTAssertThrows([retVal bar1]);
}

#pragma mark - Graft against Reserved Selectors
- (void)testObject_graftImplementationOfProtocolFromClass_returnedObject_accessesGraftedDeallocImplementation_whenCallingDealloc
{
    XCTAssertFalse(IsDeallocAccessed);
    
    @autoreleasepool {
        NSObject * object = [[NSObject alloc] init];
        object_graftImplementationOfProtocolFromClass(object, @protocol(Dealloc), [ObjectImplementsDealloc class]);
    }
    
    XCTAssertTrue(IsDeallocAccessed);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnedObject_accessesGraftedClassImplementation_whenCallingClass
{
    XCTAssertFalse(IsClassAccessed);
    
    @autoreleasepool {
        NSObject * object = [[NSObject alloc] init];
        id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(GetClass), [ObjectImplementsGetClass class]);
        
        [retVal class];
    }
    
    XCTAssertTrue(IsClassAccessed);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnedObject_accessesGraftedRespondsToSelectorImplementation_whenDoesNotRespondToTheSelector
{
    XCTAssertFalse(IsRespondsToSelectorAccessed);
    
    @autoreleasepool {
        NSArray * object = [[NSArray alloc] init];
        id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(RespondsToSelector), [ObjectImplementsRespondsToSelector class]);
        
        [retVal respondsToSelector: @selector(foo1)];
    }
    
    XCTAssertTrue(IsRespondsToSelectorAccessed);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnedObject_doesNotAccessGraftedRespondsToSelectorImplementation_whenRespondsToTheSelector
{
    XCTAssertFalse(IsRespondsToSelectorAccessed);
    
    @autoreleasepool {
        NSArray * object = [[NSArray alloc] init];
        id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(RespondsToSelector), [ObjectImplementsRespondsToSelector class]);
        
        [retVal respondsToSelector: @selector(isProxy)];
    }
    
    XCTAssertFalse(IsRespondsToSelectorAccessed);
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnedObject_accessesGraftedConformsToProtocolImplementation
{
    XCTAssertFalse(IsConformsToProtocolAccessed);
    
    @autoreleasepool {
        NSObject * object = [[NSObject alloc] init];
        id retVal = object_graftImplementationOfProtocolFromClass(object, @protocol(ConformsToProtocol), [ObjectImplementsConformsToProtocol class]);
        
        [retVal conformsToProtocol: @protocol(NSStreamDelegate)];
    }
    
    XCTAssertTrue(IsConformsToProtocolAccessed);
}

#pragma mark - Graft under Multi-Thread
- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichImplementsMethods_whenMethodsAreDefinedByTheProtocolAndImplementedByTheClass_withProtocolWithoutHierarchy_underMultiThread
{
    NSObject * object1 = [[NSObject alloc] init];
    NSObject * object2 = [[NSObject alloc] init];
    
    XCTAssertFalse([object1 respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([object2 respondsToSelector:@selector(foo1)]);
    
    dispatch_queue_t queue = dispatch_queue_create("com.WeZZard.ObjCGraft.ObjCGraftTests", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        object_graftImplementationOfProtocolFromClass(object1, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    });
    
    dispatch_group_async(group, queue, ^{
        object_graftImplementationOfProtocolFromClass(object2, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    });
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue([object1 respondsToSelector:@selector(foo1)]);
    XCTAssertTrue([object2 respondsToSelector:@selector(foo1)]);
    
    XCTAssertEqual([(id)object1 foo1], @"Foo1");
    XCTAssertEqual([(id)object2 foo1], @"Foo1");
}

- (void)testObject_graftImplementationOfProtocolFromClass_returnsObjectWhichImplementsMethods_whenMethodsAreDefinedByTheProtocolAndImplementedByTheClass_withProtocolWithHierarchy_underMultiThread
{
    NSObject * object1 = [[NSObject alloc] init];
    NSObject * object2 = [[NSObject alloc] init];
    
    XCTAssertFalse([object1 respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([object1 respondsToSelector:@selector(bar1)]);
    
    XCTAssertFalse([object2 respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([object2 respondsToSelector:@selector(bar1)]);
    
    dispatch_queue_t queue = dispatch_queue_create("com.WeZZard.ObjCGraft.ObjCGraftTests", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        object_graftImplementationOfProtocolFromClass(object1, @protocol(SubGraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    });
    
    dispatch_group_async(group, queue, ^{
        object_graftImplementationOfProtocolFromClass(object2, @protocol(SubGraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    });
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    XCTAssertTrue([object1 respondsToSelector:@selector(foo1)]);
    XCTAssertTrue([object1 respondsToSelector:@selector(bar1)]);
    
    XCTAssertTrue([object2 respondsToSelector:@selector(foo1)]);
    XCTAssertTrue([object2 respondsToSelector:@selector(bar1)]);
    
    XCTAssertEqual([(id)object1 foo1], @"Foo1");
    XCTAssertEqual([(id)object1 bar1], @"Bar1");
    
    XCTAssertEqual([(id)object2 foo1], @"Foo1");
    XCTAssertEqual([(id)object2 bar1], @"Bar1");
}
@end
