//
//  ManipulatedObject.h
//  ObjCGrafting
//
//  Created by WeZZard on 22/10/2016.
//
//

@import Foundation;

#import "SubAspect.h"

NS_ASSUME_NONNULL_BEGIN

@interface ManipulatedObject: NSObject<SubAspect>
@property (nonatomic, class, readonly, copy) NSDictionary<NSString *, NSString *> * accessRecords;
@property (nonatomic, readonly, copy) NSDictionary<NSString *, NSString *> * accessRecords;

- (void)clearAccessRecords;
+ (void)clearAccessRecords;

@property NSInteger intValue;
- (void) parentInstanceMethod;
+ (void) parentClassMethod;

- (void) childInstanceMethod;
+ (void) childClassMethod;

#pragma mark Recording Message Delivery
- (void)accessFromSelector:(SEL)selector withName:(NSString *)name;
+ (void)accessFromSelector:(SEL)selector withName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
