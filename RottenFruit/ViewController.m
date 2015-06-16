//
//  ViewController.m
//  RottenFruit
//
//  Created by Sean Zeng on 6/12/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "ViewController.h"
#import <UIImageView+AFNetworking.h>

@interface ViewController ()

@property (nonatomic) BOOL isOpen;

@property (nonatomic) CGRect originalDescriptionViewFrame;
@property (nonatomic) CGRect originalSynopsisLabelFrame;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"synopsis"];
    //[self.synopsisLabel sizeToFit];
    
    self.mpaaRatingLabel.text = self.movie[@"mpaa_rating"];
    self.mpaaRatingLabel.textAlignment = NSTextAlignmentCenter;
    self.mpaaRatingLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.mpaaRatingLabel.layer.borderWidth = 1.0;
    self.mpaaRatingLabel.layer.cornerRadius = 4.0;
    //[self.mpaaRatingLabel.layer setMasksToBounds:YES];
    
    self.runtimeLabel.text = [[self.movie[@"runtime"] stringValue] stringByAppendingString:@"m"];
    
    self.audienceScoreLabel.text = [[[self.movie valueForKeyPath:@"ratings.audience_score"] stringValue] stringByAppendingString:@"%"];
    self.criticsScoreLabel.text = [[[self.movie valueForKeyPath:@"ratings.critics_score"] stringValue]  stringByAppendingString:@"%"];

    //NSString *posterURLString = [self.movie valueForKeyPath:@"posters.detailed"];
    //posterURLString = [self convertPosterUrlStringToHighRes:posterURLString];
    //[self.posterView setImageWithURL:[NSURL URLWithString:posterURLString]];
    
    NSString *thumbnailImageUrlString = [self.movie objectForKey:@"posters"][@"thumbnail"];
    //NSString *originalImageUrlString = [thumbnailImageUrlString stringByReplacingOccurrencesOfString:@"_tmb.jpg" withString:@"_ori.jpg"];
    NSString *originalImageUrlString = [[self class] convertPosterUrlStringToHighRes:[self.movie objectForKey:@"posters"][@"detailed"]];
    NSURL *thumbnailImageUrl = [[NSURL alloc] initWithString:thumbnailImageUrlString];
    NSURL *originalImageUrl = [[NSURL alloc] initWithString:originalImageUrlString];
    
    NSURLRequest *thumbnailImageRequest = [NSURLRequest requestWithURL:thumbnailImageUrl];
    NSURLRequest *originalImageRequest = [NSURLRequest requestWithURL:originalImageUrl];
    
    UIImageView *weakPosterView = self.posterView;
    [self.posterView setImageWithURL:thumbnailImageUrl];
    [self.posterView setImageWithURLRequest:originalImageRequest placeholderImage:nil
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            UIImageView *strongPosterView = weakPosterView;
            
            [UIView transitionWithView:strongPosterView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^{
                    strongPosterView.image = image;
                }
                completion:nil];
        
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"Failed to retrieve original image: %@", error);
        }
    ];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.descriptionView addGestureRecognizer:tapGestureRecognizer];
    
    self.originalDescriptionViewFrame = self.descriptionView.frame;
    self.originalSynopsisLabelFrame = self.synopsisLabel.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Helper to workaround Rotten Tomatoes only giving low res images.
+ (NSString*)convertPosterUrlStringToHighRes:(NSString*)urlString {
    NSRange range = [urlString rangeOfString:@".*cloudfront.net/" options:NSRegularExpressionSearch];
    NSString *returnValue = urlString;
    if (range.length > 0) {
        returnValue = [urlString stringByReplacingCharactersInRange:range withString:@"https://content6.flixster.com/"];
    }
    return returnValue;
}

- (void)onTap:(UITapGestureRecognizer *)recognizer {
    //CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    
    int openDescriptionViewPositionY = 60;
    CGFloat mainScreenWidth = [UIScreen mainScreen].bounds.size.width;
    
    if (!self.isOpen) {
        self.isOpen = YES;
        
        CGRect startFrame = CGRectMake(0, self.descriptionView.frame.origin.y, mainScreenWidth, 0);
        CGRect endFrame = CGRectMake(0, openDescriptionViewPositionY , mainScreenWidth, self.descriptionView.frame.size.height);
        
        self.descriptionView.frame = startFrame;
        
        [UIView animateWithDuration:0.3
            animations:^{
                self.descriptionView.frame = endFrame;
                
                CGRect newSynopsisLabelFrame = self.originalSynopsisLabelFrame;
                newSynopsisLabelFrame.size.height = 500;
                [self.synopsisLabel setFrame:newSynopsisLabelFrame];
                [self.synopsisLabel sizeToFit];
            }
        ];
    }
    else {
        self.isOpen = NO;

        CGRect startFrame = CGRectMake(0, openDescriptionViewPositionY , mainScreenWidth, self.descriptionView.frame.size.height);
        CGRect endFrame = CGRectMake(0, self.originalDescriptionViewFrame.origin.y, mainScreenWidth, self.descriptionView.frame.size.height);
        
        self.descriptionView.frame = startFrame;
        
        [UIView animateWithDuration:0.3
            animations:^{
                self.descriptionView.frame = endFrame;
                
                CGRect newSynopsisLabelFrame = self.originalSynopsisLabelFrame;
                [self.synopsisLabel setFrame:newSynopsisLabelFrame];
            }
        ];
    }
}

@end
