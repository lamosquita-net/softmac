// BackupDrive: app de barra de menús para macOS 10.14+ (x86_64). Ver AppDelegate.m.
// Licencia: MIT (ver ../LICENSE).

#import <Cocoa/Cocoa.h>

#import "AppDelegate.h"

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    NSApplication *app = NSApplication.sharedApplication;
    AppDelegate *delegate = [[AppDelegate alloc] init];
    app.delegate = delegate;
    app.activationPolicy = NSApplicationActivationPolicyAccessory;  // sin icono en el Dock
    [app run];
  }
  return 0;
}
