//
//  showImageViewController.h
//  demoOCR
//
//  Created by o.lytvynov-bogdanov on 29.06.16.
//  Copyright © 2016 o.lytvynov-bogdanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface takePictureViewController : UIViewController <UIGestureRecognizerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) id parent;

@end
