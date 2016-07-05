// Copyright (С) ABBYY (BIT Software), 1993 - 2012. All rights reserved. 

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MocrEngine.h"

// Wraps TMocrErrorCode value
@interface CMocrErrorCode : NSObject {
	TMocrErrorCode _errorCode;
}

@property(nonatomic, assign, readonly) TMocrErrorCode errorCode;

- (id) initWithErrorCode:(TMocrErrorCode)errorCode;

@end


@interface CMocrRotationType : NSObject {
	TMocrRotationType _rotationType;
}

@property(nonatomic, assign, readonly) TMocrRotationType rotationType;

- (id) initWithRotationType:(TMocrRotationType)rotationType;

@end


@protocol IRecognitionOperationCallback

// Is called on working thread.
- (BOOL) calledWithProgress:(int)progress warningCode:(TMocrWarningCode)warningCode;

// Is called on working thread.
// rotationType should be released.
- (void) onRotationTypeDetected:(CMocrRotationType*)rotationType;

// Is called on working thread.
// layoutInfo should be released.
- (void) onPrebuiltWordsInfoReady:(CMocrPrebuiltLayoutInfo*)layoutInfo;

// Is called on main thread.
// layout and rotationType objects should be released.
- (void) onRecognizeTextOnImageSucceedWithLayout:(CMocrLayout*)layout
									rotationType:(CMocrRotationType*)rotationType;

// Is called on main thread.
// layout and rotationType objects should be released.
- (void) onRecognizeTextOnImageRegionSucceedWithLayout:(CMocrLayout*)layout
										  rotationType:(CMocrRotationType*)rotationType;

// Is called on main thread.
// businessCard and rotationType objects should be released.
- (void) onRecognizeBusinessCardOnImageSucceedWithBusinessCard:(CMocrBusinessCard*)businessCard
												  rotationType:(CMocrRotationType*)rotationType;

// Is called on main thread.
// barcode object should be released.
- (void) onRecognizeBarcodeOnImageSucceedWithBarcode:(CMocrBarcode*)barcode;

// Is called on main thread.
// errorCode and errorMessage objects should be released.
- (void) onRecognitionFailedWithErrorCode:(CMocrErrorCode*)errorCode
							 errorMessage:(NSString*)errorMessage;

@end


// Abstract class.
@interface CRecognitionOperation : NSOperation<IMocrRecognitionCallback> {
	@protected
	NSObject<IMocrRecognitionManager>* _recognitionManager;
	UIImage* __weak _imageToRecognize;
	NSObject<IRecognitionOperationCallback>* _callbackObject;
}

@property(readonly, weak) UIImage* imageToRecognize;

- (id) initWithRecognitionManager:(NSObject<IMocrRecognitionManager>*)manager
				 imageToRecognize:(UIImage*)image
				   callbackObject:(NSObject<IRecognitionOperationCallback>*)callbackObject;

- (void) onRecognitionFailed;

@end


// Operation for text recognition.
@interface CRecognizeTextOnImageOperation : CRecognitionOperation

+ (CRecognizeTextOnImageOperation*) operationWithRecognitionManager:(NSObject<IMocrRecognitionManager>*)manager
												   imageToRecognize:(UIImage*)image
													 callbackObject:(NSObject<IRecognitionOperationCallback>*)callbackObject;

- (id) initWithRecognitionManager:(NSObject<IMocrRecognitionManager>*)manager
				 imageToRecognize:(UIImage*)image
				   callbackObject:(NSObject<IRecognitionOperationCallback>*)callbackObject;

@end


// Operation for text recognition on images region.
@interface CRecognizeTextOnImageRegionOperation : CRecognitionOperation {
	CMocrImageRegion* _imageRegion;
}

+ (CRecognizeTextOnImageRegionOperation*) operationWithRecognitionManager:(NSObject<IMocrRecognitionManager>*)manager
														 imageToRecognize:(UIImage*)image
																   region:(CMocrImageRegion*)imageRegion
														   callbackObject:(NSObject<IRecognitionOperationCallback>*)callbackObject;

- (id) initWithRecognitionManager:(NSObject<IMocrRecognitionManager>*)manager
				 imageToRecognize:(UIImage*)image
						   region:(CMocrImageRegion*)imageRegion
				   callbackObject:(NSObject<IRecognitionOperationCallback>*)callbackObject;

@end


// Operation for business card recognition.
@interface CRecognizeBusinessCardOnImageOperation : CRecognitionOperation

+ (CRecognizeBusinessCardOnImageOperation*) operationWithRecognitionManager:(NSObject<IMocrRecognitionManager>*)manager
														   imageToRecognize:(UIImage*)image
															 callbackObject:(NSObject<IRecognitionOperationCallback>*)callbackObject;

- (id) initWithRecognitionManager:(NSObject<IMocrRecognitionManager>*)manager
				 imageToRecognize:(UIImage*)image
				   callbackObject:(NSObject<IRecognitionOperationCallback>*)callbackObject;

@end


// Operation for barcode recognition.
@interface CRecognizeBarcodeOnImageOperation : CRecognitionOperation

+ (CRecognizeTextOnImageOperation*) operationWithRecognitionManager:(NSObject<IMocrRecognitionManager>*)manager
												   imageToRecognize:(UIImage*)image
													 callbackObject:(NSObject<IRecognitionOperationCallback>*)callbackObject;

- (id) initWithRecognitionManager:(NSObject<IMocrRecognitionManager>*)manager
				 imageToRecognize:(UIImage*)image
				   callbackObject:(NSObject<IRecognitionOperationCallback>*)callbackObject;

@end
