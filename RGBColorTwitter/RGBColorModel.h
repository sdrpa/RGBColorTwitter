
//  Created by Sinisa Drpa, 2015.

#import <Cocoa/Cocoa.h>

@interface RGBColorModel : NSObject

@property (copy) NSString *name;
@property (strong) NSColor *color;
@property (strong) NSString *tweetID;

- (instancetype)initWithName:(NSString *)name color:(NSColor *)color NS_DESIGNATED_INITIALIZER;

@end
