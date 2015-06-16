//
//  MovieCollectionCell.m
//  RottenFruit
//
//  Created by Sean Zeng on 6/13/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "MovieCollectionCell.h"

@implementation MovieCollectionCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    // Initialization code
    NSLog(@"aaa");
    //[self init];
}

- (instancetype)init
{
    NSLog(@"bbb");
    self = [super init];
    if (self) {
        //[[NSBundle mainBundle] loadNibNamed:@"MovieCollectionCell" owner:self options:nil];
        //[self addSubview:self.movieCollectionCell];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    NSLog(@"ccc");
    self = [super initWithCoder:coder];
    if (self) {
        //[[NSBundle mainBundle] loadNibNamed:@"MovieCollectionCell" owner:self options:nil];
        //[self addSubview:self.movieCollectionCell];
    }
    return self;
}

@end
