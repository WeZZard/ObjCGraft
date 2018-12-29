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

class ObjCGraftProtocolImplementationTest: XCTestCase {
    
    var object: ManipulatedObject!
    
    override func setUp() {
        super.setUp()
        
        object = ManipulatedObject()
    }
    
    override func tearDown() {
        object = nil
        
        super.tearDown()
    }
    
    // MARK: Test interface's basic functionalities
    func testObjCGraftImplementation() {
        _ = ObjCGraftImplementation(
            of: SubAspect.self,
            on: ImplSource.self,
            to: object
        )
        
        XCTAssert(object.conforms(to: SubAspect.self))
        
        let expectedInstanceMethodAccessRecords = [
            NSStringFromSelector(#selector(getter: ManipulatedObject.intValue)): ImplSourceName,
            NSStringFromSelector(#selector(setter: ManipulatedObject.intValue)): ManipulatedObjectName,
            NSStringFromSelector(#selector(ManipulatedObject.parentInstanceMethod)): ImplSourceName,
            NSStringFromSelector(#selector(ManipulatedObject.childInstanceMethod)): ImplSourceName,
        ]
        
        let expectedClassMethodAccessRecords = [
            NSStringFromSelector(#selector(ManipulatedObject.parentClassMethod)): ImplSourceName,
            NSStringFromSelector(#selector(ManipulatedObject.childClassMethod)): ImplSourceName,
        ]
        
        _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords, with: expectedClassMethodAccessRecords)
    }
    
    func testObjCRemoveAllGraftedImplementations() {
        
        _ = ObjCGraftImplementation(
            of: SubAspect.self,
            on: ImplSource.self,
            to: object
        )
        
        ObjCRemoveAllGraftedImplementations(from: object)
        
        let expectedInstanceMethodAccessRecords = [
            NSStringFromSelector(#selector(getter: ManipulatedObject.intValue)): ManipulatedObjectName,
            NSStringFromSelector(#selector(setter: ManipulatedObject.intValue)): ManipulatedObjectName,
            NSStringFromSelector(#selector(ManipulatedObject.parentInstanceMethod)): ManipulatedObjectName,
            NSStringFromSelector(#selector(ManipulatedObject.childInstanceMethod)): ManipulatedObjectName,
        ]
        
        let expectedClassMethodAccessRecords = [
            NSStringFromSelector(#selector(ManipulatedObject.parentClassMethod)): ManipulatedObjectName,
            NSStringFromSelector(#selector(ManipulatedObject.childClassMethod)): ManipulatedObjectName,
        ]
        
        _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords, with: expectedClassMethodAccessRecords)
    }
    
    // MARK: Test applying in symbiosis with KVO
    func testAddObserver_Graft_RemoveObserver_Ungraft() {
        
        let observer = Observer()
        
        object.addObserver(observer, forKeyPath: "intValue", options: [.new], context: nil)
        
        _ = ObjCGraftImplementation(
            of: SubAspect.self,
            on: ImplSource.self,
            to: object
        )
        
        let expectedInstanceMethodAccessRecords = [
            NSStringFromSelector(#selector(getter: ManipulatedObject.intValue)): ImplSourceName,
            NSStringFromSelector(#selector(setter: ManipulatedObject.intValue)): ManipulatedObjectName,
            NSStringFromSelector(#selector(ManipulatedObject.parentInstanceMethod)): ImplSourceName,
            NSStringFromSelector(#selector(ManipulatedObject.childInstanceMethod)): ImplSourceName,
        ]
        
        let expectedClassMethodAccessRecords = [
            NSStringFromSelector(#selector(ManipulatedObject.parentClassMethod)): ImplSourceName,
            NSStringFromSelector(#selector(ManipulatedObject.childClassMethod)): ImplSourceName,
        ]
        
        _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords, with: expectedClassMethodAccessRecords)
        
        object.removeObserver(observer, forKeyPath: "intValue", context: nil)
        
        object.clearAccessRecords()
        type(of: object!).clearAccessRecords()
        
        XCTAssert(object.accessRecords.isEmpty)
        XCTAssert(type(of: object!).accessRecords.isEmpty)
        
        _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords, with: expectedClassMethodAccessRecords)
        
        XCTAssert(observer.intValues.elementsEqual([0]), "Unexpected observed int values: \(observer.intValues)")
        
        ObjCRemoveAllGraftedImplementations(from: object)
        
        let expectedInstanceMethodAccessRecords2 = [
            NSStringFromSelector(#selector(getter: ManipulatedObject.intValue)): ManipulatedObjectName,
            NSStringFromSelector(#selector(setter: ManipulatedObject.intValue)): ManipulatedObjectName,
            NSStringFromSelector(#selector(ManipulatedObject.parentInstanceMethod)): ManipulatedObjectName,
            NSStringFromSelector(#selector(ManipulatedObject.childInstanceMethod)): ManipulatedObjectName,
        ]
        
        let expectedClassMethodAccessRecords2 = [
            NSStringFromSelector(#selector(ManipulatedObject.parentClassMethod)): ManipulatedObjectName,
            NSStringFromSelector(#selector(ManipulatedObject.childClassMethod)): ManipulatedObjectName,
        ]
        
        object.clearAccessRecords()
        type(of: object!).clearAccessRecords()
        
        _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords2, with: expectedClassMethodAccessRecords2)
    }
    
    func testGraft_AddObserver_Ungraft_RemoveObserver() {
        
        let observer = Observer()
        
        _ = ObjCGraftImplementation(
            of: SubAspect.self,
            on: ImplSource.self,
            to: object
        )
        
        object.addObserver(observer, forKeyPath: "intValue", options: [.new], context: nil)
        
        let expectedInstanceMethodAccessRecords = [
            NSStringFromSelector(#selector(getter: ManipulatedObject.intValue)): ImplSourceName,
            NSStringFromSelector(#selector(setter: ManipulatedObject.intValue)): ManipulatedObjectName,
            NSStringFromSelector(#selector(ManipulatedObject.parentInstanceMethod)): ImplSourceName,
            NSStringFromSelector(#selector(ManipulatedObject.childInstanceMethod)): ImplSourceName,
        ]
        
        let expectedClassMethodAccessRecords = [
            NSStringFromSelector(#selector(ManipulatedObject.parentClassMethod)): ImplSourceName,
            NSStringFromSelector(#selector(ManipulatedObject.childClassMethod)): ImplSourceName,
        ]
        
        _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords, with: expectedClassMethodAccessRecords)
        
        ObjCRemoveAllGraftedImplementations(from: object)
        
        let expectedInstanceMethodAccessRecords2 = [
            NSStringFromSelector(#selector(getter: ManipulatedObject.intValue)): ManipulatedObjectName,
            NSStringFromSelector(#selector(setter: ManipulatedObject.intValue)): ManipulatedObjectName,
            NSStringFromSelector(#selector(ManipulatedObject.parentInstanceMethod)): ManipulatedObjectName,
            NSStringFromSelector(#selector(ManipulatedObject.childInstanceMethod)): ManipulatedObjectName,
        ]
        
        let expectedClassMethodAccessRecords2 = [
            NSStringFromSelector(#selector(ManipulatedObject.parentClassMethod)): ManipulatedObjectName,
            NSStringFromSelector(#selector(ManipulatedObject.childClassMethod)): ManipulatedObjectName,
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
                of: SubAspect.self,
                on: ImplSource.self,
                to: object
            )
            
            let expectedInstanceMethodAccessRecords = [
                NSStringFromSelector(#selector(getter: ManipulatedObject.intValue)): ImplSourceName,
                NSStringFromSelector(#selector(setter: ManipulatedObject.intValue)): ManipulatedObjectName,
                NSStringFromSelector(#selector(ManipulatedObject.parentInstanceMethod)): ImplSourceName,
                NSStringFromSelector(#selector(ManipulatedObject.childInstanceMethod)): ImplSourceName,
            ]
            
            let expectedClassMethodAccessRecords = [
                NSStringFromSelector(#selector(ManipulatedObject.parentClassMethod)): ImplSourceName,
                NSStringFromSelector(#selector(ManipulatedObject.childClassMethod)): ImplSourceName,
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
                of: SubAspect.self,
                on: ImplSource.self,
                to: object
            )
            
            let expectedInstanceMethodAccessRecords = [
                NSStringFromSelector(#selector(getter: ManipulatedObject.intValue)): ImplSourceName,
                NSStringFromSelector(#selector(setter: ManipulatedObject.intValue)): ManipulatedObjectName,
                NSStringFromSelector(#selector(ManipulatedObject.parentInstanceMethod)): ImplSourceName,
                NSStringFromSelector(#selector(ManipulatedObject.childInstanceMethod)): ImplSourceName,
            ]
            
            let expectedClassMethodAccessRecords = [
                NSStringFromSelector(#selector(ManipulatedObject.parentClassMethod)): ImplSourceName,
                NSStringFromSelector(#selector(ManipulatedObject.childClassMethod)): ImplSourceName,
            ]
            
            _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords, with: expectedClassMethodAccessRecords)
            
            ObjCRemoveAllGraftedImplementations(from: object);
            
            let expectedInstanceMethodAccessRecords2 = [
                NSStringFromSelector(#selector(getter: ManipulatedObject.intValue)): ManipulatedObjectName,
                NSStringFromSelector(#selector(setter: ManipulatedObject.intValue)): ManipulatedObjectName,
                NSStringFromSelector(#selector(ManipulatedObject.parentInstanceMethod)): ManipulatedObjectName,
                NSStringFromSelector(#selector(ManipulatedObject.childInstanceMethod)): ManipulatedObjectName,
            ]
            
            let expectedClassMethodAccessRecords2 = [
                NSStringFromSelector(#selector(ManipulatedObject.parentClassMethod)): ManipulatedObjectName,
                NSStringFromSelector(#selector(ManipulatedObject.childClassMethod)): ManipulatedObjectName,
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
                of: SubAspect.self,
                on: ImplSource.self,
                to: object
            )
            
            let expectedInstanceMethodAccessRecords = [
                NSStringFromSelector(#selector(getter: ManipulatedObject.intValue)): ImplSourceName,
                NSStringFromSelector(#selector(setter: ManipulatedObject.intValue)): ManipulatedObjectName,
                NSStringFromSelector(#selector(ManipulatedObject.parentInstanceMethod)): ImplSourceName,
                NSStringFromSelector(#selector(ManipulatedObject.childInstanceMethod)): ImplSourceName,
            ]
            
            let expectedClassMethodAccessRecords = [
                NSStringFromSelector(#selector(ManipulatedObject.parentClassMethod)): ImplSourceName,
                NSStringFromSelector(#selector(ManipulatedObject.childClassMethod)): ImplSourceName,
            ]
            
            _assertObjectAccessRecord(bySettingIntValue: 0, with: expectedInstanceMethodAccessRecords, with: expectedClassMethodAccessRecords)
            
            ObjCRemoveAllGraftedImplementations(from: object);
            
            let expectedInstanceMethodAccessRecords2 = [
                NSStringFromSelector(#selector(getter: ManipulatedObject.intValue)): ManipulatedObjectName,
                NSStringFromSelector(#selector(setter: ManipulatedObject.intValue)): ManipulatedObjectName,
                NSStringFromSelector(#selector(ManipulatedObject.parentInstanceMethod)): ManipulatedObjectName,
                NSStringFromSelector(#selector(ManipulatedObject.childInstanceMethod)): ManipulatedObjectName,
            ]
            
            let expectedClassMethodAccessRecords2 = [
                NSStringFromSelector(#selector(ManipulatedObject.parentClassMethod)): ManipulatedObjectName,
                NSStringFromSelector(#selector(ManipulatedObject.childClassMethod)): ManipulatedObjectName,
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
                of: SubAspect.self,
                on: ImplSource.self,
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
        let Object = object_getClass(object) as! ManipulatedObject.Type

        _ = object.intValue
        object.intValue = intValue
        object.parentInstanceMethod()
        Object.parentClassMethod()
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

@objc class Observer: NSObject {
    @objc var intValues: [Int] = []
    
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

private let ManipulatedObjectName = ManipulatedObject.description()
private let ImplSourceName = ImplSource.description()
