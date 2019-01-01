//
//  Object_removeAllGraftedImplementationsTests.m
//  ObjCGrafting
//
//  Created on 31/12/2018.
//

#import <XCTest/XCTest.h>
#import <dispatch/dispatch.h>
#import <objc/runtime.h>

#import <ObjCGrafting/ObjCGrafting.h>

#import "ObjCGraftTestAuxiliaries.h"

@interface Object_removeAllGraftedImplementationsTests : XCTestCase
@property (nonatomic, strong) NSObject * object;
@end

@implementation Object_removeAllGraftedImplementationsTests
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
- (void)testObject_removeAllGraftedImplementations_returnsObjectWithIsaPointerRestored {
    id grafted = object_graftImplementationOfProtocolFromClass(self.object, @protocol(GraftedProtocol1), [ObjectImplementsGraftedProtocol1 class]);
    
    XCTAssertNotEqual(object_getClass(grafted), [NSObject class]);
    
    id removed = object_removeAllGraftedImplementations(grafted);
    
    XCTAssertEqual(object_getClass(removed), [NSObject class]);
}

#pragma mark - Returned Object's Conformity to the Grafted Protocol
- (void)testObject_removeAllGraftedImplementations_returnsObjectWhichDoesNotConformsToTheRemovedGraftedProtocol {
    id grafted = object_graftImplementationsOfProtocolsFromClass_nilTerminated(self.object, [ObjectImplementsGraftedProtocols class], @protocol(GraftedProtocol1), @protocol(GraftedProtocol2), nil);
    
    XCTAssertTrue([grafted conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertTrue([grafted conformsToProtocol: @protocol(GraftedProtocol2)]);
    
    id removed = object_removeAllGraftedImplementations(grafted);
    
    XCTAssertFalse([removed conformsToProtocol: @protocol(GraftedProtocol1)]);
    XCTAssertFalse([removed conformsToProtocol: @protocol(GraftedProtocol2)]);
}

#pragma mark - Returned Object's Grafted Implementations
- (void)testObject_removeAllGraftedImplementations_returnsObjectWhichDoesNotImplementsMethodsOfTheRemovedGraftedProtocol {
    id grafted = object_graftImplementationsOfProtocolsFromClass_nilTerminated(self.object, [ObjectImplementsGraftedProtocols class], @protocol(GraftedProtocol1), @protocol(GraftedProtocol2), nil);
    
    XCTAssertTrue([grafted respondsToSelector: @selector(foo1)]);
    XCTAssertTrue([grafted respondsToSelector: @selector(foo2)]);
    
    id removed = object_removeAllGraftedImplementations(grafted);
    
    XCTAssertFalse([removed respondsToSelector: @selector(foo1)]);
    XCTAssertFalse([removed respondsToSelector: @selector(foo2)]);
}
@end
