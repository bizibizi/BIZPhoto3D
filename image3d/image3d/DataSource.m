//
//  DataSource.m
//  image3d
//
//  Created by igorbizi@mail.ru on 4/15/15.
//  Copyright (c) 2015 Igor Bizi Mineev. All rights reserved.
//

#import "DataSource.h"
@interface DataSource ()
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation DataSource

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc]init];
    }
    return _dataSource;
}

- (void)clear
{
    self.count = 0;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    int count = 0;
    
    while (true) {
        NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"IM-%d.png", count]];
        BOOL fileExists = [fileManager fileExistsAtPath:imagePath];
        if (fileExists)
        {
            BOOL success = [fileManager removeItemAtPath:imagePath error:&error];
            if (!success)
                NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            break;
        }
        
        count++;
    }
  
}

+ (instancetype)sharedManager{
    
    static id manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)addImage:(UIImage *)image
{
//    [self.dataSource addObject:image];
    
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"IM-%d.png", self.count]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if (![imageData writeToFile:imagePath atomically:YES])
        {
            NSLog((@"Failed to cache image data to disk"));
        } else { }
    });
  
    self.count ++;
}

- (NSArray *)getDataSource
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath;
    for (int i = 0; i < self.count; i++)
    {
        imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"IM-%d.png", i]];
        NSData *data = [NSData dataWithContentsOfFile:imagePath];
        UIImage *image = [UIImage imageWithData:data];
        [self.dataSource addObject:image];

    }
    return self.dataSource;
}

@end
