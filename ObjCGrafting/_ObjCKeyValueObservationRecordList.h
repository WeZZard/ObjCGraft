//
//  _ObjCKeyValueObservationRecordList.h
//  ObjCGrafting
//
//  Created on 29/12/2018.
//

#import <Foundation/Foundation.h>
#import "_ObjCGraftInternal.h"
#import "_ObjCKeyValueObservationRecord.h"

#include <unordered_map>

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
