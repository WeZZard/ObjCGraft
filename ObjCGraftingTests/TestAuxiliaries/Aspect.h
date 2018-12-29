//
//  Aspect.h
//  ObjCGrafting
//
//  Created on 29/12/2018.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol Aspect <NSObject>
@property NSInteger intValue;
- (void) parentInstanceMethod;
+ (void) parentClassMethod;
@end

NS_ASSUME_NONNULL_END
