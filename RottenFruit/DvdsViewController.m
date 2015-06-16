//
//  DvdsViewController.m
//  RottenFruit
//
//  Created by Sean Zeng on 6/15/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "DvdsViewController.h"
#import "MoviesViewController.h"

@interface DvdsViewController ()

@end

@implementation DvdsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSLog(@"DvdsViewController viewDidLoad");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MoviesViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"MoviesViewController"];
    viewController.apiURLString = @"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=us";
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    
    // move to TabBarController
    // 都一樣
    //viewController.tabBarController.title = @"DVD Rentals";
    //self.tabBarController.title = @"DVD Rentals";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
