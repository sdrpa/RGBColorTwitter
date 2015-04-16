
//  Created by Sinisa Drpa, 2015.

#import "RGBClient.h"
#import "STTwitterAPI.h"
#import "Promise.h"
#import "Deferred.h"

@interface RGBClient () {
}
@property (strong, nonatomic) STTwitterAPI *twitter;
@end

@implementation RGBClient

+ (instancetype)sharedInstance {
   static dispatch_once_t once;
   static id sharedInstance;
   dispatch_once(&once, ^{
      sharedInstance = [[self alloc] init];
   });
   return sharedInstance;
}

- (instancetype)init {
   self = [super init];
   if (self) {
   }
   return self;
}

- (Promise *)twitterAPI {
   Deferred *futureData = [Deferred deferred];
   if (_twitter) {
      return [futureData resolve:_twitter];
   }
   
   __weak RGBClient *weakSelf = self;
   STTwitterAPI *twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
   [twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
      printf("Account: %s\n", [username cStringUsingEncoding:NSUTF8StringEncoding]);
      weakSelf.twitter = twitter;
      [futureData resolve:twitter];
   } errorBlock:^(NSError *error) {
      [futureData reject:error];
      printf("%s\n", [[error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
   }];
   
   return [futureData promise];
}

- (void)initialColorListWithCount:(NSUInteger)count completion:(RGBClientColorListCompletion)completion {
   Promise *promise = [self twitterAPI];
   [promise when:^(STTwitterAPI *twitter) {
      [twitter getUserTimelineWithScreenName:@"@RGB_Colours"
                                       count:count
                                successBlock:^(NSArray *statuses) {
                                   completion(statuses);
                                } errorBlock:^(NSError *error) {
                                   completion(error);
                                }];
   } failed:^(NSError *error) {
      completion(error);
   }];
}

- (void)colorListSinceID:(NSString *)sinceID maxID:(NSString *)maxID count:(NSUInteger)count completion:(RGBClientColorListCompletion)completion {
   Promise *promise = [self twitterAPI];
   [promise when:^(STTwitterAPI *twitter) {
      [twitter getUserTimelineWithScreenName:@"@RGB_Colours"
                                     sinceID:sinceID
                                       maxID:maxID
                                       count:count
                                successBlock:^(NSArray *statuses) {
                                   completion(statuses);
                                } errorBlock:^(NSError *error) {
                                   completion(error);
                                }];
   } failed:^(NSError *error) {
      completion(error);
   }];
}

@end
