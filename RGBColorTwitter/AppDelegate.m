
//  Created by Sinisa Drpa, 2015.

#import "AppDelegate.h"
#import "RBGWindowController.h"

@interface AppDelegate () {
   RBGWindowController *_windowController;
}

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
   _windowController = [[RBGWindowController alloc] initWithWindowNibName:@"RGBWindowController"];
   [_windowController showWindow:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
   // Insert code here to tear down your application
}

@end
