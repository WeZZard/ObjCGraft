//
//  Object_graftImplementationsOfProtocolsFromClasses_nilTerminatedTests.m
//  ObjCGraft
//
//  Created on 31/12/2018.
//

#import <XCTest/XCTest.h>
#import <dispatch/dispatch.h>
#import <objc/runtime.h>

#import <ObjCGraft/ObjCGraft.h>

#import "ObjCGraftTestAuxiliaries.h"

@interface Object_graftImplementationsOfProtocolsFromClasses_nilTerminatedTests : XCTestCase

@end

@implementation Object_graftImplementationsOfProtocolsFromClasses_nilTerminatedTests
#pragma mark - Throws
- (void)testObject_graftImplementationsOfProtocolsFromClasses_nilTerminated_throws_whenProtocolAndClassIsNotOfferedInPair
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertThrows(object_graftImplementationsOfProtocolsFromClasses_nilTerminated(object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class], [NSArray class], [NSProxy class], nil));
    
    XCTAssertThrows(object_graftImplementationsOfProtocolsFromClasses_nilTerminated(object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class], @protocol(NSObject), @protocol(NSStreamDelegate), nil));
}

#pragma mark - Returned Object
- (void)testObject_graftImplementationsOfProtocolsFromClasses_nilTerminated_returnsTheInputObject
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses_nilTerminated(object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class], nil);
    
    XCTAssert(retVal == object);
}

#pragma mark - Returned Object's Class Property
- (void)testObject_graftImplementationsOfProtocolsFromClasses_nilTerminated_returnsObject_whoseClassPropertyReturnsOriginalClass_whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses_nilTerminated(object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class], nil);
    
    XCTAssertEqual([retVal class], [NSObject class]);
}

- (void)testObject_graftImplementationsOfProtocolsFromClasses_nilTerminated_returnsObject_whoseClassPropertyReturnsOriginalClass_whenTheClassDoesNotConformToProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses_nilTerminated(object, @protocol(GraftedProtocol1), [ObjectDoesNotImplementGraftedProtocol1 class], nil);
    
    XCTAssertEqual([retVal class], [NSObject class]);
}

#pragma mark - Returned Object's Is-A Pointer
- (void)testObject_graftImplementationsOfProtocolsFromClasses_nilTerminated_returnsObject_whoseIsaPointerIsAClassWithPrefixOf_ObjCGrafted__whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses_nilTerminated(object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class], nil);
    
    Class retValClass = object_getClass(retVal);
    NSString * retValClassName = NSStringFromClass(retValClass);
    
    XCTAssertTrue([retValClassName hasPrefix: @"_ObjCGrafted_"]);
}

- (void)testObject_graftImplementationsOfProtocolsFromClasses_nilTerminated_returnsObject_whoseIsaPointerIsNotOriginalClass_whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses_nilTerminated(object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class], nil);
    
    Class retValClass = object_getClass(retVal);
    
    XCTAssertNotEqual(retValClass, [NSObject class]);
}

- (void)testObject_graftImplementationsOfProtocolsFromClasses_nilTerminated_returnsObject_whoseIsaPointerIsNotSourceClass_whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses_nilTerminated(object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class], nil);
    
    Class retValClass = object_getClass(retVal);
    
    XCTAssertNotEqual(retValClass, [ObjectImplementsGraftedProtocol1 class]);
}

#pragma mark - Returned Object's Conformity with The Grafted Protocols
- (void)testObject_graftImplementationsOfProtocolsFromClasses_nilTerminated_returnsObjectWhichConformsToGraftedProtocol_whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol2)]);
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses_nilTerminated(object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class], @protocol(GraftedProtocol2), [ObjectImplementsGraftedProtocol2 class], nil);
    
    XCTAssertTrue([retVal conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertTrue([retVal conformsToProtocol: @protocol(GraftedProtocol2)]);
}

- (void)testObject_graftImplementationsOfProtocolsFromClasses_nilTerminated_returnsObjectWhichDoesNotConformToGraftedProtocol_whenTheClassDoesNotConformTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol2)]);
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses_nilTerminated(object, @protocol(GraftedProtocol1), [NSArray class], @protocol(GraftedProtocol2), [ObjectImplementsGraftedProtocol2 class], nil);
    
    XCTAssertFalse([retVal conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertTrue([retVal conformsToProtocol: @protocol(GraftedProtocol2)]);
}

- (void)testObject_graftImplementationsOfProtocolsFromClasses_nilTerminated_returnsObjectWhichConformsToGraftedProtocol_whenTheClassDoeNotConformTheProtocolButItsSuperclassDoes
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol2)]);
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses_nilTerminated(object, @protocol(GraftedProtocol1), [SubObjectImplementsGraftedProtocol1 class], @protocol(GraftedProtocol2), [ObjectImplementsGraftedProtocol2 class], nil);
    
    XCTAssertTrue([retVal conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertTrue([retVal conformsToProtocol: @protocol(GraftedProtocol2)]);
}

#pragma mark - Returned Object's Implementation
- (void)testObject_graftImplementationsOfProtocolsFromClasses_nilTerminated_returnsObjectWhichImplementsMethods_whenMethodsAreDefinedByTheProtocolAndImplementedByTheClass_withProtocolWithoutHierarchy
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object respondsToSelector: @selector(foo1)]);
    XCTAssertFalse([object respondsToSelector: @selector(foo2)]);
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses_nilTerminated(object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class], @protocol(GraftedProtocol2), [ObjectImplementsGraftedProtocol2 class], nil);
    
    XCTAssertTrue([retVal respondsToSelector: @selector(foo1)]);
    XCTAssertTrue([retVal respondsToSelector: @selector(foo2)]);
    
    XCTAssertEqual([retVal foo1], @"Foo1");
    XCTAssertEqual([retVal foo2], @"Foo2");
}

- (void)testObject_graftImplementationsOfProtocolsFromClasses_nilTerminated_returnsObjectWhichDoesNotImplementMethods_whenMethodsAreDefinedByTheProtocolAnButNotImplementedByTheClass_withProtocolWithoutHierarchy
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object respondsToSelector: @selector(foo1)]);
    XCTAssertFalse([object respondsToSelector: @selector(foo2)]);
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses_nilTerminated(object, @protocol(GraftedProtocol1), [ObjectDoesNotImplementGraftedProtocol1 class], @protocol(GraftedProtocol2), [ObjectImplementsGraftedProtocol2 class], nil);
    
    XCTAssertFalse([retVal respondsToSelector: @selector(foo1)]);
    XCTAssertTrue([retVal respondsToSelector: @selector(foo2)]);
    
    XCTAssertThrows([retVal foo1]);
    XCTAssertEqual([retVal foo2], @"Foo2");
}

- (void)testObject_graftImplementationsOfProtocolsFromClasses_nilTerminated_returnsObjectWhichImplementsMethods_whenMethodsAreDefinedByTheProtocolAndImplementedByTheClass_withProtocolWithHierarchy
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object respondsToSelector: @selector(foo1)]);
    XCTAssertFalse([object respondsToSelector: @selector(bar1)]);
    XCTAssertFalse([object respondsToSelector: @selector(foo2)]);
    XCTAssertFalse([object respondsToSelector: @selector(bar2)]);
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses_nilTerminated(object, @protocol(SubGraftedProtocol1), [ObjectImplementsGraftedProtocol1 class], @protocol(SubGraftedProtocol2), [ObjectImplementsGraftedProtocol2 class], nil);
    
    XCTAssertTrue([retVal respondsToSelector: @selector(foo1)]);
    XCTAssertTrue([retVal respondsToSelector: @selector(bar1)]);
    XCTAssertTrue([retVal respondsToSelector: @selector(foo2)]);
    XCTAssertTrue([retVal respondsToSelector: @selector(bar2)]);
    
    XCTAssertEqual([retVal foo1], @"Foo1");
    XCTAssertEqual([retVal bar1], @"Bar1");
    XCTAssertEqual([retVal foo2], @"Foo2");
    XCTAssertEqual([retVal bar2], @"Bar2");
}

- (void)testObject_graftImplementationsOfProtocolsFromClasses_nilTerminated_returnsObjectWhichDoesNotImplementMethods_whenMethodsAreDefinedByTheProtocolAnButNotImplementedByTheClass_withProtocolWithHierarchy
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object respondsToSelector: @selector(foo1)]);
    XCTAssertFalse([object respondsToSelector: @selector(bar1)]);
    XCTAssertFalse([object respondsToSelector: @selector(foo2)]);
    XCTAssertFalse([object respondsToSelector: @selector(bar2)]);
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses_nilTerminated(object, @protocol(SubGraftedProtocol1), [ObjectDoesNotImplementGraftedProtocol1 class], @protocol(SubGraftedProtocol2), [ObjectImplementsGraftedProtocol2 class], nil);
    
    XCTAssertFalse([retVal respondsToSelector: @selector(foo1)]);
    XCTAssertFalse([retVal respondsToSelector: @selector(bar1)]);
    XCTAssertTrue([retVal respondsToSelector: @selector(foo2)]);
    XCTAssertTrue([retVal respondsToSelector: @selector(bar2)]);
    
    XCTAssertThrows([retVal foo1]);
    XCTAssertThrows([retVal bar1]);
    XCTAssertEqual([retVal foo2], @"Foo2");
    XCTAssertEqual([retVal bar2], @"Bar2");
}
@end
