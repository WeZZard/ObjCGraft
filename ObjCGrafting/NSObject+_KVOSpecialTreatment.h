//
//  NSObject+_KVOSpecialTreatment.h
//  ObjCGrafting
//
//  Created on 29/12/2018.
//

#ifndef NSObject__KVOSpecialTreatment_h
#define NSObject__KVOSpecialTreatment_h

#import <Foundation/Foundation.h>

typedef void NSObjectAddObserverForKeyPathOptionsContext (NSObject *, SEL, NSObject *, NSString *, NSKeyValueObservingOptions, void *);
typedef void NSObjectRemoveObserverForKeyPath (NSObject *, SEL, NSObject *, NSString *);
typedef void NSObjectRemoveObserverForKeyPathContext (NSObject *, SEL, NSObject *, NSString *, void *);

FOUNDATION_EXPORT NSObjectAddObserverForKeyPathOptionsContext * _kNSObjectAddObserverForKeyPathOptionsContext;
FOUNDATION_EXPORT NSObjectRemoveObserverForKeyPath * _kNSObjectRemoveObserverForKeyPath;
FOUNDATION_EXPORT NSObjectRemoveObserverForKeyPathContext * _kNSObjectRemoveObserverForKeyPathContext;

#endif /* NSObject__KVOSpecialTreatment_h */
