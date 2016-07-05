//
//  showImageViewController.m
//  demoOCR
//
//  Created by o.lytvynov-bogdanov on 29.06.16.
//  Copyright © 2016 o.lytvynov-bogdanov. All rights reserved.
//

#import "takePictureViewController.h"

@interface takePictureViewController ()
{
    AVCaptureSession *session;
}

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic) BOOL isUsingFrontFacingCamera;
@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, weak) IBOutlet UIView *previewView;
@property (nonatomic, strong) UIImage *tempImage;

@end

@implementation takePictureViewController


- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [self setupAVCapture];
    NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
    self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:detectorOptions];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [self updatePreviewFrame];
}

- (void)setupAVCapture
{
    NSError *error = nil;
    
    session = [[AVCaptureSession alloc] init];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        [session setSessionPreset:AVCaptureSessionPreset640x480];
    } else {
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    
    // Select a video device, make an input
    AVCaptureDevice *device;
    
    AVCaptureDevicePosition desiredPosition = AVCaptureDevicePositionBack;
    
    // find the front facing camera
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            device = d;
            self.isUsingFrontFacingCamera = YES;
            break;
        }
    }
    // fall back to the default camera.
    if( nil == device )
    {
        self.isUsingFrontFacingCamera = NO;
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    // get the input device
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if( !error ) {
        
        // add the input to the session
        if ( [session canAddInput:deviceInput] ){
            [session addInput:deviceInput];
        }
        
        
        // Make a video data output
        self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        
        // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
        NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
                                           [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        [self.videoDataOutput setVideoSettings:rgbOutputSettings];
        [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked
        
        // create a serial dispatch queue used for the sample buffer delegate
        // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
        // see the header doc for setSampleBufferDelegate:queue: for more information
        self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
        
        if ( [session canAddOutput:self.videoDataOutput] ){
            [session addOutput:self.videoDataOutput];
        }
        
        // get the output for doing face detection.
        [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
        
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
        self.previewLayer.backgroundColor = [[UIColor blackColor] CGColor];
        
        [self updatePreviewFrame];
        [session startRunning];
        
    }
    session = nil;
    if (error) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
                                                                                 message:[error localizedDescription]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        [self teardownAVCapture];
    }
}

- (AVCaptureVideoOrientation) videoOrientationFromCurrentDeviceOrientation {
    UIDeviceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (deviceOrientation == UIDeviceOrientationPortrait)
        return AVCaptureVideoOrientationPortrait;
    else if (deviceOrientation == UIDeviceOrientationLandscapeRight)
        return AVCaptureVideoOrientationLandscapeLeft;
    else if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
        return AVCaptureVideoOrientationLandscapeRight;
    else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
        return AVCaptureVideoOrientationPortraitUpsideDown;
    
    return UIDeviceOrientationFaceUp;
}

- (void) updatePreviewFrame
{
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.previewLayer.connection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];
    
    CALayer *rootLayer = [self.previewView layer];
    [rootLayer setMasksToBounds:YES];
    [self.previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:self.previewLayer];
}

- (NSNumber *) exifOrientation: (UIDeviceOrientation) orientation
{
    int exifOrientation;
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants.
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
    
    enum {
        PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
        PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
        PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
        PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
    };
    
    switch (orientation) {
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
            break;
        case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
            if (self.isUsingFrontFacingCamera)
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            else
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            if (self.isUsingFrontFacingCamera)
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            else
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            break;
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
        default:
            exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
            break;
    }
    return [NSNumber numberWithInt:exifOrientation];
}

// clean up capture setup
- (void)teardownAVCapture
{
    session = nil;
    self.videoDataOutput = nil;
    if (self.videoDataOutputQueue) {
        
        _videoDataOutputQueue = nil;
        //        		dispatch_release(self.videoDataOutputQueue);
    }
    [self.previewLayer removeFromSuperlayer];
    self.previewLayer = nil;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    //    connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    // get the image
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer
                                                      options:(__bridge NSDictionary *)attachments];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef myImage = [context
                          createCGImage:ciImage
                          fromRect:CGRectMake(0, 0,
                                              CVPixelBufferGetWidth(pixelBuffer),
                                              CVPixelBufferGetHeight(pixelBuffer))];
    
    _tempImage = [UIImage imageWithCGImage:myImage];
    CGImageRelease(myImage);
    //    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    //    if (deviceOrientation == UIDeviceOrientationPortrait)
    //        _tempImage.transform = CGAffineTransformMakeRotation(M_PI_2);
    //    else if (deviceOrientation == UIDeviceOrientationLandscapeRight)
    //        _tempImage.transform = CGAffineTransformMakeRotation(M_PI_2);
    //    else if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
    //        _tempImage.transform = CGAffineTransformMakeRotation(M_PI_2);
    //    else if (deviceOrientation == UIDeviceOrientationFaceUp)
    //        _tempImage.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    if (attachments) {
        CFRelease(attachments);
    }
    
    // make sure your device orientation is not locked.
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    
    NSDictionary *imageOptions = nil;
    
    imageOptions = [NSDictionary dictionaryWithObject:[self exifOrientation:curDeviceOrientation]
                                               forKey:CIDetectorImageOrientation];
    
    NSArray *features = [self.faceDetector featuresInImage:ciImage
                                                   options:imageOptions];
    
    // get the clean aperture
    // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
    // that represents image data valid for display.
    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CGRect cleanAperture = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self drawFaces:features forVideoBox:cleanAperture orientation:curDeviceOrientation];
    });
}

// find where the video box is positioned within the preview layer based on the video size and gravity
- (CGRect)videoPreviewBoxForGravity:(NSString *)gravity
                          frameSize:(CGSize)frameSize
                       apertureSize:(CGSize)apertureSize
{
    CGSize size = CGSizeZero;
    
    if ([self videoOrientationFromCurrentDeviceOrientation] == AVCaptureVideoOrientationPortraitUpsideDown || [self videoOrientationFromCurrentDeviceOrientation] == AVCaptureVideoOrientationPortrait)
    {
        size.width = apertureSize.height * frameSize.height / apertureSize.width;
        size.height = frameSize.height;
        if (size.height < size.width)
        {
            size.width = size.height  / apertureSize.height / apertureSize.width;
        }
    }
    else
    {
        size.width = frameSize.width;
        size.height = apertureSize.height * frameSize.width / apertureSize.width;
        if (size.width < size.height)
        {
            size.height = size.width  / (apertureSize.width / apertureSize.height);
        }
    }
    //    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    //    CGFloat viewRatio = frameSize.width / frameSize.height;
    //
    //    CGSize size = CGSizeZero;
    //    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
    //        if (viewRatio > apertureRatio) {
    //            size.width = frameSize.width;
    //            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
    //        } else {
    //            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
    //            size.height = frameSize.height;
    //        }
    //    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
    //        if (viewRatio > apertureRatio) {
    //            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
    //            size.height = frameSize.height;
    //        } else {
    //            size.width = frameSize.width;
    //            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
    //        }
    //    } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
    //        size.width = frameSize.width;
    //        size.height = frameSize.height;
    //    }
    
    CGRect videoBox;
    videoBox.size = size;
    if (size.width < frameSize.width)
        videoBox.origin.x = (frameSize.width - size.width) / 2;
    else
        videoBox.origin.x = (size.width - frameSize.width) / 2;
    
    if ( size.height < frameSize.height )
        videoBox.origin.y = (frameSize.height - size.height) / 2;
    else
        videoBox.origin.y = (size.height - frameSize.height) / 2;
    
    return videoBox;
}

- (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [_parent supportedInterfaceOrientations];
}

// called asynchronously as the capture output is capturing sample buffers, this method asks the face detector
// to detect features and for each draw the green border in a layer and set appropriate orientation
- (void)drawFaces:(NSArray *)features forVideoBox:(CGRect)clearAperture orientation:(UIDeviceOrientation)orientation
{
    NSArray *sublayers = [NSArray arrayWithArray:[self.previewLayer sublayers]];
    NSInteger sublayersCount = [sublayers count], currentSublayer = 0;
    NSInteger featuresCount = [features count], currentFeature = 0;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    // hide all the face layers
    for ( CALayer *layer in sublayers ) {
        if ( [[layer name] isEqualToString:@"FaceLayer"] )
            [layer setHidden:YES];
    }
    
    if ( featuresCount == 0 ) {
        [CATransaction commit];
        return; // early bail.
    }
    
    CGSize parentFrameSize = [self.previewView frame].size;
    NSString *gravity = [self.previewLayer videoGravity];
    //    BOOL isMirrored = [self.previewLayer isMirrored];
    CGRect previewBox = [self videoPreviewBoxForGravity:gravity
                                              frameSize:parentFrameSize
                                           apertureSize:clearAperture.size];
    
    for ( CIFaceFeature *ff in features ) {
        // find the correct position for the square layer within the previewLayer
        // the feature box originates in the bottom left of the video frame.
        // (Bottom right if mirroring is turned on)
        CGRect faceRect = [ff bounds];
        //        if (faceRect.size.width > faceRect.size.height)
        //            faceRect = CGRectMake(faceRect.origin.x, faceRect.origin.y, faceRect.size.height, faceRect.size.width);
        // flip preview width and height
        
        CGFloat widthScaleBy;
        CGFloat heightScaleBy;
        
        if ([self videoOrientationFromCurrentDeviceOrientation] == AVCaptureVideoOrientationPortraitUpsideDown || [self videoOrientationFromCurrentDeviceOrientation] == AVCaptureVideoOrientationPortrait)
        {
            CGFloat temp = faceRect.size.width;
            faceRect.size.width = faceRect.size.height;
            faceRect.size.height = temp;
            temp = faceRect.origin.x;
            faceRect.origin.x = faceRect.origin.y;
            faceRect.origin.y = temp;
            // scale coordinates so they fit in the preview box, which may be scaled
            widthScaleBy = previewBox.size.width / clearAperture.size.height;
            heightScaleBy = previewBox.size.height / clearAperture.size.width;
        }
        else
        {
            
            // scale coordinates so they fit in the preview box, which may be scaled
            widthScaleBy = previewBox.size.width / clearAperture.size.width;
            heightScaleBy = previewBox.size.height / clearAperture.size.height;
            //            float x = faceRect.origin.x;
            //            faceRect.origin.x = faceRect.origin.y;
            //            faceRect.origin.y = x;
            //            if (faceRect.size.width > faceRect.size.height)
            //            {
            //                if (faceRect.size.width / faceRect.size.height > clearAperture.size.width / clearAperture.size.height)
            //                {
            //                    faceRect.size.width = faceRect.size.height * (clearAperture.size.width / clearAperture.size.height);
            //                }
            //                else
            //                {
            //                    faceRect.size.height = faceRect.size.width  / (clearAperture.size.width / clearAperture.size.height);
            //                }
            //            }
            //            else
            //            {
            //                if (faceRect.size.height / faceRect.size.width > clearAperture.size.height / clearAperture.size.width)
            //                {
            //                    faceRect.size.height = faceRect.size.width * (clearAperture.size.height / clearAperture.size.width);
            //                }
            //                else
            //                {
            //                    faceRect.size.width = faceRect.size.height  / (clearAperture.size.height / clearAperture.size.width);
            //                }
            //            }
        }
        
        //        if ([self videoOrientationFromCurrentDeviceOrientation] == AVCaptureVideoOrientationPortraitUpsideDown || [self videoOrientationFromCurrentDeviceOrientation] == AVCaptureVideoOrientationPortraitUpsideDown)
        faceRect.size.width *= widthScaleBy;
        faceRect.size.height *= heightScaleBy;
        faceRect.origin.x *= widthScaleBy;
        faceRect.origin.y *= heightScaleBy;
        
        //        NSLog(@"%f - %f", previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2),
        //              previewBox.origin.y + previewBox.size.height - faceRect.size.height - (faceRect.origin.y * 2));
        
        if ([self videoOrientationFromCurrentDeviceOrientation] == AVCaptureVideoOrientationPortraitUpsideDown)
            faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2),
                                    previewBox.origin.y + previewBox.size.height - faceRect.size.height - (faceRect.origin.y * 2));
        else if ([self videoOrientationFromCurrentDeviceOrientation] == AVCaptureVideoOrientationLandscapeLeft)
            faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y - 50);
        else if ([self videoOrientationFromCurrentDeviceOrientation] == AVCaptureVideoOrientationLandscapeRight)
            faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y + previewBox.size.height - faceRect.size.height - (faceRect.origin.y * 2) - 50);
        else
            faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
        //        NSLog(@"%f - %f", faceRect.origin.x, faceRect.origin.y);
        
        
        CALayer *featureLayer = nil;
        
        // re-use an existing layer if possible
        while ( !featureLayer && (currentSublayer < sublayersCount) ) {
            CALayer *currentLayer = [sublayers objectAtIndex:currentSublayer++];
            if ( [[currentLayer name] isEqualToString:@"FaceLayer"] ) {
                featureLayer = currentLayer;
                [currentLayer setHidden:NO];
            }
        }
        
        // create a new one if necessary
        if ( !featureLayer ) {
            featureLayer = [[CALayer alloc]init];
            featureLayer.contents = (id)[self imageFromColor:[UIColor colorWithRed:187/255 green:187/255 blue:187/255 alpha:0.5]].CGImage;//(id)self.borderImage.CGImage;
            [featureLayer setName:@"FaceLayer"];
            [self.previewLayer addSublayer:featureLayer];
            featureLayer = nil;
        }
        [featureLayer setFrame:faceRect];
        
        //        switch (orientation) {
        //            case UIDeviceOrientationPortrait:
        //                [featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(90.))];
        //                break;
        //            case UIDeviceOrientationPortraitUpsideDown:
        //                [featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(180.))];
        //                break;
        //            case UIDeviceOrientationLandscapeLeft:
        //                [featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(90.))];
        //                break;
        //            case UIDeviceOrientationLandscapeRight:
        //                [featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(-90.))];
        //                break;
        //            case UIDeviceOrientationFaceUp:
        //            case UIDeviceOrientationFaceDown:
        //            default:
        //                break; // leave the layer in its last known orientation
        //        }
        currentFeature++;
    }
    
    [CATransaction commit];
}

- (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (IBAction)takePicture:(id)sender
{
    [session stopRunning];
    [self teardownAVCapture];
    
    if ([self videoOrientationFromCurrentDeviceOrientation ] == AVCaptureVideoOrientationPortrait)
    {
        _tempImage = [self imageRotatedByDegrees:_tempImage deg:90.0];
    }
    else if ([self videoOrientationFromCurrentDeviceOrientation ] == AVCaptureVideoOrientationLandscapeLeft)
    {
        _tempImage = [self imageRotatedByDegrees:_tempImage deg:180.0];
    }
    else if ([self videoOrientationFromCurrentDeviceOrientation ] == AVCaptureVideoOrientationPortraitUpsideDown)
    {
        _tempImage = [self imageRotatedByDegrees:_tempImage deg:270.0];
    }
    
    SEL selector = NSSelectorFromString(@"setMainImage:");
    [_parent performSelector:selector withObject:_tempImage afterDelay:0 ];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
