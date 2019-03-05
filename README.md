[![Build Status](https://travis-ci.com/WeZZard/ObjCGraft.svg?branch=master)](https://travis-ci.com/WeZZard/ObjCGraft)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Introduction

An aspect-oriented programming framework in Objective-C/Swift. Implemented
with is-a swizzling and is KVO compliant.

You can use this framework to inject your custom implementation to any
method of any Objective-C object without affecting other instances of the
same type.

[中文](./使用說明.md)

To know the story about how I compose this framework, check
[A Story of Implementing Aspect-Oriented Programming in Objective-C and Swift](https://wezzard.com/post/2019/03/a-story-of-implementing-aspect-oriented-programming-in-objective-c-and-swift-8b92).

## Usage

### Grafting Implementations

You need three things to inject(graft) your custom implementation to a
method of an object.

- An Objective-C based protocol which defines the "aspect".
- An Objective-C based class which offers custom implementations of the
  aspect.
- An Objective-C object to inject(graft) with the custom implementations
  of the aspect.

For example, if you want to add some behavior, such as printing "Foo"
to `viewDidLoad` in an instance of type of `UIViewController` without
affecting other instances of the same type, you can do as below:

First, you need to define the "aspect" to be "manipulated" with.

MyViewControllerAspect.h

```objc
@protocol MyViewControllerAspect<NSObject>
- (void)viewDidLoad;
@end
```

Then, you need to implement this "aspect" on a class. This is recommended
to be done in Objective-C, because you don't have to take those complex
compile-time resolving in Swift into consideration when coding with
Objective-C.

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
the previously defined class to the object.

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

### Removing Grafted Implementations

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

## Known Issues

- The process goes into an infinite loop when removing KVO observer
  unbalancedly from an object and that object is grafted with some
  implementations.

## License

MIT
