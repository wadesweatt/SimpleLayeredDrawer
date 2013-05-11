//
//  RVPVPMask.h
//  SimpleLayeredDrawer
//
//  Created by Wade Sweatt on 1/23/13.
//  Copyright (c) 2013 J. Wade Sweatt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RVPathGroup : NSObject <NSCopying>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *paths;

+ (RVPathGroup *) group;

@end
