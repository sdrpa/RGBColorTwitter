
//  Created by Sinisa Drpa, 2015.

#import <Foundation/Foundation.h>

typedef void (^RGBClientColorListCompletion)(id colorsOrError);

@interface RGBClient : NSObject

+ (instancetype)sharedInstance;

- (void)colorListSinceID:(NSString *)sinceID maxID:(NSString *)maxID count:(NSUInteger)count completion:(RGBClientColorListCompletion)completion;

@end
