//
//  Object_removeGraftedImplementationsOfProtocols_nilTerminatedTests.m
//  ObjCGraft
//
//  Created on 31/12/2018.
//

#import <XCTest/XCTest.h>
#import <dispatch/dispatch.h>
#import <objc/runtime.h>

#import <ObjCGraft/ObjCGraft.h>

#import "ObjCGraftTestAuxiliaries.h"

@interface Object_removeGraftedImplementationsOfProtocols_nilTerminatedTests : XCTestCase
@property (nonatomic, strong) NSObject * object;
@end

@implementation Object_removeGraftedImplementationsOfProtocols_nilTerminatedTests
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
- (void)testObject_removeGraftedImplementationsOfProtocols_nilTerminated_returnsObjectWithIsaPointerNotRestored_whenRemovingNonLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationsOfProtocolsFromClass_nilTerminated(self.object, [ObjectImplementsGraftedProtocols class], @protocol(GraftedProtocol1), @protocol(GraftedProtocol2), nil);
    
    XCTAssertNotEqual(object_getClass(grafted), [NSObject class]);
    
    id removed = object_removeGraftedImplementationsOfProtocols_nilTerminated(grafted, @protocol(GraftedProtocol1), nil);
    
    XCTAssertNotEqual(object_getClass(removed), [NSObject class]);
}

- (void)testObject_removeGraftedImplementationsOfProtocols_nilTerminated_returnsObjectWithIsaPointerRestored_whenRemovingTheLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertNotEqual(object_getClass(grafted), [NSObject class]);
    
    id removed = object_removeGraftedImplementationsOfProtocols_nilTerminated(grafted, @protocol(GraftedProtocol1), nil);
    
    XCTAssertEqual(object_getClass(removed), [NSObject class]);
}

#pragma mark - Returned Object's Conformity to the Grafted Protocol
- (void)testObject_removeGraftedImplementationsOfProtocols_nilTerminated_returnsObjectWhichDoesNotConformsToTheRemovedGraftedProtocol_whenRemovingNonLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationsOfProtocolsFromClass_nilTerminated(self.object, [ObjectImplementsGraftedProtocols class], @protocol(GraftedProtocol1), @protocol(GraftedProtocol2), nil);
    
    XCTAssertTrue([grafted conformsToProtocol: @protocol(GraftedProtocol1)]);
    
    id removed = object_removeGraftedImplementationsOfProtocols_nilTerminated(grafted, @protocol(GraftedProtocol1), nil);
    
    XCTAssertFalse([removed conformsToProtocol: @protocol(GraftedProtocol1)]);
}

- (void)testObject_removeGraftedImplementationsOfProtocols_nilTerminated_returnsObjectWhichDoesNotConformsToTheRemovedGraftedProtocol_whenRemovingTheLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationsOfProtocolsFromClass_nilTerminated(self.object, [ObjectImplementsGraftedProtocols class], @protocol(GraftedProtocol1), @protocol(GraftedProtocol2), nil);
    
    XCTAssertTrue([grafted conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertTrue([grafted conformsToProtocol: @protocol(GraftedProtocol2)]);
    
    id removed = object_removeGraftedImplementationsOfProtocols_nilTerminated(grafted, @protocol(GraftedProtocol1), @protocol(GraftedProtocol2), nil);
    
    XCTAssertFalse([removed conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertFalse([removed conformsToProtocol: @protocol(GraftedProtocol2)]);
}

#pragma mark - Returned Object's Grafted Implementations
- (void)testObject_removeGraftedImplementationsOfProtocols_nilTerminated_returnsObjectWhichDoesNotImplementsMethodsOfTheRemovedGraftedProtocol_whenRemovingNonLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationsOfProtocolsFromClass_nilTerminated(self.object, [ObjectImplementsGraftedProtocols class], @protocol(GraftedProtocol1), @protocol(GraftedProtocol2), nil);
    
    XCTAssertTrue([grafted respondsToSelector: @selector(foo1)]);
    XCTAssertTrue([grafted respondsToSelector: @selector(foo2)]);
    
    id removed = object_removeGraftedImplementationsOfProtocols_nilTerminated(grafted, @protocol(GraftedProtocol1), nil);
    
    XCTAssertFalse([removed respondsToSelector: @selector(foo1)]);
    XCTAssertTrue([removed respondsToSelector: @selector(foo2)]);
}

- (void)testObject_removeGraftedImplementationsOfProtocols_nilTerminated_returnsObjectWhichDoesNotImplementsMethodsOfTheRemovedGraftedProtocol_whenRemovingTheLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationsOfProtocolsFromClass_nilTerminated(self.object, [ObjectImplementsGraftedProtocols class], @protocol(GraftedProtocol1), @protocol(GraftedProtocol2), nil);
    
    XCTAssertTrue([grafted respondsToSelector: @selector(foo1)]);
    XCTAssertTrue([grafted respondsToSelector: @selector(foo2)]);
    
    id removed = object_removeGraftedImplementationsOfProtocols_nilTerminated(grafted, @protocol(GraftedProtocol1), @protocol(GraftedProtocol2), nil);
    
    XCTAssertFalse([removed respondsToSelector: @selector(foo1)]);
    XCTAssertFalse([removed respondsToSelector: @selector(foo2)]);
}
@end
