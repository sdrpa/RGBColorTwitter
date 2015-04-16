
//  Created by Sinisa Drpa, 2015.

#import "RBGWindowController.h"
#import "RGBClient.h"
#import "STTwitterAPI.h"
#import "Promise.h"
#import "RGBColorModel.h"

@interface RBGWindowController () {
   BOOL _hasDoneInitialRequest; // An application’s first request to a timeline endpoint should only specify a count
   NSString *_sinceID, *_maxID;
}
@property (weak) IBOutlet NSArrayController *arrayController;
@property (assign) BOOL fetching;
@end

@implementation RBGWindowController

- (instancetype)initWithWindowNibName:(NSString *)windowNibName {
   self = [super initWithWindowNibName:windowNibName];
   if (self) {
      _sinceID = nil;
      _maxID = nil;
   }
   return self;
}

- (void)windowDidLoad {
   [super windowDidLoad];
   
   [self refresh:nil];
}

- (void)reloadDataWithStatuses:(NSArray *)statuses {
   //NSLog(@"statuses: %@", statuses);
   NSMutableArray *newStatuses = [NSMutableArray arrayWithCapacity:[statuses count]];
   for (NSDictionary *status in statuses) {
      RGBColorModel *colorModel = [self colorModelFromStatusDictionary:status];
      if (![[_arrayController arrangedObjects] containsObject:colorModel]) {
         [newStatuses addObject:colorModel];
      }
   }
   
   //NSLog(@"newStatuses (%li): %@", [newStatuses count], newStatuses);
   [_arrayController addObjects:newStatuses];
   
   RGBColorModel *first = [[_arrayController arrangedObjects] firstObject];
   RGBColorModel *last = [[_arrayController arrangedObjects] lastObject];
   
   _sinceID = first.tweetID;
   _maxID = last.tweetID;
   
   //NSLog(@"_arrayController (%li): %@", [[_arrayController arrangedObjects] count], [_arrayController arrangedObjects]);
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
   self.fetching = YES;
   RBGWindowController __weak *weakSelf = self;
   
   RGBClient *client = [RGBClient sharedInstance];
   if (!_hasDoneInitialRequest) {
      _hasDoneInitialRequest = YES;
      
      [client initialColorListWithCount:20 completion:^(id statuses) {
         weakSelf.fetching = NO;
         [self reloadDataWithStatuses:statuses];
      }];
   }
   else {
      [client colorListSinceID:nil maxID:_maxID count:20 completion:^(id statuses) {
         weakSelf.fetching = NO;
         [self reloadDataWithStatuses:statuses];
      }];
   }
}

- (IBAction)previous:(id)sender {
   
}

- (IBAction)next:(id)sender {
   self.fetching = YES;
   RBGWindowController __weak *weakSelf = self;
   
   [[RGBClient sharedInstance] colorListSinceID:nil maxID:_maxID count:20 completion:^(id statuses) {
      weakSelf.fetching = NO;
      [self reloadDataWithStatuses:statuses];
   }];
}

@end
