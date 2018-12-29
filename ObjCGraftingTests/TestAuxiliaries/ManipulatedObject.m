//
//  ManipulatedObject.m
//  ObjCGrafting
//
//  Created by WeZZard on 01/04/2017.
//
//

#import "ManipulatedObject.h"

static NSMutableDictionary * _mutableAccessRecords = nil;

@interface ManipulatedObject()
@property (nonatomic, class, strong) NSMutableDictionary * mutableAccessRecords;
@property (nonatomic, strong) NSMutableDictionary * mutableAccessRecords;
@end

@implementation ManipulatedObject
@synthesize intValue = _intValue;
@synthesize mutableAccessRecords = _mutableAccessRecords;

- (NSDictionary<NSString *,NSString *> *)accessRecords {
    return [self.mutableAccessRecords copy];
}

+ (NSDictionary<NSString *,NSString *> *)accessRecords {
    return [self.mutableAccessRecords copy];
}

- (NSMutableDictionary *)mutableAccessRecords
{
    if (_mutableAccessRecords == nil) {
        _mutableAccessRecords = [[NSMutableDictionary alloc] init];
    }
    return _mutableAccessRecords;
}

- (void)setMutableAccessRecords:(NSMutableDictionary *)mutableAccessRecords
{
    _mutableAccessRecords = mutableAccessRecords;
}

+ (NSMutableDictionary *)mutableAccessRecords {
    if (_mutableAccessRecords == nil) {
        _mutableAccessRecords = [[NSMutableDictionary alloc] init];
    }
    return _mutableAccessRecords;
}

+ (void)setMutableAccessRecords:(NSMutableDictionary *)mutableAccessRecords {
    _mutableAccessRecords = mutableAccessRecords;
}

- (void)accessFromSelector:(SEL)selector withName:(NSString *)name
{
    self.mutableAccessRecords[NSStringFromSelector(selector)] = name;
}

+ (void)accessFromSelector:(SEL)selector withName:(NSString *)name {
    self.mutableAccessRecords[NSStringFromSelector(selector)] = name;
}

- (void)clearAccessRecords
{
    [self.mutableAccessRecords removeAllObjects];
}

+ (void)clearAccessRecords {
    [self.mutableAccessRecords removeAllObjects];
}

- (NSInteger)intValue
{
    [self accessFromSelector:_cmd withName:[ManipulatedObject description]];
    return _intValue;
}

- (void)setIntValue:(NSInteger)intValue
{
    [self accessFromSelector:_cmd withName:[ManipulatedObject description]];
    _intValue = intValue;
}

- (void)parentInstanceMethod
{
    [self accessFromSelector:_cmd withName:[ManipulatedObject description]];
}

+ (void)parentClassMethod
{
    [self accessFromSelector:_cmd withName:[ManipulatedObject description]];
}

- (void)childInstanceMethod
{
    [self accessFromSelector:_cmd withName:[ManipulatedObject description]];
}

+ (void)childClassMethod
{
    [self accessFromSelector:_cmd withName:[ManipulatedObject description]];
}
@end
