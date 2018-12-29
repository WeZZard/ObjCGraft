//
//  NSArray+_KVOSpecialTreatment.mm
//  ObjCGrafting
//
//  Created on 29/12/2018.
//

#import "NSArray+_KVOSpecialTreatment.h"

#import "ClassUtilities.h"
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
    _kNSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext = objcgrafting::Cls::replaceInstanceMethod(self, @selector(addObserver:toObjectsAtIndexes:forKeyPath:options:context:), &_NSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext);
    
    _kNSArrayRemoveObserverFromObjectsAtIndicesForKeyPath = objcgrafting::Cls::replaceInstanceMethod(self, @selector(removeObserver:fromObjectsAtIndexes:forKeyPath:), &_NSArrayRemoveObserverFromObjectsAtIndicesForKeyPath);
    
    _kNSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext = objcgrafting::Cls::replaceInstanceMethod(self, @selector(removeObserver:fromObjectsAtIndexes:forKeyPath:context:), &_NSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext);
}
@end

void _NSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext(NSArray * self, SEL _cmd, NSObject * observer, NSIndexSet * indices, NSString * keyPath, NSKeyValueObservingOptions options, void * context) {
    objcgrafting::_ObjCGraftCenter::shared().lock();
    if (!objcgrafting::_ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        [self enumerateObjectsAtIndexes:indices options:NULL usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            objcgrafting::_ObjCGraftCenter::shared().objectWillAddKeyValueObserver(self, observer, keyPath, options, context);
        }];
    }
    (* _kNSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext)(self, _cmd, observer, indices, keyPath, options, context);
    if (!objcgrafting::_ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        [self enumerateObjectsAtIndexes:indices options:NULL usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            objcgrafting::_ObjCGraftCenter::shared().objectDidAddKeyValueObserver(self, observer, keyPath, options, context);
        }];
    }
    objcgrafting::_ObjCGraftCenter::shared().unlock();
}

void _NSArrayRemoveObserverFromObjectsAtIndicesForKeyPath(NSArray * self, SEL _cmd, NSObject * observer, NSIndexSet * indices, NSString * keyPath) {
    objcgrafting::_ObjCGraftCenter::shared().lock();
    if (!objcgrafting::_ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        [self enumerateObjectsAtIndexes:indices options:NULL usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            objcgrafting::_ObjCGraftCenter::shared().objectWillRemoveKeyValueObserver(self, observer, keyPath);
        }];
    }
    (* _kNSArrayRemoveObserverFromObjectsAtIndicesForKeyPath)(self, _cmd, observer, indices, keyPath);
    if (!objcgrafting::_ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        [self enumerateObjectsAtIndexes:indices options:NULL usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            objcgrafting::_ObjCGraftCenter::shared().objectDidRemoveKeyValueObserver(self, observer, keyPath);
        }];
    }
    objcgrafting::_ObjCGraftCenter::shared().unlock();
}

void _NSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext(NSArray * self, SEL _cmd, NSObject * observer, NSIndexSet * indices, NSString * keyPath, void * context) {
    objcgrafting::_ObjCGraftCenter::shared().lock();
    if (!objcgrafting::_ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        [self enumerateObjectsAtIndexes:indices options:NULL usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            objcgrafting::_ObjCGraftCenter::shared().objectWillRemoveKeyValueObserver(self, observer, keyPath, context);
        }];
    }
    (* _kNSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext)(self, _cmd, observer, indices, keyPath, context);
    if (!objcgrafting::_ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        [self enumerateObjectsAtIndexes:indices options:NULL usingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
            objcgrafting::_ObjCGraftCenter::shared().objectDidRemoveKeyValueObserver(self, observer, keyPath, context);
        }];
    }
    objcgrafting::_ObjCGraftCenter::shared().unlock();
}
