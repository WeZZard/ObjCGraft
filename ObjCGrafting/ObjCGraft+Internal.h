//
//  ObjCGraft+Internal.h
//  ObjCGrafting
//
//  Created by WeZZard on 27/03/2017.
//
//

#ifndef ObjCGraft_Internal_h
#define ObjCGraft_Internal_h

#import <objc/objc.h>
#import <objc/message.h>
#import <objc/runtime.h>

#import <Foundation/Foundation.h>
#import <ObjCGrafting/ObjCGraft.h>
#import "ObjCGraftedObjectBackwardInstanceImpl.h"

#include <memory>
#include <map>
#include <unordered_map>
#include <unordered_set>
#include <vector>
#include <list>

/// Objective-C Graft
/// =================
/// Objective-C Graft is a set of tool to graft implementation of a protocol on
/// a class to a specific object.
///
/// Principles
/// ==========
/// The key of Objective-C Graft is a technology called is-a swizzle, which
/// achieved by function: `object_setClass`.
///
/// Possible Class Hierarchy for Input Object
/// =========================================
///
/// 1. First one is an object didn't adopt any is-a swizzle technologies.
/// ```
/// Root Class:                 NSObject
///                                ^
///                                |
///                               ...
///                                ^
///                                |
/// Topmost/Semantic Class:       Foo
/// ```
///
/// 2. Second one is an object adopted considered is-a swizzle technologies(
/// Currently KVO only).
/// ```
/// Root Class:                 NSObject
///                                ^
///                                |
///                               ...
///                                ^
///                                |
/// Semantic Class:               Foo
///                                ^
///                                |
/// Topmost Class:         NSKVONotifying_Foo
/// ```
///
/// 3. Third one is the output produced with first input.
/// ```
/// Root Class:                 NSObject
///                                ^
///                                |
///                               ...
///                                ^
///                                |
/// Semantic Class:               Foo
///                                ^
///                                |
/// Topmost/Graft Class:  _OjbCGrafted_Foo_Protocol->SourceClass
///
/// 4. Fourth one is the output produced with second input.
/// ```
/// Root Class:                 NSObject
///                                ^
///                                |
///                               ...
///                                ^
///                                |
/// Semantic Class:               Foo
///                                ^
///                                |
/// Graft Class:  _OjbCGrafted_Foo_Protocol->SourceClass
///                                ^
///                                |
/// Topmost Class:         NSKVONotifying_Foo
/// ```
///
/// Possible Class Hierarchy for Grafted Object
/// ===========================================
///
/// 1. Respect to the first case of input object.
/// ```
/// Root Class:                 NSObject
///                                ^
///                                |
///                               ...
///                                ^
///                                |
/// Semantic Class:               Foo
///                                ^
///                                |
/// Topmost/Graft Class:  _OjbCGrafted_Foo_Protocol->SourceClass
/// ```
///
/// 2. Respect to the second case of input object.
/// ```
/// Root Class:                 NSObject
///                                ^
///                                |
///                               ...
///                                ^
///                                |
/// Semantic Class:               Foo
///                                ^
///                                |
/// Graft Class:  _OjbCGrafted_Foo_Protocol->SourceClass
///                                ^
///                                |
/// Topmost Class:          NSKVONotifying_Foo
/// ```

@class _ObjCKeyValueObservationRecordList;

namespace objcgrafting {
#pragma mark - Opaque Types
    struct ObjCGraftCombination;
    struct ObjCGraftInfo;
    struct ProtocolUnsafeUnretainedPointerHashFunc;
    struct IdUnsafeUnretainedHashFunc;

#pragma mark - Typedefs
    typedef std::map<Protocol * __unsafe_unretained , __unsafe_unretained Class> ObjCGraftMap;
    typedef std::unordered_map<id __unsafe_unretained , std::unique_ptr<ObjCGraftInfo>, IdUnsafeUnretainedHashFunc> ObjCGraftInfoMap;
    typedef std::unordered_map<id __unsafe_unretained , _ObjCKeyValueObservationRecordList *, IdUnsafeUnretainedHashFunc> ObjCKeyValueObservationRecordsMap;
    typedef std::list<Protocol * __unsafe_unretained> ObjCProtocolList;
    typedef std::unordered_set<Protocol * __unsafe_unretained, ProtocolUnsafeUnretainedPointerHashFunc> ObjCProtocolUnorderedSet;
    typedef std::unordered_map<Protocol * __unsafe_unretained, std::unique_ptr<ObjCProtocolList>, ProtocolUnsafeUnretainedPointerHashFunc> ObjCProtocolGraph;
    typedef std::vector<ObjCGraftCombination> ObjCGraftCombinationList;
    
#pragma mark - objcgrafting::ObjCGraftCenter
    class ObjCGraftCenter {
#pragma mark Accessing Shared Instance
    public:
        static ObjCGraftCenter& shared();
        
#pragma mark Grafting Object
    public:
        id graftObject(id object, Protocol * __unsafe_unretained *  protocols, __unsafe_unretained Class * source_classes, unsigned int count);
        id ungraftObject(id object, Protocol * __unsafe_unretained * protocols, unsigned int count);
        id ungraftObject(id object);
    private:
        void _graftObject(id object, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map);
        void _setObjectClassHierarchy(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class graft_class, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map);
        void _setObjectClassHierarchyWhenTopmostClassIsGraftable(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class graft_class, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map);
        void _setObjectClassHierarchyWhenTopmostClassIsNotGraftable(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class graft_class, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map);
        void _setObjectClassHierarchyWithConsiderationOfKeyValueObservation(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class graft_class, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map);
        void _setObjectClassHierarchyWithException(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class graft_class, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map);
        void _setObjectGraftInfo(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class graft_class, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map);
        
#pragma mark Accessing Object's Members
    public:
        bool objectHasGraftInfo(id object);
        ObjCGraftInfo& objectGetGraftInfo(id object);
        IMP objectGetBackwardInstanceImpl(id object, ObjCGraftedObjectBackwardInstanceImplKind kind);
        _ObjCKeyValueObservationRecordList * objectGetKeyValueObservationRecords(id object);
    private:
        void _objectAddGraftInfo(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class graft_class, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map);
        void _objectRemoveGraftInfo(__unsafe_unretained id object);
        void _objectRemoveKeyValueObservationRecords(__unsafe_unretained id object);
        
#pragma mark Delegating Object
    public:
        void objectWillDealloc(__unsafe_unretained id object);
    private:
        
#pragma mark Delegating Object's KVO Actions
    public:
        void objectWillAddKeyValueObserver(id object, id observer, NSString * key_path, NSKeyValueObservingOptions options, void * context);
        void objectDidAddKeyValueObserver(id object, id observer, NSString * key_path, NSKeyValueObservingOptions options, void * context);
        void objectWillRemoveKeyValueObserver(id object, id observer, NSString * key_path, void * context);
        void objectWillRemoveKeyValueObserver(id object, id observer, NSString * key_path);
        void objectDidRemoveKeyValueObserver(id object, id observer, NSString * key_path, void * context);
        void objectDidRemoveKeyValueObserver(id object, id observer, NSString * key_path);
    private:
        void _setObjectInstanceMethodClassImplForAddingObserver(id object);
        void _setObjectInstanceMethodClassImplForRemovingObserver(id object);
        
#pragma mark Managing Object's KVO Action Delegation
    public:
        bool isObjectKVOActionDelegationDisabled();
        void setObjectKVOActionDelegationDisabled(bool flag);
    private:
        bool object_kvo_action_delegation_disabled_;
        
#pragma mark Managing Lock
    public:
        void lock();
        void unlock();
    private:
        void _initLock();
        void _destroyLock();
        
#pragma mark Resolving Graft Class
    private:
        Class _resolveGraftClass(id object, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map);
        NSString * _graftedProtocolIdentifier(ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map);
        void _graftClassAddSystematicProtocols(__unsafe_unretained Class cls);
        void _graftClassAddUserDefinedProtocols(__unsafe_unretained Class cls, ObjCProtocolList& grafted_protocol_list);
        void _graftClassAddSystematicMethods(__unsafe_unretained Class cls);
        void _graftClassAddUserDefinedMethods(__unsafe_unretained Class cls, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map);
        std::unique_ptr<ObjCProtocolUnorderedSet> _resolveNetTopmostGraftedProtocols(ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map);
        std::unique_ptr<ObjCGraftCombinationList> _resolveGraftCombinationList(ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map);
        
#pragma mark Accessing Graft Class Info
        void _graftClassSetBackwardInstanceImpl(Class cls, IMP kind, ObjCGraftedObjectBackwardInstanceImplKind instance_impl);
        IMP _graftClassGetBackwardInstanceImpl(Class cls, ObjCGraftedObjectBackwardInstanceImplKind kind);
        
#pragma mark Accessing Elements in Registered Protocol Graph
        ObjCProtocolGraph& _registeredProtocolGraph();
        bool _isProtocolRegistered(Protocol * __unsafe_unretained protocol);
        ObjCProtocolList& _conformedProtocolsForRegisteredProtocol(Protocol * __unsafe_unretained protocol);
        void _registerConformedProtocolsForProtocol(Protocol * __unsafe_unretained protocol, ObjCProtocolList& protocol_list);
        
#pragma mark Instance Variables
        pthread_mutex_t lock_;
        pthread_t lock_owner_;
        
        std::unique_ptr<ObjCProtocolGraph> registered_protocol_graph_;
        
        std::unique_ptr<ObjCGraftInfoMap> graft_info_map_;
        std::unique_ptr<ObjCKeyValueObservationRecordsMap> key_value_observation_records_map_;
        
#pragma mark Managing Life-Cycle
    protected:
        ObjCGraftCenter() {
            registered_protocol_graph_ = std::make_unique<ObjCProtocolGraph>();
            graft_info_map_ =  std::make_unique<ObjCGraftInfoMap>();
            key_value_observation_records_map_ = std::make_unique<ObjCKeyValueObservationRecordsMap>();
            object_kvo_action_delegation_disabled_ = false;
            _initLock();
        }
        
        ~ObjCGraftCenter() {
            _destroyLock();
        }
#pragma mark Operator Overloads
    public:
        ObjCGraftCenter(ObjCGraftCenter const&) = delete;             // Copy construct
        ObjCGraftCenter(ObjCGraftCenter&&) = delete;                  // Move construct
        ObjCGraftCenter& operator=(ObjCGraftCenter const&) = delete;  // Copy assign
        ObjCGraftCenter& operator=(ObjCGraftCenter &&) = delete;      // Move assign
    };
    
    
    class Cls {
    public:
        template <typename T>
        static T * replaceInstanceMethod(Class cls, SEL selector, T * impl) {
            auto method = class_getInstanceMethod(cls, selector);
            return (T *)class_replaceMethod(cls, selector, (IMP)impl, method_getTypeEncoding(method));
        }
    };
}

#endif /* ObjCGraft_Internal_h */
