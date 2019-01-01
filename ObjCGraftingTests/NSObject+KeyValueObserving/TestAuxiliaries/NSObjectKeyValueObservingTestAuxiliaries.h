//
//  NSObjectKeyValueObservingTestAuxiliaries.h
//  ObjCGrafting
//
//  Created on 1/1/2019.
//

#import <Foundation/Foundation.h>

@interface NSObjectDerivedDummyModel : NSObject
@property (nonatomic, copy) NSString * name;

- (instancetype)initWithName:(NSString *)name;
@end
