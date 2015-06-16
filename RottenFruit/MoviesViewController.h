//
//  MoviesViewController.h
//  RottenFruit
//
//  Created by Sean Zeng on 6/12/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ErrorView.h"

@interface MoviesViewController : UIViewController

@property (strong, nonatomic) ErrorView *errorView;
@property (strong, nonatomic) NSString *apiURLString;

@end
