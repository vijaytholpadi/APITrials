//
//  ATFeedViewController.m
//  APITrials
//
//  Created by Vijay Tholpadi on 1/1/16.
//  Copyright © 2016 TheGeekProjekt. All rights reserved.
//

//VCs
#import "ATFeedViewController.h"

//Models
#import "ATNetworkRoutes.h"
#import "ATStory.h"

//Helper
#import "VTNetworkingHelper.h"

//Views
#import "ATFeedCollectionViewCell.h"

//Third Party framework
#import <UIImageView+WebCache.h>

static NSString *feedCollectionViewCellID = @"ATFeedCollectionViewCell";

@interface ATFeedViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>

//IBOutlets
@property (weak, nonatomic) IBOutlet UICollectionView *picsCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *funnyCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *gamingCollectionView;

//Properties
@property (strong, nonatomic) UICollectionView *collectionViewInContext;
@property (strong, nonatomic) UITabBarController *baseTabBarController;
@property (strong, nonatomic) NSMutableArray *storiesArray;
@property (strong, nonatomic) NSArray *filteredArray;
@property (assign, nonatomic) BOOL shouldShowSearchResults;
@property (strong, nonatomic) UILabel *noResultsFoundLabel;

@property (nonatomic) float searchBarBoundsY;
@property (nonatomic,strong) UISearchBar *searchBar;
@end

@implementation ATFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.storiesArray = [NSMutableArray array];
    
    self.baseTabBarController = (UITabBarController*)[self.navigationController parentViewController];
    
    //CollectionViews setup
    self.picsCollectionView.dataSource = self;
    self.picsCollectionView.delegate = self;
    self.funnyCollectionView.dataSource = self;
    self.funnyCollectionView.delegate = self;
    self.gamingCollectionView.dataSource = self;
    self.gamingCollectionView.delegate = self;
    
    UINib *feedCollectionViewCellNib = [UINib nibWithNibName:@"ATFeedCollectionViewCell" bundle:nil];
    
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    [self.picsCollectionView setCollectionViewLayout:flowLayout];
    [self.picsCollectionView registerNib:feedCollectionViewCellNib forCellWithReuseIdentifier:feedCollectionViewCellID];
    [self.funnyCollectionView setCollectionViewLayout:flowLayout];
    [self.funnyCollectionView registerNib:feedCollectionViewCellNib forCellWithReuseIdentifier:feedCollectionViewCellID];
    [self.gamingCollectionView setCollectionViewLayout:flowLayout];
    [self.gamingCollectionView registerNib:feedCollectionViewCellNib forCellWithReuseIdentifier:feedCollectionViewCellID];
    
    [self.picsCollectionView setContentInset:UIEdgeInsetsZero];
    [self.funnyCollectionView setContentInset:UIEdgeInsetsZero];
    [self.gamingCollectionView setContentInset:UIEdgeInsetsZero];
    
    [self loadFeed];
    [self addSearchBar];
    [self setupNoResultsFoundLabel];
}


- (void)loadFeed {
    int indexOfTab = (int)[[self.tabBarController viewControllers] indexOfObject:self.navigationController];
    
    NSString *networkRoute;
    
    switch (indexOfTab) {
        case 0: {
            self.title = @"Pics";
            self.collectionViewInContext = self.picsCollectionView;
            networkRoute = [ATNetworkRoutes getPicsFeedAPI];
            break;
        }
        case 1: {
            self.title = @"Funny";
            self.collectionViewInContext = self.funnyCollectionView;
            networkRoute = [ATNetworkRoutes getFunnyFeedAPI];
            break;
        }
        case 2: {
            self.title = @"Gaming";
            self.collectionViewInContext = self.gamingCollectionView;
            networkRoute = [ATNetworkRoutes getGamingFeedAPI];
            break;
        }
        default:
            break;
    }
    
    [[VTNetworkingHelper sharedInstance] performRequestWithPath:networkRoute withAuth:NO withRequestJSONSerialized:YES withCompletionHandler:^(VTNetworkResponse *response) {
        if (response.isSuccessful) {
            self.storiesArray = [ATStory getStoriesArrayFromRawArray:[[response.data objectForKey:@"data"] objectForKey:@"children"]];
            [self.collectionViewInContext reloadData];
        } else {
            
        }
    }];
}


-(void)viewDidLayoutSubviews {
    [self.noResultsFoundLabel setCenter:self.collectionViewInContext.center];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [self removeObservers];
}

- (void)setupNoResultsFoundLabel {
    self.noResultsFoundLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width - 20, 22.0f)];
    [self.noResultsFoundLabel setText:@"No Results Found"];
    [self.noResultsFoundLabel setFont:[UIFont fontWithName:@"Helvetica-Regular" size:16.0f]];
    [self.noResultsFoundLabel setCenter:self.collectionViewInContext.center];
    [self.noResultsFoundLabel setTextAlignment:NSTextAlignmentCenter];
    [self.noResultsFoundLabel setHidden:YES];
    [self.view addSubview:self.noResultsFoundLabel];
}

#pragma mark - UICollectionView datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.shouldShowSearchResults) {
        return [self.filteredArray count];
    } else {
        return [self.storiesArray count];
    }
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ATStory *currentStory;
    
    if (self.shouldShowSearchResults) {
        currentStory = [self.filteredArray objectAtIndex:indexPath.row];
    } else {
        currentStory = [self.storiesArray objectAtIndex:indexPath.row];
    }
    
    ATFeedCollectionViewCell *feedCollectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:feedCollectionViewCellID forIndexPath:indexPath];
    
    [feedCollectionViewCell.storyTitleLabel setText:currentStory.storyTitle];
    [feedCollectionViewCell.storyThumbnailImageView sd_setImageWithURL:[NSURL URLWithString:currentStory.storyThumbnailURL] placeholderImage:[UIImage imageNamed:@"placeholderImage"] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    return feedCollectionViewCell;
}


#pragma mark - UICollectionView delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}


#pragma mark - UICollectionView flow delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 140.0);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(self.searchBar.frame.size.height, 0, 0, 0);
}

- (void)searchForText:(NSString *)searchText {
    NSString *predicateFormat = @"storyTitle contains[cd] %@";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchText];
    
    self.filteredArray = [self.storiesArray filteredArrayUsingPredicate:predicate];
    
    if (![self.filteredArray count]) {
        [self.noResultsFoundLabel setHidden:NO];
    } else {
        [self.noResultsFoundLabel setHidden:YES];
    }
}


#pragma mark - search
- (void)filterContentForSearchText:(NSString*)searchText {
    [self searchForText:searchText];
    [self.collectionViewInContext reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // user did type something, check our datasource for text that looks the same
    if (searchText.length>0) {
        // search and reload data source
        self.shouldShowSearchResults = YES;
        [self filterContentForSearchText:searchText];
        [self.collectionViewInContext reloadData];
    }else{
        // if text length == 0
        // we will consider the searchbar is not active
        self.shouldShowSearchResults = NO;
        [self filterContentForSearchText:searchText];
        [self.noResultsFoundLabel setHidden:YES];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self cancelSearching];
    [self.collectionViewInContext reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.shouldShowSearchResults = YES;
    [self.view endEditing:YES];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // we used here to set self.searchBarActive = YES
    // but we'll not do that any more... it made problems
    // it's better to set self.searchBarActive = YES when user typed something
    [self.searchBar setShowsCancelButton:YES animated:YES];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    // this method is being called when search btn in the keyboard tapped
    // we set searchBarActive = NO
    // but no need to reloadCollectionView
    self.shouldShowSearchResults = NO;
    [self.searchBar setShowsCancelButton:NO animated:YES];
}
-(void)cancelSearching{
    self.shouldShowSearchResults = NO;
    [self.searchBar resignFirstResponder];
    self.searchBar.text  = @"";
    [self.noResultsFoundLabel setHidden:YES];
}


-(void)addSearchBar{
    if (!self.searchBar) {
        self.searchBarBoundsY = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0,self.searchBarBoundsY, [UIScreen mainScreen].bounds.size.width, 44)];
        self.searchBar.searchBarStyle       = UISearchBarStyleMinimal;
        self.searchBar.tintColor            = [UIColor redColor];
        self.searchBar.barTintColor         = [UIColor blackColor];
        self.searchBar.delegate             = self;
        self.searchBar.placeholder          = @"Search here";
        
        [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor blackColor]];
        
        // add KVO observer.. so we will be informed when user scroll colllectionView
        [self addObservers];
    }
    
    if (![self.searchBar isDescendantOfView:self.view]) {
        [self.view addSubview:self.searchBar];
    }
}

#pragma mark - observer
- (void)addObservers{
    [self.collectionViewInContext addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}


- (void)removeObservers{
    [self.collectionViewInContext removeObserver:self forKeyPath:@"contentOffset" context:Nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UICollectionView *)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"] && object == self.collectionViewInContext ) {
        self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x,
                                          self.searchBarBoundsY + ((-1* object.contentOffset.y)-self.searchBarBoundsY),
                                          self.searchBar.frame.size.width,
                                          self.searchBar.frame.size.height);
    }
}
@end