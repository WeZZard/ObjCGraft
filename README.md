# ObjCGrafting

ObjCGrafting is an Objective-C/Swift framework eases the pain of doing
aspect-oriented programming against Objective-C code.

## Features

- Manageable aspect-oriented programming strategy.
- Well co-existance with KVO.

## How to Do Aspect-Oriented Programming with ObjCGrafting

You need three things to do aspect-oriented programming in
Objective-C/Swift with ObjCGrafting.

- An Objective-C based object: the object which contains the "aspect" to
  be manipulated with.
- An Objective-C protocol: the protocol defines the "aspect" to be
  manipulated with.
- A class adopts to the previous Objective-C protocol: the class
  implements the "aspect".

First, you need to define the "aspect" to be "manipulated" with. For
example, if you want to add some behavior, such as printing "Foo" after
`viewDidLoad` in any instance of type of `UIViewController` without
subclassing, you can write following code:

MyViewController.h

```objc
#import <UIKit/UIKit.h>

@protocol MyViewControllerAspect
- (void)viewDidLoad;
@end

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
