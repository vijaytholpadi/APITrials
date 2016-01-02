
//
//  MMNetworkRoutes.m
//  APITrials
//
//  Created by Vijay Tholpadi on 1/1/16.
//  Copyright © 2016 TheGeekProjekt. All rights reserved.
//

#import "ATNetworkRoutes.h"

static NSString *rootURL = @"https://www.reddit.com/r/";

@implementation ATNetworkRoutes


+(NSString*)getPicsFeedAPI {
    return [NSString stringWithFormat:@"%@%@", rootURL, @"pics.json"];
}


+(NSString*)getFunnyFeedAPI {
    return [NSString stringWithFormat:@"%@%@", rootURL, @"funny.json"];
}


+(NSString*)getGamingFeedAPI {
    return [NSString stringWithFormat:@"%@%@", rootURL, @"gaming.json"];
}


@end
