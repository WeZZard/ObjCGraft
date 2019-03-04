//
//  Object_graftImplementationsOfProtocolsFromClassTests.m
//  ObjCGraft
//
//  Created on 31/12/2018.
//

#import <XCTest/XCTest.h>
#import <dispatch/dispatch.h>
#import <objc/runtime.h>

#import <ObjCGraft/ObjCGraft.h>

#import "ObjCGraftTestAuxiliaries.h"

@interface Object_graftImplementationsOfProtocolsFromClassTests : XCTestCase

@end

@implementation Object_graftImplementationsOfProtocolsFromClassTests
#pragma mark - Returned Object
- (void)testObject_graftImplementationsOfProtocolsFromClass_returnsTheInputObject
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 1);
    
    protocols[0] = @protocol(GraftedProtocol1);
    
    id retVal = object_graftImplementationsOfProtocolsFromClass(object, protocols, 1, [ObjectImplementsGraftedProtocol1 class]);
    
    free(protocols);
    
    XCTAssert(retVal == object);
}

#pragma mark - Returned Object's Class Property
- (void)testObject_graftImplementationsOfProtocolsFromClass_returnsObject_whoseClassPropertyReturnsOriginalClass_whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 1);
    
    protocols[0] = @protocol(GraftedProtocol1);
    
    id retVal = object_graftImplementationsOfProtocolsFromClass(object, protocols, 1, [ObjectImplementsGraftedProtocol1 class]);
    
    free(protocols);
    
    XCTAssertEqual([retVal class], [NSObject class]);
}

- (void)testObject_graftImplementationsOfProtocolsFromClass_returnsObject_whoseClassPropertyReturnsOriginalClass_whenTheClassDoesNotConformToProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 1);
    
    protocols[0] = @protocol(GraftedProtocol1);
    
    id retVal = object_graftImplementationsOfProtocolsFromClass(object, protocols, 1, [ObjectImplementsGraftedProtocol1 class]);
    
    free(protocols);
    
    XCTAssertEqual([retVal class], [NSObject class]);
}

#pragma mark - Returned Object's Is-A Pointer
- (void)testObject_graftImplementationsOfProtocolsFromClass_returnsObject_whoseIsaPointerIsAClassWithPrefixOf_ObjCGrafted__whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 1);
    
    protocols[0] = @protocol(GraftedProtocol1);
    
    id retVal = object_graftImplementationsOfProtocolsFromClass(object, protocols, 1, [ObjectImplementsGraftedProtocol1 class]);
    
    free(protocols);
    
    Class retValClass = object_getClass(retVal);
    NSString * retValClassName = NSStringFromClass(retValClass);
    
    XCTAssertTrue([retValClassName hasPrefix: @"_ObjCGrafted_"]);
}

- (void)testObject_graftImplementationsOfProtocolsFromClass_returnsObject_whoseIsaPointerIsNotOriginalClass_whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 1);
    
    protocols[0] = @protocol(GraftedProtocol1);
    
    id retVal = object_graftImplementationsOfProtocolsFromClass(object, protocols, 1, [ObjectImplementsGraftedProtocol1 class]);
    
    free(protocols);
    
    Class retValClass = object_getClass(retVal);
    
    XCTAssertNotEqual(retValClass, [NSObject class]);
}

- (void)testObject_graftImplementationsOfProtocolsFromClass_returnsObject_whoseIsaPointerIsNotSourceClass_whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 1);
    
    protocols[0] = @protocol(GraftedProtocol1);
    
    id retVal = object_graftImplementationsOfProtocolsFromClass(object, protocols, 1, [ObjectImplementsGraftedProtocol1 class]);
    
    free(protocols);
    
    Class retValClass = object_getClass(retVal);
    
    XCTAssertNotEqual(retValClass, [ObjectImplementsGraftedProtocol1 class]);
}

#pragma mark - Returned Object's Conformity with The Grafted Protocols
- (void)testObject_graftImplementationsOfProtocolsFromClass_returnsObjectWhichConformsToGraftedProtocol_whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol2)]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 2);
    
    protocols[0] = @protocol(GraftedProtocol1);
    protocols[1] = @protocol(GraftedProtocol2);
    
    id retVal = object_graftImplementationsOfProtocolsFromClass(object, protocols, 2, [ObjectImplementsGraftedProtocols class]);
    
    free(protocols);
    
    XCTAssertTrue([retVal conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertTrue([retVal conformsToProtocol: @protocol(GraftedProtocol2)]);
}

- (void)testObject_graftImplementationsOfProtocolsFromClass_returnsObjectWhichConformsToGraftedProtocol_whenTheClassDoesNotConformTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertTrue([object conformsToProtocol: @protocol(NSObject)]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 2);
    
    protocols[0] = @protocol(GraftedProtocol1);
    protocols[1] = @protocol(GraftedProtocol2);
    
    id retVal = object_graftImplementationsOfProtocolsFromClass(object, protocols, 2, [ObjectImplementsGraftedProtocol2 class]);
    
    free(protocols);
    
    XCTAssertFalse([retVal conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertTrue([retVal conformsToProtocol: @protocol(GraftedProtocol2)]);
}

- (void)testObject_graftImplementationsOfProtocolsFromClass_returnsObjectWhichConformsToGraftedProtocol_whenTheClassDoeNotConformTheProtocolButItsSuperclassDoes
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol2)]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 2);
    
    protocols[0] = @protocol(GraftedProtocol1);
    protocols[1] = @protocol(GraftedProtocol2);
    
    id retVal = object_graftImplementationsOfProtocolsFromClass(object, protocols, 2, [SubObjectImplementsGraftedProtocols class]);
    
    free(protocols);
    
    XCTAssertTrue([retVal conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertTrue([retVal conformsToProtocol: @protocol(GraftedProtocol2)]);
}

#pragma mark - Returned Object's Implementation
- (void)testObject_graftImplementationsOfProtocolsFromClass_returnsObjectWhichImplementsMethods_whenMethodsAreDefinedByTheProtocolAndImplementedByTheClass_withProtocolWithoutHierarchy
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([object respondsToSelector:@selector(foo2)]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 2);
    
    protocols[0] = @protocol(GraftedProtocol1);
    protocols[1] = @protocol(GraftedProtocol2);
    
    id retVal = object_graftImplementationsOfProtocolsFromClass(object, protocols, 2, [ObjectImplementsGraftedProtocols class]);
    
    free(protocols);
    
    XCTAssertTrue([retVal respondsToSelector:@selector(foo1)]);
    XCTAssertTrue([retVal respondsToSelector:@selector(foo2)]);
    
    XCTAssertEqual([retVal foo1], @"Foo1");
    XCTAssertEqual([retVal foo2], @"Foo2");
}

- (void)testObject_graftImplementationsOfProtocolsFromClass_returnsObjectWhichDoesNotImplementMethods_whenMethodsAreDefinedByTheProtocolAnButNotImplementedByTheClass_withProtocolWithoutHierarchy
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([object respondsToSelector:@selector(foo2)]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 2);
    
    protocols[0] = @protocol(GraftedProtocol1);
    protocols[1] = @protocol(GraftedProtocol2);
    
    id retVal = object_graftImplementationsOfProtocolsFromClass(object, protocols, 2, [ObjectImplementsGraftedProtocol2 class]);
    
    free(protocols);
    
    XCTAssertFalse([retVal respondsToSelector:@selector(foo1)]);
    XCTAssertTrue([retVal respondsToSelector:@selector(foo2)]);
    
    XCTAssertThrows([retVal foo1]);
    XCTAssertEqual([retVal foo2], @"Foo2");
}

- (void)testObject_graftImplementationsOfProtocolsFromClass_returnsObjectWhichImplementsMethods_whenMethodsAreDefinedByTheProtocolAndImplementedByTheClass_withProtocolWithHierarchy
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([object respondsToSelector:@selector(bar1)]);
    XCTAssertFalse([object respondsToSelector:@selector(foo2)]);
    XCTAssertFalse([object respondsToSelector:@selector(bar2)]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 2);
    
    protocols[0] = @protocol(SubGraftedProtocol1);
    protocols[1] = @protocol(SubGraftedProtocol2);
    
    id retVal = object_graftImplementationsOfProtocolsFromClass(object, protocols, 2, [ObjectImplementsGraftedProtocols class]);
    
    free(protocols);
    
    XCTAssertTrue([object respondsToSelector:@selector(foo1)]);
    XCTAssertTrue([object respondsToSelector:@selector(bar1)]);
    XCTAssertTrue([object respondsToSelector:@selector(foo2)]);
    XCTAssertTrue([object respondsToSelector:@selector(bar2)]);
    
    XCTAssertEqual([retVal foo1], @"Foo1");
    XCTAssertEqual([retVal bar1], @"Bar1");
    XCTAssertEqual([retVal foo2], @"Foo2");
    XCTAssertEqual([retVal bar2], @"Bar2");
}

- (void)testObject_graftImplementationsOfProtocolsFromClass_returnsObjectWhichDoesNotImplementMethods_whenMethodsAreDefinedByTheProtocolAnButNotImplementedByTheClass_withProtocolWithHierarchy
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([object respondsToSelector:@selector(bar1)]);
    XCTAssertFalse([object respondsToSelector:@selector(foo2)]);
    XCTAssertFalse([object respondsToSelector:@selector(bar2)]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 2);
    
    protocols[0] = @protocol(SubGraftedProtocol1);
    protocols[1] = @protocol(SubGraftedProtocol2);
    
    id retVal = object_graftImplementationsOfProtocolsFromClass(object, protocols, 2, [ObjectImplementsGraftedProtocol2 class]);
    
    free(protocols);
    
    XCTAssertFalse([object respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([object respondsToSelector:@selector(bar1)]);
    XCTAssertTrue([object respondsToSelector:@selector(foo2)]);
    XCTAssertTrue([object respondsToSelector:@selector(bar2)]);
    
    XCTAssertThrows([retVal foo1]);
    XCTAssertThrows([retVal bar1]);
    XCTAssertEqual([retVal foo2], @"Foo2");
    XCTAssertEqual([retVal bar2], @"Bar2");
}
@end
