//
//  _ObjCGraftCenter.h
//  ObjCGrafting
//
//  Created on 29/12/2018.
//

#ifndef _ObjCGraftCenter_h
#define _ObjCGraftCenter_h

#import <objc/runtime.h>
#import <pthread/pthread.h>

#include <memory>
#include <unordered_set>
#include <unordered_map>

#import "ObjCGraftCommon.h"
#import "_ObjCGraftCombination.h"
#import "_ObjCGraftInfo.h"
#import "_ObjCKeyValueObservationRecordList.h"
#import "_ObjCCompositedClassBackwardInstanceImpl.h"

namespace objcgrafting {
    typedef std::unordered_set<Protocol * __unsafe_unretained, _ObjCProtocolHasher> ObjCProtocolUnorderedSet;
    typedef std::unordered_map<Protocol * __unsafe_unretained, std::unique_ptr<_ObjCProtocolList>, _ObjCProtocolHasher> ObjCProtocolGraph;
    
    class _ObjCGraftCenter {
#pragma mark Accessing Shared Instance
    public:
        static _ObjCGraftCenter& shared();
        
#pragma mark Grafting Object
    public:
        id graftImplementationOfProtocolsFromClassesToObject(id object, Protocol * __unsafe_unretained *  protocols, __unsafe_unretained Class * source_classes, unsigned int count);
        id removeGraftedImplementationsOfProtocolsFromObject(id object, Protocol * __unsafe_unretained * protocols, unsigned int count);
        id removeGraftedImplementationsFromObject(id object);
    private:
        void _setupGraftingOnObject(id object, _ObjCProtocolList& grafted_protocol_list, _ObjCGraftRecordMap& graft_record_map);
        void _setObjectClassHierarchy(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class composited_class, _ObjCProtocolList& grafted_protocol_list, _ObjCGraftRecordMap& graft_record_map);
        void _setObjectClassHierarchyWhenTopmostClassIsGraftable(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class composited_class, _ObjCProtocolList& grafted_protocol_list, _ObjCGraftRecordMap& graft_record_map);
        void _setObjectClassHierarchyWhenTopmostClassIsNotGraftable(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class composited_class, _ObjCProtocolList& grafted_protocol_list, _ObjCGraftRecordMap& graft_record_map);
        void _setObjectClassHierarchyWithConsiderationOfKeyValueObservation(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class composited_class, _ObjCProtocolList& grafted_protocol_list, _ObjCGraftRecordMap& graft_record_map);
        void _setObjectClassHierarchyWithException(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class composited_class, _ObjCProtocolList& grafted_protocol_list, _ObjCGraftRecordMap& graft_record_map);
        void _setObjectGraftInfo(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class composited_class, _ObjCProtocolList& grafted_protocol_list, _ObjCGraftRecordMap& graft_record_map);
        
#pragma mark Accessing Object's Members
    public:
        bool objectHasGraftInfo(id object);
        _ObjCGraftInfo& objectGetGraftInfo(id object);
        IMP objectGetBackwardInstanceImpl(id object, _ObjCCompositedClassBackwardInstanceImplKind kind);
        _ObjCKeyValueObservationRecordList * objectGetKeyValueObservationRecords(id object);
    private:
        void _objectAddGraftInfo(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class composited_class, _ObjCProtocolList& grafted_protocol_list, _ObjCGraftRecordMap& graft_record_map);
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
        
#pragma mark Resolving Composited Class
    private:
        Class _resolveCompositedClass(id object, _ObjCProtocolList& grafted_protocol_list, _ObjCGraftRecordMap& graft_record_map);
        NSString * _graftedProtocolIdentifier(_ObjCProtocolList& grafted_protocol_list, _ObjCGraftRecordMap& graft_record_map);
        void _compositedClassAddSystematicProtocols(__unsafe_unretained Class cls);
        void _compositedClassAddUserDefinedProtocols(__unsafe_unretained Class cls, _ObjCProtocolList& grafted_protocol_list);
        void _compositedClassAddSystematicMethods(__unsafe_unretained Class cls);
        void _compositedClassAddUserDefinedMethods(__unsafe_unretained Class cls, _ObjCProtocolList& grafted_protocol_list, _ObjCGraftRecordMap& graft_record_map);
        std::unique_ptr<ObjCProtocolUnorderedSet> _resolveNetTopmostGraftedProtocols(_ObjCProtocolList& grafted_protocol_list, _ObjCGraftRecordMap& graft_record_map);
        std::unique_ptr<_ObjCGraftCombinationList> _resolveGraftCombinationList(_ObjCProtocolList& grafted_protocol_list, _ObjCGraftRecordMap& graft_record_map);
        
#pragma mark Accessing Composited Class Info
        void _compositedClassSetBackwardInstanceImpl(Class cls, IMP kind, _ObjCCompositedClassBackwardInstanceImplKind instance_impl);
        IMP _compositedClassGetBackwardInstanceImpl(Class cls, _ObjCCompositedClassBackwardInstanceImplKind kind);
        
#pragma mark Accessing Elements in Registered Protocol Graph
        ObjCProtocolGraph& _registeredProtocolGraph();
        bool _isProtocolRegistered(Protocol * __unsafe_unretained protocol);
        _ObjCProtocolList& _conformedProtocolsForRegisteredProtocol(Protocol * __unsafe_unretained protocol);
        void _registerConformedProtocolsForProtocol(Protocol * __unsafe_unretained protocol, _ObjCProtocolList& protocol_list);
        
#pragma mark Instance Variables
        pthread_mutex_t lock_;
        pthread_t lock_owner_;
        
        std::unique_ptr<ObjCProtocolGraph> registered_protocol_graph_;
        
        std::unique_ptr<_ObjCGraftInfoMap> graft_info_map_;
        std::unique_ptr<_ObjCKeyValueObservationRecordsMap> key_value_observation_records_map_;
        
#pragma mark Managing Life-Cycle
    protected:
        _ObjCGraftCenter() {
            registered_protocol_graph_ = std::make_unique<ObjCProtocolGraph>();
            graft_info_map_ =  std::make_unique<_ObjCGraftInfoMap>();
            key_value_observation_records_map_ = std::make_unique<_ObjCKeyValueObservationRecordsMap>();
            object_kvo_action_delegation_disabled_ = false;
            _initLock();
        }
        
        ~_ObjCGraftCenter() {
            _destroyLock();
        }
#pragma mark Operator Overloads
    public:
        _ObjCGraftCenter(_ObjCGraftCenter const&) = delete;             // Copy construct
        _ObjCGraftCenter(_ObjCGraftCenter&&) = delete;                  // Move construct
        _ObjCGraftCenter& operator=(_ObjCGraftCenter const&) = delete;  // Copy assign
        _ObjCGraftCenter& operator=(_ObjCGraftCenter &&) = delete;      // Move assign
    };
}

#endif /* _ObjCGraftCenter_h */
