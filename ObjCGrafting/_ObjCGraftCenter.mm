//
//  _ObjCGraftCenter.mm
//  ObjCGrafting
//
//  Created on 29/12/2018.
//


#import "_ObjCGraftCenter.h"

#import "_ObjCClass.h"
#import "_ObjCGraftingCompositedClass.h"
#import "_ObjCCompositedClass.h"
#import "_ObjCGraftingResolver.h"
#import "_ObjCKeyValueObservationRecord.h"
#import "_ObjCKeyValueObservationRecordList.h"

#import "NSObject+ObjCGrafting.h"
#import "NSObject+_KVOSpecialTreatment.h"
#import "NSArray+_KVOSpecialTreatment.h"

namespace objcgrafting {
#pragma mark Accessing Shared Instance
    _ObjCGraftCenter& _ObjCGraftCenter::shared() {
        static _ObjCGraftCenter shared_instance;
        return shared_instance;
    }
    
    std::unique_ptr<_ObjCGraftRequestVector> _ObjCGraftCenter::makeGraftRequests(Protocol * __unsafe_unretained * protocols, Class * source_classes, unsigned int count) {
        auto vector = std::make_unique<_ObjCGraftRequestVector>();
        
        for (unsigned int index = 0; index < count; index ++) {
            auto protocol = protocols[index];
            auto source_class = source_classes[index];
            
            if (class_conformsToProtocol(source_class, protocol)) {
                vector -> push_back({protocol, source_class});
            }
        }
        
        return vector;
    }
    
#pragma mark Grafting Object
    id _ObjCGraftCenter::graftImplementationOfProtocolsFromClassesToObject(id object, _ObjCGraftRequestVector& requests) {
        
        if (objectHasGraftInfo(object)) {
            auto& graft_info = objectGetGraftInfo(object);
            
            if (graft_info.push(requests)) {
                _setupGraftingOnObject(object, * graft_info.graft_record_map);
            }
        } else if (!requests.empty()) {
            auto graft_record_map = std::make_unique<_ObjCGraftRecordMap>();
            
            for (auto& pair: requests)  {
                auto protocol = pair.first;
                auto source_class = pair.second;
                graft_record_map -> insert({protocol, source_class});
            }
            
            _setupGraftingOnObject(object, * graft_record_map);
        }
        
        return object;
    }
    
    id _ObjCGraftCenter::removeGraftedImplementationsOfProtocolsFromObject(id object, Protocol * __unsafe_unretained * protocols, unsigned int count) {
        
        if (objectHasGraftInfo(object)) {
            auto& graft_info = objectGetGraftInfo(object);
            
            if (graft_info.pop(protocols, count)) {
                _setupGraftingOnObject(object, * graft_info.graft_record_map);
            }
        }
        
        return object;
    }
    
    id _ObjCGraftCenter::removeGraftedImplementationsFromObject(id object) {
        
        if (objectHasGraftInfo(object)) {
            auto& graft_info = objectGetGraftInfo(object);
            
            assert(!graft_info.graft_record_map -> empty());
            
            graft_info.graft_record_map -> clear();
            
            _setupGraftingOnObject(object, * graft_info.graft_record_map);
        }
        
        return object;
    }
    
    void _ObjCGraftCenter::_setupGraftingOnObject(id object, _ObjCGraftRecordMap& graft_record_map) {
        
        auto semantic_class = [object class];
        
        auto topmost_class = object_getClass(object);
        
        auto composited_class = resolveCompositedClass(object, graft_record_map);
        
        _setObjectClassHierarchy(object, semantic_class, topmost_class, composited_class, graft_record_map);
        
        _setObjectGraftInfo(object, semantic_class, composited_class, graft_record_map);
    }
    
    void _ObjCGraftCenter::_setObjectClassHierarchy(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class composited_class, _ObjCGraftRecordMap& graft_record_map) {
        
        auto is_topmost_class_graftable = topmost_class == semantic_class || class_conformsToProtocol(topmost_class, @protocol(_ObjCGraftingCompositedClass));
        
        if (is_topmost_class_graftable) {
            _setObjectClassHierarchyWhenTopmostClassIsGraftable(object, semantic_class, topmost_class, composited_class, graft_record_map);
        } else {
            _setObjectClassHierarchyWhenTopmostClassIsNotGraftable(object, semantic_class, topmost_class, composited_class, graft_record_map);
        }
    }
    
    void _ObjCGraftCenter::_setObjectClassHierarchyWhenTopmostClassIsGraftable(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class composited_class, _ObjCGraftRecordMap& graft_record_map) {
        if (graft_record_map.empty()) {
            object_setClass(object, semantic_class);
        } else {
            object_setClass(object, composited_class);
        }
    }
    
    void _ObjCGraftCenter::_setObjectClassHierarchyWhenTopmostClassIsNotGraftable(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class composited_class, _ObjCGraftRecordMap& graft_record_map) {
        
        auto topmost_class_name_raw = class_getName(topmost_class);
        
        auto topmost_class_name = [NSString stringWithUTF8String:topmost_class_name_raw];
        
        auto kvo_notifying_class_prefix = [NSString stringWithFormat:@"NSKVONotifying_"];
        
        if ([topmost_class_name hasPrefix:kvo_notifying_class_prefix]) {
            _setObjectClassHierarchyWithConsiderationOfKeyValueObservation(object, semantic_class, topmost_class, composited_class, graft_record_map);
        } else {
            _setObjectClassHierarchyWithException(object, semantic_class, topmost_class, composited_class, graft_record_map);
        }
    }
    
    void _ObjCGraftCenter::_setObjectClassHierarchyWithConsiderationOfKeyValueObservation(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class composited_class, _ObjCGraftRecordMap& graft_record_map) {
        
        auto kvo_notifying_class = topmost_class;
        
        // Return the implementation of -class method if needed
        if (objectHasGraftInfo(object)) {
            auto old_composited_class = objectGetGraftInfo(object).composited_class;
            auto kvo_notifying_class_class_impl = _ObjCCompositedClass::getBackwardInstanceImpl(old_composited_class, _ObjCCompositedClass::BackwardInstanceImplKind::KVOClassGetter);
            if (kvo_notifying_class_class_impl != nullptr) {
                _ObjCClass::replaceInstanceMethod(kvo_notifying_class, @selector(class), kvo_notifying_class_class_impl);
            }
        }
        
        assert(kvo_notifying_class != semantic_class);
        
        auto key_value_observation_records = objectGetKeyValueObservationRecords(object);
        
        setObjectKVOActionDelegationDisabled(true);
        
        // Remove all observers
        [key_value_observation_records enumerateRecordWithBlock:^(id observer, NSString *keyPath, NSKeyValueObservingOptions options, void *context) {
         (* _kNSObjectRemoveObserverForKeyPathContext)(object, @selector(removeObserver:forKeyPath:context:), observer, keyPath, context);
         }];
        
        assert(object_getClass(object) != kvo_notifying_class);
        
        if (composited_class != nullptr) {
            assert(!graft_record_map.empty());
            object_setClass(object, composited_class);
        } else {
            assert(graft_record_map.empty());
            object_setClass(object, semantic_class);
        }
        
        // Add all observers
        [key_value_observation_records enumerateRecordWithBlock:^(id observer, NSString *keyPath, NSKeyValueObservingOptions options, void *context) {
         auto filteredOptions = options & ~NSKeyValueObservingOptionInitial;
         (* _kNSObjectAddObserverForKeyPathOptionsContext)(object, @selector(addObserver:forKeyPath:options:context:), observer, keyPath, filteredOptions, context);
         }];
        
        setObjectKVOActionDelegationDisabled(false);
        
        // Replace the implementation of -class method if needed
        auto refreshed_topmost_class = object_getClass(object);
        
        if (composited_class != nullptr) {
            auto new_kvo_notifying_class_class_impl = class_getMethodImplementation(refreshed_topmost_class, @selector(class));
            if (new_kvo_notifying_class_class_impl != (IMP)&_NSObjectGetClass) {
                _ObjCCompositedClass::setBackwardInstanceImpl(composited_class, new_kvo_notifying_class_class_impl, _ObjCCompositedClass::BackwardInstanceImplKind::KVOClassGetter);
                _ObjCClass::replaceInstanceMethod(refreshed_topmost_class, @selector(class), &_NSObjectGetClass);
            }
        }
    }
    
    void _ObjCGraftCenter::_setObjectClassHierarchyWithException(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class composited_class, _ObjCGraftRecordMap& graft_record_map) {
        [NSException raise:NSInternalInconsistencyException format:@"Unkown is-a swizzle technique was found on object %@. Semantic Class = %@; Topmost Class = %@, Composited Class = %@.", [object description], NSStringFromClass(semantic_class), NSStringFromClass(topmost_class), NSStringFromClass(composited_class)];
    }
    
    void _ObjCGraftCenter::_setObjectGraftInfo(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class composited_class, _ObjCGraftRecordMap& graft_record_map) {
        
        if (objectHasGraftInfo(object)) {
            if (graft_record_map.empty()) {
                assert(object_getClass(object) == semantic_class || class_getSuperclass(object_getClass(object)) == semantic_class);
                _objectRemoveGraftInfo(object);
            } else {
                auto& graft_info = objectGetGraftInfo(object);
                assert(graft_info.semantic_class == semantic_class);
                graft_info.composited_class = composited_class;
            }
        } else {
            if (!graft_record_map.empty()) {
                _objectAddGraftInfo(object, semantic_class, composited_class, graft_record_map);
            }
        }
    }
    
#pragma mark Accessing Object's Members
    bool _ObjCGraftCenter::objectHasGraftInfo(id object) {
        return graft_info_map_ -> find(object) != graft_info_map_ -> cend();
    }
    
    _ObjCGraftInfo& _ObjCGraftCenter::objectGetGraftInfo(id object) {
        return * (* graft_info_map_)[object];
    }
    
    IMP _ObjCGraftCenter::objectGetBackwardInstanceImpl(id object, _ObjCCompositedClass::BackwardInstanceImplKind kind) {
        if (objectHasGraftInfo(object)) {
            auto& graft_info = objectGetGraftInfo(object);
            auto composited_class = graft_info.composited_class;
            IMP backward_instance_impl = _ObjCCompositedClass::getBackwardInstanceImpl(composited_class, kind);
            return backward_instance_impl;
        }
        return nil;
    }
    
    _ObjCKeyValueObservationRecordList * _ObjCGraftCenter::objectGetKeyValueObservationRecords(id object) {
        auto existed_record_list_positoin = key_value_observation_records_map_ -> find(object);
        
        if (existed_record_list_positoin != key_value_observation_records_map_ -> cend()) {
            return (* existed_record_list_positoin).second;
        } else {
            auto list = [[_ObjCKeyValueObservationRecordList alloc] initWithTarget:object];
            (* key_value_observation_records_map_)[object] = list;
            return list;
        }
    }
    
    void _ObjCGraftCenter::_objectAddGraftInfo(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class composited_class, _ObjCGraftRecordMap& graft_record_map) {
        graft_info_map_ -> emplace(object, std::make_unique<_ObjCGraftInfo>(semantic_class, composited_class, graft_record_map));
    }
    
    void _ObjCGraftCenter::_objectRemoveGraftInfo(__unsafe_unretained id object) {
        graft_info_map_ -> erase(object);
    }
    
    void _ObjCGraftCenter::_objectRemoveKeyValueObservationRecords(__unsafe_unretained id object) {
        key_value_observation_records_map_ -> erase(object);
    }
    
#pragma mark Delegating Object
    void _ObjCGraftCenter::objectWillDealloc(__unsafe_unretained id object) {
        _objectRemoveGraftInfo(object);
        _objectRemoveKeyValueObservationRecords(object);
    }
    
#pragma mark Delegating Object's KVO Actions
    void _ObjCGraftCenter::objectWillAddKeyValueObserver(id object, id observer, NSString * key_path, NSKeyValueObservingOptions options, void * context) {
        [objectGetKeyValueObservationRecords(object) addRecordWithObserver:observer keyPath:key_path options:options context:context];
        
    }
    
    void _ObjCGraftCenter::objectDidAddKeyValueObserver(id object, id observer, NSString * key_path, NSKeyValueObservingOptions options, void * context) {
        
        if (objectHasGraftInfo(object)) {
            _setObjectInstanceMethodClassImplForAddingObserver(object);
        }
    }
    
    void _ObjCGraftCenter::objectWillRemoveKeyValueObserver(id object, id observer, NSString * key_path, void * context) {
        [objectGetKeyValueObservationRecords(object) removeRecordWithObserver:observer keyPath:key_path context:context];
        
        if ([objectGetKeyValueObservationRecords(object) isEmpty]) {
            _setObjectInstanceMethodClassImplForRemovingObserver(object);
        }
        
    }
    
    void _ObjCGraftCenter::objectWillRemoveKeyValueObserver(id object, id observer, NSString * key_path) {
        [objectGetKeyValueObservationRecords(object) removeRecordsWithObserver:observer keyPath:key_path];
        
        if ([objectGetKeyValueObservationRecords(object) isEmpty]) {
            _setObjectInstanceMethodClassImplForRemovingObserver(object);
        }
    }
    
    void _ObjCGraftCenter::objectDidRemoveKeyValueObserver(id object, id observer, NSString * key_path, void * context) {
        
    }
    
    void _ObjCGraftCenter::objectDidRemoveKeyValueObserver(id object, id observer, NSString * key_path) {
        
    }
    
    void _ObjCGraftCenter::_setObjectInstanceMethodClassImplForAddingObserver(id object) {
        if (objectHasGraftInfo(object)) {
            auto& graft_info = objectGetGraftInfo(object);
            auto composited_class = graft_info.composited_class;
            auto kvo_notifying_class = object_getClass(object);
            auto current_class_impl = class_getMethodImplementation(kvo_notifying_class, @selector(class));
            if (current_class_impl != (IMP)&_NSObjectGetClass) {
                _ObjCCompositedClass::setBackwardInstanceImpl(composited_class, current_class_impl, _ObjCCompositedClass::BackwardInstanceImplKind::KVOClassGetter);
                _ObjCClass::replaceInstanceMethod(kvo_notifying_class, @selector(class), &_NSObjectGetClass);
            }
        }
    }
    
    void _ObjCGraftCenter::_setObjectInstanceMethodClassImplForRemovingObserver(id object) {
        if (objectHasGraftInfo(object)) {
            auto kvo_notifying_class = object_getClass(object);
            auto composited_class = objectGetGraftInfo(object).composited_class;
            auto backward_class_impl = _ObjCCompositedClass::getBackwardInstanceImpl(composited_class, _ObjCCompositedClass::BackwardInstanceImplKind::KVOClassGetter);
            if (backward_class_impl != nullptr) {
                _ObjCClass::replaceInstanceMethod(kvo_notifying_class, @selector(class), backward_class_impl);
            }
        }
    }
    
#pragma mark Managing Object's KVO Action Delegation
    bool _ObjCGraftCenter::isObjectKVOActionDelegationDisabled() {
        return object_kvo_action_delegation_disabled_;
    }
    
    void _ObjCGraftCenter::setObjectKVOActionDelegationDisabled(bool flag) {
        object_kvo_action_delegation_disabled_ = flag;
    }
    
#pragma mark Resolving Composited Class
    Class _ObjCGraftCenter::resolveCompositedClass(id object, _ObjCGraftRecordMap& graft_record_map) {
        if (graft_record_map.empty()) {
            return nil;
        }
        
        auto semantic_class = [object class];
        
        auto grafted_components_id = _ObjCGraftingResolver::shared().graftedProtocolIdentifier(graft_record_map);
        
        auto class_name = [NSString stringWithFormat:@"_ObjCGrafted_%@_%@", NSStringFromClass(semantic_class), grafted_components_id];
        
        auto raw_class_name = class_name.UTF8String;
        
        auto cls = objc_getClass(raw_class_name);
        
        if (cls == nullptr) {
            cls = _ObjCCompositedClass::make(semantic_class, raw_class_name, graft_record_map);
            
            assert(cls != nullptr);
        }
        
        return cls;
    }
    
#pragma mark Managing Lock
    void _ObjCGraftCenter::lock() {
        auto lock_signal = pthread_mutex_lock(&lock_);
        if (lock_signal == EINVAL) {
            [NSException raise:NSInternalInconsistencyException format:@"Invalid mutex."];
        }
        if (lock_signal == EDEADLK) {
            [NSException raise:NSInternalInconsistencyException format:@"Deadlocked."];
        }
        lock_owner_ = pthread_self();
    }
    
    void _ObjCGraftCenter::unlock() {
        lock_owner_ = NULL;
        auto unlock_signal = pthread_mutex_unlock(&lock_);
        if (unlock_signal == EINVAL) {
            [NSException raise:NSInternalInconsistencyException format:@"Invalid mutex."];
        }
        if (unlock_signal == EPERM) {
            [NSException raise:NSInternalInconsistencyException format:@"Current thread doesn't hold a lock on mutex."];
        }
    }
    
    void _ObjCGraftCenter::_initLock() {
        pthread_mutexattr_t mutexattr_type;
        
        auto signal = pthread_mutexattr_init(&mutexattr_type);
        if (signal == ENOMEM) {
            [NSException raise:NSInternalInconsistencyException format:@"Not enough memory for initializing mutex attribute."];
        }
        signal = pthread_mutexattr_settype(&mutexattr_type, PTHREAD_MUTEX_RECURSIVE);
        if (signal == EINVAL) {
            [NSException raise:NSInternalInconsistencyException format:@"Invalid mutex type."];
        }
        
        signal = pthread_mutex_init(&lock_, &mutexattr_type);
        if (signal == ENOMEM) {
            [NSException raise:NSInternalInconsistencyException format:@"The process cannot allocate enough memory to create another mutex."];
        }
        if (signal == EINVAL) {
            [NSException raise:NSInternalInconsistencyException format:@"Invalid mutex attribute."];
        }
        
        signal = pthread_mutexattr_destroy(&mutexattr_type);
        if (signal == EINVAL) {
            [NSException raise:NSInternalInconsistencyException format:@"Invalid mutex attribute."];
        }
    }
    
    void _ObjCGraftCenter::_destroyLock() {
        auto signal = pthread_mutex_destroy(&lock_);
        if (signal == EINVAL) {
            [NSException raise:NSInternalInconsistencyException format:@"Invalid mutex."];
        }
        if (signal == EBUSY) {
            [NSException raise:NSInternalInconsistencyException format:@"Mutex is locked by another thread."];
        }
    }
}
