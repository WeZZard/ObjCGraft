//
//  _ObjCKeyValueObservationRecord.mm
//  ObjCGraft
//
//  Created on 29/12/2018.
//

#import "_ObjCKeyValueObservationRecord.h"

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
