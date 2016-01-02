//
//  ATStory.m
//  APITrials
//
//  Created by Vijay Tholpadi on 1/1/16.
//  Copyright © 2016 TheGeekProjekt. All rights reserved.
//

#import "ATStory.h"

@implementation ATStory


+(NSMutableArray*)getStoriesArrayFromRawArray:(NSArray*)rawArray {
    
    NSMutableArray *storiesArray = [NSMutableArray array];
    
    for (NSDictionary *childrenUnit in rawArray) {
        NSDictionary *dataUnit = [childrenUnit objectForKey:@"data"];
        
        if (![[dataUnit objectForKey:@"stickied"] boolValue]) {
            ATStory *storyUnit = [ATStory new];
            
            storyUnit.storyTitle = [dataUnit objectForKey:@"title"];
            storyUnit.storyAuthor = [dataUnit objectForKey:@"author"];
            storyUnit.storyThumbnailURL = [dataUnit objectForKey:@"thumbnail"];
            
            [storiesArray addObject:storyUnit];
        }
    }
    return storiesArray;
}
@end
