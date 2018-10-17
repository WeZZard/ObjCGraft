//
//  GraftableObject.m
//  ObjCGrafting
//
//  Created by WeZZard on 01/04/2017.
//
//

#import "GraftableObject.h"

static NSMutableDictionary * _mutableAccessRecords = nil;

@interface GraftableObject()
@property (nonatomic, class, strong) NSMutableDictionary * mutableAccessRecords;
@property (nonatomic, strong) NSMutableDictionary * mutableAccessRecords;
- (void)accessFromSelector:(SEL)selector withName:(NSString *)name;
+ (void)accessFromSelector:(SEL)selector withName:(NSString *)name;
@end

@implementation GraftableObject
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
    [self accessFromSelector:_cmd withName:[GraftableObject description]];
    return _intValue;
}

- (void)setIntValue:(NSInteger)intValue
{
    [self accessFromSelector:_cmd withName:[GraftableObject description]];
    _intValue = intValue;
}

- (void)fatherInstanceMethod
{
    [self accessFromSelector:_cmd withName:[GraftableObject description]];
}

+ (void)fatherClassMethod
{
    [self accessFromSelector:_cmd withName:[GraftableObject description]];
}

- (void)childInstanceMethod
{
    [self accessFromSelector:_cmd withName:[GraftableObject description]];
}

+ (void)childClassMethod
{
    [self accessFromSelector:_cmd withName:[GraftableObject description]];
}
@end

@implementation GraftImplSource
- (NSInteger)intValue
{
    [self accessFromSelector:_cmd withName:[GraftImplSource description]];
    return 0;
}

- (void)fatherInstanceMethod
{
    [self accessFromSelector:_cmd withName:[GraftImplSource description]];
}

+ (void)fatherClassMethod
{
    [self accessFromSelector:_cmd withName:[GraftImplSource description]];
}

- (void)childInstanceMethod
{
    [self accessFromSelector:_cmd withName:[GraftImplSource description]];
}

+ (void)childClassMethod
{
    [self accessFromSelector:_cmd withName:[GraftImplSource description]];
}
@end
