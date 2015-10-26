//
//  DataSource.h
//  image3d
//
//  Created by igorbizi@mail.ru on 4/15/15.
//  Copyright (c) 2015 Igor Bizi Mineev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataSource : NSObject

@property (nonatomic) int count;
+ (instancetype)sharedManager;
- (void)addImage:(UIImage *)image;
- (NSArray *)getDataSource;
- (void)clear;
@end
