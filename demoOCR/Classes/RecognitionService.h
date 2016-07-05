// Copyright (С) ABBYY (BIT Software), 1993 - 2012. All rights reserved. 

#import <Foundation/Foundation.h>
#import "IMocrRecognitionManager.h"
#import "RecognitionOperations.h"

@interface CRecognitionService : NSObject {
	NSOperationQueue* _operationQueue;
}

- (id) init;

- (void) addOperation:(CRecognitionOperation*)operation;

@end
