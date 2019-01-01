# Introduction

[![Build Status](https://travis-ci.com/WeZZard/ObjCGrafting.svg?branch=master)](https://travis-ci.com/WeZZard/ObjCGrafting)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

ObjCGrafting is a framework eases pain of implementing aspect-oriented
programming in Objective-C/Swift.

It is implemented with is-a swizzle and works with KVO, which is also
implemented with is-a swizzle.

It introduced a protocol-implementation pair to help you manage your
aspect-oriented code.

## Grafting Implementations

You need three things to implement aspect-oriented programming in
Objective-C/Swift with ObjCGrafting.

- An Objective-C based protocol: the protocol defines the "aspect".
- An Objective-C based object: the object implements the "aspect".
- An object to "insert" the aspect's implementation.

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

## Removing Grafted Implementations

Objective-C

```objc
object_removeGraftedImplemenationOfProtocol(viewController, @protocol(MyViewControllerAspect), nil);

// or

object_removeAllGraftedImplemenations(viewController);
```

Swift

```swift
ObjCRemoveGraftedImplementation(of: MyViewControllerAspect.self, from: viewController)

// or

ObjCRemoveAllGraftedImplementations(from: viewController)
```

## Wiki

- [Concept behind ObjCGrafting](https://github.com/WeZZard/ObjCGrafting/wiki/Concept-behind-ObjCGrafting)
- [Understanding the Design](https://github.com/WeZZard/ObjCGrafting/wiki/Understanding-the-Design)

## Known Issues

- The process goes into an infinite loop when removing KVO observer
  unbalancedly.
