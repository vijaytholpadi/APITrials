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

@interface ATFeedViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

//IBOutlets
@property (weak, nonatomic) IBOutlet UICollectionView *picsCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *funnyCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *gamingCollectionView;

//Properties
@property (strong, nonatomic) UITabBarController *baseTabBarController;
@property (strong, nonatomic) NSMutableArray *storiesArray;
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
    
    [self loadFeed];
}



- (void)loadFeed {
    int indexOfTab = (int)[[self.tabBarController viewControllers] indexOfObject:self.navigationController];
    
    UICollectionView *collectionViewInContext;
    NSString *networkRoute;
    
    switch (indexOfTab) {
        case 0: {
            self.title = @"Pics";
            collectionViewInContext = self.picsCollectionView;
            networkRoute = [ATNetworkRoutes getPicsFeedAPI];
            break;
        }
        case 1: {
            self.title = @"Funny";
            collectionViewInContext = self.funnyCollectionView;
            networkRoute = [ATNetworkRoutes getFunnyFeedAPI];
            break;
        }
        case 2: {
            self.title = @"Gaming";
            collectionViewInContext = self.gamingCollectionView;
            networkRoute = [ATNetworkRoutes getGamingFeedAPI];
            break;
        }
        default:
            break;
    }
    
    [[VTNetworkingHelper sharedInstance] performRequestWithPath:networkRoute withAuth:NO withRequestJSONSerialized:YES withCompletionHandler:^(VTNetworkResponse *response) {
        if (response.isSuccessful) {
            self.storiesArray = [ATStory getStoriesArrayFromRawArray:[[response.data objectForKey:@"data"] objectForKey:@"children"]];
            [collectionViewInContext reloadData];
        } else {
            
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.storiesArray count];
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ATStory *currentStory = [self.storiesArray objectAtIndex:indexPath.row];
    
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

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//
//}
//
//
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}


//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
//
//}
//
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
//
//}


@end
