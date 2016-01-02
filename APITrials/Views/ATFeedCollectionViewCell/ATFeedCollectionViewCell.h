//
//  ATFeedCollectionViewCell.h
//  APITrials
//
//  Created by Vijay Tholpadi on 1/1/16.
//  Copyright © 2016 TheGeekProjekt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATFeedCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *storyThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *storyTitleLabel;

@end
