#import <Foundation/Foundation.h>

@interface NSXTimer : NSObject
{
    int64_t startTime;
    int64_t time;
    
    int64_t prev_time;
    
    dispatch_queue_t timeQueue;
}

- (id) init;
- (void) dealloc;

- (void) close;
- (int64_t) getTime;
- (void) reset;

@end
