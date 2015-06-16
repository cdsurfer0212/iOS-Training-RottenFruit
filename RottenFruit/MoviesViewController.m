//
//  MoviesViewController.m
//  RottenFruit
//
//  Created by Sean Zeng on 6/12/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "AppDelegate.h"
#import "ErrorView.h"
#import "MoviesViewController.h"
#import "MovieCell.h"
#import "MovieCollectionCell.h"
#import "Reachability.h"
#import "ViewController.h"
#import <SVProgressHUD.h>
#import <UIImageView+AFNetworking.h>


@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property BOOL isFiltered;
//@property (strong, nonatomic) ErrorView *errorView;
@property (strong, nonatomic) NSArray *movies;
//@property (strong, nonatomic) NSString *apiURLString;
@property (strong, nonatomic) NSMutableArray *filteredMovies;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

- (IBAction)onSwitchLayout:(id)sender;

@end

@implementation MoviesViewController
@synthesize isFiltered, filteredMovies;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSLog(@"MoviesViewController viewDidLoad");
    
    self.searchBar.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    
    // 初始化完再做?
    //self.collectionView.dataSource = self;
    //self.collectionView.delegate = self;
    
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MyMovieCell"];

    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.4]];
    [SVProgressHUD setForegroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
    [SVProgressHUD setRingThickness:4];
    //[SVProgressHUD show];
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
    
    if (self.apiURLString == nil)
        self.apiURLString = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=us";
    [self getData];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh..."];
    [self.refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    
    //UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:self.tableView.style];
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    tableViewController.refreshControl = self.refreshControl;
    //[self addChildViewController:tableViewController];
    
    self.errorView = [[ErrorView alloc] init];
    CGRect frame = self.errorView.errorView.frame;
    frame.origin.y = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    [self.errorView.errorView setFrame:frame];
    [self.view addSubview:self.errorView.errorView];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.moviesViewController = self;
    
    /* move to TabBarController
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:1 green:0.8 blue:0 alpha:1];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f], NSForegroundColorAttributeName:[UIColor colorWithRed:1 green:0.8 blue:0 alpha:1]} forState:UIControlStateSelected];

    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f], NSForegroundColorAttributeName:[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1]} forState:UIControlStateNormal];
    */
    
    //UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    //[self.view addGestureRecognizer:tapGestureRecognizer];
    
    CGRect searchBarFrame = self.searchBar.frame;
    [self.searchBar setFrame:CGRectMake(searchBarFrame.origin.x - 1, searchBarFrame.origin.y - 1, searchBarFrame.size.width, searchBarFrame.size.height + 1)];
    self.searchBar.layer.borderWidth = 0;
    self.searchBar.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isFiltered == YES) {
        //NSLog(@"%d", filteredMovies.count);
        //NSLog(@"%d", self.filteredMovies.count);
        return filteredMovies.count;
    }
    else {
        return self.movies.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [[UITableViewCell alloc] init];
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyMovieCell" forIndexPath:indexPath];
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyMovieCell" forIndexPath:indexPath];
    NSDictionary *movie = [[NSDictionary alloc] init];
    if (isFiltered == YES) {
        movie = filteredMovies[indexPath.row];
    }
    else {
        movie = self.movies[indexPath.row];
    }
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"synopsis"];
    
    //NSString *posterURLString = [movie valueForKeyPath:@"posters.thumbnail"];
    //[cell.posterView setImageWithURL:[NSURL URLWithString:posterURLString]];
    
    NSString *thumbnailImageUrlString = [movie objectForKey:@"posters"][@"thumbnail"];
    NSString *originalImageUrlString = [ViewController convertPosterUrlStringToHighRes:[movie objectForKey:@"posters"][@"original"]];
    NSURL *thumbnailImageUrl = [[NSURL alloc] initWithString:thumbnailImageUrlString];
    NSURL *originalImageUrl = [[NSURL alloc] initWithString:originalImageUrlString];
    
    NSURLRequest *thumbnailImageRequest = [NSURLRequest requestWithURL:thumbnailImageUrl];
    NSURLRequest *originalImageRequest = [NSURLRequest requestWithURL:originalImageUrl];
    
    MovieCell *weakCell = cell;
    [cell.posterView setImageWithURLRequest:thumbnailImageRequest placeholderImage:nil
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            MovieCell *firstStrongCell = weakCell;
                                        
            [UIView transitionWithView:firstStrongCell.posterView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^{
                    firstStrongCell.posterView.image = image;
                }
                completion:nil
            ];
                                        
            [firstStrongCell.posterView setImageWithURLRequest:originalImageRequest placeholderImage:nil
                success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    MovieCell *secondStrongCell = weakCell;
                    [UIView transitionWithView:secondStrongCell.posterView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            secondStrongCell.posterView.image = image;
                        }
                        completion:nil
                    ];
                }
                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    NSLog(@"Failed to retrieve orignal image: %@", error);
                }
            ];
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"Failed to retrieve thumbnail image: %@", error);
        }
    ];
    
    
    //cell.textLabel.text = [NSString stringWithFormat:@"Row %ld", (long)indexPath.row];
    //NSLog(@"Row %ld", (long)indexPath.row);
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getData {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.apiURLString]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError != nil) {
            [self.errorView showError];
        }
        
        //id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        //NSArray *movies = dict[@"movies"];
        //NSDictionary *firstMovie = movies[0];
        //NSLog(@"%@", firstMovie);
        
        self.movies = dict[@"movies"];
        [self.tableView reloadData];
        
        [self.refreshControl endRefreshing];
        [SVProgressHUD dismiss];
        [self.errorView dismissError];
    }];
}

- (void)refreshData: (UIRefreshControl*)refreshControl {
    NSLog(@"Refreshing Data!!!");
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm:ss"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]];
    
    //refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    //[refreshControl setTintColor:[UIColor colorWithRed:1 green:0.8 blue:0 alpha:1]];
    
    [NSThread sleepForTimeInterval:0.5];
    [self getData];
}

- (IBAction)onSwitchLayout:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegmentIndex = segmentedControl.selectedSegmentIndex;
    
    [self.contentView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    if (selectedSegmentIndex == 1) {
        if (self.collectionView == nil) {
            //[[[NSBundle mainBundle] loadNibNamed:@"MovieCollectionCell" owner:[MovieCollectionCell class] options:nil] objectAtIndex:0];
            //[[[NSBundle mainBundle] loadNibNamed:@"MovieCollectionCell" owner:self options:nil] objectAtIndex:0];
            
            //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MyMovieCollectionCell"];
            //[self.collectionView registerClass:[MovieCollectionCell class] forCellWithReuseIdentifier:@"MyMovieCollectionCell"];
           
            self.collectionView = [[[NSBundle mainBundle] loadNibNamed:@"MoviesCollectionView" owner:self options:nil] firstObject];
            [self.collectionView registerNib:[UINib nibWithNibName:@"MovieCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"MyMovieCollectionCell"];
            
            self.collectionView.dataSource = self;
            self.collectionView.delegate = self;
        }
        
        [self.collectionView reloadData];
        [self.contentView addSubview:self.collectionView];
    }
    else {
        [self.tableView reloadData];
        [self.contentView addSubview:self.tableView];
    }
}


-(void)dismissKeyboard {
    //[self.searchBar resignFirstResponder];
    //[self.view endEditing:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    MovieCell *cell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *movie = self.movies[indexPath.row];
    ViewController *destinationVC = segue.destinationViewController;
    destinationVC.movie = movie;
    
    /*
    // It's not working because destinationVC is not ready.
    destinationVC.titleLabel.text = movie[@"title"];
    destinationVC.synopsisLabel.text = movie[@"synopsis"];
    NSString *posterURLString = [movie valueForKeyPath:@"posters.detailed"];
    posterURLString = [self convertPosterUrlStringToHighRes:posterURLString];
    [destinationVC.posterView setImageWithURL:[NSURL URLWithString:posterURLString]];
    */
}

#pragma mark - UISearchBarDelegate methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        isFiltered = YES;
        filteredMovies = [[NSMutableArray alloc] init];
        for (NSDictionary *movie in self.movies) {
            NSString *title = movie[@"title"];
            NSRange range = [title rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (range.location != NSNotFound) {
                [filteredMovies addObject:movie];
            }
        }
    }
    else {
        isFiltered = NO;
    }
    
    if (self.segmentedControl.selectedSegmentIndex == 1) {
        [self.collectionView reloadData];

        [self.contentView addSubview:self.collectionView];
    }
    else {
        [self.tableView reloadData];
        
        [self.contentView addSubview:self.tableView];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - UICollectionViewDataSource methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (isFiltered == YES) {
        return filteredMovies.count;
    }
    else {
        return self.movies.count;
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyMovieCollectionCell" forIndexPath:indexPath];
    
    NSDictionary *movie = [[NSDictionary alloc] init];
    if (isFiltered == YES) {
        movie = filteredMovies[indexPath.row];
    }
    else {
        movie = self.movies[indexPath.row];
    }
    
    cell.titleLabel.text = movie[@"title"];
    //cell.synopsisLabel.text = movie[@"synopsis"];
    
    NSString *posterURLString = [ViewController convertPosterUrlStringToHighRes:[movie valueForKeyPath:@"posters.original"]];
    [cell.posterView setImageWithURL:[NSURL URLWithString:posterURLString]];
    
    //cell.layer.borderWidth = 1.0;
    //[cell.layer setBorderColor:[UIColor colorWithRed:1 green:0.8 blue:0 alpha:1].CGColor];
    
    cell.criticsScoreLabel.text = [[movie valueForKeyPath:@"ratings.critics_score"] stringValue];
    
    cell.mpaaRatingLabel.text = movie[@"mpaa_rating"];
    cell.mpaaRatingLabel.textAlignment = NSTextAlignmentCenter;
    cell.mpaaRatingLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.mpaaRatingLabel.layer.borderWidth = 0.3;
    cell.mpaaRatingLabel.layer.cornerRadius = 4.0;
    //[self.mpaaRatingLabel.layer setMasksToBounds:YES];
    
    cell.runtimeLabel.text = [[movie[@"runtime"] stringValue] stringByAppendingString:@"m"];
    
    return cell;
}

#pragma mark - UISearchBarDelegate methods
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.segmentedControl.hidden = TRUE;
    
    searchBar.showsCancelButton = YES;
    
    //change cancel button style
    UIButton *cancelButton;
    UIView *topView = searchBar.subviews[0];
    for (UIView *subView in topView.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
            cancelButton = (UIButton*)subView;
        }
    }
    if (cancelButton) {
        //[cancelButton setTitle:@"Hi" forState:UIControlStateNormal];
        cancelButton.tintColor = [UIColor colorWithRed:1 green:0.8 blue:0 alpha:1];
    }
    
    CGRect newSearchBarFrame = searchBar.frame;
    newSearchBarFrame.size.width = 320;
    [searchBar setFrame:newSearchBarFrame];

    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    self.segmentedControl.hidden = NO;
    
    searchBar.showsCancelButton = NO;
    
    CGRect newSearchBarFrame = searchBar.frame;
    newSearchBarFrame.size.width = 232;
    [searchBar setFrame:newSearchBarFrame];
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.segmentedControl.hidden = NO;
    
    searchBar.showsCancelButton = NO;
    
    CGRect newSearchBarFrame = searchBar.frame;
    newSearchBarFrame.size.width = 232;
    [searchBar setFrame:newSearchBarFrame];
    [searchBar resignFirstResponder];
}

@end
