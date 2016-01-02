//
//  ATStory.h
//  APITrials
//
//  Created by Vijay Tholpadi on 1/1/16.
//  Copyright © 2016 TheGeekProjekt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATStory : NSObject
@property (strong, nonatomic)NSString *storyTitle;
@property (strong, nonatomic)NSString *storyAuthor;
@property (strong, nonatomic)NSString *storyThumbnailURL;


+(NSMutableArray*)getStoriesArrayFromRawArray:(NSArray*)rawArray;
@end
