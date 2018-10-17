//
//  ObjCGraftProtocolImplementationTest.swift
//  ObjCGrafting
//
//  Created by WeZZard on 22/10/2016.
//
//

import XCTest

@testable
import ObjCGrafting


@objc
internal class Observer: NSObject {
    
    @objc
    var intValues: [Int] = []
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
        )
    {
        assert(keyPath == "intValue")
        
        let newIntValue = change![.newKey] as! Int
        
        intValues.append(newIntValue)
    }
}

private let GraftableObjectName = GraftableObject.description()
private let GraftImplSourceName = GraftImplSource.description()

class ObjCGraftProtocolImplementationTest: XCTestCase {
    
    var object: GraftableObject!
    
    override func setUp() {
        super.setUp()
        
        object = GraftableObject()
    }
    
    override func tearDown() {
        object = nil
        
        super.tearDown()
    }
    
    // MARK: Test interface's basic functionalities
    func testObjCGraftImplementation() {
        _ = ObjCGraftImplementation(
            of: GraftTableExpanded.self,
            on: GraftImplSource.self,
            to: object
        )
        
        XCTAssert(object.conforms(to: GraftTableExpanded.self))
        
        let expectedInstanceMethodAccessRecords = [
            NSStringFromSelector(#selector(getter: GraftableObject.intValue)): GraftImplSourceName,
            NSStringFromSelector(#selector(setter: GraftableObject.intValue)): GraftableObjectName,
            NSStringFromSelector(#selector(GraftableObject.fatherInstanceMethod)): GraftImplSourceName,
            NSStringFromSelector(#selector(GraftableObject.childInstanceMethod)): GraftImplSourceName,
        ]
        
        let expectedClassMethodAccessRecords = [
            NSStringFromSelector(#selector(GraftableObject.fatherClassMethod)): GraftImplSourceName,
            NSStringFromSelector(#selector(GraftableObject.childClassMethod)): GraftImplSourceName,
        ]
        
        _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords, with: expectedClassMethodAccessRecords)
    }
    
    func testObjCUngraftImplementation() {
        
        _ = ObjCGraftImplementation(
            of: GraftTableExpanded.self,
            on: GraftImplSource.self,
            to: object
        )
        
        ObjCUngraftAllImplementationsOfProtocols(on: object)
        
        let expectedInstanceMethodAccessRecords = [
            NSStringFromSelector(#selector(getter: GraftableObject.intValue)): GraftableObjectName,
            NSStringFromSelector(#selector(setter: GraftableObject.intValue)): GraftableObjectName,
            NSStringFromSelector(#selector(GraftableObject.fatherInstanceMethod)): GraftableObjectName,
            NSStringFromSelector(#selector(GraftableObject.childInstanceMethod)): GraftableObjectName,
        ]
        
        let expectedClassMethodAccessRecords = [
            NSStringFromSelector(#selector(GraftableObject.fatherClassMethod)): GraftableObjectName,
            NSStringFromSelector(#selector(GraftableObject.childClassMethod)): GraftableObjectName,
        ]
        
        _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords, with: expectedClassMethodAccessRecords)
    }
    
    // MARK: Test applying in symbiosis with KVO
    func testAddObserver_Graft_RemoveObserver_Ungraft() {
        
        let observer = Observer()
        
        object.addObserver(observer, forKeyPath: "intValue", options: [.new], context: nil)
        
        _ = ObjCGraftImplementation(
            of: GraftTableExpanded.self,
            on: GraftImplSource.self,
            to: object
        )
        
        let expectedInstanceMethodAccessRecords = [
            NSStringFromSelector(#selector(getter: GraftableObject.intValue)): GraftImplSourceName,
            NSStringFromSelector(#selector(setter: GraftableObject.intValue)): GraftableObjectName,
            NSStringFromSelector(#selector(GraftableObject.fatherInstanceMethod)): GraftImplSourceName,
            NSStringFromSelector(#selector(GraftableObject.childInstanceMethod)): GraftImplSourceName,
        ]
        
        let expectedClassMethodAccessRecords = [
            NSStringFromSelector(#selector(GraftableObject.fatherClassMethod)): GraftImplSourceName,
            NSStringFromSelector(#selector(GraftableObject.childClassMethod)): GraftImplSourceName,
        ]
        
        _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords, with: expectedClassMethodAccessRecords)
        
        object.removeObserver(observer, forKeyPath: "intValue", context: nil)
        
        object.clearAccessRecords()
        type(of: object!).clearAccessRecords()
        
        XCTAssert(object.accessRecords.isEmpty)
        XCTAssert(type(of: object!).accessRecords.isEmpty)
        
        _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords, with: expectedClassMethodAccessRecords)
        
        XCTAssert(observer.intValues.elementsEqual([0]), "Unexpected observed int values: \(observer.intValues)")
        
        ObjCUngraftAllImplementationsOfProtocols(on: object)
        
        let expectedInstanceMethodAccessRecords2 = [
            NSStringFromSelector(#selector(getter: GraftableObject.intValue)): GraftableObjectName,
            NSStringFromSelector(#selector(setter: GraftableObject.intValue)): GraftableObjectName,
            NSStringFromSelector(#selector(GraftableObject.fatherInstanceMethod)): GraftableObjectName,
            NSStringFromSelector(#selector(GraftableObject.childInstanceMethod)): GraftableObjectName,
        ]
        
        let expectedClassMethodAccessRecords2 = [
            NSStringFromSelector(#selector(GraftableObject.fatherClassMethod)): GraftableObjectName,
            NSStringFromSelector(#selector(GraftableObject.childClassMethod)): GraftableObjectName,
        ]
        
        object.clearAccessRecords()
        type(of: object!).clearAccessRecords()
        
        _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords2, with: expectedClassMethodAccessRecords2)
    }
    
    func testGraft_AddObserver_Ungraft_RemoveObserver() {
        
        let observer = Observer()
        
        _ = ObjCGraftImplementation(
            of: GraftTableExpanded.self,
            on: GraftImplSource.self,
            to: object
        )
        
        object.addObserver(observer, forKeyPath: "intValue", options: [.new], context: nil)
        
        let expectedInstanceMethodAccessRecords = [
            NSStringFromSelector(#selector(getter: GraftableObject.intValue)): GraftImplSourceName,
            NSStringFromSelector(#selector(setter: GraftableObject.intValue)): GraftableObjectName,
            NSStringFromSelector(#selector(GraftableObject.fatherInstanceMethod)): GraftImplSourceName,
            NSStringFromSelector(#selector(GraftableObject.childInstanceMethod)): GraftImplSourceName,
            ]
        
        let expectedClassMethodAccessRecords = [
            NSStringFromSelector(#selector(GraftableObject.fatherClassMethod)): GraftImplSourceName,
            NSStringFromSelector(#selector(GraftableObject.childClassMethod)): GraftImplSourceName,
            ]
        
        _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords, with: expectedClassMethodAccessRecords)
        
        ObjCUngraftAllImplementationsOfProtocols(on: object)
        
        let expectedInstanceMethodAccessRecords2 = [
            NSStringFromSelector(#selector(getter: GraftableObject.intValue)): GraftableObjectName,
            NSStringFromSelector(#selector(setter: GraftableObject.intValue)): GraftableObjectName,
            NSStringFromSelector(#selector(GraftableObject.fatherInstanceMethod)): GraftableObjectName,
            NSStringFromSelector(#selector(GraftableObject.childInstanceMethod)): GraftableObjectName,
            ]
        
        let expectedClassMethodAccessRecords2 = [
            NSStringFromSelector(#selector(GraftableObject.fatherClassMethod)): GraftableObjectName,
            NSStringFromSelector(#selector(GraftableObject.childClassMethod)): GraftableObjectName,
            ]
        
        object.clearAccessRecords()
        type(of: object!).clearAccessRecords()
        
        _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords2, with: expectedClassMethodAccessRecords2)
        
        object.removeObserver(observer, forKeyPath: "intValue", context: nil)
        
        object.clearAccessRecords()
        type(of: object!).clearAccessRecords()
        
        XCTAssert(object.accessRecords.isEmpty)
        XCTAssert(type(of: object!).accessRecords.isEmpty)
        
        _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords2, with: expectedClassMethodAccessRecords2)
        
        XCTAssert(observer.intValues.elementsEqual([0, 0]), "Unexpected observed int values: \(observer.intValues)")
    }
    
    func testAddObserver_Graft_RemoveObserver() {
        autoreleasepool { () -> Void in
            let observer = Observer()
            
            object.addObserver(observer, forKeyPath: "intValue", options: [.new], context: nil)
            
            _ = ObjCGraftImplementation(
                of: GraftTableExpanded.self,
                on: GraftImplSource.self,
                to: object
            )
            
            let expectedInstanceMethodAccessRecords = [
                NSStringFromSelector(#selector(getter: GraftableObject.intValue)): GraftImplSourceName,
                NSStringFromSelector(#selector(setter: GraftableObject.intValue)): GraftableObjectName,
                NSStringFromSelector(#selector(GraftableObject.fatherInstanceMethod)): GraftImplSourceName,
                NSStringFromSelector(#selector(GraftableObject.childInstanceMethod)): GraftImplSourceName,
                ]
            
            let expectedClassMethodAccessRecords = [
                NSStringFromSelector(#selector(GraftableObject.fatherClassMethod)): GraftImplSourceName,
                NSStringFromSelector(#selector(GraftableObject.childClassMethod)): GraftImplSourceName,
                ]
            
            _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords, with: expectedClassMethodAccessRecords)
            
            object.removeObserver(observer, forKeyPath: "intValue", context: nil)
            
            object.clearAccessRecords()
            type(of: object!).clearAccessRecords()
            
            XCTAssert(object.accessRecords.isEmpty)
            XCTAssert(type(of: object!).accessRecords.isEmpty)
            
            _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords, with: expectedClassMethodAccessRecords)
            
            XCTAssert(observer.intValues.elementsEqual([0]), "Unexpected observed int values: \(observer.intValues)")
        }
    }
    
    func testAddObserver_Graft_Ungraft_RemoveObserver() {
        autoreleasepool { () -> Void in
            let observer = Observer()
            
            object.addObserver(observer, forKeyPath: "intValue", options: [.new], context: nil)
            
            _ = ObjCGraftImplementation(
                of: GraftTableExpanded.self,
                on: GraftImplSource.self,
                to: object
            )
            
            let expectedInstanceMethodAccessRecords = [
                NSStringFromSelector(#selector(getter: GraftableObject.intValue)): GraftImplSourceName,
                NSStringFromSelector(#selector(setter: GraftableObject.intValue)): GraftableObjectName,
                NSStringFromSelector(#selector(GraftableObject.fatherInstanceMethod)): GraftImplSourceName,
                NSStringFromSelector(#selector(GraftableObject.childInstanceMethod)): GraftImplSourceName,
                ]
            
            let expectedClassMethodAccessRecords = [
                NSStringFromSelector(#selector(GraftableObject.fatherClassMethod)): GraftImplSourceName,
                NSStringFromSelector(#selector(GraftableObject.childClassMethod)): GraftImplSourceName,
                ]
            
            _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords, with: expectedClassMethodAccessRecords)
            
            ObjCUngraftAllImplementationsOfProtocols(on: object);
            
            let expectedInstanceMethodAccessRecords2 = [
                NSStringFromSelector(#selector(getter: GraftableObject.intValue)): GraftableObjectName,
                NSStringFromSelector(#selector(setter: GraftableObject.intValue)): GraftableObjectName,
                NSStringFromSelector(#selector(GraftableObject.fatherInstanceMethod)): GraftableObjectName,
                NSStringFromSelector(#selector(GraftableObject.childInstanceMethod)): GraftableObjectName,
                ]
            
            let expectedClassMethodAccessRecords2 = [
                NSStringFromSelector(#selector(GraftableObject.fatherClassMethod)): GraftableObjectName,
                NSStringFromSelector(#selector(GraftableObject.childClassMethod)): GraftableObjectName,
                ]
            
            object.clearAccessRecords()
            type(of: object!).clearAccessRecords()
            
            _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords2, with: expectedClassMethodAccessRecords2)
            
            object.removeObserver(observer, forKeyPath: "intValue", context: nil)
            
            object.clearAccessRecords()
            type(of: object!).clearAccessRecords()
            
            XCTAssert(object.accessRecords.isEmpty)
            XCTAssert(type(of: object!).accessRecords.isEmpty)
            
            _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords2, with: expectedClassMethodAccessRecords2)
            
            XCTAssert(observer.intValues.elementsEqual([0, 0]), "Unexpected observed int values: \(observer.intValues)")
        }
    }
    
    func testAddObserver_Graft_Ungraft_RemoveObserver_Graft() {
        autoreleasepool { () -> Void in
            let observer = Observer()
            
            object.addObserver(observer, forKeyPath: "intValue", options: [.new], context: nil)
            
            _ = ObjCGraftImplementation(
                of: GraftTableExpanded.self,
                on: GraftImplSource.self,
                to: object
            )
            
            let expectedInstanceMethodAccessRecords = [
                NSStringFromSelector(#selector(getter: GraftableObject.intValue)): GraftImplSourceName,
                NSStringFromSelector(#selector(setter: GraftableObject.intValue)): GraftableObjectName,
                NSStringFromSelector(#selector(GraftableObject.fatherInstanceMethod)): GraftImplSourceName,
                NSStringFromSelector(#selector(GraftableObject.childInstanceMethod)): GraftImplSourceName,
                ]
            
            let expectedClassMethodAccessRecords = [
                NSStringFromSelector(#selector(GraftableObject.fatherClassMethod)): GraftImplSourceName,
                NSStringFromSelector(#selector(GraftableObject.childClassMethod)): GraftImplSourceName,
                ]
            
            _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords, with: expectedClassMethodAccessRecords)
            
            ObjCUngraftAllImplementationsOfProtocols(on: object);
            
            let expectedInstanceMethodAccessRecords2 = [
                NSStringFromSelector(#selector(getter: GraftableObject.intValue)): GraftableObjectName,
                NSStringFromSelector(#selector(setter: GraftableObject.intValue)): GraftableObjectName,
                NSStringFromSelector(#selector(GraftableObject.fatherInstanceMethod)): GraftableObjectName,
                NSStringFromSelector(#selector(GraftableObject.childInstanceMethod)): GraftableObjectName,
                ]
            
            let expectedClassMethodAccessRecords2 = [
                NSStringFromSelector(#selector(GraftableObject.fatherClassMethod)): GraftableObjectName,
                NSStringFromSelector(#selector(GraftableObject.childClassMethod)): GraftableObjectName,
                ]
            
            object.clearAccessRecords()
            type(of: object!).clearAccessRecords()
            
            _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords2, with: expectedClassMethodAccessRecords2)
            
            object.removeObserver(observer, forKeyPath: "intValue", context: nil)
            
            object.clearAccessRecords()
            type(of: object!).clearAccessRecords()
            
            XCTAssert(object.accessRecords.isEmpty)
            XCTAssert(type(of: object!).accessRecords.isEmpty)
            
            _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords2, with: expectedClassMethodAccessRecords2)
            
            _ = ObjCGraftImplementation(
                of: GraftTableExpanded.self,
                on: GraftImplSource.self,
                to: object
            )
            
            object.clearAccessRecords()
            type(of: object!).clearAccessRecords()
            
            _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords, with: expectedClassMethodAccessRecords)
            
            XCTAssert(observer.intValues.elementsEqual([0, 0]), "Unexpected observed int values: \(observer.intValues)")
        }
    }
    
    private func _assertObjectAccessRecord(
        bySettingIntValue intValue: Int,
        with expectedInstanceMethodAccessRecords: [String : String],
        with expectedClassMethodAccessRecords: [String : String]
        )
    {
        let Object = object_getClass(object) as! GraftableObject.Type

        _ = object.intValue
        object.intValue = intValue
        object.fatherInstanceMethod()
        Object.fatherClassMethod()
        object.childInstanceMethod()
        Object.childClassMethod()
        
        for (selector, expectedName) in expectedInstanceMethodAccessRecords {
            let name = object.accessRecords[selector]
            if name != expectedName {
                XCTFail("Unexpected access record for selector -\(selector): \"\(name ?? "nil")\", which is expected to be \"\(expectedName)\"")
            }
        }
        
        for (selector, expectedName) in expectedClassMethodAccessRecords {
            let name = Object.accessRecords[selector]
            if name != expectedName {
                XCTFail("Unexpected access record for selector +\(selector): \"\(name ?? "nil")\", which is expected to be \"\(expectedName)\"")
            }
        }
    }
    
}
