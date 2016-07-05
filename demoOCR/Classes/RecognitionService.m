// Copyright (С) ABBYY (BIT Software), 1993 - 2012. All rights reserved. 

#import "RecognitionService.h"

@implementation CRecognitionService

- (id) init
{
	self = [super init];
	if( self == nil ) {
		return nil;
	}
	
	_operationQueue = [[NSOperationQueue alloc] init];
	
	return self;
}


- (void) addOperation:(CRecognitionOperation*)operation
{
	[_operationQueue addOperation:operation];
}

@end
