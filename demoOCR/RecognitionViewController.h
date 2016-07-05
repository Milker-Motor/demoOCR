// Copyright (С) ABBYY (BIT Software), 1993 - 2012. All rights reserved.

#import <UIKit/UIKit.h>

#import "RecognitionService.h"

@class ViewController;

@interface CRecognitionViewController : UIViewController <UINavigationBarDelegate, IRecognitionOperationCallback>
{
    CMocrEngine* _mocrEngine;
    CMocrRecognitionConfiguration* _ocrConfiguration;
    CMocrRecognitionConfiguration* _bcrConfiguration;
    
    CRecognitionService* _recognitionService;
    
    BOOL _needToStopRecognition;
    
    NSString* _pathToData;
    
    UIProgressView* progressView;
    NSMutableDictionary *recognizedCard;
}

@property (strong, nonatomic) id parent;

- (void) initializeRecognitionEngine;

- (NSString*) pathToData;

- (CMocrRecognitionConfiguration*) ocrConfiguration;
- (CMocrRecognitionConfiguration*) bcrConfiguration;

// Set value for progress bar.
// progress object should be release.
- (void) setProgress:(NSNumber*)progress;

// Represent CMocrBusinessCard as html string to show in UIWebView.
- (NSString*) stringFromMocrBusinessCard:(CMocrBusinessCard*)businessCard;

- (void) showResults:(NSString*)stringToOutput;

- (void) showMocrError:(TMocrErrorCode)errorCode message:(NSString*)errorMessage;

- (void) recognizeImage:(UIImage*)image;

- (void) recognizeBusinessCard:(UIImage*)image;

- (void) processRecognitionOperation:(CRecognitionOperation*)operation;

- (void) onBeforeRecognition;

+ (NSString*) stringFromMocrErrorCode:(TMocrErrorCode)errorCode;

@end