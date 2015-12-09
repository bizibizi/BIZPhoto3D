//
//  CameraManager.m
//  SilentCamera
//
//  Created by IgorBizi@mail.ru on 2015/05/05.
//  Copyright (c) 2015 IgorBizi@mail.ru. All rights reserved.
//

#import "CameraManager.h"
@import UIKit;
#import "DataSource.h"


#define kTimerInterval 0.01f


@interface CameraManager ()
@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) NSTimer *timer;
@property(readwrite) BOOL takePhotoFlag;
@end


@implementation CameraManager


+ (instancetype)sharedManager
{
    static id manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initializeCamera];
    }
    return self;
}

- (void)initializeCamera
{
    NSError *error;
    
    if (self.session) {
        [self.session stopRunning];
        self.session = nil;
    }
    
    self.session = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *captureDevice = nil;
    NSArray *devices = [AVCaptureDevice devices];
    
    for (AVCaptureDevice *device in devices)
    {
        if (device.position == AVCaptureDevicePositionBack) {
            captureDevice = device;
        }
    }
    
    if (!captureDevice) {
        return;
    }
    
    AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    
    if (error) {
        return;
    }
    
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [videoDataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey: @(kCMPixelFormat_32BGRA)}];
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    [self.session addInput:deviceInput];
    [self.session addOutput:videoDataOutput];
    
    [self.session startRunning];
}

- (void)takePhoto
{
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(changeTakePhotoFlag) userInfo:nil repeats:YES];
    }
}

- (void)changeTakePhotoFlag
{
    self.takePhotoFlag = YES;
//    [self stop];
}


- (void)stop
{
    [self.timer invalidate];
    self.timer = nil;
    self.takePhotoFlag = NO;
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
//    connection.supportsVideoStabilization = YES;
    if (self.takePhotoFlag) {
        UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
        NSLog(@"%lu", (unsigned long)[DataSource sharedManager].count);
        [[DataSource sharedManager] addImage:image];
       // UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingImageWithError:contextInfo:), nil);
        
        self.takePhotoFlag = NO;
        
//        if (self.images.count > 200)
//        {
//            [self.timer invalidate];
//            self.timer = nil;
//        }
    }
}

- (void)image:(UIImage *)image didFinishSavingImageWithError:(NSError *)error contextInfo:(void *)contextInfo
{
}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(buffer, 0);
    
    uint8_t *base = CVPixelBufferGetBaseAddress(buffer);
    size_t width = CVPixelBufferGetWidth(buffer);
    size_t height = CVPixelBufferGetHeight(buffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:UIImageOrientationRight];
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    return image;
}


@end
