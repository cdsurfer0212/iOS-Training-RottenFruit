//
//  MovieCollectionCell.h
//  RottenFruit
//
//  Created by Sean Zeng on 6/13/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCollectionCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *criticsScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *mpaaRatingLabel;
@property (strong, nonatomic) IBOutlet UICollectionViewCell *movieCollectionCell;
@property (strong, nonatomic) IBOutlet UIImageView *posterView;
@property (strong, nonatomic) IBOutlet UILabel *runtimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end
