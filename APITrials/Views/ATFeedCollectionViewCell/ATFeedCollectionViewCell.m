//
//  ATFeedCollectionViewCell.m
//  APITrials
//
//  Created by Vijay Tholpadi on 1/1/16.
//  Copyright © 2016 TheGeekProjekt. All rights reserved.
//

#import "ATFeedCollectionViewCell.h"

@implementation ATFeedCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [self.layer setBorderWidth:1.0f];
    [self.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
}

@end
