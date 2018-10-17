//
//  GraftableObject.h
//  ObjCGrafting
//
//  Created by WeZZard on 22/10/2016.
//
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol GraftTable <NSObject>
@property NSInteger intValue;
- (void) fatherInstanceMethod;
+ (void) fatherClassMethod;
@end

@protocol GraftTableExpanded <GraftTable>
- (void) childInstanceMethod;
+ (void) childClassMethod;
@end

@interface GraftableObject: NSObject<GraftTableExpanded>
@property (nonatomic, class, readonly, copy) NSDictionary<NSString *, NSString *> * accessRecords;
@property (nonatomic, readonly, copy) NSDictionary<NSString *, NSString *> * accessRecords;

- (void)clearAccessRecords;
+ (void)clearAccessRecords;

@property NSInteger intValue;
- (void) fatherInstanceMethod;
+ (void) fatherClassMethod;

- (void) childInstanceMethod;
+ (void) childClassMethod;
@end

@interface GraftImplSource: GraftableObject
@end

NS_ASSUME_NONNULL_END
