//
//  _ObjCKeyValueObservationRecordList.mm
//  ObjCGraft
//
//  Created on 29/12/2018.
//

#import "_ObjCKeyValueObservationRecordList.h"

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
