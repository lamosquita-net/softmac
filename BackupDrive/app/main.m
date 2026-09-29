// BackupDrive: app de barra de menús para macOS 10.14+ (x86_64).
//
// No sincroniza por sí misma: muestra el estado que escribe scripts/backupdrive-sync.sh en
// ~/Library/Application Support/BackupDrive/status.json, lanza ese script a petición y activa o
// desactiva el LaunchAgent que lo ejecuta cada hora. Sin nib ni Xcode: ver build-app.sh.
//
// Licencia: MIT (ver ../LICENSE).

#import <Cocoa/Cocoa.h>

static NSString *const kAgentLabel = @"net.lamosquita.backupdrive";
static NSString *const kSyncScript = @"/usr/local/bin/backupdrive-sync.sh";
static const NSTimeInterval kPollSeconds = 2.0;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>
@property(strong) NSStatusItem *statusItem;
@property(strong) NSTimer *timer;
@property(copy) NSDate *statusDate;  // mtime de status.json ya leído
@property(copy) NSDictionary *status;
@property(strong) NSTask *manualRun;
@end

@implementation AppDelegate

#pragma mark - Rutas

- (NSString *)appSupportDir {
  NSString *override = NSProcessInfo.processInfo.environment[@"BACKUPDRIVE_DIR"];
  if (override.length) return override;
  return [NSHomeDirectory()
      stringByAppendingPathComponent:@"Library/Application Support/BackupDrive"];
}

- (NSString *)statusPath {
  return [self.appSupportDir stringByAppendingPathComponent:@"status.json"];
}

- (NSString *)logPath {
  NSString *log = self.status[@"log"];
  if ([log isKindOfClass:NSString.class] && log.length) return log;
  return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Logs/BackupDrive/backupdrive.log"];
}

- (NSString *)agentPlistPath {
  return [NSHomeDirectory()
      stringByAppendingPathComponent:
          [NSString stringWithFormat:@"Library/LaunchAgents/%@.plist", kAgentLabel]];
}

#pragma mark - Arranque

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  self.statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSSquareStatusItemLength];
  self.statusItem.button.toolTip = @"BackupDrive";
  NSMenu *menu = [[NSMenu alloc] initWithTitle:@"BackupDrive"];
  menu.delegate = self;
  menu.autoenablesItems = NO;
  self.statusItem.menu = menu;

  [self reloadStatusForce:YES];
  self.timer = [NSTimer scheduledTimerWithTimeInterval:kPollSeconds
                                                target:self
                                              selector:@selector(poll:)
                                              userInfo:nil
                                               repeats:YES];
  self.timer.tolerance = 0.5;
}

- (void)poll:(NSTimer *)timer {
  [self reloadStatusForce:NO];
}

#pragma mark - Estado

// Relee status.json si ha cambiado. El script lo escribe de forma atómica (mv), así que nunca se
// lee a medias.
- (void)reloadStatusForce:(BOOL)force {
  NSDictionary *attrs = [NSFileManager.defaultManager attributesOfItemAtPath:self.statusPath
                                                                       error:nil];
  NSDate *mtime = attrs.fileModificationDate;
  if (!force && ((mtime == nil && self.statusDate == nil) ||
                 (mtime && [mtime isEqualToDate:self.statusDate]))) {
    return;
  }
  self.statusDate = mtime;
  NSDictionary *parsed = nil;
  NSData *data = mtime ? [NSData dataWithContentsOfFile:self.statusPath] : nil;
  if (data) {
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if ([json isKindOfClass:NSDictionary.class]) parsed = json;
  }
  self.status = parsed;
  [self updateIcon];
}

- (NSString *)field:(NSString *)key of:(NSDictionary *)dict {
  id value = dict[key];
  return [value isKindOfClass:NSString.class] ? value : @"";
}

- (BOOL)isRunning {
  if (self.manualRun.isRunning) return YES;
  return [[self field:@"state" of:self.status] isEqualToString:@"running"];
}

- (void)updateIcon {
  NSString *name = @"menubar_BackupDriveTemplate";
  NSString *result = [self field:@"result" of:self.status];
  if (self.isRunning) {
    name = @"menubar_BackupDrive-syncTemplate";
  } else if ([result isEqualToString:@"error"] || [result isEqualToString:@"interrupted"]) {
    name = @"menubar_BackupDrive-errorTemplate";
  }
  NSImage *image = [NSImage imageNamed:name];
  image.template = YES;  // negro en modo claro, blanco en oscuro
  self.statusItem.button.image = image;
}

- (NSDate *)dateFromISO:(NSString *)iso {
  if (!iso.length) return nil;
  static NSISO8601DateFormatter *formatter;
  if (!formatter) formatter = [[NSISO8601DateFormatter alloc] init];
  return [formatter dateFromString:iso];
}

// "hace 5 min", "hoy 18:05", "29/09 18:05". NSRelativeDateTimeFormatter es de 10.15.
- (NSString *)describeDate:(NSDate *)date {
  if (!date) return @"—";
  NSTimeInterval ago = -date.timeIntervalSinceNow;
  if (ago < 60) return @"hace un momento";
  if (ago < 3600) return [NSString stringWithFormat:@"hace %d min", (int)(ago / 60)];
  NSDateFormatter *f = [[NSDateFormatter alloc] init];
  f.dateFormat = [NSCalendar.currentCalendar isDateInToday:date] ? @"'hoy' HH:mm" : @"dd/MM HH:mm";
  return [f stringFromDate:date];
}

- (NSString *)summaryLine {
  if (!self.status) {
    return [NSFileManager.defaultManager fileExistsAtPath:self.statusPath]
               ? @"Estado ilegible (status.json)"
               : @"Todavía no se ha sincronizado";
  }
  NSDate *started = [self dateFromISO:[self field:@"started" of:self.status]];
  NSDate *finished = [self dateFromISO:[self field:@"finished" of:self.status]];
  NSString *result = [self field:@"result" of:self.status];
  if (self.isRunning) {
    return [NSString stringWithFormat:@"Sincronizando… (empezó %@)", [self describeDate:started]];
  }
  NSString *what = @"terminada";
  if ([result isEqualToString:@"ok"]) what = @"correcta";
  else if ([result isEqualToString:@"error"]) what = @"con errores";
  else if ([result isEqualToString:@"interrupted"]) what = @"interrumpida";
  return [NSString stringWithFormat:@"Última sincronización %@: %@", what,
                                    [self describeDate:finished]];
}

#pragma mark - LaunchAgent

- (BOOL)agentLoaded {
  NSTask *task = [[NSTask alloc] init];
  task.launchPath = @"/bin/launchctl";
  task.arguments = @[ @"list", kAgentLabel ];
  task.standardOutput = NSFileHandle.fileHandleWithNullDevice;
  task.standardError = NSFileHandle.fileHandleWithNullDevice;
  @try {
    [task launch];
    [task waitUntilExit];
  } @catch (NSException *e) {
    return NO;
  }
  return task.terminationStatus == 0;
}

- (void)toggleAgent:(NSMenuItem *)item {
  BOOL loaded = self.agentLoaded;
  if (!loaded && ![NSFileManager.defaultManager fileExistsAtPath:self.agentPlistPath]) {
    [self alert:@"No está instalado el LaunchAgent"
           info:[NSString stringWithFormat:@"Copia launchd/%@.plist a ~/Library/LaunchAgents/ "
                                           @"(ver BackupDrive/README.md).",
                                           kAgentLabel]];
    return;
  }
  NSTask *task = [[NSTask alloc] init];
  task.launchPath = @"/bin/launchctl";
  task.arguments = @[ loaded ? @"unload" : @"load", @"-w", self.agentPlistPath ];
  [task launch];
  [task waitUntilExit];
}

#pragma mark - Acciones

- (void)syncNow:(NSMenuItem *)item {
  if (self.isRunning) return;
  if (![NSFileManager.defaultManager isExecutableFileAtPath:kSyncScript]) {
    [self alert:@"No encuentro el motor de BackupDrive"
           info:[NSString stringWithFormat:@"Falta %@ (ver BackupDrive/README.md).", kSyncScript]];
    return;
  }
  // El script tiene su propio bloqueo: si launchd ya está sincronizando, sale sin hacer nada.
  NSTask *task = [[NSTask alloc] init];
  task.launchPath = kSyncScript;
  task.standardInput = NSFileHandle.fileHandleWithNullDevice;
  task.standardOutput = NSFileHandle.fileHandleWithNullDevice;
  task.standardError = NSFileHandle.fileHandleWithNullDevice;
  __weak AppDelegate *weakSelf = self;
  task.terminationHandler = ^(NSTask *t) {
    dispatch_async(dispatch_get_main_queue(), ^{
      weakSelf.manualRun = nil;
      [weakSelf reloadStatusForce:YES];
    });
  };
  self.manualRun = task;
  [task launch];
  [self updateIcon];
}

- (void)openLog:(NSMenuItem *)item {
  NSString *log = self.logPath;
  if (![NSFileManager.defaultManager fileExistsAtPath:log]) {
    [self alert:@"Todavía no hay registro" info:log];
    return;
  }
  [NSWorkspace.sharedWorkspace openFile:log withApplication:@"Console"];
}

- (void)openConfigFolder:(NSMenuItem *)item {
  [NSFileManager.defaultManager createDirectoryAtPath:self.appSupportDir
                          withIntermediateDirectories:YES
                                           attributes:nil
                                                error:nil];
  [NSWorkspace.sharedWorkspace openFile:self.appSupportDir];
}

- (void)openFolder:(NSMenuItem *)item {
  [NSWorkspace.sharedWorkspace openFile:item.representedObject];
}

- (void)about:(NSMenuItem *)item {
  [NSApp activateIgnoringOtherApps:YES];
  [NSApp orderFrontStandardAboutPanel:nil];
}

- (void)alert:(NSString *)message info:(NSString *)info {
  [NSApp activateIgnoringOtherApps:YES];
  NSAlert *alert = [[NSAlert alloc] init];
  alert.messageText = message;
  alert.informativeText = info ?: @"";
  [alert runModal];
}

#pragma mark - Menú

- (NSMenuItem *)addItem:(NSString *)title action:(SEL)action to:(NSMenu *)menu {
  NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:@""];
  item.target = self;
  item.enabled = action != NULL;
  [menu addItem:item];
  return item;
}

// Se reconstruye cada vez que se abre: así siempre muestra el estado actual.
- (void)menuNeedsUpdate:(NSMenu *)menu {
  [self reloadStatusForce:YES];
  [menu removeAllItems];

  [self addItem:self.summaryLine action:NULL to:menu];

  NSArray *profiles = self.status[@"profiles"];
  if ([profiles isKindOfClass:NSArray.class] && profiles.count) {
    for (NSDictionary *p in profiles) {
      if (![p isKindOfClass:NSDictionary.class]) continue;
      NSString *result = [self field:@"result" of:p];
      NSString *mark = [result isEqualToString:@"ok"] ? @"✓" : @"✗";
      NSString *local = [self field:@"local" of:p];
      NSString *title = [NSString stringWithFormat:@"%@ %@ ↔ %@", mark,
                                                   local.lastPathComponent,
                                                   [self field:@"remote" of:p]];
      if (![result isEqualToString:@"ok"]) {
        id code = p[@"exit"];
        title = [title stringByAppendingFormat:@"  (%@%@)",
                                               [result isEqualToString:@"skipped"] ? @"omitido"
                                                                                   : @"error",
                                               [code isKindOfClass:NSNumber.class]
                                                   ? [NSString stringWithFormat:@" %@", code]
                                                   : @""];
      }
      NSMenuItem *item = [self addItem:title action:@selector(openFolder:) to:menu];
      item.representedObject = local;
      item.toolTip = [NSString stringWithFormat:@"%@\nAbrir la carpeta local", local];
      item.enabled = [NSFileManager.defaultManager fileExistsAtPath:local];
      item.indentationLevel = 1;
    }
  }

  [menu addItem:NSMenuItem.separatorItem];
  NSMenuItem *sync = [self addItem:@"Sincronizar ahora" action:@selector(syncNow:) to:menu];
  sync.enabled = !self.isRunning;
  NSMenuItem *agent = [self addItem:@"Sincronizar cada hora"
                             action:@selector(toggleAgent:)
                                 to:menu];
  agent.state = self.agentLoaded ? NSControlStateValueOn : NSControlStateValueOff;

  [menu addItem:NSMenuItem.separatorItem];
  [self addItem:@"Ver registro" action:@selector(openLog:) to:menu];
  [self addItem:@"Abrir carpeta de configuración" action:@selector(openConfigFolder:) to:menu];

  [menu addItem:NSMenuItem.separatorItem];
  [self addItem:@"Acerca de BackupDrive" action:@selector(about:) to:menu];
  NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"Salir de BackupDrive"
                                                action:@selector(terminate:)
                                         keyEquivalent:@"q"];
  quit.target = NSApp;
  [menu addItem:quit];
}

@end

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
