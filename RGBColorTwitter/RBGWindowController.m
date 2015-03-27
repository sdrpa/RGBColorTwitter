
//  Created by Sinisa Drpa, 2015.

#import "RBGWindowController.h"
#import "RGBClient.h"
#import "STTwitterAPI.h"
#import "Promise.h"
#import "RGBColorModel.h"

@interface RBGWindowController () {
   NSString *_sinceID, *_maxID;
}
@property (weak) IBOutlet NSArrayController *arrayController;
@end

@implementation RBGWindowController

- (void)windowDidLoad {
   [super windowDidLoad];
   
   [self refresh:nil];
}

- (void)reloadDataWithStatuses:(NSArray *)statuses {
   //NSLog(@"statuses: %@", statuses);
   for (NSDictionary *status in statuses) {
      RGBColorModel *colorModel = [self colorModelFromStatusDictionary:status];
      if (![[_arrayController arrangedObjects] containsObject:colorModel]) {
         [_arrayController addObject:colorModel];
      }
   }
   RGBColorModel *first = [[_arrayController arrangedObjects] firstObject];
   RGBColorModel *last = [[_arrayController arrangedObjects] lastObject];
   
   _sinceID = first.tweetID;
   _maxID = last.tweetID;
   
   NSLog(@"_arrayController (%li): %@", [[_arrayController arrangedObjects] count], [_arrayController arrangedObjects]);
}

- (RGBColorModel *)colorModelFromStatusDictionary:(NSDictionary *)status {
   //NSLog(@"status: %@", status);
   NSString *text = status[@"text"];
   
   NSCharacterSet *newlineCharacterSet = [NSCharacterSet newlineCharacterSet];
   NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
   
   NSString *currentLine;
   RGBColorModel *colorModel = [RGBColorModel new];
   colorModel.tweetID = status[@"id_str"];
   
   NSScanner *scanner = [NSScanner scannerWithString:text];
   if ([scanner scanUpToString:@"#" intoString:&currentLine]) {
      NSString *name = [currentLine stringByTrimmingCharactersInSet:newlineCharacterSet];
      colorModel.name = [name stringByReplacingOccurrencesOfString:@"\"" withString:@""];
   }
   
   if ([scanner scanUpToCharactersFromSet:whitespaceCharacterSet intoString:&currentLine]) {
      NSString *string = [currentLine copy];
      NSString *hexString = [string stringByReplacingOccurrencesOfString:@"#" withString:@"0x"];
      unsigned colorInt = 0;
      [[NSScanner scannerWithString:hexString] scanHexInt:&colorInt];
      colorModel.color = [self colorWithHexValue:colorInt];
   }
   
   return colorModel;
}

- (NSColor *)colorWithHexValue:(unsigned)color {
   return [NSColor colorWithSRGBRed:((color >> 16) & 0xFF) / 255.0 \
                              green:((color >> 8) & 0xFF) / 255.0 \
                               blue:(color & 0xFF) / 255.0 \
                              alpha:1.0];
}

- (IBAction)refresh:(id)sender {
   _sinceID = nil;
   [[RGBClient sharedInstance] colorListSinceID:_sinceID maxID:nil count:20 completion:^(id statuses) {
      [self reloadDataWithStatuses:statuses];
   }];
}

- (IBAction)previous:(id)sender {
   
}

- (IBAction)next:(id)sender {
   [[RGBClient sharedInstance] colorListSinceID:_maxID maxID:nil count:20 completion:^(id statuses) {
      [self reloadDataWithStatuses:statuses];
   }];
}

@end
