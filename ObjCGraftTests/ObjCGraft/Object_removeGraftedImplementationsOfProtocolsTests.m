//
//  Object_removeGraftedImplementationsOfProtocolsTests.m
//  ObjCGraft
//
//  Created on 31/12/2018.
//

#import <XCTest/XCTest.h>
#import <dispatch/dispatch.h>
#import <objc/runtime.h>

#import <ObjCGraft/ObjCGraft.h>

#import "ObjCGraftTestAuxiliaries.h"

@interface Object_removeGraftedImplementationsOfProtocolsTests : XCTestCase
@property (nonatomic, strong) NSObject * object;
@property (nonatomic, assign) Protocol * __unsafe_unretained * protocol1;
@property (nonatomic, assign) Protocol * __unsafe_unretained * protocol1And2;
@end

@implementation Object_removeGraftedImplementationsOfProtocolsTests
- (void)setUp
{
    [super setUp];
    self.object = [[NSObject alloc] init];
    
    self.protocol1 = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 1);
    self.protocol1And2 = (Protocol * __unsafe_unretained *)malloc(sizeof(Protocol *) * 2);
    self.protocol1[0] = @protocol(GraftedProtocol1);
    self.protocol1And2[0] = @protocol(GraftedProtocol1);
    self.protocol1And2[1] = @protocol(GraftedProtocol2);
}

- (void)tearDown
{
    self.object = nil;
    free(self.protocol1);
    free(self.protocol1And2);
}

#pragma mark - Returned Object's Is-A Pointer
- (void)testObject_removeGraftedImplementationsOfProtocols_returnsObjectWithIsaPointerNotRestored_whenRemovingNonLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationsOfProtocolsFromClass_nilTerminated(self.object, [ObjectImplementsGraftedProtocols class], @protocol(GraftedProtocol1), @protocol(GraftedProtocol2), nil);
    
    XCTAssertNotEqual(object_getClass(grafted), [NSObject class]);
    
    id removed = object_removeGraftedImplementationsOfProtocols(grafted, self.protocol1, 1);
    
    XCTAssertNotEqual(object_getClass(removed), [NSObject class]);
}

- (void)testObject_removeGraftedImplementationsOfProtocols_returnsObjectWithIsaPointerRestored_whenRemovingTheLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertNotEqual(object_getClass(grafted), [NSObject class]);
    
    id removed = object_removeGraftedImplementationsOfProtocols(grafted, self.protocol1, 1);
    
    XCTAssertEqual(object_getClass(removed), [NSObject class]);
}

#pragma mark - Returned Object's Conformity to the Grafted Protocol
- (void)testObject_removeGraftedImplementationsOfProtocols_returnsObjectWhichDoesNotConformsToTheRemovedGraftedProtocol_whenRemovingNonLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationsOfProtocolsFromClass_nilTerminated(self.object, [ObjectImplementsGraftedProtocols class], @protocol(GraftedProtocol1), @protocol(GraftedProtocol2), nil);
    
    XCTAssertTrue([grafted conformsToProtocol: @protocol(GraftedProtocol1)]);
    
    id removed = object_removeGraftedImplementationsOfProtocols(grafted, self.protocol1, 1);
    
    XCTAssertFalse([removed conformsToProtocol: @protocol(GraftedProtocol1)]);
}

- (void)testObject_removeGraftedImplementationsOfProtocols_returnsObjectWhichDoesNotConformsToTheRemovedGraftedProtocol_whenRemovingTheLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationsOfProtocolsFromClass_nilTerminated(self.object, [ObjectImplementsGraftedProtocols class], @protocol(GraftedProtocol1), @protocol(GraftedProtocol2), nil);
    
    XCTAssertTrue([grafted conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertTrue([grafted conformsToProtocol: @protocol(GraftedProtocol2)]);
    
    id removed = object_removeGraftedImplementationsOfProtocols(grafted, self.protocol1And2, 2);
    
    XCTAssertFalse([removed conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertFalse([removed conformsToProtocol: @protocol(GraftedProtocol2)]);
}

#pragma mark - Returned Object's Grafted Implementations
- (void)testObject_removeGraftedImplementationsOfProtocols_returnsObjectWhichDoesNotImplementsMethodsOfTheRemovedGraftedProtocol_whenRemovingNonLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationsOfProtocolsFromClass_nilTerminated(self.object, [ObjectImplementsGraftedProtocols class], @protocol(GraftedProtocol1), @protocol(GraftedProtocol2), nil);
    
    XCTAssertTrue([grafted respondsToSelector: @selector(foo1)]);
    XCTAssertTrue([grafted respondsToSelector: @selector(foo2)]);
    
    id removed = object_removeGraftedImplementationsOfProtocols(grafted, self.protocol1, 1);
    
    XCTAssertFalse([removed respondsToSelector: @selector(foo1)]);
    XCTAssertTrue([removed respondsToSelector: @selector(foo2)]);
}

- (void)testObject_removeGraftedImplementationsOfProtocols_returnsObjectWhichDoesNotImplementsMethodsOfTheRemovedGraftedProtocol_whenRemovingTheLastGraftedImplementationsOfProtocol {
    id grafted = object_graftImplementationsOfProtocolsFromClass_nilTerminated(self.object, [ObjectImplementsGraftedProtocols class], @protocol(GraftedProtocol1), @protocol(GraftedProtocol2), nil);
    
    XCTAssertTrue([grafted respondsToSelector: @selector(foo1)]);
    XCTAssertTrue([grafted respondsToSelector: @selector(foo2)]);
    
    id removed = object_removeGraftedImplementationsOfProtocols(grafted, self.protocol1And2, 2);
    
    XCTAssertFalse([removed respondsToSelector: @selector(foo1)]);
    XCTAssertFalse([removed respondsToSelector: @selector(foo2)]);
}
@end
