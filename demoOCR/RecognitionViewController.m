// Copyright (С) ABBYY (BIT Software), 1993 - 2012. All rights reserved.

#import "RecognitionViewController.h"
#import "MocrEngine.h"

static NSString* FineBcrFieldNames[MBFT_Count] = {
    @"Phone",
    @"Fax",
    @"Mobile",
    @"E-mail",
    @"Web",
    @"Address",
    @"Name",
    @"Company",
    @"Job",
    @"Other Text",
};

static NSString* FineBcrFieldComponentNames[MBFCT_Count] = {
    @"First Name",
    @"Middle Name",
    @"Last Name",
    @"Extra Name",
    @"Title",
    @"Degree",
    @"Phone Prefix",
    @"Phone Country Code",
    @"Phone Code",
    @"Phone Body",
    @"Phone Extensoin",
    @"Zip Code",
    @"Country",
    @"City",
    @"Street Address",
    @"Region",
    @"Job Position",
    @"Job Department",
};

@implementation CRecognitionViewController

- (id) init
{
    self = [super initWithNibName:@"RecognitionView" bundle:nil];
    if( self == nil ) {
        return nil;
    }
    
    _pathToData = nil;
    
    [self initializeRecognitionEngine];
    
    _recognitionService = [[CRecognitionService alloc] init];
    recognizedCard = [[NSMutableDictionary alloc] init];
    
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) initializeRecognitionEngine
{
    // Load the license data from file.
    NSString* licenseDataFilePath = [[self pathToData] stringByAppendingPathComponent:@"license"];
    NSFileHandle* licenseDataFile = [NSFileHandle fileHandleForReadingAtPath:licenseDataFilePath];
    NSData* licenseData = [licenseDataFile readDataToEndOfFile];
    
    // Intialize MobileOCR engine
    NSArray* dataSources = [NSArray arrayWithObject:[CMocrDirectoryDataSource dataSourceWithDirectoryPath:[self pathToData]]];
    CMocrLicense* license = [CMocrLicense licenseWithLicenseData:licenseData applicationId:@"iOS_ID"];
    _mocrEngine = [CMocrEngine createArcSharedEngineWithDataSources:dataSources license:license];
    if( _mocrEngine == nil ) {
        // Failed to create singleton instance of the CMocrEngine class.
        TMocrErrorCode errorCode;
        NSString* errorMessage;
        [CMocrEngine getLastError:&errorCode message:&errorMessage];
        NSLog(@"Error code: %@. Error message: %@", [CRecognitionViewController stringFromMocrErrorCode:errorCode], errorMessage);
    }
    
    _ocrConfiguration = nil;
    _bcrConfiguration = nil;
}

- (NSString*) pathToData
{
    if( _pathToData == nil ) {
        NSBundle* mainBundle = [NSBundle mainBundle];
        if( mainBundle != nil ) {
            NSString* bundlePath = [mainBundle bundlePath];
            _pathToData = [bundlePath copy];
        } else {
            _pathToData = @"./";
        }
    }
    return _pathToData;
}

- (CMocrRecognitionConfiguration*) ocrConfiguration
{
    if( _ocrConfiguration == nil ) {
        NSSet* recognitionLanguages = [NSSet setWithObjects:@"English", @"French", nil];
        _ocrConfiguration = [[CMocrRecognitionConfiguration alloc]
                             initWithImageResolution:0
                             imageProcessingOptions:MIPO_DetectPageOrientation | MIPO_ProhibitVerticalCjkText
                             recognitionMode:MRM_Full
                             recognitionConfidenceLevel:MRCL_Level3
                             barcodeTypes:MBT_ANY1D | MBT_SQUARE2D | MBT_PDF417
                             defaultCodePage:MSCP_Utf8
                             unknownLetter:L'^'
                             recognitionLanguages:recognitionLanguages];
    }
    return _ocrConfiguration;
}

- (CMocrRecognitionConfiguration*) bcrConfiguration
{
    if( _bcrConfiguration == nil ) {
        NSSet* recognitionLanguages = [NSSet setWithObjects:@"English", @"French", nil];
        _bcrConfiguration = [[CMocrRecognitionConfiguration alloc]
                             initWithImageResolution:0
                             imageProcessingOptions:0
                             recognitionMode:MRM_Full
                             recognitionConfidenceLevel:MRCL_Level3
                             barcodeTypes:0
                             defaultCodePage:MSCP_Utf8
                             unknownLetter:L'^'
                             recognitionLanguages:recognitionLanguages];
    }
    return _bcrConfiguration;
}

- (NSString*) businessCardFieldToString:(CMocrBusinessCardField*)businessCardField
{
    NSMutableString* resultString = [NSMutableString string];
    {
        NSString* fieldName = FineBcrFieldNames[businessCardField.fieldType];
        if (!recognizedCard[fieldName])
            recognizedCard[fieldName] = [[NSMutableArray alloc] init];
        
        for(CMocrTextLine* textLine in businessCardField.lines) {
            NSString* lineString = [textLine copyString];
            [recognizedCard[fieldName] addObject:lineString];
        }
    }
    
    // How to work with field component.
    // If bcr-field is complex, then Components array contains more than zero of elements.
    // For each component, output it.
    for( CMocrBusinessCardFieldComponent* component in businessCardField.components ) {
        NSString* componentName = FineBcrFieldComponentNames[component.componentType];
        if (!recognizedCard[componentName])
            recognizedCard[componentName] = [[NSMutableArray alloc] init];
        
        for(CMocrTextLine* textLine in component.lines) {
            NSString* lineString = [textLine copyString];
            [recognizedCard[componentName] addObject:lineString];
        }
    }
    
    return resultString;
}

// Represent CMocrBusinessCard as string to show in UIWebView.
- (NSString*) stringFromMocrBusinessCard:(CMocrBusinessCard*)businessCard
{
    NSMutableString* resultString = [NSMutableString string];
    
    for(CMocrBusinessCardField* bcrField in businessCard.fields) {
        [resultString appendString:[self businessCardFieldToString:bcrField]];
    }
    return resultString;
}

// Represent CMocrBarcode as string to show in UIWebView.
- (NSMutableString*) stringFromMocrBarcode:(CMocrBarcode*)barcode
{
    NSMutableString* resultString = [NSMutableString string];
    NSString* lineString = [barcode.text copyString];
    [resultString appendFormat:@"%@", lineString];
    
    return resultString;
}

+ (NSString*) stringFromMocrErrorCode:(TMocrErrorCode)errorCode
{
    switch( errorCode ) {
        case MEC_NoError:
            return @"MEC_NoError";
        case MEC_EngineInstanceExists:
            return @"MEC_EngineInstanceExists";
        case MEC_EngineNotInitialized:
            return @"MEC_EngineNotInitialized";
        case MEC_FileNotFound:
            return @"MEC_FileNotFound";
        case MEC_InvalidArgument:
            return @"MEC_InvalidArgument";
        case MEC_MemoryAllocationFailed:
            return @"MEC_MemoryAllocationFailed";
        case MEC_RecognitionInProgress:
            return @"MEC_RecognitionInProgress";
        case MEC_FineErrNotInitialized:
            return @"MEC_FineErrNotInitialized";
        case MEC_FineErrLicenseError:
            return @"MEC_FineErrLicenseError";
        case MEC_FineErrInvalidArgument:
            return @"MEC_FineErrInvalidArgument";
        case MEC_FineErrInternalFailure:
            return @"MEC_FineErrInternalFailure";
        case MEC_FineErrNotEnoughMemory:
            return @"MEC_FineErrNotEnoughMemory";
        case MEC_FineErrTerminatedByCallback:
            return @"MEC_FineErrTerminatedByCallback";
    }
}

- (void) showResults:(NSString*)stringToOutput
{
    NSMutableString* string = [NSMutableString string];
    [string appendString:stringToOutput];
    
    SEL selector = NSSelectorFromString(@"dataFromImage:");
    [_parent performSelector:selector withObject:recognizedCard afterDelay:0 ];
}

- (void) showMocrError:(TMocrErrorCode)errorCode message:(NSString*)errorMessage
{
    NSLog(@"Error %@: %@", [CRecognitionViewController stringFromMocrErrorCode:errorCode], errorMessage);
}

- (void) recognizeImage:(UIImage*)image
{
    CMocrEngine* mobileOcrEngine = [CMocrEngine getSharedEngine];
    NSObject<IMocrRecognitionManager>* recognitionManager =
    [mobileOcrEngine newRecognitionManagerWithConfiguration:[self ocrConfiguration]];
    [self processRecognitionOperation:[CRecognizeTextOnImageOperation operationWithRecognitionManager:recognitionManager imageToRecognize:image callbackObject:self]];
}

- (void) recognizeBusinessCard:(UIImage*)image
{
    CMocrEngine* mobileOcrEngine = [CMocrEngine getSharedEngine];
    NSObject<IMocrRecognitionManager>* recognitionManager =
    [mobileOcrEngine newRecognitionManagerWithConfiguration:[self bcrConfiguration]];
    [self processRecognitionOperation:[CRecognizeBusinessCardOnImageOperation operationWithRecognitionManager:recognitionManager imageToRecognize:image callbackObject:self]];
}

- (void) processRecognitionOperation:(CRecognitionOperation*)operation
{
    
    [self onBeforeRecognition];
    
    //process
    [_recognitionService addOperation:operation];
}


// Set value for progress bar.
// progress object should be release.
- (void) setProgress:(NSNumber*)progress
{
    progressView.progress = [progress floatValue];
}

- (BOOL) calledWithProgress:(int)progress warningCode:(TMocrWarningCode)warningCode
{
    CGFloat stage = progress / 100.0;
    
    [self performSelectorOnMainThread:@selector(setProgress:) withObject:[[NSNumber alloc] initWithFloat:stage] waitUntilDone:NO];
    
    return !_needToStopRecognition;
}

- (void) onRotationTypeDetected:(CMocrRotationType*)rotationType
{
}

- (void) onPrebuiltWordsInfoReady:(CMocrPrebuiltLayoutInfo*)layoutInfo
{
}

- (void) onRecognizeTextOnImageSucceedWithLayout:(CMocrLayout*)layout
                                    rotationType:(CMocrRotationType*)rotationType
{
    [self onAfterRecognition];
}

- (void) onRecognizeTextOnImageRegionSucceedWithLayout:(CMocrLayout*)layout
                                          rotationType:(CMocrRotationType*)rotationType
{
    [self onRecognizeTextOnImageSucceedWithLayout:layout rotationType:rotationType];
}

- (void) onRecognizeBusinessCardOnImageSucceedWithBusinessCard:(CMocrBusinessCard*)businessCard
                                                  rotationType:(CMocrRotationType*)rotationType
{
    if (recognizedCard.count)
        [recognizedCard removeAllObjects];
    
    [self showResults:[self stringFromMocrBusinessCard:businessCard]];
    
    // Release arguments.
    
    [self onAfterRecognition];
}

- (void) onRecognizeBarcodeOnImageSucceedWithBarcode:(CMocrBarcode*)barcode
{
    [self showResults:[self stringFromMocrBarcode:barcode]];
    
    // Release argument.
    
    [self onAfterRecognition];
}

- (void) onRecognitionFailedWithErrorCode:(CMocrErrorCode*)errorCode errorMessage:(NSString*)errorMessage
{
    NSLog(@"%@", errorMessage);
    if( [errorCode errorCode] == MEC_FineErrTerminatedByCallback ) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self showMocrError:[errorCode errorCode] message:errorMessage];
        [self onAfterRecognition];
    }
}

- (void) onBeforeRecognition
{
    _needToStopRecognition = NO;
}

- (void) onAfterRecognition
{
    //finish
}

@end
