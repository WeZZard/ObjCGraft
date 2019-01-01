# Introduction

[![Build Status](https://travis-ci.com/WeZZard/ObjCGrafting.svg?branch=master)](https://travis-ci.com/WeZZard/ObjCGrafting)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

ObjCGrafting is a framework eases pain of implementing aspect-oriented
programming in Objective-C/Swift.

It is implemented with is-a swizzle and works with KVO, which is also
implemented with is-a swizzle.

It introduced a protocol-implementation pair to help you manage your
aspect-oriented code.

## Example

You need three things to implement aspect-oriented programming in
Objective-C/Swift with ObjCGrafting.

- An Objective-C based object: the object which contains the "aspect" to
  be manipulated with.
- An Objective-C protocol: the protocol defines the "aspect" to be
  manipulated with.
- A class adopts to the previous Objective-C protocol: the class
  implements the "aspect".

For example, if you want to add some behavior, such as printing "Foo"
after `viewDidLoad` in any instance of type of `UIViewController` without
subclassing, you can write following code:

First, you need to define the "aspect" to be "manipulated" with.

MyViewControllerAspect.h

```objc
@protocol MyViewControllerAspect<NSObject>
- (void)viewDidLoad;
@end
```

Then, you need to implement this "aspect" on a class. This is recommended
to be done in Objective-C, because you don't have to take complex
compile-time resolving into consideration when coding with Objective-C.

MyViewController.h

```objc
#import <UIKit/UIKit.h>

@interface MyViewController: UIViewController<MyViewControllerAspect>
@end
```

MyViewController.m

```objc
#import "MyViewController.h"

@implementation MyViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Foo");
}
@end
```

Last, you need to graft the implementation defined by the "aspect" from
the previously defined class to another.

Objective-C

```objc
UIViewController * viewController = [UIViewController alloc] init];
object_graftImplemenationOfProtocolFromClass(viewController, @protocol(MyViewControllerAspect), [MyViewController class]);
```

Swift

```swift
let viewController = UIViewController()
ObjCGraftImplementation(of: MyViewControllerAspect.self, from: MyViewController.self, to: viewController)
```

Now, your `viewController` object can log "Foo" when the `viewDidLoad` was
called.

## Wiki

- [Concept behind ObjCGrafting](https://github.com/WeZZard/ObjCGrafting/wiki/Concept-behind-ObjCGrafting)
- [Understanding the Design](https://github.com/WeZZard/ObjCGrafting/wiki/Understanding-the-Design)

## Known Issues

- The process goes into an infinite loop when removing KVO observer
  unbalancedly.
