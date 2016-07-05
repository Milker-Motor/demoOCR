// Copyright (C) ABBYY (BIT Software), 1993 - 2012. All rights reserved.

#import <Foundation/Foundation.h>
#import <MocrDefs.h>

@class CMocrUserLanguage;

@interface CMocrRecognitionConfiguration : NSObject<NSCopying> {
	@private
	int _imageResolution;
	unsigned int _imageProcessingOptions;
	TMocrRecognitionMode _recognitionMode;
	TMocrRecognitionConfidenceLevel _recognitionConfidenceLevel;
	unsigned int _barcodeTypes;
	TMocrSupportedCodePage _defaultCodePage;
	unichar _unknownLetter;
	NSMutableSet* _recognitionLanguages;
	NSString* _userPatternsDataFileName;
	NSSet* _userLanguages;
	BOOL _isMicrModeEnabled;
	CMocrUserLanguage* _micrLanguage;
	NSString* _micrPatternsDataFileName;
}

@property int imageResolution;
@property unsigned int imageProcessingOptions;
@property TMocrRecognitionMode recognitionMode;
@property TMocrRecognitionConfidenceLevel recognitionConfidenceLevel;
@property unsigned int barcodeTypes;
@property TMocrSupportedCodePage defaultCodePage;
@property unichar unknownLetter;
@property(readonly) NSSet* recognitionLanguages;
@property(readonly) NSString* userPatternsDataFileName;
@property(readonly) NSSet* userLanguages;
@property(readonly) BOOL isMicrModeEnabled;
@property(readonly) CMocrUserLanguage* micrLanguage;
@property(readonly) NSString* micrPatternsDataFileName;

// Create autoreleased instance.
+ (CMocrRecognitionConfiguration*) configuration;

// Default constructor.
- (id) init;

// Constructor with initialial values.
- (id) initWithImageResolution:(int)imageResolution
		imageProcessingOptions:(unsigned int)imageProcessingOptions
			   recognitionMode:(TMocrRecognitionMode)recognitionMode
	recognitionConfidenceLevel:(TMocrRecognitionConfidenceLevel)recognitionConfidenceLevel
				  barcodeTypes:(unsigned int)barcodeTypes
			   defaultCodePage:(TMocrSupportedCodePage)defaultCodePage
				 unknownLetter:(unichar)unknownLetter
		  recognitionLanguages:(NSSet*)recognitionLanguages;

- (BOOL) setRecognitionLanguages:(NSSet*)recognitionLanguageNames;

- (BOOL) setUserRecognitionLanguages:(NSSet*)userLanguages patternsDataFileName:(NSString*)patternsDataFileName;

- (BOOL) enableMicrModeWithLanguage:(CMocrUserLanguage*)micrLanguage patternsDataFileName:(NSString*)patternsDataFileName;

- (void) disableMicrMode;

@end
