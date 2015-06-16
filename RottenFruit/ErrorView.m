//
//  ErrorView.m
//  RottenFruit
//
//  Created by Sean Zeng on 6/14/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "ErrorView.h"
#import <NSString+FontAwesome.h>

@interface ErrorView ()

@property (strong, nonatomic) IBOutlet UILabel *errorIconLabel;
@property (strong, nonatomic) IBOutlet UILabel *errorTextLabel;
@property (nonatomic) BOOL isErrorState;

@end

@implementation ErrorView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isErrorState = NO;
        self.errorView.hidden = YES;
        
        //self.errorView = [[[NSBundle mainBundle] loadNibNamed:@"ErrorView" owner:self options:nil] firstObject];
        [[NSBundle mainBundle] loadNibNamed:@"ErrorView" owner:self options:nil];
        
        [self.errorView addSubview:self.errorTextLabel];
    
        self.errorIconLabel.text = [NSString awesomeIcon:FaExfclamationTriangle];
        [self.errorView addSubview:self.errorIconLabel];
        
        [self addSubview:self.errorView];
    }
    return self;
}

- (void)dismissError {
    self.isErrorState = NO;
    
    [UIView animateWithDuration:0.3
        animations:^{
            self.errorView.alpha = 0.0;
        }
        completion:^(BOOL finished) {
            self.errorView.hidden = YES;
        }
    ];
}

- (void)showError {
    CGFloat mainScreenWidth = [UIScreen mainScreen].bounds.size.width;
    
    if (!self.isErrorState) {
        self.isErrorState = YES;
        
        CGRect startFrame = CGRectMake(0, self.errorView.frame.origin.y, mainScreenWidth, 0);
        CGRect endFrame = CGRectMake(0, self.errorView.frame.origin.y, mainScreenWidth, self.errorView.frame.size.height);
        
        self.errorView.frame = startFrame;
        self.errorView.hidden = NO;
    
        [UIView animateWithDuration:1.0
            animations:^{
                self.errorView.alpha = 0.7;
                self.errorView.frame = endFrame;
            }
        ];
    }
    else {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
        animation.additive = YES;
        animation.duration = 0.4;
        animation.keyPath = @"position.x";
        animation.keyTimes = @[ @0, @(1 / 6.0), @(3 / 6.0), @(5 / 6.0), @1 ];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        animation.values = @[ @0, @8, @-8, @4, @0 ];

        [self.errorIconLabel.layer addAnimation:animation forKey:@"wiggle"];
        [self.errorTextLabel.layer addAnimation:animation forKey:@"wiggle"];
    }
}

@end
