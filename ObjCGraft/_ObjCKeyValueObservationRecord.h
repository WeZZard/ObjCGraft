//
//  _ObjCKeyValueObservationRecord.h
//  ObjCGraft
//
//  Created on 29/12/2018.
//

#import <Foundation/Foundation.h>
#include <memory>
#include <unordered_set>

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
