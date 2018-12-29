//
//  SubAspect.h
//  ObjCGrafting
//
//  Created on 29/12/2018.
//

#import "Aspect.h"

@protocol SubAspect <Aspect>
- (void) childInstanceMethod;
+ (void) childClassMethod;
@end

