//
//  NSArray+_KVOSpecialTreatment.mm
//  ObjCGraft
//
//  Created on 29/12/2018.
//

#import "NSArray+_KVOSpecialTreatment.h"

#import "_ObjCClass.h"
#import "_ObjCGraftCenter.h"

static NSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext _NSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext;
static NSArrayRemoveObserverFromObjectsAtIndicesForKeyPath _NSArrayRemoveObserverFromObjectsAtIndicesForKeyPath;
static NSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext _NSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext;

NSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext * _kNSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext = NULL;
NSArrayRemoveObserverFromObjectsAtIndicesForKeyPath * _kNSArrayRemoveObserverFromObjectsAtIndicesForKeyPath = NULL;
NSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext * _kNSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext = NULL;

@implementation NSArray(_KVOSpecialTreatment)
+ (void)load
{
    _kNSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext = objcgraft::_ObjCClass::replaceInstanceMethod(self, @selector(addObserver:toObjectsAtIndexes:forKeyPath:options:context:), &_NSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext);
    
    _kNSArrayRemoveObserverFromObjectsAtIndicesForKeyPath = objcgraft::_ObjCClass::replaceInstanceMethod(self, @selector(removeObserver:fromObjectsAtIndexes:forKeyPath:), &_NSArrayRemoveObserverFromObjectsAtIndicesForKeyPath);
    
    _kNSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext = objcgraft::_ObjCClass::replaceInstanceMethod(self, @selector(removeObserver:fromObjectsAtIndexes:forKeyPath:context:), &_NSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext);
}
@end

void _NSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext(NSArray * self, SEL _cmd, NSObject * observer, NSIndexSet * indices, NSString * keyPath, NSKeyValueObservingOptions options, void * context) {
    objcgraft::_ObjCGraftCenter::shared().lock();
    if (!objcgraft::_ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        [self enumerateObjectsAtIndexes:indices options:NULL usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            objcgraft::_ObjCGraftCenter::shared().objectWillAddKeyValueObserver(obj, observer, keyPath, options, context);
        }];
    }
    (* _kNSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext)(self, _cmd, observer, indices, keyPath, options, context);
    if (!objcgraft::_ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        [self enumerateObjectsAtIndexes:indices options:NULL usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            objcgraft::_ObjCGraftCenter::shared().objectDidAddKeyValueObserver(obj, observer, keyPath, options, context);
        }];
    }
    objcgraft::_ObjCGraftCenter::shared().unlock();
}

void _NSArrayRemoveObserverFromObjectsAtIndicesForKeyPath(NSArray * self, SEL _cmd, NSObject * observer, NSIndexSet * indices, NSString * keyPath) {
    objcgraft::_ObjCGraftCenter::shared().lock();
    if (!objcgraft::_ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        [self enumerateObjectsAtIndexes:indices options:NULL usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            objcgraft::_ObjCGraftCenter::shared().objectWillRemoveKeyValueObserver(obj, observer, keyPath);
        }];
    }
    (* _kNSArrayRemoveObserverFromObjectsAtIndicesForKeyPath)(self, _cmd, observer, indices, keyPath);
    if (!objcgraft::_ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        [self enumerateObjectsAtIndexes:indices options:NULL usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            objcgraft::_ObjCGraftCenter::shared().objectDidRemoveKeyValueObserver(obj, observer, keyPath);
        }];
    }
    objcgraft::_ObjCGraftCenter::shared().unlock();
}

void _NSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext(NSArray * self, SEL _cmd, NSObject * observer, NSIndexSet * indices, NSString * keyPath, void * context) {
    objcgraft::_ObjCGraftCenter::shared().lock();
    if (!objcgraft::_ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        [self enumerateObjectsAtIndexes:indices options:NULL usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            objcgraft::_ObjCGraftCenter::shared().objectWillRemoveKeyValueObserver(obj, observer, keyPath, context);
        }];
    }
    (* _kNSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext)(self, _cmd, observer, indices, keyPath, context);
    if (!objcgraft::_ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        [self enumerateObjectsAtIndexes:indices options:NULL usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            objcgraft::_ObjCGraftCenter::shared().objectDidRemoveKeyValueObserver(obj, observer, keyPath, context);
        }];
    }
    objcgraft::_ObjCGraftCenter::shared().unlock();
}
