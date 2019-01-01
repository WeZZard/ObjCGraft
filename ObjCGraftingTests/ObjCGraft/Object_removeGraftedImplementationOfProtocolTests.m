//
//  Object_removeGraftedImplementationOfProtocolTests.m
//  ObjCGrafting
//
//  Created on 31/12/2018.
//

#import <XCTest/XCTest.h>
#import <dispatch/dispatch.h>
#import <objc/runtime.h>

#import <ObjCGrafting/ObjCGrafting.h>

#import "ObjCGraftTestAuxiliaries.h"

@interface Object_removeGraftedImplementationOfProtocolTests : XCTestCase
@property (nonatomic, strong) NSObject * object;
@end

@implementation Object_removeGraftedImplementationOfProtocolTests
- (void)setUp
{
    [super setUp];
    self.object = [[NSObject alloc] init];
}

- (void)tearDown
{
    self.object = nil;
}

#pragma mark - Returned Object's Is-A Pointer
- (void)testObject_removeGraftedImplementationOfProtocol_returnsObjectWithIsaPointerNotRestored_whenRemovingNonLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationsOfProtocolsFromClass_nilTerminated(self.object, [ObjectImplementsGraftedProtocols class], @protocol(GraftedProtocol1), @protocol(GraftedProtocol2), nil);
    
    XCTAssertNotEqual(object_getClass(grafted), [NSObject class]);
    
    id removed = object_removeGraftedImplementationOfProtocol(grafted, @protocol(GraftedProtocol1));
    
    XCTAssertNotEqual(object_getClass(removed), [NSObject class]);
}

- (void)testObject_removeGraftedImplementationOfProtocol_returnsObjectWithIsaPointerRestored_whenRemovingTheLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertNotEqual(object_getClass(grafted), [NSObject class]);
    
    id removed = object_removeGraftedImplementationOfProtocol(grafted, @protocol(GraftedProtocol1));
    
    XCTAssertEqual(object_getClass(removed), [NSObject class]);
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
