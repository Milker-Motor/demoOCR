#import <Foundation/Foundation.h>

@interface NSObject(PerformSelectorOnMainThreadMultipleArgs)

- (void) performSelectorOnMainThread:(SEL)selector
					   waitUntilDone:(BOOL)wait
						 withObjects:(NSObject*)object, ... NS_REQUIRES_NIL_TERMINATION;

@end
