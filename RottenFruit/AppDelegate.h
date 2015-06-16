//
//  AppDelegate.h
//  RottenFruit
//
//  Created by Sean Zeng on 6/12/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoviesViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (weak, nonatomic) MoviesViewController *moviesViewController;

@end

