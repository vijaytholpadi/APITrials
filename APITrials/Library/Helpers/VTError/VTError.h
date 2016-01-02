//
//  VTError.h
//  Mobmerry
//
//  Created by Vijay Tholpadi on 12/9/15.
//  Copyright © 2015 InteractionOne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTError : NSObject
@property (nonatomic, assign) NSDictionary *errorDictionary;
@property (nonatomic, retain) NSError * error;
@end
