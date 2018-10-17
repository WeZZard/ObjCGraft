//
//  ObjCGraft.m
//  ObjCGrafting
//
//  Created by WeZZard on 27/03/2017.
//
//

#import <pthread/pthread.h>

#import "ObjCGraft.h"
#import "ObjCGraft+Internal.h"

#pragma mark - Typedefs
typedef void NSObjectAddObserverForKeyPathOptionsContext (NSObject *, SEL, NSObject *, NSString *, NSKeyValueObservingOptions, void *);
typedef void NSObjectRemoveObserverForKeyPath (NSObject *, SEL, NSObject *, NSString *);
typedef void NSObjectRemoveObserverForKeyPathContext (NSObject *, SEL, NSObject *, NSString *, void *);

typedef void NSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext (NSArray *, SEL, NSObject *, NSIndexSet *, NSString *, NSKeyValueObservingOptions, void *);
typedef void NSArrayRemoveObserverFromObjectsAtIndicesForKeyPath (NSArray *, SEL, NSObject *, NSIndexSet *, NSString *);
typedef void NSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext (NSArray *, SEL, NSObject *, NSIndexSet *, NSString *, void *);

typedef Class NSObjectClass (NSObject *, SEL);

typedef void NSObjectDealloc (NSObject * __unsafe_unretained, SEL);

namespace objcgrafting {
    struct ObjCKeyValueObservationRecord;
    struct ObjCKeyValueObservationRecords;
}

/// Identifies the class is a graft class
///
/// All the graft class shall conform to this protocol.
@protocol _ObjCGrafted<NSObject>
@end

@interface _ObjCKeyValueObservationRecord: NSObject {
    std::unique_ptr<std::unordered_set<void *>> _contexts;
    NSUInteger _hash;
}
@property (nonatomic, readonly, unsafe_unretained) id observer;
@property (nonatomic, readonly, copy) NSString * keyPath;
@property (nonatomic, assign) NSKeyValueObservingOptions options;
- (void)addContext:(void *)context;
- (BOOL)removeContext:(void *)context;
- (void)enumerateContextsUsingBlock:(void (^)(void * context))block;
- (BOOL)needsRemove;
- (instancetype)initWithObserver:(id)observer keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options;
@end

@interface _ObjCKeyValueObservationRecordList: NSObject {
    __unsafe_unretained id _target;
    NSMutableSet<_ObjCKeyValueObservationRecord *> * _records;
}
- (instancetype)initWithTarget:(id)target;
- (void)addRecordWithObserver:(id)observer keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)removeRecordsWithObserver:(id)observer keyPath:(NSString *)keyPath;
- (void)removeRecordWithObserver:(id)observer keyPath:(NSString *)keyPath context:(void *)context;
- (void)enumerateRecordWithBlock:(void (^)(id observer, NSString * keyPath, NSKeyValueObservingOptions options, void * context))block;
- (BOOL)isEmpty;
@end

#pragma mark - C Function Prototypes
static NSObjectAddObserverForKeyPathOptionsContext _NSObjectAddObserverForKeyPathOptionsContext;
static NSObjectRemoveObserverForKeyPath _NSObjectRemoveObserverForKeyPath;
static NSObjectRemoveObserverForKeyPathContext _NSObjectRemoveObserverForKeyPathContext;
static NSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext _NSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext;
static NSArrayRemoveObserverFromObjectsAtIndicesForKeyPath _NSArrayRemoveObserverFromObjectsAtIndicesForKeyPath;
static NSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext _NSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext;

static NSObjectClass _NSObjectClass;
static NSObjectDealloc _NSObjectDealloc;
static inline NSObjectDealloc _NSObjectSuperDealloc;

#pragma mark - Constants
static NSObjectAddObserverForKeyPathOptionsContext * _kNSObjectAddObserverForKeyPathOptionsContext;
static NSObjectRemoveObserverForKeyPath * _kNSObjectRemoveObserverForKeyPath;
static NSObjectRemoveObserverForKeyPathContext * _kNSObjectRemoveObserverForKeyPathContext;
static NSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext * _kNSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext;
static NSArrayRemoveObserverFromObjectsAtIndicesForKeyPath * _kNSArrayRemoveObserverFromObjectsAtIndicesForKeyPath;
static NSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext * _kNSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext;

#pragma mark - C Binding Functions Implementations
id object_graftProtocol(id object, Protocol * protocol, Class sourceClass) {
    Protocol * __unsafe_unretained unsafe_unretained_protocol = protocol;
    objcgrafting::ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::ObjCGraftCenter::shared().graftObject(object, &unsafe_unretained_protocol, &sourceClass, 1);
    objcgrafting::ObjCGraftCenter::shared().unlock();
    return retVal;
}

id object_graftProtocols(id object, Protocol * _Nonnull *  _Nonnull protocols, __unsafe_unretained Class _Nonnull * _Nonnull sourceClasses, unsigned int count) {
    Protocol * __unsafe_unretained unsafe_unretained_first_protocol = * protocols;
    Protocol * __unsafe_unretained * unsafe_unretained_protocols = &unsafe_unretained_first_protocol;
    objcgrafting::ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::ObjCGraftCenter::shared().graftObject(object, unsafe_unretained_protocols, sourceClasses, count);
    objcgrafting::ObjCGraftCenter::shared().unlock();
    return retVal;
}

id object_graftProtocolsWithNilTermination(id object, Protocol * firstProtocol, Class firstSourceClass, ...) {
    Protocol * each_protocol;
    Class each_source_class;
    
    va_list arg_list;
    
    auto protocols = std::make_unique<std::vector<Protocol * __unsafe_unretained>>();
    protocols -> push_back(firstProtocol);
    auto source_classes = std::make_unique<std::vector<__unsafe_unretained Class>>();
    source_classes -> push_back(firstSourceClass);
    
    unsigned int count = 1;
    
    va_start(arg_list, firstSourceClass);
    while ((each_protocol = va_arg(arg_list, Protocol *)) && (each_source_class = va_arg(arg_list, Class))) {
        protocols -> push_back(each_protocol);
        source_classes -> push_back(each_source_class);
        
        count += 1;
    }
    va_end(arg_list);
    
    auto protocol_array = &(* protocols)[0];
    auto source_classes_array = &(* source_classes)[0];
    
    objcgrafting::ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::ObjCGraftCenter::shared().graftObject(object, protocol_array, source_classes_array, count);
    objcgrafting::ObjCGraftCenter::shared().unlock();
    return retVal;
}

id object_ungraftProtocol(id object, Protocol * protocol) {
    Protocol * __unsafe_unretained unsafe_unretained_protocol = protocol;
    objcgrafting::ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::ObjCGraftCenter::shared().ungraftObject(object, &unsafe_unretained_protocol, 1);
    objcgrafting::ObjCGraftCenter::shared().unlock();
    return retVal;
}

id object_ungraftProtocols(id object, Protocol * _Nonnull *  _Nonnull protocols, unsigned int count) {
    Protocol * __unsafe_unretained unsafe_unretained_first_protocol = * protocols;
    Protocol * __unsafe_unretained * unsafe_unretained_protocols = &unsafe_unretained_first_protocol;
    objcgrafting::ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::ObjCGraftCenter::shared().ungraftObject(object, unsafe_unretained_protocols, count);
    objcgrafting::ObjCGraftCenter::shared().unlock();
    return retVal;
}

id object_ungraftProtocolsWithNilTermination(id object, Protocol * firstProtocol, ...) {
    
    Protocol * each_protocol;
    
    va_list arg_list;
    
    auto protocols = std::make_unique<std::vector<Protocol * __unsafe_unretained>>();
    protocols -> push_back(firstProtocol);
    
    unsigned int count = 1;
    
    va_start(arg_list, firstProtocol);
    while ((each_protocol = va_arg(arg_list, Protocol *))) {
        protocols -> push_back(each_protocol);
        
        count += 1;
    }
    va_end(arg_list);
    
    auto protocol_array = &(* protocols)[0];
    
    objcgrafting::ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::ObjCGraftCenter::shared().ungraftObject(object, protocol_array, count);
    objcgrafting::ObjCGraftCenter::shared().unlock();
    return retVal;
}

id object_ungraftAllProtocols(id object) {
    objcgrafting::ObjCGraftCenter::shared().lock();
    id retVal = objcgrafting::ObjCGraftCenter::shared().ungraftObject(object);
    objcgrafting::ObjCGraftCenter::shared().unlock();
    return retVal;
}

namespace objcgrafting {
#pragma mark - Utility Functions
    struct ProtocolUnsafeUnretainedPointerHashFunc {
        std::size_t operator()(Protocol * __unsafe_unretained const& protocol) const {
            auto pointer = (__bridge void *)protocol;
            
            return (std::size_t)pointer;
        }
    };
    
    struct IdUnsafeUnretainedHashFunc {
        std::size_t operator()(id __unsafe_unretained const& object) const {
            auto pointer = (__bridge void *)object;
            
            return (std::size_t)pointer;
        }
    };
    
#pragma mark - objcgrafting::ObjCGraftCombination
    struct ObjCGraftCombination {
        bool is_instance;
        SEL name;
        const char * types;
        IMP impl;
        
        ObjCGraftCombination(bool is_instance, SEL name, const char * types, IMP impl) {
            this -> is_instance = is_instance;
            this -> name = name;
            this -> types = types;
            this -> impl = impl;
        }
    };
    
#pragma mark - objcgrafting::ObjCGraftInfo
    struct ObjCGraftInfo {
        /// Since other is-a swizzle dependent technologies like KVO may oerride
        /// `NSObject`'s `class` method to masquerade as nothing happened on it,
        /// we don't use `object_getClass` to get the true original class but
        /// `[NSObject -class]` the masqueraded.
        __unsafe_unretained Class semantic_class;
        
        /// The composited class with grafted implementations.
        __unsafe_unretained Class graft_class;
        
        /// The priority of grafted protocols.
        std::unique_ptr<ObjCProtocolList> grafted_protocol_list;
        
        /// The relationship of protocols and source-classes.
        std::unique_ptr<ObjCGraftMap> graft_map;
        
        ObjCGraftInfo(__unsafe_unretained Class semantic_class, __unsafe_unretained Class graft_class, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map) {
            this -> semantic_class = semantic_class;
            this -> graft_class = graft_class;
            this -> grafted_protocol_list = std::make_unique<ObjCProtocolList>(grafted_protocol_list);
            this -> graft_map = std::make_unique<ObjCGraftMap>(graft_map);
        }
        
        /// Return value indicates the graft info itself was mutated due to this graft.
        bool graft(Protocol * __unsafe_unretained *  protocols, __unsafe_unretained Class * source_classes, unsigned int count) {
            
            bool is_any_thing_modified = false;
            
            for (unsigned int index = 0; index < count; index ++) {
                auto protocol = protocols[index];
                auto source_class = source_classes[index];
                
                auto position_in_graft_map = graft_map -> find(protocol);
                
                if (position_in_graft_map != graft_map -> cend()) {
                    auto pair = * position_in_graft_map;
                    if (pair.second != source_class) {
                        graft_map -> insert({protocol, source_class});
                        is_any_thing_modified = true;
                    }
                } else {
                    graft_map -> insert({protocol, source_class});
                    is_any_thing_modified = true;
                }
                
                if (position_in_graft_map != graft_map -> cend()) {
                    // The protocol has already been grafted.
                    auto position_in_grafted_protocol_list = std::find(grafted_protocol_list -> cbegin(), grafted_protocol_list -> cend(), protocol);
                    
                    assert(position_in_grafted_protocol_list != grafted_protocol_list -> cend());
                    
                    auto grafted_protocol = (* position_in_grafted_protocol_list);
                    
                    if (position_in_grafted_protocol_list != grafted_protocol_list -> cbegin()) {
                        grafted_protocol_list -> erase(position_in_grafted_protocol_list);
                        grafted_protocol_list -> push_front(grafted_protocol);
                        
                        is_any_thing_modified = true;
                    }
                    
                } else {
                    // The protocol has not been grafted.
                    grafted_protocol_list -> push_back(protocol);
                    
                    is_any_thing_modified = true;
                }
            }
            
            return is_any_thing_modified;
        }
        
        /// Return value indicates the graft info itself was mutated due to this ungraft.
        bool ungraft(Protocol * __unsafe_unretained * protocols, unsigned int count) {
            
            bool is_any_thing_erased = false;
            
            for (unsigned int index = 0; index < count; index ++) {
                
                auto protocol = protocols[index];
                
                graft_map -> erase(protocol);
                
                auto grafted_protocol_position = std::find(grafted_protocol_list -> cbegin(), grafted_protocol_list -> cend(), protocol);
                
                assert(grafted_protocol_position != grafted_protocol_list -> cend());
                
                grafted_protocol_list -> erase(grafted_protocol_position);
                
                is_any_thing_erased = true;
            }
            
            return is_any_thing_erased;
        }
    };
    
#pragma mark - objcgrafting::ObjCGraftCenter
#pragma mark Accessing Shared Instance
    ObjCGraftCenter& ObjCGraftCenter::shared() {
        static ObjCGraftCenter shared_instance;
        return shared_instance;
    }
    
#pragma mark Grafting Object
    id ObjCGraftCenter::graftObject(id object, Protocol * __unsafe_unretained *  protocols, __unsafe_unretained Class * source_classes, unsigned int count) {
        
        if (objectHasGraftInfo(object)) {
            auto& graft_info = objectGetGraftInfo(object);
            
            if (graft_info.graft(protocols, source_classes, count)) {
                _graftObject(object, * graft_info.grafted_protocol_list, * graft_info.graft_map);
            }
        } else {
            auto graft_map = std::make_unique<ObjCGraftMap>();
            auto grafted_protocol_list = std::make_unique<ObjCProtocolList>();
            for (unsigned int index = 0; index < count; index ++) {
                auto protocol = protocols[index];
                auto source_class = source_classes[index];
                graft_map -> insert({protocol, source_class});
                grafted_protocol_list -> push_front(protocol);
            }
            _graftObject(object, * grafted_protocol_list, * graft_map);
        }
        
        return object;
    }
    
    id ObjCGraftCenter::ungraftObject(id object, Protocol * __unsafe_unretained * protocols, unsigned int count) {
        
        if (objectHasGraftInfo(object)) {
            auto& graft_info = objectGetGraftInfo(object);
            
            if (graft_info.ungraft(protocols, count)) {
                _graftObject(object, * graft_info.grafted_protocol_list, * graft_info.graft_map);
            }
        }
        
        return object;
    }
    
    id ObjCGraftCenter::ungraftObject(id object) {
        
        if (objectHasGraftInfo(object)) {
            auto& graft_info = objectGetGraftInfo(object);
            
            assert(!graft_info.graft_map -> empty());
            assert(!graft_info.grafted_protocol_list -> empty());
            
            graft_info.graft_map -> clear();
            graft_info.grafted_protocol_list -> clear();
            
            _graftObject(object, * graft_info.grafted_protocol_list, * graft_info.graft_map);
        }
        
        return object;
    }
    
    void ObjCGraftCenter::_graftObject(id object, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map) {
        
        auto semantic_class = [object class];
        
        auto topmost_class = object_getClass(object);
        
        auto graft_class = _resolveGraftClass(object, grafted_protocol_list, graft_map);
        
        _setObjectClassHierarchy(object, semantic_class, topmost_class, graft_class, grafted_protocol_list, graft_map);
        
        _setObjectGraftInfo(object, semantic_class, graft_class, grafted_protocol_list, graft_map);
    }
    
    void ObjCGraftCenter::_setObjectClassHierarchy(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class graft_class, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map) {
        
        auto is_topmost_class_graftable = topmost_class == semantic_class || class_conformsToProtocol(topmost_class, @protocol(_ObjCGrafted));
        
        if (is_topmost_class_graftable) {
            _setObjectClassHierarchyWhenTopmostClassIsGraftable(object, semantic_class, topmost_class, graft_class, grafted_protocol_list, graft_map);
        } else {
            _setObjectClassHierarchyWhenTopmostClassIsNotGraftable(object, semantic_class, topmost_class, graft_class, grafted_protocol_list, graft_map);
        }
    }
    
    void ObjCGraftCenter::_setObjectClassHierarchyWhenTopmostClassIsGraftable(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class graft_class, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map) {
        if (grafted_protocol_list.empty()) {
            assert(graft_map.empty());
            object_setClass(object, semantic_class);
        } else {
            assert(graft_class != nullptr);
            object_setClass(object, graft_class);
        }
    }
    
    void ObjCGraftCenter::_setObjectClassHierarchyWhenTopmostClassIsNotGraftable(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class graft_class, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map) {
        
        auto topmost_class_name_raw = class_getName(topmost_class);
        
        auto topmost_class_name = [NSString stringWithUTF8String:topmost_class_name_raw];
        
        auto kvo_notifying_class_prefix = [NSString stringWithFormat:@"NSKVONotifying_"];
        
        if ([topmost_class_name hasPrefix:kvo_notifying_class_prefix]) {
            _setObjectClassHierarchyWithConsiderationOfKeyValueObservation(object, semantic_class, topmost_class, graft_class, grafted_protocol_list, graft_map);
        } else {
            _setObjectClassHierarchyWithException(object, semantic_class, topmost_class, graft_class, grafted_protocol_list, graft_map);
        }
    }
    
    void ObjCGraftCenter::_setObjectClassHierarchyWithConsiderationOfKeyValueObservation(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class graft_class, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map) {
        
        auto kvo_notifying_class = topmost_class;
        
        // Return the implementation of -class method if needed
        if (objectHasGraftInfo(object)) {
            auto old_graft_class = objectGetGraftInfo(object).graft_class;
            auto kvo_notifying_class_class_impl = _graftClassGetBackwardInstanceImpl(old_graft_class, ObjCGraftedObjectBackwardInstanceImplKindKVOClass);
            if (kvo_notifying_class_class_impl != nullptr) {
                Cls::replaceInstanceMethod(kvo_notifying_class, @selector(class), kvo_notifying_class_class_impl);
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
        
        if (graft_class != nullptr) {
            assert(!grafted_protocol_list.empty());
            assert(!graft_map.empty());
            object_setClass(object, graft_class);
        } else {
            assert(grafted_protocol_list.empty());
            assert(graft_map.empty());
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
        
        if (graft_class != nullptr) {
            auto new_kvo_notifying_class_class_impl = class_getMethodImplementation(refreshed_topmost_class, @selector(class));
            if (new_kvo_notifying_class_class_impl != (IMP)&_NSObjectClass) {
                _graftClassSetBackwardInstanceImpl(graft_class, new_kvo_notifying_class_class_impl, ObjCGraftedObjectBackwardInstanceImplKindKVOClass);
                Cls::replaceInstanceMethod(refreshed_topmost_class, @selector(class), &_NSObjectClass);
            }
        }
    }
    
    void ObjCGraftCenter::_setObjectClassHierarchyWithException(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class topmost_class, __unsafe_unretained Class graft_class, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map) {
        [NSException raise:NSInternalInconsistencyException format:@"Unkown is-a swizzle technique was found on object %@. Semantic Class = %@; Topmost Class = %@, Graft Class = %@.", [object description], NSStringFromClass(semantic_class), NSStringFromClass(topmost_class), NSStringFromClass(graft_class)];
    }
    
    void ObjCGraftCenter::_setObjectGraftInfo(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class graft_class, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map) {
        
        if (objectHasGraftInfo(object)) {
            if (graft_map.empty()) {
                assert(object_getClass(object) == semantic_class || class_getSuperclass(object_getClass(object)) == semantic_class);
                _objectRemoveGraftInfo(object);
            } else {
                auto& graft_info = objectGetGraftInfo(object);
                assert(graft_info.semantic_class == semantic_class);
                graft_info.graft_class = graft_class;
            }
        } else {
            if (!graft_map.empty()) {
                _objectAddGraftInfo(object, semantic_class, graft_class, grafted_protocol_list, graft_map);
            }
        }
    }
    
#pragma mark Accessing Object's Members
    bool ObjCGraftCenter::objectHasGraftInfo(id object) {
        return graft_info_map_ -> find(object) != graft_info_map_ -> cend();
    }
    
    ObjCGraftInfo& ObjCGraftCenter::objectGetGraftInfo(id object) {
        return * (* graft_info_map_)[object];
    }
    
    _ObjCKeyValueObservationRecordList * ObjCGraftCenter::objectGetKeyValueObservationRecords(id object) {
        auto existed_record_list_positoin = key_value_observation_records_map_ -> find(object);
        
        if (existed_record_list_positoin != key_value_observation_records_map_ -> cend()) {
            return (* existed_record_list_positoin).second;
        } else {
            auto list = [[_ObjCKeyValueObservationRecordList alloc] initWithTarget:object];
            (* key_value_observation_records_map_)[object] = list;
            return list;
        }
    }
    
    IMP ObjCGraftCenter::objectGetBackwardInstanceImpl(id object, ObjCGraftedObjectBackwardInstanceImplKind kind) {
        if (objectHasGraftInfo(object)) {
            auto& graft_info = objectGetGraftInfo(object);
            auto graft_class = graft_info.graft_class;
            IMP backward_instance_impl = _graftClassGetBackwardInstanceImpl(graft_class, kind);
            return backward_instance_impl;
        }
        return nil;
    }
    
    void ObjCGraftCenter::_objectAddGraftInfo(id object, __unsafe_unretained Class semantic_class, __unsafe_unretained Class graft_class, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map) {
        graft_info_map_ -> emplace(object, std::make_unique<ObjCGraftInfo>(semantic_class, graft_class, grafted_protocol_list, graft_map));
    }
    
    void ObjCGraftCenter::_objectRemoveGraftInfo(__unsafe_unretained id object) {
        graft_info_map_ -> erase(object);
    }
    
    void ObjCGraftCenter::_objectRemoveKeyValueObservationRecords(__unsafe_unretained id object) {
        key_value_observation_records_map_ -> erase(object);
    }
    
#pragma mark Delegating Object
    void ObjCGraftCenter::objectWillDealloc(__unsafe_unretained id object) {
        _objectRemoveGraftInfo(object);
        _objectRemoveKeyValueObservationRecords(object);
    }
    
#pragma mark Delegating Object's KVO Actions
    void ObjCGraftCenter::objectWillAddKeyValueObserver(id object, id observer, NSString * key_path, NSKeyValueObservingOptions options, void * context) {
        [objectGetKeyValueObservationRecords(object) addRecordWithObserver:observer keyPath:key_path options:options context:context];
        
    }
    
    void ObjCGraftCenter::objectDidAddKeyValueObserver(id object, id observer, NSString * key_path, NSKeyValueObservingOptions options, void * context) {
        
        if (objectHasGraftInfo(object)) {
            _setObjectInstanceMethodClassImplForAddingObserver(object);
        }
    }
    
    void ObjCGraftCenter::objectWillRemoveKeyValueObserver(id object, id observer, NSString * key_path, void * context) {
        [objectGetKeyValueObservationRecords(object) removeRecordWithObserver:observer keyPath:key_path context:context];
        
        if ([objectGetKeyValueObservationRecords(object) isEmpty]) {
            _setObjectInstanceMethodClassImplForRemovingObserver(object);
        }
        
    }
    
    void ObjCGraftCenter::objectWillRemoveKeyValueObserver(id object, id observer, NSString * key_path) {
        [objectGetKeyValueObservationRecords(object) removeRecordsWithObserver:observer keyPath:key_path];
        
        if ([objectGetKeyValueObservationRecords(object) isEmpty]) {
            _setObjectInstanceMethodClassImplForRemovingObserver(object);
        }
    }
    
    void ObjCGraftCenter::objectDidRemoveKeyValueObserver(id object, id observer, NSString * key_path, void * context) {
        
    }
    
    void ObjCGraftCenter::objectDidRemoveKeyValueObserver(id object, id observer, NSString * key_path) {
        
    }
    
    void ObjCGraftCenter::_setObjectInstanceMethodClassImplForAddingObserver(id object) {
        if (objectHasGraftInfo(object)) {
            auto& graft_info = objectGetGraftInfo(object);
            auto graft_class = graft_info.graft_class;
            auto kvo_notifying_class = object_getClass(object);
            auto current_class_impl = class_getMethodImplementation(kvo_notifying_class, @selector(class));
            if (current_class_impl != (IMP)&_NSObjectClass) {
                _graftClassSetBackwardInstanceImpl(graft_class, current_class_impl, ObjCGraftedObjectBackwardInstanceImplKindKVOClass);
                Cls::replaceInstanceMethod(kvo_notifying_class, @selector(class), &_NSObjectClass);
            }
        }
    }
    
    void ObjCGraftCenter::_setObjectInstanceMethodClassImplForRemovingObserver(id object) {
        if (objectHasGraftInfo(object)) {
            auto kvo_notifying_class = object_getClass(object);
            auto graft_class = objectGetGraftInfo(object).graft_class;
            auto backward_class_impl = _graftClassGetBackwardInstanceImpl(graft_class, ObjCGraftedObjectBackwardInstanceImplKindKVOClass);
            if (backward_class_impl != nullptr) {
                Cls::replaceInstanceMethod(kvo_notifying_class, @selector(class), backward_class_impl);
            }
        }
    }
    
#pragma mark Managing Object's KVO Action Delegation
    bool ObjCGraftCenter::isObjectKVOActionDelegationDisabled() {
        return object_kvo_action_delegation_disabled_;
    }
    
    void ObjCGraftCenter::setObjectKVOActionDelegationDisabled(bool flag) {
        object_kvo_action_delegation_disabled_ = flag;
    }
    
#pragma mark Managing Lock
    void ObjCGraftCenter::lock() {
        auto lock_signal = pthread_mutex_lock(&lock_);
        if (lock_signal == EINVAL) {
            [NSException raise:NSInternalInconsistencyException format:@"Invalid mutex."];
        }
        if (lock_signal == EDEADLK) {
            [NSException raise:NSInternalInconsistencyException format:@"Deadlocked."];
        }
        lock_owner_ = pthread_self();
    }
    
    void ObjCGraftCenter::unlock() {
        lock_owner_ = NULL;
        auto unlock_signal = pthread_mutex_unlock(&lock_);
        if (unlock_signal == EINVAL) {
            [NSException raise:NSInternalInconsistencyException format:@"Invalid mutex."];
        }
        if (unlock_signal == EPERM) {
            [NSException raise:NSInternalInconsistencyException format:@"Current thread doesn't hold a lock on mutex."];
        }
    }
    
    void ObjCGraftCenter::_initLock() {
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
    
    void ObjCGraftCenter::_destroyLock() {
        auto signal = pthread_mutex_destroy(&lock_);
        if (signal == EINVAL) {
            [NSException raise:NSInternalInconsistencyException format:@"Invalid mutex."];
        }
        if (signal == EBUSY) {
            [NSException raise:NSInternalInconsistencyException format:@"Mutex is locked by another thread."];
        }
    }
    
#pragma mark Resolving Graft Class
    Class ObjCGraftCenter::_resolveGraftClass(id object, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map) {
        
        if (grafted_protocol_list.empty()) {
            assert(graft_map.empty());
            return nil;
        }
        
        auto semantic_class = [object class];
        
        auto grafted_components_id = _graftedProtocolIdentifier(grafted_protocol_list, graft_map);
        
        auto class_name = [NSString stringWithFormat:@"_ObjCGrafted_%@_%@", NSStringFromClass(semantic_class), grafted_components_id];
        
        auto raw_class_name = class_name.UTF8String;
        
        auto cls = objc_getClass(raw_class_name);
        
        if (cls == nullptr) {
            cls = objc_allocateClassPair(semantic_class, raw_class_name, sizeof(void *) * OBJC_GRAFTED_CLASS_BACKWARD_IMPL_COUNT);
            ObjCGraftClassInitialize(cls);
            objc_registerClassPair(cls);
            
            _graftClassAddSystematicProtocols(cls);
            _graftClassAddUserDefinedProtocols(cls, grafted_protocol_list);
            _graftClassAddSystematicMethods(cls);
            _graftClassAddUserDefinedMethods(cls, grafted_protocol_list, graft_map);
            
            assert(cls != nullptr);
        }
        
        return cls;
    }
    
    NSString * ObjCGraftCenter::_graftedProtocolIdentifier(ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map) {
        auto component_names = [[NSMutableArray<NSString *> alloc] init];
        
        auto protocols = std::make_unique<std::vector<Protocol * __unsafe_unretained>>();
        
        for (auto& protocol: grafted_protocol_list) {
            auto source_class = graft_map[protocol];
            assert(source_class != nullptr);
            protocols -> push_back(protocol);
            auto protocol_name = NSStringFromProtocol(protocol);
            auto source_class_name = NSStringFromClass(source_class);
            auto component_name = [NSString stringWithFormat:@"%@->%@", protocol_name, source_class_name];
            [component_names addObject:component_name];
        }
        
        auto grafted_components_id = [component_names componentsJoinedByString:@"|"];
        
        return grafted_components_id;
    }
    
    void ObjCGraftCenter::_graftClassAddSystematicProtocols(__unsafe_unretained Class cls) {
        // Conforms to _ObjCGrafted.
        class_addProtocol(cls, @protocol(_ObjCGrafted));
    }
    
    void ObjCGraftCenter::_graftClassAddUserDefinedProtocols(__unsafe_unretained Class cls, ObjCProtocolList& grafted_protocol_list) {
        for (auto& protocol: grafted_protocol_list) {
            class_addProtocol(cls, protocol);
        }
    }
    
    void ObjCGraftCenter::_graftClassAddSystematicMethods(__unsafe_unretained Class cls) {
        // Add [NSObject -class]
        class_addMethod(cls, @selector(class), (IMP)&_NSObjectClass, "@:");
        
        // Add [NSObject -dealloc]
        class_addMethod(cls, NSSelectorFromString(@"dealloc"), (IMP)&_NSObjectDealloc, "@:");
    }
    
    void ObjCGraftCenter::_graftClassAddUserDefinedMethods(__unsafe_unretained Class cls, ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map) {
        
        auto graft_combination_list = _resolveGraftCombinationList(grafted_protocol_list, graft_map);
        
        Class metaClass = objc_getMetaClass(class_getName(cls));
        
        for (auto& graft: * graft_combination_list) {
            if (graft.is_instance) {
                if (graft.name == @selector(class)) {
                    _graftClassSetBackwardInstanceImpl(cls, graft.impl, ObjCGraftedObjectBackwardInstanceImplKindClass);
                } else if (graft.name == NSSelectorFromString(@"dealloc")) {
                    _graftClassSetBackwardInstanceImpl(cls, graft.impl, ObjCGraftedObjectBackwardInstanceImplKindDealloc);
                } else {
                    class_addMethod(cls, graft.name, graft.impl, graft.types);
                }
            } else {
                class_addMethod(metaClass, graft.name, graft.impl, graft.types);
            }
        }
    }
    
    std::unique_ptr<ObjCProtocolUnorderedSet> ObjCGraftCenter::_resolveNetTopmostGraftedProtocols(ObjCProtocolList& grafted_protocol_list, ObjCGraftMap& graft_map) {
        auto resolved_protocol_set = std::make_unique<ObjCProtocolUnorderedSet>();
        
        auto net_topmost_protocol_set = std::make_unique<ObjCProtocolUnorderedSet>();
        
        for (auto& pair: graft_map) {
            auto topmost_protocol = pair.first;
            
            if (resolved_protocol_set -> find(topmost_protocol) == resolved_protocol_set -> cend()) {
                
                auto unresolved_protocol_list = std::make_unique<ObjCProtocolList>();
                unresolved_protocol_list -> push_back(topmost_protocol);
                
                while (!unresolved_protocol_list -> empty()) {
                    auto protocol_being_resolved = * unresolved_protocol_list -> cbegin();
                    unresolved_protocol_list -> pop_front();
                    
                    if (!_isProtocolRegistered(protocol_being_resolved)) {
                        
                        auto conformed_protocol_list = std::make_unique<ObjCProtocolList>();
                        
                        unsigned int conformed_protocol_count = 0;
                        auto conformed_protocols = protocol_copyProtocolList(protocol_being_resolved, &conformed_protocol_count);
                        
                        for (unsigned int index = 0; index < conformed_protocol_count; index ++) {
                            auto conformed_protocol = conformed_protocols[index];
                            
                            conformed_protocol_list -> push_back(conformed_protocol);
                            unresolved_protocol_list -> push_back(conformed_protocol);
                        }
                        
                        free(conformed_protocols);
                        
                        _registerConformedProtocolsForProtocol(protocol_being_resolved, * conformed_protocol_list);
                    }
                    
                    resolved_protocol_set -> insert(protocol_being_resolved);
                }
                
                net_topmost_protocol_set -> insert(topmost_protocol);
            }
            
        }
        
        return net_topmost_protocol_set;
    }
    
    std::unique_ptr<ObjCGraftCombinationList> ObjCGraftCenter::_resolveGraftCombinationList(ObjCProtocolList& grafted_protocol_list, ObjCGraftMap &graft_map) {
        
        auto net_topmost_protocol_set = _resolveNetTopmostGraftedProtocols(grafted_protocol_list, graft_map);
        
        auto graft_combination_list = std::make_unique<ObjCGraftCombinationList>();
        
        auto grafted_instance_selector_set = std::make_unique<std::unordered_set<SEL>>();
        
        auto grafted_class_selector_set = std::make_unique<std::unordered_set<SEL>>();
        
        for (auto& grafted_protocol: grafted_protocol_list) {
            
            if (net_topmost_protocol_set -> find(grafted_protocol) != net_topmost_protocol_set -> cend()) {
                auto source_class = graft_map[grafted_protocol];
                
                auto source_meta_class = objc_getMetaClass(class_getName(source_class));
                
                unsigned int source_class_method_count = 0;
                auto source_class_method_list = class_copyMethodList(source_class, &source_class_method_count);
                
                auto instance_candidate_selector_set = std::make_unique<std::unordered_set<SEL>>();
                
                for (unsigned int index = 0; index < source_class_method_count; index ++) {
                    auto method = source_class_method_list[index];
                    auto selector = method_getName(method);
                    instance_candidate_selector_set -> insert(selector);
                }
                
                free(source_class_method_list);
                
                unsigned int source_meta_class_method_count = 0;
                auto source_meta_class_method_list =class_copyMethodList(source_meta_class, &source_meta_class_method_count);
                
                auto class_candidate_selector_set = std::make_unique<std::unordered_set<SEL>>();
                
                for (unsigned int index = 0; index < source_meta_class_method_count; index ++) {
                    auto method = source_meta_class_method_list[index];
                    auto selector = method_getName(method);
                    class_candidate_selector_set -> insert(selector);
                }
                
                free(source_meta_class_method_list);
                
                assert(source_class != nullptr);
                
                auto not_enlisted_protocol_list = std::make_unique<ObjCProtocolList>();
                not_enlisted_protocol_list -> push_back(grafted_protocol);
                
                while (!not_enlisted_protocol_list -> empty()) {
                    auto protocol_to_enlist = * not_enlisted_protocol_list -> cbegin();
                    not_enlisted_protocol_list -> pop_front();
                    
                    assert(_isProtocolRegistered(protocol_to_enlist));
                    
                    for (unsigned int flag = 0; flag <= 0b11; flag ++) {
                        bool is_required = (flag & 0b01) != 0;
                        bool is_instance = (flag & 0b10) != 0;
                        
                        auto cls = is_instance ? source_class : source_meta_class;
                        
                        auto& grafted_selector_set = is_instance ? grafted_instance_selector_set : grafted_class_selector_set;
                        
                        auto& allowed_selector_set = is_instance ? instance_candidate_selector_set : class_candidate_selector_set;
                        
                        unsigned int method_count = 0;
                        auto method_description_list = protocol_copyMethodDescriptionList(protocol_to_enlist, is_required, is_instance, &method_count);
                        
                        for (unsigned int index = 0; index < method_count; index ++) {
                            auto method_description = method_description_list[index];
                            
                            auto selector = method_description.name;
                            auto types = method_description.types;
                            
                            bool is_not_grafted = grafted_selector_set -> find(selector) == grafted_selector_set -> cend();
                            
                            if (is_not_grafted && allowed_selector_set -> find(selector) != allowed_selector_set -> cend()) {
                                auto impl = class_getMethodImplementation(cls, selector);
                                graft_combination_list -> emplace_back(is_instance, selector, types, impl);
                                grafted_selector_set -> insert(selector);
                            }
                        }
                        
                        free(method_description_list);
                    }
                    
                    not_enlisted_protocol_list -> merge(_conformedProtocolsForRegisteredProtocol(protocol_to_enlist));
                }
                
            }
        }
        
        return graft_combination_list;
    }
    
#pragma mark Accessing Graft Class Info
    void ObjCGraftCenter::_graftClassSetBackwardInstanceImpl(Class cls, IMP impl, ObjCGraftedObjectBackwardInstanceImplKind kind) {
        ObjCGraftClassSetBackwardInstanceImpl(cls, impl, kind);
    }
    
    IMP ObjCGraftCenter::_graftClassGetBackwardInstanceImpl(Class cls, ObjCGraftedObjectBackwardInstanceImplKind kind) {
        return ObjCGraftClassGetBackwardInstanceImpl(cls, kind);
    }
    
#pragma mark Accessing Elements in Registered Protocol Graph
    ObjCProtocolGraph& ObjCGraftCenter::_registeredProtocolGraph() {
        return *registered_protocol_graph_;
    }
    
    bool ObjCGraftCenter::_isProtocolRegistered(Protocol * __unsafe_unretained protocol) {
        auto position = registered_protocol_graph_ -> find(protocol);
        if (position == registered_protocol_graph_ -> cend()) {
            return false;
        }
        return true;
    }
    
    ObjCProtocolList& ObjCGraftCenter::_conformedProtocolsForRegisteredProtocol(Protocol * __unsafe_unretained protocol) {
        auto position = registered_protocol_graph_ -> find(protocol);
        return * position -> second;
    }
    
    void ObjCGraftCenter::_registerConformedProtocolsForProtocol(Protocol * __unsafe_unretained protocol, ObjCProtocolList& protocol_list) {
        registered_protocol_graph_ -> emplace(protocol, std::make_unique<ObjCProtocolList>(protocol_list));
    }
}

#pragma mark - KVO Sepcial Treatment
#pragma mark _ObjCKeyValueObservationRecord
@implementation _ObjCKeyValueObservationRecord
- (void)addContext:(void *)context
{
    _contexts -> insert(context);
}

- (BOOL)removeContext:(void *)context
{
    return _contexts -> erase(context) != 0 ;
}

- (void)enumerateContextsUsingBlock:(void (^)(void * context))block
{
    for (auto& context: * _contexts) {
        block(context);
    }
}

- (BOOL)needsRemove
{
    return _contexts -> empty();
}

- (instancetype)initWithObserver:(id)observer keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options
{
    self = [super init];
    if (self) {
        _contexts = std::make_unique<std::unordered_set<void *>>();
        _observer = observer;
        _keyPath = keyPath;
        _options = options;
        _hash = [[NSString stringWithFormat:@"%p %@", observer, keyPath] hash];
    }
    return self;
}

- (NSUInteger)hash
{
    return _hash;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        _ObjCKeyValueObservationRecord * record = (_ObjCKeyValueObservationRecord * )object;
        return record -> _observer == _observer && [record -> _keyPath isEqualToString:_keyPath];
    }
    
    return NO;
}
@end
#pragma mark _ObjCKeyValueObservationRecordList
@implementation _ObjCKeyValueObservationRecordList
- (instancetype)initWithTarget:(id)target
{
    self = [super init];
    if (self) {
        _target = target;
        _records = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)addRecordWithObserver:(id)observer keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    NSParameterAssert(observer);
    NSParameterAssert(keyPath);
    auto key = [[_ObjCKeyValueObservationRecord alloc] initWithObserver:observer keyPath:keyPath options:options];
    auto existedMember = [_records member:key];
    if (existedMember) {
        existedMember.options = existedMember.options | options;
        [existedMember addContext: context];
    } else {
        [key addContext:context];
        [_records addObject: key];
    }
}

- (void)removeRecordsWithObserver:(id)observer keyPath:(NSString *)keyPath
{
    NSParameterAssert(observer);
    NSParameterAssert(keyPath);
    auto recordsToRemove = [[NSMutableSet alloc] init];
    [_records enumerateObjectsUsingBlock:^(_ObjCKeyValueObservationRecord * record, BOOL * stop) {
        NSLog(@"record: %@", record);
        NSLog(@"record.observer: %@", record.observer);
        NSLog(@"record.keyPath: %@", record.keyPath);
        NSLog(@"observer: %@", observer);
        NSLog(@"keyPath: %@", keyPath);
        if (record.observer == observer && [record.keyPath isEqualToString:keyPath]) {
            [recordsToRemove addObject: record];
        }
    }];
    [_records minusSet:recordsToRemove];
}

- (void)removeRecordWithObserver:(id)observer keyPath:(NSString *)keyPath context:(void *)context
{
    NSParameterAssert(observer);
    NSParameterAssert(keyPath);
    auto key = [[_ObjCKeyValueObservationRecord alloc] initWithObserver:observer keyPath:keyPath options:NULL];
    [_records removeObject:key];
}

- (void)enumerateRecordWithBlock:(void (^)(id observer, NSString * keyPath, NSKeyValueObservingOptions options, void * context))block
{
    [_records enumerateObjectsUsingBlock:^(_ObjCKeyValueObservationRecord * record, BOOL * stop) {
        [record enumerateContextsUsingBlock:^(void *context) {
            block(record.observer, record.keyPath, record.options, context);
        }];
    }];
}

- (BOOL)isEmpty
{
    return [_records count] == 0;
}
@end

#pragma mark NSObject Sepcial Treatment
@implementation NSObject(ObjCGraft)
+ (void)load
{
    _kNSObjectAddObserverForKeyPathOptionsContext = objcgrafting::Cls::replaceInstanceMethod(self, @selector(addObserver:forKeyPath:options:context:), &_NSObjectAddObserverForKeyPathOptionsContext);
    
    _kNSObjectRemoveObserverForKeyPath = objcgrafting::Cls::replaceInstanceMethod(self, @selector(removeObserver:forKeyPath:), &_NSObjectRemoveObserverForKeyPath);
    
    _kNSObjectRemoveObserverForKeyPathContext = objcgrafting::Cls::replaceInstanceMethod(self, @selector(removeObserver:forKeyPath:context:), &_NSObjectRemoveObserverForKeyPathContext);
}
@end

#pragma mark NSArray Sepcial Treatment
@implementation NSArray(ObjCGraft)
+ (void)load
{
    _kNSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext = objcgrafting::Cls::replaceInstanceMethod(self, @selector(addObserver:toObjectsAtIndexes:forKeyPath:options:context:), &_NSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext);
    
    _kNSArrayRemoveObserverFromObjectsAtIndicesForKeyPath = objcgrafting::Cls::replaceInstanceMethod(self, @selector(removeObserver:fromObjectsAtIndexes:forKeyPath:), &_NSArrayRemoveObserverFromObjectsAtIndicesForKeyPath);
    
    _kNSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext = objcgrafting::Cls::replaceInstanceMethod(self, @selector(removeObserver:fromObjectsAtIndexes:forKeyPath:context:), &_NSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext);
}
@end

#pragma mark - Swizzled Functions Implementations
void _NSObjectAddObserverForKeyPathOptionsContext(NSObject * self, SEL _cmd, NSObject * observer, NSString * keyPath, NSKeyValueObservingOptions options, void * context) {
    objcgrafting::ObjCGraftCenter::shared().lock();
    if (!objcgrafting::ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        objcgrafting::ObjCGraftCenter::shared().objectWillAddKeyValueObserver(self, observer, keyPath, options, context);
    }
    (* _kNSObjectAddObserverForKeyPathOptionsContext)(self, _cmd, observer, keyPath, options, context);
    if (!objcgrafting::ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        objcgrafting::ObjCGraftCenter::shared().objectDidAddKeyValueObserver(self, observer, keyPath, options, context);
    }
    objcgrafting::ObjCGraftCenter::shared().unlock();
}

void _NSObjectRemoveObserverForKeyPath(NSObject * self, SEL _cmd, NSObject * observer, NSString * keyPath) {
    objcgrafting::ObjCGraftCenter::shared().lock();
    if (!objcgrafting::ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        objcgrafting::ObjCGraftCenter::shared().objectWillRemoveKeyValueObserver(self, observer, keyPath);
    }
    (* _kNSObjectRemoveObserverForKeyPath)(self, _cmd, observer, keyPath);
    if (!objcgrafting::ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        objcgrafting::ObjCGraftCenter::shared().objectDidRemoveKeyValueObserver(self, observer, keyPath);
    }
    objcgrafting::ObjCGraftCenter::shared().unlock();
}

void _NSObjectRemoveObserverForKeyPathContext(NSObject * self, SEL _cmd, NSObject * observer, NSString * keyPath, void * context) {
    // In iOS 11, `[NSObject -removeObserver:forKeyPath:context:]` was
    // routed to `[NSObject -removeOberver:forKeyPath:]`, which causes
    // duplicate removal to the records on the Graft Center. And such a
    // duplicate removal causes bad accesses. To prevent this duplicate
    // removal, `ObjCGraftCenter::setObjectKVOActionDelegationDisabled()`
    // was made public and called after the outter delegation calls here.
    objcgrafting::ObjCGraftCenter::shared().lock();
    if (!objcgrafting::ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        objcgrafting::ObjCGraftCenter::shared().objectWillRemoveKeyValueObserver(self, observer, keyPath, context);
    }
    // Prevent duplicate removal.
    objcgrafting::ObjCGraftCenter::shared().setObjectKVOActionDelegationDisabled(true);
    (* _kNSObjectRemoveObserverForKeyPathContext)(self, _cmd, observer, keyPath, context);
    // Recover from preventting duplicate removal.
    objcgrafting::ObjCGraftCenter::shared().setObjectKVOActionDelegationDisabled(false);
    if (!objcgrafting::ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        objcgrafting::ObjCGraftCenter::shared().objectDidRemoveKeyValueObserver(self, observer, keyPath, context);
    }
    objcgrafting::ObjCGraftCenter::shared().unlock();
}

void _NSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext(NSArray * self, SEL _cmd, NSObject * observer, NSIndexSet * indices, NSString * keyPath, NSKeyValueObservingOptions options, void * context) {
    objcgrafting::ObjCGraftCenter::shared().lock();
    if (!objcgrafting::ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        [self enumerateObjectsAtIndexes:indices options:NULL usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            objcgrafting::ObjCGraftCenter::shared().objectWillAddKeyValueObserver(self, observer, keyPath, options, context);
        }];
    }
    (* _kNSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext)(self, _cmd, observer, indices, keyPath, options, context);
    if (!objcgrafting::ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        [self enumerateObjectsAtIndexes:indices options:NULL usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            objcgrafting::ObjCGraftCenter::shared().objectDidAddKeyValueObserver(self, observer, keyPath, options, context);
        }];
    }
    objcgrafting::ObjCGraftCenter::shared().unlock();
}

void _NSArrayRemoveObserverFromObjectsAtIndicesForKeyPath(NSArray * self, SEL _cmd, NSObject * observer, NSIndexSet * indices, NSString * keyPath) {
    objcgrafting::ObjCGraftCenter::shared().lock();
    if (!objcgrafting::ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        [self enumerateObjectsAtIndexes:indices options:NULL usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            objcgrafting::ObjCGraftCenter::shared().objectWillRemoveKeyValueObserver(self, observer, keyPath);
        }];
    }
    (* _kNSArrayRemoveObserverFromObjectsAtIndicesForKeyPath)(self, _cmd, observer, indices, keyPath);
    if (!objcgrafting::ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        [self enumerateObjectsAtIndexes:indices options:NULL usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            objcgrafting::ObjCGraftCenter::shared().objectDidRemoveKeyValueObserver(self, observer, keyPath);
        }];
    }
    objcgrafting::ObjCGraftCenter::shared().unlock();
}

void _NSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext(NSArray * self, SEL _cmd, NSObject * observer, NSIndexSet * indices, NSString * keyPath, void * context) {
    objcgrafting::ObjCGraftCenter::shared().lock();
    if (!objcgrafting::ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        [self enumerateObjectsAtIndexes:indices options:NULL usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            objcgrafting::ObjCGraftCenter::shared().objectWillRemoveKeyValueObserver(self, observer, keyPath, context);
        }];
    }
    (* _kNSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext)(self, _cmd, observer, indices, keyPath, context);
    if (!objcgrafting::ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        [self enumerateObjectsAtIndexes:indices options:NULL usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            objcgrafting::ObjCGraftCenter::shared().objectDidRemoveKeyValueObserver(self, observer, keyPath, context);
        }];
    }
    objcgrafting::ObjCGraftCenter::shared().unlock();
}

void _NSObjectDealloc(NSObject * __unsafe_unretained self, SEL _cmd) {
    if (objcgrafting::ObjCGraftCenter::shared().objectHasGraftInfo(self)) {
        NSObjectDealloc * customImpl = (NSObjectDealloc *)objcgrafting::ObjCGraftCenter::shared().objectGetBackwardInstanceImpl(self, ObjCGraftedObjectBackwardInstanceImplKindDealloc);
        
        if (customImpl != nullptr) {
            (* customImpl)(self, _cmd);
        } else {
            _NSObjectSuperDealloc(self, _cmd);
        }
        
        objcgrafting::ObjCGraftCenter::shared().lock();
        objcgrafting::ObjCGraftCenter::shared().objectWillDealloc(self);
        objcgrafting::ObjCGraftCenter::shared().unlock();
    } else {
        _NSObjectSuperDealloc(self, _cmd);
    }
}

void _NSObjectSuperDealloc(NSObject * __unsafe_unretained self, SEL _cmd) {
    struct objc_super superclass = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    
    typedef void SuperMsg (struct objc_super *, SEL);
    SuperMsg * superImpl = (SuperMsg *)objc_msgSendSuper;
    (* superImpl)(&superclass, _cmd);
}

Class _NSObjectClass(NSObject * self, SEL _cmd) {
    objcgrafting::ObjCGraftCenter::shared().lock();
    
    auto& graft_info = objcgrafting::ObjCGraftCenter::shared().objectGetGraftInfo(self);
    
    Class semantic_calss = graft_info.semantic_class;
    
    NSObjectClass * customImpl = (NSObjectClass *)objcgrafting::ObjCGraftCenter::shared().objectGetBackwardInstanceImpl(self, ObjCGraftedObjectBackwardInstanceImplKindClass);
    
    if (customImpl) {
#if DEBUG
        Class retVal = (* customImpl)(self, _cmd);
        NSLog(@"The return value(\"%@\") of your implementation defined for selector \"-class\" grafted on class \"%@\" was omitted.", NSStringFromClass(retVal), NSStringFromClass(semantic_calss));
#else
        (* customImpl)(self, _cmd);
#endif
    }
    
    assert(semantic_calss != nil);
    
    objcgrafting::ObjCGraftCenter::shared().unlock();
    
    return semantic_calss;
}
