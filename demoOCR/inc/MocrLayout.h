// Copyright (C) ABBYY (BIT Software), 1993 - 2012. All rights reserved.

#import <Foundation/Foundation.h>
#import <MocrBarcode.h>
#import <MocrTextBlock.h>

// Text recognition results
@interface CMocrLayout:NSObject<NSCopying> {
	@private
	// Array of CMocrTextBlock objects
	NSArray* _blocks;
	
	@private
	// Array of CMocrBarcode objects
	NSArray* _barcodes;
}

@property(retain) NSArray* blocks;
@property(retain) NSArray* barcodes;

// Returns new array with NSString objects. This array contains recognized text from layout.
- (NSArray*) copyStrings;

@end
