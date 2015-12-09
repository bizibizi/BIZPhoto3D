//
//  ViewController.m
//  image3d
//
//  Created by IgorBizi@mail.ru on 4/12/15.
//  Copyright (c) 2015 IgorBizi@mail.ru. All rights reserved.
//

#import "ViewController.h"
@import CoreMotion;
@import QuartzCore;
#import "DataSource.h"
#import "CameraManager.h"


int lastAccelerationX;
int lastRotationY;


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic) int yawOld;
@property (nonatomic) int yawNew;
@property (nonatomic) BOOL running;
//
@property (nonatomic, strong) NSTimer *framePerSec;
@property (nonatomic) CGFloat tikTime;
@end


@implementation ViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[DataSource sharedManager] clear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[DataSource sharedManager] clear];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    
    NSMutableArray *test = [NSMutableArray array];
    for (int i = 0; i <= 34; i++)
    {
        [test addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i]]];
    }
    self.dataSource = [test copy];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    lastAccelerationX = 0;
    lastRotationY = 0;
    [self updateUI];

    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.1f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.imageView.layer addAnimation:transition forKey:nil];
    
    [self loadGyro];
}

- (void)startTimer
{
    self.tikTime = 0;
    self.framePerSec = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tik) userInfo:nil repeats:YES];
}

- (void)stopTimer
{
    [self.framePerSec invalidate];
    self.framePerSec = nil;
}

- (void)tik
{
    self.tikTime += 0.5;
}


#pragma mark - Events


- (IBAction)sliderAction:(UISlider *)sender
{
    NSUInteger value = sender.value;
    if (self.dataSource.count) {
        self.imageView.image = [self.dataSource objectAtIndex:value];
        NSLog(@"%ld",(long)value);
    }
}

- (IBAction)startButton:(UIButton *)sender
{
    self.running = !self.running;
    if (self.running)
    {
        [[CameraManager sharedManager] takePhoto];
        [self startTimer];
    } else {
        [[CameraManager sharedManager] stop];
        self.dataSource = [[DataSource sharedManager] getDataSource];
        [self stopTimer];
        NSLog(@"fps %f",  self.dataSource.count/self.tikTime);

    }
    [self updateUI];
}

- (IBAction)clear:(UIButton *)sender
{
    [[DataSource sharedManager] clear];
    self.imageView.image = nil;
    self.dataSource = [NSArray array];
}

- (void)updateUI
{
    self.slider.minimumValue = 0;
    self.slider.maximumValue = self.dataSource.count - 1;
    self.slider.value = 0;
    
    if (self.dataSource.count)
    {
        self.imageView.image = [self.dataSource objectAtIndex:0];
    }
    
    if (self.running)
    {
        self.imageView.hidden = YES;
        self.slider.hidden = YES;
    } else {
        self.imageView.hidden = NO;
        self.slider.hidden = NO;
    }
    
    
}

- (void)loadGyro
{
    self.motionManager = [[CMMotionManager alloc] init];
    //Gyroscope
    if([self.motionManager isGyroAvailable])
    {
        /* Start the gyroscope if it is not active already */
        if([self.motionManager isGyroActive] == NO)
        {
            self.motionManager.accelerometerUpdateInterval = 0.1;
            self.motionManager.gyroUpdateInterval = 0.05;
            [self.motionManager startAccelerometerUpdates];
            
//            [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
//                                                     withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
//                                                         [self outputAccelertionData:accelerometerData.acceleration];
//                                                         if(error){
//                                                             
//                                                             NSLog(@"%@", error);
//                                                         }
//                                                     }];
            
            
            [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler:^(CMGyroData *gyroData, NSError *error) {
                                                [self outputRotationData:gyroData.rotationRate];
                                            }];
            
            /* Update us 2 times a second */
//            [self.motionManager setGyroUpdateInterval:1.0f / 2.0f];
            
            /* Add on a handler block object */
            
//            [self.motionManager
//             startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
//                                                toQueue:[NSOperationQueue currentQueue]
//                                            withHandler: ^(CMDeviceMotion *motion, NSError *error){
//                                        [self performSelectorOnMainThread:@selector(handleDeviceMotion:)
//                                                               withObject:motion
//                                                            waitUntilDone:YES];
//                                                           }];
            
            /* Receive the gyroscope data on this block */
//            [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue]
//                                            withHandler:^(CMGyroData *gyroData, NSError *error)
//             {
//                 NSString *x = [[NSString alloc] initWithFormat:@"%.02f",gyroData.rotationRate.x];
////                 NSLog(@"%@",x);
//                 NSString *y = [[NSString alloc] initWithFormat:@"%.02f",gyroData.rotationRate.y];
////                 NSLog(@"%@",y);
//                 NSString *z = [[NSString alloc] initWithFormat:@"%.02f",gyroData.rotationRate.z];
////                 NSLog(@"%@",z);
//             }];
        }
    }
    else
    {
        NSLog(@"Gyroscope not Available!");
    }
}


- (void)handleDeviceMotion:(CMDeviceMotion*)motion {
    
    CMAttitude *attitude = motion.attitude; //in radians
    //degrees = radians * (180 / M_PI)
    double yaw = attitude.yaw * (180 / M_PI); // рыскание - влево-вправо
    double pitch = attitude.pitch * (180 / M_PI); // тангаж - вверх-вниз
    double roll = attitude.roll * (180 / M_PI); //крен - из бока в бок

    
    double x = cos(yaw)*cos(pitch) * 360;
    double y = sin(yaw)*cos(pitch)  * 360;
    double z = sin(pitch)  * 360;
    
//    double x = sin(attitude.yaw);
//    double y = -(sin(attitude.pitch)*cos(attitude.yaw));
//    double z = -(cos(attitude.pitch)*cos(attitude.yaw));
//    int x = -cos(attitude.pitch) * sin(attitude.yaw);
//    int y = -sin(attitude.pitch);
//    int z = cos(attitude.pitch) * cos(attitude.yaw);
//    NSLog(@"%f",M_PI);
//    NSLog(@"%f",y);
//    NSLog(@"%f",z);

//    self.ya
//    if (!self.yawOld) {
//        self.yawOld = roll;
////    }
//    
//    if (self.yawOld > self.yawNew)
//    {
//        [self updateImageWithNextImage:NO];
//    } else {
//        [self updateImageWithNextImage:YES];
//    }
//    
//    self.yawNew = self.yawOld;
//    
////    [attitude multiplyByInverseOfAttitude:motion.attitude];
//    
////    NSLog(@"Yaw   %d ", yaw);
//    NSLog(@"Pitch %d ",pitch);
//    NSLog(@"Roll  %d ",roll);
    
    
//    image.transform = CGAffineTransformMakeRotation(-attitude.yaw);
}



//- (void)updateImageWithNextImage:(BOOL)next
//{
//    UIImage *image = self.imageView.image;
//    NSInteger index = [self.dataSource indexOfObject:image];
//    UIImage *newImage;
//    
//    if (next) {
//        index++;
//    } else {
//        index--;
//    }
//    
//    if (index >= self.dataSource.count) {
//        newImage = [self.dataSource lastObject];
//    } else if (index < 0) {
//        newImage = [self.dataSource firstObject];
//    } else {
//        newImage = self.dataSource[index];
//    }
//    
//    self.imageView.image = newImage;
//}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    if (self.dataSource.count)
    {
        int x = acceleration.x * 100;
        NSInteger index = [self.dataSource indexOfObject:self.imageView.image];
        
//        NSLog(@"%d", x);
        
        if(x > lastAccelerationX)
        {
            index++;
        } else if(x < lastAccelerationX) {
            index--;
        } else if(x == lastAccelerationX) {
        }
        
        if (index < self.dataSource.count && index >= 0)
        {
            UIImage *image = [self.dataSource objectAtIndex:index];
            self.imageView.image = image;
            lastAccelerationX = x;
        }
    }
}

- (void)outputRotationData:(CMRotationRate)rotation
{
    if (self.dataSource.count)
    {
//        double y = [[NSString stringWithFormat:@"%.4fg",rotation.y] doubleValue];
        int y = rotation.y * 100;
        NSLog(@"%d", y);
        NSInteger index = [self.dataSource indexOfObject:self.imageView.image];
        
        if (y != lastRotationY)
        {
            if(y > 0)
            {
                index++;
            } else if(y < 0) {
                index--;
            } else if(y == 0) {
            }
            
            if (index < self.dataSource.count && index >= 0)
            {
                UIImage *image = [self.dataSource objectAtIndex:index];
                self.imageView.image = image;
                lastRotationY = y;
                //            NSLog(@"%d", index);
            }
        }
        
 
    }
}
@end
