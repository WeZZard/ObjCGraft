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

#import "ObjCGraftCommon.h"
#import "_ObjCGraftCombination.h"
#import "_ObjCGraftInfo.h"
#import "_ObjCCompositedClass.h"
#import "_ObjCKeyValueObservationRecordList.h"

namespace objcgrafting {
    class _ObjCGraftCenter {
#pragma mark Accessing Shared Instance
    public:
        static _ObjCGraftCenter& shared();
        
#pragma mark Managing Object's Implementation Grafting
    public:
        std::unique_ptr<_ObjCGraftRequestVector> makeGraftRequests(Protocol * __unsafe_unretained * protocols, Class * source_classes, unsigned int count);
        id graftImplementationOfProtocolsFromClassesToObject(id object, _ObjCGraftRequestVector& requests);
        id removeGraftedImplementationsOfProtocolsFromObject(id object, Protocol * __unsafe_unretained * protocols, unsigned int count);
        id removeGraftedImplementationsFromObject(id object);
    private:
        void _setupGraftingOnObject(id object, _ObjCGraftRecordMap& graft_record_map);
        void _setObjectClassHierarchy(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class composited_class, _ObjCGraftRecordMap& graft_record_map);
        void _setObjectClassHierarchyWhenTopmostClassIsGraftable(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class composited_class, _ObjCGraftRecordMap& graft_record_map);
        void _setObjectClassHierarchyWhenTopmostClassIsNotGraftable(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class composited_class, _ObjCGraftRecordMap& graft_record_map);
        void _setObjectClassHierarchyWithConsiderationOfKeyValueObservation(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class composited_class, _ObjCGraftRecordMap& graft_record_map);
        void _setObjectClassHierarchyWithException(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class composited_class, _ObjCGraftRecordMap& graft_record_map);
        void _setObjectGraftInfo(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class composited_class, _ObjCGraftRecordMap& graft_record_map);
        
#pragma mark Accessing Object's Members
    public:
        bool objectHasGraftInfo(id object);
        _ObjCGraftInfo& objectGetGraftInfo(id object);
        IMP objectGetBackwardInstanceImpl(id object, _ObjCCompositedClass::BackwardInstanceImplKind kind);
        _ObjCKeyValueObservationRecordList * objectGetKeyValueObservationRecords(id object);
    private:
        void _objectAddGraftInfo(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class composited_class, _ObjCGraftRecordMap& graft_record_map);
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
        
#pragma mark Resolving Composited Class
        Class resolveCompositedClass(id object, _ObjCGraftRecordMap& graft_record_map);
        
#pragma mark Managing Lock
    public:
        void lock();
        void unlock();
    private:
        void _initLock();
        void _destroyLock();
        
#pragma mark Instance Variables
        pthread_mutex_t lock_;
        pthread_t lock_owner_;
        
        std::unique_ptr<_ObjCGraftInfoMap> graft_info_map_;
        std::unique_ptr<_ObjCKeyValueObservationRecordsMap> key_value_observation_records_map_;
        
#pragma mark Managing Life-Cycle
    protected:
        _ObjCGraftCenter() {
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
