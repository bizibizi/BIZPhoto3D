//
//  CameraManager.h
//  SilentCamera
//
//  Created by IgorBizi@mail.ru on 2015/05/05.
//  Copyright (c) 2015 IgorBizi@mail.ru. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;


@interface CameraManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

+ (instancetype)sharedManager;
- (void)takePhoto;
- (void)stop;
@end
