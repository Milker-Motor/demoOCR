// Copyright (С) ABBYY (BIT Software), 1993 - 2012. All rights reserved. 

#import "RecognitionOperations.h"
#import "NSObject+PerformSelectorOnMainThreadMultipleArgs.h"

@implementation CMocrErrorCode

@synthesize errorCode = _errorCode;

- (id) initWithErrorCode:(TMocrErrorCode)errorCode
{
	self = [super init];
	if( self == nil ) {
		return nil;
	}
	
	_errorCode = errorCode;
	
	return self;
}

@end


@implementation CMocrRotationType

@synthesize rotationType = _rotationType;

- (id) initWithRotationType:(TMocrRotationType)rotationType
{
	self = [super init];
	if( self == nil ) {
		return nil;
	}
	
	_rotationType = rotationType;
	
	return self;
}

@end


@implementation CRecognitionOperation

@synthesize imageToRecognize = _imageToRecognize;

- (id) initWithRecognitionManager:(NSObject<IMocrRecognitionManager>*)manager
				 imageToRecognize:(UIImage*)image
				   callbackObject:(NSObject<IRecognitionOperationCallback>*)callbackObject
{
	self = [super init];
	if( self == nil ) {
		return nil;
	}
	
	_recognitionManager = manager;
	_imageToRecognize = image;
	_callbackObject = callbackObject;
	
	return self;
}


- (BOOL) calledWithProgress:(int)progress warning:(TMocrWarningCode)warning
{
	return [_callbackObject calledWithProgress:progress warningCode:warning];
}

- (void) onRotationTypeDetected:(TMocrRotationType)rotationType
{
	[_callbackObject onRotationTypeDetected:[[CMocrRotationType alloc] initWithRotationType:rotationType]];
}

- (void) onPrebuiltWordsInfoReady:(CMocrPrebuiltLayoutInfo*)layoutInfo
{
	[_callbackObject onPrebuiltWordsInfoReady:layoutInfo];
}

- (void) onRecognitionFailed
{
	TMocrErrorCode errorCode;
	NSString* errorMessage;
	[CMocrEngine getLastError:&errorCode message:&errorMessage];
	[_callbackObject performSelectorOnMainThread:@selector(onRecognitionFailedWithErrorCode:errorMessage:)
		waitUntilDone:NO withObjects:[[CMocrErrorCode alloc] initWithErrorCode:errorCode], errorMessage, nil];
}

@end


@implementation CRecognizeTextOnImageOperation

+ (CRecognizeTextOnImageOperation*) operationWithRecognitionManager:(NSObject<IMocrRecognitionManager>*)manager
												   imageToRecognize:(UIImage*)image
													 callbackObject:(NSObject<IRecognitionOperationCallback>*)callbackObject
{
	return [[self alloc] initWithRecognitionManager:manager imageToRecognize:image callbackObject:callbackObject];
}

- (id) initWithRecognitionManager:(NSObject<IMocrRecognitionManager>*)manager
				 imageToRecognize:(UIImage*)image
				   callbackObject:(NSObject<IRecognitionOperationCallback>*)callbackObject
{
	return [super initWithRecognitionManager:manager imageToRecognize:image callbackObject:callbackObject];
}

- (void) start
{
	CMocrLayout* layout = nil;
	TMocrRotationType rotationType;
	if( ![_recognitionManager recognizeTextOnImage:_imageToRecognize withCallback:self storeLayout:&layout rotation:&rotationType] ) {
		[self onRecognitionFailed];
		return;
	}
	[_callbackObject performSelectorOnMainThread:@selector(onRecognizeTextOnImageSucceedWithLayout:rotationType:)
		waitUntilDone:NO withObjects:layout, [[CMocrRotationType alloc] initWithRotationType:rotationType], nil];
}

@end


@implementation CRecognizeTextOnImageRegionOperation

+ (CRecognizeTextOnImageRegionOperation*) operationWithRecognitionManager:(NSObject<IMocrRecognitionManager>*)manager
														 imageToRecognize:(UIImage*)image
																   region:(CMocrImageRegion*)imageRegion
														   callbackObject:(NSObject<IRecognitionOperationCallback>*)callbackObject
{
	return [[self alloc] initWithRecognitionManager:manager imageToRecognize:image region:imageRegion callbackObject:callbackObject];
}

- (id) initWithRecognitionManager:(NSObject<IMocrRecognitionManager>*)manager
				 imageToRecognize:(UIImage*)image
						   region:(CMocrImageRegion*)imageRegion
				   callbackObject:(NSObject<IRecognitionOperationCallback>*)callbackObject
{
	self = [super initWithRecognitionManager:manager imageToRecognize:image callbackObject:callbackObject];
	if( self == nil ) {
		return nil;
	}
	
	_imageRegion = imageRegion;
	
	return self;
}


- (void) start
{
	CMocrLayout* layout = nil;
	TMocrRotationType rotationType;
	if( ![_recognitionManager recognizeTextOnImage:_imageToRecognize withRegion:_imageRegion callback:self storeLayout:&layout rotation:&rotationType] ) {
		[self onRecognitionFailed];
		return;
	}
	[_callbackObject performSelectorOnMainThread:@selector(onRecognizeTextOnImageSucceedWithLayout:rotationType:)
		waitUntilDone:NO withObjects:layout, [[CMocrRotationType alloc] initWithRotationType:rotationType], nil];
}

@end


@implementation CRecognizeBusinessCardOnImageOperation

+ (CRecognizeBusinessCardOnImageOperation*) operationWithRecognitionManager:(NSObject<IMocrRecognitionManager>*)manager
														   imageToRecognize:(UIImage*)image
															 callbackObject:(NSObject<IRecognitionOperationCallback>*)callbackObject
{
	return [[self alloc] initWithRecognitionManager:manager imageToRecognize:image callbackObject:callbackObject];
}

- (id) initWithRecognitionManager:(NSObject<IMocrRecognitionManager>*)manager
				 imageToRecognize:(UIImage*)image
				   callbackObject:(NSObject<IRecognitionOperationCallback>*)callbackObject
{
	return [super initWithRecognitionManager:manager imageToRecognize:image callbackObject:callbackObject];
}

- (void) start
{
	CMocrBusinessCard* businessCard = nil;
	TMocrRotationType rotationType;
	if( ![_recognitionManager recognizeBusinessCardOnImage:_imageToRecognize withCallback:self storeBusinessCard:&businessCard rotation:&rotationType] ) {
		[self onRecognitionFailed];
		return;
	}
	[_callbackObject
		performSelectorOnMainThread:@selector(onRecognizeBusinessCardOnImageSucceedWithBusinessCard:rotationType:)
		waitUntilDone:NO withObjects:businessCard, [[CMocrRotationType alloc] initWithRotationType:rotationType], nil];
}


@end


@implementation CRecognizeBarcodeOnImageOperation

+ (CRecognizeTextOnImageOperation*) operationWithRecognitionManager:(NSObject<IMocrRecognitionManager>*)manager
												   imageToRecognize:(UIImage*)image
													 callbackObject:(NSObject<IRecognitionOperationCallback>*)callbackObject
{
	return [[self alloc] initWithRecognitionManager:manager imageToRecognize:image callbackObject:callbackObject];
}

- (id) initWithRecognitionManager:(NSObject<IMocrRecognitionManager>*)manager
				 imageToRecognize:(UIImage*)image
				   callbackObject:(NSObject<IRecognitionOperationCallback>*)callbackObject
{
	return [super initWithRecognitionManager:manager imageToRecognize:image callbackObject:callbackObject];
}

- (void) start
{
	CMocrBarcode* barcode = nil;
	if( ![_recognitionManager recognizeBarcodeOnImage:_imageToRecognize withCallback:self storeBarcode:&barcode] ) {
		[self onRecognitionFailed];
		return;
	}
	[_callbackObject performSelectorOnMainThread:@selector(onRecognizeBarcodeOnImageSucceedWithBarcode:) withObject:barcode waitUntilDone:NO];
}

@end
