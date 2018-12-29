//
//  NSArray+_KVOSpecialTreatment.h
//  ObjCGrafting
//
//  Created on 29/12/2018.
//

#ifndef NSArray__KVOSpecialTreatment_h
#define NSArray__KVOSpecialTreatment_h

#import <Foundation/Foundation.h>

#pragma mark - Typedefs
typedef void NSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext (NSArray *, SEL, NSObject *, NSIndexSet *, NSString *, NSKeyValueObservingOptions, void *);
typedef void NSArrayRemoveObserverFromObjectsAtIndicesForKeyPath (NSArray *, SEL, NSObject *, NSIndexSet *, NSString *);
typedef void NSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext (NSArray *, SEL, NSObject *, NSIndexSet *, NSString *, void *);

#pragma mark - Constants
FOUNDATION_EXTERN NSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext * _kNSArrayAddObserverToObjectsAtIndicesForKeyPathOptionsContext;
FOUNDATION_EXTERN NSArrayRemoveObserverFromObjectsAtIndicesForKeyPath * _kNSArrayRemoveObserverFromObjectsAtIndicesForKeyPath;
FOUNDATION_EXTERN NSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext * _kNSArrayRemoveObserverFromObjectsAtIndicesForKeyPathContext;

#endif /* NSArray__KVOSpecialTreatment_h */
