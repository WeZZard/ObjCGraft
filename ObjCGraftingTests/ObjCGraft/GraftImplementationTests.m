//
//  GraftImplementationTests.m
//  ObjCGrafting
//
//  Created on 29/12/2018.
//

#import <XCTest/XCTest.h>
#import <ObjCGrafting/ObjCGrafting.h>

#import <objc/runtime.h>

#import "SubAspect.h"
#import "ManipulatedObject.h"
#import "ImplSource.h"

@interface GraftImplementationObjectiveCTests : XCTestCase

@end

@implementation GraftImplementationObjectiveCTests
#pragma mark object_graftImplementationOfProtocol
- (void)testObject_graftImplementationOfProtocol_setsTheIsaPointerOfTheObjectToACompositedClass
{
    NSObject * object = [[NSObject alloc] init];
    
    Class objectClass = object_getClass(object);
    
    XCTAssertEqual(objectClass, [NSObject class]);
    XCTAssertNotEqual(objectClass, [NSArray class]);
    
    id retVal = object_graftImplementationOfProtocol(object, @protocol(NSObject), [NSProxy class]);
    
    Class retValClass = object_getClass(retVal);
    NSString * retValClassName = NSStringFromClass(retValClass);
    
    XCTAssertNotEqual(retValClass, [NSProxy class]);
    XCTAssertNotEqual(retValClass, [NSArray class]);
    XCTAssert([retValClassName hasPrefix: @"_ObjCGrafted_"]);
}

- (void)testObject_graftImplementationOfProtocol_returnsTheObject
{
    NSObject * object = [[NSObject alloc] init];
    
    id retVal = object_graftImplementationOfProtocol(object, @protocol(NSObject), [NSArray class]);
    
    XCTAssert(retVal == object);
}

- (void)testObject_graftImplementationOfProtocol_returnsObject_whichWithImplementationOfProtocolGraftedFromClass
{
    NSObject * object = [[NSObject alloc] init];
    
    XCTAssertFalse([object isProxy]);
    
    id retVal = object_graftImplementationOfProtocol(object, @protocol(NSObject), [NSProxy class]);
    
    XCTAssert([retVal isProxy]);
}

- (void)testObject_graftImplementationOfProtocol_returnsObjectOfNothingChanged_whenTheClassDoeNotConformToProtocolButItsSuperclassDoes
{
    NSObject * object = [[NSObject alloc] init];
    
    id retVal = object_graftImplementationOfProtocol(object, @protocol(NSObject), [NSArray class]);
    
    Class retValClass = object_getClass(retVal);
    
    XCTAssertEqual(retValClass, [NSObject class]);
}

- (void)testObject_graftImplementationOfProtocol_returnsObjectOfNothingChanged_whenTheClassIsNotConformToProtocol
{
    NSObject * object = [[NSObject alloc] init];
    
    id retVal = object_graftImplementationOfProtocol(object, @protocol(NSStreamDelegate), [NSProxy class]);
    
    Class retValClass = object_getClass(retVal);
    
    XCTAssertEqual(retValClass, [NSObject class]);
}

- (void)testObject_graftImplementationOfProtocol_returnsObjectOfNothingChanged_whenTheClassIsNotImplementingProtocol
{
    
}

#pragma mark object_graftImplementationsOfProtocols
- (void)testObject_graftImplementationsOfProtocols_returnsObject_whichWithImplementationsOfProtocolsGraftedFromClasses
{
    
}

- (void)testObject_graftImplementationsOfProtocols_returnsObjectOfPartiallyChanged_whenAClassIsNotConformToProtocol
{
    
}

- (void)testObject_graftImplementationsOfProtocols_returnsObjectOfPartiallyChanged_whenAClassIsNotImplementingProtocol
{
    
}

#pragma mark object_graftImplementationsOfProtocols_nilTerminated
- (void)object_graftImplementationsOfProtocols_nilTerminated_returnsObject_whichWithImplementationsOfProtocolsGraftedFromClasses
{
    
}

- (void)object_graftImplementationsOfProtocols_nilTerminated_throws_whenProtocolAndClassIsNotPaired
{
    
}
@end
