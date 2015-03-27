
//  Created by Sinisa Drpa, 2015.

#import "RGBColorModel.h"
#import "NSColor+NSColorHexadecimalValue.h"

@implementation RGBColorModel

- (instancetype)init {
   return [self initWithName:@"Black" color:[NSColor blackColor]];
}

- (instancetype)initWithName:(NSString *)name color:(NSColor *)color {
   self = [super init];
   if (self) {
      _name = name;
      _color = color;
   }
   return self;
}

- (NSString *)description {
   return [NSString stringWithFormat:@"<%@: %p> %@: %@", self.className, self, self.name, [self.color hexadecimalString]];
}

- (BOOL)isEqual:(id)object{
   return [self isEqualToColorModel:object];
}

- (BOOL)isEqualToColorModel:(RGBColorModel *)colorModel {
   if (self == colorModel) {
      return YES;
   }
   
   if ([[self name] isEqualToString:[colorModel name]] && [[self color] isEqual:[colorModel color]]) {
      return YES;
   }
   
   return NO;
}

- (NSUInteger)hash {
   NSUInteger hash = 0;
   hash += [[self name] hash];
   
   return hash;
}

@end
