//
//  NSObject+_KVOSpecialTreatment.mm
//  ObjCGraft
//
//  Created on 29/12/2018.
//

#import "NSObject+_KVOSpecialTreatment.h"

#import "_ObjCClass.h"
#import "_ObjCGraftCenter.h"

static NSObjectAddObserverForKeyPathOptionsContext _NSObjectAddObserverForKeyPathOptionsContext;
static NSObjectRemoveObserverForKeyPath _NSObjectRemoveObserverForKeyPath;
static NSObjectRemoveObserverForKeyPathContext _NSObjectRemoveObserverForKeyPathContext;

NSObjectAddObserverForKeyPathOptionsContext * _kNSObjectAddObserverForKeyPathOptionsContext = NULL;
NSObjectRemoveObserverForKeyPath * _kNSObjectRemoveObserverForKeyPath = NULL;
NSObjectRemoveObserverForKeyPathContext * _kNSObjectRemoveObserverForKeyPathContext = NULL;

@implementation NSObject(_KVOSpecialTreatment)
+ (void)load
{
    _kNSObjectAddObserverForKeyPathOptionsContext = objcgraft::_ObjCClass::replaceInstanceMethod(self, @selector(addObserver:forKeyPath:options:context:), &_NSObjectAddObserverForKeyPathOptionsContext);
    
    _kNSObjectRemoveObserverForKeyPath = objcgraft::_ObjCClass::replaceInstanceMethod(self, @selector(removeObserver:forKeyPath:), &_NSObjectRemoveObserverForKeyPath);
    
    _kNSObjectRemoveObserverForKeyPathContext = objcgraft::_ObjCClass::replaceInstanceMethod(self, @selector(removeObserver:forKeyPath:context:), &_NSObjectRemoveObserverForKeyPathContext);
}
@end

void _NSObjectAddObserverForKeyPathOptionsContext(NSObject * self, SEL _cmd, NSObject * observer, NSString * keyPath, NSKeyValueObservingOptions options, void * context) {
    objcgraft::_ObjCGraftCenter::shared().lock();
    if (!objcgraft::_ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        objcgraft::_ObjCGraftCenter::shared().objectWillAddKeyValueObserver(self, observer, keyPath, options, context);
    }
    (* _kNSObjectAddObserverForKeyPathOptionsContext)(self, _cmd, observer, keyPath, options, context);
    if (!objcgraft::_ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        objcgraft::_ObjCGraftCenter::shared().objectDidAddKeyValueObserver(self, observer, keyPath, options, context);
    }
    objcgraft::_ObjCGraftCenter::shared().unlock();
}

void _NSObjectRemoveObserverForKeyPath(NSObject * self, SEL _cmd, NSObject * observer, NSString * keyPath) {
    objcgraft::_ObjCGraftCenter::shared().lock();
    if (!objcgraft::_ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        objcgraft::_ObjCGraftCenter::shared().objectWillRemoveKeyValueObserver(self, observer, keyPath);
    }
    (* _kNSObjectRemoveObserverForKeyPath)(self, _cmd, observer, keyPath);
    if (!objcgraft::_ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        objcgraft::_ObjCGraftCenter::shared().objectDidRemoveKeyValueObserver(self, observer, keyPath);
    }
    objcgraft::_ObjCGraftCenter::shared().unlock();
}

void _NSObjectRemoveObserverForKeyPathContext(NSObject * self, SEL _cmd, NSObject * observer, NSString * keyPath, void * context) {
    // In iOS 11, `[NSObject -removeObserver:forKeyPath:context:]` was
    // routed to `[NSObject -removeOberver:forKeyPath:]`, which causes
    // duplicate removal to the records on the Graft Center. And such a
    // duplicate removal causes bad accesses. To prevent this duplicate
    // removal, `_ObjCGraftCenter::setObjectKVOActionDelegationDisabled()`
    // was made public and called after the outter delegation calls here.
    objcgraft::_ObjCGraftCenter::shared().lock();
    if (!objcgraft::_ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        objcgraft::_ObjCGraftCenter::shared().objectWillRemoveKeyValueObserver(self, observer, keyPath, context);
    }
    // Prevent duplicate removal.
    objcgraft::_ObjCGraftCenter::shared().setObjectKVOActionDelegationDisabled(true);
    (* _kNSObjectRemoveObserverForKeyPathContext)(self, _cmd, observer, keyPath, context);
    // Recover from preventting duplicate removal.
    objcgraft::_ObjCGraftCenter::shared().setObjectKVOActionDelegationDisabled(false);
    if (!objcgraft::_ObjCGraftCenter::shared().isObjectKVOActionDelegationDisabled()) {
        objcgraft::_ObjCGraftCenter::shared().objectDidRemoveKeyValueObserver(self, observer, keyPath, context);
    }
    objcgraft::_ObjCGraftCenter::shared().unlock();
}
