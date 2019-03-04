//
//  Object_graftImplementationsOfProtocolsFromClassesTests.m
//  ObjCGraft
//
//  Created on 31/12/2018.
//

#import <XCTest/XCTest.h>
#import <dispatch/dispatch.h>
#import <objc/runtime.h>

#import <ObjCGraft/ObjCGraft.h>

#import "ObjCGraftTestAuxiliaries.h"

@interface Object_graftImplementationsOfProtocolsFromClassesTests : XCTestCase

@end

@implementation Object_graftImplementationsOfProtocolsFromClassesTests
#pragma mark - Returned Object
- (void)testObject_graftImplementationsOfProtocolsFromClasses_returnsTheInputObject
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 1);
    Class * classes = (Class *)malloc(sizeof(Class) * 1);
    
    protocols[0] = @protocol(GraftedProtocol1);
    classes[0] = [ObjectImplementsGraftedProtocol1 class];
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses(object, protocols, classes, 1);
    
    free(protocols);
    free(classes);
    
    XCTAssert(retVal == object);
}

#pragma mark - Returned Object's Class Property
- (void)testObject_graftImplementationsOfProtocolsFromClasses_returnsObject_whoseClassPropertyReturnsOriginalClass_whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 1);
    Class * classes = (Class *)malloc(sizeof(Class) * 1);
    
    protocols[0] = @protocol(GraftedProtocol1);
    classes[0] = [ObjectImplementsGraftedProtocol1 class];
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses(object, protocols, classes, 1);
    
    free(protocols);
    free(classes);
    
    XCTAssertEqual([retVal class], [NSObject class]);
}

- (void)testObject_graftImplementationsOfProtocolsFromClasses_returnsObject_whoseClassPropertyReturnsOriginalClass_whenTheClassDoesNotConformToProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 1);
    Class * classes = (Class *)malloc(sizeof(Class) * 1);
    
    protocols[0] = @protocol(GraftedProtocol1);
    classes[0] = [ObjectDoesNotImplementGraftedProtocol1 class];
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses(object, protocols, classes, 1);
    
    free(protocols);
    free(classes);
    
    XCTAssertEqual([retVal class], [NSObject class]);
}

#pragma mark - Returned Object's Is-A Pointer
- (void)testObject_graftImplementationsOfProtocolsFromClasses_returnsObject_whoseIsaPointerIsAClassWithPrefixOf_ObjCGrafted__whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 1);
    Class * classes = (Class *)malloc(sizeof(Class) * 1);
    
    protocols[0] = @protocol(GraftedProtocol1);
    classes[0] = [ObjectImplementsGraftedProtocol1 class];
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses(object, protocols, classes, 1);
    
    free(protocols);
    free(classes);
    
    Class retValClass = object_getClass(retVal);
    NSString * retValClassName = NSStringFromClass(retValClass);
    
    XCTAssertTrue([retValClassName hasPrefix: @"_ObjCGrafted_"]);
}

- (void)testObject_graftImplementationsOfProtocolsFromClasses_returnsObject_whoseIsaPointerIsNotOriginalClass_whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 1);
    Class * classes = (Class *)malloc(sizeof(Class) * 1);
    
    protocols[0] = @protocol(GraftedProtocol1);
    classes[0] = [ObjectImplementsGraftedProtocol1 class];
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses(object, protocols, classes, 1);
    
    free(protocols);
    free(classes);
    
    Class retValClass = object_getClass(retVal);
    
    XCTAssertNotEqual(retValClass, [NSObject class]);
}

- (void)testObject_graftImplementationsOfProtocolsFromClasses_returnsObject_whoseIsaPointerIsNotSourceClass_whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 1);
    Class * classes = (Class *)malloc(sizeof(Class) * 1);
    
    protocols[0] = @protocol(GraftedProtocol1);
    classes[0] = [ObjectImplementsGraftedProtocol1 class];
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses(object, protocols, classes, 1);
    
    free(protocols);
    free(classes);
    
    Class retValClass = object_getClass(retVal);
    
    XCTAssertNotEqual(retValClass, [ObjectImplementsGraftedProtocol1 class]);
}

#pragma mark - Returned Object's Conformity with The Grafted Protocols
- (void)testObject_graftImplementationsOfProtocolsFromClasses_returnsObjectWhichConformsToGraftedProtocol_whenTheClassConformsToTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol2)]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 2);
    Class * classes = (Class *)malloc(sizeof(Class) * 2);
    
    protocols[0] = @protocol(GraftedProtocol1);
    classes[0] = [ObjectImplementsGraftedProtocol1 class];
    
    protocols[1] = @protocol(GraftedProtocol2);
    classes[1] = [ObjectImplementsGraftedProtocol2 class];
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses(object, protocols, classes, 2);
    
    free(protocols);
    free(classes);
    
    XCTAssertTrue([retVal conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertTrue([retVal conformsToProtocol: @protocol(GraftedProtocol2)]);
}

- (void)testObject_graftImplementationsOfProtocolsFromClasses_returnsObjectWhichConformsToGraftedProtocol_whenTheClassDoesNotConformTheProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertTrue([object conformsToProtocol: @protocol(NSObject)]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 2);
    Class * classes = (Class *)malloc(sizeof(Class) * 2);
    
    protocols[0] = @protocol(GraftedProtocol1);
    classes[0] = [NSArray class];
    
    protocols[1] = @protocol(GraftedProtocol2);
    classes[1] = [ObjectImplementsGraftedProtocol2 class];
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses(object, protocols, classes, 2);
    
    free(protocols);
    free(classes);
    
    XCTAssertFalse([retVal conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertTrue([retVal conformsToProtocol: @protocol(NSObject)]);
}

- (void)testObject_graftImplementationsOfProtocolsFromClasses_returnsObjectWhichConformsToGraftedProtocol_whenTheClassDoeNotConformTheProtocolButItsSuperclassDoes
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertFalse([object conformsToProtocol: @protocol(GraftedProtocol2)]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 2);
    Class * classes = (Class *)malloc(sizeof(Class) * 2);
    
    protocols[0] = @protocol(GraftedProtocol1);
    classes[0] = [ObjectImplementsGraftedProtocol1 class];
    
    protocols[1] = @protocol(GraftedProtocol2);
    classes[1] = [SubObjectImplementsGraftedProtocol2ForSuperclass class];
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses(object, protocols, classes, 2);
    
    free(protocols);
    free(classes);
    
    XCTAssertTrue([retVal conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertTrue([retVal conformsToProtocol: @protocol(GraftedProtocol2)]);
}

#pragma mark - Returned Object's Implementation
- (void)testObject_graftImplementationsOfProtocolsFromClasses_returnsObjectWhichImplementsMethods_whenMethodsAreDefinedByTheProtocolAndImplementedByTheClass_withProtocolWithoutHierarchy
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([object respondsToSelector:@selector(foo2)]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 2);
    Class * classes = (Class *)malloc(sizeof(Class) * 2);
    
    protocols[0] = @protocol(GraftedProtocol1);
    classes[0] = [ObjectImplementsGraftedProtocol1 class];
    
    protocols[1] = @protocol(GraftedProtocol2);
    classes[1] = [ObjectImplementsGraftedProtocol2 class];
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses(object, protocols, classes, 2);
    
    free(protocols);
    free(classes);
    
    XCTAssertTrue([retVal respondsToSelector:@selector(foo1)]);
    XCTAssertTrue([retVal respondsToSelector:@selector(foo2)]);
    
    XCTAssertEqual([retVal foo1], @"Foo1");
    XCTAssertEqual([retVal foo2], @"Foo2");
}

- (void)testObject_graftImplementationsOfProtocolsFromClasses_returnsObjectWhichDoesNotImplementMethods_whenMethodsAreDefinedByTheProtocolAnButNotImplementedByTheClass_withProtocolWithoutHierarchy
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([object respondsToSelector:@selector(foo2)]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 2);
    Class * classes = (Class *)malloc(sizeof(Class) * 2);
    
    protocols[0] = @protocol(GraftedProtocol1);
    classes[0] = [ObjectDoesNotImplementGraftedProtocol1 class];
    
    protocols[1] = @protocol(GraftedProtocol2);
    classes[1] = [ObjectImplementsGraftedProtocol2 class];
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses(object, protocols, classes, 2);
    
    free(protocols);
    free(classes);
    
    XCTAssertFalse([retVal respondsToSelector:@selector(foo1)]);
    XCTAssertTrue([retVal respondsToSelector:@selector(foo2)]);
    
    XCTAssertThrows([retVal foo1]);
    XCTAssertEqual([retVal foo2], @"Foo2");
}

- (void)testObject_graftImplementationsOfProtocolsFromClasses_returnsObjectWhichImplementsMethods_whenMethodsAreDefinedByTheProtocolAndImplementedByTheClass_withProtocolWithHierarchy
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([object respondsToSelector:@selector(bar1)]);
    XCTAssertFalse([object respondsToSelector:@selector(foo2)]);
    XCTAssertFalse([object respondsToSelector:@selector(bar2)]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 2);
    Class * classes = (Class *)malloc(sizeof(Class) * 2);
    
    protocols[0] = @protocol(SubGraftedProtocol1);
    classes[0] = [ObjectImplementsGraftedProtocol1 class];
    
    protocols[1] = @protocol(SubGraftedProtocol2);
    classes[1] = [ObjectImplementsGraftedProtocol2 class];
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses(object, protocols, classes, 2);
    
    free(protocols);
    free(classes);
    
    XCTAssertTrue([object respondsToSelector:@selector(foo1)]);
    XCTAssertTrue([object respondsToSelector:@selector(bar1)]);
    XCTAssertTrue([object respondsToSelector:@selector(foo2)]);
    XCTAssertTrue([object respondsToSelector:@selector(bar2)]);
    
    XCTAssertEqual([retVal foo1], @"Foo1");
    XCTAssertEqual([retVal bar1], @"Bar1");
    XCTAssertEqual([retVal foo2], @"Foo2");
    XCTAssertEqual([retVal bar2], @"Bar2");
}

- (void)testObject_graftImplementationsOfProtocolsFromClasses_returnsObjectWhichDoesNotImplementMethods_whenMethodsAreDefinedByTheProtocolAnButNotImplementedByTheClass_withProtocolWithHierarchy
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object respondsToSelector:@selector(foo1)]);
    XCTAssertFalse([object respondsToSelector:@selector(bar1)]);
    XCTAssertFalse([object respondsToSelector:@selector(foo2)]);
    XCTAssertFalse([object respondsToSelector:@selector(bar2)]);
    
    Protocol * __unsafe_unretained * protocols = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 2);
    Class * classes = (Class *)malloc(sizeof(Class) * 2);
    
    protocols[0] = @protocol(SubGraftedProtocol1);
    classes[0] = [ObjectDoesNotImplementGraftedProtocol1 class];
    
    protocols[1] = @protocol(SubGraftedProtocol2);
    classes[1] = [ObjectImplementsGraftedProtocol2 class];
    
    id retVal = object_graftImplementationsOfProtocolsFromClasses(object, protocols, classes, 2);
    
    free(protocols);
    free(classes);
    
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
