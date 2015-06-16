//
//  ErrorView.h
//  RottenFruit
//
//  Created by Sean Zeng on 6/14/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ErrorView : UIView

@property (strong, nonatomic) IBOutlet UIView *errorView;

- (void)dismissError;
- (void)showError;

@end
